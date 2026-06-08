# Endringslogg — Romtegner

Kronologisk logg over arbeid i `romtegner.html`. Nyeste øverst.

---

## 2026-06-08 — ØKT-OPPSUMMERING: snøsmelting fullført + matte-pakkemotor

Stor økt: fullførte utendørs snøsmelte-modulen (steg 1–8), konsoliderte produktvelgeren
(snø + innendørs deler nå én UI + én motor), og bygde en matte-pakkemotor for InSnow 300T.
Alt verifisert i preview-server `romtegner` (dev-login `?dev`) og **deployet via Vercel**.
Commits: `06b2acf`, `92d682c`, `57d74be`, `a80652b`, `81d79c4`, `48bdc93`, `6242729`,
`49f54aa`, `536947b`, `0c97e0b`, `7db1513`, `05d0efb`, `e36a335`.

### Snøsmelting-modul fullført (steg 1–8)
- **Ekte InSnow 300T-matter i DB** (`_ensureOutdoorMatProducts`): erstattet placeholder
  `CVA20001–20016` med 32 ekte faste-størrelse-matter (17× 230V `CVA106xx` + 15× 400V fra
  Cenika produktblad 05/2025), bredder 0,5/1,0 m, `mat_total_length_mm` → fast-lengde-modell.
- **`_moduleContext()`** — datadrevet modul-forskjell (wm2Default, ccMaxCm, roomWord,
  hindringTypes, hasScreed). `_roomWord`/`_roomTargetWm2`/maks-CC rutet gjennom det.
- **Effektbehov** (`SNOW_USAGE` 250/300/350 + `_snowUsageWm2` + bruksområde-velger).
- **Delt produktvelger (UPC):** snø ruter nå til `showUnifiedProductPanel` (samme som
  innendørs) via `openProduktMenu`/`showCablePlacePanel`/auto-åpning. UPC modul-bevisst
  (snø=kun utendørs InSnow, innendørs=ekskluder utendørs). Header «Bruksområde» (snø) vs
  «Romtype» (inne). Gammelt flytende snø-panel nøytralisert.
- **Multi-kabel via `_buildNCableZones`** (samme motor som innendørs; LOCKED-regler).
- **Spenningsfilter** rettet (6 steder buggy `name.startsWith` → trygt `product_family`-
  mønster); «InSnow 30T» drar ikke lenger inn 400V.
- **Bugfix:** `maxCCmm is not defined` krasjet info-panelet ved valg av snø-kabel; rettet +
  korrekt snø-maks-CC 300mm via modul-kontekst. Fjernet foreldet «Avretning»-input i snø.
- **Steg 8:** fjernet 465 linjer død gammel snø-sti (`_renderSnowSettingsPanel`,
  `showSnowProposals`, `_snow*`-forslag/preview). Beholdt `_updateSnowSettingsPanel` som shim.

### Produktvelger UX (begge moduler, delt)
- **Dokket panel** (`_dockRwp`): `#room-workflow-panel` ligger nå eksakt over venstre sidebar
  (position:fixed, følger sidebar-bredden) i stedet for oppå griddet → forhåndsvisning fri.
- **Chip/nedtrekk-hybrid:** Produkttype + Effekt-klasse + Spenning + Bruksområde som chips;
  Romtype beholdt som nedtrekk. Splittet familie-nedtrekket i klasse+spenning (`_familyKlasse`,
  `_upcState.klasse/voltage`, voltage-filter i resultatrenderne).
- **Matte-variant forhåndsviser areal:** klikk en variant → eksakt matte legges ut (byttbar),
  via `autoFillMatSerpentine(productId, {exact, keepPanel})`.

