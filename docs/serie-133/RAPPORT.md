# 133 — Vannrett matte: én koordinatkonvensjon (motor = klipp = tegning = treff = klamp)

## 133

Kjørt 23.–24.10.2026 på `main` fra `8e9607f` (132 committet, ikke pushet). **Ikke pushet.** Bakgrunn:
124-rapporten «Funn utenfor scope 1», serie-128 RAPPORT (128 Test 3, 130 «Funn», 131 «Auto-retning per
kapittel»), SPØRSMÅL 128-1 (a) og 130-4. Kenneth 24.10: «rett dette først.» Skjermbilder i
`skjermbilder/` (headless Chrome via CDP, harness i `/tmp/cdp133`, gammel kode servert fra port 4001).

**Resultat i én setning:** en vannrett matte (`rotation_deg = 90`) har nå ett koordinatsystem —
`x_cm/y_cm` er blokkas lave hjørne, bredder stables i +y, kabelen går i +x — brukt av motoren,
klippingen, vakten, tegningen, treffet, rødmerkingen, klampen, naboavstanden og PDF-en; lagrede
vannrette matter konverteres ved innlasting fra den tegnede posisjonen og tegnes pikselidentisk;
'h'-veien leverer det velgeren estimerer (rect #10: 10,0 m², var 8,0), 900 × 300 får 5 × 600 (var
4 synlige bredder i venstre halvdel), og ingen loddrett benkrad er endret.

## STEG 0 — målt før endring

### 0.1 De 48 leserne av `rotation_deg` (linjenummer før 133)

Konvensjon: **A** = `y_cm`/`x_cm` er blokkstart på tvers/langs (motorens), **B** = senter
`(x_cm + totalW/2, y_cm + L/2)` + rotasjon om senteret (tegningens, speiler langaksen for 90°),
**C** = ser bare på om rotasjonen er 0 (ignorerer 90°).

| Linje | Sted | Konv. | Leser/skriver | 133 |
|---|---|---|---|---|
| 4243 | `S.mats`-definisjonen (kommentar) | – | dok | konvensjonen skrevet inn |
| 13696, 13909 | `_matPlaceCandidate` (naboer kun 0°) | C | leser | uendret (0°-modell, dokumentert der) |
| 14492 | `_matRunOrder` («høy along = venstre») | B | leser | høy along = høyre (`firstHigh = !left`) |
| 14519 | `_matRunWorldGeom` senter + rotasjon | B | leser | leser `_matFrame` |
| 14521 | `_matRunWorldGeom` `alongStart = x_cm` | A | leser | uendret (i rammen) |
| 14669 | `_matRunDragDelta` rotasjonsmatrise | B | leser | rammens aksevektorer |
| 14699 | `_matRunStartBaseCm` | A | leser | uendret |
| 14763 | `_matCablePlan` `alongStartCm` (1D langs) | A | leser | uendret |
| 14846, 14874 | `_matRunsWithinRoom` `perpBase = y_cm` | A | leser | uendret |
| 15540 | `_matPlaceMultiMats` skriver `rotation_deg` | A | skriver | + `matCoordV: 2` |
| 16596–16597 | `_matChapterRegressionTest` fiksturer (0°) | C | test | uendret |
| 17408, 17423 | `_matRelayWithGap` (127) | A | leser/skriver | uendret |
| 17807 | `autoFillMatSerpentine` kommentar «swaps them» | B | dok | ny kommentar |
| 17810–17812 | `autoFillMatSerpentine` `matX = alongCenter − totalW/2`, `matY = acrossCenter − L/2` | **B-senter + A-klipp** | skriver | `matX = alongCenter − L/2`, `matY = acrossCenter − totalW/2` |
| 17938 | `autoFillMatSerpentine` skriver `rotation_deg` | A | skriver | + `matCoordV: 2` |
| 19802, 20480 | testfiksturer (0°) | C | test | uendret |
| 19940 | `_matArrangementRegressionTest` vannrett fikstur («motor-konvensjon») | A | test | uendret, grønn |
| 20279, 20281 | flyttetest-fiksturer (`runStarts` absolutt) | A | test | uendret, grønn |
| 41038 | `_upcPlaceMat`-commit (0°) | C | skriver | uendret |
| 42772 | `drawMats` `ctx.rotate(rad)` om senter | B | leser | `_matFrame`: 90° = `ctx.transform(0,1,1,0)` |
| 42807 | `drawMats` `alongStartCm` | A | leser | uendret |
| 46082 | `_matRotate90` | rotasjon | skriver | `_matSetRotationDeg` (senteret står) |
| 46125, 46149, 46166, 46256 | `_matCenterGroupInRoom`/`_matManualGroupX` (akse `y_cm` for 90°) | A | leser/skriver | uendret |
| 47310 | smale matter i kile (trapp) | A | skriver | + `matCoordV: 2` |
| 53589–53597 | `_drawMatDimChainForRoom` (`cy + localCx`) | B | leser | senter fra `_matFrame` |
| 59456, 59538 | 108-flytting (`runStarts` + dx for 90°) | A | skriver | uendret |
| 63156 | objektinfo «Liggende/Stående» | – | leser | uendret |
| 66209 | manuell plassering commit (0°) | C | skriver | + `matCoordV: 2` |
| 66308 | rotasjonshåndtak, pivot `x + width/2` | B (én bredde) | leser | `_matCenter(mat)` |
| 67000 | fritt rotasjonshåndtak skriver vinkel | rotasjon | skriver | `_matSetRotationDeg` |
| 67122 | matte-drag magnet (kun 0°) | C | leser | uendret |
| 68597 | piltaster («høy = venstre» for 90°) | B | leser | `dStart = high ? −dx : dx` |
| 69590, 69654 | ctxbar (visning, gruppe-chip) | – / A | leser | uendret |
| 78008 | `_renderRoomToImageOffscreen` (rotasjon om `x + width/2`, én bredde) | B | leser | **død kode** (0 kallere), ikke rørt |
| 91289, 91314 | `getMatViolations` (kun 0°) | C | leser | uendret |

**Hvor de to konvensjonene oppsto** (`git blame`):
- **B (tegningen):** `8222438` 11.03.2026 «Fase 4: Varmematte-modul — plassering, rendering, drag/rotate» —
  matta var én rektangel tegnet med `translate(senter) + rotate`. `_matRunWorldGeom` (`e3b5904`, 124,
  23.10.2026) kopierte samme transform for treff/rødmerking.
- **A (motoren):** `72f9267` 18.08.2026 13:44 «flere matter i samme rom» skrev `matX = alongCenter − L/2`
  for 'h' (A) og klippet med `perpBase = matY`. Samme dag, `b85c30a` 15:58 «Regel H — aldri overskudd»,
  fikk `autoFillMatSerpentine` sin egen 'h'-gren `matX = alongCenter − totalW/2`, `matY = acrossCenter −
  L/2` — blokksenteret stemte med tegningen (B), men klippingen rett under leste `perpBase = matY` (A).
  Der ble spriket født: i et rektangel ser det riktig ut, men klippingen skjer `L/2 − totalW/2` unna.
- Flermatte-mattene (A) ble derfor **tegnet** utenfor rommet (skjermbilde 133-04), mens enkelt-matte
  (B-senter) ble tegnet riktig, men **klippet** feil.

### 0.2 De tre tilfellene, før (fra `8e9607f`)

Produkt EcoMat 100T 9 m² som inngang (motoren bytter variant), mellomrom 1 cm, hjørne nede-venstre.

