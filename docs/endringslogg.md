# Endringslogg — Romtegner

Kronologisk logg over arbeid i `romtegner.html`. Nyeste øverst.

---

## 2026-06-22 — Folie: montør-stil utlegg, bruker velger retning — `b1e9596`, `b36cbc6`

Etter brukers referanse (folie_optimalt) + ønske om å velge retning selv:
- **Én retning i hele rommet** + **uniform bredde forankret inntil vegg** pr sone (ingen
  smale folier midt i arealet; det udekkede mot vegg). `_packZoneUniform` + «lange strimler»-
  scoring (få, brede, lange kolonner).
- **Horisontal og Vertikal i Automatisk-panelet bruker nå sone-teknikken** (`_zonedDefsForDirection`)
  for ikke-rektangulære rom → bruker velger retning selv. Separat «Soner»-kort fjernet. Enkle
  rom (≤1 sone) beholder dagens H/V (ingen regresjon).
- Klamp sone-rektangler til rommets bbox (siste grid-celle stakk forbi vegg → 15 mm-brudd).
- Falske gap-⚠ fjernet tidligere (along-akse-vakt i `getStripViolations`).
- Verifisert på brukers rom: Vertikal 84 % / Horisontal 85 %, begge én retning, 0 regelbrudd,
  få brede strimler forankret til vegg.

---

## 2026-06-22 — Folie «Soner»: rutenett-dekomponering (fikser dårlig dekning) — `a2ee334`

Brukerrapport: «Soner» ga store udekkede arealer på et ekte 53 m²-rom (stua <50 %).
Reprodusert med brukers EKSAKTE romgeometri (hentet via konsoll): slabb-dekomponeringen
la soner oppå hindringer og trimmet stua til en tynn kolonne.

- Ny `_decomposeRoomToRects`: rasteriser rom-interiør MINUS hindringer/forbudte soner i
  et rutenett (~6–12 cm), og hent grådig ut største all-fyllbare rektangel (`_largestRectInGrid`,
  histogram-metode), gjenta. Hindringer = naturlige hull; 25 mm-margin håndteres ved pakking.
- Verifisert på brukers rom: stua fanges som ekte 324×333-sone; Soner-dekning 95 % (var 80 %;
  H/V 52/46 %), 0 folie i hindring, 0 overlapp. Regresjon: rektangel → fallback; L 91 %, U 90 %.

**Oppfølging — falske ⚠ + vegg-margin** (`d733cf1`, `b4ab12e`)
- `getStripViolations` sin gap-sjekk manglet along-akse-vakten → strimler ende-til-ende i ulike
  soner ble feilflagget. Lagt til vakt → ekte overlapp=0 gir 0 gap-⚠. Maks dekning: 91 % helt rent.
- `_computeRectFillDefs` klippet mot sone-rektangelet (kan stikke litt utenfor rommet i grid-
  oppløsning) → 3 vegg-brudd i stua. Nå klippes mot ROMMET (riktig 25 mm margin) + begrenses til
  sonens along-rekkevidde. Soner på brukers rom: **94 % med 0 regelbrudd** (vegg/hindring/gap/overlapp).

---

## 2026-06-22 — Folie: aldri folie i hindring + scoring-straff (Del A/B/C)

Tre gjenstående folie-punkter, reprodusert empirisk FØRST (innlogget, ekte produkter).
Commits (nyeste først): `e701dce`, `2da21be`.

**Del A — aldri folie i hindring** (`2da21be`)
- Rotårsak: `_centerStripDefs` forskyver alle strimler perp (sentrering/skyv-mot-vegg)
  men re-klipper ikke lengden → en strimmel som var hindring-fri i sin kolonne havner
  over en hindring og beholder full lengde → folie i hindring (H/V «lange strimler»).
- Fiks: `_reclipDefsAroundObstacles` re-klipper hver def mot hindringer/forbudte soner
  ved sin (forskjøvne) pos og deler/forkorter. Brukt etter sentrering i begge strategier.
  No-op uten hindringer → ingen regresjon. Verifisert: 2 hindringer → 0 folie i hindring.

**Del C — straff regelbrudd + oppstykking i scoringen** (`e701dce`)
- `_layoutRulePenalty` trekkes fra `_foilLayoutStats.score`: folie i hindring ~1× romareal
  (dominerer), <25 mm 0,15×, svært korte strimler oppstykkingsstraff. → «Soner» blir kun
  ★ når den faktisk er bedre enn H/V. Rene layouts: straff 0 (uendret rangering).

**Del B — stable folie i samme kolonne manuelt** — ingen endring (allerede løst)
- Reprodusert grundig ('v'+'h', under/over, ulik bredde, full kolonne, 2–3 stablet):
  alle plasseres korrekt. `_withFoilAvoid`+`computeClippedSegments` deler faktisk kolonnen
  rundt eksisterende folie; along-vakten i `_stripOverlapsAny` gjør stabling lovlig. Prompten
  sin antatte rotårsak stemmer ikke. (Hard-refresh hvis det fortsatt feiler — send ev. repro.)

---

## 2026-06-22 — Folie: sone-basert utlegg + hindring-varsel (verifiser-først)

Fire sammenhengende folie-problemer (sone-utlegg, hindring-eksklusjon, uavhengige
arealer). Diagnostisert empirisk i koden FØRST (innlogget, ekte produkter). Commits
(nyeste først): `bab96f6`, `07866c5`, `f80a5c8`, `a591539`, `49c5e41`.

**Verifisering (read-only) viste at 4/3/2 alt var helt/delvis løst siden prompten:**
- **Problem 4 (uavhengige arealer)** — allerede løst: `_stripOverlapsAny`/`_clampStripToRoom`
  er 2D-lokale (along-akse-vakt), og auto-folie-unngåelse trekker fra hver folie som
  rektangel. Bekreftet med repro. Ingen endring.
- **Problem 2 (auto rundt hindring)** — fungerer: `computeClippedSegments` klipper
  strimler m/ margin rundt hindringer. Bekreftet. Ingen endring.

**Problem 3 — varsle folie oppå/under hindring** (`49c5e41`)
- `getStripViolations` sjekket bare avstand-til-kant, så en strimmel som overlappet
  (delvis/helt inne i) en hindring ble aldri flagget. Ny `_rectIntersectsPoly` (rect ∩
  polygon) → overlapp ⇒ avstand 0 ⇒ brudd. Samme varselmekanisme (modal + sidepanel),
  ved drag og plassering. Ingen falsk positiv når strimmelen er klar av hindringen.

**Problem 1 — sone-basert auto-utlegg** (`a591539`)
- `_decomposeRoomToRects`: ortogonalt rom → akse-justerte rektangler. `_packRectBestDir`:
  pakk hver sone uavhengig (clipPoly), velg retning (v/h) etter best dekning.
  `autoAddStripsZoned` (auto-knappen peker hit) bruker `_withFoilAvoid` så soner aldri
  overlapper; hindringer rutes rundt. Fallback til `autoAddStrips` for enkle/ikke-ortogonale
  rom (ingen regresjon). Låste regler består.
- Verifisert: L-form → 2 soner, 0 overlapp, sone-isolert, 0 folie under hindring;
  rektangel → fallback.

**Problem 1 — koblet inn i faktisk flyt + bedre dekning + robusthet** (`f80a5c8`, `07866c5`, `bab96f6`)
- Sone-utlegget lå i en sekundær knapp som hovedflyten ikke bruker. Nå tilbyr
  `showAutoFillComparison` et tredje «★ Soner»-kort (ved siden av Horisontal/Vertikal),
  via `_zonedFoilDefs` (defs uten å plassere; sentinel-strips så soner aldri overlapper).
- Adaptiv bredde per sone (bredeste folie som får plass → smalere fyller resten) + retning
  per sone etter dekket areal → kraftig bedre dekning (U-rom: H/V 57 % → Soner 87 %).
- **Robust dekomponering:** klyng/snap koordinater + soner garantert inne i rommet (snitt
  av flere skann). Fjernet den harde ortogonalitets-bailen som gjorde at håndtegnede
  (litt skjeve) rom aldri delte seg → «Soner» dukket aldri opp. Nå trigger den på ekte
  L/T/U-rom; >12 soner → fallback. Verifisert: noisy U m/ hindring → Soner 78 %, 0 overlapp,
  0 folie under hindring, 0 strimler utenfor rommet.

---

## 2026-06-22 — WBW-flyt (vegg-for-vegg): taster + mus

Raskere og mer naturlig vegg-for-vegg-opprettelse, uten å bygge nytt. Commits
(nyeste først): `e5ea346`, `6e023fe`, `601eb29`.

**Taster** (`601eb29`)
- Piltast (↑↓←→) legger veggen direkte i den retningen (var allerede på plass);
  beholder fokus+merk på lengdefeltet etterpå → rask repetisjon for rektangler.
- Skjerm-pilene speiler nå piltastene (`wbwDirPlace` = `setDir` + `addWbwWall`).
- Enter lukker rommet; en vegg som lander på startpunktet auto-lukker.
- Status + Taster-tooltip oppdatert til ny flyt.
- Fiks (`e5ea346`): `addWbwWall`/`undoWbwWall` kalte aldri `render()`, så en vegg lagt
  med piltast dukket først opp ved musebevegelse → kaller nå `render()` umiddelbart.
  Svak stiplet forhåndsvisning av neste vegg vises så snart en lengde er skrevet
  (live mens lengden endres); blir grønn når veggen vil lukke rommet.

**Mus** (`6e023fe`)
- Enter lukker nå i BEGGE moduser. Klikk nær startpunktet (≤ 14 px) lukker rommet
  (≥3 vegger); pekeren blir «pointer» når et klikk lukker.
- Grønn stiplet lukkelinje + forstørret start-prikk vises når musa er nær start,
  så det er tydelig at neste klikk lukker.
- Behold fast-lengde-forhåndsvisning som følger musa, Shift = frihånd, og auto-lukk
  når en festet vegg lander på start. Mus-tooltip/hint oppdatert.

Verifisert (innlogget): firkant via piltaster og via pek+klikk gir begge eksakt
300×300-rom; klikk-på-start og Enter lukker i musemodus.

---

## 2026-06-22 — Kabel-tilbehør ved PDF-eksport (typeavhengig)

Utvidet den deklarative tilbehørs-funksjonen til varmekabel, og gjorde hele tilbehørs-
lista typeavhengig. Commits (nyeste først): `f4e108e`, `ff51e3b`, `c57c88c`, `3720ce4`, `f445aec`.

**Typegating + kabel-tilbehør i modal** (`f445aec`)
- `showAccessoriesModal()` viser Varmefolie-seksjon KUN ved folie og Varmekabel-seksjon
  KUN ved kabel (begge hvis begge; matte alene → ingen). Avledet fra `S.strips`/`S.cables`.
- Ny deklarativ `CABLE_ACCESSORIES` + `_computeCableContext()`:
  - Strips svart (CV087193): 4/m → rund opp til hele 100-pk, viser utregningsgrunnlag.
  - Stålnett (CVA10900): per-rom sjekkliste, `ceil(netto_m2 × 1,10 / 0,92)` pr rom + live total.
  - Følerrør: 1 per kabel-rom; art.nr/EL-nr slås opp i katalogen, flagges hvis det mangler.
- Items merkes `type:'foil'|'cable'`. Ingen regresjon i folie-tilbehør/RKK.

**PDF/Excel gruppert per type** (`3720ce4`)
- PDF «Tilbehør» får egne underseksjoner (Varmefolie / Varmekabel) med art.nr/EL/enhet/
  antall; stålnett viser valgte rom, manglende katalog-nr flagges «OBS:».
- Excel Bestilling + Materialliste skiller tilbehør per type; stålnett-rom i Rom-kolonnen.

**Modal: ingenting forhåndsavhuket + ryddet stålnett-tekst** (`f4e108e`)
- Alle avkrysninger (folie, kabel OG stålnett-rom) starter UAVHUKET. Antallet vises
  fortsatt ferdig utfylt (redigerbart); kun avhukede poster tas med i rapport/PDF.
  «Total stålnett» teller bare avhukede rom (0 når ingen er valgt).
- Fjernet hjelpelinja over stålnett-lista (spec/art.nr) + «velg rom med brennbart
  underlag» → kun «Stålnett» + romliste (navn, areal, antall nett). Beregninger uendret.

**Art.nr/EL-nr hardkodet + avhuket som standard** (`c57c88c`, `ff51e3b`)
- Tilbehør ligger ikke i `heating_products`, så katalog-oppslaget fant dem ikke.
  Hardkodet art.nr + EL-nr (hentet fra cenika.no produktsider):
  - Strips svart **CV087193** · EL **1322300**
  - Stålnett **CVA10900** · EL **1001896**
  - Følerrør **CVA10526** · EL **5400784**
- Alt kabel-tilbehør er `defaultEnabled:false` (ikke valgt som standard); antallet vises
  fortsatt i feltene, så man bare huker av det som skal tilbys. Folie-tilbehør uendret.

Verifisert mot ekte data (innlogget): auto-regler 75 m → 300 strips / 3×100pk · bad 5,8 m²
→ 7 nett · 1 føler/rom; defaults avhuket m/ synlig antall; EL-nr følger med på items;
exportPDF kjører ende-til-ende uten feil.

---

## 2026-06-22 — Gulvtype (toppgulv) + read-only prosjektpresentasjon

To sammenhengende ting: gulvtype per rom med effekt-kompatibilitet, og en read-only
«som prosjektert»-presentasjon. Commits (nyeste først): `87c0bc4`, `9487807`, `d8d89cb`,
`1cab5da`, `5e75838`.

