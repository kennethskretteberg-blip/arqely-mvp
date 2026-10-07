// ============================================================================
// Supabase Edge Function: send-feedback
// ----------------------------------------------------------------------------
// Sender en tilbakemelding fra en INNLOGGET bruker til ADMIN_EMAIL.
//
// Deploy:  supabase functions deploy send-feedback
// Secrets: RESEND_API_KEY, FROM_EMAIL, ADMIN_EMAIL
//
// ⚠ HVORFOR DENNE BLE SKREVET OM (maalt 07.10.2026)
//
// Den forrige utgaven sendte e-post paa et HELT TOMT POST-kall uten noen
// Authorization-header — bekreftet live: 200 {"success":true}. Hvem som helst kunne fylle
// Kenneths innboks og toemme Resend-kvoten. I tillegg kom avsenderidentiteten
// (user_email / user_name / org_name) fra klientens body, saa en melding kunne tillegges en
// hvilken som helst bruker, og alt gikk UESCAPET inn i HTML-en.
//
// Naa: innlogging kreves, IDENTITETEN hentes fra JWT-en og databasen, og bare selve meldingen
// kommer fra body — escapet. Supabase sin `verify_jwt` er ikke nok: anon-noekkelen er en
// gyldig JWT og ligger aapent i klienten.
// ============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const FROM_DEFAULT = "Varmeplan <noreply@varmeplan.no>";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const esc = (s: unknown) =>
  String(s ?? "").replace(/[&<>"]/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]!));

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status, headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") return json({ error: "POST kreves" }, 405);
  try {
    const b = await req.json().catch(() => ({}));
    const type = String(b?.type || "general");
    const message = String(b?.message || "").trim().slice(0, 4000);

    const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
    const FROM_EMAIL = Deno.env.get("FROM_EMAIL") || FROM_DEFAULT;
    const ADMIN_EMAIL = Deno.env.get("ADMIN_EMAIL") || "";
    if (!RESEND_API_KEY || !ADMIN_EMAIL) return json({ error: "Email config missing" }, 500);
    if (!message) return json({ error: "melding kreves" }, 400);

    const db = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Innlogging foerst — foer noe arbeid gjoeres.
    const auth = req.headers.get("Authorization") || "";
    const jwt = auth.startsWith("Bearer ") ? auth.slice(7) : "";
    if (!jwt) return json({ error: "innlogging kreves" }, 401);
    const { data: userRes } = await db.auth.getUser(jwt);
    const bruker = userRes?.user;
    if (!bruker) return json({ error: "innlogging kreves" }, 401);

    // Identiteten slaas opp — den kan ikke oppgis av kalleren.
    const user_email = bruker.email || "";
    const { data: prof } = await db.from("profiles")
      .select("full_name").eq("id", bruker.id).maybeSingle();
    const user_name = prof?.full_name || "";
    const { data: medl } = await db.from("organization_members")
      .select("organizations(name)").eq("user_id", bruker.id).limit(1).maybeSingle();
    const org_name = (medl as { organizations?: { name?: string } } | null)?.organizations?.name || "";

    const typeLabels: Record<string, string> = { bug: "🐛 Feilrapport", feature: "💡 Forslag", general: "💬 Generelt" };
    const typeLabel = typeLabels[type] || typeLabels.general;

    const emailRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: FROM_EMAIL,
        to: [ADMIN_EMAIL],
        subject: `${typeLabel} fra ${user_name || user_email || "bruker"}`,
        html: `
          <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 560px; margin: 0 auto; padding: 40px 24px;">
            <h2 style="color: #0891b2; font-size: 24px; margin-bottom: 24px;">Ny tilbakemelding</h2>
            <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; margin-bottom: 24px;">
              <table style="font-size: 14px; color: #1e293b; width: 100%;">
                <tr><td style="padding: 4px 12px 4px 0; font-weight: 600; color: #64748b;">Type:</td><td>${typeLabel}</td></tr>
                <tr><td style="padding: 4px 12px 4px 0; font-weight: 600; color: #64748b;">Fra:</td><td>${esc(user_name) || "Ikke oppgitt"} (${esc(user_email) || "—"})</td></tr>
                ${org_name ? `<tr><td style="padding: 4px 12px 4px 0; font-weight: 600; color: #64748b;">Org:</td><td>${esc(org_name)}</td></tr>` : ""}
              </table>
            </div>
            <div style="background: #fffbeb; border: 1px solid #fde68a; border-radius: 12px; padding: 20px;">
              <p style="color: #1e293b; font-size: 14px; line-height: 1.6; margin: 0; white-space: pre-wrap;">${esc(message)}</p>
            </div>
          </div>
        `,
      }),
    });

    if (!emailRes.ok) {
      const errBody = await emailRes.text();
      return new Response(JSON.stringify({ error: "Email failed", details: errBody }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
