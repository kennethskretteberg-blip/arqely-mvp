# 057 · Plantegning: veggene skal legges **over dører og vinduer**, så rommene lukker — åpninger lukkes i motoren og vises som egne (stiplede) vegger brukeren kan slette

**Repo:** `lumelo-backend` (hoveddel) + `arqely-mvp` (visning) · **Prioritet: Høy** · **Størrelse: middels**
**Meldt av Kenneth 10.10.2026.** lumelo fra `cfbf7a2`, arqely fra `a82a0df` — **symbolnavnene er fasit.**
**Forutsetning:** 056 (rommene lander riktig — ellers kan ikke resultatet vurderes på lerretet).

---

## Kenneths ord

> «Det ble bare 4 rom opprettet. Jeg tror den største feilen er at vinduer og dører bryter
> veggene slik at det ikke blir opprettet rom. Kan man få veggene til å legge seg over vinduer
> og dører?»

Ja — og det er riktig diagnose. 047b målte **179 frie veggender** på tegningen; en arkitekt
tegner veggen som to tykke biter med døra/vinduet imellom, så senterlinjene stopper på hver
side av åpningen. Rommet lukker ikke.

## Hva som finnes — og hvorfor det ikke er nok

| Mekanisme | Hvor | Begrensning |
|---|---|---|
| `_bridge_gaps` | `room_detection.py` :138, kalt fra `detect_rooms` med `close_gaps` (appen sender `close_gaps_cm: 121`, :6417 i index.html) | Kobler bare **fri ende ↔ fri ende** som peker mot hverandre (`min_cos 0.7`), ≤ 121 cm. En dør **inntil en tverrvegg** har bare én fri ende — partneren er et hjørne. Et **vindu** er 100–300 cm bredt → aldri lukket |
| `weld_t_junctions` | `wall_centerlines.py` :483 | Flytter en ende som stopper på en annen veggs *flate* inn på senterlinja — toleranse ½ tykkelse + 3 cm. Treffer ikke en ende som stopper 90 cm før tverrveggen |
| `_merge_collinear` | :307, toleranse **1 cm** | Slår bare sammen biter som *berører* hverandre |
| `chain_collinear` | :179, `CHAIN_GAP_CM = 2.0` | Kjeder råstrek med 2 cm gap — ikke åpninger |

Alle fire er riktige for det de gjør; ingen av dem har som oppgave å gå **over en åpning**.
Og de kjører for sent til å vises: brukeren ser i vegg-sjekken veggene *med* hullene og får
ingen sjanse til å si «den der er en ekte åpning».

## Prinsipp

**Motoren lukker åpningene som egne vegger (`source: 'opening'`), appen viser dem stiplet, og
brukeren kan slette dem i vegg-sjekken.** Da ser Kenneth nøyaktig hva motoren har gjettet, og
rommene lukker. En ekte åpning mellom kjøkken og stue (uten vindussymbol, bredere enn en dør)
lukkes **ikke** — der er det riktig at det blir ett rom.

## STEG 0 (lumelo)

1. Kjør `/import/plan` på Okkenhaugvegen (`local/`, gitignored) og rapportér: antall vegger,
   frie ender (`_open_ends` på senterlinjene), T-sveiset, rom lukket (i dag 4 av 34), coverage.
2. Mål gapene: for hver fri ende, avstand langs veggens retning til (a) nærmeste **kollineære**
   frie ende, (b) nærmeste **vegg** den ville treffe. Histogram i 10 cm-bøtter. Hvor mange
   gap er ≤ 130 (dør), 130–400 (vindu), > 400?
3. Hva ligger i `parsed.segments` i gap-området? Er vindussymbolene (tynne parallelle streker
   på tvers av åpningen) med som tynne segmenter (`segment_widths` < `MIN_STROKE_PT`)? Er
   dørslagene (buer) i `segments` som polylinjer, eller forkastet i parsingen? Tell for 5 kjente
   dører og 5 kjente vinduer på tegningen.
4. Er det frie ender som egentlig er **hjørner som ikke møtes** (to vegger som stopper 5–20 cm
   fra hverandre i 90°)? Hvor mange?

## Gjør (lumelo)

### 1. `bridge_openings(walls, segments, widths, *, pt_per_cm)` i `wall_centerlines.py`

Kjøres i `plan_from_parsed` (:241-området) **etter** `weld_t_junctions`, **før** `coverage`
og `detect_rooms`. Returnerer `(walls, stats)`; nye vegger får `source='opening'` og et nytt
felt `opening: 'door' | 'window' | 'gap'`, tykkelse = naboveggens.

Tre regler, i denne rekkefølgen, hver fri ende brukes én gang:

**a) Kollineær bro (dør/vindu i samme vegg).** To vegger på samme linje (vinkel ≤
`PAIR_MAX_ANGLE_DEG`, vinkelrett avstand ≤ max(2 cm, ¼ tykkelse)), tykkelse lik ±2 cm, med
gap `g` mellom endene som vender mot hverandre:
- `g ≤ DOOR_MAX_CM` (**130**) → bro, `opening='door'`.
- `130 < g ≤ WINDOW_MAX_CM` (**400**) → bro **bare med bevis**: i rektangelet gap × 1,5·tykkelse
  finnes ≥ 2 tynne segmenter (bredde < `MIN_STROKE_PT` eller ikke vegg-kandidat) som er
  parallelle med veggen (≤ 10°) og dekker ≥ 50 % av gapet → `opening='window'`. Eller en bue /
  polylinje med radius ≈ g (dørslag) → `opening='door'`. Uten bevis: **ingen bro** (ekte
  åpning).
