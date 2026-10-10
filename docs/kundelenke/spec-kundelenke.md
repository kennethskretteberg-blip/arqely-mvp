# Spec · Kundelenke — kunden fyller inn mål eller tegner rommene selv

**Status:** låst 07.10.2026 (Kenneth). **Gjelder:** `arqely-mvp/index.html` + Supabase.
**Prompter:** serien `prompter/varmeplan/kundelenke/027–030`.

## Problemet

Tegninger kommer ofte uten mål. Kenneth estimerer, tegner opp og spør kunden om målene på
veggene han er usikker på. Kunden måler, tegner på ark, tar bilde, sender e-post; Kenneth tegner
inn; noen mål mangler; frem og tilbake. Samme dobbeltarbeid når elektrikeren er på befaring og
kunne tegnet rommet selv.

## Løsningen i én setning

Én **kundelenke** per prosjekt (`https://varmeplan.no/?kunde=<kode>`) som åpner prosjektets
tegning uten innlogging, i én av to moduser: **«mål»** (kunden retter mål på vegger) eller
**«tegn»** (kunden tegner rommene selv). Svaret lagres som et *forslag* på lenken, Kenneth får
e-post, og innarbeider forslaget vegg for vegg / rom for rom i prosjektet.

## Regler

1. **Kunden ser kun geometri.** Rom (punkter/vegger/mål), romnavn, etasjenavn, prosjektnavn.
   Aldri kundenavn, kundenummer, produkter, priser, utlegg, PDF, andre prosjekter.
2. **Kunden skriver aldri i prosjektet.** Svaret ligger på kundelenken (`answer`). Først når
   Kenneth trykker «Bruk» i Varmeplan endres tegningen. Alltid `pushUndo` før innarbeiding.
3. **Alle vegger kan endres** (Kenneth 07.10: «Alle»). Veggene Kenneth har merket som usikre
   vises først og rødt — men kunden kan rette hvilken som helst.
4. **Målene må gå opp.** En lukket romform har ikke uavhengige vegglengder. Innarbeidingen
   setter vegg for vegg og viser avvik («kunde 4,10 m → ble 3,95 m») i stedet for å tegne et
   skjevt rom i stillhet. Kenneth avgjør.
4b. **«Går målene opp?»-sjekken er én funksjon, brukt tre steder.** For rom med bare rette
   vinkler (alle vegger vannrett/loddrett — det er nesten alle) gjelder: summen av vegger som går
   *opp* = summen som går *ned*, og summen *høyre* = summen *venstre*. `_roomAxisBalance(walls)`
   returnerer avviket per akse og hvilke vegger som inngår. Brukes (a) i Varmeplans WBW når
   Kenneth tegner fra en skisse («Høyre side summerer til 8,15 m, venstre vegg 11,25 m — 3,10 m
   mangler i loddrette mål»), og veggene på den siden kan merkes «usikre» med ett klikk; (b) **live
   på kundesiden** mens kunden retter, som veiledning («Mangler 3,10 m i høyde på høyre side»),
   aldri som sperre for innsending; (c) i gjennomgangspanelet før «Bruk». Eksempel 07.10: skissen
   oppga 11,25 m venstre vegg, men høyre side (2,72 − 0,35 + 4,35 − 1,00 + 2,43) ble 8,15 m — den
   lukkende veggen ble for kort, og ingen sa hvor feilen lå.
5. **Tegn-modus har fire måter** (Kenneth 07.10): **Mål** (lengde × bredde), **Polygon**,
   **L-form**, **WBW** (vegg for vegg). På PC virker WBW som i Varmeplan. På telefon virker WBW
   med **pilknapper** (retning + legg vegg) og et **talltastatur på skjermen** (siffer, komma,
   slett, piler) — ingen avhengighet av mobilens eget tastatur.
6. **Tegn-modus gir rom med de samme feltene som import-malen (sak 014)**: navn, romtype,
   areal/geometri, varmetype-ønske, ønsket W/m², etasje. Rommene opprettes med `createRoom` når
   Kenneth trykker «Bruk».
7. **Lenken er ufarlig å dele.** Lang tilfeldig kode (UUID), utløper (standard 30 dager), kan
   trekkes tilbake, én lenke = ett prosjekt. Anonyme kall går **kun** gjennom to
   `security definer`-funksjoner (hent / svar) — tabellens RLS åpnes aldri for anon. Samme
   mønster som `?present=` og `get_present_project`.
8. **Domene:** alle lenker som sendes ut bruker `https://varmeplan.no` — aldri `location.origin`
   (som gir arqely.com/localhost). Gjelder kundelenke **og** presentasjonslenke.
9. **E-post begge veier:** Kenneth kan sende lenken til kunden fra Varmeplan (valgfritt — han kan
   også bare kopiere den). Når kunden sender inn, går det e-post til den som laget lenken.
   Edge Function + Resend, som `send-invite-email`.
10. **Én lenke, én status:** `open → answered → applied` (eller `expired`/`revoked`). Kunden kan
    sende inn flere ganger til Kenneth har trykket «Bruk» (siste svar gjelder).

11. **Hele dialogen per prosjekt er en logg** (055), avledet av `kundelenker` — én runde per
    lenke, begge moduser. Alt som har egen kolonne (`created_at`, `invite_sent_at`,
    `answered_at`, `answer`, `approve_all_at`, `applied_result`, `svar_sendt_at`, `applied_at`)
    leses derfra; bare hendelser UTEN egen kolonne (`kopiert`, `trukket`, `paaminnelse`) lagres,
    i `hendelser jsonb`, og alltid via RPC-en `kundelenke_logg` (append, så to vinduer ikke
    overskriver hverandre). Loggen er **intern** — kunden ser den aldri, og ingen anonym vei
    skriver til den.

## Datamodell (Supabase, additiv)

```
kundelenker
  id uuid pk, token uuid unique, project_id uuid → romtegner_projects, org_id uuid,
  mode text ('maal'|'tegn'), asked_walls jsonb [{roomId, wallIdx}], note text,
  status text ('open'|'answered'|'applied'|'expired'|'revoked'),
  expires_at timestamptz, created_by uuid, notify_email text,
  answer jsonb, answered_at timestamptz, answered_by_name text, created_at timestamptz
rpc kundelenke_get(p_token)     → { mode, status, note, project_name, floors[], rooms[] (kun geometri+navn), asked_walls, expires_at }
rpc kundelenke_answer(p_token, p_answer jsonb, p_name text) → boolean  (avvist når expired/revoked/applied)
```
Svar-format: `maal`: `{ walls: [{roomId, wallIdx, lengthCm, wasCm}], comment }`.
`tegn`: `{ rooms: [{ name, roomType, floorName, shape, points[] (cm), modType, targetWm2 }], comment }`.

## Ikke i v1

- Kundelenke uten prosjekt (åpen «tegn selv»-side på cenika.no). Krever misbruksvern; tas opp etterpå.
- Elektriker med egen Varmeplan-konto som deler prosjekt-ID mellom organisasjoner (riktig på
  sikt — bygg på `present_token`-mønsteret og org-medlemskap når det blir aktuelt).
- Bilder/vedlegg fra kunden i svaret.
