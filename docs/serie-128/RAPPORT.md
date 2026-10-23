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

## 130

Kjørt 23.10.2026 på `main` fra `7035376` (129 committet, ikke pushet). **Ikke pushet.** Spec: Regel 20,
**Regel 27** (`spec-matte-utlegg.md`, Cowork-mappa — nå merket «BEKREFTET og bygget i 130» med en kort
implementasjonsnote), Regel 9, Regel 12. Skjermbilder i `skjermbilder/130-*.png` (headless Chrome).

Kenneth (23.10.2026, bilde 1): «Jeg måler mer enn 60 cm ledig felt fra matten og inn til vegg. Her vil man
da fått plass til en bredde til. […] Det kan virke som appen avgrenser delen av rommet med blå matte som
et eget rom med en usynlig vegg?»

**Resultat i én setning:** sonegrensen er ikke lenger en vegg — når en sone fylles, får den bruke ledig
gulv inn i nabosonen (stoppet bare av ekte vegg, hindring, forbudt sone eller en nabomatte), og blokka
ankres inntil nabomatta med brukerens mellomrom; i bilde 1 får blå **4 bredder** inntil rød (1 cm), med
slakken mot høyre yttervegg, og rød er uendret.

### STEG 0 — målt før endring (fila fra `7035376`, port 4000)

Rom: L-rom **300 × 400 + alkove 200 × 200** (x 0–300 / y 0–400 pluss x 300–500 / y 0–200), EcoMat 100T
(cc 12 cm, kuttraster 24 cm, nettmargin 2,5 cm etter 128), mellomrom 1 cm, hjørne nede-venstre.
Retningen er **låst loddrett** i alle målingene under (se «Funn» om auto-retning).

**1. Reproduksjon av bilde 1.**

| Hva | Målt |
|---|---|
| `_decomposeRoomToRects` | `[0,0 – 300,400]` (12,0 m²) og `[300,0 – 498,198]` (3,92 m²). Alkovens rektangel slutter 2 cm før veggen (rutenettet på 6 cm klamper siste celle); marginen legges oppå → boksen går til 495,5. |
| Rekkefølge | Størst først: hoveddelen, så alkoven. Begge `single`. |
| Rød (hoveddel) | 18 m-rull, 5 bredder × 360 cm, x 23–277. **Sentrert**: 23 cm slakk mot hver langvegg. |
| Blå (alkove) | 5 m-rull, 3 bredder (168, 168, 144), x 321,8–473,8. **Sentrert i sonens boks (300–495,5)**: 21,8 cm mot sonesnittet, 21,7 cm mot høyre vegg. |
| Ledig mellom rød og blå | 321,8 − 277 = **44,8 cm**. Ledig på blå sin side totalt: 44,8 + 21,7 = **66,5 cm** → én bredde til (50 + 1). |
| Dekning | 9,0 + 2,4 = 11,4 m². |

**2. Hvor sonegrensen ble en vegg** — fire steder, alle i sone-veien:
`_matZoneUsableRoom` bygger sonens boks (0 margin mot en sonegrense-kant, men boksen *slutter* der) →
`_matAreaGeom` regner `acrossMin/Max`, `alongMin/Max` og `maxRuns` av den boksen →
`zoneAlongMin/Max` klemmer de klippede segmentene i `_matClipRunToRoom` / `_matRoomCapacityCm` /
`_matPlaceMultiMats` (en bredde får aldri lekke forbi snittet) → `acrossCenter` sentrerer blokka midt i
boksen (slakken deles mellom sonesnittet og ytterveggen, mot Regel 20 pkt. 4).

**3. Nabomatter.** Motoren visste *ingenting* om andre matter: `_matClippedSegments` klipper mot polygon,
hindringer og forbudte soner — aldri mot `S.mats`. Det fantes ingen felles opptatt-test for matter (frihånd
har sin egen «overlaps» i ghosten). Og `_matPlanZones` planlegger alle soner som `dryRun`, så mattene fra
tidligere soner ligger ikke i `S.mats` når neste sone regnes — de måtte sendes inn eksplisitt.

### Gjort

