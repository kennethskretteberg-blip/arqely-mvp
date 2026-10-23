# 128 — Matte: veggmarginen følger Regel 12 (kabel 5 cm fra vegg = nett 2,5/3 cm), én kilde

## 128

Kjørt 23.10.2026 på `main` fra `69e3831` (127 committet, ikke pushet). **Ikke pushet.** Spec: Regel 12
(`spec-matte-utlegg.md`, Cowork-mappa) — Kenneths avgjørelse 23.10.2026 er skrevet inn der, og
konfliktnotatet fra 22.08 er lukket. Skjermbilder i `skjermbilder/` (headless Chrome, 300 × 400-rom,
EcoMat 100T 0,5×18 m, stående, hjørne nede-venstre).

Kenneth (23.10.2026): «Min 5 cm fra kabel til vegg, dvs. 2,5 cm fra ytterkant nettet til vegg.»

**Resultat i én setning:** nettet lå 5 cm fra vegg (kabelen 7–7,5 cm); nå ligger kabelen 5 cm fra vegg
(nettet 2,5 cm for 60T/100T, 3 cm for 150T), fra én funksjon, i alle veier. Snømatter uendret.

## STEG 0 — målt før endring (gammel fil servert på port 4300)

### 0.1 Alle steder som leste `min_wall_margin_mm` eller hadde egen veggmargin for matte

| Sted (linje før 128) | Verdi i dag | Kilde | 128 |
|---|---|---|---|
| `_matPlaceCandidate` :13832 (klikk-plassering, ghost) | 5 cm | `prod.min_wall_margin_mm ?? 50` | → `_matWallMarginCm` |
| `_matWholeBandPlanForDir` :15018 (hele bredder per sone) | 5 cm, **0 hvis feltet mangler** | `min_wall_margin_mm \|\| 0` | → `_matWallMarginCm` |
| `_matRoomGeomForFill` :15306 (flermatte-søket, benk) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matZonePlanFor` :15579 (soner) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matRelayWithGap` :16257 (127, mellomrom i denne matta) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `autoFillMatSerpentine` :16339 (auto) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matFreeCableMarginCm` :17328 (frihånd **langside**: klipp, vakt, areal, tegning) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matFreeStartFor` :17492 / `_matFreeStartSlide` :17544 (frihånd **kortside**) | `max(cc/2, 5)` = 5 cm (150T), **6 cm** (60T/100T, cc 12) | cc/2 mot produktfeltet | kortside = langside = `_matWallMarginCm` |
| Klikk-plassering, vakten :64734 | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matGroupMaxMarginCm` :44713 (avstand for en gruppe) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `getMatViolations` :89788 (varsel ved flytting) | 5 cm, 0 hvis feltet mangler | `\|\| 0` | → `_matWallMarginCm` |
| `_matArrangementRegressionTest` :18511/:18525 | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matBenchMatsResult` :19439 / `_matBenchRunVei4` :19491 (mattebenk, brukbart areal) | 5 cm | `?? 50` | → `_matWallMarginCm` |
| `_matRunPlacementIssue` :14544 (124-rødmerking) | ingen margin — sjekker rompolygonet med 0,5 cm toleranse | — | uendret |
| `_clampMatToRoom` :44792 (drag) | ingen margin — klemmer til rommets boks | — | uendret (varselet etter drag bruker `getMatViolations`) |
| `_matUsableAreaM2` / `_matRunsWithinRoom` / `_matClippedSegments` | tar `marginCm` som parameter | kallerne over | uendret |
| PDF | ingen egen margin — PDF tegner matta via `drawMats` (127-rapporten); ingen mål-tekst for matte-margin | — | uendret |
| Objektinfo «Avstand langvegg» :61697 | viser `mat._effMarginAlongCm` (satt av motoren) | motoren | følger automatisk |
| `_autoFillPlates` :20673 | 5 cm | `?? 50` | **urørt** — plater, ikke matte |
| Produktkatalog (admin) `marginOf` :80166 | viser feltet rått: «5,0 cm» | DB-feltet | urørt (se SPØRSMÅL 4) |
| Innlasting :84837 | setter 25 mm hvis feltet mangler | — | urørt; feltet er nå bare et «0 = ute»-flagg |
| Reservekatalog `_ensureEcoMatProducts` :89297 | `min_wall_margin_mm: ty.inset` (20/25) | — | urørt; ≠ 0 → Regel 12 |
| `_matBenchCatalog` :15756 | 50 (inne) / 0 (InSnow) | — | urørt |

