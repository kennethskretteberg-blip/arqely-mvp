# kundelenke-mail

E-post for kundelenker (spec-kundelenke regel 9). To meldinger, én funksjon.

| `kind` | Hvem kaller | Hva skjer |
|---|---|---|
| `invite` | Kenneth, innlogget | Sender kundelenken til kundens e-post |
| `answered` | Kundesiden, anonymt | Varsler den som laget lenken om at det er kommet mål |

## Deploy

```bash
supabase functions deploy kundelenke-mail
```

Secrets (samme som de øvrige e-postfunksjonene — er de satt fra før, trengs ingenting her):

```bash
supabase secrets set RESEND_API_KEY=re_xxx
supabase secrets set FROM_EMAIL='Varmeplan <noreply@arqely.no>'
```

`SUPABASE_URL` og `SUPABASE_SERVICE_ROLE_KEY` er innebygd i runtime.

Migrasjonen `supabase-migration-kundelenke-mail.sql` må være kjørt (tre nye kolonner på
`kundelenker`).

## Avsenderdomene

`FROM_EMAIL` må være en adresse på et domene som er **verifisert i Resend**. I dag sender
`send-invite-email` fra `noreply@arqely.no`, og det virker. Skal avsender bli
`noreply@varmeplan.no`, må domenet verifiseres i Resend først (DNS-poster), ellers avvises
sendingen. Lenkene i e-posten peker uansett på `varmeplan.no` — det er uavhengig av avsender.

## Hvorfor funksjonen slår opp alt selv

Klienten sender bare *hvilken lenke* (token), og for `invite` i tillegg mottaker og en
fritekstmelding. Alt annet — organisasjonsnavn, prosjektnavn, utløpsdato, mottakeren for
`answered` — hentes server-side med service role.

Det er en bevisst forskjell fra `send-invite-email`, som tar både mottaker **og** selve
lenke-URL-en rett fra klientens body. Den kan altså sende en vilkårlig lenke til en vilkårlig
adresse med Varmeplan som avsender.

Like viktig: Supabase sin `verify_jwt` er **ikke** det samme som «innlogget bruker» — anon-
nøkkelen er en gyldig JWT, og den ligger åpent i klienten. `invite` verifiserer derfor brukeren
eksplisitt med `auth.getUser(jwt)` og sjekker medlemskap i lenkens organisasjon.

`answered` må kunne kalles anonymt (kunden er ikke innlogget) og er snevret inn i tre lag:

1. lenken må ha `status='answered'`
2. svaret må være under 10 minutter gammelt
3. maks ett varsel per lenke per 10 minutter (`last_notified_at`)

Mottakeren er alltid lenkens egen `notify_email`, aldri noe fra kallet. Til sammen gjør det den
ubrukelig som e-postkanon: det eneste en angriper kan utløse er én e-post til Kenneth selv, om
en kunde akkurat har svart.
