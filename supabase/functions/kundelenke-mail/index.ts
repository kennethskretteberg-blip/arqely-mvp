// ============================================================================
// Supabase Edge Function: kundelenke-mail
// ----------------------------------------------------------------------------
// To meldinger, en funksjon (spec-kundelenke regel 9):
//   kind='invite'    Kenneth sender kundelenken til kunden.    Krever innlogget bruker.
//   kind='answered'  Kunden har sendt inn maal -> varsel til   Anonymt kall tillatt.
//                    den som laget lenken.
//
// Deploy:  supabase functions deploy kundelenke-mail
// Secrets: RESEND_API_KEY, FROM_EMAIL   (SUPABASE_URL / SERVICE_ROLE_KEY er innebygd)
//
// ⚠ SIKKERHET — STEG 0-funn som formet denne funksjonen:
//
// 1) Plattformens `verify_jwt` er IKKE det samme som «innlogget bruker». Supabase godtar
//    ANON-NOKKELEN som en gyldig JWT, og den ligger apent i klienten. En funksjon som stoler
//    paa verify_jwt alene er derfor i praksis apen for alle. `kind='invite'` verifiserer
//    derfor brukeren EKSPLISITT med auth.getUser(jwt) og sjekker medlemskap i lenkens org.
//
// 2) Ingen av de eksisterende funksjonene leser kallerens Authorization-header i det hele
//    tatt. `send-invite-email` tar bade mottaker OG lenke-URL rett fra klientens body — den
//    kan altsa sende hva som helst til hvem som helst. Den feilen gjentas ikke her:
//    alt innhold (org-navn, prosjektnavn, token, utlopsdato) slaas opp server-side med
//    service role. Fra klienten kommer BARE: hvilken lenke (token), og for 'invite' hvilken
//    mottaker + en fritekstmelding — begge validert og escapet.
//    `send-warranty-email` er monsteret som ble kopiert: den slar opp alt selv.
//
// 3) `kind='answered'` ma kunne kalles anonymt (kunden er ikke innlogget). Den er derfor
//    snevret inn i tre lag: lenken MA ha status='answered', svaret MA vere under 10 minutter
//    gammelt, og det sendes maks ett varsel per lenke per 10 minutter (last_notified_at).
//    Mottakeren er ALLTID lenkens egen notify_email — aldri noe fra kallet.
// ============================================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// varmeplan.no er verifisert i Resend (Kenneth, 07.10.2026), og FROM_EMAIL-secreten er satt.
// Secreten vinner uansett — denne fallbacken fyrer bare om den skulle mangle — men de to skal
// peke samme vei, saa ingen blir overrasket av en avsender fra et annet domene.
// NB: FROM_EMAIL er en PROSJEKT-secret, delt av alle fem e-postfunksjonene.
const FROM_DEFAULT = "Varmeplan <noreply@varmeplan.no>";
const PUBLIC_BASE_URL = "https://varmeplan.no";   // spec regel 8 — aldri kallerens origin
const NOTIFY_WINDOW_MS = 10 * 60 * 1000;

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status, headers: { ...cors, "Content-Type": "application/json" },
  });
}

const esc = (s: unknown) =>
  String(s ?? "").replace(/[&<>"]/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]!));

// Bevisst konservativ: en adresse, ingen mellomrom, ett @, punktum i domenet.
const EMAIL_RE = /^[^\s@,;<>]+@[^\s@,;<>]+\.[^\s@,;<>]{2,}$/;

async function sendEmail(opts: { to: string[]; subject: string; html: string; fromName?: string; replyTo?: string }) {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) throw new Error("RESEND_API_KEY mangler (sett som secret).");
  const base = Deno.env.get("FROM_EMAIL") ?? FROM_DEFAULT;
  // Avsendernavnet byttes til org-navnet, men adressen er ALLTID den verifiserte.
  const addr = base.includes("<") ? base.slice(base.indexOf("<")) : `<${base}>`;
  const from = opts.fromName ? `${opts.fromName.replace(/["<>]/g, "")} ${addr}` : base;
  const body: Record<string, unknown> = { from, to: opts.to, subject: opts.subject, html: opts.html };
  if (opts.replyTo) body.reply_to = opts.replyTo;
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`Resend-feil ${res.status}: ${await res.text()}`);
  return await res.json();
}