Spec-tabellen under Regel 12 («tre forskjellige veggmarginer») stemte delvis: auto og frihånd langside
var begge 5 cm (ikke 20/25 mm som tabellen sier for auto — det gjaldt bare reservekatalogen), mens
kortsiden var `max(cc/2, 5)`, altså 5 cm for 150T og **6 cm for 60T/100T**. Tabellen er merket som
historikk i spec-en.

### 0.2 300 × 400-rommet, stående matte, nede-venstre (målt med `_matRunWorldGeom`)

| | Før (nett 5 cm) | Etter |
|---|---|---|
| **100T** (velger 0,5×18 m, 5 bredder × 360 cm, mellomrom 7) | nett 5,0 cm fra endevegg, kabel **7,5 cm** | nett **2,5 cm**, kabel **5,0 cm** |
| **150T** (0,5×18 m, 5 bredder, mellomrom 4) | nett 5,0 cm, kabel **7,0 cm** | nett **3,0 cm**, kabel **5,0 cm** |
| Antall bredder | 5 | 5 (6 bredder trenger 335 cm, rommet gir 295) |
| Sideveis (sentrert, Regel 9) | 11 cm (100T) / 17 cm (150T) | uendret — mellomrommet, ikke marginen, styrer |

Skjermbilder `01-foer-…` og `02-etter-…` viser det samme utlegget med nettet 5 → 2,5 cm fra bunnveggen.

### 0.3 Mattebenk før endring
`_matBench(42, 64)`: 224 rader, 196 lovlige. Lagret som referanse (absolutt m² per rad, ikke bare
prosent — se under hvorfor det var nødvendig).

## Gjort

1. **`MAT_CABLE_WALL_CM = 5` og `_matWallMarginCm(prod)`** rett etter `_matEdgeInsetCm`:
   `max(0, 5 − _matEdgeInsetCm(prod))`; `min_wall_margin_mm === 0` → 0 (utendørs, «ingen vegger ute»);
   uten produkt → 5 (konservativt). Gir 2,5 cm (60T/100T, inntrekk 25 mm) og 3,0 cm (150T, 20 mm).
2. **Alle stedene i tabellen** bruker funksjonen. Ingen `?? 50`, `|| 0` eller hardkodet 5 igjen i
   mattekoden for veggmargin.
3. **Frihånd kortside = langside.** `shortM = longM = _matWallMarginCm(prod)` (var `max(cc/2, 5)`).
   Kabelkravet holder i enden med god margin: tegningen legger første streng cc/2 (≥ 4 cm) innenfor
   mesh-kanten.
4. **Regel 29** (132) kan lese `MAT_CABLE_WALL_CM`; spec-en sier det nå.
5. **Basen urørt.** `min_wall_margin_mm` = 50 på alle EcoMat-rader står, men leses bare som «≠ 0».
6. Spec: Kenneths avgjørelse under Regel 12, konfliktnotatet lukket, kodingen beskrevet.

### Om `min_wall_margin_mm` (punkt 2 i prompten)
Feltet heter «veggmargin» og har hatt tre tolkninger: nettmargin (motoren før 128), kant-inntrekk
(reservekatalogen setter 20/25) og innlastingsstandard 25 mm. Etter 128 betyr det bare «0 = ute».
Anbefaling: **omtolk det til kabelkravet** (`kabel−vegg i mm`, 50 for EcoMat, 0 for InSnow — det er det
radene faktisk inneholder i dag) og la `_matWallMarginCm` lese `prod.min_wall_margin_mm ?? 50` som
kabelkrav i stedet for konstanten. Det krever først at (a) reservekatalogen slutter å sette inntrekket i
feltet, og (b) innlastingsstandarden 25 mm (som er folie-standarden) ikke gjelder matte — ellers blir
kabelkravet 2,5 cm og nettmarginen 0. Begge er små, men hører i sin egen prompt med migrasjon (evt.
omdøpt til `mat_cable_wall_mm`). Ikke gjort her.

