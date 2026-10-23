# 127 — Matte: flytt hele arrangementet (alle matter i rommet) og mellomrom per valgt matte

Kjørt 23.10.2026 på `main` fra `4df9d57`. **Ikke pushet.** Spec: Regel 9 (mellomrom), Regel 12 (margin),
Regel 26 (124). Skjermbilder i `skjermbilder/` (headless Chrome, 400 × 300-rom, EcoMat 150T fra
mattebenkens katalog, 2 auto-matter + 1 frihånds-matte).

Kenneth (23.10.2026): «Jeg ønsker å kunne markere en matte og flytte hele arrangementet. Jeg ønsker å
kunne markere en matte og velge avstand mellom breddene på den valgte matten.»

**Tolkning:** «hele arrangementet» = alle matter i samme rom (auto-matter og frihånds-matter), flyttet
som én enhet med innbyrdes avstand uendret. Se SPØRSMÅL nederst.

## STEG 0 — målt før endring (gammel fil servert på port 4300)

### 0.1 Mellomrom-feltet på en valgt, lagt matte
Målt: matte med `gap_cm` 4 valgt, `setMatGap(7)` (det feltet/chippen kaller). Etter: chippen viser
«↔ 7 cm», `S.varmematte.gapCm` = 7, **matta står på 4**. Feltet endret altså bare neste utlegg (og en
eventuell aktiv forhåndsvisning via `_upcPlaceMat(..., 'variant')`) — aldri den lagte matta. Samme
som 124 STEG 0.3 målte.

### 0.2 Hvilken funksjon legger én mattes bredder på nytt?
Ingen. `autoFillMatSerpentine` lager alltid et **nytt** mat-objekt (ny id, velger variant på nytt, leser
`S.ui.selectedRoomId` og de globale `S.varmefolie.direction/startCorner`), og kan ikke legge om én
eksisterende matte uten å slette den. Den mindre biten som trengs — klippingen av **én bredde** mot
rom/hindringer/sone — var løkkekroppen i motoren (STEG 1 / Regel A / Regel H). Den er nå trukket ut
**uendret** til `_matClipRunToRoom(p)` og brukes av både motoren og den nye omleggingen, så de aldri
kan klippe ulikt. Mattebenken bekrefter: 224 rader, ingen endring i noen kolonne unntatt `ms`.

### 0.3 runAdjust, runStarts/runLengths og «Dekker» ved endret mellomrom
Før var det ikke noe «ved endret mellomrom» — `gap_cm` ble aldri skrevet etter utlegg. `runAdjust`
nullstilles bare ved nytt utlegg (nytt objekt). `runStarts`/`runLengths` er absolutte verdenskoordinater
langs mattas akse (108-tabellen), satt av motorens klipp. «Dekket areal» (`_matLaidLengthCm`) summerer
`runLengths` når de finnes, ellers nominelt — så en omlegging som skriver nye `runLengths` gir riktig
«Dekker» uten mer kode.

### 0.4 Hvordan flyttes én matte i dag?
Mousemove-grenen for `_matDragKind === 'mat'` skriver bare `mat.x_cm/y_cm` (+ klamp og magnet).
**Målt funn (ikke rettet, utenfor scope):** på en romform-klippet matte (`runStarts` satt) flyttet et
drag på 30 cm `y_cm` fra 55 til 25, men `runStarts` ble stående på `[55,55,55,55,55]` — tegningen
leser `runStarts` absolutt (`_matRunStartBaseCm`), så breddene blir liggende igjen langs dragaksen
mens blokka og etiketten flytter seg. 108-tabellen advarte om nettopp dette («Glemmes de, blir en
romform-klippet matte liggende igjen»). Flyttingen fra 108 (`_ROOM_TRANSLATE_SPEC` → `mats`:
`x_cm/y_cm` + `runStarts` + `labelPos`; `matPaths`: `start` + `labelPos`) tar alt med, og
`_applyRoomMoveSnapshot` kan skrive flere objekter fra samme startbilde — brukt rett fram her.

## Gjort

### 1. Flytt hele arrangementet
- Chip **«Flytt alle matter i rommet»** i ctxbar for valgt matte og valgt frihånds-matte slår på
  arrangement-modus (`_matArrangeMode`, UI-tilstand, lagres ikke). I modus flytter ethvert grep i en
  matte, bredde, gizmo-pil (akselås X/Y) eller frihånds-bane i rommet **alle** matter og frihånds-
  matter i rommet. Modusen slås av med chippen eller når ingen matte er valgt lenger.
- **Alt + dra** på en matte gjør det samme uten modus. Alt + venstre var panorering — nå sjekkes
  matte-treff først; Alt + dra **utenfor** en matte panorerer som før (testet).
