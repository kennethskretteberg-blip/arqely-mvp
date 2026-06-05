# Endringslogg — Romtegner

Kronologisk logg over arbeid i `romtegner.html`. Nyeste øverst.

---

## 2026-06-04 — Varmekabel: færre/store, bedre layout, manuell velger

- **`6f8bf6f` — Punkt 3: manuelt valg + dekning% + live forhåndsvisning.** Kabel-velgeren
  (`_updateCableSelection`) lister nå forslag (1× stor + multi 3×/4×/…) med total W, W/m²,
  CC, dekning~% og effekt-merke (▼lav/●ok/▲høy). Klikk → live forhåndsvisning (ikke commit,
  som snø-modulen) + «✓ Bruk / ✕ Avbryt». Ingenting endelig før bekreftelse.
- **`10bd31c` — Punkt 2: deknings-drevet layout (like-AREAL bånd).** `_autoFillNCables`
  delte i like-BREDE bånd → dårlig tiling på uregelmessige rom. Ny `_equalAreaBandBounds`
  deler i N bånd med likt netto-areal → hver fast-lengde kabel fyller kant-til-kant.
  L-form 60 m²: 3 bånd à 20 m², 95% dekning (opp fra ~88%). Rektangel uendret.
- **`39adf4b` — Punkt 1: foretrekk færre/større kabler.** `selectMultiCables` rangerte på
  effekt-presisjon → en liten kabel slo færre store. Nå: færrest kabler innen ±12% effekt,
  største kabel. Katalogen har lange InFloor 17T (opp til 200m), så 72 m² @ 129 W/m² gir
  nå 3× 183m i stedet for 7× 79m. LOCKED kabelregler urørt.

---

## 2026-06-04 — Bakgrunn: alltid-synlig hurtigkontroll

- **`cb4a778` — Synlighets-/dimme-kontroll for bakgrunn tilbake på toppen.** Kontrollen
  lå kun i none-state-ctxbaren (kun når ingenting var valgt) → forsvant når et rom ble
  valgt. Ny `_bgCtxGroupHtml()` prepende i `updateCtxBar` for alle hvile-tilstander
  (skjult i transiente moduser + før kalibrering): Vis-toggle + dimme-slider + «…»-meny
  (målestokk/bytt/fjern), bundet til det aktive laget (synket med sidebar-lista). Fjernet
  none-state-duplikatet + død flytende `#bg-panel`-HTML. Rendering og prosjektdata urørt
  (trygg fiks — full S.bgs→bgLayers-migrering droppet pga. lav gevinst/høy risiko).

---

## 2026-06-04 — Varmekabel: ubegrenset antall kabler

- **`07032b0` — Store rom kan nå prosjekteres med så mange kabler som trengs.**
  `selectMultiCables` var hardkodet til maks 2× — nå effekt-drevet: N ≈ ønsket effekt /
  kabel-effekt, med gyldig CC. Ny `_autoFillNCables` splitter perp-aksen i N like bånd
  og legger én serpentin per bånd (indre bånd: ny `boundaryEdge='both'` → halv-CC mot
  begge nabokabler, uniform CC). Alle kabel-paneler viser «N×» og plasserer N.
  2-kabel-veien (delt start + lead-run) uendret; ny vei kun for N≥3. Tak 16 (praktisk
  ubegrenset). Verifisert ekte InSnow (64 m²): 200 W/m²→13 kabler, 300→16, 0 overlapp.

---

## 2026-06-04 — UX: seleksjons-drevet kontekst-handlingsmeny

- **`fe327c1` — Samme prinsipp overalt: klikk rad = velg/åpne, ✏️ = navn.** Utvidet
  rom-fiksen til etasje-headere (klikk → toggle, ✏️ omdøp), prosjektliste-rader på
  dashbordet (klikk → åpne prosjekt, ✏️ omdøp) og hindring-rader (fjernet villedende
  cursor:text, ✏️ lagt til). Alle eksisterende rename-handlere gjenbrukt; dobbeltklikk
  + høyreklikk «Gi nytt navn» beholdt.
- **`fefdabd` — Klikk hele rom-raden for å velge rommet.** Navne-spennet i sidebar
  hadde egen onclick som startet omdøping (med stopPropagation), så klikk på navnet
  valgte ikke rommet. Fjernet den → hele raden kaller `selRoom`. Omdøping flyttet til
  en tydelig ✏️-knapp (i tillegg til dobbeltklikk + høyreklikk «Gi nytt navn»).

- **`40f9e08` — Rydd opp i `#ctxbar` (rom-tilstand).** Rom-valgt viste ~12 knapper
  samtidig. Nå seleksjons-drevet: primær «+ Produkt» (fylt aksent) + 4 sekundære
  (+ Hindring, + Sone, Auto-soner, Mål); resten (Skillevegg, Fyll fra punkt, Sentrer,
  Folie-avstand, Tøm, Dokumentasjon, Rom-label, Målsett rom/folie/kabel, Slett rom)
  under én «⋯ Mer»-popover (`_showCtxMore`, gjenbruker `#produkt-menu` + `.ctx-item`).
  Ny `.snap-chip.primary`-stil, 44px-trykkflater beholdt, `#topbar` uendret. Alle
  onclick-handlere gjenbrukt — ingenting mistet, la til «Slett rom». None-state:
  «Rektangel» markert som primær.

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