### Matte-pakkemotor (`_packSnowMats`) + 4 oppfølgingspunkter
- **Pakkemotor:** legger InSnow 300T-matter i LENGDERETNINGEN, kombinerer ende-til-ende
  per kolonne (k=floor(L/ℓ)), N kolonner på tvers med ~10cm gap + 15cm udekket kant, og
  fyller rest på tvers (rotert 90°). Hver fysiske matte = ett `S.mats`-objekt. Auto velger
  bredeste+lengste (færrest stk). Verifisert mot Cenika-fasit: Sone 1 (4,6×25, 1×20m) →
  5× 1×20m; Kenneths variant (kun 1×12m) → 8× 1×12m + 1× 0,5×8m.
- **Punkt 1 — watt-fix:** `_matRatedW` = produktets ratede effekt pr. fysisk matte (ikke
  laid geometri × num_runs). Brukt i `_computeRoomStats`, sidebar-tre, specRows, PDF-eksport,
  materialliste. Sone 1 = 30000W korrekt (var feilaktig per-løp).
- **Punkt 2 — Bruk/Avbryt:** snø-matter legges som preview (`room._matPreviewIds`); «Bruk»
  committer, «Avbryt» fjerner, bytte swapper. Speiler kabel-preview-flyten.
- **Punkt 3 — rekursiv rest:** rest fylles med flere tverr-bånd til leftover < 40cm. Sone 2
  (4,6×26,5) → 5× 1×20m + 1× 0,5×12m, full dekning.
- **Punkt 4 — fargekoding:** `MAT_COLORS` (8 farger) pr. fysisk matte i `drawMats`;
  materialliste med matchende fargeprikker. Enkeltmatte-rom uendret (`_matColor` → null).

Status: alt deployet. **Restpunkter/notater:** Sone 2-rest er forenklet (ett lengde-ish +
ett kryss-bånd, ~PDF men ikke byte-identisk Cenika-kombo); trapp-modulen + klimasone-tabell +
auto-spenning + styring/følere er utenfor scope (ikke startet).

---

## 2026-06-05 — ØKT-OPPSUMMERING: multi-kabel-motor (varmekabel)

Samlet arbeid på multi-kabel-utlegg denne økta (detaljer i oppføringene under). Commits:
`96dd460`, `825940d`, `0b06e87`, `6d006d9`, `e6906bd`, `4e51fa2`, `b08072d`, `f129876`.

- **Retning etter dekning** + picker-bias; **↻ Retning** snur hele gruppa.
- **Delt sone (hakk/døråpning) = ugyldig løsning** — auto velger den aldri, tvang nektes.
- **Full gavl-dekning** i vertikal modus (skew-kabler godtas, ikke lenger forkastet).
- **Lengde-klamp**: ingen kabel > produktlengde (trimmer sveip, aldri CC).
- **Tette half-CC-sømmer** mellom soner.
- **NØYAKTIG lik CC i alle soner** (felles CC → lik flateeffekt i hele rommet).
- **Manuelt valg «Like soner» / «Korridor»** for 2 kabler; samme motor/regler for alle 2+.

Status: alt deployet via Vercel. Restpunkt: ingen kjente. Merk testrom `__TESTGARD__` kan
ligge igjen i BIV6-prosjektet (slettes manuelt).

---

## 2026-06-05 — Multi-kabel: manuelt valg «Like soner» / «Korridor» (2+)

Brukerønske: ha BEGGE multi-kabel-layoutene med et manuelt valg. Tidligere brukte 2 kabler en
egen korridor-sti (felles startpunkt + lead-run) og 3+ en annen (like soner) — inkonsistent.

- **To moduser** via `autoFillMultiCable(roomId, productId, n, forcedDir, mode)`:
  - **`soner`** (standard) → den forente `_buildNCableZones`-motoren, håndterer nå **2+**
    (felles CC, like soner, split-ugyldig, retningskontroll, lengde-klamp, søm-pinning, skew).
  - **`korridor`** → lead-run-sti med felles startpunkt ved termostat. **Kun for 2 kabler**;
    3+ med korridor-forespørsel faller automatisk til soner.
- `S.varmekabel.multiCableMode = 'soner'` (standard, huskes pr. økt). Kablene tagges
  `multiCableMode`.