| Tilfelle | `x_cm`/`y_cm` | Bredder (motorens `perpPos`, `runStart+len`) | Tegnet (`_matRunWorldGeom`) | Dekning |
|---|---|---|---|---|
| **900 × 300 'h'** | 103,5 / **−78**, 22 m, L 456 | r0 perp −78…−28 → **0 cm**; r1–r3 456; r4 @199,5 + 360 | r1–r4 x 2,5–458,5, y 74–277 (venstre halvdel av rommet) | 8,64 m² |
| 300 × 900 'v' (speil) | 23 / 297,5, 30 m, L 600 | 5 × 600, ingen klipp | x 23–277, y 297,5–897,5 | **15,0 m²** |
| **rect #10 420 × 259** (benk, 150T 14 m²) | 36,5 / **−30,5**, 16 m, L 320 | r0 perp −30,5…19,5 (delvis utenfor) | x 3–323, y 3–256 (inne) | **8,0 m²**; estimat 'h' 10,0, 'v' 9,6; 'v' leverer 8,96 |
| Bilde 1 (300×400 + alkove) auto | 131-kapittel 'h' 7 × 288 | kapitlene leser `_matRunWorldRects` (tegnet) | x 6–294, y 22–378 — inne | 13,0 m² |
| T (600×200 + stamme 200×300) auto | stamme 'h' 5 × 192 | som over | inne, stammen 9,6 m | 15,0 m² |

Bilde 1-hoveddelen og T-stammen er etter 131 bygget på `_matRunWorldRects` (den tegnede geometrien),
så «x fra −12,5» og «0 cm lagt» fra 130-rapporten er allerede maskert av 131 — motoren klippet fortsatt
med `alongStart = −28` for en matte tegnet fra x = 6. Mekanismen i rect #10: Regel H-løkka startet med
20 m (L 400, `matY = 129,5 − 200 = −70,5`), r0 og r1 lå utenfor og ble klippet til 0 → nedgradert til
16 m, der r0 (−30,5…19,5) bare delvis stakk ut og slapp gjennom (`_matClippedSegments` klipper kun
langs).

### 0.3 Mattebenk før: `_matBench(42, 64)` → `/tmp/cdp133/bench-before.json` (224 rader, 195 lovlige,
35 Regel H-feilmeldinger i konsollen).

## Gjort

1. **Én konvensjon** (kommentar ved `S.mats`): `x_cm/y_cm` = blokkas lave hjørne for både 0° og 90°;
   bredder stables i +tvers (x for 0°, y for 90°), kabelen går i +langs (y / x), `runStarts` er
   absolutte langs-koordinater. 90° er en **transponering** av 0°-blokka, ikke en rotasjon — det er
   motorens A, som krevde færrest endringer (motor-klipp, vakt, 127, 108, gruppering og kabelplan var
   allerede A; bare tegningen, treffet, piltastene, målkjeden, rotasjonsknappen og klampen var B).
   Fri vinkel (håndtaket, 45°-trinn) er fortsatt rotasjon om senteret, bit-identisk.
2. **Én hjelper:** `_matFrame(mat)` gir senter, aksevektorer og `toW(lx, ly)`; `_matRunWorldGeom`,
   `drawMats` (`ctx.transform(0,1,1,0)` for 90°), label-boksen, `_matRunDragDelta`,
   `_drawMatDimChainForRoom`, `_matCenter`, `_getMatGizmoPos`/`drawMatMoveGizmo`, rotasjonspivoten og
   `_clampMatToRoom` leser den. Treff, rødmerking, 130-naboer, 131-kapitler, 127 og PDF gikk allerede via
   `_matRunWorldGeom`/`_matRunWorldRects` og følger med.
3. **Skrivere:** `autoFillMatSerpentine` 'h' skriver `matX = alongCenter − L/2`, `matY = acrossCenter −
   totalW/2`; `_matPlaceMultiMats`, kile-matter, manuell plassering og motoren stempler `matCoordV: 2`.
   `_matRunOrder`: høy along-ende for 90° = høyre; piltaster og S-håndtak følger. `_matSetRotationDeg`
   holder senteret når en matte går inn i/ut av 90° (knappen og håndtaket), og flytter `runStarts` med.
4. **Migrering:** `_matMigrateCoordV2` i `_restoreProject` — gamle 90°-matter uten `matCoordV` får
   `x' = x + totalW/2 − L/2`, `y' = y + L/2 − totalW/2`, speilede `runStarts` (materialisert sammen med
   `runLengths` når kort siste/klipp finnes, siden paritetsregelen ellers legger den korte bredden i feil
   ende), `startCorner: 'tl'` når feltet mangler (gammel standard: start til venstre). `runAdjust`
   beholdes — startenden i verden er den samme. Loddrette og fritt roterte matter får bare feltet.
5. **Estimat = levering:** rect #10 'h' leverer 10,0 m² = `_matAreaGeom` sitt estimat (avvik 0 %).

## De tre tilfellene, etter

| Tilfelle | `x_cm`/`y_cm` | Bredder | Tegnet | Dekning |
|---|---|---|---|---|
| **900 × 300 'h'** | 2,5 / 23, **30 m**, L 600 | 5 × 600 @2,5, perp 23/74/125/176/227 | r x 2,5–602,5, y = perp…perp+50 — identisk med klippet | **15,0 m²** (= speilet 'v') |
| 300 × 900 'v' | 23 / 297,5 (uendret) | 5 × 600 | uendret | 15,0 m² |
| **rect #10** auto → 'h' | 3 / 3, **20 m**, L 400 | 5 × 400 | x 3–403, y 3–256 | **10,0 m²** = estimat; 'v' 8,96 uendret → 'h' er faktisk bedre |
| Bilde 1 / T auto | som før (131) | ingen bredde utenfor, stamme 9,6 m | | 13,0 / 15,0 m² |

900 × 300 med **auto**-retning velger fortsatt 'v' (estimat 24,5 mot 22,2 m²) og leverer 12,0 m²
(24 m, 10 × 240) der 'h' leverer 15,0 — det er Regel E-avviket mellom estimat og levering i 'v'-veien
(SPØRSMÅL 128-1 (b)), ikke koordinatsaken. Ikke bygget her, se SPØRSMÅL 133-1.

## Migrering — to gamle prosjekter

Laget med **gammel kode** (`8e9607f`, `_buildSaveData()` → `/tmp/cdp133/old-A.json`, `old-B.json`):

- **A:** 900 × 300 'h' auto (bredde 0 klippet til 0, `y = −78`), 300 × 900 'v', manuell 'h' med kort
  siste + `runAdjust` + hjørne `br`, legacy 'h' uten `startCorner` med klipp, og en 'v'-matte rotert
  90/180/270 med knappen. 7 matter.
- **B:** 2104 (1000 × 263) flermatte 'h' (2 × 12 m — tegnet **utenfor** rommet, skjermbilde 133-04),
  700 × 250 'h', 1105 (567 × 242) 'h'. 4 matter.

Begge lastet via `_restoreProject` på gammel (port 4001) og ny kode (4000), samme vei:
`_matRunWorldGeom` per bredde (boks, start, slutt, lengde, rødmerking), lagt lengde, kabelrekkefølge og
senter: **0 avvik** på 11 matter. `canvas.toDataURL()` per rom i vanlig modus **og** `_pdfMode`
(drawMats er PDF-ens tegner): **identisk hash** for alle 7 rom. Kabelstrengene ligger på samme
verdensposisjoner (gammel plan ga dem i speilet lokal langs-koordinat, konvertert i målingen). Gizmoen
flytter seg for 90° (var `y + L`, nå `y + totalW` — den sto under en vannrett matte før). Hele-side-
PNG-ene (133-05/06) avviker byte-vis bare i statuslinja; lerretet er likt.