## Test

| # | Krav | Resultat |
|---|---|---|
| 1 | 300 × 400 med 100T: nett 2,5 cm (kabel 5,0); 150T: 3,0 | ✓ målt (tabell 0.2) |
| 2 | Frihånd: bane kan legges 2,5 cm fra vegg, ikke nærmere | ✓ delvis — se under |
| 3 | Mattebenk: ingen rom lavere | ✗ **3 rader lavere i absolutt m² — alle er retningsvalg, se under** |
| 4 | Alle matte-batterier + `_pdfExportSmokeTest` grønne | ✓ 2/2, 4/4, 13/13, 70/70, 55/55, 28/28, 20/20 |

### Test 2 — frihånd
Startpunktet (`_matFreeStartFor`, 'v', nede-venstre) er (27,5 · 397,5) for 100T = nett 2,5 cm fra
begge vegger, og (28 · 397) for 150T = 3 cm. Før: (30 · 295) i testrommet; forventningen i
`_matFreeRegressionTest` er oppdatert til (28 · 297) med kommentar — det eneste tallet som låste 5 cm.

**Funn (ikke rettet, fantes før 128):** commit-vakten `_matFreeRunsWithinRoom` godtar en bane inntil
**1,0 cm innenfor marginen langs banen** (toleransen `along >= lo − 1` i `_matFreeClampLen`; målt: 100T
godtatt til 1,5 cm, avvist fra 1,25 cm; gammel fil: godtatt til 4,0 cm med 5 cm margin — samme 1 cm).
**På tvers** sjekker vakten ikke marginen i det hele tatt — `clipStripToRoom` trekker marginen bare fra
langs sveipaksen. Plasseringen (start/gli) holder marginen eksakt, så i praksis styrer startpunktet.

### Test 3 — mattebenk (224 rader, 56 rom × 4 veier)
Benkens «Dekning %» er dekket m² / brukbart m², og **brukbart areal vokser** når marginen krymper
(1642 → 1666 m² summert over innendørs-radene). Prosenten faller derfor for 133 rader selv der dekket
m² er uendret. Sammenligningen er gjort på **absolutt m²** (egen kjøring som speiler `_matBench`):

| | Før | Etter |
|---|---|---|
| Dekket m², vei 1/2 (auto, 56 rom) | 1246,2 | **1300,4** (+54,2 m², +4,3 %) |
| Dekket m², vei 4 (frihånd-syntetisk) | 755,8 | 763,0 |
| Dekket m², vei 3 (InSnow) | 588,5 | 588,5 (uendret, krav) |
| Rader høyere / like / lavere | — | **38 / 183 / 3** |
| Lovlige rader | 196 | 195 |

**De tre lavere radene og de to lovlig→ulovlig:**

| Rom | Vei | Før | Etter | Hvorfor |
|---|---|---|---|---|
| rect #10 (420 × 259) | 1 og 2 | 8,96 m² | 8,00 m² | Auto-retningen byttet **v → h**. Velgeren (`_matAreaGeom`) sammenligner et *estimat*: med margin 3 gir 'h' 5 × 400 = 10,0 m² mot 'v' 8 × 240 = 9,6 (med margin 5: 'h' 4 bredder = 8,0 mot 9,6 → 'v'). Men 'h'-veien **leverer 8,0** (0,5×16 m, 5 × 320) i stedet for sitt eget estimat 10,0 — og matta får `y_cm = −30,5`. Det er 124-funnet «vannrett matte har to koordinatkonvensjoner». Tvunget 'v' gir 8,96 før og etter. |
| stor #45 (1557 × 873) | 4 | 46,08 (ulovlig) | 25,92 (lovlig) | Retning **h → v**. Før-raden var ulovlig («banen starter utenfor rommet») og telte ikke. Vei 1/2 steg 96 → 120 m² på samme rom. |
| 1110 Lærergarderobe HC | 4 | 6,4 lovlig | 6,8 **ulovlig** | Retning v → h; den syntetiske frihåndsbanen er ulovlig i 'h' for 14 av 18 'h'-rom før og 15 av 19 etter (samme feil). Vei 1 gir 6,0 m² begge, men 'h'-matta får `x_cm = −10`. |
| rect #10 | 4 | 7,2 lovlig | 10,0 **ulovlig** | Samme som over (v → h). |