1. **`_matZoneFreeRoom(room, rect, marginCm, dir, priorMats, gapCm)`** (ny, ved `_matZoneUsableRoom`):
   starter med dagens boks og skyver hver *sonegrense*-kant (`_rectEdgeIsSoneBoundary`, uendret) utover
   1 cm om gangen så lenge stripa over hele den andre aksen er ledig (`_matRectBlockedBy`: inne i rommet
   med Regel 12-margin, unna hindringer med per-hindring-klaring, unna forbudte soner, unna nabomattenes
   bredder + mellomrom). Først tvers-aksen (der hele bredder vinnes), så langsaksen med den utvidede
   tverrbredden. Stoppes kanten av en matte, snappes den eksakt til mattekanten + mellomrom. Returnerer
   boksen som `{points}` (samme form `_matAreaGeom` alt leser) pluss hva som stoppet hver kant.
   Marginen legges bare *utover* (bort fra sonen) og på langs — med margin på alle fire sider ble stripa
   rett over et innvendig hjørne (T-stamme → topp) feilaktig blokkert; funnet og rettet under test.
2. **Retning og ankerhjørne fra sonen (Regel 27 pkt. 1):** retningen velges som før på sonens *eget*
   rektangel (`_matAreaGeom` på dagens boks) og låses inn (`userDir`) før den utvidede boksen regnes.
3. **Ankring inntil nabomatta (pkt. 3):** `_matZoneAnchorSide` → `anchorAcross`/`anchorAlong`
   (`'lo'`/`'hi'`/null). I `autoFillMatSerpentine` og `_matPlaceMultiMats` går ankeret foran
   «Sentrer»/«Fra vegg» på den aksen; de andre aksene er som før. Begge sider matte → lav side.
4. **`priorMats` gjennom hele flyten:** `_matPlanZones` akkumulerer dryRun-mattene sone for sone (pluss det
   som alt ligger i rommet, `_matPriorMatsFor`) og sender dem til `_matZonePlanFor` /
   `autoFillMatSerpentine({ zoneRect, priorMats })`; commit-løkka i `_showMatZoneProposalPanel` gjør det
   samme med de committede mattene, så forslag og utlegg ser nøyaktig samme naboer.
   **Uten `priorMats` er alt som før** — båndene fra «Del så matta går opp» og «Mellomrom i denne matta»
   bruker fortsatt sonerektangelet som grense (låst i regresjonstesten).
5. **Felles opptatt-test for matter:** `_matRunWorldRects` (per-bredde-rektangler fra `_matRunWorldGeom`,
   altså der bredden *tegnes*) og `_matOverlapsMats(mat, others, gapCm)`. Brukes som ny vakt i begge
   motorene (Regel 27 pkt. 2, `console.error` + avbrutt, som de andre vaktene) og i mattebenken.
6. **Panelet:** ny intro-tekst, og «· bruker ledig plass i nabosonen (Regel 27)» på sonen det gjelder
   (`zp.extended`), så 3,5 m² dekket i en 3,9 m²-sone ikke ser ut som en feil (`130-03`).
7. **Mattebenk:** «Regel 27: matte overlapper matte» er ny lovlighetsregel i `_matBenchCheckLegal`
   (kjørt *før* 130: ingen rad hadde overlapp, benken bit-identisk). zoneRect-avviket varsler nå bare når
   sone-konteksten dekker *mindre* enn frittstående — mer er ønsket nå.
8. **`_matZoneRegressionTest`:** 1102-analogen oppdatert (liten sone 6,96 → **8,00 m²**, samlet 30,96 →
   **32,00**, med kommentar: den lille sonen bruker stripa y 400 → ~384 opp til den store sonens matter);
   nye sjekker: `extended` uten overlapp, bilde 1 (rød uendret 5 bredder x 23–277; blå 4 bredder; x0 = rød
   + 1 cm = 278; slakk mot høyre vegg; ingen overlapp, begge innenfor rommet) og bånd-flyten uten
   `priorMats` (fortsatt 3 bredder innenfor sonen). 4 → **11 sjekker**.

### Bilde 1 — før og etter (loddrett låst, 1 cm mellomrom)