function shell(inner: string) {
  return `<div style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;max-width:560px;margin:0 auto;padding:36px 24px;color:#1a1d21">
    <div style="font-size:20px;font-weight:700;color:#0891b2;margin-bottom:2px">Varmeplan</div>
    <div style="color:#6b7280;font-size:13px;margin-bottom:24px">Prosjektering av elektrisk varme</div>
    ${inner}
    <div style="color:#9ca3af;font-size:11px;margin-top:28px;border-top:1px solid #e5e7eb;padding-top:14px">
      Denne e-posten ble sendt fra Varmeplan. Svar gaar til avsenderen av lenken.
    </div></div>`;
}

function button(href: string, label: string) {
  return `<div style="margin:22px 0"><a href="${esc(href)}"
    style="display:inline-block;background:#0891b2;color:#fff;text-decoration:none;padding:12px 22px;border-radius:8px;font-size:14px;font-weight:600">${esc(label)}</a></div>
    <div style="font-size:11px;color:#9ca3af">Virker ikke knappen: ${esc(href)}</div>`;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "POST kreves" }, 405);

  try {
    const { kind, token, to, message } = await req.json();
    if (kind !== "invite" && kind !== "answered") return json({ error: "ugyldig kind" }, 400);
    if (!token || typeof token !== "string") return json({ error: "token kreves" }, 400);

    const db = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // ⚠ MAALT MOT DEN DEPLOYEDE FUNKSJONEN: et `invite`-kall UTEN innlogging fikk
    // 404 «ukjent lenke» i stedet for 401 — altsa ble lenken slaatt opp FOR autentiseringen.
    // Tokenet er en v4-UUID, saa oppregning er praktisk umulig, men svaret rapet likevel om et
    // gitt token finnes, til en kaller som ikke hadde noe der aa gjore. Autentiser foerst,
    // gjor arbeid etterpa: billigere, og ingenting lekker.
    let bruker: { id: string } | null = null;
    if (kind === "invite") {
      const auth = req.headers.get("Authorization") || "";
      const jwt = auth.startsWith("Bearer ") ? auth.slice(7) : "";
      if (!jwt) return json({ error: "innlogging kreves" }, 401);
      const { data: userRes } = await db.auth.getUser(jwt);
      if (!userRes?.user) return json({ error: "innlogging kreves" }, 401);
      bruker = userRes.user;
    }

    const { data: link, error: linkErr } = await db
      .from("kundelenker").select("*").eq("token", token).maybeSingle();
    if (linkErr) return json({ error: "oppslag feilet" }, 500);
    if (!link) return json({ error: "ukjent lenke" }, 404);

    // Prosjektnavn hentes server-side, aldri fra kallet.
    const { data: proj } = await db
      .from("romtegner_projects").select("name").eq("id", link.project_id).maybeSingle();
    const projectName = proj?.name || "Prosjekt";
    const { data: org } = link.org_id
      ? await db.from("organizations").select("name").eq("id", link.org_id).maybeSingle()
      : { data: null };
    const orgName = org?.name || "Varmeplan";
    const kundeUrl = `${PUBLIC_BASE_URL}/?kunde=${link.token}`;

    // ───────────────────────── invite ─────────────────────────
    if (kind === "invite") {
      // Lag 1 (en EKTE bruker, ikke bare en gyldig JWT) er alt gjort over, FOR oppslaget.
      // Lag 2: brukeren maa vere medlem av lenkens organisasjon.
      if (!link.org_id) return json({ error: "lenken mangler organisasjon" }, 403);
      const { data: medlem } = await db.from("organization_members")
        .select("user_id").eq("org_id", link.org_id).eq("user_id", bruker!.id).maybeSingle();
      if (!medlem) return json({ error: "ikke medlem av organisasjonen" }, 403);

      if (link.status === "revoked" || link.status === "expired" || link.status === "applied") {
        return json({ error: "lenken er ikke lenger aktiv" }, 409);
      }

      const rcpt = String(to || "").trim();
      if (!EMAIL_RE.test(rcpt)) return json({ error: "ugyldig e-postadresse" }, 400);
      const msg = String(message || "").slice(0, 1000);

      const utlop = link.expires_at
        ? new Date(link.expires_at).toLocaleDateString("nb-NO", { day: "numeric", month: "long", year: "numeric" })
        : null;

      await sendEmail({
        to: [rcpt],
        fromName: orgName,
        replyTo: link.notify_email || undefined,
        subject: `${orgName} ber deg fylle inn maal for ${projectName}`,
        html: shell(`
          <div style="font-size:17px;font-weight:600;margin-bottom:10px">${esc(orgName)} ber deg fylle inn maal</div>
          <p style="font-size:14px;line-height:1.55;margin:0 0 4px">Prosjekt: <b>${esc(projectName)}</b></p>
          <p style="font-size:14px;line-height:1.55;color:#4b5563">Apne lenken under, sa ser du tegningen og kan rette maalene direkte. Du trenger ingen innlogging.</p>
          ${msg ? `<div style="background:#f8fafc;border:1px solid #e2e8f0;border-left:3px solid #0891b2;border-radius:8px;padding:12px 14px;margin:16px 0;font-size:13px;white-space:pre-wrap">${esc(msg)}</div>` : ""}
          ${button(kundeUrl, "Fyll inn maal")}
          ${utlop ? `<p style="font-size:12px;color:#6b7280;margin-top:16px">Lenken er gyldig til ${esc(utlop)}.</p>` : ""}`),
      });

      await db.from("kundelenker")
        .update({ invite_sent_to: rcpt, invite_sent_at: new Date().toISOString() })
        .eq("id", link.id);
      return json({ ok: true, sent_to: rcpt });
    }

    // ──────────────────────── answered ────────────────────────
    // Anonymt kall. Tre lag som til sammen gjor den ubrukelig som e-postkanon.
    if (link.status !== "answered") return json({ error: "lenken har ikke et nytt svar" }, 403);
    if (!link.answered_at || Date.now() - new Date(link.answered_at).getTime() > NOTIFY_WINDOW_MS) {
      return json({ error: "svaret er for gammelt til aa varsle om" }, 403);
    }
    if (link.last_notified_at && Date.now() - new Date(link.last_notified_at).getTime() < NOTIFY_WINDOW_MS) {
      return json({ ok: true, skipped: "allerede varslet" });
    }
    if (!link.notify_email) return json({ ok: true, skipped: "ingen mottaker" });

    const svar = link.answer || {};
    const antallVegger = Array.isArray(svar.walls) ? svar.walls.length : 0;
    const antallRom = Array.isArray(svar.walls)
      ? new Set(svar.walls.map((w: any) => w.roomId)).size : 0;
    const hvem = link.answered_by_name || "Kunden";
    const apneUrl = `${PUBLIC_BASE_URL}/?project=${link.project_id}&kundesvar=${link.id}`;

    await sendEmail({
      to: [link.notify_email],
      subject: `${hvem} har sendt inn maal for ${projectName}`,
      html: shell(`
        <div style="font-size:17px;font-weight:600;margin-bottom:10px">Svar fra kunde</div>
        <p style="font-size:14px;line-height:1.55;margin:0 0 4px"><b>${esc(hvem)}</b> har sendt inn
          <b>${antallVegger} ${antallVegger === 1 ? "maal" : "maal"}</b> fordelt paa
          <b>${antallRom} ${antallRom === 1 ? "rom" : "rom"}</b> for <b>${esc(projectName)}</b>.</p>
        ${svar.comment ? `<div style="background:#f8fafc;border:1px solid #e2e8f0;border-left:3px solid #0891b2;border-radius:8px;padding:12px 14px;margin:16px 0;font-size:13px;white-space:pre-wrap">${esc(String(svar.comment).slice(0, 2000))}</div>` : ""}
        <p style="font-size:13px;color:#4b5563">Tegningen er ikke endret — maalene ligger som et forslag til du gaar gjennom dem.</p>
        ${button(apneUrl, "Apne i Varmeplan")}`),
    });

    await db.from("kundelenker")
      .update({ last_notified_at: new Date().toISOString() })
      .eq("id", link.id);
    return json({ ok: true });

  } catch (e) {
    return json({ error: String((e as Error).message || e) }, 500);
  }
});
