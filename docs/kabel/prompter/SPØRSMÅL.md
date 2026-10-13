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

Kenneth sa «ja» til 068 uten å svare på de fire spørsmålene. Jeg bygde videre på disse
antakelsene — alle kan endres uten å bygge om:

1. **Lengdetoleranse ±1 %** som spec §0.4 sier. Motoren treffer den i alle rom den løser
   (flere på 0,00 %), så den er ikke lenger den bremsen den var i 068.
2. **Kenneths vannrette referanse skal også rettes.** Den nye motoren legger badet vannrett
   med 0 cm utenfor lovlig område, der skew hadde 203 cm. Prisen er dekning: 88,3 % mot 96,5 %.
   **Dette er det eneste stedet den nye motoren er dårligere enn dagens**, og merge-kriterium
   §8.2 sier «ikke dårligere på hvert mål». Trenger svar før 071.
3. **`pathEls` + `centerline`** som format → utleggene er auto-utfylling-bare (kan ikke dras).
4. **Rettvinklede overganger regnes som hardt brudd** på bøyeradius. Motoren lager dem derfor
   ikke i det hele tatt — den kobler celler med U-svinger, eller svarer «ingen løsning».

Nytt spørsmål fra 069:

5. **Hindring midt i rommet har beviselig ingen lovlig én-kabel-løsning** (cellene ligger
   `0 < {1,2} < 3`; tilbaketuren har ingen lovlig korridor). Motoren svarer «2 kabler» med
   prøvde lengder. Alternativet er en **transittkorridor** — reservert plass langs en vegg,
   slik `leadRun` gjør for flerkabel — som koster dekning. Vil du ha den i 070, eller er
   «2 kabler» riktig svar for de rommene?

## 070

-

## 071

-