- Ny drag-type `_matDragKind = 'matarr'`: startbilde via `_snapshotRoomForMove(roomId, ['mats',
  'matPaths'])` (ny valgfri `keys`-parameter; rommet selv tas ikke med), hvert musesteg skriver
  «original + delta» med `_applyRoomMoveSnapshot` — ingen ny løkke per felt. Rutenett-snap mot det
  grepne objektets eget anker, akselås som for én matte, delta fra startbildet (108).
- Frihånds-matte: et «Sentrer»-offset foldes inn i `start` ved dragstart og `centered` slås av, som
  en enkelt-flytting gjør.
- Slipp: validering som for én bredde (124): `_matRunPlacementIssue` per bredde og
  `_matPathMoveValid` per bane → rød toast «Flyttet, men: …», breddene i rammede matter rødmerkes i
  tegningen (`mat._arrCheck`, vist av `drawMats`). **Ingen sprett.** Ett `pushUndo` per drag.
- Ny rad i `_SHORTCUTS`: «Alt + dra — Flytt alle matter i rommet sammen».

### 2. Mellomrom for den valgte matta
- Når en lagt matte med ≥2 bredder er valgt, viser feltet **mattas eget** `gap_cm` med etiketten
  «Mellomrom i denne matta» — i produktpanelet (`_matGapFieldHtml` bytter gren), i objektinfo-panelet
  (ny rad) og som ctxbar-chip med popup (`openMatOwnGapPanel`). Endring (felt/▲▼/popup) kaller
  `_matRelayWithGap(mat, cm)`:
  - samme produkt, antall bredder, hjørne/retning (`startCorner`/`rotation_deg`) og sone
    (`mat.zoneId` → samme along-grenser som Regel 20 ga ved utlegget),
  - **første bredde i kabelrekkefølgen** (`_matRunCableOrder`) ligger fast — blokkstarten flyttes
    `−rFirst × Δgap` så ankerbreddens tverrposisjon er uendret; de andre flytter seg,
  - klipp mot rom og hindringer regnes på nytt per bredde med `_matClipRunToRoom` (Regel A:
    `runStarts`/`runLengths` fra samme klipp),
  - bredder som ikke får plass (på tvers: utenfor rommets boks minus margin; langs: ingen fritt
    segment) legges ikke ut (`runLengths[r] = 0`, som motoren selv gjør) og telles i
    `mat._gapDroppedRuns` → gul merknad «N bredder får ikke plass med X cm mellomrom» i ctxbar,
    objektinfo og som toast,
  - `runAdjust` (124) nullstilles, toast «Justeringer på breddene er nullstilt» når det fantes noen,
  - `_coldTotalCm` justeres, `_gapCappedFromCm` nullstilles. Andre matter i rommet røres ikke.
- Grenser: produktets Regel 18-gulv (0 EcoMat / 5 InSnow) … `MAT_GAP_MAX_CM` (= 10 cm i dag).
- Uten valgt matte er feltet globalt som før (`setMatGap` → neste utlegg).
- Frihånds-matte: chippen og popup-tittelen heter nå «Mellomrom i denne matta», og raden i
  sidepanelet (`_matPathPanel`) likeså — samme ord og plassering som auto-matte. Virkemåten (`mp.gapCm`)
  er uendret.

## Funn og avvik (målt)

| # | Funn | Håndtering |
|---|---|---|
| 1 | `clipStripToRoom` godtar en bredde som bare **delvis** ligger innenfor rommet på tvers (klipper kun langs). Målt: tverrposisjon 380 i et 400 bredt rom ga segment 5–295. Motoren merker det aldri (legger aldri flere enn `maxRuns`). | Eksplisitt tverr-sjekk i `_matRelayWithGap` (rommets boks ± margin, eller sonens boks) før klipp. |
| 2 | Enkelt-matte-drag flytter ikke `runStarts` (STEG 0.4). | Ikke rettet — eget funn. Arrangement-flyttingen bruker 108-veien og er riktig. |
| 3 | Vannrett matte (rotation 90): motoren/vakten (`perpBase = y_cm + r·(b+gap)`, along fra `x_cm`) og tegningen (rotasjon om boksens senter) har ulik konvensjon — kjent fra 124. | Ankeret holdes i motorens konvensjon (samme som klipp og vakt). På skjermen vil første bredde i en vannrett matte forskyve seg Δgap/2. Trenger den egne prompten 124 ba om. |
| 4 | `MAT_GAP_MAX_CM = 10` — testens «12 cm» klemmes til 10. I 400-rommet med 7 × 50 cm gir alt over 6 cm én bredde som faller ut, så gul merknad er testet med 8 og 10 cm. | Ingen endring av taket. |
| 5 | Når en bredde faller ut, står etikettens «W/m² flate» høyere (rullens W over mindre dekket areal) — samme som for en klippet bredde i dag. | Ingen endring; merknaden sier hvorfor. |
| 6 | Alt + venstre var panorering. | Alt + dra **på** en matte = flytt alle; ellers panorering som før. Rad i hurtigtast-panelet. |