| | Før (`7035376`) | Etter 130 |
|---|---|---|
| Rød (hoveddel) | 18 m, 5 × 360, x 23–277 | **uendret** (sonens x1-kant er ikke en sonegrense: 2 av 5 prøvepunkter ligger i alkoven, < 50 %) |
| Blå: bredder | 3 (168, 168, 144), 5 m-rull | **4** (192, 192, 192, 120), 7 m-rull |
| Blå: plassering | x 321,8–473,8, sentrert i sonen | x **278–481**: 1 cm inntil rød (277 + 1) |
| Ledig mot rød / mot høyre vegg | 44,8 / 21,7 cm | **0 (mellomrom 1 cm) / 14,5 cm** — slakken mot ytterveggen |
| Blå: dekning | 2,40 m² | **3,48 m²** |
| Samlet | 11,4 m² | **12,5 m²** |
| Skjermbilde | `130-01` | `130-02`, panel `130-03` |

### Test (prompten)

| # | Krav | Resultat |
|---|---|---|
| 1 | Bilde 1: blå 4 bredder inntil rød (1 cm), slakk mot høyre yttervegg, rød uendret | Målt, se tabellen over. Låst i `_matZoneRegressionTest`. |
| 2 | Alkove **under** hoveddelen og T-rom: ingen bredde over en ekte vegg, ingen overlapp | L (300×400 + 200×200 under): blå ankres rett under rød (start y 383,3 = rød slutt 382,3 + 1), `_matRunsWithinRoom` sann for begge, ingen overlapp (`130-05`). T (600×200 + 200×300 stamme): stammen går 14 cm opp i toppbeltet til rett under toppmattas bredder (y 184), 8 m-rull 3 × 288 → 3,96 m², totalt 13,0 m² (`130-04`). `_matRunPlacementIssue`: ingen. Begge med loddrett retning — se «Funn» om auto. |
| 3 | Rektangulære rom bit-identisk | Mattebenk: **ingen** rad for rektangulære rom uten soner endret (vei 1–4, 224 rader). `_matRegressionTest` 2/2. Den ene «rect»-raden som endret seg (hindring #27) har en hindring som deler rommet i soner — det *er* et sonerom. |
| 4 | Mattebenk: rom som endret dekning | Se tabellen under: 7 rom (14 rader), alle høyere eller lik, **ingen lavere**, ingen ny ulovlig rad (29 ulovlige før og etter — alle i vei 4/frihånd, kjent). |
| 5 | Testbatterier | `_matZoneRegressionTest` **11/11** · `_matRegressionTest` 2/2 · `_matFreeRegressionTest` 26/26 · `_matPathClickRegressionTest` 28/28 · `_matRunAdjustRegressionTest` 70/70 · `_matArrangementRegressionTest` 55/55 · `_foilRegressionTest` 9/9 · `_pdfExportSmokeTest` 20/20. Ingen konsollunntak. |

### Mattebenk-differansen (`_matBench(42, 64)`, før = 7035376 + overlappsjekken, etter = 130)

| Rom | Vei | Dekning før | Dekning etter | Matter | Poeng før → etter |
|---|---|---|---|---|---|
| L #16 | 1 og 2 | 69,7 % | **73,7 %** | 2 → 2 | −56003 → −41313 |
| T #20 | 1 og 2 | 97,4 % | 97,4 % | 2 → 2 | −91703 → −91370 (bedre marginsymmetri) |
| T #21 | 1 og 2 | 88,6 % | **91,8 %** | 2 → 2 | −119735 → −97643 |
| 1102 Garderobe | 1 og 2 | 83,9 % | 83,9 % | 2 → 2 | −99899 → −98603 (matta flyttet inntil naboen, samme rull) |
| 1108 Garderobe | 1 og 2 | 41,9 % | **54,9 %** | 2 → 2 | −49228 → −48038 |
| Kenneth L-rom (500×400, hakk) | 1 og 2 | 80,2 % | **86,4 %** | 2 → 2 | −42447 → −34214 |
| hindring #27 (480×… med søyle) | 1 og 2 | 61,6 % | **81,7 %** | 2 → 2 | −26197 → −3320 |

11 sonerom i benken; 4 av dem (L #18, L #23, T #19, U #17, U #22) uendret — der stoppes utvidelsen av
vegg eller av naboens matte som alt ligger inntil snittet. Konsollfeil fra benken: 45 → 47; de to nye er
Regel D-avvisninger (vakt, ikke unntak) i hindring #24 for en 24 cm smal restsone som er utelatt både
før og etter (før avviste Regel H samme sone).

### Funn utenfor scope (ikke rettet)

- **Auto-retning velger vannrett for hoveddelen i bilde 1** (7 bredder × 264 gir høyere estimat enn
  5 × 360), og for T-stammen. Den vannrette veien har koordinatsaken fra SPØRSMÅL 128-1: matta
  *tegnes* 30 cm forskjøvet (x fra −12,5, «Bredde 1 ligger 13 cm utenfor rommet»), og T-stammen ender
  med 2 m-rull og 0 cm lagt — **identisk før og etter 130** (målt direkte: `oldMat`/`newMat` like).
  130 avgrenser nabomatta der den *tegnes* (`_matRunWorldGeom`, samme kilde som treff og rødmerking),
  så en vannrett nabo unngås visuelt riktig; rettes 128-1 slik at tegning = motor, følger 130 med.
- **`extended`-flagget** leser også tegnet posisjon: en vannrett matte som tegnes utenfor sitt
  rektangel (128-1) får «bruker ledig plass i nabosonen» i panelet uten at det stemmer (hindring #24).
- **Sonerektangelet slutter 2 cm før veggen** (rutenettets klamping), og Regel 12-marginen legges oppå
  → 4,5 cm fra vegg i stedet for 2,5 på sonens veggkanter. Fantes før 130; 130 utvider bare
  sonegrense-kanter, ikke veggkanter.
- **Alkove under hoveddelen (loddrett):** langsaksen utvides 19 cm opp til rød, men kuttrasteret (24)
  og katalogen (5 m vs. 6 m) gir samme rull — gevinsten er null der, 0,6 m² med auto-retning.
- **Kort siste bredde** (144/120) i blå er Regel E-fallbacken (rullen går ikke opp i like bredder),
  uendret oppførsel.
- **Hindring som bare delvis blokkerer utvidelsen** (f.eks. en søyle i nabosonen midt i stripa) stopper
  hele stripa — modellen er et rektangel. Per-bredde-klippingen kunne gått rundt den.

### Skal IKKE — holdt
`_decomposeRoomToRects` og størst-først urørt. Ingen matte over to soner (131). Ikke pushet.

### Verifiseringsmetode
`new Function` på inline-scriptet; headless Chrome 156 (CDP, port 9333) mot `serve-varmeplan.js` på
4000, uten innlogging (`#app` vist, skylagring stubbet) — harness i `/tmp/cdp130/` (`cdp.mjs`,
`setup130.js`, `steg0/steg2/bench/tests.mjs`). Utlegg via `_matFillRoomSmart(dryRun)` og ekte klikk på
«Legg ut» i sonepanelet; vakter og overlapp målt på `S.mats` etterpå. Benken kjørt tre ganger (før,
før + overlappsjekk, etter) og differansen regnet på radnivå.

### Endringslogg (kode, alt i `index.html`)
- Nye: `_matRectInsidePoly`, `_matRunWorldRects`, `_matOverlapsMats`, `_matPriorMatsFor`,
  `_matRectBlockedBy`, `_matZoneAnchorSide`, `_matZoneFreeRoom` (etter `_matZoneUsableRoom`).
- `autoFillMatSerpentine` — `opts.priorMats`: utvidet boks, låst retning, `anchorAcross/Along`, vakt.
- `_matZonePlanFor(room, rect, prod, priorMats)` — samme; `geom.anchorAcross/anchorAlong/priorMats`.
- `_matPlaceMultiMats` — ankring fra `geom`, vakt mot `geom.priorMats`.
- `_matPlanZones` — `prior` akkumuleres; `zp.extended`. `_showMatZoneProposalPanel` — tekst + commit-løkke.
- `_matBenchCheckLegal` (Regel 27), `_matBench` (zoneRect-varsel bare ved lavere), `_matZoneRegressionTest`.
- Spec `spec-matte-utlegg.md` Regel 27 (Cowork-mappa, utenfor repoet).