**Del A — Gulvtype + kompatibilitet** (`5e75838`)
- Nytt valgfritt `floorType` per rom (lagres automatisk via `_buildSaveData`).
- `FLOOR_TYPES` som data: maks anbefalt flateeffekt per gulvtype (flis/mikrosement/betong
  150, vinyl/laminat/parkett 100, teppe 60, annet/ukjent = ingen sjekk) — lett redigerbar.
- Ren funksjon `floorTypeCompat(floorType, wm2)` → ok/advarsel/none + delt banner
  `_floorCompatBannerHtml`. Toppgulv-velger + live varsel i UPC-panelet og hurtig-
  prosjekteringskortet. Degraderer pent når gulvtype mangler.

**Del B steg 1 — Presentasjonsmodus** (`1cab5da`)
- «▶ Presentasjon»-knapp i topbar. Gjenbruker editor-canvas + `render()` via
  `S.ui.present` (ingen ny tegning); `body.present-mode` skjuler all redigerings-chrome.
- Topptekst (prosjektnavn, «Prosjektert av <leverandør> for <firma>», dato) + nøkkeltall
  (antall rom, oppvarmet areal, total installert effekt). Leverandøruavhengig, nøytral
  default «Varmeplan». Read-only input: kun panorering/zoom; Escape avslutter.

**Del B steg 2 — Detaljpanel** (`d8d89cb`)
- Hold over (desktop) / trykk (mobil) et rom → fremheving (cyan kontur/glød) + detaljpanel:
  produkt + artikkelnr, installert W, flateeffekt, c/c, kabellengde, spenning, nominell
  motstand (R = U²/P), og toppgulv + kompatibilitet. Treff-test via `ptInPoly`.

**Del B steg 3 — Gulvtekstur + delelenke + PDF** (`9487807`, `87c0bc4`)
- Subtil gulvtekstur per gulvtype UNDER leggemønsteret: rutenett (flis/mikrosement/betong),
  bordmønster (laminat/parkett/vinyl), prikker (teppe).
- «🔗 Del lenke» genererer/lagrer `present_token` og kopierer `?present=<token>`. Boot-sti
  åpner prosjektet read-only uten innlogging via sikker `get_present_project`-RPC (anon kan
  ikke liste andre delte prosjekter). «⬇ PDF» gjenbruker `exportPDF()`.
- Ny migrasjon `supabase-migration-presentation.sql` (kjøres manuelt): `present_token`-kolonne,
  RPC, anon-lesetilgang til katalogtabeller. Mockup i `docs/Varmeplan-prosjektpresentasjon.html`.
- **NB:** Supabase-rundturen for delelenken er implementert men ikke testet mot live DB —
  test «Del lenke» + åpne lenken i privat vindu etter at migrasjonen er kjørt.

---

## 2026-06-18 — Hurtig prosjektering: «Lagre prosjekt»-knapp (commit 2f080da)

Tydelig lagre-kontroll nederst i romlista, som komplement til autolagringen.
- Teal «Lagre prosjekt»-knapp rett under «Opprettede rom»; deaktivert når lista er tom.
  Autolagrings-indikatoren i headeren beholdt.
- `_listSaveProject` → idempotent flush (`_saveToSupabase`) + toast «Lagret – finnes i
  prosjektlista og i feltappen»; knappen viser «Lagret ✓», og «Gå til prosjektliste»
  dukker opp (uten å tvinge navigasjon).
- Navngiving for gjenfinning: ved autonavn («Prosjekt – <dato>») ber `_listSaveNameDialog`
  om prosjektnavn (+ valgfri adresse) før lagring; ellers lagres direkte. Navnet skrives
  til `romtegner_projects.name` → søkbart i feltappen.
- Datastruktur uendret — samme record (rom + produkter i `data`) som feltappen leser; kun verifisert.

---

## 2026-06-16 — Import plantegning: tegnede rom, samlet meny, kalibreringsvalg, lag-filter, folie-label

Bygde ut PDF-importen (mot den delte motoren) så den også gir **ekte tegnede rom**, og
ryddet i import-UX etter testtilbakemelding. Commits (nyeste først): `e963ae4`, `9c679de`,
`81a8fcf`, `caf0c6a`, `2218a1d`, `fdd2fcc`, `23eb071`.

**Importer plantegning → tegnede rom** (`23eb071`, `fdd2fcc`)
- Ny adapter `_drawCreateRoomsFromReview`: motor-polygon (meter, Y-opp) → cm med Y-flip →
  `createRoom(pts,'polygon',navn,floorId,keepPosition=true)` = ekte rom m/ vegger, bevart
  innbyrdes plassering. Mål (`target` 'draw'/'list') tres gjennom review-flyten.
- «Importer plantegning» i tegne-verktøylinja (ctxbar) peker nå på motor-importen.

**Samlet import-meny** (`2218a1d`)
- Én «Importer plantegning»-knapp → `_importPlanMenu`: «Les av rom automatisk» (motor) eller
  «Tegn selv over bakgrunn» (PDF/JPG som bakgrunn, også skannede).

**Auto-les med bakgrunn + kalibrering i flukt** (`caf0c6a`, `81a8fcf`)
- Auto-les laster PDF som **bakgrunn** (pdf.js), bruker kalibrerer, så plasseres rommene
  nøyaktig oppå (kanonisk frame: PDF-punkt (0,0) = verden (0,0), skala fra kalibrert bakgrunn).
  Bakgrunnen blir liggende så møblering vises mens man tegner folie.
- Kalibrerings-overlayet tilbyr nå **begge** metoder: «Klikk to punkter (kjent avstand)» og
  «Fast målestokk (1:50)» (gjaldt før kun to-punkts). Gjelder all bakgrunnsimport.
- **Lag-filter:** auto-les henter PDF-lagene og lar bruker huke av vegg-lag (default
  vegg/yttervegg/skille) → kun vegger blir rom; møbler/inventar/tekst vises kun i bakgrunnen.

**Folie-stripe-label mindre på skjerm** (`9c679de`)
- Folie-stripe-labelen skaleres ned på canvas (lettere å lese romoppsett), men beholder
  passende størrelse i PDF-utskrift.

**Liste-import (hurtig prosjektering) — to skaleringsvalg** (`e963ae4`)
- PDF-importen i hurtig prosjektering får i tillegg til «Målestokk 1:__» et valg
  «Klikk et kjent mål i tegningen» (to-punkts via bakgrunn). Etter målsetting fortsetter
  alt som før: vegg-lag → liste med romnavn + areal.

**Forbehold (uendret):** selve motoren testes mot ekte vektor-PDF fra brukerens maskin
(sandkassen min når den ikke). Bakgrunn↔rom-justering kan trenge én finjusterings-runde på
en virkelig tegning. Lag-filteret virker kun hvis PDF-en har lag som skiller vegger fra møbler.

---

## 2026-06-15 (kveld) — Infra: motor deployet til Fly, mappe-organisering, feltapp-oppsett

Ikke `romtegner.html`-endringer, men workspace/infra fra samme økt — loggført for sporbarhet.

**Lumelo-motoren live på Fly.io**
- Deployet `~/Code/lumelo-backend` (FastAPI) → `https://lumelo-backend.fly.dev` (region arn,
  scale-to-zero). La til `Dockerfile`/`fly.toml`/`.dockerignore` + CORS for arqely.com i
  `app/core/config.py` + deploy/status-notis i `lumelo-backend/CLAUDE.md`. Commit i
  lumelo-backend: `95b45a5` (repoet har ingen remote ennå — kun lokal commit).
- Verifisert `GET /health` → ok (fra mobil; mitt sandkasse-miljø når ikke eksternt nett).
  Sandkasse-merknad: Bash/preview/WebFetch er nett-begrenset her → ekstern verifisering må
  gjøres fra brukerens maskin.

**Prosjektmappe-organisering** (`~/Documents/Claude Code/`)
- Den ekte koden til Lumelo bor i `~/Code` (ikke iCloud). La inn **symlenker** under Claude
  Code-mappa: `lumelo` → `~/Code/lumelo`, `lumelo-backend` → `~/Code/lumelo-backend`
  (samlet tilgang, men deps synkes ikke til iCloud).
- `Lumelo_Spec` → omdøpt til **`Lumelo_Spec (arkiv)`** (kun gammel plan/spec; den ekte koden
  er symlenkene). `arqely-mvp` = fortsatt rotmappa til Varmeplan-web.

**Ny app: Varmeplan Feltapp (Prompt 0 + oppsett)**
- Eget prosjekt for mobil feltapp (Expo/React Native), delt Supabase. Opprettet
  `~/Code/varmeplan-app` (+ symlink i Claude Code-mappa) med `docs/` (UX-prototyper +
  `supabase-schema/` = migrasjonene) og en `CLAUDE.md` som fanger Prompt 0-planen:
  offline-først (expo-sqlite + outbox), backend-kontrakt (rom i prosjekt-JSON, integer
  product_id, klient-genererte UUID-er, RLS via org-medlemskap), måleregler fra `suppliers`,
  navigasjon + 6-stegs byggeplan. Bygges i egen Claude Code-økt (Prompt 1).

---

## 2026-06-15 — Import plantegning: gjennomgangssteg, motor live, og liste-UX

Koblet PDF-import (mot den delte Lumelo-motoren) til hurtig prosjektering via et
fokusert gjennomgangssteg, og fikk **motoren live i produksjon**. Commits (nyeste
først): `aebdd88`, `d635d91`, `c8e0802`, `51b334b`, `021f21d`.

**Gjennomgangssteg (steg 2)** — `#import-review-screen` (`021f21d` la import, `51b334b` la gjennomgang)
- `_pdfImportRun` → `_pdfOpenReview(ImportResult)` i stedet for rett i lista.
- To synkroniserte ruter mot én kilde (`_reviewState.rooms`): SVG-plan (polygoner,
  bbox→viewBox, flip Y; teal=valgt, grå=fravalgt, gul=warn; klikk=toggle) + redigerbar
  liste (navn/areal/slett/legg til). Toveis hover via rom-id.
- Areal = shoelace(polygon, m²). `review[]` plasseres i riktig rom via `where`-punkt;
  navnløse rom → «Sjekk navn». Bulk (alle/ingen/forslag) + smart standard fra
  `_pdfGuessRoomType`. Gulvoppbygging lagres (`_floorBuild`). Adapter
  `_pdfCreateListRoomsFromReview` → `_listCreateRoomObj`.

**Motor live på Fly.io** (`c8e0802`, `d635d91`)
- `_engineUrl()`: `window.LUMELO_ENGINE_URL` → `localStorage['lumelo_engine_url']` →
  vertsbasert (arqely.com → `https://lumelo-backend.fly.dev`, ellers localhost:8000).
  Feil-dialog lar deg lime inn/lagre motor-adresse.
- Motoren (`~/Code/lumelo-backend`, FastAPI) deployet til Fly (`lumelo-backend.fly.dev`,
  region arn) — bekreftet `/health` = ok. Se [[project_lumelo_engine]].

**Liste-/import-UX** (`aebdd88`)
- Fiks blank side: `_pdfOpenReview` skjulte `#app`; `_reviewReturnToApp()` viser den igjen
  ved commit/avbryt → man lander rett i hurtig prosjektering.
- Prosjektnavn ved import (felt i gjennomgang-toolbaren → `S.project.name`).
  **Bugfiks:** `_ensureDraftProject` auto-navnga ALLTID ved autolagring og overskrev
  brukerens navn — nå kun når navnet er tomt.
- Valgt rom forsvinner ikke lenger fra lista: redigert rom blir værende i tabellen,
  uthevet (teal + ● + venstrekant); kortet får «Rediger rom: \<navn\>».
- Piltaster på Type/Klasse/Produkt/Etasje-nedtrekkene stepper valget med live CC + W/m².

Alt verifisert i preview (mock-import, ingen DB-skriving). Motor-deploy-artefakter
(`Dockerfile`/`fly.toml`/`.dockerignore` + CORS for arqely.com) ligger i `lumelo-backend`.

---

## 2026-06-13 — Autonom polering av dok-/garanti-/reklamasjonsmodulen

Kjørt autonomt (uten brukervalg) mens bruker var borte. Alt verifisert i preview
(parse + render + PDF-bygging med mock-state, ingen skriving til produksjons-DB).
Commits (nyeste først): `bf64a2d` (kode), + CLAUDE.md / Edge Function / denne loggen.

**Selvgjennomgang + buggfiks** (underagent-review av all ny kode)
- `_docUpdProduct`: `nominal_ohm` settes til `null` (ikke `NaN`) når effekt tømmes.
- `_claimMutate`: kaster nå feil ved mislykket `claim_events`-innsetting (ingen stille feil).
- `_docMeasOk`: robust fallback til standard-leverandør hvis `_docState` mangler
  (hindrer krasj ved PDF-bygging uten aktiv state).

**Montørens sak-status (les-only)** — `_claimStatusView`
- Fullført rom i doc-velgeren viser «Sak: <status>» når en reklamasjon finnes, og åpner
  en les-only statusvisning med tidslinje + «neste steg» (venter på godkjenning /
  godkjent → kontakt feilsøkefirma / avvist / lukket). Henter kun egne saker.

**Rikere garantibevis-PDF** — `_docBuildPDF`
- Leverandørfarget topp (hex→rgb for robust jsPDF-rendering).
- Fotodokumentasjon bygget inn som miniatyr-rutenett (2 per rad, automatisk sideskift).

**Dokumentasjon / scaffold**
- `CLAUDE.md`: ny seksjon «Documentation, Warranty & Claims Module (implemented)» —
  tabeller, RLS-mønster (JWT-superadmin), kodekart, z-index- og e-post-konvensjoner.
  Flyttet ut av «Future».
