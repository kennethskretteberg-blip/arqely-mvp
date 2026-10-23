# 128 — Matte: veggmarginen følger Regel 12 (kabel 5 cm fra vegg = nett 2,5/3 cm), én kilde

## 128

Kjørt 23.10.2026 på `main` fra `69e3831` (127 committet, ikke pushet). **Ikke pushet.** Spec: Regel 12
(`spec-matte-utlegg.md`, Cowork-mappa) — Kenneths avgjørelse 23.10.2026 er skrevet inn der, og
konfliktnotatet fra 22.08 er lukket. Skjermbilder i `skjermbilder/` (headless Chrome, 300 × 400-rom,
EcoMat 100T 0,5×18 m, stående, hjørne nede-venstre).

Kenneth (23.10.2026): «Min 5 cm fra kabel til vegg, dvs. 2,5 cm fra ytterkant nettet til vegg.»

**Resultat i én setning:** nettet lå 5 cm fra vegg (kabelen 7–7,5 cm); nå ligger kabelen 5 cm fra vegg
(nettet 2,5 cm for 60T/100T, 3 cm for 150T), fra én funksjon, i alle veier. Snømatter uendret.

## STEG 0 — målt før endring (gammel fil servert på port 4300)

### 0.1 Alle steder som leste `min_wall_margin_mm` eller hadde egen veggmargin for matte

