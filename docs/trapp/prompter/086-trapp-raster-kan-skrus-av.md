# 086 · Trapp: rasteret kan skrus av også i trappmodulen

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Normal** · **Størrelse: liten**
**Kjøres på `main`.** Linjenumre fra `3b07568` — symbolnavn er fasit.

---

## Kenneths ord

> «Ønsker å kunne skru av visning for raster.» (i trappmodulen)

## Hva som finnes

- Knappen **«Raster»** (`#chip-show-grid`, :1991) → `_toggleGridVisible()` (:55134) →
  `S.ui.showGrid`. `render()` tegner rasteret bare når `S.ui.showGrid !== false` (:4908).
- Knappen ligger i en verktøylinjegruppe med `data-modules="indoor snow"` (:1990). I trappmodulen
  er hele gruppen skjult — derfor finnes det ingen måte å slå av rasteret der. Selve rasteret tegnes
  likevel, fordi `render()` ikke spør om modul.

## STEG 0

1. Bekreft at `data-modules` er eneste grunn til at knappen mangler i trappmodulen (finn funksjonen
   som viser/skjuler `[data-modules]` ved modulbytte).
2. Tegner trappmodulen eget raster/hjelpelinjer noe annet sted (`drawStairs`, `_drawStairPlan`,
   `_drawStairSide`) som også bør følge `S.ui.showGrid`?
3. Lagres `S.ui.showGrid` med prosjektet, eller er det en økt-innstilling? (Ikke endre — bare
   rapporter.)

## Gjør

- Flytt «Raster»-knappen ut i en egen gruppe med `data-modules="indoor stair snow"`. Snap, Bygg, 90°
  og 45° blir der de er (`indoor snow`) — de gjelder romtegning, ikke trapp.
- Knappens `on`-tilstand skal stemme med `S.ui.showGrid` når man bytter modul (oppdater i samme
  funksjon som viser/skjuler gruppene).
- Gjelder STEG 0.2 noe trappeget raster: la det følge `S.ui.showGrid` også.
- Hurtigtast: ingen ny.

## Skal IKKE

- Endre hvordan rasteret ser ut eller snapper.
- Endre PDF-utskriften (den slår allerede av rasteret selv, :63390).

## Test

1. Trappmodul → «Raster» synlig → klikk → rasteret borte, knappen grå. Klikk igjen → tilbake.
2. Skru av i trapp → bytt til innendørs → rasteret er av der også, knappen viser «av» (én felles
   innstilling).
3. Innendørs og snøsmelting: knappen virker som før, Snap/90°/45° uendret.
4. Hurtig prosjektering (liste): ingen rasterknapp (som i dag).

## Rapport

STEG 0.1–0.3. Endringslogg. Commit: «086: trapp — Raster-knappen også i trappmodulen (av/på)».
