# 136 — Matte: Kenneths svar på serie-133 (motor)

## 136

Kjørt 24.10.2026 på `main` fra `82131aa` (135 committet, ikke pushet). **Ikke pushet.** Kenneths svar på
serie-133 (133-1/3/4, 134-1/2/3/4, 135-2) er skrevet inn under hvert spørsmål i `docs/serie-133/SPØRSMÅL.md`
(«**Svar (Kenneth 24.10):**»). Skjermbilder i `skjermbilder/136-*` (headless Chrome via CDP på port 9336,
harness i `/tmp/cdp136`; gammel kode `82131aa` servert fra port 4002 for «før»-bildene, ny fra 4000).

**Resultat i én setning:** auto-velgeren estimerer nå per retning det motoren faktisk leverer (Regel B/E/24/H
regnet tørt på boksen — 900 × 300 velger 'h' og får 15,0 m², var 'v' 12,0), rullvalget går bare ned til den
stubbfrie rullen når tapet er under ett rulltrinn (ellers beholdes største rull og stubben sies gult — de fem
benkrommene fra 134 er tilbake på 84,1 / 80,5 / 85,3 / 85,6 %), et rektangulært rom går kapittelbanen bare når
tverrstykkene faktisk havner i rullen, retningslåsen vinner over «prøv den andre retningen», og
grid-dekomponeringen snapper sonerektangler til veggen også innover (H-broa 300–500: 192 cm-bredder der 168/176
fikk plass). Mattebenk: 209 av 224 rader uendret, 13 høyere, **0 lavere**, 0 nye ulovlige, tid 163 → 159 ms.

### STEG 0 — målt før endring (`82131aa`, port 4002 — `/tmp/cdp136/steg0-4002.json`)

1. **A — hvor estimatet bor, og hvor leveringen regnes.** `_matAreaGeom` sin `_cov(d)` (lokal i retningsvalget)
   estimerer `antall bredder (Regel 8+18) × floor(langspenn / raster) × raster` — uten å vite hvilke ruller som
   finnes. Leveringen regnes i `autoFillMatSerpentine`: Regel B (`candidates`, største rull ≤ kapasitet), Regel E
   (`_matEqualWidthNL`) per forsøk, ellers fallbacken (N−1 like + kortere siste) og Regel H-løkka (`tooLong` →
   neste rull ned, inntil 5 forsøk). Målt (100T 9 m² som inngang, app-katalog 2–30 m, raster 24):

   | Rom | Estimat 'h' / 'v' (m²) | Auto | Levering 'h' | Levering 'v' |
   |---|---|---|---|---|
   | 900 × 300 | 22,2 / **24,48** | 'v' → **12,0** (24 m, 10 × 240) | **15,0** (30 m, 5 × 600) | 12,0 |
   | 300 × 900 | 24,48 / 22,2 | 'h' → 12,0 | 12,0 | **15,0** |
   | rect #10 420 × 259 (150T) | 10,0 / 9,6 | 'h' → 10,0 (alt riktig etter 133) | 10,0 | 8,96 |

   **Hvorfor 'v' faller fra 30 til 24 m** (probe `probeA.mjs`, `_matEqualWidthNL`/`_matLaidLengthCm` logget per
   forsøk): 30 m → Regel E null (125 enheter, ingen N ≤ 17 med L ≤ 295) → fallback 17 × 168 = 2856, 144 til overs
   → 28 m → E null (2800/24 går ikke opp) → fallback 16 × 168 + **112** — men `_matClipRunToRoom` flater den korte
   siste til rasteret (96) og vraker den under minstelengden 100 → `runLengths[16] = 0`, 112 til overs → 26 m →
   samme → 24 m: E 10 × 240. Estimatet må altså speile både Regel E **og** fallbackens raster/minstelengde.
   Benkens 35 rektangulære rom (150T): auto-retningen var alt lik beste levering i alle (`Arects` i JSON) —
   avviket finnes bare der Regel E feiler i flere rull-trinn på rad (900 × 300-typen, utenfor benken).