- **UI:** ny ctxbar-toggle «▦ Like soner» / «🚇 Korridor» ved siden av «↻ Retning», vises KUN
  for 2-kabel-grupper (skjult ved 3+). `_cableToggleMultiMode()` kjører gruppa på nytt i valgt
  modus. `_cableFlipDirection` bevarer nå modus.

Verifisert (Garderobe herrer): 2-soner → lik CC 19,81, ingen lead-run; 2-korridor → lik CC
19,81 + felles startpunkt + lead-run; 3-korridor → faller til soner (CC 13,21). Enkeltkabel
uendret. LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: NØYAKTIG lik CC i alle soner (lik flateeffekt)

Kenneths prioritering: lik CC i alle soner (lik W/m²) > eksakt veggmargin. CC spriket før
mellom sonene (14,2/11,7/13,2) fordi hver sone regnet sin EGEN CC, og vertex-snapping
ubalanserte arealene.

- **Én felles CC** regnes én gang i `_buildNCableZones`:
  `sharedCC = clamp(nettoTotal_m2 / (N·cable_length_m) · 100, minSp, maxSp)`, og settes som
  `tempRoom._forcedSpacingCm` på hver sone.
- **Motorene tvinges til felles CC:** `generateCableBoustrophedon._solve`, `generateCableSkew`
  og `generateCableV6` (inkl. V6 stage-7 lengde-opt hoppes over) bruker `_forcedSpacingCm` i
  stedet for å utlede CC fra delroms-arealet.
- **Like arealer:** droppet `_snapBoundsToVertices` for multi-kabel — like-areal-kuttet er nå
  styrende (lik areal → lik lengde → lik CC virker). Motorene takler uregelmessige delrom.
- **Resten absorberes i sveip-margin, aldri i CC:** `_trimCableToLength` trimmer sveip-
  utstrekningen (sving-til-vegg) ned til produktlengden; half-CC-pinning ved sømmene beholdes.

Verifisert (Garderobe herrer, vertikalt): alle tre kabler **CC 13,21 cm** (var
14,2/11,7/13,2), lengder 182,7/183/183 m (alle ≤ 183), ~128 W/m² ≈ måltall 129. Enkeltkabel
+ 2-kabel + rektangulære rom upåvirket. LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: godta skew-kabler (full gavl-dekning i vertikal modus)

Gavl-sona i vertikal modus ble underfylt (serpentin-fallback ~130 m av 183 m). Årsak:
`_buildNCableZones` sjekket kun `cable.runs.length`, men **skew-motoren lagrer banen i
`pathEls`, ikke `runs`** — så en gyldig skew-kabel ble forkastet og falt til serpentin.

- Ny `_cableHasGeom(cable)` = har `runs` ELLER `pathEls`. Brukt i alle tre stedene
  `_buildNCableZones` sjekket «har kabelen geometri» (fallback-trigger, sluttsjekk).
- Dekningsscoren bruker `cable.coverage` for skew-kabler (ingen runs å summere).
- Split-deteksjon/pin/trim hopper trygt over runs-løse skew-kabler.

Verifisert (Garderobe herrer, vertikalt): gavl-sona K1 = skew **181,6 m** (var serpentin
130 m), K2/K3 boustrophedon 182,3/183 m — alle ≤ 183 m, full gavl-dekning, fargekodet riktig.
LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: delt sone = ugyldig løsning (ikke bare straffet)

Etter brukerkrav: «hvis en sone blir delt i to, så må det bli et ugyldig løsning». Oppgraderte
split-håndteringen fra en myk score-straff til en HARD ugyldighet.

- `_buildNCableZones` måler nå split-andelen PER SONE (verste sone) og returnerer `invalid:true`
  når en sone har ≥30 % strenger brutt i ≥2 segmenter (en void/hakk deler sona fysisk).
- `_autoFillNCables` dropper alle ugyldige retninger. Finnes ingen gyldig retning → returnerer
  null (ingen fallback til en delt layout; auto-fyll kan da prøve færre/større kabler oppstrøms).
  Tvinger man en delt retning (↻ Retning), returneres null → knappen nekter med toast.