- `supabase/functions/send-warranty-email/` (index.ts + README): Edge Function for
  kunde-/leverandørkopi (Resend). **Inaktiv** til den rulles ut + secrets settes —
  README har deploy-steg og hvordan den kobles på i `_docGenerate`/`_claimSubmit`.

**Gjenstår til bruker (krever valg/nøkler):** rull ut Edge Function (Resend-nøkkel +
verifisert domene) og koble den på; «del med huseier»-offentlig visning (krever ny
anon-RLS-policy via share_token — egen migrasjon).

---

## 2026-06-12 — NY MODUL: Dokumentasjon & garantiportal (Fase 1–3, hele Prompt 0→3)

Bygget en komplett dokumentasjons-, garanti- og reklamasjonsmodul oppå eksisterende
prosjekt/rom/produkt/innlogging. Alt verifisert i preview (UI + PDF) og ende-til-ende mot
Supabase (lagring + reklamasjonsflyt, med opprydding av testdata). Pushet til `main`.
Commits (nyeste først): `8bf26f9` (Fase 3), `1176ed0` (Fase 2), `e48b862` (Fase 1).

**Migrasjoner (kjørt i Supabase, ren ASCII, idempotente)**
- `supabase-migration-documentation.sql` — `suppliers` (leverandør som data, seed Cenika m/
  måleregler ±10 %, >10 MΩ @ 500 V), `supplier_id` FK på `heating_products` (integer, ikke uuid),
  `warranty_certificates`, `certificate_products`, `measurements`, `certificate_photos`, RLS + privat
  `documentation` storage-bucket.
- `supabase-migration-claims.sql` — `claims`, `claim_events` (tidslinje), `claim_photos`, RLS.
- **RLS-lærdom:** superadmin-policyer må lese `is_superadmin` fra `auth.jwt() -> 'app_metadata'`,
  IKKE `SELECT FROM auth.users` (authenticated mangler tilgang → 42501; separate policyer
  kortslutter ikke slik OR-uttrykk inni én policy gjør).

**Fase 1 — Dokumentasjon (`e48b862`)**
- Ny «Dokumentasjon»-fane (prosjekt-/rom-velger) + rollestyrt «Garantiportal»-fane (kun
  `org_type='supplier'`) + «Dokumentér»-snarvei i rom-høyreklikkmeny.
- Mobil `#doc-screen` 5-stegs veiviser: bekreft produkter (prefill fra tegning, nominell R=U²/P)
  → installasjon & styring → måleverdier m/ live validering (grønn/rød) → foto med faste slots
  → sjekkliste + signatur → genererer garanti-ID, lagrer bevis + PDF (jsPDF) til skyen.

**Fase 2 — Garantiportal (`1176ed0`)**
- KPI (totalt, denne måneden, med avvik, aktive firma), filtrert bevisliste (søk + status + firma +
  periode), detaljpanel med fargekodet måletabell (mot leverandørtoleranse), foto via signerte
  storage-URL-er, «Åpne PDF». RLS «Supplier orgs read their certificates» filtrerer automatisk.

**Fase 3 — Reklamasjon (`8bf26f9`)**
- Mobil `#claim-screen` «Meld feil» (kanal app + telefon → samme sak): feiltype, kundebeskrivelse,
  feilsøk (R/iso/foto), anbefalt tiltak, feilsøkefirma, kunde-e-post → sak m/ tidslinje.
- Portal under-nav Garantibevis|Reklamasjoner: statistikk (antall, samlet kostnad, vanligste årsak,
  andel dekket), saksliste, saksdetalj med tidslinje + **godkjenningssteg** (Godkjenn/Avvis —
  feilsøkefirma sendes ikke ut før godkjent) + kostnad + utfall (godkjent/delvis/avslått → lukk).
- Innganger: «⚠ Meld feil» på fullført rom i doc-velger + «Registrer telefonsak» i bevisdetalj.

**Bevisste valg / gjenstår**
- Leverandør som data (ØS Varme = «én ny rad»). Egne tabeller, ikke prosjekt-JSON (portal-søk på tvers).
- Skjermer `#doc-screen`/`#claim-screen` må ha z-index > 1001 (dashbordet `#project-list-screen` = 1001);
  portal-modal z-index 2000.
- E-post (kunde-rutinevarsel + leverandør/montør-kopi) utsatt til Supabase Edge Function — vises som
  info; alt lagres i skyen uavhengig. `share_token` finnes på beviset for senere «del med huseier»-lenke.

---

## 2026-06-10 — ØKT-OPPSUMMERING (stor økt: kabel-, folie-, matte-, soner- og plantegning-arbeid)

Detaljerte oppføringer pr. punkt under. Alt verifisert (mest numerisk in-memory pga. treg test-fane
mot slutten) og pushet til `main`. Commits (nyeste først): `83eeab3`, `438cc2d`, `3762ab9`,
`3a36364`, `e81773b`, `fd1a8eb`, `0bc8953`, `81626be`, `053b363`, `d18ce32`, `f810848`, `28422d8`,
`298d11e`, `193e8d6`, `720947a`, `fd78476` (+ tidlig: `616a110`, `6dee009`, `bc0d773`).

**Varmekabel**
- `fd78476` V6 honorerer valgt RETNING (`dirExplicit`) — slutt på «velger horisontalt, legger vertikalt».
- `720947a` L/T horisontalt → ren boustrophedon-serpentin; + 5 cm perp-margin fra indre parallelle vegger.
- `193e8d6` auto-retning foretrekker den rene (godt-fyllende) boustrophedon-retningen.
- `3a36364` «Del i N like soner» med eksplisitt horisontal/vertikal-toggle (hard honorering, felles CC).
- `83eeab3` rene multi-kabel-soner i komplekse rom (betinget vertex-snap + ingen skew i soner).
- (tidlig: retningsvelger-reapply, L-diagonal→ortogonal, rektangel-starthjørne.)

**Varmefolie**
- `f810848` «lange strimler vegg-til-vegg» som default (mot fragmentering) + bryter «Maks dekning».
- `e81773b` ALDRI folie over folie (hard invariant: footprint-subtraksjon ved fyll + retnings-uavhengig overlapp).

**SONER (utleggingssoner)**
- `28422d8` del et rom i navngitte soner via delelinjer; folie pr. sone, per-kant margin (yttervegg vs delt grense).

**Hindring**
- `298d11e` fri plassering + mykt vegg-snap (`clampHindringToRoom` omskrevet: containment + sann segment-avstand).

**Plantegning / bakgrunn**
- `d18ce32` «Fast målestokk» (1:50) alltid tilgjengelig + eksakt for PDF.
- `053b363` deselekter bakgrunn etter skalering (henger på skalerings-baren).
- `81626be` + `0bc8953` lås kalibrert underlag (klikk-felle), også eksisterende prosjekter.
- `fd1a8eb` bakgrunn lekket til andre prosjekter (async onload-race) — token-guard.

**Matte (EcoMat innendørs)**
- `3762ab9` EcoMat 60T/100T/150T-utlegg: bredder inntil hverandre + kald sone, hele matta delt i N like bredder.
- `438cc2d` innendørs: tydeligere produkt-label (unna romnavn), kabel-label alltid synlig, matter unngår hindringer (5 cm), matte-gap min 0 (folie-modell).

**Anbefalt neste steg (ikke gjort):** felles kabel/folie/matte-INVARIANT-spec + testliste alle motorer
må bestå (5 cm margin, lik CC, hjørne-start/stopp, eksplisitt retning hard, aldri overlapp, ingen
diagonal/rar form, fyll til vegg) — fanger samme rot-klasse systematisk. Venter på «si fra».

---

## 2026-06-10 — Varmekabel: rene multi-kabel-soner i komplekse rom (Gang) — betinget vertex-snap + ingen skew i soner

Symptom: Gang (~37 m²) delt i 2 like soner — sone 1 ren serpentin, sone 2 (irregulær equal-area-
halvdel) fikk «rare former» (skew-løp, skrå/ujevne U-svinger) og fylte ikke til veggene.

### Rotårsak
`_buildNCableZones` kuttet med `_equalAreaBandBounds` (lik areal → lik CC), men på et komplekst rom
ble sone 2 IRREGULÆR → `_autoFillCableImpl` sin `needSkew = !rectilinear || …` falt til
`generateCableSkew` → skrå løp / rare former.

### Fix (to prong)
1. **Betinget vertex-snap** (`_buildNCableZones`): re-innført `_snapBoundsToVertices` — snapper hvert
   indre kutt til nærmeste rom-hjørne/innhakk, MEN bruker det kun når sonene holder seg ~like store
   (areal-avvik ≤ 10 %); ellers beholdes equal-area-kuttet. Gir mest mulig REKTANGULÆRE soner uten å
   ødelegge lik CC.
2. **Ingen skew i soner** (`_noSkew`-flagg på sone-temp-rommet): `needSkew` respekterer nå
   `room._noSkew` → multi-kabel-soner bruker ren aksejustert serpentin (boustrophedon/V6, ortogonal
   kobling) i stedet for skew. «Heller jevnt udekket inntil vegg enn skrå/rotete løp» (Kenneths regel).

### Verifisert (numerisk; in-memory, ingen konsoll-feil)
- L-korridor (~35,8 m²) delt i 2, begge retninger: BEGGE soner = **boustrophedon**, `pathEls:0` (ingen
  skew), `nConn:0` (ingen diagonal kobling), lik CC 12,7 cm, ~140 m kabel hver (≈99 % dekning).
- Ingen regresjon: rektangel delt i 2 → begge boustrophedon (uendret); enkel kabel i SKRÅTT rom →
  bruker fortsatt skew (pathEls 51), siden `_noSkew` kun gjelder sone-temp-rom.

> Spec-en anbefaler sterkt en felles «kabel/folie/matte-invariant-spec» med testliste alle motorer
> må bestå (5 cm margin, lik CC, hjørne-start/stopp, eksplisitt retning hard, aldri overlapp, ingen
> diagonal/rar form, fyll til vegg). Ikke laget ennå — venter på «si fra».

---

## 2026-06-10 — Innendørs: tydeligere label + kabel alltid synlig + matte-hindring + matte-gap (4 punkter)

1. **Tydeligere produkt-label, unna romnavn:** font opp (strimmel 7–11 → 12–15 px; kabel 10 → 13;
   matte 12 → 13) og labelen FORSKYVES langs objektets lengde vekk fra rom-sentroiden (strimmel/
   kabel: ~28 % mot enden lengst fra sentroiden; matte: ~halvveis mot en ende), så den aldri ligger
   oppå romnavnet (som tegnes i sentroiden). Rammet 2-linjers-oppsett beholdt.
2. **Kabel + label ALLTID synlig:** kabel-labelen var gated på `S.ui.showStripLabels` (folie-toggel)
   → fjernet for kabel. Kabel-geometri OG label vises nå permanent uansett valgt rom/objekt (kun
   `cable.labelVisible===false` skjuler en enkelt). Valgt kabel uthives fortsatt.
3. **Matter unngår hindringer (5 cm):** `autoFillMatSerpentine` brukte før kun rom-bbox og rørte
   ALDRI `S.hindrings`. Nå inflateres hver hindring med veggmarginen (5 cm) og det brukbare
   rektangelet krympes grådig til største hindrings-frie side → ingen matte på/innen 5 cm av en
   hindring (verifisert: bunn-hindring y=300 → matte stopper y=282). Sentral hindring → matta havner
   på den største frie siden; per-løp-klipping rundt indre hindringer er en senere refinement.
4. **Matte-gap som varmefolie (min 0):** gap-panelet (`openMatGapPanel`/`setMatGap`/`stepMatGap`) er
   nå modul-bevisst — innendørs: min 0 / default 0 (matter inntil hverandre, sentrert) / max 5; snø
   (Ute/InSnow): beholder min 5 / standard 10 / max 20. Fikset `cm||10`-bug som gjorde 0→10. Motoren
   bruker bruker-gapen (default 0), sentrerer blokka → rest = kald sone likt på veggene. EcoMat-
   tvang-til-0 erstattet med denne (default 0 = samme edge-to-edge).

Verifisert: render m/strip+matte+ny label-kode 3 ms uten feil; hindring-unngåelse + gap 0/3/steg
numerisk. Items 1–2 (visuelt) bekreftet via kode + feilfri render — fin-justering av label-størrelse/
plassering kan vurderes visuelt (kunne ikke ta skjermbilde pga. treg test-fane).

---

## 2026-06-10 — EcoMat innendørs: matte-utlegg etter Kenneths modell (bredder inntil hverandre, hele matta delt i N)

Spec basert på 3 Cenika-produktblad (EcoMat 60T/100T/150T) + teknisk tegning TPL-ECOMT-CA-2183.

### Produktdata
- **Supabase hadde allerede ekte EcoMat-rader** (57 stk, laget 2026-03-11) med riktig
  cc/kutt/bredde/areal/W/art.nr/el.nr. Derfor: ikke dupliser — `_ensureEcoMatProducts()` injiserer
  hele katalogen (60T/100T/150T, 19 størrelser hver, 0,5×2m…0,5×30m, CVA10100–10158, el 1013743–
  1013799, fra produktbladene) KUN som fallback hvis ingen finnes.
- `_normalizeEcoMat()` markerer ALLE EcoMat-produkter (Supabase eller fallback) med
  `mat_equal_widths=true` (Supabase-radene mangler flagget). CC/kutt fra tegningen: 60T/100T = 120/
  240 mm, 150T = 80/160 mm; bredde 500 mm; W/m² 60/100/150.