2. **B — rullen velges i `_matChapterRollPlans(Σ, prod, path)`** (134): like → neste lengde ned ved samme K til
   den er stubbfri, blandet → `_matChapterBestAtKFree`. Katalogtrinnene: 150T-benk 100 cm (2–10 m), 200 cm
   (10–32 m), 400 cm (32–60 m); app-katalogen 100T/150T 100 cm (2–10 m), 200 cm (10–30 m). De fem rommene:

   | Rom (150T, auto) | Σ | Største ≤ Σ | Stubb | Valgt i 134 | Tap = trinn? |
   |---|---|---|---|---|---|
   | 1108 Garderobe / Kenneth L-rom | 27,84 m | 26 m | 8 cm i bredde 8 (raster 16) | 24 m, 12,0 m² | 2 m = 2 m |
   | L #23 | 14,72 m | 14 m | 8 cm i tverrstykke 1 | 12 m, 6,0 m² | 2 m = 2 m |
   | hindring #26 | 18,56 m | 18 m | 8 cm i tverrstykke | 16 m, 8,0 m² | 2 m = 2 m |
   | hindring #27 | 26,56 m | 26 m | 8 cm i tverrstykke | 24 m, 12,0 m² | 2 m = 2 m |

3. **C — rektangelet avgjøres i `_matPlanZones`:** `single && !cross.chapters.length → null`; ellers kapittelbane
   — uten å vite om stykkene havner i rullen. 300 × 400 «fra vegg» med **auto**-retning (velgeren tar 'h', 7 × 288):
   100T: Σ 21,36 m → 20 m, stykkene (fra 20,16 m) utenfor, `dryRun.kind = 'zone'`, mens S.mats-veien gir 7 × 288
   med siste 264 (9,96 m²); 150T: Σ 20,96 → 20 m, stykkene utenfor, S.mats 10,0 m². Med 'v' låst (134-testen):
   5 × 384 + 7 × 24, Σ 20,88 → 18 m (134 / B), stykkene utenfor, 9,0 m².
4. **E — `snapToWalls`** (135) ser bare på kanter *utenfor* veggen (`w > r.x0 && w < r.x0 + CELL`). Kanter *inne* i
   rommet: H-rommets bro **203,301,497,497** mot ekte 300–500 (bench 150T: 6 × 176; app 100T: 'h' 3 × 288);
   T-19 `0,0,462,567` mot vegg 464/568; U-22 `0,345,483,784` mot 786; 1102 `0,0,896,400` + `0,400,296,696`;
   Kenneth L-rom `300,0,498,198`. 47 av 56 benkrom hadde minst én slik kant (1–6 cm), `Einside` i JSON.

Mattebenk før: `bench-before.json` — 224 rader, 194 lovlige, 163 ms totalt (vei 1 40 ms, vei 2 30 ms).

### Gjort (alt i `index.html`)

- **A · Estimat = Regel E.** Ny `_matDirCoverEstimateCm(n, alo, cut, minLen, lens, equalWidths)`: Regel B (største
  rull ≤ n × raster-lengde), så per forsøk Regel E (`_matEqualWidthNL` → hele rullen), ellers fallbacken slik
  `autoFillMatSerpentine` gjør den (N−1 like rundet opp til raster, siste tar resten, **flatet til raster og
  vraket under minstelengde** — nøyaktig det som felte 28 m), og Regel H (≤ ett kuttintervall til overs → ferdig,
  ellers neste rull ned, inntil 5 forsøk, beste forsøk vinner). Ny `_matVariantRollLensCm(prod)` (samme
  variantfilter som `candidates`). `_matAreaGeom` bruker det når `ctx.rollLensCm` er satt — fra
  `autoFillMatSerpentine` (utenfor sone) og `_matRoomGeomForFill` — og Regel 8-tallet som tie-break (1110: begge
  leverer 6,0 → 'h' som før). Kapitlene (`_matChapterBlock`, ingen rull) og Fjeldseth-båndene er urørt.
- **B · Stubb, ett trinn.** `_matChapterRollPlans`: den stubbfrie velges bare når `Σ største − Σ stubbfri <
  katalogavstanden fra største rull i maksplanen til neste rull ned` (`stepBelow`). Ellers beholdes største med
  `equalStub`/`mixedStub`, og den stubbfrie legges i nye `equalLess`/`mixedLess` (+ `…LessLossCm`, `…StepCm`).
  Panelet: den valgte raden sier **gult** «siste bredde er en stubb på X cm (Regel 24) — nest største rull (Y m)
  hadde tapt Z m, ett rulltrinn (T m) eller mer»; den stubbfrie vises som «(nest største, unngår stubben)» og kan
  velges (`equalLess`/`unequalLess` → `_matChapterCommit`). Tapet < trinnet (134-oppførselen) står urørt.