**Kontroll:** med retningen tvunget til det den var før, gir alle tre rommene **identisk** absolutt
dekning før og etter i alle veier (rect #10 'v' 8,96/8,96; stor #45 'h' 96/96 og 46,08/46,08; 1110 'v'
6,0/6,0 og 6,4/6,4). Marginendringen i seg selv senker altså ingen rom. Det som senker rect #10 er at
retningsvelgeren nå (riktig, etter estimatet) velger 'h', og at 'h'-veien har en kjent feil (124) som gjør
at den leverer mindre enn estimatet og legger matta utenfor rommet. Stoppet her som prompten sier —
ikke rettet, hører til en egen prompt for vannrett matte. Se SPØRSMÅL 1.

## Verifiseringsmetode
`node --check` på inline-scriptet; headless Chrome (CDP, port 9333) mot `serve-varmeplan.js` på 4000 (ny)
og 4300 (gammel fil fra `HEAD`), uten innlogging (skylagring stubbet, `#app` vist), testene kjørt som
globale funksjoner. Benk-sammenligning på absolutt m² (egen kjøring, samme katalog/rom/veier som
`_matBench`).

## Endringslogg (kode, alt i `index.html`)
- `MAT_CABLE_WALL_CM`, `_matWallMarginCm` — nye (etter `_matEdgeInsetCm`).
- `_matPlaceCandidate`, `_matWholeBandPlanForDir`, `_matRoomGeomForFill`, `_matZonePlanFor`,
  `_matRelayWithGap`, `autoFillMatSerpentine`, `_matFreeCableMarginCm`, `_matFreeStartFor`,
  `_matFreeStartSlide`, klikk-vakten, `_matGroupMaxMarginCm`, `getMatViolations`,
  `_matBenchMatsResult`, `_matBenchRunVei4`, `_matArrangementRegressionTest` — leser funksjonen.
- `_matFreeRegressionTest` — forventning (30,295) → (28,297), kommentert.
- Spec `spec-matte-utlegg.md` Regel 12 og Regel 29-avhengigheten (Cowork-mappa, utenfor repoet).

---

# 129 — Frihånds-matte: «hopp» (fri start på neste bredde), stiplet forbindelse uten lengde

## 129

Kjørt 23.10.2026 på `main` fra `a973fc5` (128 committet, ikke pushet). **Ikke pushet.** Spec: Regel 17,
Regel 22, **Regel 28** (`spec-matte-utlegg.md`, Cowork-mappa) — frihånd-delen av pkt. 3 er nå merket
bekreftet, auto-delen står som utkast. Skjermbilder i `skjermbilder/129-*.png` (headless Chrome).

Kenneth (23.10.2026): «Fra matte 6 til matte 7 så er det forskyvning av stopp og start på de to mattene.
[…] Jeg ønsker at appen kan gjøre dette uten å beregne noe kortere matte. […] ved hjelp av frihånd-utlegg.»

**Resultat i én setning:** i frihånd kan neste bredde nå starte hvor som helst i rommet (tast **H**,
knappen **⤼ Hopp**, eller **Shift + klikk**); forbindelsen tegnes som tynn stiplet strek i plan og PDF,
og teller ikke noe sted — lengden er fortsatt Σ breddelengder, rullvalget er det samme som uten hopp.

## STEG 0 — målt før endring (fila fra `a973fc5`, port 4000)