### Matte-motor (`autoFillMatSerpentine`, gated på `mat_equal_widths`)
- **Bredder INNTIL hverandre:** `gapCm` tvinges til 0 for EcoMat → N = floor(brukbar bredde / 50 cm)
  eksakt; blokka sentreres → rest = kald sone likt på begge yttervegger (ikke jevn-fordelt gap som
  før). Seam-klaring kommer fra kant-inntrekket (2,5 cm hver side → ~5 cm kabel-til-kabel).
- **Størrelsesvalg snudd (Kenneths modell):** velg STØRSTE variant der (mat_total_length / N) ≤
  brukbar lengde; fordel HELE matta i N like bredder à (total/N), rundet NED til kutt-intervallet.
  Erstatter «minste matte ≥ behov + snap til rom». Bruker hele matta, minimer svinn, kald sone i
  lengde-enden.
- Retning respekterer delt retningsvelger; forhåndsvis-før-godta som ellers.

### Verifisert (numerisk; render 14 ms — ingen freeze)
- **Spec-eksempel 210×400, 100T:** N=4, velger 0,5×14m (700 W), 4 bredder à 336 cm (3,5m snappet
  til kutt 24cm), gap 0, **5 cm kald sone hver yttervegg**, brukt 13,4 av 14m. Matcher eksempelet.
- 260×600 100T → 0,5×28m, N=5. 210×400 150T → 0,5×14m (1050 W), N=4. 300×500 150T → 0,5×24m, N=5.
- Ikke-EcoMat-matter (InSnow utendørs) uendret (jevn-fordelt gap beholdt).
- Stats: produktets `total_effect_w` / `mat_area_m2` (ratet effekt), som InSnow.

---

## 2026-06-10 — Varmekabel: «Del i N like soner» med eksplisitt horisontal/vertikal-valg

Kenneth: del et stort rom (~37 m²) i 2–3 HELT LIKE soner → like kabler med jevn CC, og velg
eksplisitt om rommet deles horisontalt eller vertikalt. Motoren fantes (`_buildNCableZones`:
equal-area-soner + felles CC + like kabler); manglet UI + hard styring av retning.

- **UI:** delretning-toggle [Auto] [Horisontalt] [Vertikalt] i kabel-panelets manuell-/«Flere
  kabler»-seksjon (`_cableSplitToggleHtml`/`_setCableSplitDir`, modul-var `_cableSplitDir`).
  Antall = eksisterende count-input. «Forhåndsvis ›» bygger forslaget.
- **Hard honorering:** `_cableManualPreview` → `_cablePreviewPlace(...,splitDir)` →
  `autoFillMultiCable(roomId, productId, n, splitDir)` → `_autoFillNCables(forcedDir)`. forcedDir
  bygger KUN valgt retning (samme harde override som dirExplicit). Map: Horisontalt→'h'
  (horisontale delelinjer, soner stablet), Vertikalt→'v' (vertikale delelinjer, soner side om
  side). De power-drevne multi-kabel-knappene honorerer også toggelen (default `_cableSplitDir`).
  Auto (null) = motoren velger som før.
- **Beholdt:** equal-area-kutt (`_equalAreaBandBounds`), felles `sharedCC`, half-CC-sømmer → N
  identiske kabler med jevn CC også over sone-grensene.
- **Verifisert (37 m² rom, prod InFloor 10T 50m):** 3 vertikalt → 3 kabler alle 'v', soner
  [0–247][247–493][493–740], CC 24,7 cm identisk, 50 m hver; 3 horisontalt → alle 'h', samme CC;
  2 vertikalt → 2 like; Auto → motoren velger. Visuelt bekreftet (K1/K2/K3 side om side, identiske).
  Ingen regresjon på énkabel. Ingen konsoll-feil.

---

## 2026-06-10 — Varmefolie: ALDRI folie over folie (hard invariant)

Symptom: en folie (lang strimmel) la seg OVER andre folier. Krav: folie skal aldri overlappe
folie — stopp en klaring (≥ folie-gap) før eksisterende folie, uansett retning/sone/fyll-sti.

### Rotårsak
- Overlapp-vernet (`_stripOverlapsAny`) sjekket bare folier i SAMME retning (`_stripsForRoomDir`).
- `computeClippedSegments` klippet mot rom-polygon + hindringer + forbudt-soner, men ALDRI mot
  eksisterende folier → fyll/sone-fyll/lange-strimler kunne legge en folie rett oppå andre.

### Fiks
- **Footprint-subtraksjon i `computeClippedSegments`** (kjernen): ny modul-kontekst `_foilAvoidCtx`
  (`{roomId, excludeIds}`), satt via `_withFoilAvoid(roomId, exclude, fn)` rundt hver fyll-operasjon.
  Når satt, subtraheres footprinten til ALLE eksisterende folier i rommet (alle retninger/soner),
  inflatert med folie-gap, akkurat som en hindring — UNNTATT batchen som erstattes (unngår
  selv-blokkering). Opt-in → editorer/ikke-fyll-stier uendret.
- **Wiret i alle fyll-stier:** auto-fyll-sammenligning (ekskluder samme kategori), sone-fyll
  (ekskluder samme sone — peker på det EKTE rommet siden sone-fyll bruker temp-rom), manuell
  drop/preview (ekskluder ingen). «Lange strimler» går gjennom samme `computeClippedSegments`.
- **Retnings-uavhengig overlapp** i `_stripOverlapsAny`: i tillegg til samme-retning-logikken,
  ekte verdens-rektangel-nærhet (`_stripWorldRect`/`_rectsWithin`) mot folier av MOTSATT retning →
  manuell plassering/drag og sikkerhetsnett blokkerer kryssende folier.

### Verifisert (numerisk; ingen konsoll-feil)
- Eksisterende horisontal folie (y150–169); ny vertikal ved x180: uten vern ett løp y3–297 (overlapp);
  MED vern splittet y3–147 + y172–296 → stopper 3 cm (gap) før, ingen overlapp. Kryss-retning flagges.
- Sone-fyll: 0 overlapp mellom nabosoners folie (6 par sjekket).
- Ingen regresjon: rent rektangel auto-fyll uendret (2 striper/91 %); klaringen = folie-gap (holder
  SONER-skjøtens half-gap konsistent; «~5 cm ende-mot-side» er tilnærmet med gap — kan økes om ønsket).

---

## 2026-06-10 — Plantegning BUGFIX 4: bakgrunn «lekket» til andre prosjekter (async race)

Bruker: «bakgrunnstegningen jeg la inn på et prosjekt har lagt seg inn som bakgrunn på alle mine
lagrede prosjekter — ble ok igjen etter en refresh».

- **Rotårsak:** i `_restoreProject` lastes bakgrunns-bildet ASYNKRONT (`bImg.onload`). Åpner du
  prosjekt A (med bg) og så B, kan A-bildets `onload` fyre ETTER at B har nullstilt `S.bgs` →
  A-bakgrunnen skrives inn i B sitt `S.bgs`. Rent i minnet (derfor «ok etter refresh»); lekker bare
  til lagring hvis man lagrer mens den feil-bakgrunnen vises.
- **Fiks:** innlastings-generasjon `_bgRestoreGen` bumpes ved hver prosjekt-åpning; hver async
  bg-`onload` fanger generasjonen ved planlegging og skriver KUN hvis den fortsatt er gjeldende
  (`if (_myBgGen !== _bgRestoreGen) return`). Stale bilder fra et tidligere prosjekt ignoreres.
- **Verifisert:** to prosjekter åpnet etter hverandre gir konsistent `S.bgs` (ingen lekket bg),
  ingen feil.
- **Merk til bruker:** lekkasjen var i minnet → dine LAGREDE prosjekter er trygge (en refresh
  fjernet den). Hvis et prosjekt likevel viser feil bakgrunn ETTER refresh, si fra — da kan en
  feil-bakgrunn ha blitt lagret, og jeg rydder den.

---

## 2026-06-10 — Plantegning BUGFIX 3: auto-lås kalibrert underlag ved innlasting (eksisterende prosjekter)

Oppfølger: bruker fortsatt fast + «vis/skjul gjør ingenting». Reproduserte HELE den ekte flyten
interaktivt (importer → «Sett målestokk nå» → 2 klikk → 5 m → fullfør): etter kalibrering kommer
den kombinerte «BAKGRUNN Vis/opacity … | TEGN ROM Rektangel/Mål/…»-baren, klikk i tegningen holder
seg der (bg låst), og vis/skjul SKJULER tegningen korrekt. Altså: med gjeldende kode virker alt.

- **Sannsynlig årsak for «fortsatt fast»:** (a) deploy/cache-etterslep (eldre versjon i nettleseren),
  eller (b) eksisterende prosjekt med en ALLEREDE kalibrert, ULÅST bakgrunn — auto-låsen i bugfix 2
  gjelder bare NYE kalibreringer.
- **Fiks (b):** `_restoreProject` låser nå et kalibrert underlag ved innlasting
  (`if (bg.img && !bg._needsCalibration) bg.locked = true`) → eksisterende prosjekter blir også
  klikk-trygge (klikk går gjennom underlaget). Lås opp via lås-knappen for å flytte det.
- **Verifisert:** ulåst bg → klikk treffer; låst bg → klikk går gjennom (`_hitBgLayer` null).
  Full ekte kalibrerings-flyt gir «Tegn rom»-bar; vis/skjul fungerer.
- **Til bruker:** symptomene matcher å kjøre eldre kode — gjør en HARD refresh (Cmd/Ctrl+Shift+R)
  for å hente nyeste versjon.

---

## 2026-06-10 — Plantegning BUGFIX 2: lås underlaget etter kalibrering (klikk-felle)

Oppfølger: «jeg kan skalere og den går over til opprett-rom-baren, men hvis jeg klikker i tegningen
går den tilbake til plantegning-baren — kommer meg ikke ut.»

- **Rotårsak:** et kalibrert, ULÅST bakgrunns-lag er klikk-valgbart (`_hitBgLayer` treffer det).
  Etter skalering var baren riktig, men ETHVERT klikk i tegningen valgte bakgrunnen igjen →
  «Plantegning … Skaler på nytt»-baren kom tilbake, og man satt fast.
- **Fiks:** `confirmBgCalibrate` og `confirmFixedScale` setter nå `bg.locked = true` etter fullført
  kalibrering. `_hitBgLayer` hopper over låste lag → klikk går GJENNOM underlaget, så man tegner rom
  fritt. Lås opp igjen via lås-knappen (plantegning-ctxbar eller sidepanelets lag-liste) for å
  flytte/transformere underlaget. Standard CAD-oppførsel for et referanse-underlag.
- **Verifisert:** etter både fast målestokk og 2-punkts er `bg.locked=true`, `_hitBgLayer` ved et
  punkt inne i tegningen returnerer null, og klikk-kandidatlista er tom → ingen utilsiktet
  bg-seleksjon. `includeLocked`-stien finner det fortsatt for eksplisitte operasjoner.
- Merk: gjelder NYE kalibreringer. Eksisterende prosjekter med ulåst kalibrert underlag: lås det
  én gang via «Lås»-knappen i plantegning-baren, så går klikk gjennom.

---

## 2026-06-10 — Plantegning BUGFIX: «henger på skalerings-baren» etter kalibrering

Bruker: «det skjer ikke noe når jeg skalerer eller setter målestokk … nå vises kun topbar for
skaleringsvalg hele tiden» (tidligere kom rom-innsetting opp etter skalering).

- **Rotårsak:** når skalering trigges fra den VALGTE bakgrunnen (selectedBg satt — f.eks. via
  «Skaler på nytt»/«Målestokk 1:_» i plantegning-ctxbar-en), nullstilte hverken `confirmBgCalibrate`
  eller `confirmFixedScale` `S.ui.selectedBg`. Skaleringen BLE utført (widthCm endret), men
  bakgrunnen forble valgt → ctxbar-en hang igjen på «Plantegning … Skaler på nytt»-baren i stedet
  for å gå til «Tegn rom». Føltes som «det skjer ikke noe».
- **Fiks:** begge funksjonene nullstiller nå `S.ui.selectedBg = null` (i tillegg til
  selectedRoomId/selectedWallId) → ctxbar-en går korrekt til rom-innsetting etter skalering.
- **Verifisert:** både fast målestokk (1:50) og 2-punkts kalibrering trigget fra valgt bakgrunn gir
  nå `selectedBg=false` og ctxbar «Tegn rom … Rektangel/Mål/Polygon». Ingen konsoll-feil.

---

## 2026-06-10 — Plantegning: «Fast målestokk» (1:50) alltid tilgjengelig + eksakt for PDF

Bruker meldte «får ikke skalert tegning lenger» og ønsket målestokk-forhold (1:50) som tillegg.

### Funn (bug-undersøkelse)
- 2-punkts-kalibreringen (`startBgCalibrate` → klikk 2 punkter → `confirmBgCalibrate`) er IKKE brutt:
  verifisert ende-til-ende i appen (klikk 1 → punkt 1, klikk 2 → modal → skalerer; A4 100 px = 5 m
  ga riktig faktor). Logikken i både `confirmBgCalibrate` og `confirmFixedScale` er korrekt.
- Reell mangel: **«Fast målestokk» (forhold) var bare tilgjengelig på en NYIMPORTERT, ukalibrert
  tegning** (ctxbar-grenen `notCalibrated`). Når tegningen først var kalibrert og du valgte den for
  å re-skalere, fantes bare «Skaler på nytt» (2-punkts) — ikke forholds-skalering. Det forklarer at
  man «ikke får skalert» via forhold etterpå.

### Endringer
- **«Målestokk 1:_»-knapp lagt til i den valgte-plantegning-ctxbar-en** (ved siden av «Skaler på
  nytt») → forholds-skalering er nå tilgjengelig når som helst, ikke bare ved import.