## Test

| Nr | Krav | Resultat |
|---|---|---|
| 1 | 2 auto-matter + 1 frihånd: «Flytt alle» og dra 40 cm → alle tre +40, innbyrdes avstand lik; Alt + dra uten modus; angre | ✓ test A/B (40 cm x, 30 cm y, `runStarts`/`labelPos` følger med, ett pushUndo, angre bit-for-bit). Skjermbilder `04`–`06`. |
| 2 | Velg én matte, mellomrom +3: bare den legges om, anker fast, naboer urørt; «Dekker» og klipp stemmer; stort mellomrom → gul merknad | ✓ test C (anker-quad identisk, nabo-bredde b+gap+3 fra ankeret, matte 2 og frihånd JSON-identiske, `_matRunsWithinRoom` sann, ingen bredde med plasseringsmerknad; maks mellomrom → 1 bredde ut + merknad + toast; tilbake til 4 cm = alle bredder bit-for-bit som før). Skjermbilder `01`–`03`. |
| 3 | Ingen matte valgt: globalt felt som før | ✓ test D (`_matGapFieldHtml` uten «i denne matta», `setMatGap(7)` rører ikke matta). |
| 4 | runAdjust nullstilles med toast | ✓ test C (angre gir både mellomrom og justering tilbake). |
| 5 | Lagre/åpne: `gap_cm`, posisjoner, merknad består; PDF | ✓ JSON-rundtur (test E); `_pdfExportSmokeTest` grønn (PDF bruker `drawMats`). |
| 6 | Regresjon | `_matRegressionTest` ✓, `_matRunAdjustRegressionTest` 70/70 ✓, `_roomMoveRegressionTest` 42/42 ✓, `_matZoneRegressionTest` ✓, `_pdfExportSmokeTest` 20/20 ✓, mattebenk 224 rader: ingen endring unntatt `ms`. Ny `_matArrangementRegressionTest()` **55/55** ✓. |

Verifiseringsmetode: `node --check` på inline-scriptet; headless Chrome (CDP, port 9333) mot
`serve-varmeplan.js` på 4000 (ny) og 4300 (gammel fil fra `HEAD`), uten innlogging (skylagring stubbet),
testene kjørt som globale funksjoner med lerretet synlig.

## SPØRSMÅL til Kenneth

1. **«Hele arrangementet»** er tolket som *alle matter og frihånds-matter i samme rom*. Mente du
   noe annet — f.eks. bare mattene som ligger inntil hverandre (gruppa), eller alt i rommet inkludert
   folie/kabel?
2. Skal enkelt-matte-draget (én matte) også ta med `runStarts` (funn 2)? I dag blir en klippet mattes
   bredder liggende igjen langs dragaksen.

## Endringslogg (kode, alt i `index.html`)

- `_matClipRunToRoom` — ny; løkkekroppen fra `autoFillMatSerpentine` (uendret), motoren kaller den.
- `_matRelayWithGap` — ny; omlegging av én matte med nytt mellomrom.
- `_matOwnGapSelected/_matOwnGapBounds/_matOwnGapNoteText/_matOwnGapFieldHtml/setMatOwnGap/
  stepMatOwnGap/openMatOwnGapPanel` — nye; `_matGapFieldHtml` bytter gren ved valgt matte.
- ctxbar (matte og frihånd): chip «Mellomrom i denne matta» + «Flytt alle matter i rommet»; gul merknad.
  Objektinfo-panelet: rad «Mellomrom i denne matta» + merknad. `openMatPathGapPanel`/`_matPathPanel`: etikett.
- `_matArrangeMode/_matArrSnap/_matArrRoomId`, `_matToggleArrangeMode/_matArrWants/_matArrBegin/
  _matArrDelta/_matArrMove/_matArrEnd` — nye; mousedown (Alt-gren før panorering, gizmo, bredde,
  matte-kropp, frihånds-bane), mousemove/mouseup (`'matarr'`), `drawMats` (`_arrCheck`).
- `_snapshotRoomForMove(roomId, keys)` — valgfri filtrering.
- `_SHORTCUTS` — ny rad. `_matArrangementRegressionTest` — ny.
