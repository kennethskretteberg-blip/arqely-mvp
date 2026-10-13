# SPØRSMÅL — serien Kabelmotor (068–071)

Claude Code: legg spørsmål under riktig prompt mens du kjører, med valget du tok i mellomtiden.

## Avklart av Kenneth før start (13.10.2026)

- Arbeidet gjøres i en git worktree; ingenting merges eller pushes til main før han har sjekket at
  badet løses godt.
- Coworks justeringer av oppdragsteksten (spec §0) er godtatt.
- Samme kabel i samme bad lagt **horisontalt** legger seg perfekt (CC 12,5, én slynge) — feilene er
  i vertikal retning. Horisontalt utlegg er referanse.

## Til Kenneth (ubesvart)

- **Lengdetoleranse:** satt til **±1 %** av produktlengden (47 m → ±0,47 m). Riktig, eller strammere/
  løsere?
- ~~**Prosjektnavn for badet**~~ — FUNNET selv: **«Ekebergveien 28» → rom «Bad»**, 5,887 m²,
  InFloor 17T 800W 47m. Geometrien (11 punkter, ingen hindringer, ingen soner) er kopiert inn
  som `_cableFixtures.badHakk`. Ingen kundedata. Prosjektet ble bare lest.
- **Retning når brukeren har valgt vertikal og den ikke går:** 070 legger da ut horisontalt med
  melding og «Prøv vertikal likevel». Ok, eller vil du heller få ⚠-utlegget i valgt retning først?

## 068

1. **Lengdetoleransen ±1 % er den klart viktigste avklaringen — den avgjør 99 av 140 rader.**
   Med ±1 % feiler til og med et rent rektangel 400×300 med 96 m kabel: lagt lengde −1,18 %
   (vertikalt) / −0,94 % (horisontalt). Horisontalt består, vertikalt ikke. Spørsmålet er om
   ±1 % er riktig *krav*, eller om det bare avslører at lengdestyringen er for svak i dag.
   **Valget mitt i mellomtiden:** beholdt ±1 % slik spec §0.4 sier, og rapportert ærlig.
   `_cableGeometryCheck(cable, room, { lengthTolPct: 2 })` bytter den uten kodeendring.

2. **Kenneths «perfekte» horisontale utlegg består ikke kontrollen.** Det er én
   sammenhengende slynge med CC 12,5 og 136 W/m² — nøyaktig som du beskrev — men banen
   ligger **0,83 cm fra veggen der produktet krever 5 cm**, over 213 cm av lengden, langs den
   skrå veggen oppe. Og lengden er 46,05 m av 47 (−2,03 %).
   Spørsmål: skal dette regnes som **referansen som er god nok** (og kravet senkes/nyanseres
   for skrå vegger), eller som **et utlegg som også må rettes** i 069?
   **Valget mitt i mellomtiden:** regnet det som feil, ikke senket terskelen (prompt-regel).

3. **`pathEls`-formen slår av dra-redigering.** Den nye motoren bør levere `pathEls` +
   en eksplisitt `centerline` (se `arkitektur.md` §1), men i dag er `pathEls`-kabler
   auto-utfylling-bare — de kan ikke dras. Godtar du at nye utlegg er auto-bare i første
   runde, med manuell redigering som egen runde etterpå?

4. **Knekker (radius 0) i overgangene.** V6s koblingsbaner er rette vinkler; en kabel kan
   ikke bøyes 90° på null radius. Kontrollen melder dem som `bøy`. Er det riktig å regne en
   rettvinklet overgang som et hardt brudd, eller tegner dere dem i praksis som en myk bue?

## 069

-

## 070

-

## 071

-