Rom i testen: L-rom **300 × 400 + alkove 300 × 200** (x 0–300 / y 0–400 pluss x 300–600 / y 0–200),
EcoMat 100T (cc 12 cm, kuttraster 24 cm, nettmargin 2,5 cm etter 128), hjørne nede-venstre, stående.
Avvik fra prompten: alkoven er 300 bred, ikke 200, fordi «90° til 10 + U-svinger 11–12» ellers ikke får
plass (3 loddrette bredder i alkoven bruker 150 cm; en vannrett bredde trenger ≥ 100 cm til). Og
hoveddelen får **5** loddrette bredder, ikke 6: 6 × 50 = 300 cm > 295 (300 − 2 × 2,5). Bildet i prompten
er håndtegnet og ikke i målestokk — mønsteret (U-svinger, hopp, U-svinger, 90°, U-svinger) er det
som er testet, ikke antallet.

### 0.1 Bildet tegnet i frihånd i dag

| Steg | Hva skjer | Mulig? |
|---|---|---|
| 1–5 (U-svinger loddrett) | 5 × 384 cm, kant i kant, fri ende øverst på bredde 5 (227,5, 13,5) | ja |
| 5 → «7» i alkoven (musa ved 327,5, 190) | `_matFreeCandidate` regner alltid fra fri ende `E`: anti-parallell → **U-sving ved x = 277,5** (inntil bredde 5), ikke ved 327,5. Ghosten lander i hoveddelen/øvre del, 168 cm ned | nei — ingen kobling der neste bane starter fritt |
| klikk mot alkoven som gir lengde 0 (f.eks. 327,5, 5 → vannrett 96 cm < minste 100) | treffer «tilgivende avslutning» (`moves.length ≥ 1 && len ≤ 0` → `_matFreeExit(true)`): banen **committes og frihånd avsluttes** | nei — brukeren mister tegnemodus uten å ville det |
| 9 → 10 (90°) | egen bane startet fra toppveggen (hjørne 'tr'): `corner` gir flush bane ved siden av, 168 cm | ja |
| 10–12 (U-svinger vannrett) | 168 + 144 cm | ja |

Konklusjon 0.1: alt unntatt hoppet lar seg tegne — men som **to** matter (5 + 6 bredder), ikke én.
Skjermbildene `129-04`/`129-05` viser det samme mønsteret tegnet som ÉN matte etter 129.

### 0.2 Hvordan en bane avsluttes og tilstanden mellom to klikk

`_matFree` mellom to klikk (målt): `{ roomId, productId, start, moves[], ghost, gapCm, offX, offY,
phase:'draw', startAxis, startWall, startFromCorner, lastReject }`. `phase` har bare to verdier i dag:
`'start'` (glir innsettingspunktet) og `'draw'`. En bane «avsluttes» ikke eksplisitt — hvert klikk
legger ett move i `moves`, og `_matFreeEnd` (siste `run.b`) er alltid neste startpunkt. `ghost` er
kandidaten under musa (`axis, dir, len, conn, side, rawLen`).

Et «sett nytt startpunkt»-steg passer derfor som **en tredje fase `'jump'`** (H / knapp): musa viser
punktet, klikk låser det i `_matFree.jumpFrom` og går tilbake til `'draw'`. `_matFreeCandidate` leser
`jumpFrom` som `E` i stedet for fri ende. Shift + klikk hopper over fasen og låser punktet direkte.

### 0.3 `_matFreeCatalog` over banene

`_matFreeCatalog` → `_matFreeTotalCm(mp, raw)` → `Σ _matFreeRunLen(r)` over `_matFreeDeriveRuns`. Ingen
del av rullvalget (`_matFreeSplitPlan`, segments `fromCm/toCm`) leser hvor en bane ligger — kun lengden.
Målt: 5 bredder uten hopp → `totalCm 1920`, `Σ runLen 1920`. Etter 129, 12 bredder med ett hopp →
`totalCm 2952` = Σ bredder, og en syntetisk rett bane med samme 12 lengder gir **samme** rull (0,5 × 28 m,
152 cm udekket). Katalogen tåler altså en bane som ikke henger geometrisk sammen — uten endring.

