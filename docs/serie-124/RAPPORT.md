# 124 — Matteutlegg: start følger velgeren, mellomrom før utlegg, én bredde kan justeres

Kjørt 23.10.2026 på `main` fra `b750c70`. Pushet som `e3b5904`. Spec: Regel 26 i `spec-matte-utlegg.md`.
Skjermbilder i `skjermbilder/` (headless Chromium, 400 × 300-rom, EcoMat 150T fra mattebenkens katalog).

## STEG 0 — målt før endring

### 0.1 Velgeren mot faktisk utlegg (400 × 300, «Fyll rom»)

«Første bredde» = bredden kabelen starter i. «Start» = hjørnet den grønne markøren står i.

| Velger (hjørne + retning) | Forventet første bredde / start | Før: første bredde / start | Etter |
|---|---|---|---|
| nede venstre, opp (bl/v)   | venstre / nede venstre | venstre / nede venstre | ✓ |
| oppe venstre, ned (tl/v)   | venstre / oppe venstre | venstre / **nede venstre** | ✓ |
| nede høyre, opp (br/v)     | høyre / nede høyre     | **venstre / nede venstre** | ✓ |
| oppe høyre, ned (tr/v)     | høyre / oppe høyre     | **venstre / nede venstre** | ✓ |
| nede venstre, høyre (bl/h) | bunn / nede venstre    | **topp / oppe venstre** | ✓ |
| oppe venstre, høyre (tl/h) | topp / oppe venstre    | topp / oppe venstre | ✓ |
| nede høyre, venstre (br/h) | bunn / nede høyre      | **topp / oppe venstre** | ✓ |
| oppe høyre, venstre (tr/h) | topp / oppe høyre      | topp / **oppe venstre** | ✓ |

Før fulgte bare ankringen mot vegg (DEL C 12.09) velgeren; kabelrekkefølgen var alltid «r stigende,
start i høy along-ende». Etter: alle 8 stemmer (regresjonstesten sjekker alle 8 + en matte uten
`startCorner`, som tegnes som før). Skjermbilder `02` (bl/v) og `03` (tr/h).

### 0.2 Startmarkør
Matta hadde en **sort** kaldskjøt-strek (~8 cm) ved start og en sort prikk ved slutt, på skjerm og i
PDF (PDF-eksporten gjenbruker `drawMats` i `_pdfMode`). Kabelens grønne «S»-rombe / oransje «E» tegnes
bare for en valgt kabel (`drawCables`). Nå: **grønn** start (strek + prikk) og **rød** slutt på matte og
frihåndsmatte, alltid, også i PDF (skjermbilde `06`).

### 0.3 Mellomrom
Folie har ikke noe mellomrom-felt i produktpanelet; `gap-mm-input` (≈ :36237) er popup-panelet
`openGapPanel` fra ctxbar-chippen «⟷ N mm» / rom-høyreklikk, som skriver `setRoomGap`. Matte hadde
tilsvarende popup `openMatGapPanel` fra chippen «↔ N cm» på en *valgt* matte, som skriver
`S.varmematte.gapCm` via `setMatGap`. Endring **etter** utlegg: den lagte matta beholder `gap_cm`
(målt: felt 3 → 7 → matta står på 3); bare en aktiv forhåndsvisning (snø / UPC-variant) pakkes om.
Verdien brukes ved neste utlegg. Uendret.

### 0.4 Tegning og treff
`drawMats`: senter + rotasjon; bredde r på lokal x = −totalW/2 + w/2 + r·(w+gap), lengde/start fra
`_matRunLenCm`/`_matRunStartCm`. `hitMat`: invers transform, men leste **produktets `min_gap_mm`**
i stedet for mattas `gap_cm` og hele **nominelle** lengden — en klippet bredde kunne treffes der den
ikke var tegnet — og ga bare matte-id. Nå `hitMatRun` → `{ id, r }` fra samme geometri som tegningen.

### 0.5 Dekker, W/m² og materialliste
- «Dekker»/lagt lengde: `_matLaidLengthCm` (sum av `runLengths`, ellers (n−1)·L + siste) → ctxbar
  «19,5/20,0 m» og materiallista. Leser geometri.
- W i ctxbar: `W/m² × n × bredde × L` (nominell). Leser produktet; uendret av justering.
- Label-linja (`_matLabelInfoLine`): W delt på dekket areal — **stiger** når en bredde kortes
  (150 → 154 W/m² i skjermbilde `05`). Spørsmål til Kenneth under.
- Frihånd: `_matFreeCatalog` velger rull fra tegnet lengde (nå nominell, Regel 17), «Dekket areal»
  fra geometri (`_matFreeCoveredAreaM2`).

## Gjort

**A.** `_matRunOrder(mat)` / `_matRunCableOrder` / `_matRunStartIsHigh` leser `mat.startCorner`
(lagres av `autoFillMatSerpentine` og `_matPlaceMultiMats`). `_matCablePlan` tar breddene i
kabelrekkefølge og speiler inn-/utside (`_matCableEntrySide`); `_matRunsWithinRoom` slår opp på
`run.r`. Lagringsrekkefølgen (`r = 0` nærmest lav tverr-kant) og klippingen er urørt. Grønn/rød markør.

**B.** `_matGapFieldHtml()` («Mellomrom ▼ 3 ▲ cm») i `_upcRenderMatResults`, over «Fyll rom
automatisk». Samme `setMatGap`/`stepMatGap`/`mat-gap-cm-input` som chippen etter utlegg;
`_matGapFieldState()` er den ene kilden til grenser og visningsverdi. Skjermbilde `01`. Målt: 3 cm
før utlegg → breddene ligger 3 cm fra hverandre, chippen viser 3.

