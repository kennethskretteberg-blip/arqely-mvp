# 006 · Klient: bygningsomriss som vektorlag, snapping ved tegning, helning og avstand hus → område

**Repo:** `~/Code/arqely-mvp` (`index.html`) · **Størrelse: middels** · Forutsetter 005 (og 004 i tjenesten)

## Mål

Når et snø-område tegnes på et kartutsnitt, skal (1) bygningsomrisset ligge som en tynn, klikkbar
vektorlinje oppå kartet, (2) rom-tegningens punkter **snappe** til omrissets hjørner og kanter (og
til eiendomsgrensen der den finnes som vektor — ellers bare omriss), (3) området få **helning fra
terrenget** og **avstand fra huset** som tall med kilde-badge i rompanelet.

## STEG 0

1. Les `getWorldPos` (≈ :4251): rekkefølgen grid-snap → angle-snap → re-grid for `polygon`, og
   `rect2`/`lshape`. Snapping til omriss må inn **etter** angle-snap og **før** siste grid-snap
   (ellers vinner rasteret over hjørnet). Finn `SNAP_PX`-mønsteret (≈ :10674: 14 skjermpiksler
   omregnet til cm) og bruk samme.
2. Les hvordan «lås akse, så snap til vegg» er løst for skillevegg (`_nearestPtOnPolyBoundary`,
   ≈ :26210) — det er den samme regelen for omriss.
3. Les rompanelet for snø (`_moduleContext`, `_roomTargetWm2` ≈ :2771, romkortet `drawRoomCard`
   ≈ :4868) og hvor W/m²-forslaget vises — der skal helningen inn som tilleggslinje.
4. Bekreft at `S.geo[floorId]` fra 005 har `chosen.footprint` i verdens-cm, og at
   `_serializeBgFields`/`S.geo` rundturen fra `_geoRegressionTest` er grønn.

## Gjør

### 1. Vektorlag `drawGeoFeatures()`

- Tegnes i `render()` rett etter `drawBgImage()` og **før** rom, kun når aktiv etasje har
  `bg.geo`. Kilde: `S.geo[floorId].candidates[*].footprint` (valgt = mørk blå 1,5 px, andre = grå
  1 px), i verdens-cm. Skjules i `_pdfMode`? **Nei** — omrisset skal med på PDF (tynn), det er
  nyttig for montøren. Bryter i bakgrunnens ctxbar «Vis omriss» (på).
- Klikk på et annet omriss enn det valgte → «Bruk dette bygget?» → oppdaterer `chosen` (ingen
  ny henting av kart).
- `footprint.source === 'DOM1'` tegnes **stiplet** (avledet, ~1 m); har `prov.note` (lav
  confidence) → liten ⚠ ved omrisset med teksten fra `note`. `footprint === null` → ingenting
  tegnes, ingen snapping, og tom-tilstanden/ctxbar sier «Omriss mangler — tegn området fritt».

### 2. Snapping ved rom-tegning

- Ny `_geoSnap(p)` i `getWorldPos` for `polygon`, `rect2`, `lshape` og `hindring-polygon` når
  aktiv etasje har `bg.geo`: snap til nærmeste **hjørne** på valgt omriss (innen `SNAP_PX`),
  ellers til nærmeste punkt på en **kant** (samme radius), ellers uendret. Eiendomsgrense-vektor
  finnes ikke (den er kun raster i 003) — skriv det i SPØRSMÅL som mulig 003b (Teig-WFS).
- Snap-ring tegnes (samme stil som romtegningens første-punkt-ring). Shift = ingen snap (som
  ellers).
- Rekkefølge: grid → angle → **geo** → (ikke re-grid når geo traff). Shift-regelen og `S.snap`-
  bryterne respekteres; ny bryter `S.snap.geo` (på) i snap-chipsene.

### 3. Helning og avstand i rompanelet

- Når et rom på en geo-etasje opprettes eller endres (samme sted `roomAreas` invalideres),
  kall `_roofApi.slope(polygon i EPSG:25833 via _worldToGeo)` **debounced 600 ms**, lagre
  `room.terrain = { slope_pct_mean, slope_pct_max, aspect_deg, prov, fetchedAt }` (serialiseres med
  rommet — det er romdata, ikke transient).
- Rompanel (snø): linje «Helning: 8,7 % (maks 14 %) · fra terreng (DTM1)» med badge-fargen for
  `DOM_RASTER` (blå «Fra data»); ≥ 6 % → tillegg «bratt — vurder høyere W/m²» (**ingen automatisk
  endring** av W/m²; regelen er Kenneths — legg spørsmålet i SPØRSMÅL: skal 300 → 350 W/m² foreslås
  over X %?).
- «Avstand hus → område: 6,4 m» = korteste avstand fra valgt omriss til rommets polygon
  (shapely-logikk i JS: punkt–segment-avstand over alle kantpar) — vises i panelet, badge
  `FOOTPRINT`. Ingen kaldkabel-beregning ennå (bare tallet).
- Tjeneste nede → linjene skjules, ingen feil.

### 4. Romkort og PDF

- Romkortet på lerretet: én ekstra liten linje «↘ 8,7 %» når `room.terrain` finnes.
- PDF-romsiden: i «Areal, effekt og dekning»-blokken, én rad «Helning (terreng)» og «Avstand til
  bygning» når de finnes, med kilde i parentes.

## Tester

- `_geoRegressionTest` utvides: snap til hjørne innen radius, ikke utenfor; snap til kant gir
  punkt på linja; Shift slår av; polygon-tegning på en etasje **uten** geo er bit-for-bit uendret
  (samme punkter inn → samme punkter ut).
- Manuelt: tegn oppkjørsel langs husveggen → hjørnene fanger; panelet viser helning og avstand;
  PDF viser radene; `_foilRegressionTest()`/`_matRegressionTest()` uendret.

## Skal IKKE

- Endre W/m² automatisk.
- Snappe rom til noe som helst på etasjer uten `bg.geo`.
- Tegne omriss inn i selve kartbildet (det er et vektorlag, med vilje).

## Commit / rapport

Commit: «006: bygningsomriss som vektorlag, snapping, helning og avstand i snø-området».
STATUS: snap-radius valgt; om eiendomsgrense-vektor bør bli 003b; forslag til helningsregel.