- **Eksakt 1:50 for PDF:** ved PDF-import fanges den fysiske sidestørrelsen fra PDF-ens punkt-mål
  (`vp.width/RENDER_SCALE / 72 * 2.54`) og lagres som `bg.paperWidthCm/paperHeightCm`.
  `confirmFixedScale` bruker den når den finnes → 1:50 blir nøyaktig (A4-landskap 29,7×21 cm →
  1485×1050 cm). Raster-bilder (JPG/PNG) har ingen pålitelig fysisk størrelse → faller tilbake til
  150-DPI-antagelse som før.
- `_installBgImage(...,meta)` lagrer/nullstiller sidestørrelsen; rastersti uendret.

### Verifisert
- PDF (A4) 1:50 → 1485×1050 cm eksakt; raster 1:50 → 150-DPI-fallback; knappen vises i bg-ctxbar;
  2-punkts-kalibrering fungerer fortsatt. Ingen konsoll-feil.
- Merk: jeg klarte ikke å reprodusere en brutt 2-punkts-flyt — hvis «får ikke skalert» fortsatt
  skjer, trengs det konkret symptom (hvilken knapp, hva skjer).

---

## 2026-06-10 — Varmefolie: «lange strimler vegg-til-vegg» som default (mot fragmentering)

Snur folie-prioriteringen fra «maks dekning» til **få, lange, ensartede strimler vegg-til-vegg**,
med en bryter for de som vil ha maks dekning. Løser runde-2-folie-punktet (fragmentering i
uregelmessige/trappetrinn-rom) — og forbedrer samtidig folie-dekning i uregelmessige SONER.

### Rotårsak (fragmentering)
- `chooseBestProduct` byttet til SMALERE folie når en kolonne ble klippet <90 % (mot et
  trappetrinn) → patchwork av bredder.
- `_autoFillRoomOnce` lagde én strimmel pr. SEGMENT → en kolonne ble delt i hoved + kort topp-bit.
- `_scoreFoilLayout` maksimerte AREAL (straffet antall svakt) → «maks dekning» vant.

### Fiks
- **Strategi-flagg** `S.varmefolie.foilStrategy`: `'long'` (default) | `'coverage'`. Bryter i
  auto-plasserings-panelet («Lange strimler» / «Maks dekning»), `_setFoilStrategy` re-kjører.
- **`_autoFillRoomOnce(...,longMode)`**: ÉN ensartet bredde for hele rommet (ingen per-kolonne
  nedskalering), og ÉN strimmel pr. kolonne (lengste sammenhengende segment). Godtar litt udekket
  langs grunne/uregelmessige kanter.
- **`_longStripsLayout`**: prøver HVER ensartet bredde × begge sweep-ender, velger beste long-score
  → bredt for rektangel, smalere der bredt knapt får plass (L/arm-soner) → god dekning med få,
  lange strimler. Brukt av `_autoFillBothDirections` (default-stien) og `_fillSoneFoil`.
- **`_scoreFoilLayout` 'long'-profil**: maks dekket areal MINUS reell kostnad pr. strimmel (≈8 % av
  romarealet) og pr. ekstra breddetype (≈12 %) → en ekstra strimmel/kobling må «fortjene plassen»
  i dekning. Retning velges av denne scoren (lengste/færreste vinner).
- Når retning ikke er eksplisitt valgt: scoren foretrekker naturlig retningen med lengst strimler.

### Verifisert (numerisk; ingen konsoll-feil)
- Rektangel 400×300: long = 2 striper / 1 bredde / 91 % vs coverage = 3 / 2 bredder / 94 %.
- Trappetrinn-rom: long = 2 / 1 / 87 % vs coverage = 3 / 2 / 94 %.
- L-formet sone (Vindfang Sone 2): long = **57 %** (2 striper) — bedre enn coverage 43 %, og fikser
  en mellomliggende 27 %-regresjon (bredeste-uniform alene).
- «Maks dekning»-bryter gir dagens tettere/mer oppdelte layout (eksisterende motor uendret).
- Vanlig rom-folie i coverage-modus uberørt; `computeClippedSegments`/`_autoFillRoomOnce`-tillegg
  bakoverkompatible.

### Ikke gjort (informativt, ikke blokkerende)
- Eksplisitt markering «trenger tilførsel fra begge ender / skjøt» for svært lange strimler er
  ikke lagt til (antall striper i panelet = antall tilkoblinger; ingen hard produkt-maks kjent).

---

## 2026-06-10 — SONER: del et rom i navngitte utleggingssoner (Kjerne)

Ny feature: del ett rom i flere SONER med delelinjer, fyll folie pr. sone med individuell
retning og per-kant margin. Scope «Kjerne først» + rette delelinjer vegg-til-vegg (bekreftet
med bruker). Bygger på eksisterende sone-/folie-infra. Verifisert numerisk + visuelt på ekte
Bloksbergveien/Vindfang og syntetiske rom; ingen konsoll-feil; ingen regresjon på vanlig
rom-folie.

### Datamodell
- Ny `type:'sone'` i `S.zones`: `{id,roomId,type:'sone',name,points,direction,startCorner}`.
  Holdt UTENFOR alle `type==='forbidden'/'preferred'`-filtre (de matcher ikke 'sone') → kabel/
  folie-constraints uberørt (verifisert).
- Folie-strimler får `zoneId` (null for vanlig rom-folie).

### Opprettelse — «Del i soner» (rett delelinje)
- Ny modus (ctxbar-knapp på valgt rom): klikk to vegger → endepunkter snappes til rom-/
  sonegrensen → **robust polygon-split langs korde** (`_splitPolygonByChord`) deler rom-
  polygonet (eller sonen linja krysser) i to. Sonene PARTISJONERER rommet (verifisert: rektangel
  → 2× lik areal; gjentatt split → N soner uten hull/overlapp; sum sone-areal = romareal).
- Auto-navn «Sone N» (redigerbart via ctxbar). Render: indigo soner med navn + retningspil.

### Valg + ctxbar/info pr. sone
- `hitZone`/`selectZone` virker for 'sone' (hit-rekkefølge: strip→cable→zone, så strimler inni
  kan fortsatt velges). Ctxbar: navn-redigering, «+ Produkt», per-sone retning (↕/↔), slett,
  areal + effekt + dekning. Info-panel: «Utleggingssone», retning, areal, effekt, dekning.

### Folie pr. sone + PER-KANT margin (kjernen)
- «+ Produkt» på en sone ruter til `_fillSoneFoil`: fyller KUN sonen, i `zone.direction`,
  strimler tagges `zoneId`. Erstatter sonens eksisterende folie.
- **Per-kant margin** (`_zoneFillablePolygon` + `_offsetPolygonPerEdge`): hver sonekant
  klassifiseres — ligger på en romvegg (yttervegg) → veggmargin (`_effectiveMarginCm`); delt
  grense (delelinje) → halv folie-gap (`_effectiveGapCm/2`). Sone-polygonet insettes per kant,
  og fylles med margin 0 (ingen dobbel-inset). Verifisert eksakt: yttervegg inset 2,5 cm, delt
  grense 1,5 cm.
- Motor-utvidelse (bakoverkompatibelt): `computeClippedSegments(...,opts{marginCm,clipPoly})` og
  `_autoFillRoomOnce(...,marginCm)`. Vanlig rom-folie uendret (regresjonstestet: 94%/92%).

### Stats / sletting
- `_soneStats` (areal, effekt W, W/m², dekning %, strip-antall) vist i ctxbar + info-panel.
  Rom-total inkluderer sone-strimler (de har `roomId`) → sum pr. rom = sum soner.
- Slett sone fjerner også sonens folie.

### Resultat / begrensninger
- Rektangulære soner (hovedscenario): 600×400 → 4 soner à 6 m², vekslende retning, **91–92 %
  dekning**, perfekt partisjon.
- **Utsatt til runde 2:** (1) folie-dekning på UREGELMESSIGE soner (L/arm) er svak — den greedy
  `_autoFillRoomOnce` får ikke brede folier over arm-grenser (Vindfang Sone 2 ~43 %); (2) sone-
  navn kan få nummer-hull etter gjentatte splitter; (3) hindringer inne i en sone subtraheres
  ikke i sone-fyllet; (4) kabel/matte pr. sone; (5) PDF/materialliste pr. sone; (6) polyline-
  delelinjer; (7) sammenslåing/flytting av delelinjer.

---

## 2026-06-10 — Hindring: fri plassering + mykt vegg-snap (clampHindringToRoom omskrevet)

- **Symptom:** hindringer (f.eks. kjøkkenøy i Rom 6) kunne ikke plasseres fritt — de ble dratt mot
  en vegg «midt i rommet», som om det fantes forbudte soner. Reprodusert: en hindring midt i Rom 6
  (42-punkts, konkavt, langt fra alle vegger) ble flyttet **233 cm** for å snappe mot en vegg.
- **Rotårsak:** `clampHindringToRoom` (~19788) snappet flush ut fra signert avstand til veggens
  UENDELIGE LINJE og valgte veggen med STØRST avstand innenfor rekkevidde → falskt snap i
  komplekse/konkave rom. Containment og snap var sammenblandet i ett steg.
- **Fiks — to ATSKILTE steg:**
  1. **Containment (alltid):** ekte polygon-test — `ptInPoly` på hindringens hjørner + nærmeste
     punkt på rom-grensen; translerer hele hindringen minimalt inn kun når et hjørne faktisk er
     utenfor (itererer for flere brudd). Ikke per-vegg-linjeavstand.
  2. **Mykt vegg-snap (kun ≤5 cm fra segmentet):** krever tangentiell overlapp med vegg-SEGMENTET
     (hindringen ligger langs segmentet, ikke nær dens forlengede linje), velger FAKTISK NÆRMESTE
     vegg (minste avstand, ikke størst), og snapper flush kun når 0 < avstand < HINDRING_SNAP_CM
     (5 cm). Ellers fri plassering.
  - Ingen snap til andre hindringer/soner (kun `room.walls`). Grid-snap i `_dhDragging` og
    `_hwMoving`-kallerne uendret.
- **Verifisert (ekte Rom 6 + rektangel, numerisk + visuelt):** midt i rommet → 0 cm (var 233);
  3 cm fra vegg → snap flush; 8 cm fra vegg → fri; 200 cm utenfor → contained inn; rektangel
  3/8 cm → snap/fri. Skjermbilder: øy fritt mellom benkene + øy snappet flush mot vegg.

---

## 2026-06-10 — Varmekabel: auto-retning foretrekker den RENE retningen (boustrophedon-fyll)

Lett alternativ til en risikabel V6-vertikal-omskriving: i stedet for å pusse på den delte
V6-koblingsmotoren, lar vi auto-retning styre brukeren mot den rene retningen.

- **Bakgrunn:** på et utstikker-rom (L/T med horisontal arm, f.eks. Vindfang) finnes en ren
  enkelt-serpentin (boustrophedon, 0 koblinger) bare langs armen (horisontalt). Vertikalt finnes
  den ikke (stort `openLen`-hopp) → kun V6 med kobling. Eksplisitt vertikalt valg er brukerens
  rett, men AUTO bør lande på den rene retningen.
- **Fiks (cascade, boustrophedon-blokk i `_autoFillCableImpl`):** blant gyldige retninger spores nå
  `bFill` = beste som også FYLLER kabelen godt (≥90 %), og `bChosen = bFill || bBest` velges. Når
  en retning gir ren, godt-fyllende boustrophedon, vinner den framfor en underfyllende. Påvirker kun
  AUTO (uten eksplisitt valg) — `dirs` har da begge retninger; ved eksplisitt valg er `dirs` kun den
  ene, så brukerens valg overstyres aldri.
- **Verifisert (Vindfang):** AUTO → boustrophedon 'h', 0 koblinger, ren; eksplisitt 'h' → ren
  (uendret); eksplisitt 'v' → fortsatt v6 (valg respektert); rektangel AUTO → boustrophedon, ingen
  regresjon.

---

## 2026-06-10 — Varmekabel: L/T-rom horisontalt blir ren boustrophedon-serpentin + 5 cm perp-margin

Fortsettelse på Vindfang (Bloksbergveien/Hybel). To uavhengige fikser, begge verifisert på ekte
rom og målt numerisk + visuelt.

### Fiks 1 — boustrophedon `_solve`: robust CC-sveip i stedet for biseksjon
- **Symptom:** L/T-rom horisontalt ga en stygg V6-celle-layout: ett løp med tettere CC, kantete
  (ikke-buede) svinger, en Y-split der et koblings-bein lå 4,4 cm fra et løp (<5 cm), og en rar
  kantet strek før svingen. Rotårsak: V6 deler rommet i 3 bånd med polyline-**koblinger**.
- **Hvorfor V6 i det hele tatt ble valgt:** den rene motoren (boustrophedon) lager én
  sammenhengende serpentin med bue-svinger + jevn CC, men `_solve` brukte **biseksjon**, som antar
  at `_layout`-gyldighet er monoton i CC. På L/T er den **ikke-monoton** (gyldig ved 9 cm, null ved
  12 cm, gyldig ved 15 cm — celle-handoff `openLen`-sjekken). Biseksjonen spratt da til CC 39,9 cm
  → bare 15,6 m av 50 m → cascadens `fillOk`-terskel (≥90 %) falt til V6. (Dette var den samme
  «15,6 m»-underfyllingen fra tidligere økter — nå endelig forklart.)
- **Fiks:** erstattet biseksjonen med et grovt CC-sveip (0,25 cm steg) over hele området + lokal
  forfining rundt beste CC. Robust mot de ikke-monotone null-hullene; finner alltid den GYLDIGE
  layouten nærmest target-lengde.
