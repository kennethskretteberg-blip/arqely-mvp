// ============================================================================
// Supabase Edge Function: notify-admin-registration
// ----------------------------------------------------------------------------
// Varsler ADMIN_EMAIL om en ny registrering.
//
// Deploy:  supabase functions deploy notify-admin-registration
// Secrets: RESEND_API_KEY, FROM_EMAIL, ADMIN_EMAIL
//
// ⚠ HVORFOR DENNE BLE SKREVET OM (maalt 07.10.2026)
//
// Den forrige utgaven sendte e-post paa et HELT TOMT POST-kall uten noen
// Authorization-header — bekreftet live: 200 {"success":true}, og e-posten kom fram med
// «Ny registrering: undefined». Hvem som helst kunne altsaa fylle Kenneths innboks og toemme
// Resend-kvoten, slik at ekte invitasjoner sluttet aa gaa ut.
//
// Den kan IKKE kreve innlogging: den kalles rett etter auth.signUp(), og med
// e-postbekreftelse paa har brukeren ingen sesjon enda. I stedet beviser kalleren at
// registreringen FINNES: klienten sender bruker-id-en fra signUp-svaret, og funksjonen
// slaar den opp med service role og krever at kontoen er opprettet for under 15 minutter
// siden. Det kan ikke forfalskes uten faktisk aa registrere seg — som er den legitime flyten.
// E-postadressen tas fra oppslaget, aldri fra body.
//
// Navn/firma/melding kommer fortsatt fra body (de finnes ingen andre steder enda), men
// escapes naa — foer gikk de UESCAPET inn i HTML-en i e-posten til Kenneth.
// ============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const FROM_DEFAULT = "Varmeplan <noreply@varmeplan.no>";
const MAKS_ALDER_MS = 15 * 60 * 1000;

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
    const userId = String(b?.user_id || "").trim();
    const name = String(b?.name || "").slice(0, 200);
    const company = String(b?.company || "").slice(0, 200);
    const message = String(b?.message || "").slice(0, 2000);

    const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
    const FROM_EMAIL = Deno.env.get("FROM_EMAIL") || FROM_DEFAULT;
    const ADMIN_EMAIL = Deno.env.get("ADMIN_EMAIL") || "";
    if (!RESEND_API_KEY || !ADMIN_EMAIL) return json({ error: "Email config missing" }, 500);

    if (!userId) return json({ error: "user_id kreves" }, 400);

    // Beviset: kontoen MAA finnes og vere fersk. Kan ikke forfalskes uten aa registrere seg.
    const db = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );
    const { data: u } = await db.auth.admin.getUserById(userId);
    const konto = u?.user;
    if (!konto) return json({ error: "ukjent bruker" }, 404);
    const alder = Date.now() - new Date(konto.created_at).getTime();
    if (!(alder >= 0 && alder < MAKS_ALDER_MS)) {
      return json({ error: "registreringen er ikke fersk" }, 403);
    }
    const email = konto.email || "";   // fra oppslaget, aldri fra body

    const emailRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        Authorization: `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: FROM_EMAIL,
        to: [ADMIN_EMAIL],
        subject: `Ny registrering: ${name || email}`,
        html: `<meta charset="utf-8">
          <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 560px; margin: 0 auto; padding: 40px 24px;">
            <h2 style="color: #0891b2; font-size: 24px; margin-bottom: 24px;">Ny brukerforespørsel</h2>

            <div style="background: #fffbeb; border: 1px solid #fde68a; border-radius: 12px; padding: 20px; margin-bottom: 24px;">
              <table style="font-size: 14px; color: #1e293b; width: 100%;">
                <tr><td style="padding: 4px 12px 4px 0; font-weight: 600; color: #64748b;">Navn:</td><td>${esc(name) || "Ikke oppgitt"}</td></tr>
                <tr><td style="padding: 4px 12px 4px 0; font-weight: 600; color: #64748b;">E-post:</td><td>${esc(email)}</td></tr>
                ${company ? `<tr><td style="padding: 4px 12px 4px 0; font-weight: 600; color: #64748b;">Firma:</td><td>${esc(company)}</td></tr>` : ""}
                ${message ? `<tr><td style="padding: 4px 12px 4px 0; font-weight: 600; color: #64748b;">Melding:</td><td style="font-style: italic;">"${esc(message)}"</td></tr>` : ""}
              </table>
            </div>

            <p style="color: #475569; font-size: 14px;">
              Logg inn i Romtegner og gå til Admin-panelet for å godkjenne eller avvise forespørselen.
            </p>
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
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