Verifisert (Garderobe herrer): auto → 'v', tvunget 'v' → 'v', tvunget 'h' → null (toppsona
deles av døråpningen). LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: retningskontroll + split-sone-straff

Bruker meldte at horisontale soner var uegnet der en døråpning/hakk fysisk DELER den øverste
sona i to (kabelen må bro over hakket), og at man ikke fikk valgt retning.

- **Split-sone-straff i `_buildNCableZones`-scoren.** Teller strenger som er brutt i ≥2
  segmenter (= en void/hakk deler sona). Auto-retningsvalget trekker fra `0.6 × split-andel`
  fra dekningsscoren → for et rom der et hakk deler det horisontale topp-båndet (mange
  splittede strenger) velger auto nå VERTIKALE soner i stedet. Verifisert på Garderobe herrer:
  'h' gir K1 med 20/31 splittede strenger (score 0,88→0,69), 'v' gir 0 splittede (0,86) → auto
  velger 'v'.
- **Tvunget retning:** `autoFillMultiCable(roomId, productId, n, forcedDir)` →
  `_autoFillNCables(..., forcedDir)` bygger kun den retningen (hopper over auto-valget).
- **`↻ Retning`-knappen** (`_cableFlipDirection`) håndterer nå multi-kabel-grupper: i stedet
  for å flippe én kabel kjøres HELE gruppa på nytt i motsatt retning (tvunget) og erstattes,
  så sonene re-orienteres samlet. Verifisert: v→h→v gir samme layout tilbake, ingen feil.

LOCKED kabelregler urørt; enkeltkabel + 2-kabel upåvirket.

---

## 2026-06-05 — Multi-kabel: lengde-klamp (≤ produktlengde) + V6-søm-pinning

Avdekket på det FAKTISKE rommet (Garderobe herrer, H7 gt5) at multi-kabel-utlegget hadde
to feil som det syntetiske testrommet ikke fanget: (1) K2/K3 krevde **186,6/186,5 m** av en
**183 m**-kabel — fysisk umulig; (2) gavl-sona (V6) sin søm-kant lå **22 cm** fra kuttet.

- **`_trimCableToLength(cable, targetCm)`** — ingen kabel kan kreve mer enn produktlengden.
  Ved overskudd (diskret strengantall bommer oppover) kortes strengene ved å trimme sweep-
  endene, fordelt PROPORSJONALT med hver strengs kapasitet (lange strenger gir mest, korte
  gavl/topp-strenger urørt → like-spenn-strenger trimmes likt, så celle-lik-lengde beholdes).
  Perp-posisjoner urørt → sømmene flytter seg ikke.
- **`_pinCableSeamToCut(...)`** — for motorer som ignorerer `_cableSeam` (V6/skew/serpentin på
  en uregelmessig yttersone): skyv ALLE strenger likt langs perp-aksen så søm-kanten havner
  halv-CC fra kuttet → én CC over sømmen. Kun yttersoner (én søm), klampet så veggsiden
  beholder ≥ margin.
- Begge kalles i `_buildNCableZones` etter at hver kabel er bygd (før push/dekningsmåling).

Verifisert: Garderobe herrer → K1 182,8 / K2 183 / K3 183 m (alle ≤ 183), sømmer 13/14 cm
(K1|K2 22→13), dekning 88 %. Rektangel → 179,4 m hver, sømmer 15/15, 96 %. Enkeltkabel +
2-kabel upåvirket (klamp/pin kjører kun i N≥3-stien). LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: tette sømmer (halv-CC delte vegger) + picker-retning

Etter Kenneths modell: 3 like soner, hver kabel legges normalt, men **veggen som deles
med nabosona er halv-CC** → full CC mellom siste streng i sone N og første streng i sone
N+1 (ingen kald stripe). Samme prinsipp som to-kabel-stien allerede bruker (`boundaryEdge`).