- **Resultat (Vindfang H, InFloor 10T 500W 50 m):** boustrophedon vinner nå (var v6), CC jevn
  9,9 cm overalt, **0 koblinger** → alle U-svinger er halvsirkel-buer, ingen Y-split, ingen
  tett-løp, ingen kantet koblings-strek; 48,8 m, 87 %, min vegg-avstand 5,49 cm; start/slutt i
  hjørner. Bekreftet visuelt.
- **Begrensning:** vertikal retning på dette rommet finnes ikke som ren enkelt-serpentin (armen
  stikker ut horisontalt → stort `openLen`-hopp), så vertikal bruker fortsatt V6. Horisontal er
  den naturlige retningen for et slikt rom.

### Fiks 2 — `_generatePolygonClippedRuns`: perp-margin fra indre parallelle vegger
- **Symptom:** øverste streng i venstre arm lå 0,7 cm fra ytterveggen (brøt hard 5 cm).
- **Rotårsak:** funksjonen insettet kun løpenes ENDER (sweep-aksen). En INDRE step-vegg parallell
  med løpene (armens topp/bunn-kant, usynlig for det ytre posisjon-rutenettet) fikk ingen
  perp-margin. (Promptens `_fillCellSerpentine` var død V5-kode — ikke i live-stien.)
- **Fiks:** masker hvert løp med rom-klipp ved `pos ± margin` (rå klipp, ingen sweep-inset). Der
  rommet ikke strekker en full margin i perp på en side, ligger man <margin fra en parallell vegg
  → klipp bort. Tom-vakt for ytre ekstremer (allerede dekket av posisjon-rutenettet). Lik CC
  beholdt; litt mer udekket inntil veggen (OK).
- **Resultat:** global min vegg-avstand 0,7 → 5,03 cm (H) / 9,58 cm (V). Gjelder fortsatt V6-stier
  (vertikal/hindringer). Rektangler uendret (boustrophedon-stien urørt).

### Verifisering / ingen regresjon
- Rektangler (300×200/54 m, 250×200/29 m, 400×300/54 m): boustrophedon, jevn CC, lengde nær target.
- LOCKED-regler urørt (halvsirkel-U, lik-lengde innen serpentin, ingen Y-split, sweepMargin).

---

## 2026-06-10 — Varmekabel: V6 honorerer valgt RETNING (dirExplicit) — fikser «velger horisontalt, legger vertikalt»

Diagnostisert og fikset på ekte prosjekt **Bloksbergveien → etasje «Hybel» → rom «Vindfang»**
(T/L-rom: høy høyre-rektangel med horisontal arm til venstre, InFloor 10T 500W 50 m).

### Rotårsak
`generateCableV6` kjørte sitt interne auto-retningsvalg (`_quickTry('v')` vs `_quickTry('h')`,
~linje 9925) **ubetinget** og overstyrte den passerte retningen hver gang én retning dekket
>2 % mer. På Vindfang dekker vertikal litt mer, så et eksplisitt **horisontalt** valg ble
stille flippet tilbake til **vertikal** → «jeg velger horisontalt, men den legger vertikalt».
(Den gamle 15,6 m-underfyllingen var en annen sti — boustrophedon — som ikke lenger velges.)
`_autoFillNCables` respekterte allerede `dirExplicit`; V6 gjorde det ikke.

### Fiks
- I `generateCableV6`: ny `_dirLocked`-vakt rundt auto-retningsblokken. Retning låses (ingen
  auto-flip) når brukeren bevisst valgte den (`S.varmefolie.dirExplicit` + gyldig `h`/`v`)
  ELLER når en multi-kabel-sone tvinger orkestratorens retning (`room._forcedSpacingCm`).
  Ellers auto-velg ved best dekning som før.
- Bonus: `_forcedSpacingCm`-låsen gjør multi-kabel-soner retnings-konsistente (en sone kunne
  før stille rotere via V6s interne flip og bryte parallell-tiling).

### Verifisert (in-memory, autentisert fane, lagring nøytralisert)
- **Vindfang request 'h' → får 'h'** (v6, lik CC 8,8 cm, 50 m = produktlengde, **86 % dekning**
  vs vertikal 81 %, 2 ortogonale koblinger, start/slutt i ekte hjørner). Visuelt bekreftet:
  ren horisontal serpentin, ortogonal innhugging rundt innerhjørnet, ingen diagonal/Y-split.
- **Vindfang request 'v' → får 'v'** uendret (50 m, 81 %).
- **Multi-kabel** (rektangel, 2 soner): request 'h' → begge 'h'; request 'v' → begge 'v';
  lik CC + lik lengde i begge soner. Ingen regresjon.
- Auto-modus (dirExplicit=false): auto-flip beholdt uendret.
- LOCKED-regler urørt: halvsirkel-U, lik-lengde innen sone, ingen Y-split.

---

## 2026-06-09 — Varmekabel: retningsvelger reapply + L-diagonal + rektangel-hjørne

Tre sammenhengende kabel-forbedringer rundt retnings-/hjørnevalg. Commits: `bc0d773`,
`6dee009`, + denne (rektangel-hjørne). Verifisert in-memory i autentisert fane.

### Del A — retningsvelger re-kjører eksisterende/forhåndsvist kabel (`bc0d773`)
- Ny `_reapplyCableDirection` (nær `_cableFlipDirection`): når brukeren endrer retning/hjørne
  i pickeren, re-kjøres umiddelbart aktiv forhåndsvisning (`_cablePreviewPlace`), commitet
  enkelt-kabel (`autoFillCable`) eller multi-kabel-gruppe (`autoFillMultiCable`) i den nye
  retningen.
- Wiret inn i begge pickere (`_vfDirEvt`, `_vfPickEvt`) via en endrings-guard:
  re-kjør bare når `snap.dir`/`snap.corner` faktisk endret seg.
- `_cablePreviewMeta` utvidet med `familyName`, `categoryId`.

### Del B — fjernet vertikal L-diagonal (ortogonal kobling langs innerveggen) (`6dee009`)
- I `_v6ConnectCells` (live V6-cellekobling): når exit/entry ligger på forskjøvne sweep-nivåer
  rutes koblingen nå **ortogonalt** langs innerhjørnet i stedet for en diagonal snarvei.
  `_covers` finner cellen som spenner hele sweep-området; bias 0.7 mot dens grenseløp;
  `mk(bPerp, sweep)` bygger en 4-punkts ortogonal sti; obstacle-validert med fallback til
  rett `[exitPt, bestEntry]`. Bevart 50 m, ingen regresjon på horisontal (dx:0/dy:13),
  rektangel fortsatt boustrophedon (49,4 m).
- Samme fiks også speilet i den døde `_connectCellPathsV5` (uskadelig, ikke i live-cascade).

### Punkt (a) — rektangel-boustrophedon honorerer valgt starthjørne (denne commit)
- I `generateCableBoustrophedon` → `_layout()` (variant-utvelgelsen): når
  `S.varmefolie.dirExplicit && startCorner` er satt, **hard-filtreres** de fire traverserings-
  variantene (`perpAsc × startHigh`) til den som lander på valgt hjørne — i stedet for det
  gamle myke +0,5-tiebreaker-nudget. Tracker `bestForced` ved siden av `best`; bruker
  `bestForced` når det finnes, ellers trygg fallback til ufiltrerte beste.
- Auto-modus (ingen bevisst valg) helt uendret — motorens selvvalg beholdes.
- Bakgrunn: rektangler bruker boustrophedon, som internt selv-velger starthjørnet i
  `_layout`s 4-variant-søk. Tidligere talte picker-hjørnet bare som +0,5 og ble overdøvet av
  hjørne-landing-bonus (opptil 8/ende) → valgt hjørne ble ignorert på rektangel. Nå honoreres
  det. Samme `dirExplicit && userCorner`-mønster som V6-fiksen (`a2ee83e`).
- **Verifisert:** parser OK; alle 8 hjørne×retning-kombinasjoner gir nøyaktig valgt hjørne;
  overstyring bevist (motorens naturlige selvvalg `tl` → eksplisitt `tr` gir `tr`, `br` gir
  `br`); kabellengde stabil (~59,9 m), ingen LOCKED-regel berørt.

---

## 2026-06-08 — ØKT-OPPSUMMERING: snøsmelting fullført + matte-pakkemotor

Stor økt: fullførte utendørs snøsmelte-modulen (steg 1–8), konsoliderte produktvelgeren
(snø + innendørs deler nå én UI + én motor), og bygde en matte-pakkemotor for InSnow 300T.
Alt verifisert i preview-server `romtegner` (dev-login `?dev`) og **deployet via Vercel**.
Commits: `06b2acf`, `92d682c`, `57d74be`, `a80652b`, `81d79c4`, `48bdc93`, `6242729`,
`49f54aa`, `536947b`, `0c97e0b`, `7db1513`, `05d0efb`, `e36a335`.

### Snøsmelting-modul fullført (steg 1–8)
- **Ekte InSnow 300T-matter i DB** (`_ensureOutdoorMatProducts`): erstattet placeholder
  `CVA20001–20016` med 32 ekte faste-størrelse-matter (17× 230V `CVA106xx` + 15× 400V fra
  Cenika produktblad 05/2025), bredder 0,5/1,0 m, `mat_total_length_mm` → fast-lengde-modell.
- **`_moduleContext()`** — datadrevet modul-forskjell (wm2Default, ccMaxCm, roomWord,
  hindringTypes, hasScreed). `_roomWord`/`_roomTargetWm2`/maks-CC rutet gjennom det.
- **Effektbehov** (`SNOW_USAGE` 250/300/350 + `_snowUsageWm2` + bruksområde-velger).
- **Delt produktvelger (UPC):** snø ruter nå til `showUnifiedProductPanel` (samme som
  innendørs) via `openProduktMenu`/`showCablePlacePanel`/auto-åpning. UPC modul-bevisst
  (snø=kun utendørs InSnow, innendørs=ekskluder utendørs). Header «Bruksområde» (snø) vs
  «Romtype» (inne). Gammelt flytende snø-panel nøytralisert.
- **Multi-kabel via `_buildNCableZones`** (samme motor som innendørs; LOCKED-regler).
- **Spenningsfilter** rettet (6 steder buggy `name.startsWith` → trygt `product_family`-
  mønster); «InSnow 30T» drar ikke lenger inn 400V.
- **Bugfix:** `maxCCmm is not defined` krasjet info-panelet ved valg av snø-kabel; rettet +
  korrekt snø-maks-CC 300mm via modul-kontekst. Fjernet foreldet «Avretning»-input i snø.
- **Steg 8:** fjernet 465 linjer død gammel snø-sti (`_renderSnowSettingsPanel`,
  `showSnowProposals`, `_snow*`-forslag/preview). Beholdt `_updateSnowSettingsPanel` som shim.

### Produktvelger UX (begge moduler, delt)
- **Dokket panel** (`_dockRwp`): `#room-workflow-panel` ligger nå eksakt over venstre sidebar
  (position:fixed, følger sidebar-bredden) i stedet for oppå griddet → forhåndsvisning fri.
- **Chip/nedtrekk-hybrid:** Produkttype + Effekt-klasse + Spenning + Bruksområde som chips;
  Romtype beholdt som nedtrekk. Splittet familie-nedtrekket i klasse+spenning (`_familyKlasse`,
  `_upcState.klasse/voltage`, voltage-filter i resultatrenderne).
- **Matte-variant forhåndsviser areal:** klikk en variant → eksakt matte legges ut (byttbar),
  via `autoFillMatSerpentine(productId, {exact, keepPanel})`.

### Matte-pakkemotor (`_packSnowMats`) + 4 oppfølgingspunkter
- **Pakkemotor:** legger InSnow 300T-matter i LENGDERETNINGEN, kombinerer ende-til-ende
  per kolonne (k=floor(L/ℓ)), N kolonner på tvers med ~10cm gap + 15cm udekket kant, og
  fyller rest på tvers (rotert 90°). Hver fysiske matte = ett `S.mats`-objekt. Auto velger
  bredeste+lengste (færrest stk). Verifisert mot Cenika-fasit: Sone 1 (4,6×25, 1×20m) →
  5× 1×20m; Kenneths variant (kun 1×12m) → 8× 1×12m + 1× 0,5×8m.
- **Punkt 1 — watt-fix:** `_matRatedW` = produktets ratede effekt pr. fysisk matte (ikke
  laid geometri × num_runs). Brukt i `_computeRoomStats`, sidebar-tre, specRows, PDF-eksport,
  materialliste. Sone 1 = 30000W korrekt (var feilaktig per-løp).
- **Punkt 2 — Bruk/Avbryt:** snø-matter legges som preview (`room._matPreviewIds`); «Bruk»
  committer, «Avbryt» fjerner, bytte swapper. Speiler kabel-preview-flyten.
- **Punkt 3 — rekursiv rest:** rest fylles med flere tverr-bånd til leftover < 40cm. Sone 2
  (4,6×26,5) → 5× 1×20m + 1× 0,5×12m, full dekning.
- **Punkt 4 — fargekoding:** `MAT_COLORS` (8 farger) pr. fysisk matte i `drawMats`;
  materialliste med matchende fargeprikker. Enkeltmatte-rom uendret (`_matColor` → null).

Status: alt deployet. **Restpunkter/notater:** Sone 2-rest er forenklet (ett lengde-ish +
ett kryss-bånd, ~PDF men ikke byte-identisk Cenika-kombo); trapp-modulen + klimasone-tabell +
auto-spenning + styring/følere er utenfor scope (ikke startet).

---

## 2026-06-05 — ØKT-OPPSUMMERING: multi-kabel-motor (varmekabel)

Samlet arbeid på multi-kabel-utlegg denne økta (detaljer i oppføringene under). Commits:
`96dd460`, `825940d`, `0b06e87`, `6d006d9`, `e6906bd`, `4e51fa2`, `b08072d`, `f129876`.

