# 049 · Rom fra planveggene: utvid gjennomgangsskjermen, romtype fra navn, «Bekreft alle», «Ikke navngitt»

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Høy** · **Størrelse: stor**
**Spec:** `spec-plantegning.md`. Krever 046 + 048. Linjenumre fra `0491101` — **symbolnavnene er fasit.**

---

## Kenneths ord

> «Rom med navn på tegningen skal få navnet. Rom uten navn skal ikke rote til lista — samle dem
> nederst, så jeg kan hente dem fram når jeg trenger dem.»

## ⚠ Gjennomgangsskjermen finnes allerede — ikke bygg en ny

Målt 08.10.2026: `#import-review-screen` (:1843) + `_reviewRenderList` (:54549) har per rom
**redigerbart navn** (`rv-name`), **redigerbart areal** (`rv-area`), **advarsler** med severity
(`r.review`, vises som `rv-flag`), **slett** (`_reviewDeleteRoom`), **varmetype-velger**
(`_reviewTypeSeg`, folie/kabel/matte/ingen), **bulk-rad** for alle rom, «Merk alle» / «Fjern
alle» / «Forslag (våtrom + fellesareal)», romtype-standarder (`_reviewOpenModTypeDefaults`),
live-telling (`_reviewUpdateCount`) og live-sum (`_reviewUpdateSum`).

Planens «rom-kort ved klikk på lerretet» ville altså duplisert det meste. **049 utvider denne
skjermen.** Det som faktisk mangler er fire ting: romtype gjettet fra navnet, arealsjekk mot
tegningens oppgitte areal, «Bekreft alle med navn fra tegningen», og «Ikke navngitt»-gruppen i
romlista etterpå.

## Hva som finnes — målt

| | Finnes | Hvor |
|---|---|---|
| Gjennomgangsskjerm med navn/areal/advarsel/slett/varmetype | ja (se over) | `_reviewRenderList` :54549 |
| Romopprettelse | `createRoom(pts, shape, name, floorId, keepPosition, wallConfigs, promptName)` | :40734 |
| Romtyper | `ROOM_TYPES` | søk i filen |
| Planvegger | `S.planWalls`, `S.planMeta` | 046 |
| «Anbefalt»-merket | på `auto` for PDF, på `manual` for DXF/DWG | `_rasterMethodChoice` :53931 |
| Romtype-gjetting fra navn | **finnes ikke** | bygges her |
| «Ikke navngitt»-gruppe | **finnes ikke** | bygges her |

## STEG 0

1. **Hva heter rommene som kommer fra `/import/pdf` i dag,** og hvordan havner de i
   `_reviewState.rooms`? Les `_autoReadDoImport` (:54199) og `_reviewOpen`-veien. 049 skal mate
   SAMME struktur fra `/import/plan`, ikke en parallell.
2. **Hva gjør «Forslag (våtrom + fellesareal)» i dag?** (`_reviewBulk('suggest')`.) Hvis den
   allerede gjetter noe fra romnavn, er romtype-gjettingen i §2 en utvidelse av den, ikke en ny.
3. **Hvor rendres romlista under etasjen** (den `renderSidebar` bygger, :43108)? Finn funksjonen
   som lager rom-radene, og mål radhøyden — «Ikke navngitt»-gruppen skal ikke flytte de andre
   radene når den åpnes/lukkes (033-regelen: ingenting hopper).
4. **Tåler `createRoom` 34 kall etter hverandre?** Den kaller `pushUndo()` selv (030-funnet med
   `_undoSuppress`). Mål hvor mange angre-steg 34 rom gir, og bruk samme vern.

## Gjør

### 1. `/import/plan` → gjennomgangsskjermen

«Lag rom» i `plan-review` (046) kaller motoren med de (muligens rettede) planveggene, får
`rooms` + `labels` tilbake, og fyller `_reviewState.rooms` med: `name` (nummer + navn fra
label), `areaM2` (polygonets), `statedAreaM2`, `planLabel`, `planIndex`, `roomType` (gjettet).
Rekkefølgen er tegningens romnummer.

