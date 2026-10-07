# Status — Kundelenke (027–030)

**Alle fire promptene er kjørt.** Serien er komplett og i `main` per 07.10.2026.
Spec: [`spec-kundelenke.md`](spec-kundelenke.md) · Valg og avklaringer: [`prompter/SPØRSMÅL.md`](prompter/SPØRSMÅL.md)

---

## Hva som er bygget

| | Prompt | Commit | Status |
|---|---|---|---|
| Grunnmur: tabell, RPC-er, usikre vegger, kundeside for mål | 027 | `327778f` | ✅ i `main` |
| Mottak: merke, gjennomgang vegg for vegg, Bruk/Bruk alle, avvik | 028 | `0aee111` | ✅ i `main` |
| E-post begge veier, alle lenker på varmeplan.no | 029 | `4c09d7a` | ✅ i `main` |
| Tegn selv: fire metoder på PC, talltastatur på telefon | 030 | se `git log` | ✅ i `main` |

## Dette må Kenneth gjøre for at alt skal virke

**1. Migrasjoner — alle tre er kjørt og verifisert:**

| Fil | Hva | Verifisert |
|---|---|---|
| `supabase-migration-kundelenke.sql` | tabell `kundelenker` + to RPC-er | ✅ begge rutiner finnes |
| `supabase-migration-kundelenke-028.sql` | `kundelenke_get` avviser `applied` | ✅ `avviser_applied = true` |
| `supabase-migration-kundelenke-mail.sql` | `last_notified_at`, `invite_sent_to/at` | ⬜ **kjøres i SQL Editor** |

**2. Edge Function — ikke deployet ennå:**

```bash
supabase functions deploy kundelenke-mail
```

Secrets (`RESEND_API_KEY`, `FROM_EMAIL`) er de samme som de øvrige e-postfunksjonene bruker.
Uten deploy virker alt annet; bare e-postene uteblir, og lenken kan deles manuelt.

**3. Avsenderdomene (valgfritt).** Funksjonen sender fra `noreply@arqely.no`, som er den
adressen som faktisk sender e-post i dag. Skal det bli `noreply@varmeplan.no`, må domenet
verifiseres i Resend (DNS-poster hos Domeneshop) og `FROM_EMAIL`-secreten settes. Ingen
kodeendring. Lenkene *i* e-posten peker uansett på `varmeplan.no`.

## Domenene — målt 07.10.2026

| URL | Svar |
|---|---|
| `varmeplan.no` | 200 direkte — **primærdomene** |
| `www.varmeplan.no` | 307 → `varmeplan.no` |
| `arqely.com` | 307 → `www.arqely.com` |
| `www.arqely.com` | 200 direkte |

Begge domenene serverer **samme Vercel-prosjekt** (identisk innhold, verifisert med sha256).
`arqely.com` redirecter altså ikke til `varmeplan.no` — de kjører parallelt. Det er uproblematisk
for kundelenkene, som treffer `varmeplan.no` uten et eneste hopp; gamle arqely-lenker fortsetter
å virke.

## Sikkerhetsmodellen

- Tabellens RLS åpnes **aldri** for anon. Verifisert: en anonym `select` på `kundelenker` gir
  0 rader, mens begge `security definer`-funksjonene er kallbare.
- `kundelenke_get` velger felt **eksplisitt** fra prosjektets JSON — aldri `data` rått. Kunden
  ser geometri og navn, ingenting annet.
- `kundelenke-mail` slår opp alt innhold selv med service role. Fra klienten kommer bare token,
  og for invitasjon mottaker + melding.
- `kind='invite'` verifiserer brukeren med `auth.getUser(jwt)` + medlemskap i lenkens org.
  **Merk:** Supabase sin `verify_jwt` er *ikke* det samme som innlogget bruker — anon-nøkkelen er
  en gyldig JWT og ligger åpent i klienten.
- `kind='answered'` er anonym, men krever `status='answered'`, svar under 10 min gammelt, og
  maks ett varsel per lenke per 10 min. Mottakeren er alltid lenkens egen `notify_email`.

## To funn som gjelder eldre kode

1. **`send-invite-email` tar både mottaker og lenke-URL rett fra klientens body**, uten å lese
   `Authorization`. Den kan altså sende en vilkårlig lenke til en vilkårlig adresse med Varmeplan
   som avsender. Ikke rørt i denne serien — fortjener en egen oppgave.
2. **Presentasjonslenken viste «Del lenke» og «Avslutt» til alle**, fordi `_presentEnter()`
   nullstilte `presentPublic` rett etter at den var satt. Rettet i 030.

## Flyten, ende til ende

```
Kenneth merker usikre vegger  ──►  «Be kunde om mål»  ──►  Mål eller Tegn
                                          │
                                          ├─ kopier lenke, eller send på e-post
                                          ▼
                       kunden åpner varmeplan.no/?kunde=<token>
                       (ingen innlogging, kun geometri og romnavn)
                                          │
                 mål: retter vegglengder  │  tegn: tegner rom med fire metoder
                 — balansesjekk live      │  — talltastatur + piler på telefon
                                          ▼
                                     «Send inn»
                                          │
                          e-post til Kenneth  +  status = answered
                                          ▼
                 prosjektlista: «✉ Svar fra kunde»  ──►  Gå gjennom
                                          │
                 Estimert | Kunde | Avvik | Blir   og/eller   Nye rom fra kunde
                                          ▼
                             Bruk / Bruk alle  (ett Ctrl+Z angrer alt)
                                          │
                        avvik som ikke går opp vises, de skjules aldri
                                          ▼
                                   status = applied
                             (lenken blir ugyldig)
```

## Ikke i v1 (fra spec)

- Åpen «tegn selv»-side uten prosjekt, f.eks. fra cenika.no. Krever misbruksvern.
- Elektriker med egen Varmeplan-konto som deler prosjekt mellom organisasjoner.
- Bilder/vedlegg fra kunden i svaret.