To steder leser geometri mellom baner: `_drawMatPathCable` (kabelen starter hver bredde i enden
nærmest forrige utgang — `moveTo`, aldri strek mellom bredder) og skjøtmarkøren i `_drawMatPathObj`
(kun skjøt *inni* en bane). Begge virker uendret; skjøt som faller nøyaktig i et hopp er lagt til (se under).

## Gjort (alt i `index.html`)

1. **Ny kobling `jump`** i `_matFreeDeriveRuns`: `{ axis, dir, len, conn:'jump', side, from:{dx,dy} }`.
   `from` er forskyvningen fra forrige **nominelle** ende — **relativ**, ikke verdenskoordinat som prompten
   skisserte (`from:{x,y}`). Grunn: hele moves-modellen er relativ, og dermed virker flytting av matta
   (start/offX/offY, 127 «flytt alle»), kloning i `pushUndo`, lagring og oppdeling i ruller
   (`_matFreeSliceMoves`) uten ett eneste nytt spesialtilfelle. Banen har full lengde fra det nye punktet
   (ikke 124 sin `startCm`, som korter). Ingen U-svingbue.
2. **Tegnemåte:** `_matFreeJumpBegin` (H / «⤼ Hopp» i ctxbar) → fase `'jump'`; `_matFreeJumpPoint` snapper
   til 10 cm-raster, til senterlinja for en bredde **inntil forrige bane ± mellomrom** (NET + gap til hver
   side) og til forrige endes koordinat — nærmeste innen ~14 px vinner, ellers rasteret. Utenfor rommet
   eller på en hindring → `ok:false` (rød ghost, toast, fasen beholdes). `_matFreeJumpSet` låser punktet
   (`jumpFrom`). Shift + klikk kaller `_matFreeJumpSet` direkte. Med `jumpFrom` satt regner
   `_matFreeCandidate` fra punktet og gir `conn:'jump'`; klikk legger movet og sletter `jumpFrom`.
   Et klikk som ikke gir bane mens `jumpFrom` er satt avslutter **ikke** (ny vakt før «tilgivende
   avslutning») — toast i stedet.
3. **Forbindelsen:** `_drawMatJumpLink` — tynn stiplet strek fra forrige ende til ny start, i
   `_drawMatPathObj` for både aktiv og committet bane. PDF-en går gjennom samme `render`, så streken er
   med der (`129-09`). Ingen lengde noe sted: katalog, «Dekker», materialliste, toast, sidepanel.
4. **Rullvalg:** uendret (Σ breddelengder). Skjøt som faller nøyaktig på slutten av banen *før* et hopp
   vises nå ved slutten av forrige bane (ny gren i skjøt-løkka); skjøter inni baner som før.
5. **Angre/Esc:** `_matFreeUndoMove` fjerner et satt, ubrukt hopp-punkt først; deretter går hopp +
   bredde i ett (ett move). Esc i fase `'jump'` eller med `jumpFrom` satt → `_matFreeJumpCancel`
   (tilbake til tegning, ikke ut av frihånd). H i fase `'jump'` slår fasen av igjen.
6. **Lagring, PDF, 124, 127:** målt — JSON-rundtur gir identiske baner; `_matPathSetRunAdj` på bredde 7
   (etter hoppet: shift 5, start 24) flytter bare den, naboen står; justering av selve hopp-banen
   (start 24: `a` 190 → 166, `b` står); Alt + dra (127) flytter alle 12 bredder med samme delta
   (20,6 / −10,3), `undo()` setter start tilbake.
7. **Hurtigtaster:** to nye rader i `_SHORTCUTS` (H, Shift + klikk). Hintlinje og ctxbar sier hva som
   skjer i hver fase. H fanges i frihånd **før** den globale «H = håndverktøy».
8. **Regresjonstest:** ny seksjon «129 / Regel 28» i `_matFreeRegressionTest` (13 nye sjekker, 26 totalt):
   geometri, Σ lengde 936, samme rull som uten hopp, kandidat med `from`, snapping, avvisning (utenfor
   rom / hindring), angre (punkt, så hopp + bredde), H/Esc, oppdeling beholder `from`, commit.

