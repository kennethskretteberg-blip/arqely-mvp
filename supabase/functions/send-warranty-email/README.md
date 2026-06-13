# send-warranty-email (Edge Function)

Rutine-e-post for dokumentasjons-/garantimodulen. **Inaktiv** til den rulles ut og
secrets er satt. Frontend (`romtegner.html`) viser i dag mottakerne som info og lagrer
alt i skyen uavhengig — denne funksjonen står klar til å kobles på når du vil.

## Hva den gjør
`POST` med JSON-body:

```json
{ "type": "certificate", "id": "<warranty_certificates.id>", "to": ["valgfri@ekstra.no"] }
{ "type": "claim",       "id": "<claims.id>" }
```

- `certificate`: sender kopi av garantibevis. Legger automatisk til leverandørens
  `suppliers.recipient_email` som mottaker.
- `claim`: sender rutinevarsel til kundens e-post (`claims.customer_email`).

Bruker [Resend](https://resend.com) som e-postleverandør (bytt enkelt til Postmark/
SendGrid ved å endre `sendEmail()` i `index.ts`).

## Rulle ut (når du vil aktivere)

1. Installer Supabase CLI og logg inn:
   ```bash
   brew install supabase/tap/supabase
   supabase login
   supabase link --project-ref <DITT_PROJECT_REF>
   ```
2. Sett secrets:
   ```bash
   supabase secrets set RESEND_API_KEY=re_xxxxxxxx
   supabase secrets set FROM_EMAIL="Varmeplan <noreply@dittdomene.no>"
   ```
   (`SUPABASE_URL` og `SUPABASE_SERVICE_ROLE_KEY` er innebygd i runtime — trengs ikke settes.)
3. Deploy:
   ```bash
   supabase functions deploy send-warranty-email
   ```
4. Verifiser domene i Resend (SPF/DKIM) for at e-post ikke havner i spam.

## Koble på i appen (senere)
I `_docGenerate` (etter at beviset er lagret) og `_claimSubmit` (etter at saken er
opprettet), kall funksjonen:

```js
await _db.functions.invoke('send-warranty-email', { body: { type: 'certificate', id: cert.id } });
await _db.functions.invoke('send-warranty-email', { body: { type: 'claim', id: claim.id } });
```

Pakk inn i try/catch slik at en e-postfeil ikke blokkerer lagringen (beviset/saken
er allerede trygt lagret i databasen).

## Test lokalt (valgfritt)
```bash
supabase functions serve send-warranty-email --env-file ./supabase/.env.local
curl -X POST http://localhost:54321/functions/v1/send-warranty-email \
  -H "Content-Type: application/json" \
  -d '{"type":"claim","id":"<en-claim-id>"}'
```
