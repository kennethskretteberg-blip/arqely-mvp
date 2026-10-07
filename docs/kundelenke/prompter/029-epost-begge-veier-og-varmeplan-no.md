# 029 · E-post begge veier (lenke til kunde, varsel ved svar) og alle lenker på varmeplan.no

**Repo:** `arqely-mvp` · **Filer:** `index.html`, ny `supabase/functions/kundelenke-mail/index.ts`, `supabase-migration-kundelenke-mail.sql` · **Prioritet: Normal** · **Størrelse: liten–middels**
**Spec:** regel 8, 9. Krever 027. Linjenumre fra `d43d1d8`.

---

## Hva som finnes

`supabase/functions/send-invite-email/index.ts` sender via **Resend** med secrets `RESEND_API_KEY`
og `FROM_EMAIL` (i dag `noreply@arqely.no`). Klienten kaller den med `fetch(SUPABASE_URL +
'/functions/v1/send-invite-email', …)` (:54887). Samme mønster her — én funksjon, to meldinger.

## STEG 0

1. Les `send-invite-email/index.ts` og `notify-admin-registration` — hvordan verifiseres kalleren
   (JWT i `Authorization`? `verify_jwt`?). Kundens kall er **anonymt**, Kenneths er innlogget —
   funksjonen må skille.
2. Sjekk hvilket domene `FROM_EMAIL` faktisk er verifisert på i Resend (står i secrets/README).
   Skal avsender bli `noreply@varmeplan.no`, må Kenneth verifisere domenet i Resend → SPØRSMÅL.md.
3. `grep -n "location.origin"` — alle steder som bygger lenker som sendes ut av appen skal over på
   `_PUBLIC_BASE_URL` (027 innførte den for kundelenke og presentasjon; sjekk invitasjoner :54887/:55728
   — de bygges kanskje i klienten også).

## Gjør

### 1. Edge Function `kundelenke-mail`

Body `{ kind: 'invite' | 'answered', token }`. Funksjonen slår **selv** opp lenken med service
role (aldri stol på klientens data for mottaker/innhold):

- `kind='invite'` (**krever gyldig bruker-JWT**, og brukeren må være medlem av lenkens `org_id`):
  sender til `p_to` (fra body, validert e-postformat) med `p_message` (Kenneths tekst, maks 1000
  tegn, escapet). Innhold: «<Org-navn> ber deg fylle inn mål for <prosjektnavn>» + knapp med
  `https://varmeplan.no/?kunde=<token>` + utløpsdato + Kenneths melding. Avsendernavn = org-navn,
  reply-to = `notify_email` (så kunden kan svare direkte til Kenneth).
- `kind='answered'` (anonymt kall tillatt, **men** bare gyldig når lenkens `status='answered'` og
  `answered_at` er < 10 min gammel — det hindrer at noen bruker funksjonen som e-postkanon):
  sender til `notify_email`: «<Navn> har sendt inn N mål / N rom for <prosjektnavn>» + knapp
  «Åpne i Varmeplan» → `https://varmeplan.no/?project=<project_id>&kundesvar=<id>` (boot-stien
  åpner prosjektet og gjennomgangspanelet fra 028). Rate: maks én `answered`-mail per lenke per
  10 min (kolonne `last_notified_at`).
- Migrasjon: `alter table kundelenker add column if not exists last_notified_at timestamptz,
  add column if not exists invite_sent_to text, add column if not exists invite_sent_at timestamptz`.

### 2. Klient

- Modal «Be kunde om mål» (027 §3): «Send på e-post» aktiveres: felt mottaker + melding → kaller
  `kind='invite'` → «Sendt til …» og lagres (`invite_sent_to/at`), vises i prosjektinfo-blokken.
  «Send på nytt» samme kall.
- Kundesiden: etter vellykket `kundelenke_answer` → kall `kind='answered'` (feil her stopper
  **ikke** bekreftelsen til kunden — e-post er tillegg).
- Boot: `?project=<id>&kundesvar=<id>` → åpne prosjektet (eksisterende prosjekt-åpning) → åpne
  gjennomgangspanelet fra 028.
- Alle utgående lenker (kundelenke, presentasjon, invitasjon hvis klientbygd) på
  `_PUBLIC_BASE_URL`.

### 3. Vercel/domene (Kenneth, dokumenter i STATUS.md)

Bekreft at `varmeplan.no` er primærdomene på Vercel-prosjektet og at `arqely.com` redirecter dit —
ellers havner kundelenker på en side som kanskje sies opp. `vercel.json` har bare én redirect i
dag; legg eventuelt inn domene-redirect der hvis Vercel ikke gjør det på prosjektnivå.

## Skal IKKE

- Sende e-post fra klienten direkte (ingen API-nøkkel i `index.html`).
- La `kind='invite'` gå uten innlogget bruker.
- Lagre kundens e-post noe sted utover `invite_sent_to` på lenken.

## Test

1. Lag lenke → Send på e-post til egen adresse → mottatt, knappen går til `varmeplan.no/?kunde=…`,
   reply-to er Kenneths adresse.
2. Fyll inn som kunde i inkognito → Kenneth mottar «har sendt inn 3 mål», knappen åpner prosjektet
   med panelet fra 028.
3. Kall `kind='answered'` to ganger på 1 min → én e-post. Kall med token som ikke er `answered` →
   403/ingen e-post. `kind='invite'` uten JWT → 401.
4. `grep location.origin` → ingen treff i lenkebygging som sendes ut.

## Rapport

STEG 0.1–0.3; secrets og deploy-kommandoer Kenneth må kjøre (`supabase functions deploy
kundelenke-mail`, `supabase secrets set …`); Resend-domenespørsmålet i SPØRSMÅL.md. Endringslogg.
Commit: «029: kundelenke-mail (invitasjon + svarvarsel via Resend), alle utgående lenker på varmeplan.no».