- **C · Rektangel.** `_matPlanZones`: for `single` returneres null når `coverCm < Σ hovedbredder + første
  tverrstykke` — rommet går S.mats-veien som før 134, bit-identisk.
- **D · Lås vinner.** `_matPlanZones` leser `userDir`; ved `fail.reason === 'overlap'` med lås utelates sonen med
  `reason: 'dirLocked'` (ingen nytt forsøk). `excludedZones[].reason` settes også ellers (`'size'`/`'overlap'`).
  Panelet: «utelatt: retning låst — i den låste retningen ville kapitlet overlappet en nabomatte (Regel 27); med
  auto-retning prøves den andre». Varselet i `_matChapterBlock` sier det samme.
- **E · Snapp innover.** `snapToWalls` får `inner(side)`: en kant inne i rommet, innenfor én celle fra en ortogonal
  vegg på utsiden, snappes til veggen når veggen (summen av kollineære veggstykker) dekker hele kanten (≥ kantlengde
  − 1 cm) og prøvepunktene sier rommet ligger på innsiden av veggen og fortsetter fra kanten til veggen. Sonegrenser
  (delvis vegg: T-rommets hoveddel over stammen) røres ikke. Kjøres etter 135-snappen (utover), per rektangel.
- **Tester.** `_matRotationRegressionTest` 35 → **39** (A: estimatet på 900 × 300/rect #10 tørt, auto-retning
  'h'/'v'/'h', 1110 tie-break), `_matChapterRegressionTest` 22 → **25** (B: T-rom beholder 28 m med stubb 16, 24 m
  som equalLess (tap 4 m ≥ trinn 2 m); syntetisk katalog i fine trinn: tap = trinn → beholdt; D: låst 'v' + inntrenger
  → ett varsel «retningen er låst», `dirLocked`; E (auto): to varsler som i 134; E-snapp: H-broa 203,300,497,500 med
  6 × 192, Kenneth L-rom eksakt, T-rommets hoveddel-underkant urørt), `_matCrossFillRegressionTest` 30 → **32**
  (variant A beholder 26 m med stubb 8 tverr, 24 m som equalLess, 13,0 m²; dryRun-biten har tverrstykker; D 20 m
  beholdt, 10,0 m²; C: auto-retning → null/S.mats 7 × 288 9,96 m²; katalog 16/18 m → null/S.mats 5 × 360 9,0 m²).
  `_matZoneRegressionTest`: alkoven snappet til veggen → start y 4 (var 3), oppdatert.

### Før / etter per punkt

