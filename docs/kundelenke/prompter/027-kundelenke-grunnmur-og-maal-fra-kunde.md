# 027 · Kundelenke, grunnmur: tabell + RPC-er, merk usikre vegger, «Be kunde om mål», og kundesiden der kunden retter målene

**Repo:** `arqely-mvp` · **Filer:** `index.html`, ny `supabase-migration-kundelenke.sql` · **Prioritet: Høy** · **Størrelse: stor**
**Spec:** `docs/kundelenke/spec-kundelenke.md` (regler 1–4, 7, 8, 10 gjelder her). Linjenumre fra `d43d1d8`.

---

## Hva som finnes å bygge på

| | Hvor | Gjenbruk |
|---|---|---|
| Offentlig lenke uten innlogging | `?present=<token>` → `_presentLoadByToken` (:6775), RPC `get_present_project` (security definer, `supabase-migration-presentation.sql`) | **Samme mønster.** Ny RPC, ny boot-sti `?kunde=` |
| Read-only visning | `_presentEnter` (:6598), `present-mode`-klassen, `S.ui.presentPublic` | Kundemodus = presentasjon + ett panel |
| Rom-geometri | `room.points[]` (cm), `room.walls[]`, `room.dims[]`, `_hitDimLine` (:45532) | Vegg `i` = segmentet `points[i] → points[(i+1)%n]` |
| Målelinjer tegnes | `drawDims`/dim-tegning per rom (finn via `dims`) | Rød stiplet + «?» for usikre vegger |
| Token-oppslag i URL | `_inviteToken` (:53760) | Samme sted leses `?kunde=` |

## STEG 0

1. Les `supabase-migration-presentation.sql` helt og `_presentLoadByToken`. Noter hvordan
   anon-rettigheter er gitt (grant execute til anon på funksjonen, ingen RLS-åpning).
2. Finn hvordan en vegg identifiseres stabilt i et rom. Er `room.walls[i]` alltid parallell med
   `points[i]→points[i+1]`, og overlever indeksen lagring/lasting? Hvis ikke → bruk
   `{roomId, wallIdx}` med `wallIdx` = punktindeks, og skriv det i rapporten.
3. Finn tegnefunksjonen for målelinjer (automatiske veggmål) og hvor PDF-romsiden tegner dem, så
   rød «?»-markering kan legges begge steder.
4. Sjekk at `?present=` fortsatt virker etter at boot-koden utvides (ikke bryt den).

## Gjør

### 1. Migrasjon `supabase-migration-kundelenke.sql`

Tabell `kundelenker` nøyaktig som spec §Datamodell. RLS: org-medlemmer (`organization_members`) kan
select/insert/update rader med sin `org_id`; **ingen** policy for anon. To funksjoner,
`security definer`, `set search_path = public`, `grant execute … to anon, authenticated`:

- `kundelenke_get(p_token uuid)` → én jsonb: `{ mode, status, note, expires_at, project_name,
  floors: [{id, name}], rooms: [{id, name, floorId, points, walls (kun lengder/indeks), dims?}],
  asked_walls }`. Bygges fra `romtegner_projects.data` **med eksplisitt utvalg** — aldri
  `data` rått (spec regel 1). Returnerer `null` når token ikke finnes, er `expired`/`revoked`,
  eller `expires_at < now()`.
- `kundelenke_answer(p_token uuid, p_answer jsonb, p_name text)` → boolean. Avviser når status er
  `applied/expired/revoked` eller utløpt. Setter `answer, answered_at, answered_by_name,
  status='answered'`. Maks 200 kB payload (sjekk `pg_column_size`).

### 2. Merk usikre vegger (innlogget bruker)

- Klikk på vegg/målelinje → kontekstmeny (`dimCtxMenu` :45555-området eller vegg-menyen) får
  «Usikkert mål» (toggle). Lagres som `room.uncertainWalls: [wallIdx]` i prosjekt-JSON.
- Tegning: usikker vegg får rød stiplet målelinje og «?» etter tallet, både på lerret og i
  PDF-romsiden (STEG 0.3). Sidebar-rom-raden får liten «?» når rommet har usikre vegger.

### 2b. «Går målene opp?» — `_roomAxisBalance(points)` (spec regel 4b)

- Ren funksjon: for et rom der alle vegger er vannrette/loddrette (toleranse 1°), returner
  `{ rectilinear, dxCm: Σhøyre − Σvenstre, dyCm: Σopp − Σned, walls: [{idx, axis, dir, lenCm}] }`.
  Ikke-rettvinklede rom → `rectilinear:false`, ingen melding.
- **WBW-panelet** (`#wbw-panel`, `updWbw`): mens Kenneth legger vegger vises en linje
  «Høyre side 8,15 m · venstre 11,25 m → 3,10 m mangler loddrett» når avviket > 2 cm, og ved «Lukk
  rom» en toast med samme tekst + knappen **«Merk veggene på den siden som usikre»** (setter
  `uncertainWalls` på alle loddrette vegger som inngår i den korte/lange summen). Det er den
  typiske skisse-feilen: enkeltmål stemmer hver for seg, men summen gjør det ikke.
- Samme sjekk kjøres på kundesiden (§4) og i 028-panelet — alle bruker denne ene funksjonen.

### 3. «Be kunde om mål» (innlogget bruker)

