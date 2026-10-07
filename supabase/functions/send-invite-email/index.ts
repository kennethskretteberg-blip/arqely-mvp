// ============================================================================
// Supabase Edge Function: send-invite-email
// ----------------------------------------------------------------------------
// Sender en organisasjonsinvitasjon. Klienten oppgir KUN invitasjonens token;
// mottaker, lenke, organisasjonsnavn og avsendernavn slaas opp server-side.
//
// Deploy:  supabase functions deploy send-invite-email
// Secrets: RESEND_API_KEY, FROM_EMAIL  (SUPABASE_URL / SERVICE_ROLE_KEY er innebygd)
//
// ⚠ HVORFOR DENNE BLE SKREVET OM (maalt 07.10.2026)
//
// Den forrige utgaven leste ALDRI `Authorization`, og tok bade `to` OG `invite_url` rett fra
// klientens body. Et kall uten noen Authorization-header i det hele tatt naadde vaar egen kode
// (bekreftet: 400 «Missing 'to' or 'invite_url'» fra denne funksjonen, ikke 401 fra
// plattformen). Hvem som helst kunne altsaa sende en VILKAARLIG lenke til en VILKAARLIG adresse
// med Varmeplan som avsender — en ferdig phishing-kanal paa vaart eget, verifiserte domene.
// `org_name` og `invited_by` ble i tillegg interpolert UESCAPET inn i HTML-en.
//
// Og: Supabase sin `verify_jwt` er ikke et vern her. Anon-noekkelen ER en gyldig JWT og ligger
// aapent i klienten. Brukeren verifiseres derfor eksplisitt med auth.getUser(jwt).
//
// Monsteret er det samme som `kundelenke-mail`: funksjonen slaar opp alt den sender selv.
// ============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const FROM_DEFAULT = "Varmeplan <noreply@varmeplan.no>";
const PUBLIC_BASE_URL = "https://varmeplan.no";   // aldri kallerens origin

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status, headers: { ...cors, "Content-Type": "application/json" },
  });
}

const esc = (s: unknown) =>
  String(s ?? "").replace(/[&<>"]/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]!));

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "POST kreves" }, 405);

  try {
    const body = await req.json().catch(() => ({}));
    const token = String(body?.token || "").trim();
    if (!token) {
      // Eldre klienter sendte `to` + `invite_url`. Den kontrakten finnes ikke lenger.
      return json({ error: "token kreves (last siden på nytt)" }, 400);
    }

    const db = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Lag 1: en EKTE bruker, foer noe arbeid gjoeres og foer noe slaas opp.
    const auth = req.headers.get("Authorization") || "";
    const jwt = auth.startsWith("Bearer ") ? auth.slice(7) : "";
    if (!jwt) return json({ error: "innlogging kreves" }, 401);
    const { data: userRes } = await db.auth.getUser(jwt);
    const bruker = userRes?.user;
    if (!bruker) return json({ error: "innlogging kreves" }, 401);

    const { data: inv } = await db.from("org_invitations")
      .select("*").eq("token", token).maybeSingle();
    if (!inv) return json({ error: "ukjent invitasjon" }, 404);
    if (inv.status !== "pending") return json({ error: "invitasjonen er ikke lenger åpen" }, 409);
    if (!inv.email) return json({ error: "invitasjonen mangler mottaker" }, 409);

    // Lag 2: kalleren maa ha rett til aa invitere til NETTOPP denne organisasjonen.
    const superadmin = (bruker.app_metadata as Record<string, unknown> | undefined)?.is_superadmin === true;
    if (!superadmin) {
      if (!inv.org_id) return json({ error: "kun superadmin kan sende invitasjoner uten organisasjon" }, 403);
      const { data: medlem } = await db.from("organization_members")
        .select("role").eq("org_id", inv.org_id).eq("user_id", bruker.id).maybeSingle();
      if (!medlem) return json({ error: "ikke medlem av organisasjonen" }, 403);
      if (medlem.role !== "owner" && medlem.role !== "admin") {
        return json({ error: "krever eier- eller admin-rolle" }, 403);
      }
    }

    const apiKey = Deno.env.get("RESEND_API_KEY");
    if (!apiKey) return json({ error: "RESEND_API_KEY mangler" }, 500);

    // Alt innhold hentes server-side. Fra klienten kom bare tokenet.
    const { data: org } = inv.org_id
      ? await db.from("organizations").select("name").eq("id", inv.org_id).maybeSingle()
      : { data: null };
    const orgNavn = org?.name || "Varmeplan";

    let invitertAv = "En administrator";
    if (inv.invited_by) {
      const { data: prof } = await db.from("profiles")
        .select("full_name").eq("id", inv.invited_by).maybeSingle();
      if (prof?.full_name) invitertAv = prof.full_name;
      else {
        const { data: u } = await db.auth.admin.getUserById(inv.invited_by);
        if (u?.user?.email) invitertAv = u.user.email;
      }
    }

    const url = `${PUBLIC_BASE_URL}/?invite=${encodeURIComponent(inv.token)}`;

    const emailRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=utf-8", Authorization: `Bearer ${apiKey}` },
      body: JSON.stringify({
        from: Deno.env.get("FROM_EMAIL") ?? FROM_DEFAULT,
        to: [inv.email],
        subject: `Du er invitert til ${orgNavn}`,
        html: `<meta charset="utf-8">
          <div style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;max-width:560px;margin:0 auto;padding:40px 24px">
            <h2 style="color:#0891b2;font-size:24px;margin-bottom:8px">Varmeplan</h2>
            <p style="color:#666;font-size:14px;margin-bottom:24px">Prosjektering av elektrisk varme</p>
            <div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:24px;margin-bottom:24px">
              <h3 style="color:#1e293b;font-size:18px;margin:0 0 12px 0">Du er invitert</h3>
              <p style="color:#475569;font-size:14px;line-height:1.6;margin:0 0 8px 0">
                <strong>${esc(invitertAv)}</strong> har invitert deg til <strong>${esc(orgNavn)}</strong>.
              </p>
              <p style="color:#475569;font-size:14px;line-height:1.6;margin:0">
                Klikk på knappen under for å opprette kontoen din.
              </p>
            </div>
            <a href="${esc(url)}" style="display:inline-block;background:#0891b2;color:#fff;text-decoration:none;padding:14px 32px;border-radius:8px;font-size:15px;font-weight:600">Opprett konto</a>
            <p style="color:#94a3b8;font-size:12px;margin-top:32px;line-height:1.5">
              Hvis du ikke forventet denne invitasjonen, kan du se bort fra e-posten.<br>
              Lenken virker kun én gang.
            </p>
          </div>`,
      }),
    });

    if (!emailRes.ok) {
      const t = await emailRes.text();
      console.error("Resend error:", t);
      return json({ error: "Kunne ikke sende e-post", details: t }, 500);
    }
    const result = await emailRes.json();
    return json({ success: true, id: result.id, sent_to: inv.email });

  } catch (err) {
    console.error("send-invite-email:", err);
    return json({ error: String((err as Error).message || err) }, 500);
  }
});