| Punkt | Rom | Før (`82131aa`) | Etter 136 |
|---|---|---|---|
| A | 900 × 300, 100T, auto | 'v' (estimat 24,5 mot 22,2): 24 m, 10 × 240, **12,0 m²** | **'h'**: 30 m, 5 × 600, **15,0 m²** (`136-A-900x300-auto-*`) |
| A | 300 × 900, 100T, auto | 'h' 12,0 | **'v' 15,0** |
| A | rect #10 420 × 259, 150T | 'h' 10,0 | 'h' 10,0 (uendret) |
| A | benkens 35 rektangler | auto = beste levering i alle | **ingen retning endret** |
| A | grense-minlengde #51 232 × 113, InSnow (vei 3) | 'v' 4 × 112 = 336 av 400 cm, 64,1 % | **'h' 2 × 208 = hele 4 m-rullen, 76,3 %** |
| B | 1108 / Kenneth L-rom (150T) | 24 m, 12,0 m² (77,6 %), 26 m som alternativ | **26 m, 13,0 m² (84,1 %)**, gul «stubb på 8 cm», 24 m som «nest største» (`136-B-kenneth-lrom-*`) |
| B | L #23 | 12 m, 6,0 (69,0 %) | **14 m, 7,0 (80,5 %)** |
| B | hindring #26 | 16 m, 8,0 (75,8 %) | **18 m, 9,0 (85,3 %)** |
| B | hindring #27 | 24 m, 12,0 (79,0 %) | **26 m, 13,0 (85,6 %)** |
| B | T-rom 600 × 200 + stamme (100T), Σ 29,76 | 24 m, 12,0 | **28 m, 14,0**, stubb 16 cm gul, 24 m som nest største (tap 4 m ≥ 2 m) |
| B | variant A 300 × 380 + alkove (100T), Σ 26,40 | 24 m, 12,0 | **26 m, 13,0** (stubb 8 cm i stykke 2), 24 m som nest største |
| C | 300 × 400 «fra vegg», 100T, auto ('h') | kapittelbane 7 × 288 + 5 × 24 planlagt, 20 m, stykkene utenfor, 10,0 | **S.mats** 7 × 288 (siste 264), 9,96 m² — bit-identisk med før 134 |
| C | samme, 'v' låst, 100T | 18 m (134 / B), stykkene utenfor, 9,0 | 20 m beholdt (B), 1920 + 24 ≤ 2000 → **kapittelbane, 10,0 m²** med 3 hele stykker + 8 cm |
| C | samme, 'v' låst, katalog 16/18 m (syntetisk) | — | null → S.mats 5 × 360, 9,0 |
| C | benk, rektangler × 4 fra-vegg-varianter (148 rader) | 16 zone / 80 single / 52 multi | 12 zone / 84 single: **2 rom bytter vei** (rect #9 5,0 → 4,96; smal #38 1,0 → 0,96 — bare «fra vegg»-variantene; benkens hovedrader uendret) |
| D | bilde 2, 'v' låst, matte 2 cm inn i alkoven | «prøver den andre retningen» → 'h' overlapper også → utelatt (2 varsler) | **utelatt direkte**, ett varsel «retningen er låst», panel «utelatt: retning låst» (`136-D-laast-v-panel-*`) |
| D | samme, auto | 2 varsler, utelatt | uendret (134 / E) |
| E | H-rom bro | 203,301,497,497 → 150T 6 × 176 / 100T 'h' 3 × 288 | **203,300,497,500** → 150T **6 × 192**, 100T 'v' 6 × 192 (`136-E-hrom-utlegg-*`) |
| E | Kenneth L-rom / 1102 / T-19 / U-22 | 300,0,498,198 / 896 + 296,696 / 462,567 / 784 | **300,0,500,200 / 900 + 300,700 / 464 / 786** — T-rommets 567 (delvis vegg) står |
| E | hindring #31 (275 × 386) | rekt. y1 384 → 320 + 4 × 336, 16 m, 78,3 % | y1 386 → 5 × 336, Σ 18,08, **18 m, 88,1 %** |
| E | hindring #30 | 94,5 % | 94,5 % (rekt. 516 → 518, samme bredder flyttet 2 cm — poengene endret) |

### Test (prompten)

| # | Krav | Resultat |
|---|---|---|
| 1 | A: 900 × 300 100T auto → 'h' 15,0; rect #10 → 'h' 10,0; 300 × 900 → 'v' 15,0; rektangler med estimat = levering uendret | Ja, alle tre. Benkens 35 rektangler: ingen retning endret (tie-break på Regel 8-tallet). Låst i `_matRotationRegressionTest`. |
| 2 | B: de fem benkrommene tilbake på største rull med gul stubb der tapet var over ett trinn; under ett trinn fortsatt nest største | Alle fem taper nøyaktig ett trinn (2 m) → ikke under → tilbake på største rull (tabellen). «Under ett trinn» finnes ikke i benken — med like ruller er tapet alltid K × trinnet (K ≥ 1), så bare en blandet plan med en finere rull under den største kan havne under; låst syntetisk (tap = trinn → beholdt). Se SPØRSMÅL 136-1. |
| 3 | C: 300 × 400 «fra vegg» 100T → S.mats 5 × 360 som før 134; 150T → kapittelbane 10,0 | Bestillingens tall forutsatte 134 / B (18 m): med B fra 136 beholdes 20 m også for 100T, stykkene kommer med (19,20 + 0,24 ≤ 20) → kapittelbane 10,0 m² med stubb — og 150T likeså (20 m, 10,0). Regelen selv er låst to veier: auto-retning ('h', stykkene utenfor) → null/S.mats 7 × 288, og 'v' med katalog 16/18 m → null/S.mats 5 × 360 (9,0) som før 134. 2 benkrom bytter vei. Se SPØRSMÅL 136-2. |
| 4 | D: låst 'v' + sone som avvises → utelatt med melding; auto → andre retning | Ja (`136-D-laast-v-panel-etter`): «utelatt: retning låst», ett varsel; auto: to varsler, 134 / E uendret. Låst. |
| 5 | E: H-broa 300–500 → bredder 192; T-19/T-20/U-22 lovlige; folie uendret | Ja: 203,300,497,500, 6 × 192. T-19/T-20/U-22 vei 1/2 lovlige (ulovlige 30 → 30, alle vei 4 / syntetisk). `_foilRegressionTest` 9/9. |
| 6 | Mattebenk opp i 'v'-rom med Regel E-avvik, de fem B-rommene, E-rom; ingen lavere uten forklaring; batterier | 224 rader: 209 uendret, **13 høyere** (fem B-rom × 2 veier, hindring #31 × 2 (E), grense-minlengde #51 vei 3 (A, InSnow)), **0 lavere**, 2 «annet» (hindring #30 poeng, E), 0 nye ulovlige. 'v'-rom med Regel E-avvik finnes ikke i benken (auto var alt beste). Tid 163 → 159 ms (vei 1 40 → 42 ms = +5 %, vei 2 30 → 30). Batterier: `_matRegressionTest` 2/2 · `_matZoneRegressionTest` 17/17 · `_matChapterRegressionTest` **25/25** · `_matCrossFillRegressionTest` **32/32** · `_matRotationRegressionTest` **39/39** · `_matFreeRegressionTest` 36/36 · `_matPathClickRegressionTest` 28/28 · `_matRunAdjustRegressionTest` 70/70 · `_matArrangementRegressionTest` 55/55 · `_foilRegressionTest` 9/9 · `_pdfExportSmokeTest` 20/20. Ingen konsollunntak. |

### Mattebenk-differansen (`_matBench(42, 64)`, før = `82131aa`, etter = 136; vei 1 = vei 2)

| Rom (150T, auto, 1 cm) | Dekning før → etter | Rull før → etter | Hvorfor |
|---|---|---|---|
| 1108 Garderobe / Kenneth L-rom | 77,6 → **84,1 %** | 24 → 26 m | B: tapet (2 m) er ett trinn — største beholdes, stubb 8 cm gul |
| L #23 | 69,0 → **80,5 %** | 12 → 14 m | B |
| hindring #26 | 75,8 → **85,3 %** | 16 → 18 m | B |
| hindring #27 | 79,0 → **85,6 %** | 24 → 26 m | B |
| hindring #31 | 78,3 → **88,1 %** | 16 → 18 m | E: sonerektangel 384 → 386 → 5 × 336 (var 320 + 4 × 336), Σ 17,92 → 18,08 |
| grense-minlengde #51 (vei 3, InSnow) | 64,1 → **76,3 %** | 4 m → 4 m | A: 'v' 4 × 112 (336 lagt) → 'h' 2 × 208 (hele rullen) |
| hindring #30 | 94,5 → 94,5 | 36 → 36 m | E: rektangel 516 → 518, breddene flyttet 2 cm (poeng 9152 → 8902) |

Alle 12 Regel H-«forsøkstaket»-meldingene i konsollen er de samme før og etter (vei 4 / sone-rom gjennom
`autoFillMatSerpentine` i benkens standalone-sjekk) — ikke rørt.

### Skjermbilder
`136-A-900x300-auto-{foer,etter}`, `136-B-kenneth-lrom-panel-{foer,etter}`, `136-B-kenneth-lrom-utlegg-{foer,etter}`,
`136-D-laast-v-panel-{foer,etter}`, `136-E-hrom-utlegg-{foer,etter}`, `136-bench-{before,after}.json`.

### Funn utenfor scope (ikke rettet)

- **Fallbackens korte siste bredde vrakes når den ikke er på rasteret** (STEG 0.1): 28 m i 900 × 300 'v' gir
  16 × 168 + 112, men `_matClipRunToRoom` flater 112 til 96 og vraker under minstelengden 100 — bredden legges som
  0 og Regel H går ned en rull. Regel 24 sier «siste tar resten»; en 112 cm bredde er ikke under ett
  kuttintervall. Estimatet speiler oppførselen (A), så velgeren er riktig uansett — men selve nedgangen kan være
  en feil i motoren. SPØRSMÅL 136-3.
- **Delvise vegger snappes ikke** (E): T-20s hoveddel ligger 2 cm fra veggen i y, men veggen dekker bare sidene av
  stammen (505 av 712 cm) — kanten er både vegg og sonegrense, og røres ikke. Stammens kapittel utvider seg inn
  i hoveddelen uansett (Regel 27), så tapet er 2 cm × sidene. L-16, L-18, T-19, T-21 likeså (1–3 cm).
- **A i flermatte-domenet:** retningen estimeres med én rull også der kapasiteten overstiger største rull
  (`_matFillRoomSmart` → `_matMultiSolve`). I benken ga det bare uavgjort → Regel 8-tallet → uendret (2104, Obs Bygg,
  stor #40–47). SPØRSMÅL 136-4.
- **Panelet** har nå inntil seks rull-rader (like/blandet × valgt/største/nest største) når alle tre finnes og er
  ulike; dedupliseres parvis som i 135 / F.

### Skal IKKE — holdt
133-konvensjonen, frihånd-tegningen og panelene utover merknadene (gul stubb, «nest største»-rad, «retning
låst») er urørt. Ikke pushet.

### Verifiseringsmetode
Headless Chrome (CDP, port 9336, egen fane per skript) mot `serve-varmeplan.js` på 4000 (ny) og
`python -m http.server` på 4002 (`82131aa`) uten innlogging — harness i `/tmp/cdp136/` (`cdp.mjs`, `setup130.js`,
`steg0.mjs` (A/B/C/E målt på begge versjoner → `steg0-4002.json` / `steg0-4000.json`), `probeA.mjs` (Regel E/H-
forsøkene logget), `probe2.mjs` (benkdifferansen forklart), `pathswitch.mjs` (C: 37 rektangler × 4 fra-vegg-
varianter på begge versjoner), `tests.mjs`, `bench.mjs` + `diff.mjs` (radnivå, med tid), `shots.mjs` (panel +
utlegg på begge porter)). Utlegg via `_matFillRoomSmart`/`autoFillMatSerpentine` og ekte «Legg ut»-klikk.

### Endringslogg (kode, alt i `index.html`)
- Nye: `_matDirCoverEstimateCm`, `_matVariantRollLensCm`, `inner` (inne i `snapToWalls`).
- Endret: `_matAreaGeom` (`ctx.rollLensCm`/`ctx.equalWidths`, `_covE` + tie-break), `_matRoomGeomForFill` og
  `autoFillMatSerpentine` (sender rullene), `_matChapterRollPlans` (`stepBelow`, `equalLess`/`mixedLess`/
  `…LessLossCm`/`…StepCm`), `_showMatZoneProposalPanel` (gul stubb-note, «nest største»-rader, `equalLess`/
  `unequalLess` i commit, «retning låst»-note), `_matPlanZones` (`userDir`, `dirLocked`, `reason`, C-vakten),
  `_matChapterBlock` (varseltekst), `_decomposeRoomToRects` (`snapToWalls` innover), `_matZoneRegressionTest`,
  `_matChapterRegressionTest`, `_matCrossFillRegressionTest`, `_matRotationRegressionTest`.
- Spec `spec-matte-utlegg.md` (Cowork-mappa): 136-notat under Regel 8 (velgeren estimerer med Regel E), Regel 20
  (snapp innover), Regel 24 (ett trinn, gul stubb), Regel 27 (lås vinner), Regel 29 (rektangel bare når stykkene
  kommer med).

Commit: «136: matte — svar serie-133 (motor): velgeren estimerer med Regel E, stubbvalg bare innen ett rulltrinn
(ellers gul stubb), rektangel til kapittelbane bare når stykkene kommer med, retningslås vinner, soner snappes til
veggen». **Ikke pushet.**