- **Seam-bevisst streng-plassering i `generateCableBoustrophedon`.** Nytt `room._cableSeam`
  `{min,max}` (settes kun på midlertidige delrom). En kant som deles med en nabokabel er
  IKKE vegg: ytterste streng pinnes eksakt halv-CC fra kuttet, og resten (slack) legges mot
  ekte vegg. **Kantsoner** (én søm) pinnes; **midtsona** (to sømmer) beholder liten
  veggmargin + sentrering — halv-CC-margin på begge sider der ville droppet en streng og
  blåst opp resten (løsere sømmer). Enkeltkabel uendret (`_cableSeam` udefinert → identisk
  sentrert layout).
- **`_buildNCableZones`** markerer hver delroms-kant som søm (`min: i>0`, `max: i<N-1`).
- **Retning følger picker:** `_autoFillNCables` biaser mot `S.varmefolie.direction`
  (retningsvelgeren) men prøver fortsatt begge og bytter kun ved klar deknings-gevinst
  (>2 %) — så et bevisst valg/uavgjort (rektangel) æres, mens default 'v' som ville latt en
  gavl stå udekket likevel flipper til 'h'.

Målt: GABLE-rommet K2|K3-søm **19 → 14 cm** (ideal 13), K1|K2 14 cm; RECT 15/15 (ideal
13,1) — ~1,5–2 cm over ideal (uunngåelig hårfin rest når sonebredde ≠ multiplum av CC ved
låst kabellengde). Dekning 93–96 %. LOCKED kabelregler urørt; enkeltkabel + 2-kabel uendret.

---

## 2026-06-05 — Multi-kabel: velg retning etter dekning (gavl/hakk-rom)

- **`_autoFillNCables` velger nå kjøreretning etter total dekning, ikke bare
  `_suggestDirection`.** Den gamle koden låste alltid dominansretningen. På et rom med
  skrå gavl (f.eks. Garderobe herrer, 72,5 m²) ga VERTIKALE kutt et helt udekket delrom
  (gavlen → motoren «skew» → 0 %, samlet 61 %), mens HORISONTALE topp/midt/bunn-bånd
  isolerer gavlen i ett bånd og tiler resten rent (80 % / 94 % / 97 % → samlet **93 %**).
  Refaktorert: ny `_buildNCableZones(room, productId, prod, n, dir)` bygger N like-areal
  delrom for ÉN retning og returnerer `{cables, score}` (areal-vektet dekningsgrad);
  `_autoFillNCables` kjører den for BEGGE retninger og beholder den beste (med liten
  hysterese mot dominansretningen så vi bare bytter ved klar gevinst). Beholder snapping
  til verteks, konsistent retning for alle delrom, serpentin-fallback og aldri-dropp.
  Verifisert på den eksakte Garderobe-geometrien: 61 % → 93 %, 3 kabler, alle 'h'.
  RESTPUNKT: tynne kalde sømmer mellom båndene (hvert bånd holder veggmargin mot kuttet);
  halv-CC-stramming ved sømmene gjenstår som egen oppgave. LOCKED kabelregler urørt;
  enkeltkabel + rektangulære rom uendret.

---

## 2026-06-05 — Multi-kabel: rene delrom uten udekket trekant

- **Rene delrom — snap kutt til verteks + konsistent retning + deknings-retry.**
  `_autoFillNCables` forbedret etter prompt-kabel-multi-rene-soner: (1) **Smartere
  kuttlinjer** — ny `_snapBoundsToVertices` snapper hvert like-areal-kutt til nærmeste
  rom-verteks-perp-koordinat innenfor toleranse, så hvert delrom blir mest mulig
  REKTANGULÆRT (isolerer hakk/skråvegg i ett delrom i stedet for å kutte tvers gjennom
  → fjerner den udekkede trekanten i midten). (2) **Konsistent retning** — kjøreretningen
  låses til rommets dominansretning for ALLE delrom via `S.varmefolie.direction` (forced
  dir), så `autoFillCable` ikke re-velger pr. delrom → alle strenger parallelle. (3)
  **Deknings-sjekk** — ny `_cableCoverageFrac`; hvis et delrom dekker <90 %, prøv alt-
  retning og behold den beste; serpentin-fallback hvis fortsatt tomt (aldri stille dropp).
  Verifisert: L-hakk/notch → 3 kabler, samme retning, ~96 % dekning, kutt snappet til
  notch-verteks; skråvegg-gavl → rene rektangler + isolert trapes-rest (uunngåelig pr.
  LOCKED lik-strenglengde). LOCKED kabelregler urørt; enkeltkabel + rektangulære rom
  uendret.

