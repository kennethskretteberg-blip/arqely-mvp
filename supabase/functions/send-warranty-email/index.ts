// ============================================================================
// Supabase Edge Function: send-warranty-email
// ----------------------------------------------------------------------------
// Sender rutine-e-post for dokumentasjonsmodulen:
//   - type 'certificate' : kopi av garantibevis til montør / fast firma-adresse /
//                          leverandørens mottaker-e-post (suppliers.recipient_email).
//   - type 'claim'       : rutinevarsel til kunde når en reklamasjonssak opprettes.
//
// IKKE AKTIV før den er rullet ut + secrets er satt (se README.md i denne mappa).
// Frontend viser i dag mottakerne som info; selve utsendingen skjer her.
//
// Deploy:  supabase functions deploy send-warranty-email
// Secrets: RESEND_API_KEY, FROM_EMAIL  (SUPABASE_URL / SERVICE_ROLE_KEY er innebygd)
// ============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

async function sendEmail(to: string[], subject: string, html: string) {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  const from = Deno.env.get("FROM_EMAIL") ?? "Varmeplan <noreply@varmeplan.no>";
  if (!apiKey) throw new Error("RESEND_API_KEY mangler (sett som secret).");
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from, to, subject, html }),
  });
  if (!res.ok) throw new Error(`Resend-feil ${res.status}: ${await res.text()}`);
  return await res.json();
}

const esc = (s: unknown) =>
  String(s ?? "").replace(/[&<>"]/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]!));

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "POST kreves" }, 405);

  try {
    const { type, id, to } = await req.json();
    if (!type || !id) return json({ error: "type og id kreves" }, 400);

    // Service-role-klient (omgår RLS — funksjonen kjører server-side).
    const db = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    let subject = "";
    let html = "";
    const recipients: string[] = Array.isArray(to) ? to : (to ? [to] : []);

    if (type === "certificate") {
      const { data: c, error } = await db
        .from("warranty_certificates")
        .select("*, suppliers(display_name, recipient_email), certificate_products(product_name, kind, effect_w, nominal_ohm)")
        .eq("id", id).single();
      if (error || !c) return json({ error: "Fant ikke garantibevis" }, 404);

      const supplierEmail = c.suppliers?.recipient_email;
      if (supplierEmail && !recipients.includes(supplierEmail)) recipients.push(supplierEmail);
      const prods = (c.certificate_products ?? [])
        .map((p: any) => `<li>${esc(p.product_name)} — ${esc(p.effect_w)} W, nominell ${esc(p.nominal_ohm)} Ω</li>`).join("");
      subject = `Garantibevis ${esc(c.garanti_id)} — ${esc(c.project_name)}`;
      html = `
        <h2>Garantibevis ${esc(c.garanti_id)}</h2>
        <p><b>Prosjekt:</b> ${esc(c.project_name)}<br>
           <b>Adresse:</b> ${esc(c.project_address)}<br>
           <b>Rom:</b> ${esc(c.room_name)}<br>
           <b>Montør:</b> ${esc(c.installer_name)} (${esc(c.installer_company)})</p>
        <p><b>Produkter:</b></p><ul>${prods}</ul>
        <p>Beviset med måleverdier, foto og signatur er lagret i Varmeplan.</p>`;
    } else if (type === "claim") {
      const { data: cl, error } = await db
        .from("claims")
        .select("*, warranty_certificates(project_name, project_address, room_name, installer_company)")
        .eq("id", id).single();
      if (error || !cl) return json({ error: "Fant ikke reklamasjonssak" }, 404);

      if (cl.customer_email && !recipients.includes(cl.customer_email)) recipients.push(cl.customer_email);
      const cert = cl.warranty_certificates ?? {};
      subject = `Reklamasjonssak ${esc(cl.claim_no)} opprettet`;
      html = `
        <h2>Reklamasjonssak ${esc(cl.claim_no)}</h2>
        <p>Det er registrert en feilmelding på varmeanlegget på <b>${esc(cert.project_address)}</b> (${esc(cert.room_name)}).</p>
        <p><b>Beskrivelse:</b> ${esc(cl.fault_description)}</p>
        <p>Saksnummer <b>${esc(cl.claim_no)}</b> følger all videre korrespondanse.
           Feilsøkefirma kontaktes etter at leverandøren har godkjent saken.</p>`;
    } else {
      return json({ error: "Ukjent type (forventet 'certificate' eller 'claim')" }, 400);
    }

    if (!recipients.length) return json({ error: "Ingen mottakere" }, 400);
    const result = await sendEmail(recipients, subject, html);
    return json({ ok: true, sent_to: recipients, id: result?.id ?? null });
  } catch (e) {
    return json({ error: String((e as Error).message ?? e) }, 500);
  }
});