- `g > 400` → aldri.

**b) Fri ende → tverrvegg (dør inntil en vegg).** Fri ende hvis forlengelse i veggens egen
retning treffer en annen veggs senterlinje innen `DOOR_MAX_CM`, uten å krysse noen tredje
vegg → forleng til fotpunktet, `opening='door'`. (Dette er `weld_t_junctions` med lang arm, men
som **egen** vegg så den kan slettes.)

**c) Hjørne som ikke møtes.** Fri ende der en annen fri ende ligger innen 25 cm og veggene står
≈ 90° → forleng begge til skjæringspunktet (ikke egen vegg — dette er ikke en åpning, bare
unøyaktighet; STEG 0.4 avgjør om regelen trengs).

Terskler som konstanter øverst i fila, med én kommentarlinje hver om *hvorfor* (dør: NS 3931
standard dørbredder 70–120 cm + karm; vindu: 400 cm dekker vanlige stue-/panoramavinduer).

### 2. `/plan/rooms` (:469) — redigerte vegger

Her finnes ingen tynne streker, så bare **a) med `g ≤ DOOR_MAX_CM`** og **b)** gjelder — begge
inn i `_bridge_gaps`-steget i `detect_rooms` (regel b er ny der: fri ende → treff på en part
innen `close_gaps`, ikke bare ende↔ende). `close_gaps_cm` fra appen beholdes (121 → sett til
130 i appen).

### 3. Kontrakt

`PlanWall.source` får `'opening'`; nytt valgfritt `opening`. `PlanResult` får
`openings: {door, window, gap}` (antall). `coverage` skal **ikke** telle åpningsveggene som
dekning av råstrek (de dekker ingen strek).

### 4. Tester (lumelo)

- Syntetisk PDF-fixture (eller utvid eksisterende): rektangelrom med én dør (90 cm gap) i en vegg,
  ett vindu (180 cm gap med to tynne parallelle streker), én dør inntil tverrvegg, én åpning på
  250 cm **uten** symbol. Forventet: dør og vindu og T-dør lukkes (3 `opening`-vegger), den
  symbolløse åpningen står, rommene lukker riktig.
- Okkenhaugvegen (manuelt, rapportér): rom lukket før/etter, frie ender før/etter, antall
  `door/window/gap`. **Mål: ≥ 25 av 34** rom; si ærlig hvor det stopper og hvorfor (STEG 0.2-
  histogrammet forteller det).

## Gjør (arqely)

- `drawPlanWalls` (:5748): vegger med `source === 'opening'` tegnes **stiplet** (`setLineDash
  [8,6]`), 60 % alpha på bredden, samme rav. Tooltip/valgt-tekst i `_planRenderBar`:
  «Lagt over dør/vindu — slett hvis det er en ekte åpning». `Delete` sletter som andre vegger.
- Verktøylinja: brikke «🚪 12 dører · 🪟 6 vinduer lukket» fra `res.openings`; klikk → blink
  alle åpningsveggene i 1,5 s.
- `_planApplyResponse` (:5981) bærer `source` og `opening` med. `_planLagRom` sender
  `close_gaps_cm: 130`.
- `_planRegressionTest`: en `opening`-vegg tegnes stiplet (kildesjekk), slettes som vanlig, og
  sendes til `/plan/rooms` som vanlig vegg (den er bare en vegg der).

## Skal IKKE

- Lukke åpninger bredere enn en dør uten symbolbevis.
- Endre `weld_t_junctions`, `chain_collinear` eller `_merge_collinear` (de er riktige for sitt).
- Røre labels, kalibrering eller `_til_innvendig`.
- Legge Okkenhaugvegen-PDF-en i repoet (adresse i tittelfeltet) — den forblir i `local/`.

## Test (ende til ende)

1. Okkenhaugvegen → Finn vegger → stiplede rav vegger over dører og vinduer, brikke med antall.
   Slett én stiplet vegg → den er borte, resten står.
2. Lag rom → **≥ 25 rom** lagt på lerretet oppå tegningen (056), de fleste med ✓ mot oppgitt
   areal. Rapportér hvilke som fortsatt mangler og hva som stopper dem (skjermbilde av røde
   prikker / frie ender).
3. Syntetisk fixture: nøyaktig 3 åpningsvegger, den symbolløse åpningen står, 2 rom (ikke 1,
   ikke 3).
4. `uv run pytest -q` grønn; `_planRegressionTest` grønn.

## Rapport

STEG 0.1–0.4 med histogrammet, før/etter-tallene på Okkenhaugvegen, hvilke terskler som til
slutt ble brukt og hvorfor. Endringslogg i begge repoer. `fly deploy` kjøres av Kenneth —
skriv kommandoen i «Til Kenneth». Commits: «057: plantegning — bridge_openings legger vegger
over dører (≤130) og vinduer (symbolbevis ≤400) som egne opening-vegger; fri ende → tverrvegg;
/plan/rooms lærer T-dør» og «057: plantegning — åpningsvegger stiplet i vegg-sjekken, brikke
med antall, close_gaps 130».