- **Retning etter dekning** + picker-bias; **↻ Retning** snur hele gruppa.
- **Delt sone (hakk/døråpning) = ugyldig løsning** — auto velger den aldri, tvang nektes.
- **Full gavl-dekning** i vertikal modus (skew-kabler godtas, ikke lenger forkastet).
- **Lengde-klamp**: ingen kabel > produktlengde (trimmer sveip, aldri CC).
- **Tette half-CC-sømmer** mellom soner.
- **NØYAKTIG lik CC i alle soner** (felles CC → lik flateeffekt i hele rommet).
- **Manuelt valg «Like soner» / «Korridor»** for 2 kabler; samme motor/regler for alle 2+.

Status: alt deployet via Vercel. Restpunkt: ingen kjente. Merk testrom `__TESTGARD__` kan
ligge igjen i BIV6-prosjektet (slettes manuelt).

---

## 2026-06-05 — Multi-kabel: manuelt valg «Like soner» / «Korridor» (2+)

Brukerønske: ha BEGGE multi-kabel-layoutene med et manuelt valg. Tidligere brukte 2 kabler en
egen korridor-sti (felles startpunkt + lead-run) og 3+ en annen (like soner) — inkonsistent.

- **To moduser** via `autoFillMultiCable(roomId, productId, n, forcedDir, mode)`:
  - **`soner`** (standard) → den forente `_buildNCableZones`-motoren, håndterer nå **2+**
    (felles CC, like soner, split-ugyldig, retningskontroll, lengde-klamp, søm-pinning, skew).
  - **`korridor`** → lead-run-sti med felles startpunkt ved termostat. **Kun for 2 kabler**;
    3+ med korridor-forespørsel faller automatisk til soner.
- `S.varmekabel.multiCableMode = 'soner'` (standard, huskes pr. økt). Kablene tagges
  `multiCableMode`.
- **UI:** ny ctxbar-toggle «▦ Like soner» / «🚇 Korridor» ved siden av «↻ Retning», vises KUN
  for 2-kabel-grupper (skjult ved 3+). `_cableToggleMultiMode()` kjører gruppa på nytt i valgt
  modus. `_cableFlipDirection` bevarer nå modus.

Verifisert (Garderobe herrer): 2-soner → lik CC 19,81, ingen lead-run; 2-korridor → lik CC
19,81 + felles startpunkt + lead-run; 3-korridor → faller til soner (CC 13,21). Enkeltkabel
uendret. LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: NØYAKTIG lik CC i alle soner (lik flateeffekt)

Kenneths prioritering: lik CC i alle soner (lik W/m²) > eksakt veggmargin. CC spriket før
mellom sonene (14,2/11,7/13,2) fordi hver sone regnet sin EGEN CC, og vertex-snapping
ubalanserte arealene.

- **Én felles CC** regnes én gang i `_buildNCableZones`:
  `sharedCC = clamp(nettoTotal_m2 / (N·cable_length_m) · 100, minSp, maxSp)`, og settes som
  `tempRoom._forcedSpacingCm` på hver sone.
- **Motorene tvinges til felles CC:** `generateCableBoustrophedon._solve`, `generateCableSkew`
  og `generateCableV6` (inkl. V6 stage-7 lengde-opt hoppes over) bruker `_forcedSpacingCm` i
  stedet for å utlede CC fra delroms-arealet.
- **Like arealer:** droppet `_snapBoundsToVertices` for multi-kabel — like-areal-kuttet er nå
  styrende (lik areal → lik lengde → lik CC virker). Motorene takler uregelmessige delrom.
- **Resten absorberes i sveip-margin, aldri i CC:** `_trimCableToLength` trimmer sveip-
  utstrekningen (sving-til-vegg) ned til produktlengden; half-CC-pinning ved sømmene beholdes.

Verifisert (Garderobe herrer, vertikalt): alle tre kabler **CC 13,21 cm** (var
14,2/11,7/13,2), lengder 182,7/183/183 m (alle ≤ 183), ~128 W/m² ≈ måltall 129. Enkeltkabel
+ 2-kabel + rektangulære rom upåvirket. LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: godta skew-kabler (full gavl-dekning i vertikal modus)

Gavl-sona i vertikal modus ble underfylt (serpentin-fallback ~130 m av 183 m). Årsak:
`_buildNCableZones` sjekket kun `cable.runs.length`, men **skew-motoren lagrer banen i
`pathEls`, ikke `runs`** — så en gyldig skew-kabel ble forkastet og falt til serpentin.

- Ny `_cableHasGeom(cable)` = har `runs` ELLER `pathEls`. Brukt i alle tre stedene
  `_buildNCableZones` sjekket «har kabelen geometri» (fallback-trigger, sluttsjekk).
- Dekningsscoren bruker `cable.coverage` for skew-kabler (ingen runs å summere).
- Split-deteksjon/pin/trim hopper trygt over runs-løse skew-kabler.

Verifisert (Garderobe herrer, vertikalt): gavl-sona K1 = skew **181,6 m** (var serpentin
130 m), K2/K3 boustrophedon 182,3/183 m — alle ≤ 183 m, full gavl-dekning, fargekodet riktig.
LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: delt sone = ugyldig løsning (ikke bare straffet)

Etter brukerkrav: «hvis en sone blir delt i to, så må det bli et ugyldig løsning». Oppgraderte
split-håndteringen fra en myk score-straff til en HARD ugyldighet.

- `_buildNCableZones` måler nå split-andelen PER SONE (verste sone) og returnerer `invalid:true`
  når en sone har ≥30 % strenger brutt i ≥2 segmenter (en void/hakk deler sona fysisk).
- `_autoFillNCables` dropper alle ugyldige retninger. Finnes ingen gyldig retning → returnerer
  null (ingen fallback til en delt layout; auto-fyll kan da prøve færre/større kabler oppstrøms).
  Tvinger man en delt retning (↻ Retning), returneres null → knappen nekter med toast.

Verifisert (Garderobe herrer): auto → 'v', tvunget 'v' → 'v', tvunget 'h' → null (toppsona
deles av døråpningen). LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: retningskontroll + split-sone-straff

Bruker meldte at horisontale soner var uegnet der en døråpning/hakk fysisk DELER den øverste
sona i to (kabelen må bro over hakket), og at man ikke fikk valgt retning.

- **Split-sone-straff i `_buildNCableZones`-scoren.** Teller strenger som er brutt i ≥2
  segmenter (= en void/hakk deler sona). Auto-retningsvalget trekker fra `0.6 × split-andel`
  fra dekningsscoren → for et rom der et hakk deler det horisontale topp-båndet (mange
  splittede strenger) velger auto nå VERTIKALE soner i stedet. Verifisert på Garderobe herrer:
  'h' gir K1 med 20/31 splittede strenger (score 0,88→0,69), 'v' gir 0 splittede (0,86) → auto
  velger 'v'.
- **Tvunget retning:** `autoFillMultiCable(roomId, productId, n, forcedDir)` →
  `_autoFillNCables(..., forcedDir)` bygger kun den retningen (hopper over auto-valget).
- **`↻ Retning`-knappen** (`_cableFlipDirection`) håndterer nå multi-kabel-grupper: i stedet
  for å flippe én kabel kjøres HELE gruppa på nytt i motsatt retning (tvunget) og erstattes,
  så sonene re-orienteres samlet. Verifisert: v→h→v gir samme layout tilbake, ingen feil.

LOCKED kabelregler urørt; enkeltkabel + 2-kabel upåvirket.

---

## 2026-06-05 — Multi-kabel: lengde-klamp (≤ produktlengde) + V6-søm-pinning

Avdekket på det FAKTISKE rommet (Garderobe herrer, H7 gt5) at multi-kabel-utlegget hadde
to feil som det syntetiske testrommet ikke fanget: (1) K2/K3 krevde **186,6/186,5 m** av en
**183 m**-kabel — fysisk umulig; (2) gavl-sona (V6) sin søm-kant lå **22 cm** fra kuttet.

- **`_trimCableToLength(cable, targetCm)`** — ingen kabel kan kreve mer enn produktlengden.
  Ved overskudd (diskret strengantall bommer oppover) kortes strengene ved å trimme sweep-
  endene, fordelt PROPORSJONALT med hver strengs kapasitet (lange strenger gir mest, korte
  gavl/topp-strenger urørt → like-spenn-strenger trimmes likt, så celle-lik-lengde beholdes).
  Perp-posisjoner urørt → sømmene flytter seg ikke.
- **`_pinCableSeamToCut(...)`** — for motorer som ignorerer `_cableSeam` (V6/skew/serpentin på
  en uregelmessig yttersone): skyv ALLE strenger likt langs perp-aksen så søm-kanten havner
  halv-CC fra kuttet → én CC over sømmen. Kun yttersoner (én søm), klampet så veggsiden
  beholder ≥ margin.
- Begge kalles i `_buildNCableZones` etter at hver kabel er bygd (før push/dekningsmåling).

Verifisert: Garderobe herrer → K1 182,8 / K2 183 / K3 183 m (alle ≤ 183), sømmer 13/14 cm
(K1|K2 22→13), dekning 88 %. Rektangel → 179,4 m hver, sømmer 15/15, 96 %. Enkeltkabel +
2-kabel upåvirket (klamp/pin kjører kun i N≥3-stien). LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: tette sømmer (halv-CC delte vegger) + picker-retning

Etter Kenneths modell: 3 like soner, hver kabel legges normalt, men **veggen som deles
med nabosona er halv-CC** → full CC mellom siste streng i sone N og første streng i sone
N+1 (ingen kald stripe). Samme prinsipp som to-kabel-stien allerede bruker (`boundaryEdge`).

- **Seam-bevisst streng-plassering i `generateCableBoustrophedon`.** Nytt `room._cableSeam`
  `{min,max}` (settes kun på midlertidige delrom). En kant som deles med en nabokabel er
  IKKE vegg: ytterste streng pinnes eksakt halv-CC fra kuttet, og resten (slack) legges mot
  ekte vegg. **Kantsoner** (én søm) pinnes; **midtsona** (to sømmer) beholder liten
  veggmargin + sentrering — halv-CC-margin på begge sider der ville droppet en streng og
  blåst opp resten (løsere sømmer). Enkeltkabel uendret (`_cableSeam` udefinert → identisk
  sentrert layout).
- **`_buildNCableZones`** markerer hver delroms-kant som søm (`min: i>0`, `max: i<N-1`).
- **Retning følger picker:** `_autoFillNCables` biaser mot `S.varmefolie.direction`
  (retningsvelgeren) men prøver fortsatt begge og bytter kun ved klar deknings-gevinst
  (>2 %) — så et bevisst valg/uavgjort (rektangel) æres, mens default 'v' som ville latt en
  gavl stå udekket likevel flipper til 'h'.

Målt: GABLE-rommet K2|K3-søm **19 → 14 cm** (ideal 13), K1|K2 14 cm; RECT 15/15 (ideal
13,1) — ~1,5–2 cm over ideal (uunngåelig hårfin rest når sonebredde ≠ multiplum av CC ved
låst kabellengde). Dekning 93–96 %. LOCKED kabelregler urørt; enkeltkabel + 2-kabel uendret.

---

## 2026-06-05 — Multi-kabel: velg retning etter dekning (gavl/hakk-rom)

- **`_autoFillNCables` velger nå kjøreretning etter total dekning, ikke bare
  `_suggestDirection`.** Den gamle koden låste alltid dominansretningen. På et rom med
  skrå gavl (f.eks. Garderobe herrer, 72,5 m²) ga VERTIKALE kutt et helt udekket delrom
  (gavlen → motoren «skew» → 0 %, samlet 61 %), mens HORISONTALE topp/midt/bunn-bånd
  isolerer gavlen i ett bånd og tiler resten rent (80 % / 94 % / 97 % → samlet **93 %**).
  Refaktorert: ny `_buildNCableZones(room, productId, prod, n, dir)` bygger N like-areal
  delrom for ÉN retning og returnerer `{cables, score}` (areal-vektet dekningsgrad);
  `_autoFillNCables` kjører den for BEGGE retninger og beholder den beste (med liten
  hysterese mot dominansretningen så vi bare bytter ved klar gevinst). Beholder snapping
  til verteks, konsistent retning for alle delrom, serpentin-fallback og aldri-dropp.
  Verifisert på den eksakte Garderobe-geometrien: 61 % → 93 %, 3 kabler, alle 'h'.
  RESTPUNKT: tynne kalde sømmer mellom båndene (hvert bånd holder veggmargin mot kuttet);
  halv-CC-stramming ved sømmene gjenstår som egen oppgave. LOCKED kabelregler urørt;
  enkeltkabel + rektangulære rom uendret.

---

## 2026-06-05 — Multi-kabel: rene delrom uten udekket trekant

- **Rene delrom — snap kutt til verteks + konsistent retning + deknings-retry.**
  `_autoFillNCables` forbedret etter prompt-kabel-multi-rene-soner: (1) **Smartere
  kuttlinjer** — ny `_snapBoundsToVertices` snapper hvert like-areal-kutt til nærmeste
  rom-verteks-perp-koordinat innenfor toleranse, så hvert delrom blir mest mulig
  REKTANGULÆRT (isolerer hakk/skråvegg i ett delrom i stedet for å kutte tvers gjennom
  → fjerner den udekkede trekanten i midten). (2) **Konsistent retning** — kjøreretningen
  låses til rommets dominansretning for ALLE delrom via `S.varmefolie.direction` (forced
  dir), så `autoFillCable` ikke re-velger pr. delrom → alle strenger parallelle. (3)
  **Deknings-sjekk** — ny `_cableCoverageFrac`; hvis et delrom dekker <90 %, prøv alt-
  retning og behold den beste; serpentin-fallback hvis fortsatt tomt (aldri stille dropp).
  Verifisert: L-hakk/notch → 3 kabler, samme retning, ~96 % dekning, kutt snappet til
  notch-verteks; skråvegg-gavl → rene rektangler + isolert trapes-rest (uunngåelig pr.
  LOCKED lik-strenglengde). LOCKED kabelregler urørt; enkeltkabel + rektangulære rom
  uendret.

