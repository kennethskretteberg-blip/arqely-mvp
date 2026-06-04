# Endringslogg — Romtegner

Kronologisk logg over arbeid i `romtegner.html`. Nyeste øverst.

---

## 2026-06-04 — Folie skråvegg-motor + onboarding/multi-org

Økt som ryddet folie-auto-fill-scoringen, bygde skråvegg-trapper, og forbedret
onboarding/brukeradministrasjon. Alle endringer verifisert på ekte FlexFoil-data i
preview-serveren (Chrome), og syntaks-sjekket før commit.

### Folie: skråvegg-dekning (ny `_slantStaircaseFill`-motor)

Bygd stegvis gjennom flere prompter. Sluttresultat: hver skråvegg får en ren
40/20cm-trapp som følger diagonalen, midtpartiet pakkes optimalt, ingen
overlapp/støv, og rette rom (rektangel/L/T) er garantert uendret.

- **`31fd9fc` — Pakk kjerne-båndet optimalt + jevne mellomrom.**
  Etter trapping dekomponeres det fullhøye kjerne-båndet (komplementet til
  slant-sonene) og pakkes med `_bestMixedWidthFit` (uttømmende søk → færrest
  strimler / beste breddekombinasjon) i stedet for grådig. Slakken fordeles jevnt
  mellom strimlene. Kun brede produkter (>40cm) i kjernen; båndet krympes forbi
  trappestrimler som strekker seg inn (ren overgang). Byttes kun når ikke verre
  (≤ antall strimler og ≥ dekning), validert mot trappene (ingen overlapp).

- **`045025a` — 40cm-trapp på BEGGE sider (slutt å beholde flatt kuttede brede strimler).**
  Ny `_stripCutRatio` (lengde / høyeste-kant-potensial). Brede strimler (>40cm)
  som diagonalen kutter < 85 % fjernes — også de som straddler sonegrensa — og
  sonen bygges om til ren trapp (regionen utvides til strimlenes fulle spenn).
  Brukervalg: ren trapp først, selv om en flat strimmel dekker marginalt mer m².

- **`0a4885d` — Fjern overlapp-advarsel, støv-strimler og glipper.**
  `_freeSweepRanges` erstatter `_subtractCoveredSweep` og håndhever leverandør
  perp-GAP (`_effectiveGapCmPair`) mot alle strimler → ingen ⚠. `_buildNarrowStaircase`
  dropper støv (< 30cm) og velger bredden som dekker mest (40cm i kroppen, fint
  20cm nær spissen, eksakt ett gap mellom trinn).

- **`6fda605` — 40/20cm-trapp på ALLE skråvegger (redesign).**
  Itererer per skråvegg-kant (slant-sone = kantens perp-span). Foretrekker ren
  full-høyde trapp der den dekker ≥ det den erstatter; ellers additiv så ingen
  sone står tom. Løste at bare én skråvegg fikk trapp.

- **`62e547f` — Skråvegg-dekning med trapp av smale FlexFoil-strimler (20/40cm).**
  Første versjon: additivt etter-pass `_slantStaircaseFill`, kun ved
  `_roomHasSlantedWall`. Hjelpere `_roomHasSlantedWall`, `_posNearSlant`,
  `_narrowEdgeFillProducts`.

### Folie: opprydding

- **`bcbb2ec` — Samle layout-scoring i én `_scoreFoilLayout` (P4).**
  Erstatter `_scoreLayout` + lokal score-closure i `_autoFillBothDirections` med
  én scorer med to dokumenterte vekt-profiler (select/zone). Aritmetikk bevist
  byte-identisk → ingen synlig endring.

### Onboarding & multi-org

- **`ff11db0` — Onboarding.** Samle pending-statuser til én komponent
  (`_AUTH_STATUS`), invitasjons-vei på login («📩 Har du en invitasjon?»),
  2-stegs registrering, org-admin rolle-endring + invitasjon på nytt.

- **`97e6d8b` — P7 multi-org.** Alle medlemskap i `_userMemberships`, aktiv-org i
  localStorage, org-bytter i avatar-meny (kun ved >1 org), plan-basert medlemstak
  (`_orgMemberLimit`).

### Kabel-motor (P1, tidligere i økten)

- **`4c86720` — Samle delt kabel-scoring i `_scoreCableCandidate`.**
- **`d1b0135` — Fjern død kabel-motor (V5/V4/length-driven).**

---

## Verifiseringsmetode

- **Syntaks:** ekstraher inline `<script>` → `node --check`.
- **Funksjonelt:** preview-server `romtegner` (port 4000) + Chrome MCP, testet på
  syntetiske rom (trapes, hus med 2 skråvegger, steep-trapes, kappet hjørne) og
  ekte FlexFoil 60W-produkter. Sjekket: dekning, overlapp (0), støv (ingen <30cm),
  no-op på rektangel/L/T.
- **LOCKED-regler** i CLAUDE.md (U-turns, sweep-margin, equal-length runs, ingen
  Y-splits) ikke berørt — dette gjelder kun folie, ikke varmekabel.