## Skal IKKE — holdt
Auto-utlegg urørt. Forbindelsen tegnes kun, måles/telles aldri. Ikke pushet.

## Test (prompten)

| # | Krav | Resultat |
|---|---|---|
| 1 | Kenneths bilde som ÉN matte: 1–5 U, Shift-klikk inntil bredde 5, 6–9, 90°, U 10–12 | 12 bredder i ett objekt (`129-04`, `129-05`). Σ = 2952 cm = 5 × 384 + 4 × 168 + 3 × 120. Rull 0,5 × 28 m, 1,5 m udekket. Syntetisk rett bane med samme lengder: samme rull. |
| 2 | Stiplet strek i plan og PDF, ingen lengde | `129-05` (plan), `129-09` (PDF-utsnitt). Sidepanel: «5 × 3,8 + 4 × 1,7 + 3 × 1,2 = 29,5 m», materialliste 1 × 28 m. |
| 3 | Hopp utenfor rommet avvises | (650, 100) og det manglende hjørnet (450, 300) → rød ghost «⚠ utenfor rommet», toast, fasen beholdes (`129-02`). |
| 4 | Angre, lagre/åpne, flytt alle, juster etter hopp | Alle målt, se «Gjort» pkt. 5–6 og `129-06`, `129-07`. |
| 5 | Testbatterier | `_matFreeRegressionTest` 26/26 · `_matPathClickRegressionTest` 28/28 · `_matRunAdjustRegressionTest` 70/70 · `_matArrangementRegressionTest` 55/55 · `_pdfExportSmokeTest` 20/20. Ingen konsollfeil. |

## Funn utenfor scope (ikke rettet)
- Streken går rett fra ende til start — i Kenneths bilde limes kabelen **langs veggen**. Rett strek er
  det spec-en sier («tynn stiplet strek mellom slutt og start»); om den skal rutes langs vegg er et
  spørsmål (SPØRSMÅL 129-1).
- Et committet enkelt-rull-objekt beholder `productId` for det *tegnede* produktet (0,5 × 18 m) selv om
  katalogen velger 28 m — eksisterende Modell A-oppførsel (rullen løses ved render), ikke endret.
- Hopp-punkt nøyaktig på kanten av en innvendig vegg (f.eks. y = 200 der alkoven begynner) gir
  «får ikke plass» for neste bredde fordi båndet på 50 cm krysser veggen — punktet selv er lovlig
  (inne i rommet), men bredden er det ikke. Rasteret på 10 cm gjør det lett å havne der.

## Verifiseringsmetode
`new Function` på inline-scriptet; headless Chrome 156 (CDP, port 9333) mot `serve-varmeplan.js` på
4000, uten innlogging (`#app` vist, skylagring stubbet); tegning via ekte `MouseEvent`/`KeyboardEvent`
mot lerretet (ikke direkte funksjonskall) — unntatt 124-justeringen, som ble kalt direkte
(`_matPathSetRunAdj`). PDF fanget ved å stubbe `jsPDF.save`, rendret med `pdftoppm` 300 dpi.

## Endringslogg (kode, alt i `index.html`)
- `_matFreeDeriveRuns` — gren `conn === 'jump'`.
- `_matFreeCandidate` — `E = jumpFrom` når satt; move med `conn:'jump', from`.
- Nye: `_matFreeJumpBegin`, `_matFreeJumpCancel`, `_matFreeJumpPoint`, `_matFreeJumpSet`, `_drawMatJumpLink`.
- `_matFreeUndoMove` — hopp-punkt angres først.
- `_matFreeSliceMoves` — kopierer `from`.
- `_drawMatPathObj` — stiplet forbindelse, hopp-ghost/låst punkt, skjøt ved hopp.
- mousedown/mousemove (lerret), keydown (H, Esc), `updateCtxBar` (Hopp-knapp + status), `updMode`
  (hint), `_SHORTCUTS` (2 rader), `_matFreeRegressionTest` (ny seksjon).
- Spec `spec-matte-utlegg.md` Regel 28 (Cowork-mappa, utenfor repoet).