---

## 2026-06-04 — Varmekabel: manuelt valg i RIKTIG panel

- **`55d4a8c` — Manuell-seksjon + dekning% + preview lagt i det LIVE panelet.** Forrige
  runde la manuell-valget i `_updateCableSelection`, men panelet brukeren faktisk ser (RWP
  unified product picker) er `_upcRenderCableResults` (`#upc-results`) — derfor var det
  «borte». Nå i `_upcRenderCableResults`: «✋ Manuelt»-seksjon (type-dropdown + antall-
  stepper + Forhåndsvis) høyt (etter forslag, før «Flere kabler»), dekning% + effekt-merke
  på opsjonene, og preview-før-commit. Ny `_refreshCablePanel` oppdaterer riktig panel.

---

## 2026-06-04 — Varmekabel: synlig manuelt valg + fargekoding

- **`4f0e52f` — Manuell-seksjon flyttet opp + fargekod hver kabel.** (A) «✋ Manuelt — velg
  type + antall»-boksen flyttet OPP (rett etter «Nærmest», før den lange «Flere kabler»-
  lista) → synlig uten å scrolle. (B) Ny `INDOOR_CABLE_COLORS`-palett (6 distinkte) +
  `_cableStroke`/`_cableBaseColor`: hver kabel i en multi-gruppe får sin egen farge på
  serpentin/connections/lead-run/etikett, label K1/K2/K3… (ikke bare K1/K2). Fargelegende i
  romkortet (prikk + K# + produkt · lengde · effekt). Enkeltkabel uendret (oransje),
  LOCKED-regler urørt.

- **`85e9c8c` — Aldri dropp en kabel + fri manuell type/antall.** (1) `_autoFillNCables`
  droppet et delrom stille hvis den gode motoren ga ingen runs på en uregelmessig del
  (skrå gavl/hakk) → 3 valgt ble 2 tegnet, en del udekket. Nå: fallback til serpentin på
  sub-polygonet (`_engine='serpentine-fallback'`) → kabelen plasseres alltid; kun ekte
  slivere droppes (med `console.warn`). Verifisert: skrå-gavl → 3 kabler (2 boustrophedon +
  1 fallback), L/T → 3 boustrophedon. (2) Ny «Manuelt»-seksjon i kabel-velgeren: type-
  dropdown (alle familie-varianter) + antall-stepper (1–16) + «Forhåndsvis» → bygger
  N-delrom-layout + live preview (Bruk/Avbryt), valg huskes. Verifisert: antall=4 → 4 kabler.

- **`7f63800` — Multi-kabel deler rommet i N reelle DELROM og kjører én-kabel-motoren i
  hvert.** `_autoFillNCables` kjørte før den enkle serpentinen i et perp-BÅND av hele rom-
  polygonet → «rektangulært bånd»-problem på L/hakk (udekket). Nå klipper `_clipPolygonToSlab`
  rom-polygonet til hver like-areal slab → reelt sub-polygon, og `autoFillCable`
  (boustrophedon/V6, full dekning + hjørne-til-hjørne) kjøres på et midlertidig delrom og
  re-keyes til ekte rom. Hver kabel arver single-kabel-kvalitet; nabokabler møtes med ~én CC.
  Verifisert: L-form 74 m² → 3 delrom à likt areal, alle boustrophedon, 91% (= single-kvalitet,
  opp fra 88%). Manuell velger + forhåndsvisning (forrige økt) bruker nå denne motoren.

---

## 2026-06-04 — Varmekabel: færre/store, bedre layout, manuell velger

- **`6f8bf6f` — Punkt 3: manuelt valg + dekning% + live forhåndsvisning.** Kabel-velgeren
  (`_updateCableSelection`) lister nå forslag (1× stor + multi 3×/4×/…) med total W, W/m²,
  CC, dekning~% og effekt-merke (▼lav/●ok/▲høy). Klikk → live forhåndsvisning (ikke commit,
  som snø-modulen) + «✓ Bruk / ✕ Avbryt». Ingenting endelig før bekreftelse.
- **`10bd31c` — Punkt 2: deknings-drevet layout (like-AREAL bånd).** `_autoFillNCables`
  delte i like-BREDE bånd → dårlig tiling på uregelmessige rom. Ny `_equalAreaBandBounds`
  deler i N bånd med likt netto-areal → hver fast-lengde kabel fyller kant-til-kant.
  L-form 60 m²: 3 bånd à 20 m², 95% dekning (opp fra ~88%). Rektangel uendret.
- **`39adf4b` — Punkt 1: foretrekk færre/større kabler.** `selectMultiCables` rangerte på
  effekt-presisjon → en liten kabel slo færre store. Nå: færrest kabler innen ±12% effekt,
  største kabel. Katalogen har lange InFloor 17T (opp til 200m), så 72 m² @ 129 W/m² gir
  nå 3× 183m i stedet for 7× 79m. LOCKED kabelregler urørt.

---

## 2026-06-04 — Bakgrunn: alltid-synlig hurtigkontroll

- **`cb4a778` — Synlighets-/dimme-kontroll for bakgrunn tilbake på toppen.** Kontrollen
  lå kun i none-state-ctxbaren (kun når ingenting var valgt) → forsvant når et rom ble
  valgt. Ny `_bgCtxGroupHtml()` prepende i `updateCtxBar` for alle hvile-tilstander
  (skjult i transiente moduser + før kalibrering): Vis-toggle + dimme-slider + «…»-meny
  (målestokk/bytt/fjern), bundet til det aktive laget (synket med sidebar-lista). Fjernet
  none-state-duplikatet + død flytende `#bg-panel`-HTML. Rendering og prosjektdata urørt
  (trygg fiks — full S.bgs→bgLayers-migrering droppet pga. lav gevinst/høy risiko).

---

## 2026-06-04 — Varmekabel: ubegrenset antall kabler

- **`07032b0` — Store rom kan nå prosjekteres med så mange kabler som trengs.**
  `selectMultiCables` var hardkodet til maks 2× — nå effekt-drevet: N ≈ ønsket effekt /
  kabel-effekt, med gyldig CC. Ny `_autoFillNCables` splitter perp-aksen i N like bånd
  og legger én serpentin per bånd (indre bånd: ny `boundaryEdge='both'` → halv-CC mot
  begge nabokabler, uniform CC). Alle kabel-paneler viser «N×» og plasserer N.
  2-kabel-veien (delt start + lead-run) uendret; ny vei kun for N≥3. Tak 16 (praktisk
  ubegrenset). Verifisert ekte InSnow (64 m²): 200 W/m²→13 kabler, 300→16, 0 overlapp.

---

## 2026-06-04 — UX: seleksjons-drevet kontekst-handlingsmeny

- **`fe327c1` — Samme prinsipp overalt: klikk rad = velg/åpne, ✏️ = navn.** Utvidet
  rom-fiksen til etasje-headere (klikk → toggle, ✏️ omdøp), prosjektliste-rader på
  dashbordet (klikk → åpne prosjekt, ✏️ omdøp) og hindring-rader (fjernet villedende
  cursor:text, ✏️ lagt til). Alle eksisterende rename-handlere gjenbrukt; dobbeltklikk
  + høyreklikk «Gi nytt navn» beholdt.
- **`fefdabd` — Klikk hele rom-raden for å velge rommet.** Navne-spennet i sidebar
  hadde egen onclick som startet omdøping (med stopPropagation), så klikk på navnet
  valgte ikke rommet. Fjernet den → hele raden kaller `selRoom`. Omdøping flyttet til
  en tydelig ✏️-knapp (i tillegg til dobbeltklikk + høyreklikk «Gi nytt navn»).

- **`40f9e08` — Rydd opp i `#ctxbar` (rom-tilstand).** Rom-valgt viste ~12 knapper
  samtidig. Nå seleksjons-drevet: primær «+ Produkt» (fylt aksent) + 4 sekundære
  (+ Hindring, + Sone, Auto-soner, Mål); resten (Skillevegg, Fyll fra punkt, Sentrer,
  Folie-avstand, Tøm, Dokumentasjon, Rom-label, Målsett rom/folie/kabel, Slett rom)
  under én «⋯ Mer»-popover (`_showCtxMore`, gjenbruker `#produkt-menu` + `.ctx-item`).
  Ny `.snap-chip.primary`-stil, 44px-trykkflater beholdt, `#topbar` uendret. Alle
  onclick-handlere gjenbrukt — ingenting mistet, la til «Slett rom». None-state:
  «Rektangel» markert som primær.

---

## 2026-06-04 — Folie skråvegg-motor + onboarding/multi-org

Økt som ryddet folie-auto-fill-scoringen, bygde skråvegg-trapper, og forbedret
onboarding/brukeradministrasjon. Alle endringer verifisert på ekte FlexFoil-data i
preview-serveren (Chrome), og syntaks-sjekket før commit.

### Folie: skråvegg-dekning (ny `_slantStaircaseFill`-motor)

Bygd stegvis gjennom flere prompter. Sluttresultat: hver skråvegg får en ren
40/20cm-trapp som følger diagonalen, midtpartiet pakkes optimalt, ingen
overlapp/støv, og rette rom (rektangel/L/T) er garantert uendret.

- **`31fd9fc` — Pakk kjerne-båndet optimalt + jevne mellomrom.**
  Etter trapping dekomponeres det fullhøye kjerne-båndet (komplementet til
  slant-sonene) og pakkes med `_bestMixedWidthFit` (uttømmende søk → færrest
  strimler / beste breddekombinasjon) i stedet for grådig. Slakken fordeles jevnt
  mellom strimlene. Kun brede produkter (>40cm) i kjernen; båndet krympes forbi
  trappestrimler som strekker seg inn (ren overgang). Byttes kun når ikke verre
  (≤ antall strimler og ≥ dekning), validert mot trappene (ingen overlapp).

- **`045025a` — 40cm-trapp på BEGGE sider (slutt å beholde flatt kuttede brede strimler).**
  Ny `_stripCutRatio` (lengde / høyeste-kant-potensial). Brede strimler (>40cm)
  som diagonalen kutter < 85 % fjernes — også de som straddler sonegrensa — og
  sonen bygges om til ren trapp (regionen utvides til strimlenes fulle spenn).
  Brukervalg: ren trapp først, selv om en flat strimmel dekker marginalt mer m².

- **`0a4885d` — Fjern overlapp-advarsel, støv-strimler og glipper.**
  `_freeSweepRanges` erstatter `_subtractCoveredSweep` og håndhever leverandør
  perp-GAP (`_effectiveGapCmPair`) mot alle strimler → ingen ⚠. `_buildNarrowStaircase`
  dropper støv (< 30cm) og velger bredden som dekker mest (40cm i kroppen, fint
  20cm nær spissen, eksakt ett gap mellom trinn).

- **`6fda605` — 40/20cm-trapp på ALLE skråvegger (redesign).**
  Itererer per skråvegg-kant (slant-sone = kantens perp-span). Foretrekker ren
  full-høyde trapp der den dekker ≥ det den erstatter; ellers additiv så ingen
  sone står tom. Løste at bare én skråvegg fikk trapp.

- **`62e547f` — Skråvegg-dekning med trapp av smale FlexFoil-strimler (20/40cm).**
  Første versjon: additivt etter-pass `_slantStaircaseFill`, kun ved
  `_roomHasSlantedWall`. Hjelpere `_roomHasSlantedWall`, `_posNearSlant`,
  `_narrowEdgeFillProducts`.

### Folie: opprydding

- **`bcbb2ec` — Samle layout-scoring i én `_scoreFoilLayout` (P4).**
  Erstatter `_scoreLayout` + lokal score-closure i `_autoFillBothDirections` med
  én scorer med to dokumenterte vekt-profiler (select/zone). Aritmetikk bevist
  byte-identisk → ingen synlig endring.

### Onboarding & multi-org

- **`ff11db0` — Onboarding.** Samle pending-statuser til én komponent
  (`_AUTH_STATUS`), invitasjons-vei på login («📩 Har du en invitasjon?»),
  2-stegs registrering, org-admin rolle-endring + invitasjon på nytt.

- **`97e6d8b` — P7 multi-org.** Alle medlemskap i `_userMemberships`, aktiv-org i
  localStorage, org-bytter i avatar-meny (kun ved >1 org), plan-basert medlemstak
  (`_orgMemberLimit`).

### Kabel-motor (P1, tidligere i økten)

- **`4c86720` — Samle delt kabel-scoring i `_scoreCableCandidate`.**
- **`d1b0135` — Fjern død kabel-motor (V5/V4/length-driven).**

---

## Verifiseringsmetode

- **Syntaks:** ekstraher inline `<script>` → `node --check`.
- **Funksjonelt:** preview-server `romtegner` (port 4000) + Chrome MCP, testet på
  syntetiske rom (trapes, hus med 2 skråvegger, steep-trapes, kappet hjørne) og
  ekte FlexFoil 60W-produkter. Sjekket: dekning, overlapp (0), støv (ingen <30cm),
  no-op på rektangel/L/T.
- **LOCKED-regler** i CLAUDE.md (U-turns, sweep-margin, equal-length runs, ingen
  Y-splits) ikke berørt — dette gjelder kun folie, ikke varmekabel.