## Mattebenk før/etter (`_matBench(42, 64)`, `bench-before.json` / `bench-after.json`)

| | Før | Etter |
|---|---|---|
| Rader | 224 | 224 |
| Uendret | | 189 |
| Opp | | **29** (alle 'h') |
| Ned | | 6 (alle vei 3 InSnow, alle 'h') |
| Lovlige | 195 | 195 |
| Vei 1/2 ulovlige | 0 | 0 |
| Vei 4 ulovlige | 29 | 29 |
| Snitt dekning vei 1/2 | 74,3 % | 77,7 % |
| Snitt dekning vei 3 | 48,7 % | 51,8 % |
| Regel H «forsøkstaket» i konsollen | 35 | 12 |

**Ingen rad uten vannrett matte endret seg** (kontrollert rad for rad på gammel og ny kode:
`/tmp/cdp133/benchdetail.json`). Utvalg: rect #10 8,0 → 10,0 m² · 2104 6,4 → 24,0 · rect #15 3,84 → 8,0 ·
2102 12,0 → 12,96 · grense-kapasitet #52–55 (InSnow) 12,8 → 26,0 · stor #41/#42 28 → 30.

**De 6 lavere** (T #21 8,24 → 8,16, U #22 13,6 → 12,32, hindring #24 6,0 → 3,84, #26 6,0 → 3,2,
#28 4,96 → 3,28, #29 10,88 → 7,92): alle hadde før **4–10 bredder tegnet utenfor rommet** (og #26/#29
over hindringen) — dekningen var talt på nett som lå i veggen. Etter: 0 utenfor, 0 over hindring.
Det er sannheten som har tatt igjen tallet, ikke en regresjon.

**Vei 4 (syntetisk frihånd):** 29 → 29 ulovlige, ikke ned. Årsaken ligger i benkens egen syntetiske
bane, ikke i `S.mats`: `_matBenchRunVei4` starter i hjørnet nede-venstre og legger alle 'h'-bredder
med `side: 1` (nedover, +y) — banen går rett ut gjennom gulvveggen. For 'v' ble det samme rettet med
`dir0 = −1`. Frihånd var utenfor scope («Skal IKKE»), så benk-banen er ikke rørt. Se SPØRSMÅL 133-2.

## Tester

| Test | Resultat |
|---|---|
| **`_matRotationRegressionTest`** (ny) | **35/35**: 900 × 300 'h' (5 bredder, tegnet = klipp, treff, 124-justering, klamp, senter/gizmo), speilet 'v' bit-identisk, rect #10 (10,0 = estimat, 'v' 8,96), bilde 1 + T (ingen utenfor, stamme > 0), migrering av 6 fiksturer (klippet/kort siste/`runAdjust`/uten `startCorner`/flermatte/'v'/180°) med vaksine og idempotens, ↻ 90° (senter, 4 × 90° tilbake), rødmerking |
| Vaksine: gammel formel lagt tilbake i `_matRunWorldGeom` i siden | **9/35 røde** (tegnet ≠ klipp, treff, migrering ×4, ↻ 90°) |
| `_matRegressionTest` | 2/2 |
| `_matZoneRegressionTest` | 17/17 |
| `_matFreeRegressionTest` | 26/26 |
| `_matPathClickRegressionTest` | 28/28 |
| `_matRunAdjustRegressionTest` | 70/70 |
| `_matArrangementRegressionTest` | 55/55 |
| `_matChapterRegressionTest` | 14/14 |
| `_matCrossFillRegressionTest` | 23/23 |
| `_pdfExportSmokeTest` | 20/20 |

Interaksjon på 900 × 300 'h' (CDP, ekte mus/tastatur): 127 «Mellomrom i denne matta» 1 → 4 cm (anker
står, 0 droppet, tegnet y0 = `y_cm + r·54`, inne) · 108/127 flytt hele arrangementet (30, 10): alle bokser
flytter, `runStarts` følger, tilbake eksakt · 124 musedrag av bredde 3 nedover 3 cm → +5 cm (tegnet +5
i y) · S-håndtak 20 cm innover → «start +20 cm», 580 cm · ArrowDown → +5 · ↻ 90°-knappen fire ganger:
senteret (300, 453,5) står, feltene tilbake. Skjermbilde 133-03.

## Skjermbilder

- `133-01-900x300-h-foer.png` — 4 synlige bredder i venstre halvdel, 8,6 m², panel «siste bredde 80 cm kortere».
- `133-02-900x300-h-etter.png` — 5 × 600, 15,0 m², matta inne i rommet, gizmo nede-venstre av blokka.
- `133-03-900x300-h-justert-bredde.png` — bredde 3 valgt: «580 cm · forskjøvet +10 cm · start +20 cm».
- `133-04-gammelt-prosjekt-B-flermatte-h-foer.png` — gammel kode: 2104 sine to 12 m-matter tegnet under/utenfor rommet.
- `133-05`/`133-06` — prosjekt B lastet på gammel og ny kode (migrert): lerretet er hash-identisk.
- `133-07` — prosjekt A migrert. `133-08` — ↻ 90° på en 'v'-matte: snur på stedet.

## Funn utenfor scope (ikke rettet)

- **`_renderRoomToImageOffscreen`** (≈ :78000) tegner matta som én bredde rotert om `x + width/2` —
  død kode (ingen kallere). Bør slettes i en opprydding.
- **Enkelt-matte-drag flytter ikke `runStarts`** (mousemove ≈ :67110 skriver bare `x_cm/y_cm`).
  Tegningen er relativ til blokkstarten, så bildet følger med, men `_matRunsWithinRoom`/`_matRelayWithGap`
  leser absolutte `runStarts` og ser matta der den var. 108-flytting og 127-arrangement gjør det riktig
  (`_ROOM_TRANSLATE_SPEC`). Gjelder 'v' like mye som 'h', fantes før 133.
- **Forbandt-produkter (InSnow, `mat_stagger_half_cc`) på migrerte 'h'-matter:** halv-CC-forskyvningen
  på odde bredder ankres nå fra venstre ende i stedet for høyre — strengene i de odde breddene ligger
  speilet innad i bredden (nettet er identisk). EcoMat (ingen forskyvning) er pikselidentisk.
- **900 × 300 auto velger 'v'** på et estimat 'v' ikke leverer (Regel E) — SPØRSMÅL 128-1 (b).
- **Vei 4 'h' i benken** er ulovlig av benkens egen bane (side nedover) — se over.

Commit: «133: vannrett matte — én koordinatkonvensjon (motor = klipp = tegning = treff = klamp via
_matRunWorldGeom), migrering av lagrede matter, estimat = levering; regresjonstest». **Ikke pushet.**

## 134

**Matte — Kenneths svar på serie-128 (motor).** Kjørt 24.10.2026 på `main` fra `75bb622` (133). **Ikke
pushet.** Svarene er skrevet inn under hvert spørsmål i `docs/serie-128/SPØRSMÅL.md` («**Svar (Kenneth
24.10):**»). Skjermbilder i `skjermbilder/134-*` (headless Chrome via CDP, harness i `/tmp/cdp134`;
gammel kode (`75bb622`) servert fra port 4002 for «før»-bildene).

**Resultat i én setning:** en sone klemt mellom to matter sentreres (A), rullvalget hopper over planer som
ender i en stubb og viser den større som alternativ (B), senere kapitler starter i velgerens ende (C), et
rektangulært rom med kvalifisert restfelt får tverrstykker via kapittelbanen (D), en sone som Regel 27-
vakten avviser prøves i den andre retningen (E) — og hindring #30, som var bestillingen bak E, viste seg å
være en snapp-feil i `_matZoneFreeRoom` (boksen ble aldri trukket inn til nabomatta + mellomrom), rettet
i samme økt: 84,0 → 94,5 % dekning.

