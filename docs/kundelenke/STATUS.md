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
| Tegn selv: fire metoder på PC, talltastatur på telefon | 030 | `ef636f9` | ✅ i `main` |
| Kundesiden: sidepanel, veggvalg, piltaster og gizmo | 032 | `3540512` | ✅ i `main` |

**032 erstattet en regel fra 027.** Der sto det at «geometrien tegnes ikke om på kundesiden».
Nå følger tegningen tallene mens kunden retter — men spec regel 2 står uendret: alt skjer lokalt
i kundens nettleser, og ingenting skrives før «Send inn». Det er mulig fordi `_applyWallLength`
er en ren geometrifunksjon; målt at den ikke utløser et eneste lagringskall eller undo-steg.

Svaret bærer derfor nå **både** vegglengder og `answer.points` — kundens resultat-geometri.
Kenneth arbeider fortsatt inn via lengdene, men 028-panelet viser kundens punkter som gul
stiplet skygge, så han ser *hva kunden så*. Målt ende til ende: de to er punkt for punkt
identiske.

## Oppsett — alt er på plass

Hele kjeden er operativ per 07.10.2026: migrasjoner kjørt, funksjon deployet, domene verifisert.

**1. Migrasjoner — alle tre er kjørt og verifisert:**

| Fil | Hva | Verifisert |
|---|---|---|
| `supabase-migration-kundelenke.sql` | tabell `kundelenker` + to RPC-er | ✅ begge rutiner finnes |
| `supabase-migration-kundelenke-028.sql` | `kundelenke_get` avviser `applied` | ✅ `avviser_applied = true` |
| `supabase-migration-kundelenke-mail.sql` | `last_notified_at`, `invite_sent_to/at` | ✅ 18 kolonner bekreftet |

**2. Edge Function — ✅ deployet og verifisert** (07.10.2026, prosjekt `nhzhffertfqdeslhzyxx`).

Målt mot den live funksjonen:

| Kall | Svar |
|---|---|
| `invite` med **anon-nøkkelen** | 401 «innlogging kreves» |
| `invite` uten `Authorization` | 401 |
| `answered` med ukjent token | 404 «ukjent lenke» |
| ugyldig `kind` | 400 |

Den første raden er beviset på at `verify_jwt` **ikke** hadde holdt: anon-nøkkelen er en gyldig
JWT og slapp gjennom plattformsjekken, men ble stoppet av den eksplisitte `auth.getUser`-sjekken.

Skal funksjonen deployes på nytt senere:

```bash
supabase functions deploy kundelenke-mail
```

**3. Avsenderdomene — ✅ ferdig.** `varmeplan.no` er verifisert i Resend, og både `FROM_EMAIL`
og `RESEND_API_KEY` er satt (Kenneth 07.10.2026). Tas i bruk automatisk ved deploy; ingenting
mer å gjøre.

⚠ `FROM_EMAIL` er en **prosjekt**-secret, delt av alle fem e-postfunksjonene
(`send-invite-email`, `notify-admin-registration`, `send-feedback`, `send-warranty-email`,
`kundelenke-mail`). Alle sender nå fra `noreply@varmeplan.no`; de tre første sendte tidligere
fra `arqely.no` / `invite.arqely.com`. Antakelig ønsket, men ikke isolert til kundelenken.

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

## Verktøy fra den innloggede editoren som lakk inn på kundesiden

Målt i nettleseren 07.10.2026 (032), ikke antatt — `present-mode` skjuler ingen av dem:

| Element | Hva kunden fikk se |
|---|---|
| `#wip` | «VEGG · ID · Lengde · Vinkel · Rom» + en **«✕ Avslutt»**-knapp som ville tatt kunden ut av siden |
| Rommets transform-gizmo | Håndtak for å flytte og rotere **hele** rommet |
| Minikartet | Navigasjonshjelpemiddel som hører sammen med sidebaren |

Stengt med en ny `body.kunde-maal`-klasse. Lærdommen: kundesiden er presentasjon **pluss**
redigering, så den kan ikke bare arve `present-mode`-lista — hver nye ting som vises ved et
valg må sjekkes eksplisitt.

## Tre åpne e-postutløsere — funnet og tettet

Målt mot de deployede funksjonene 07.10.2026, ikke lest ut av koden. Alle tre er nå rettet og
redeployet; verifisert at ingen av dem sender på et uautentisert kall.

| Funksjon | Før | Etter |
|---|---|---|
| `send-invite-email` | nådde vår kode uten `Authorization`; mottaker **og** lenke-URL fra klientens body | 401 uten innlogget bruker; tar kun `token`, slår opp alt selv |
| `notify-admin-registration` | **sendte e-post på tomt POST-kall** (200) | 400 uten `user_id`, 404 på ukjent, krever konto under 15 min gammel |
| `send-feedback` | **sendte e-post på tomt POST-kall** (200) | 401 uten innlogging; identitet fra JWT, ikke fra body |

`send-invite-email` var en ferdig phishing-kanal på vårt eget verifiserte domene, med
`org_name`/`invited_by` interpolert uescapet inn i HTML-en. De to andre kunne hvem som helst
bruke til å fylle `ADMIN_EMAIL` og tømme Resend-kvoten, slik at ekte invitasjoner stoppet.

**Presentasjonslenken viste «Del lenke» og «Avslutt» til alle**, fordi `_presentEnter()`
nullstilte `presentPublic` rett etter at den var satt. Rettet i 030.

## Norsk i e-postene

ASCII-regelen i `prompter/000-KJØR-MEG.md` gjelder **SQL-kommentarer**, ikke e-posttekst. Den ble
feilaktig dratt over på kundeteksten i 029 («Apne», «maalene»); rettet i 031. Alle fem funksjoner
har nå `<meta charset="utf-8">` og `charset=utf-8` mot Resend, og
`scripts/sjekk-norsk-i-epost.sh` fanger det hvis det sniker seg inn igjen.

## Flyten, ende til ende

```
Kenneth merker usikre vegger  ──►  «Be kunde om mål»  ──►  Mål eller Tegn
                                          │
                                          ├─ kopier lenke, eller send på e-post
                                          ▼
                       kunden åpner varmeplan.no/?kunde=<token>
                       (ingen innlogging, kun geometri og romnavn)
                                          │
                 mål: velger vegg i lista │  tegn: tegner rom med fire metoder
                 eller på tegningen,       │  — talltastatur + piler på telefon
                 retter med tall, piltast  │
                 eller gizmo — tegningen   │
                 følger med (032)          │
                 — balansesjekk live       │
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
