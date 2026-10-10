# 056 · Plantegning: rommene fra «Lag rom» speilvendes i y og lander utenfor tegningen

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Kritisk** · **Størrelse: liten**
**Meldt av Kenneth 10.10.2026** etter 052. Linjenumre fra `a82a0df` — **symbolnavnene er fasit.**

---

## Kenneths ord

> «Appen leser tegningen bedre nå, fint bilde med oransje vegger over plantegningen, men de
> rommene som ble opprettet la seg helt feil sted, utenfor tegningen.»

## Hva som skjer — målt i koden

To omregninger som ikke er enige om hvilken vei y går:

1. `_planRomRader` (:6454) regner polygonet fra (u,v) til **verdens-cm med y nedover** — nøyaktig
   som veggene tegnes (`_planUVtoW` :5737: `y = originY + v·heightCm`) — og deler på 100 for å
   gi meter: `[(originX + u·widthCm)/100, (originY + v·heightCm)/100]`.
2. `_drawCreateRoomsFromReview` (:56781) er skrevet for den **gamle** `/import/pdf`-veien, der
   polygonene kommer i PDF-meter med y **oppover**, og speiler derfor: `{ x: p[0]·100,
   y: -p[1]·100 }`.

Resultat: rommene får `y = −(originY + v·heightCm)` — speilvendt om x-aksen, altså over/utenfor
tegningen. Veggene (046) går ikke gjennom denne funksjonen, så de ligger riktig. 052 målte bare
**arealer** (som er like for et speilvendt polygon) og så derfor ikke feilen; den ekte PDF-en
rendret heller ikke ferdig i testpanelet, så ingen så rommene på lerretet.

## STEG 0

1. Reproduser med motorens svar for Okkenhaugvegen (eller `_planRegressionTest`s syntetiske
   vegger): etter Lag rom, sammenlign `S.rooms[n].points[0].y` med `_planUVtoW(bg,
   polygon[0]).y`. Forventet: motsatt fortegn.
2. Bekreft at `fitAll()` i `_drawCreateRoomsFromReview` er grunnen til at Kenneth ser både
   tegningen og rommene (zoomer ut til å få med alt).

## Gjør

- Gi `_drawCreateRoomsFromReview(rooms, opts)` et valg `{ yDown: true }`: da brukes
  `{ x: p[0]·100, y: p[1]·100 }` (ingen speiling). `_planRomTilLerret` kaller med `yDown: true`.
  Den gamle `/import/pdf`-veien er uendret (standard `false`).
- Alternativt (mindre pent): speil i `_planRomRader`. Velg det første — det er der antakelsen
  om y-retning bor.
- Etter opprettelsen: ikke `fitAll()`, men behold visningen slik den var i vegg-sjekken
  (brukeren står alt og ser på tegningen). `fitAll` kun i den gamle veien (samme `opts`).
- `_planRegressionTest` blokk J: ny sjekk som sammenligner **posisjon**, ikke bare areal —
  rommets senter skal ligge innenfor underlagets rektangel (`originX..originX+widthCm`,
  `originY..originY+heightCm`), og `points[0]` skal være lik `_planUVtoW(bg, polygon[0])`
  ± 1 cm.

## Skal IKKE

- Endre `_planUVtoW`/`_planWtoUV` eller veggene.
- Endre den gamle gjennomgangsskjermens omregning.

## Test

1. Okkenhaugvegen → Finn vegger → Lag rom → rommene ligger **oppå** tegningen, inni sine vegger;
   zoom er uendret fra vegg-sjekken.
2. Gammel vei («La appen finne rommene») → rommene ligger som før.
3. Regresjon grønn, med den nye posisjonssjekken (verifiser at den **feiler** på koden før
   endringen).

## Rapport

STEG 0.1-tallene. Endringslogg. Commit: «056: plantegning — rommene speilvendes ikke lenger (yDown
i _drawCreateRoomsFromReview), ingen fitAll etter Lag rom, posisjonssjekk i regresjonen».
