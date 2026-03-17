// Supabase Edge Function: notify-admin-registration
// Deploy with: supabase functions deploy notify-admin-registration
//
// Trigger: Call from client after successful registration,
// OR set up as a Database Webhook on profiles table INSERT.
//
// Required secrets:
//   RESEND_API_KEY — API key from resend.com
//   FROM_EMAIL     — Verified sender email
//   ADMIN_EMAIL    — Email to receive notifications

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM_EMAIL = Deno.env.get("FROM_EMAIL") || "Romtegner <noreply@arqely.no>";
const ADMIN_EMAIL = Deno.env.get("ADMIN_EMAIL") || "";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { name, email, company, message } = await req.json();

    if (!RESEND_API_KEY || !ADMIN_EMAIL) {
      return new Response(JSON.stringify({ error: "Email config missing" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const emailRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: FROM_EMAIL,
        to: [ADMIN_EMAIL],
        subject: `Ny registrering: ${name || email}`,
        html: `
          <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 560px; margin: 0 auto; padding: 40px 24px;">
            <h2 style="color: #0891b2; font-size: 24px; margin-bottom: 24px;">Ny brukerforespørsel</h2>

            <div style="background: #fffbeb; border: 1px solid #fde68a; border-radius: 12px; padding: 20px; margin-bottom: 24px;">
              <table style="font-size: 14px; color: #1e293b; width: 100%;">
                <tr><td style="padding: 4px 12px 4px 0; font-weight: 600; color: #64748b;">Navn:</td><td>${name || "Ikke oppgitt"}</td></tr>
                <tr><td style="padding: 4px 12px 4px 0; font-weight: 600; color: #64748b;">E-post:</td><td>${email}</td></tr>
                ${company ? `<tr><td style="padding: 4px 12px 4px 0; font-weight: 600; color: #64748b;">Firma:</td><td>${company}</td></tr>` : ""}
                ${message ? `<tr><td style="padding: 4px 12px 4px 0; font-weight: 600; color: #64748b;">Melding:</td><td style="font-style: italic;">"${message}"</td></tr>` : ""}
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
