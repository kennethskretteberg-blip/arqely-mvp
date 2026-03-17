// Supabase Edge Function: send-invite-email
// Deploy with: supabase functions deploy send-invite-email
//
// Required secrets (set via Supabase dashboard or CLI):
//   RESEND_API_KEY — API key from resend.com (free tier: 100 emails/day)
//   FROM_EMAIL     — Verified sender email (e.g. noreply@arqely.no)
//
// Alternative: Use Supabase's built-in SMTP by configuring
// Auth > Email Templates in the Supabase dashboard.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM_EMAIL = Deno.env.get("FROM_EMAIL") || "Romtegner <noreply@arqely.no>";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { to, invite_url, org_name, invited_by } = await req.json();

    if (!to || !invite_url) {
      return new Response(JSON.stringify({ error: "Missing 'to' or 'invite_url'" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (!RESEND_API_KEY) {
      return new Response(JSON.stringify({ error: "RESEND_API_KEY not configured" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Send email via Resend
    const emailRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: FROM_EMAIL,
        to: [to],
        subject: `Du er invitert til ${org_name || "Romtegner"}`,
        html: `
          <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 560px; margin: 0 auto; padding: 40px 24px;">
            <h2 style="color: #0891b2; font-size: 24px; margin-bottom: 8px;">Romtegner</h2>
            <p style="color: #666; font-size: 14px; margin-bottom: 24px;">Prosjektering av elektrisk varme</p>

            <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; margin-bottom: 24px;">
              <h3 style="color: #1e293b; font-size: 18px; margin: 0 0 12px 0;">Du er invitert! 🎉</h3>
              <p style="color: #475569; font-size: 14px; line-height: 1.6; margin: 0 0 8px 0;">
                <strong>${invited_by || "En administrator"}</strong> har invitert deg til
                <strong>${org_name || "Romtegner"}</strong>.
              </p>
              <p style="color: #475569; font-size: 14px; line-height: 1.6; margin: 0;">
                Klikk på knappen under for å opprette din konto og få tilgang.
              </p>
            </div>

            <a href="${invite_url}"
               style="display: inline-block; background: #0891b2; color: white; text-decoration: none;
                      padding: 14px 32px; border-radius: 8px; font-size: 15px; font-weight: 600;">
              Opprett konto
            </a>

            <p style="color: #94a3b8; font-size: 12px; margin-top: 32px; line-height: 1.5;">
              Hvis du ikke forventet denne invitasjonen, kan du ignorere denne e-posten.<br>
              Lenken fungerer kun én gang.
            </p>
          </div>
        `,
      }),
    });

    if (!emailRes.ok) {
      const errBody = await emailRes.text();
      console.error("Resend error:", errBody);
      return new Response(JSON.stringify({ error: "Email sending failed", details: errBody }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const result = await emailRes.json();
    return new Response(JSON.stringify({ success: true, id: result.id }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Error:", err);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
