# 046 · Vegg-sjekk: motorens vegger OPPÅ tegningen, flytt/slett/tegn, så «Lag rom»

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Høy** · **Størrelse: stor**
**Spec:** `spec-plantegning.md`. Linjenumre fra `0491101` — **symbolnavnene er fasit.**

---

## Kenneths ord

> «La appen finne veggene, men la meg se og rette dem før de blir rom.»

## Hvorfor denne først

020 bygde automatisk romgjenkjenning uten en sjekk-flate og ga 590 «rom» — «rot». Vegg-sjekken
er det som skiller denne serien fra 020, så den bygges først, mot **syntetisk** motor-utdata.
Da finnes det et sted å se motorens feil når 047 kommer, og kontrakten defineres av den som
skal bruke den.

## Hva som finnes — målt 08.10.2026

| | Finnes | Hvor |
|---|---|---|
| Valgdialog ved import | `_rasterMethodChoice(file)` (:53931) → `_rasterChoose(mode)` (:53965) → `auto` kaller `_autoReadStart`, `manual` legger underlag | To valg i dag: `auto` / `manual` |
| Motor-klient | `LUMELO_FLY_URL` / `LUMELO_LOCAL_URL` (:52891), helsesjekk + adresseoppløsning med localhost-preferanse og `localStorage`-override | Hele klientlaget er på plass |
| Underlag | `_loadBgPdf` (:41849) / `_loadBgDwg` (:41795) → `_installBgImageForFloor` (:42389) → vanlig `S.bgs`-objekt | Gjenbrukes uendret |
| Gjennomgang etter auto | `#import-review-screen` (:1843) + `_reviewRenderList` (:54549) — **romgjennomgang**, ikke vegg | 049 utvider den; 046 rører den ikke |
| Kalibrering | Målestrek-verktøy (manuelt), `$INSUNITS` for DWG | — |
| `S.planWalls` | **0 forekomster** | Nytt lag |

**⚠ Tre import-innganger, ikke én.** Målt: `_emptyPickImport()` (:53805) brukes både av
verktøylinjens «Importer plantegning» og av tom-tilstandens slipp-sone (:2035), og
`_importPlanMenu()` (:54215) kaller `_emptyPickImport`. I 021 ble bare én av tre rettet, og de
to andre hoppet rett i lag-velgeren. Alle tre må ende i den nye flyten.

## STEG 0

1. **Mål de tre inngangene.** Slipp en PDF via (a) etasjens slipp-sone, (b) verktøylinjens
   «Importer plantegning», (c) tom-tilstandens slipp-sone. Hvilke av dem går gjennom
   `_rasterMethodChoice`, og hvilke hopper forbi? Rapportér som tabell. Dette er hypotesen fra
   021b — etterprøv den, ikke stol på den.
2. **Hvor tegnes underlaget, og hva er `w2s` i forhold til det?** Finn ut hvordan en
   PDF-bakgrunn får sin skala (`_installBgImageForFloor` sin `meta`), så planveggene kan legges
   i SAMME verdenskoordinater. Mål: legg en syntetisk vegg på en kjent strek i underlaget og
   bekreft at den treffer.
3. **Hva skjer med `S.bgs` ved etasjebytte?** Planveggene skal følge etasjen sin, som
   bakgrunnen. Sjekk hvordan `S.bgs` nøkles per etasje og gjør `S.planWalls` likt.
4. **Finnes en `plan-review`-lignende modus fra før?** `S.ui.mode` / `S.ui.drawMode`-verdiene som
   finnes i dag — list dem, så den nye ikke kolliderer.

## Gjør

### 1. Nytt lag `S.planWalls`

```js
// Per etasje, som S.bgs. Aldri blandet med room.walls — dette er motorens FORSLAG.
S.planWalls = { <floorId>: [{ id, a:{x,y}, b:{x,y}, thickness_cm, source }] }
```
Lagres i prosjektet (`_buildSaveData` / `_restoreProject`), så en halvferdig vegg-sjekk
overlever at man lukker fanen. `S.planMeta = { <floorId>: { coverage, leftovers, calibration } }`.

### 2. Modus `plan-review`

- Egen tilstand på lerretet: underlag + planvegger + verktøylinje. Rommene i prosjektet tegnes
  som vanlig (de kan finnes fra før) men er ikke redigerbare mens modusen står på.