### STEG 0 — målt før endring (fila fra `75bb622`, port 4000)

1. **B — hvor rullen velges, og hvordan stubben ser ut.** `_matPlanZones` → `_matChapterRollPlans(Σ, prod)`:
   «blandet» = `_matFreeSplitPlan` (K klatrer til resten er under korteste rull; så størst sum, så minst
   spredning), «like» = samme K, største lengde som går opp K ganger. Bare Σ gikk inn — banen var ukjent for
   rullvalget. Stubben er bare synlig etter `_matChapterPieces` (`_matFreeSliceMoves` skjærer banen ved
   rullens lengde): T-rommet (600×200 + stamme 200×300, 100T, velger nede-venstre): Σ 29,76 m, stammen
   først (3 × 288), så 11 × 192 → 28 m-biten slutter 16 cm inn i bredde 14 (`u/v-16`, under 24-rasteret).
   Variant A (132): 26 m-biten slutter 8 cm inn i tverrstykke 2 (`u/h-8X`, under 2 × CC = 24). Benk (150T,
   auto): Kenneth L-rom 26 m → 8 cm i en vanlig bredde (raster 16), hindring #27 26 m → 8 cm i et
   tverrstykke, L #23 14 m → 8 cm tverr, hindring #26 18 m → 8 cm tverr, hindring #25 10 m → 24 cm inn i
   et 32 cm-stykke (≥ 16, lov), T #20 2 × 32 m → 176 cm (lov).
2. **C — startende for kapittel 2+.** `_matChapterRunOrder(ch, prevEnd)`: for `prevEnd` satt prøves begge
   ytterbredder × begge ender, kortest avstand til forrige slutt vinner. Bilde 2, velger nede-venstre:
   bredde 5 slutter øverst (252, 8) → bredde 6 startet øverst (303, 3), hopp (51, −5) ≈ 51 cm. Å følge
   velgeren koster løs kabel: bredde 6 nederst (303, 195), hopp (51, 187) ≈ **194 cm** (Kenneths «200 cm»).
   Velger øverst-venstre: bredde 5 slutter nederst (252, 392) → bredde 6 øverst (303, 3), hopp ≈ 392 cm.
3. **D — rektangel med slakk i dag.** 300×400, 100T, «fra vegg» nede-venstre: `_matPlanZones` null (én sone)
   → `S.mats`-veien: 18 m, 5 × 360 på x 2,5–256,5, y 37,5–397,5, 9,0 m²; slakken x 256,5–300 = **43,5 cm**
   (≥ 37) står udekket. Simulert kapittel på samme rektangel: 5 × 384 + restfelt 43,5 × 400 → 7 × 24 cm
   tverr (x 264,5–288,5), Σ 20,88 m. Veien som ble valgt: hele rommet over til kapittelbanen når det finnes
   et kvalifisert felt (null ellers, så `S.mats`-veien står bit-identisk) — ikke `S.mats` + et tverrkapittel,
   fordi rullen velges av hele Σ (Regel 22 pkt. 2-mønsteret) og alle leserne alt finnes for banen.
4. **E — hindring #30.** 378×518, hindring 10–59 × 10–58 (klaring vegg), 150T, auto: sone 1 (y 60–516)
   vannrett 9 × 368 fra y 60 (sonegrensen, 0 margin, mellomrom kappet til 0,375); sone 2 (x 60–378 × y 0–60)
   velger selv 'h' (loddrett gir langs 57 < 100). `_matZoneFreeRoom`: y1-kanten (sonegrense) stoppes av
   matta i første stripe, men snappen godtok bare kanter *utenfor* boksen (`edge ≥ cur`) — matta lå kant i
   kant på y 60, så boksen beholdt y 60, kapitlet ble ankret 'hi' på y 10–60 og overlappet → `warn` og
   utelatt. «Prøv den andre retningen» gir der **ingenting** ('v' er for kort) — det som manglet var snapp
   innover. Begge er gjort (E som bestilt, snappen som årsaken).

### Gjort (alt i `index.html`)

- **A · Sentrering.** `_matZoneAnchorSide`: begge sider matte → `'mid'` (var lav side). Lest i
  `_matChapterBlock` (tvers og langs), `_matCrossFieldChapter` (stykkets ender og stablingen),
  `_matPlaceMultiMats` og `autoFillMatSerpentine` (de gamle `S.mats`-veiene, for konsistens). H-rom
  (stolper 200×800 + bro 300×200 mellom, 100T): broa 6 bredder x **197,5–502,5** — 19 cm til hver
  nabomatte (var 178,5–483,5: 0 / 38). Skjermbilde `134-A-hrom-*`.
- **B · Rullvalg uten stubb.** Ny `_matChapterStubAt(runs, coverCm, prod)`: hvor planens sum lander i banen;
  lagt del av den bredden < kuttraster (Regel 24) eller < max(2 × CC, raster) i et tverrstykke (Regel 29
  pkt. 2) = stubb. `_matChapterRollPlans(Σ, prod, path)`: like → neste lengde ned ved samme K; blandet →
  `_matChapterBestAtKFree` (alle kombinasjoner ved samme K, størst sum så minst spredning, memoisert per sum).
  Den større planen beholdes som `equalAlt`/`mixedAlt` (+ `…AltStub`); finnes ingen stubbfri ved samme K,
  står den største med `equalStub`/`mixedStub`. Uten `path` er alt som før (testene for 50,0 m / 1,5 m uendret).
  Panelet: den valgte raden sier «unngår stubb på 16 cm (Regel 24)» / «… 8 cm inne i et tverrstykke (Regel
  29 pkt. 2)», den større vises som «(største som får plass) … ender i en stubb på X cm» og kan velges
  (`equalAlt`/`unequalAlt` → `_matChapterCommit` med den planen; `_multiMatPref` husker bare like/blandet).
- **C · Startende følger velgeren.** `_matChapterRunOrder`: `startHigh` = velgerens ende per akse ('v':
  nederst for «b…», 'h': venstre for «…l») for alle kapitler; senere kapitler velger bare hvilken ytterbredde
  som er først (nærmest forrige kapittel, 2D-avstand til breddens midtpunkt). Gjelder også tverrkapitler.
- **D · Regel 29 i rektangulære rom.** `_matPlanZones`: én sone er ikke lenger `null` med én gang —
  kapittelet planlegges, `_matCrossFillChapters` kjøres, og **uten** tverrkapittel returneres `null` (S.mats-
  veien, bit-identisk: benkens 106 rektangulære rader uendret). Med tverrkapittel: `zonePlan.single = true`,
  panelet heter «Én matte med tverrstykker i restfeltet», toasten «lagt ut med tverrstykker i restfeltet».
  Toasten teller nå bredder som faktisk ble lagt (bitenes moves), ikke planens.
- **E · Utelatt sone i andre retning.** `_matChapterBlock(room, rect, prod, priorMats, opts)`: `opts.dir`
  tvinger retningen, `opts.fail = { reason: 'size' | 'overlap', dir }` ved null; kapitlet får `otherDir`.
  `_matPlanZones`: fail `overlap` → nytt forsøk med den andre retningen (vakten like streng), varsler
  «prøver den andre retningen» / «også i retning X — sonen utelatt». Panelet: «lagt i den andre retningen —
  i hovedretningen ville kapitlet overlappet en nabomatte (Regel 27)».
