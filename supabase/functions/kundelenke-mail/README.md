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

## Avsenderdomene — ferdig satt opp

`varmeplan.no` er **verifisert i Resend** og `FROM_EMAIL` er satt (Kenneth, 07.10.2026).
Funksjonen trenger ingen egen konfigurasjon.

⚠ **`FROM_EMAIL` er en prosjekt-secret, ikke en funksjons-secret.** Den deles av alle fem
e-postfunksjonene — `send-invite-email`, `notify-admin-registration`, `send-feedback`,
`send-warranty-email` og denne. Når den settes til `noreply@varmeplan.no`, bytter *alle*
avsender; de to første sendte tidligere fra `arqely.no` og den tredje fra
`invite.arqely.com`. Det er antakelig ønsket (ett avsenderdomene for hele appen), men det er
en sideeffekt verdt å kjenne til.

Avsender**navnet** byttes per e-post til organisasjonens navn; selve adressen er alltid den
verifiserte. `reply_to` settes til den som laget lenken, så kundens svar går dit — ikke til
`noreply@`.

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