Knapp i fil-gruppa i topbaren ved Presentasjon (`data-modules="indoor stair snow list"`), ikon
`send`/`link`. Modal:
- Modus: **Mål** (standard) / **Tegn** (deaktivert med «kommer i 030» til 030 er kjørt).
- «Melding til kunden» (fritekst, valgfri), gyldig i 30 dager (kan endres).
- Liste over merkede vegger («Stue: vegg 2, vegg 3») — informativt.
- **Lag lenke** → insert i `kundelenker` (`token = crypto.randomUUID()`, `org_id = _userOrg.id`,
  `created_by = _currentUser.id`, `notify_email = _currentUser.email`, `asked_walls` fra
  `uncertainWalls`) → viser lenken `https://varmeplan.no/?kunde=<token>` (konstant
  `_PUBLIC_BASE_URL = 'https://varmeplan.no'` — **ikke** `location.origin`; bytt også
  `_presentShareLink` (:6773) til samme konstant) med **Kopier**. E-post-sending kommer i 029 —
  la knappen «Send på e-post» stå deaktivert med tooltip.
- Prosjektet må være lagret i skyen (`_supabaseProjectId`), som for presentasjon.
- Prosjektinfo i sidebaren viser «Kundelenke: åpen · utløper 06.11» med «Trekk tilbake»
  (`status='revoked'`) og «Kopier lenke». Flere lenker per prosjekt er lov; vis nyeste åpne.

### 4. Kundesiden — mål-modus (anonym)

Boot: `?kunde=<token>` → `_kundeLoadByToken(token)`: `rpc('kundelenke_get')` → bygg et **minimalt
S** (`S.project.name`, `S.floors`, `S.rooms` med points/walls/dims/name — ingenting annet), skjul
auth/prosjektliste, `_presentEnter()`-oppsett, så `S.ui.kundeMode = 'maal'`.

Visning:
- Topplinje: «Varmeplan · <prosjektnavn> · Fyll inn mål» + meldingen fra Kenneth.
- Hver vegg har et **mål-felt** (cm eller m — vis «3,20 m», lagre cm). Klikk/tapp på vegg eller
  målelinje åpner feltet; på smal skjerm (bredde < 900 px eller `pointer: coarse`) vises i tillegg
  en **liste per rom** nederst («Stue — vegg 1: 3,20 m [rediger] …») så man slipper å treffe
  streker med fingeren. Usikre vegger først, røde, med «?».
- Endret verdi → vegg vises **grønn** med ny verdi; original beholdes som grå tekst («var 3,20»).
  Geometrien tegnes **ikke** om på kundesiden — kunden retter tall, Kenneth innarbeider (spec
  regel 2/4). Skriv det som en liten hjelpetekst: «Tegningen oppdateres av Varmeplan når målene er
  mottatt.»
- **Live «går målene opp?»** (§2b, spec 4b): over Send inn-knappen står per rom «✓ Målene går opp»
  eller «⚠ Høyre side er 3,10 m kortere enn venstre — sjekk de loddrette målene» (bruker kundens
  tall der de er endret, ellers tegningens). Aldri sperre — kunden kan sende inn likevel, med
  avviket lagret i svaret (`axisBalance` per rom) så Kenneth ser det i 028.
- «Navn» (kundens navn, valgfritt) + «Kommentar» + **Send inn** → `rpc('kundelenke_answer', …)`
  med `{ walls: [{roomId, wallIdx, lengthCm, wasCm}], comment }` → bekreftelse «Takk — målene er
  sendt til <org-navn>». Kan sendes igjen (siste gjelder) til status er `applied`.
- Ugyldig/utløpt token → vennlig side «Lenken er ikke lenger gyldig — kontakt den som sendte den».

## Skal IKKE

- Vise produkter, utlegg, kundenavn, kundenummer, PDF eller noe fra `S.project` utover navn.
- Skrive i `romtegner_projects` fra kundesiden.
- Endre geometri automatisk (det er 028).

## Test

1. Rom med 2 merkede vegger → PDF og lerret viser rød «?». «Be kunde om mål» → rad i tabellen,
   lenke kopiert med `varmeplan.no`.
2. Åpne lenken i inkognito (ikke innlogget): tegningen vises, bare geometri; merkede vegger røde
   først. Nettverksfanen: kun to RPC-kall, ingen `romtegner_projects`-spørring. Rett 3 mål, send inn →
   raden har `answer` med 3 vegger, `status='answered'`.
3. Samme lenke på telefon: liste per rom virker, felt store nok, send inn virker.
4. Trekk tilbake → lenken gir «ikke gyldig». Utløpt dato → samme.
5. `?present=` virker som før. Innlogget bruker ser ikke kundesidens UI.
6. Ny `_kundelenkeRegressionTest()`: syntetisk svar-payload valideres (riktige felt, cm-tall,
   avviste negative/NaN), token-URL-bygging bruker `_PUBLIC_BASE_URL`.
7. `_roomAxisBalance` på rommet fra Kenneths skisse 07.10 (WBW: 440 → opp 272 → 15 → ned 35 →
   190 → opp 435 → 190 tilbake → ned 100 → 15 → opp 243 → 440 tilbake → lukk): `dyCm = −310`
   (lukkende vegg 815 mot oppgitt 1125), `dxCm = 0`, og «Merk veggene» setter usikker på de fem
   loddrette veggene på høyre side. Rektangel 320 × 400 → 0/0. Skrått rom → `rectilinear:false`.

## Rapport

STEG 0.1–0.4; hvordan vegg identifiseres; hvilke migrasjoner Kenneth må kjøre. Endringslogg.
Commit: «027: kundelenke — tabell/RPC, usikre vegger, Be kunde om mål, kundeside for innfylling av mål».