- **Snapp innover (`_matZoneFreeRoom`).** `inside`-vinduet for en mattekant + mellomrom er nå
  `[cur − g, cur + STEP]` for en høy kant (speilet for lav), og boksen settes til kanten også når det
  betyr å krympe. Hindring #30: sone 2 får y 3–59, én bredde 304 cm på y 9–59 inntil hovedkapitlet
  (anchor 'hi'), Σ 33,12 → 36,16 m, 32 → 36 m-rull, **16,0 → 18,0 m²** (benk: 84,0 → 94,5 %).
- **Tester.** `_matChapterRegressionTest` 14 → **22** (C bilde 2 nede-/øverst-venstre, B T-rom + `_matChapterStubAt`
  på fire punkter, A H-rom, E/snapp hindring #30, E-mekanismen med en inntrenger 2 cm inn i alkoven: 'v'
  feiler med `overlap`, tvungen 'h' legger 3 × 480 (Regel 27 på langs gjennom tom hoveddel), begge feiler
  med inntrenger → to varsler og utelatt). `_matCrossFillRegressionTest` 23 → **30** (variant A: 24 m valgt,
  26 m som alternativ med stubb 8 tverr, commit med alternativet beholder tverr-sjekkene; D 100T/150T og
  sentrert bit-identisk; A tverrstykker mellom to matter sentrert x 110,5–134,5).

### Før / etter per punkt

| Punkt | Rom | Før (`75bb622`) | Etter 134 |
|---|---|---|---|
| A | H-rom, bro mellom to stolper (100T) | 6 bredder x 178,5–483,5 (inntil venstre, 38 cm slakk mot høyre) | x **197,5–502,5**, 19 cm til hver nabomatte (`anchorAcross: 'mid'`) |
| B | T-rom 600×200 + stamme 200×300 (100T), Σ 29,76 m | 28 m, siste bredde **16 cm**, 14,0 m² | **24 m**, siste bredde hel (192), 12,0 m²; panel: 24 m «unngår stubb på 16 cm», 28 m «ender i en stubb på 16 cm» |
| B | Variant A 300×380 + alkove 226×200 (100T), Σ 26,40 m | 26 m, **8 cm** inn i tverrstykke 2, 13,0 m² | **24 m**, ender 24 cm inn i bredde 9 (= ett raster), 12,0 m²; 26 m som alternativ (`134-B-variantA-etter-panel`) |
| C | Bilde 2, velger nede-venstre | bredde 6 starter øverst (303, 3), hopp (51, −5) | bredde 6 starter **nederst** (303, 195), hopp (51, 187) ≈ 194 cm (`134-C-bilde2-bl-*`) |
| C | Bilde 2, velger øverst-venstre | bredde 6 starter nederst (303, 195), hopp (51, 187) | bredde 6 starter **øverst** (303, 3), hopp (51, −389) |
| C | Bilde 2, velger øverst-høyre (alkoven først) | kapittel 2 starter øverst (252, 8), hopp (−51, 5) | uendret |
| D | Rektangel 300×400 «fra vegg» (100T) | `S.mats`: 18 m, 5 × 360, slakk 43,5 cm udekket, 9,0 m² | kapittelbane: 5 × 384 + 7 × 24 cm tverr planlagt, Σ 20,88 m → **18 m** (20 m ville endt 8 cm inn i stykke 4), 9,0 m²; 20 m som alternativ gir 10,0 m² med 3 hele stykker + 8 cm (`134-D-rekt-fravegg-*`) |
| D | Samme, 150T | `S.mats`: 18 m, 8,96 m² («siste bredde kortere») | 5 × 384 + 7 × 32 cm, Σ 21,44 → **20 m** (ender 16 cm = to strenger inn i stykke 3), **10,0 m²** |
| D | Samme, sentrert (slakk 20,5 per side) | `S.mats` | `_matPlanZones` null → `S.mats`, bit-identisk |
| E | Benk hindring #30 (150T, auto) | sone 2 utelatt («ville overlappet en nabomatte»), 32 m, 16,0 m², 84,0 % | sone 2: 1 × 304 vannrett på y 9–59, 36 m, **18,0 m²**, **94,5 %** — snappen, ikke retningen (`134-E-hindring30-*`) |

### Test (prompten)