- **Rendering:** senterlinje i **rav** (`#ffa726`, samme som valgt vegg på kundesiden — den
  fargen finnes ikke i arkitekttegninger) med halvtransparent bredde lik `thickness_cm`, så
  treff/bom mot den svarte veggen under er synlig på en meters avstand. Egen funksjon
  `drawPlanWalls()` kalt fra `render()` — **ikke** en hale inne i `drawRooms()`, som 030 lærte
  at aldri kjører (to tidlige `return`).
- **Røde prikker** på `leftovers` (strek motoren ikke klarte å gjøre til vegg).

### 3. Verktøylinje

`Flytt vegg (dra) · Slett vegg · Tegn vegg · Snap til tegning [på] · Dekning: 96 % · [Lag rom]`

- **Flytt:** dra en senterlinje. Treff = 10 px på PC, 22 px på smal skjerm (samme mønster som
  `nearMoveArrow` og `hitVertexFreeDrag` fikk i 045 — valgfri toleranse, ikke en ny konstant).
- **Slett:** klikk på vegg → borte. Ctrl+Z angrer (ett steg per handling).
- **Tegn:** klikk–klikk gir ny vegg med forrige tykkelse.
- **Snap til tegning:** snapper til motorens **råsegmenter** (`leftovers` + `walls`), ikke til
  piksler. Av/på, standard på.
- **Dekning:** fra `coverage.pct`. Under 90 % → gul tekst «Noen vegger mangler — se røde
  markører».

### 4. «Lag rom» (foreløpig, uten motor)

Lukk senterlinjene til polygoner i klienten er **ikke** oppgaven her — det er motorens jobb
(047 returnerer `rooms`). I 046 gjør «Lag rom» to ting: validerer at det finnes ≥ 1 vegg, og
kaller en stubb `_planLagRom()` som i 046 bare logger kontrakten den forventer. 049 kobler den
til gjennomgangsskjermen.

### 5. Alle tre inngangene

Rut (a), (b) og (c) gjennom `_rasterMethodChoice`. Legg et **tredje** valg for PDF:
«Finn vegger og rom automatisk» → `_rasterChoose('plan')` → `plan-review`.
**Ikke flytt «Anbefalt»-merket ennå** — det skjer i 049, når flyten virker ende til ende.

### 6. Syntetisk motor-utdata (dev-hook)

`window._planDevFixture(n)` som legger inn en håndlaget `/import/plan`-respons (ett rektangulært
rom, ett L-rom, én manglende vegg, én `leftover`) i `S.planWalls` + `S.planMeta`. Det er dette
046 testes mot, og det er den samme formen 047 skal levere.

## Skal IKKE

- Røre `#import-review-screen` eller `_reviewRenderList` (049).
- Lage rom. Ingenting blir rom i 046.
- Flytte «Anbefalt»-merket.
- Kalle lumelo. 046 er klient-only mot fixture.

## Test

1. Alle tre inngangene gir valgdialogen; «Finn vegger og rom automatisk» gir `plan-review`.
2. Fixture → veggene ligger oppå underlaget i rav; en vegg flyttet 1 m i verden flytter seg
   1 m på skjermen (mål med `w2s`, ikke med øyet).
3. Flytt / slett / tegn: Ctrl+Z angrer ett steg per handling. Snap av/på endrer landingspunktet.
4. Dekning 96 % vises; sett fixture til 80 % → gul tekst + røde prikker.
5. Etasjebytte: planveggene følger etasjen, som bakgrunnen. Lagre + last prosjektet → veggene
   er der.
6. Ny `_planRegressionTest`: `S.planWalls` persisteres, `drawPlanWalls` kalles fra `render()`
   og ikke fra `drawRooms`, de tre inngangene ruter til `_rasterMethodChoice` (kildekode-sjekk
   med `_kildeUtenKommentarer`), «Lag rom» krever ≥ 1 vegg.

## Rapport

STEG 0.1–0.4 (særlig tabellen over de tre inngangene og om 021b-hypotesen stemte), hvordan
planveggene ble låst til bakgrunnens skala. Endringslogg.
Commit: «046: plantegning — vegg-sjekk-modus med motorens vegger oppå underlaget, flytt/slett/tegn, snap og dekning»