### 2. Romtype fra navn

Ordliste i koden, redigerbar, med ordene nederst-først (lengste treff vinner):

```
Bad, WC, Dusj, Vask        -> bad
Sov, Soverom               -> soverom
Kjk, Kjøkken, Stue, Oppg   -> stue
Entre, Gang, Hall, Korridor-> gang
Bod, Lager, BK, IKT, Tekn  -> ingen varme
```

**«Ingen varme» er en romtype, ikke en mangel.** Rom med kjent navn og ingen varme skal navngis
og merkes — ikke havne i «Ikke navngitt» (spec regel 4).

### 3. Arealsjekk

Per rad: ✓ når `abs(poly - stated)/stated <= 0.05`, ellers ⚠ «Tegningen sier 25,7 m², rommet ble
31,2 m² — sjekk veggene». Bruk den **eksisterende** `r.review`-mekanismen med
`severity:'warn'` — da vises den i `rv-flag` uten ny UI.

### 4. «Bekreft alle med navn fra tegningen»

Ny knapp i `rv-toolbar`. Setter `named:true` på alle rom som har en label. På en tegning med 34
rom er rom-for-rom en straff. Enter = bekreft gjeldende rad, Tab = neste — hurtigtastene legges
i `_SHORTCUTS` (CLAUDE.md: hurtigtast-panelet er en manuell liste, ingen automatikk fanger en
glemt rad).

### 5. «Ikke navngitt (N)» i romlista

- Rom uten label, eller hoppet over, får `room._planNamed = false` og navn «Rom 1, Rom 2 …»
  (tegningens rekkefølge).
- I romlista under etasjen: egen overskrift **«Ikke navngitt (N)»** med ▸/▾. Standard **lukket**
  når N > 0 **og** minst ett rom er navngitt. Tilstanden lagres i prosjektet.
- På lerretet: grå kontur, ingen fyll, ingen navn.
- Klikk på et grått rom → samme gjennomgangsrad åpnes → Bekreft flytter det opp.
- Etasje-toppen: «Etasje 1 · 22 rom · 12 ikke navngitt».
- Romoversikt / PDF / materialliste tar bare med navngitte rom.

### 6. Flytt «Anbefalt»-merket

Nå — og først nå, når flyten virker ende til ende — flyttes merket i `_rasterMethodChoice` for
PDF fra «La appen finne rommene» til «Finn vegger og rom automatisk». Målt 08.10.2026 at merket
i dag peker på den svakeste veien for PDF.

## Skal IKKE

- Bygge et nytt rom-kort på lerretet. Gjennomgangsskjermen finnes.
- Lage en parallell vei inn i `_reviewState`.
- La «Ikke navngitt» bety «ingen varme».
- Ta med ikke-navngitte rom i PDF/materialliste.

## Test

1. Fixture med 6 rom, 4 med label → «Bekreft alle med navn» gir 4 navngitte, 2 i «Ikke navngitt».
2. «102 Kjk./stue» → romtype `stue`. «Bod» → `ingen varme`, og rommet er **navngitt**.
3. Rom der polygonet ble 31,2 m² mot oppgitt 25,7 → ⚠ i `rv-flag` med begge tallene.
4. 34 rom opprettes → **ett** angre-steg (ikke 34). Mål det.
5. Romlista: åpne/lukke «Ikke navngitt» flytter **0 px** på de navngitte radene.
6. PDF-eksport med 22 navngitte + 12 ikke navngitte → 22 rom i Romoversikt.
7. `_planRegressionTest` utvidet: romtype-ordlista, arealsjekk-grensen (5 %), gruppens
   standardtilstand, at «Anbefalt» nå står på plan-valget for PDF.

## Rapport

STEG 0.1–0.4 (hvordan `_reviewState` mates i dag, hva «Forslag» gjetter, radhøyden i romlista,
antall angre-steg for 34 rom). Endringslogg.
Commit: «049: plantegning — rom fra planveggene inn i gjennomgangen, romtype fra navn, arealsjekk, Bekreft alle, Ikke navngitt-gruppe»