| # | Krav | Resultat |
|---|---|---|
| 1 | A: sone mellom to matter: lik slakk begge sider | Ja — H-rom 19 / 19 cm; tverrstykker mellom to matter 10,5 / 10,5 cm. Låst. |
| 2 | B: T-rommet ikke lenger 28 m + 16 cm; variant A ikke 8 cm inn i stykke 2; panelet viser alternativet | Ja — 24 m begge (tabellen); panelet viser den stubbfrie med «unngår stubb på X cm» og den større med «ender i en stubb på X cm». Låst. |
| 3 | C: bilde 2 nede-venstre: bredde 6 nederst, hopp ≈ 200 cm; øverst motsatt | Ja — (51, 187) ≈ 194 cm; øverst-venstre: bredde 6 øverst. Låst. |
| 4 | D: 300×400 «fra vegg» 100T: tverrstykker når feltet kvalifiserer; uten felt bit-identisk | Feltet (43,5 cm) kvalifiserer og får 7 × 24 cm planlagt; med B-regelen faller de utenfor 18 m-rullen (20 m ender 8 cm inn i stykke 4) — 20 m er ett klikk unna i panelet og gir 10,0 m² (`134-D-rekt-fravegg-alt20m-etter-utlegg`). 150T får stykkene i 20 m-rullen (10,0 m², var 8,96). Sentrert → null → bit-identisk (benk: alle rektangulære rader uendret). Låst. |
| 5 | E: hindring #30: 319 cm-bredden legges, dekning opp | Ja — 304 cm (312 brukbart etter hindringsklaring 3 cm, 16-raster), 84,0 → 94,5 %. Årsaken var snappen (STEG 0.4); E-mekanismen er bygget og låst, men gir ingenting i benken. |
| 6 | Mattebenk: ingen rom lavere (B kan gi små nedganger — list dem), batterier grønne, testene utvidet | 224 rader, 212 uendret, 2 høyere (hindring #30 vei 1/2), **10 lavere — alle B**, se under. Ingen ny ulovlig (29 før/etter, alle vei 4). `_matRegressionTest` 2/2 · `_matZoneRegressionTest` 17/17 · `_matChapterRegressionTest` **22/22** · `_matCrossFillRegressionTest` **30/30** · `_matFreeRegressionTest` 26/26 · `_matPathClickRegressionTest` 28/28 · `_matRunAdjustRegressionTest` 70/70 · `_matArrangementRegressionTest` 55/55 · `_matRotationRegressionTest` 35/35 · `_foilRegressionTest` 9/9 · `_pdfExportSmokeTest` 20/20. Ingen konsollunntak. |

### Mattebenk-differansen (`_matBench(42, 64)`, før = `75bb622`, etter = 134; vei 1 = vei 2)

| Rom (150T, auto, 1 cm) | Dekning før → etter | Rull før → etter | Hvorfor |
|---|---|---|---|
| hindring #30 | 84,0 → **94,5 %** | 32 → 36 m | snapp innover: sone 2 lagt (1 × 304) |
| 1108 Garderobe / Kenneth L-rom (samme geometri) | 84,1 → 77,6 % | 26 → 24 m | B: 26 m endte 8 cm inn i en 192-bredde (raster 16) |
| L #23 | 80,5 → 69,0 % | 14 → 12 m | B: 14 m endte 8 cm inn i tverrstykke 1 (16 cm) |
| hindring #26 | 85,3 → 75,8 % | 18 → 16 m | B: 18 m endte 8 cm inn i et tverrstykke |
| hindring #27 | 85,6 → 79,0 % | 26 → 24 m | B: 26 m endte 8 cm inn i et tverrstykke |

De fem nedgangene er nøyaktig Kenneths valg i 131-2/132-2 (c): én kabelstreng (8 cm) i en bredde er ikke
en bredde. I alle fem viser panelet den større rullen som alternativ. Benkens `_matBenchPathsResult`
måler standardvalget. Poengene stiger i fire av dem (mindre breddespredning) — poengformelen sier fortsatt
lite om en kapittelbane (131).

### Funn utenfor scope (ikke rettet)

- **Grid-dekomponeringen taper centimeter i soner.** H-rommets bro (y 300–500) blir rektangel y 301–497;
  kapitlet får 168 cm bredder der 192 hadde fått plass (margin 2,5 fra den ekte veggen). `_decomposeRoomToRects`
  rasteriserer i 6–12 cm celler (132 STEG 0.2). Regel 27-utvidelsen gjelder bare sonegrense-kanter, så en
  vegg-kant som ligger noen cm inne i rommet blir stående.
- **E gir ingenting i benken** etter snapp-fiksen: en Regel 27-avvisning krever nå en matte som stikker
  dypere enn mellomrommet inn i sonen, og da feiler som regel begge retninger. Mekanismen står (bestilt),
  låst i testen med en syntetisk inntrenger.
- **Panelet viser fortsatt to like rader** når like og blandet er samme plan (131-6) — nå også for
  alternativ-radene (dedupliseres når de er like).
- **Hindring uten navn tegnes med «undefined»-etikett** i den syntetiske #30-oppsettet (`134-E-hindring30-*`) —
  harnessens hindring mangler `name`; ikke sett i appen.
- **D endrer geometrien i rektangler med kvalifisert felt** selv når tverrstykkene faller utenfor rullen
  (300×400 100T: 5 × 384 + 264 i stedet for 5 × 360, samme 9,0 m²): kapittelbanen fyller til kapasitet og
  lar rullen skjære. Dekningen er lik, bildet er et annet (SPØRSMÅL 134-2).

### Skal IKKE — holdt
133s konvensjon, frihånd-tegningen og frihånd-panelet (`_matPathPanel`) er urørt; bare sone-forslagspanelet
(`_showMatZoneProposalPanel`) har fått B-radene og D-ordlyden. Ikke pushet.

### Verifiseringsmetode
Headless Chrome (CDP, port 9333) mot `serve-varmeplan.js` på 4000 (ny) og `python -m http.server` på
4002 (`75bb622`) uten innlogging — harness i `/tmp/cdp134/` (`cdp.mjs`, `setup130.js`, `steg0.mjs` (alle
punktene målt på begge versjoner → `steg0-before.json` / `steg0-after.json`), `debug30.mjs` (snapp-
hypotesen), `dbgL.mjs` (benkrommene med B), `tests.mjs`, `bench.mjs` + `diff.mjs` (radnivå), `shots.mjs`
(panel + utlegg på begge porter)). Utlegg via `_matFillRoomSmart` og ekte «Legg ut»-klikk.

### Endringslogg (kode, alt i `index.html`)
- Nye: `_matChapterStubAt`, `_matChapterBestAtKFree`.
- Endret: `_matZoneAnchorSide` (`'mid'`), `_matChapterBlock` (`opts.dir`/`opts.fail`/`otherDir`, `'mid'`),
  `_matCrossFieldChapter` (`'mid'`), `_matPlaceMultiMats` og `autoFillMatSerpentine` (`'mid'`),
  `_matZoneFreeRoom` (snapp innover), `_matChapterRunOrder` (velgerens ende), `_matChapterRollPlans`
  (`path`, `equalAlt`/`mixedAlt`/stubb-felter), `_matPlanZones` (én sone, E-forsøk, `single`, banen til
  rullvalget, `otherDir`), `_showMatZoneProposalPanel` (alternativ-rader, stubbnoter, D-ordlyd, E-note,
  laidRuns i toasten), `_matChapterRegressionTest`, `_matCrossFillRegressionTest`.
- Spec `spec-matte-utlegg.md` (Cowork-mappa): Regel 11-notat, Regel 24-notat (stubbvalget), Regel 27 pkt. 3–5
  + 134-notat, Regel 28 pkt. 1 (startende), Regel 29 pkt. 1–2 + 134-notat.

Commit: «134: matte — svar serie-128 (motor): sentrering mellom naboer, rullvalg uten stubb, kapittelstart
følger velgeren, Regel 29 i rektangulære rom, utelatt sone prøves i andre retning; spec». **Ikke pushet.**

## 135

Kjørt 24.10.2026 på `main` fra `273cce5` (134 committet, ikke pushet). **Ikke pushet.** Kenneths svar på
serie-128 (panel og frihånd), skrevet inn i `docs/serie-128/SPØRSMÅL.md` (128-2/3/4, 129-1/2/3, 130-2,
131-6). Skjermbilder i `skjermbilder/135-*` (headless Chrome via CDP på port 9335, harness i
`/tmp/cdp135`, gammel kode `273cce5` servert fra port 4002).

**Resultat i én setning:** frihånd-vakten godtar nå 0,1 cm (var 1 cm i startsøket, 0,5 cm på lengden)
og sjekker nettkanten mot vegg også på tvers (var ingen sjekk — en nettkant 1,5 cm *utenfor* veggen
gikk gjennom); katalogen viser «Nett 2,5 cm · kabel 5,0 cm» (150T: 3,0; InSnow: 0); hopp-streken rutes
langs veggen bredden slutter mot og så inn til startpunktet (rundt et hjørne: neste vegg), ellers rett;
hopp-punktet snapper langs banen til kuttrasteret fra forrige ende (24/16 cm); «Fyll rom» i et rom med
matter spør «Tøm og fyll / Fyll rundt dem / Avbryt» (Enter = tøm); sonepanelet viser én rad når like og
blandet er samme plan. Én ting utenfor listen: den strammere vakten avslørte at grid-dekomponeringen lar
sone-rektangler stikke 0,5–2,5 cm **utenfor** ekte vegger som ligger på en halv centimeter — rettet i
`_decomposeRoomToRects` (se «Funn under A»).

### STEG 0 — målt før endring (`steg0-foer.json`, port 4000 = `273cce5`)

1. **A · Vakten.** `_matFreeRunsWithinRoom` → `_matFreeClampLen`: startpunktet fikk ligge **1 cm**
   utenfor intervallet (`along >= lo − 1`, to steder), lengden fikk være **0,5 cm** for lang
   (`maxLen + 0.5 < len`). Målt i 300×400 med 100T (margin 2,5): langs 0,05 innenfor **OK**, 0,2
   utenfor **OK**, 0,9 utenfor avvist («matta ville ligget utenfor rommet»), 1,5 utenfor avvist
   («starter utenfor»). På tvers: 0,2 / 1,0 / 2,5 cm inne i marginen **OK**, og **nettkant 1,5 cm utenfor
   selve veggen OK** — `clipStripToRoom` klipper båndet stille til rommets ytterboks og trekker marginen
   bare fra intervallets ender. Benk vei 4 (134 `bench-after.json` = `273cce5`): **29 ulovlige** av 56
   (16 «starter utenfor», 13 «ville ligget utenfor» — 133-2: benkens 'h'-bane går nedover ut av rommet).
2. **B · Katalogen** bor i `index.html` (`_renderProductCatalog`, kolonnen «Veggmargin» via `marginOf` =
   `min_wall_margin_mm / 10`), ikke i `admin.html` (som ikke har noen margin-kolonne). Viste «5.0 cm» for
   alle EcoMat, «0.0 cm» for InSnow.
3. **C · Hoppet** tegnes av `_drawMatJumpLink(A, B)` som én rett stiplet strek — i plan (lagret bane og
   ghost) og i PDF (`_renderRoomToImage` tegner via hoved-`render()`, samme tegner). Bilde 2 (bl): hopp
   fra (252, 8) til (303, 195), rett diagonal (`135-C-bilde2-utlegg-foer`).
4. **E · «Fyll rom».** Det gamle produktpanelet kaller `_matFillRoomSmart(id)` direkte — tømmer ikke;
   UPC «Fyll rom automatisk ★» (`_upcPlaceMat(id,'auto')`) gjør `pushUndo` + `_clearRoomProductCollections`
   og kaller med `skipPushUndo`. Målt: rom 300×400 med to frihåndsmatter → «Fyll rom» la én `S.mats`-
   matte rundt dem uten spørsmål (`135-E-fyllrom-utlegg-foer`).
5. **D · Snapp:** `_matFreeJumpPoint` snappet til 10 cm-raster på begge akser (E = (27,5, 13,5): mus
   (80, 206) → (78,5, 210)). **F:** bilde 2 ga «1 rull» + «1 rull (gir ingenting ekstra her)».

### Gjort (alt i `index.html`)

- **A · Vakt.** Ny konstant `MAT_FREE_TOL_CM = 0.1` brukt i `_matFreeClampLen` (begge intervallsøk) og i
  `_matFreeRunsWithinRoom` (lengden). Ny `_matFreeRunCrossShortCm(mp, r, room)`: båndet nett + margin på
  begge sider må ligge inne i polygonet langs hele bredden (ytterboks + skannelinjer via
  `clipStripToRoom` med margin 0); mangler det, trimmes båndet fra én side om gangen (binærsøk) og tallet
  rapporteres. Vakten avviser med «bredden ligger X cm for nær veggen på tvers (margin Y cm)»; et
  startpunkt inne i rommet men inne i marginen sier nå «banen starter inne i veggmarginen (Y cm)» (var
  «utenfor rommet»). Kun rommets vegger — hindringer/soner har sine egne klaringer i klampen.
  **Rødmerking (124):** `_matPathRunIssue` får «ligger X cm inne i veggmarginen (Y cm) i enden / på
  tvers», og `_drawMatPathObj` merker nå **alle** bredder i en lagret bane (var kun justerte) — en bane
  lagret med den gamle toleransen vises rød, spretter ikke; breddepanelet (`_matRunPanelHtml`) viser
  teksten for frihåndsbredder uten justering også.
- **B · Katalog.** `marginOf(p, isMat)`: matte-rader «Nett 2,5 cm · kabel 5,0 cm» (`_matWallMarginCm` /
  `MAT_CABLE_WALL_CM`), 150T «Nett 3,0 cm · kabel 5,0 cm», `min_wall_margin_mm = 0` → «0». Andre typer
  som før. Ingen DB-endring.
- **C · Strek langs vegg.** Ny `_matJumpLinkRoute(mp, prevRun, A, B)`: A må ligge inntil en vegg
  (≤ max(12, margin + cc + 2) cm), stykke 1 går på tvers av banens akse i A sin langs-koordinat til
  B sin tverr-koordinat (hjørnet P) og må følge veggen hele veien; stykke 2 går langs banens akse inn
  til B. Ligger P utenfor rommet (hopp rundt et hjørne), trekkes P inn til innsiden av veggen og kabelen
  følger neste vegg til B sin langs-koordinat (P2) før et kort stykke inn til B — fire punkter. Faller
  noe av dette utenfor, tegnes streken rett som før. `_drawMatJumpLink(A, B, invalid, route)` tegner
  polylinjen; lagret bane, ghost (fase hopp og låst punkt) og PDF bruker samme rute.
- **D · Snapp.** `_matFreeJumpPoint`: langs forrige bredde sin akse snapper punktet til
  `E.along + k × RASTER` (`mat_cut_interval_mm` = 2 × CC: 24 cm 60T/100T, 16 cm 150T); på tvers inntil
  forrige bredde ± mellomrom og forrige endes koordinat innen ~14 px, ellers fritt (0,1 cm). 10 cm-
  rasteret er borte.
- **E · Fyll rom.** `_matFillRoomSmart`: har rommet matter (`S.mats` + `S.matPaths` med `roomId`) og
  kallet ikke er `dryRun`/`skipPushUndo`/`fillAround`, vises `_matFillChoicePanel`: «Rommet har N matter
  fra før» → [Tøm og fyll] (standard, Enter: `pushUndo` + `_clearRoomProductCollections(roomId,
  ['mats','matPaths'])` + `_matFillRoomSmart(…, {skipPushUndo:true})` — ett angre-steg, sonepanelets
  Avbryt gir mattene tilbake via sin egen `undo()`) [Fyll rundt dem] (`fillAround: true` = 130-oppførsel)
  [Avbryt] (Esc). UPC-auto og benken (dryRun) uendret.
- **F · Rullvalg.** `_showMatZoneProposalPanel`: er «like» og «blandet» samme plan, vises bare like-raden
  (forvalget faller til 'equal' om det sto på 'unequal'); noten «(gir ingenting ekstra her)» er borte
  der. `_showMatMultiProposalPanel`: «ulike» skjules bare når produktlista er nøyaktig den samme; lik
  dekning med en annen plan beholder begge rader og noten.

### Funn under A — grid-dekomponeringen stikker utenfor halvcentimeter-vegger (rettet)

Benken etter A alene: dekning uendret på alle 224 rader, men **T-19, T-20 og U-22 (vei 1 og 2) ble
ulovlige** — kapittelbanen fra 134 ville blitt avvist av `_matChapterCommit` sin vakt i appen («Ingen
matte kunne legges ut»). Årsak (målt i `dbgB.mjs`): `_decomposeRoomToRects` legger cellekanter på
`minX + k × CELL` (7 cm) og klemmer bare til rommets *ytterboks* — en indre vegg på 164,5 ga rektangel
161–301 for stammen 164,5–299,5 (T-19), 462 for veggen 459,5 (T-20: bredden lå **1 cm** fra veggen, 2 cm
inne i marginen, og hadde gått gjennom i 134 fordi vakten ikke sjekket tvers), 343 for veggen 345 (U-22).
Kapitlene ankrer på rektangelet + margin, og den gamle 1 cm-toleransen skjulte det. Rettet i
`_decomposeRoomToRects` (`snapToWalls`): en rektangelkant som ligger innenfor én celle *utenfor* en
ortogonal vegg (rommet på innsiden, sjekket med prøvepunkt 0,5 cm på hver side) trekkes inn til veggen.
Kanter som ligger *inne* i rommet røres ikke — 134-4 («taper centimeter») står som eget spørsmål.
Etter fiksen: T-19 161→164,5 / 301→299,5, T-20 252→252,5 / 462→459,5, U-22 343→345 / 161→160,5 / 322→322,5;
alle tre lovlige, **dekning identisk** (224/224 rader uendret mot 134). `_foilRegressionTest` 9/9
(folie-sonene bruker samme dekomponering, strimlene klippes mot rommet uansett).

### Mattebenk (`_matBench(42, 64)`, før = 134 `bench-after.json`, etter = `135-bench-after.json`)

| | Før | Etter | |
|---|---|---|---|
| Rader / dekning uendret | 224 | **224 / 224** | ingen rad opp eller ned |
| Ulovlige, alle veier | 29 | **30** | +1: grense-minlengde-51 vei 4 |
| Ulovlige, vei 4 | 29 | **30** | 16 «50,0 cm for nær veggen på tvers», 13 «ville ligget utenfor», 1 «starter utenfor» |

Den nye raden (rom 232×113, 'h', 2 bredder): benkens syntetiske bane legger bredde 2 på y 135 — 22 cm
*under* rommet — og gikk før gjennom fordi klampen klippet båndet stille til ytterboksen (ingen tverr-
sjekk); nå «bredden ligger 50,0 cm for nær veggen på tvers». De 16 'h'-radene som før sa «starter
utenfor» (bredde 3) stoppes nå alt på bredde 2 med tverr-tallet — samme rom, riktigere grunn (133-2
står). Ingen lovlig rad ble ulovlig etter dekomponeringsfiksen.

### Test (prompten)

| # | Krav | Resultat |
|---|---|---|
| 1 | A: 0,05 innenfor godtas, 0,2 utenfor avvises, for nær på tvers rødmerkes; benk vei 4 før/etter | Langs: 0,05 **OK**, 0,2 **avvist** («starter inne i veggmarginen (2,5 cm)»). Tvers: 0,05 OK, 0,2 avvist «0,2 cm for nær veggen på tvers», nettkant utenfor veggen «4,0 cm». Rødmerking: `_matPathRunIssue` gir «Bredde 1 ligger 1 cm inne i veggmarginen (2,5 cm) på tvers». Vei 4: 29 → 30 (én ekte ulovlig som slapp gjennom før). Låst i `_matFreeRegressionTest`. |
| 2 | B: nett/kabel for 60T, 100T, 150T, 0 for InSnow | 60T/100T «Nett 2,5 cm · kabel 5,0 cm», 150T «Nett 3,0 cm · kabel 5,0 cm», InSnow «0» (`135-B-katalog-*`; InSnow-raden er syntetisk i harnessen — ingen Supabase uten innlogging). |
| 3 | C: bilde 2 hopp 6 → 7 langs veggen i plan og PDF; midt i rommet rett | Bilde 2 (bl, 5 bredder i hoveddelen): (252, 8) → (303, 8) → (303, 195) — langs V1 og ned til startpunktet, i plan (`135-C-bilde2-hopp-zoom-etter`) og PDF (`135-C-bilde2-pdf-rombilde-etter`). Midt i rommet (bredde stoppet 157,5 cm fra veggen): rett (`135-C-midt-etter`). Rundt hjørnet (L-rom, hopp fra hoveddelens bunn til alkoven): 4 punkter, låst i testen. Ghost i fase hopp følger samme rute (`135-C-hopp-ghost-etter`). |
| 4 | D: hopp-snapp treffer 24/16 cm-raster langs banen | E = (27,5, 13,5), 100T: mus (80, 206) → (78,5, **205,5**) = 13,5 + 8 × 24; (150, 100) → (150, 109,5); (27, 300) → (27,5, 301,5). Testen: 150T-rom (397,5 − 9 × 24 = 181,5). Låst. |
| 5 | E: rom med to matter → valget; Tøm og fyll som før 130; Fyll rundt = 130 | Valget vises (`135-E-fyllrom-etter`). Tøm og fyll: 2 baner → 0, 1 ny matte, undo-stakk +1, angre gir de to tilbake (`135-E-toem-og-fyll-etter`). Fyll rundt: 2 baner + 1 matte (`135-E-fyll-rundt-etter`, = STEG 0.4). |
| 6 | F: én rad når like, to når ulike | Bilde 2: én rad «1 rull» (`135-F-bilde2-panel-etter`, var to). T-rom/variant A fra 134 (like ≠ blandet): uendret to rader + alternativ-rader (`_matChapterRegressionTest` 22/22). |
| 7 | Batterier, `_matFreeRegressionTest` utvidet, `_pdfExportSmokeTest` | `_matFreeRegressionTest` 26 → **36** (A: 5, C: 3, D: 1 + omskrevet snapp-fasit) · `_matChapterRegressionTest` 22/22 · `_matCrossFillRegressionTest` 30/30 · `_matZoneRegressionTest` 17/17 · `_matRegressionTest` 2/2 · `_matPathClickRegressionTest` 28/28 · `_matRunAdjustRegressionTest` 70/70 · `_matArrangementRegressionTest` 55/55 · `_matRotationRegressionTest` 35/35 · `_foilRegressionTest` 9/9 · `_pdfExportSmokeTest` 20/20. Ingen konsollunntak. |

### Skjermbilder
`135-B-katalog-{foer,etter,150T-etter,insnow-etter}`, `135-C-bilde2-utlegg-{foer,etter}`,
`135-C-bilde2-hopp-zoom-etter`, `135-C-bilde2-pdf-rombilde-etter`, `135-C-midt-etter`,
`135-C-hopp-ghost-etter`, `135-E-fyllrom-{foer,etter}`, `135-E-fyllrom-utlegg-foer`,
`135-E-toem-og-fyll-etter`, `135-E-fyll-rundt-etter`, `135-F-bilde2-panel-{foer,etter}`,
`135-bench-after.json`.

### Funn utenfor scope (ikke rettet)
- **Stykke 2 av hopp-streken går over bredden selv** når startpunktet ligger i enden av bredden som
  vender bort fra veggen (bilde 2: fra (303, 8) ned x = 303 til (303, 195) — rett gjennom bredde 6). Det
  er bokstavelig «langs veggen, så inn til startpunktet»; en montør ville nok limt kabelen langs V1 og
  bredde 6 sin kant. SPØRSMÅL 135-1.
- **Rødmerking for alle bredder** betyr at en lagret bane over en hindring som er lagt til *etterpå*
  også blir rød (før: bare justerte bredder). Tilsiktet (124-prinsippet), men nytt.
- **Benkens 'h'-bane (133-2)** står: 16 rom får fortsatt bredde 2 lagt under rommet.
- `admin.html` har ingen produktkatalog; prompten antok det.

### Skal IKKE — holdt, med ett unntak
Motoren fra 134 (`_matZoneAnchorSide`, `_matChapterRollPlans`, `_matChapterRunOrder`, `_matPlanZones`,
`_matChapterBlock`) og 133-konvensjonen er urørt; `min_wall_margin_mm` ikke migrert; ikke pushet.
**Unntaket** er `_decomposeRoomToRects` (eldre enn 134, delt med folie-sonene): kanter som stakk
*utenfor* veggen klemmes inn. Uten den ville A gjort auto-utlegg umulig i rom med vegger på halve
centimeter. Lett å ta ut (én blokk, `snapToWalls`) om det skal vente på 134-4.

### Endringslogg (kode, alt i `index.html`)
- Nye: `MAT_FREE_TOL_CM`, `_matFreeRunCrossShortCm`, `_matJumpLinkRoute`, `_matFillChoicePanel`,
  `snapToWalls` (inne i `_decomposeRoomToRects`).
- Endret: `_matFreeClampLen` (0,1 cm), `_matFreeRunsWithinRoom` (0,1 cm, tverr-sjekk, ny startmelding),
  `_matPathRunIssue` (margintekst), `_drawMatPathObj` (alle bredder merkes, hopp-rute),
  `_matRunPanelHtml` (frihånd uten justering), `_drawMatJumpLink` (polylinje), ghost-tegningen,
  `_matFreeJumpPoint` (kuttraster), `_matFillRoomSmart` (valget), `_showMatZoneProposalPanel` og
  `_showMatMultiProposalPanel` (én rad), `_renderProductCatalog` (nett/kabel), `_matFreeRegressionTest`.

Commit: «135: matte — svar serie-128 (panel/frihånd): vakt 0,1 cm + tverr, katalog viser nett/kabel-
margin, hopp-strek langs vegg, snapp på kuttraster, Fyll rom spør om tømming, én rad ved like planer».
**Ikke pushet.**