---

## 2026-06-04 — Varmekabel: manuelt valg i RIKTIG panel

- **`55d4a8c` — Manuell-seksjon + dekning% + preview lagt i det LIVE panelet.** Forrige
  runde la manuell-valget i `_updateCableSelection`, men panelet brukeren faktisk ser (RWP
  unified product picker) er `_upcRenderCableResults` (`#upc-results`) — derfor var det
  «borte». Nå i `_upcRenderCableResults`: «✋ Manuelt»-seksjon (type-dropdown + antall-
  stepper + Forhåndsvis) høyt (etter forslag, før «Flere kabler»), dekning% + effekt-merke
  på opsjonene, og preview-før-commit. Ny `_refreshCablePanel` oppdaterer riktig panel.

---

## 2026-06-04 — Varmekabel: synlig manuelt valg + fargekoding

- **`4f0e52f` — Manuell-seksjon flyttet opp + fargekod hver kabel.** (A) «✋ Manuelt — velg
  type + antall»-boksen flyttet OPP (rett etter «Nærmest», før den lange «Flere kabler»-
  lista) → synlig uten å scrolle. (B) Ny `INDOOR_CABLE_COLORS`-palett (6 distinkte) +
  `_cableStroke`/`_cableBaseColor`: hver kabel i en multi-gruppe får sin egen farge på
  serpentin/connections/lead-run/etikett, label K1/K2/K3… (ikke bare K1/K2). Fargelegende i
  romkortet (prikk + K# + produkt · lengde · effekt). Enkeltkabel uendret (oransje),
  LOCKED-regler urørt.

- **`85e9c8c` — Aldri dropp en kabel + fri manuell type/antall.** (1) `_autoFillNCables`
  droppet et delrom stille hvis den gode motoren ga ingen runs på en uregelmessig del
  (skrå gavl/hakk) → 3 valgt ble 2 tegnet, en del udekket. Nå: fallback til serpentin på
  sub-polygonet (`_engine='serpentine-fallback'`) → kabelen plasseres alltid; kun ekte
  slivere droppes (med `console.warn`). Verifisert: skrå-gavl → 3 kabler (2 boustrophedon +
  1 fallback), L/T → 3 boustrophedon. (2) Ny «Manuelt»-seksjon i kabel-velgeren: type-
  dropdown (alle familie-varianter) + antall-stepper (1–16) + «Forhåndsvis» → bygger
  N-delrom-layout + live preview (Bruk/Avbryt), valg huskes. Verifisert: antall=4 → 4 kabler.

- **`7f63800` — Multi-kabel deler rommet i N reelle DELROM og kjører én-kabel-motoren i
  hvert.** `_autoFillNCables` kjørte før den enkle serpentinen i et perp-BÅND av hele rom-
  polygonet → «rektangulært bånd»-problem på L/hakk (udekket). Nå klipper `_clipPolygonToSlab`
  rom-polygonet til hver like-areal slab → reelt sub-polygon, og `autoFillCable`
  (boustrophedon/V6, full dekning + hjørne-til-hjørne) kjøres på et midlertidig delrom og
  re-keyes til ekte rom. Hver kabel arver single-kabel-kvalitet; nabokabler møtes med ~én CC.
  Verifisert: L-form 74 m² → 3 delrom à likt areal, alle boustrophedon, 91% (= single-kvalitet,
  opp fra 88%). Manuell velger + forhåndsvisning (forrige økt) bruker nå denne motoren.

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
