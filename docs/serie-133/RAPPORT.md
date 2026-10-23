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
