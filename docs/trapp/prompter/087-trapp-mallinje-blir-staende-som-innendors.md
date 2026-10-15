# 087 · Trapp: mållinje (D) virker som innendørs — målet blir stående på tegningen, kan velges, flyttes og slettes, og lagres med prosjektet

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Høy** · **Størrelse: liten–middels**
**Kjøres på `main`.** Linjenumre fra `3b07568` — symbolnavn er fasit.

---

## Kenneths ord

> «Ønsker å kunne bruke målefunksjon (distanse) slik som for innendørs — i dag blir målet borte fra
> tegningen.»

## Hvordan mål virker i dag (lest i koden)

- `startDimMode()` (:49172), hurtigtast **D** (:54984, gjelder alle moduler), knapp «Mållinje»
  (`#chip-dim-tool`) bare i rom-/hindring-verktøylinja.
- Klikk 1 og 2 setter punktene, klikk 3 setter avstanden ut fra linja. Mousedown-grenen
  `mode==='dim'` (:51836) lagrer så målet:
  - finnes et **valgt rom** (`currentRoom()` = `S.ui.selectedRoomId`) → `room.dims`
  - ellers → `S.floatingDims` med `floorId: _effectiveActiveFloorId()`
- `drawUserDimLines()` (:41678) tegner `room.dims` for rom på aktiv etasje/del, og `S.floatingDims`
  filtrert med `_onActiveFloor` (:5032). Treff/valg: `_hitDimLine` (:55202).
- Trapper har **ingen etasje**, bare `partId` (tabellen ved :4031: «en trapp-del har intet
  etasje-lag»).

## Sannsynlige årsaker til at målet forsvinner (bekreft i STEG 0)

1. **Et rom er fortsatt valgt** fra innendørsdelen (`S.ui.selectedRoomId` blir ikke nullstilt når man
   går inn i trapp-delen). Målet havner da i `room.dims` på et rom som ikke hører til trapp-delen,
   og `_rebuildActiveFloorRoomIds` filtrerer bort hele rommet — målet er lagret, men usynlig.
2. **`floorId` på et fritt mål** i trapp-delen blir `S.floors[0].id` (reserven i
   `_effectiveActiveFloorId`, :4980) eller forrige etasje. Ved neste tegning/åpning stemmer ikke
   etasjen, og `_onActiveFloor` gir `false`.
3. Klikket i mål-modus **treffer trappen først** (`hitStair`) i mousedown og velger trappen i stedet
   for å sette punktet, eller `cancelDrawing()` kalles når trappen velges.

## STEG 0

1. Reproduser på et **duplisert** prosjekt med både innendørs rom og en trapp-del: tegn et mål med D
   i trapp-delen (a) med trapp valgt, (b) uten noe valgt, (c) etter å ha valgt et rom i innendørs
   først. Logg hvor målet lagres (`room.dims` / `S.floatingDims`, med `floorId`/`roomId`) og
   hvorfor det ikke tegnes.
2. Prosjekt med **bare** trapp (ingen etasjer, ingen rom): virker det der?
3. Følger målene med i `_buildSaveData`/`_restoreProject` (:60303, :60594) — også et mål med
   `partId`?

## Gjør

### 1. Mål i trapp-delen hører til delen (eller trappen)

- I trapp-delen (`moduleType === 'stair'`) lagres et mål **aldri** i `room.dims`.
- **Trapp valgt** når målet startes → målet festes til trappen: `stair.dims[]` med punkter
  **relativt til trappens `x_cm/y_cm`**. Det flytter seg når trappen flyttes og slettes med trappen.
  `drawUserDimLines` tegner `stair.dims` for trapper i aktiv del (samme filter som
  `drawStairs`, :33730).
- **Ingen trapp valgt** → `S.floatingDims` med `partId: S.ui.activePartId` (og **ikke** en gjettet
  `floorId`). `_onActiveFloor`: et objekt med `partId` er synlig når `partId === S.ui.activePartId`.
  Oppdater revisjonstabellen ved :4031 med den nye raden.
- Gjelder også `_hitDimLine`, valg-gizmoen (`drawDimMoveGizmo`), flytting av avstand, og sletting
  (:55252) — alt skal finne mål i `stair.dims` og frie mål med `partId`.

### 2. Klikk i mål-modus setter punkter, ikke valg

I mousedown: når `S.ui.drawMode === 'dim'` skal klikk på trappen sette målepunkt, ikke velge trappen
eller avbryte målingen.

### 3. Snapping

Som innendørs snapper mot romhjørner/vegger: mål i trapp-delen snapper til trappens hjørner og
trinnkanter (flatene i `stair.surfaces`, i både plan- og sidevisning når den vises). Shift = fri
lengde, som i dag (:4800).

### 4. Knapp

«Mållinje»-knappen (`#chip-dim-tool`, samme `startDimMode()`) i trappmodulens verktøylinje — både
uten valgt trapp («🪜 Trapp-modul · ＋ Legg til trapp · Mållinje») og med valgt trapp.

### 5. Lagring

`stair.dims` og frie mål med `partId` lagres og leses tilbake. Eldre prosjekter uten feltene åpner
som før. Mål som i dag ligger «gjemt» i et innendørsrom fra trapp-delen (årsak 1) rører du ikke —
rapporter bare hvor mange du finner i Kenneths prosjekter (lesende).

## Skal IKKE

- Endre mål i innendørs- eller snøsmeltingsmodulen.
- Endre trappens egne mål (085) — brukerens mållinjer kommer i tillegg.
- Ta brukerens mållinjer med i PDF-en i denne runden (se SPØRSMÅL).

## Test

1. Trapp-del, trapp valgt, D → tre klikk → målet står. Flytt trappen → målet følger.
2. Trapp-del, ingenting valgt, D → målet står. Bytt til innendørs → målet vises ikke der. Tilbake →
   der igjen.
3. Velg et rom i innendørs, gå til trapp, D → målet står i trapp-delen (ikke i rommet).
4. Klikk på et mål → valgt, kan flyttes ut/inn og slettes (Delete).
5. Snapping til trinnhjørne, Shift fri lengde.
6. Lagre, lukk, åpne → alle mål på plass. Slett trappen → trappens mål borte, frie mål står.
7. Innendørs: mål som før (rom valgt → `room.dims`, ellers frie mål).
8. Prosjekt med bare trapp → virker.

## Rapport

STEG 0.1–0.3 (hvilken av årsakene det var). Endringslogg. Commit: «087: trapp — mållinje virker i
trappmodulen (festet til trapp eller fri i delen), snapper til trinn, lagres; knapp i verktøylinja».