| Sted (linje før 128) | Verdi i dag | Kilde | 128 |
|---|---|---|---|
| `_matPlaceCandidate` :13832 (klikk-plassering, ghost) | 5 cm | `prod.min_wall_margin_mm ?? 50` | → `_matWallMarginCm` |
| `_matWholeBandPlanForDir` :15018 (hele bredder per sone) | 5 cm, **0 hvis feltet mangler** | `min_wall_margin_mm \|\| 0` | → `_matWallMarginCm` |
| `_matRoomGeomForFill` :15306 (flermatte-søket, benk) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matZonePlanFor` :15579 (soner) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matRelayWithGap` :16257 (127, mellomrom i denne matta) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `autoFillMatSerpentine` :16339 (auto) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matFreeCableMarginCm` :17328 (frihånd **langside**: klipp, vakt, areal, tegning) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matFreeStartFor` :17492 / `_matFreeStartSlide` :17544 (frihånd **kortside**) | `max(cc/2, 5)` = 5 cm (150T), **6 cm** (60T/100T, cc 12) | cc/2 mot produktfeltet | kortside = langside = `_matWallMarginCm` |
| Klikk-plassering, vakten :64734 | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matGroupMaxMarginCm` :44713 (avstand for en gruppe) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `getMatViolations` :89788 (varsel ved flytting) | 5 cm, 0 hvis feltet mangler | `\|\| 0` | → `_matWallMarginCm` |
| `_matArrangementRegressionTest` :18511/:18525 | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matBenchMatsResult` :19439 / `_matBenchRunVei4` :19491 (mattebenk, brukbart areal) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matRunPlacementIssue` :14544 (124-rødmerking) | ingen margin — sjekker rompolygonet med 0,5 cm toleranse | — | uendret |
| `_clampMatToRoom` :44792 (drag) | ingen margin — klemmer til rommets boks | — | uendret (varselet etter drag bruker `getMatViolations`) |
| `_matUsableAreaM2` / `_matRunsWithinRoom` / `_matClippedSegments` | tar `marginCm` som parameter | kallerne over | uendret |
| PDF | ingen egen margin — PDF tegner matta via `drawMats` (127-rapporten); ingen mål-tekst for matte-margin | — | uendret |
| Objektinfo «Avstand langvegg» :61697 | viser `mat._effMarginAlongCm` (satt av motoren) | motoren | følger automatisk |
| `_autoFillPlates` :20673 | 5 cm | `?? 50` | **urørt** — plater, ikke matte |
| Produktkatalog (admin) `marginOf` :80166 | viser feltet rått: «5,0 cm» | DB-feltet | urørt (se SPØRSMÅL 4) |
| Innlasting :84837 | setter 25 mm hvis feltet mangler | — | urørt; feltet er nå bare et «0 = ute»-flagg |
| Reservekatalog `_ensureEcoMatProducts` :89297 | `min_wall_margin_mm: ty.inset` (20/25) | — | urørt; ≠ 0 → Regel 12 |
| `_matBenchCatalog` :15756 | 50 (inne) / 0 (InSnow) | — | urørt |

Spec-tabellen under Regel 12 («tre forskjellige veggmarginer») stemte delvis: auto og frihånd langside
var begge 5 cm (ikke 20/25 mm som tabellen sier for auto — det gjaldt bare reservekatalogen), mens
kortsiden var `max(cc/2, 5)`, altså 5 cm for 150T og **6 cm for 60T/100T**. Tabellen er merket som
historikk i spec-en.

### 0.2 300 × 400-rommet, stående matte, nede-venstre (målt med `_matRunWorldGeom`)

| | Før (nett 5 cm) | Etter |
|---|---|---|
| **100T** (velger 0,5×18 m, 5 bredder × 360 cm, mellomrom 7) | nett 5,0 cm fra endevegg, kabel **7,5 cm** | nett **2,5 cm**, kabel **5,0 cm** |
| **150T** (0,5×18 m, 5 bredder, mellomrom 4) | nett 5,0 cm, kabel **7,0 cm** | nett **3,0 cm**, kabel **5,0 cm** |
| Antall bredder | 5 | 5 (6 bredder trenger 335 cm, rommet gir 295) |
| Sideveis (sentrert, Regel 9) | 11 cm (100T) / 17 cm (150T) | uendret — mellomrommet, ikke marginen, styrer |

Skjermbilder `01-foer-…` og `02-etter-…` viser det samme utlegget med nettet 5 → 2,5 cm fra bunnveggen.

### 0.3 Mattebenk før endring
`_matBench(42, 64)`: 224 rader, 196 lovlige. Lagret som referanse (absolutt m² per rad, ikke bare
prosent — se under hvorfor det var nødvendig).

## Gjort

1. **`MAT_CABLE_WALL_CM = 5` og `_matWallMarginCm(prod)`** rett etter `_matEdgeInsetCm`:
   `max(0, 5 − _matEdgeInsetCm(prod))`; `min_wall_margin_mm === 0` → 0 (utendørs, «ingen vegger ute»);
   uten produkt → 5 (konservativt). Gir 2,5 cm (60T/100T, inntrekk 25 mm) og 3,0 cm (150T, 20 mm).
2. **Alle stedene i tabellen** bruker funksjonen. Ingen `?? 50`, `|| 0` eller hardkodet 5 igjen i
   mattekoden for veggmargin.
3. **Frihånd kortside = langside.** `shortM = longM = _matWallMarginCm(prod)` (var `max(cc/2, 5)`).
   Kabelkravet holder i enden med god margin: tegningen legger første streng cc/2 (≥ 4 cm) innenfor
   mesh-kanten.
4. **Regel 29** (132) kan lese `MAT_CABLE_WALL_CM`; spec-en sier det nå.
5. **Basen urørt.** `min_wall_margin_mm` = 50 på alle EcoMat-rader står, men leses bare som «≠ 0».
6. Spec: Kenneths avgjørelse under Regel 12, konfliktnotatet lukket, kodingen beskrevet.

### Om `min_wall_margin_mm` (punkt 2 i prompten)
Feltet heter «veggmargin» og har hatt tre tolkninger: nettmargin (motoren før 128), kant-inntrekk
(reservekatalogen setter 20/25) og innlastingsstandard 25 mm. Etter 128 betyr det bare «0 = ute».
Anbefaling: **omtolk det til kabelkravet** (`kabel−vegg i mm`, 50 for EcoMat, 0 for InSnow — det er det
radene faktisk inneholder i dag) og la `_matWallMarginCm` lese `prod.min_wall_margin_mm ?? 50` som
kabelkrav i stedet for konstanten. Det krever først at (a) reservekatalogen slutter å sette inntrekket i
feltet, og (b) innlastingsstandarden 25 mm (som er folie-standarden) ikke gjelder matte — ellers blir
kabelkravet 2,5 cm og nettmarginen 0. Begge er små, men hører i sin egen prompt med migrasjon (evt.
omdøpt til `mat_cable_wall_mm`). Ikke gjort her.

## Test

| # | Krav | Resultat |
|---|---|---|
| 1 | 300 × 400 med 100T: nett 2,5 cm (kabel 5,0); 150T: 3,0 | ✓ målt (tabell 0.2) |
| 2 | Frihånd: bane kan legges 2,5 cm fra vegg, ikke nærmere | ✓ delvis — se under |
| 3 | Mattebenk: ingen rom lavere | ✗ **3 rader lavere i absolutt m² — alle er retningsvalg, se under** |
| 4 | Alle matte-batterier + `_pdfExportSmokeTest` grønne | ✓ 2/2, 4/4, 13/13, 70/70, 55/55, 28/28, 20/20 |

### Test 2 — frihånd
Startpunktet (`_matFreeStartFor`, 'v', nede-venstre) er (27,5 · 397,5) for 100T = nett 2,5 cm fra
begge vegger, og (28 · 397) for 150T = 3 cm. Før: (30 · 295) i testrommet; forventningen i
`_matFreeRegressionTest` er oppdatert til (28 · 297) med kommentar — det eneste tallet som låste 5 cm.

**Funn (ikke rettet, fantes før 128):** commit-vakten `_matFreeRunsWithinRoom` godtar en bane inntil
**1,0 cm innenfor marginen langs banen** (toleransen `along >= lo − 1` i `_matFreeClampLen`; målt: 100T
godtatt til 1,5 cm, avvist fra 1,25 cm; gammel fil: godtatt til 4,0 cm med 5 cm margin — samme 1 cm).
**På tvers** sjekker vakten ikke marginen i det hele tatt — `clipStripToRoom` trekker marginen bare fra
langs sveipaksen. Plasseringen (start/gli) holder marginen eksakt, så i praksis styrer startpunktet.

### Test 3 — mattebenk (224 rader, 56 rom × 4 veier)
Benkens «Dekning %» er dekket m² / brukbart m², og **brukbart areal vokser** når marginen krymper
(1642 → 1666 m² summert over innendørs-radene). Prosenten faller derfor for 133 rader selv der dekket
m² er uendret. Sammenligningen er gjort på **absolutt m²** (egen kjøring som speiler `_matBench`):

| | Før | Etter |
|---|---|---|
| Dekket m², vei 1/2 (auto, 56 rom) | 1246,2 | **1300,4** (+54,2 m², +4,3 %) |
| Dekket m², vei 4 (frihånd-syntetisk) | 755,8 | 763,0 |
| Dekket m², vei 3 (InSnow) | 588,5 | 588,5 (uendret, krav) |
| Rader høyere / like / lavere | — | **38 / 183 / 3** |
| Lovlige rader | 196 | 195 |

**De tre lavere radene og de to lovlig→ulovlig:**

| Rom | Vei | Før | Etter | Hvorfor |
|---|---|---|---|---|
| rect #10 (420 × 259) | 1 og 2 | 8,96 m² | 8,00 m² | Auto-retningen byttet **v → h**. Velgeren (`_matAreaGeom`) sammenligner et *estimat*: med margin 3 gir 'h' 5 × 400 = 10,0 m² mot 'v' 8 × 240 = 9,6 (med margin 5: 'h' 4 bredder = 8,0 mot 9,6 → 'v'). Men 'h'-veien **leverer 8,0** (0,5×16 m, 5 × 320) i stedet for sitt eget estimat 10,0 — og matta får `y_cm = −30,5`. Det er 124-funnet «vannrett matte har to koordinatkonvensjoner». Tvunget 'v' gir 8,96 før og etter. |
| stor #45 (1557 × 873) | 4 | 46,08 (ulovlig) | 25,92 (lovlig) | Retning **h → v**. Før-raden var ulovlig («banen starter utenfor rommet») og telte ikke. Vei 1/2 steg 96 → 120 m² på samme rom. |
| 1110 Lærergarderobe HC | 4 | 6,4 lovlig | 6,8 **ulovlig** | Retning v → h; den syntetiske frihåndsbanen er ulovlig i 'h' for 14 av 18 'h'-rom før og 15 av 19 etter (samme feil). Vei 1 gir 6,0 m² begge, men 'h'-matta får `x_cm = −10`. |
| rect #10 | 4 | 7,2 lovlig | 10,0 **ulovlig** | Samme som over (v → h). |

**Kontroll:** med retningen tvunget til det den var før, gir alle tre rommene **identisk** absolutt
dekning før og etter i alle veier (rect #10 'v' 8,96/8,96; stor #45 'h' 96/96 og 46,08/46,08; 1110 'v'
6,0/6,0 og 6,4/6,4). Marginendringen i seg selv senker altså ingen rom. Det som senker rect #10 er at
retningsvelgeren nå (riktig, etter estimatet) velger 'h', og at 'h'-veien har en kjent feil (124) som gjør
at den leverer mindre enn estimatet og legger matta utenfor rommet. Stoppet her som prompten sier —
ikke rettet, hører til en egen prompt for vannrett matte. Se SPØRSMÅL 1.

## Verifiseringsmetode
`node --check` på inline-scriptet; headless Chrome (CDP, port 9333) mot `serve-varmeplan.js` på 4000 (ny)
og 4300 (gammel fil fra `HEAD`), uten innlogging (skylagring stubbet, `#app` vist), testene kjørt som
globale funksjoner. Benk-sammenligning på absolutt m² (egen kjøring, samme katalog/rom/veier som
`_matBench`).

## Endringslogg (kode, alt i `index.html`)
- `MAT_CABLE_WALL_CM`, `_matWallMarginCm` — nye (etter `_matEdgeInsetCm`).
- `_matPlaceCandidate`, `_matWholeBandPlanForDir`, `_matRoomGeomForFill`, `_matZonePlanFor`,
  `_matRelayWithGap`, `autoFillMatSerpentine`, `_matFreeCableMarginCm`, `_matFreeStartFor`,
  `_matFreeStartSlide`, klikk-vakten, `_matGroupMaxMarginCm`, `getMatViolations`,
  `_matBenchMatsResult`, `_matBenchRunVei4`, `_matArrangementRegressionTest` — leser funksjonen.
- `_matFreeRegressionTest` — forventning (30,295) → (28,297), kommentert.
- Spec `spec-matte-utlegg.md` Regel 12 og Regel 29-avhengigheten (Cowork-mappa, utenfor repoet).