**C.** Datamodell `mat.runAdjust[i] = { acrossCm, startCm }` og `moves[i].shiftCm / startCm`.
`_matRunLenCm` = base − startCm; `_matRunStartCm` flytter starten når bredden starter i lav ende;
`_matRunAcrossOffsetCm` brukes av tegning, treff, vakt og målsetting. `_matRunWorldGeom` gir
verdensgeometri per bredde (håndtak, rødmerking). Frihånd: `_matFreeDeriveRuns` justerer bare den
utleverte banen, kjeden går videre fra nominell bane (naboene står stille); `_matFreeCatalog` velger
rull fra nominell lengde. Valg: klikk på bredde i valgt matte (`S.ui.selectedMatRunIdx`), Esc velger
bort. Drag: delta fra grepspunktet, snapp 5 cm, Shift glidende; S-håndtak for start. Piler: på tvers
= sidelengs, langs = start (5 cm, Shift 1 cm). Panel i ctxbar med «Start +cm» og «Nullstill». Gul
merknad under minste lengde, rød kant + merknad utenfor rom / over hindring — uten sprett.
Kuttlinjer tegnes nå bare innenfor breddens faktiske utstrekning. Fire rader i hurtigtast-panelet.

## Test

| # | Krav | Resultat |
|---|---|---|
| 1 | 4 hjørner × 2 retninger, startmarkør skjerm + PDF | ✓ tabellen over, `_matRunAdjustRegressionTest` A-delen, skjermbilde `06` |
| 2 | L-rom med soner, flermatte, benk | `_matRegressionTest`, `_matZoneRegressionTest` grønne; mattebenk 224 rader: 224 like, 0 dårligere |
| 3 | 3 cm før utlegg | ✓ målt (gap_cm 3, felt viser 3 etterpå) |
| 4 | hjørne 2 cm inn, ← én gang, naboer stille, Shift, grip 2 cm | ✓ test + skjermbilder `07`/`08`; «dra 2 cm → 0, 3 cm → 5, Shift → 2,8» |
| 5 | start +50: 50 cm kortere, slutt fast, produkt/W uendret, Dekker mindre, gul merknad | ✓ test + skjermbilde `05` (288 → 238 cm, 20,0 → 19,5 m, 1512 W uendret) |
| 6 | samme på frihånd | ✓ test + skjermbilde `10` |
| 7 | angre, lagring (JSON-rundtur), flytt hele matta, nytt utlegg nullstiller | ✓ test |
| 8 | PDF | `_pdfExportSmokeTest` grønn, `06` |
| 9 | `_matRunAdjustRegressionTest()` | 70 sjekker grønne; alle matte-batterier + `_matPathClickRegressionTest` grønne |

Merk om test 4: en 2 cm-tapp i endeveggen gjorde *hele* utlegget kortere (Regel 6: like bredder, L
288 → 240) i stedet for å klippe én bredde; det er dagens utlegg og ikke rørt. Bredde 3 flyttes 5 cm
mot venstre, naboene står, ingen rød merknad. Rødmerking er vist i skjermbilde `09` (bredde 1 40 cm
utenfor).

## Avvik fra prompten (bevisste)
- **Piler langs bredden** flytter starten direkte (ingen egen «håndtaket er valgt»-tilstand);
  Shift + pil = 1 cm på begge akser. Enklere, og tallfeltet «Start +cm» finnes i tillegg.
- `acrossCm` er positiv langs mattas **lokale tverrakse** (+x for loddrett, +y for vannrett matte),
  ikke «mot høyre i leggeretningen». Tastatur og drag bruker samme akse, så det merkes ikke.
- `_matPathClickRegressionTest` starter nå hvert klikk fra uvalgt matte: et andre klikk på en valgt
  frihåndsmatte velger nå en bane (Regel 26), ikke hele matta. Hele matta flyttes fortsatt med første
  klikk-og-dra, eller etter Esc.
- Sidelengs flytting klipper **ikke** bredden på nytt (står som avgrensning i Regel 26).

## Funn utenfor scope (ikke rettet)
1. **Vannrett matte (rotation 90) har to koordinatkonvensjoner.** `autoFillMatSerpentine` setter
   `matY = acrossCenter − L/2` og klipper/vokter med `perpBase = y_cm`, `alongStart = x_cm`, mens
   `drawMats` tegner bredde r på y = (y_cm + L/2) − totalW/2 + r·(w+gap). I et 900 × 300-rom med
   «h» ble 2 av 5 bredder klippet til 0 (perpPos −154/−100, utenfor rommet) selv om tegningen lå midt
   i rommet. `_matPlaceMultiMats` bruker den andre konvensjonen (`matX = alongCenter − L/2`), og
   `_clampMatToRoom` ignorerer rotasjon. 400 × 300 går bra ved et slumpetreff. Bør få en egen prompt.
2. **br/h og tr/h velger mindre rull** enn bl/h og tl/h i samme rom (L 240 mot 320, 5 bredder):
   identisk før og etter, rotårsak er along-ankringen i høy ende (DEL B-notatet i koden).
3. **Label-W/m²** stiger når en bredde kortes (W konstant, areal mindre). Riktig fysikk for en
   fastlengde-rull, men Kenneth bør si om labelen skal vise produktets W/m² i stedet.

## Spørsmål til Kenneth
- Skal en bredde som ble kortet av et hjørne ved utlegget kunne **forlenges** igjen etter at den er
  flyttet forbi hjørnet (en «slutt»-justering i tillegg til start)? Det er ikke bygget.
