import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM_EMAIL = Deno.env.get("FROM_EMAIL") || "Romtegner <noreply@invite.arqely.com>";
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
    const { user_email, user_name, org_name, type, message } = await req.json();

    if (!RESEND_API_KEY || !ADMIN_EMAIL) {
      return new Response(JSON.stringify({ error: "Email config missing" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

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
                <tr><td style="padding: 4px 12px 4px 0; font-weight: 600; color: #64748b;">Fra:</td><td>${user_name || "Ikke oppgitt"} (${user_email || "—"})</td></tr>
                ${org_name ? `<tr><td style="padding: 4px 12px 4px 0; font-weight: 600; color: #64748b;">Org:</td><td>${org_name}</td></tr>` : ""}
              </table>
            </div>
            <div style="background: #fffbeb; border: 1px solid #fde68a; border-radius: 12px; padding: 20px;">
              <p style="color: #1e293b; font-size: 14px; line-height: 1.6; margin: 0; white-space: pre-wrap;">${message}</p>
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
