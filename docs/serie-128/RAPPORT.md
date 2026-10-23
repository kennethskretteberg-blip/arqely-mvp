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

---

## 131

**Auto-matte: én matte gjennom sonene (Regel 28)** — kapitlene i rekkefølgen retningsvelgeren gir,
fritt hopp mellom kapitlene, samlet rullvalg. Committet på `main`, **ikke pushet**.

### STEG 0 — målt før endring (fila fra `321722e`, port 4000)

**0.1 Bilde 2-rommet (300 × 400 + alkove 200 × 200, EcoMat 100T, 1 cm mellomrom, velger nede til
venstre, loddrett):** to matter, én per sone — rød 18 m (5 × 360, x 23–277, 9,0 m²) + blå 7 m (4 bredder
192/192/192/120, x 278–481, 3,48 m²) = **12,48 m², 1248 W**. Med auto-retning velger hoveddelen vannrett
(7 × 264, tegnet forskjøvet, x fra −28 — SPØRSMÅL 128-1). Skjermbilde `131-01`.

**0.2 Hva en matte må kunne beskrive, og valget.** Bildet trenger bredder med ulik tvers-posisjon, ulik
lengde (384 mot 192), potensielt ulik retning per kapittel (auto velger vannrett i hoveddelen og loddrett
i alkoven), og en forbindelse uten lengde mellom kapitlene.

| | (a) `S.mats` + `chapters[]` | (b) frihånds-bane (`S.matPaths`) |
|---|---|---|
| Beskriver bildet? | Bare med ny akse/anker/rotasjon per kapittel | Ja, alt — `moves[]` med `uturn`/`jump` (129), vilkårlig akse per bane |
| Lesere som må læres opp | `S.mats`: 237 referanser; 110 direkte lesninger av `runStarts`/`runLengths`/`runAdjust`/`num_runs`/`rotation_deg`; ~80 funksjoner (tegning, kabelplan, treff, gizmo, vakt, målkjede, PDF, lister, benk) antar ÉN akse og ÉN rotasjon (`x + r·(w+gap)`, `_matRunWorldGeom`) | `S.matPaths`: 235 referanser, ~75 funksjoner — alle leser alt banen slik den er: tegning (`_drawMatPathObj`), kabel (`_drawMatPathCable`, hopp fra 129), treff/valg/dra, panel (`_matPathPanel`), 124 (`shiftCm`/`startCm`), 127 (`_matArrBegin` tar matPaths), PDF, romliste, materialliste, undo |
| Rullvalg over Σ bredder, skjøt der den faller | Må bygges (Regel B/E/H-løkka er per matte) | Finnes: `_matFreeSplitPlan` (Regel 22 pkt. 3) + `_matFreeSliceMoves` (pkt. 4) |
| Ulempe | Stor, risikabel omskriving av låst geometri | Panelet er frihånd-panelet (ingen «Kaldt felt/side», «Del så matta går opp»-bånd eller Regel E-noter); `_matFreeCatalog` utleder rullen av banens lengde, så hver bit må ha Σ = rullen |

**Valgt: (b).** Motoren planlegger geometrien som i 130 og skriver resultatet som en frihånds-bane —
ingen ny leser noe sted, `S.mats` urørt (gamle prosjekter og rektangulære rom bit-identiske).

**0.3 Velgeren per sone i dag.** `S.varmefolie.startCorner` leses av motorene ved utlegg og lagres på
matta (`mat.startCorner`); `_matRunOrder` (124 A) utleder første bredde (venstre/høyre, øverst/nederst)
og startende av det, `_matCornerFlags` styrer «fra vegg»-ankring. Sonene (130) ble lagt **størst
først**, retning per sone fra sonens eget rektangel (`_matAreaGeom`) eller brukerens lås; velgeren
påvirket aldri sonerekkefølgen, bare bredde/ende innenfor hver matte.

### Gjort (alt i `index.html`, ny seksjon «131 · ÉN MATTE GJENNOM SONENE» etter `_matPlanZones`)

1. **`_matZoneOrderFromPicker(room, rects)`** (Regel 28 pkt. 1): startsone = sonen som inneholder
   velgerens hjørne av romboksen (ligger hjørnet i et innhukk: nærmeste), deretter nærmeste sone
   (senteravstand) som grenser til den forrige (`_matRectsAdjacent`, ≥ 10 cm felles kant), størst ved
   likhet; uten nabo til den forrige: nabo til noen lagt sone, ellers nærmeste.
2. **`_matChapterBlock(room, rect, prod, priorMats)`**: ett kapittel = breddene i én sone, 130-geometrien
   (`_matZoneUsableRoom` → retning på sonens eget rektangel → `_matZoneFreeRoom` → `_matAreaGeom` →
   ankring `_matZoneAnchorSide` → Regel 9-mellomrom → `_matClipRunToRoom` per bredde) men **fylt til
   kapasitet**: N = maxRuns, hver bredde så lang rommet gir (kuttraster). Ingen rull per sone. Breddene
   regnes i verdenskoordinater (vannrett har ikke 128-1-forskyvningen). Returnerer `runs[]` og
   `_runRects` (samme form som `_matRunWorldRects`), så kapitlet er «nabomatte» for neste.
3. **Geometri størst først, rekkefølge fra velgeren.** Målt i første forsøk: med velgeren i alkoven la
   alkoven seg først og utvidet seg (Regel 27) inn i den ulagte hoveddelen over hele stripa y 3–195 —
   hoveddelen fikk ikke plass til én eneste bredde og ble utelatt. Geometrien regnes derfor fortsatt
   størst først (130); velgeren bestemmer hvilken sone kabelen *starter* i og hoppene imellom.
4. **`_matChaptersToPath`**: kapitlene → én bane. Første kapittel: første bredde og startende fra velgeren
   (124 A). Senere kapitler (`_matChapterRunOrder`): den ytterste bredden og enden nærmest der forrige
   kapittel sluttet (kortest løs kabel). Nabobredder i samme kapittel som starter der forrige sluttet og
   ligger NET + mellomrom unna: `uturn`; alt annet (kapittelskiftet, en annerledes klippet bredde):
   `jump` med `from` relativt til forrige nominelle ende (129). Et kapittel der Regel 9 måtte kappe
   mellomrommet (trang sone — bilde 2 med auto-retning: alkoven 200,5 cm bred etter den vannrette
   hoveddelen, 4 bredder → 0,17 cm) bærer sitt eget mellomrom på U-svingene (`move.gap`, lest av
   `_matFreeDeriveRuns`, kopiert av `_matFreeSliceMoves`) — ellers ble hver nabobredde der et hopp med
   stiplet strek.
5. **Rullvalg `_matChapterRollPlans(Σ, prod)`** (Regel 11): «blandet» = `_matFreeSplitPlan` (Regel 22
   pkt. 3: K klatrer bare til resten er under korteste rull, så likest); «like» = samme K, alle av én
   lengde (den største som går opp K ganger). Like er standard (pkt. 4), begge vises med tall. Første
   versjon lot «like» maksimere dekningen alene — benken ga da 13–29 små identiske ruller (U #22: 29 ×
   1 m) der blandet klarte seg med 2–3; forkastet. Går ikke minste rull opp i banen: minste brukes og
   panelet varsler (som `_matCapacityShortfall`).
6. **`_matChapterPieces`**: banen delt i biter per rull med `_matFreeSliceMoves` (skjøt der den faller,
   Regel 22 pkt. 4), hver bit med rullens produktrad og `auto: true`. Siste bredde kortes (bilde 2:
   192 → 104), utelates aldri (Regel 24). **`_matChapterCommit`**: vakt per bit (`_matPathMoveValid`:
   rom/margin/hindring/forbudt sone/areal/andre baner, pluss `_matOverlapsMats` mot `S.mats` i rommet),
   så ett undo-steg (hopper over når kalleren tok det — UPC-flyten), id-er, `S.matPaths`, valg + panel.
7. **`_matPlanZones`** returnerer nå `{ chapter: true, chapters, path, rolls, kind, plan, pieces,
   totalCm, coverCm, uncoveredCm, zonePlans (én per kapittel, `mats: []`), excludedZones, totalAreaM2,
   totalWatt }`. `_matFillRoomSmart(dryRun)` gir `{ kind: 'zone', mats: [], matPaths: pieces }`.
   `_matZonePlanFor`/den gamle per-sone-veien står igjen (bakoverkompatibilitet/lesbarhet), brukes ikke
   av nytt utlegg.
8. **Panelet `_showMatZoneProposalPanel`**: «Én matte gjennom N soner», hodelinje «1 matte · 9 bredder ·
   2 kapitler · Σ 26,9 m», én rad per kapittel (bredder à lengde, retning, «hopp fra forrige kapittel»,
   Regel 27-noten), rullvalg like/blandet med m², udekket («siste bredde kortes, Regel 24»), W, A og
   «(gir ingenting ekstra her)» som flermatte-panelet; samlet W/m² BTA; utelatte soner. «Legg ut» →
   `_matChapterCommit`. Skjermbilde `131-02`, `131-07`.
9. **Frihånd-vakten (`_matFreeClampLen`, ny parameter `noRaster`)**: vakten `_matFreeRunsWithinRoom`
   spør nå «får bredden plass?» uten å avrunde lengden til kuttrasteret. Målt: den kortede siste bredden
   (104 cm) ble avrundet til 96 og avvist som «matta ville ligget utenfor rommet». Samme avvisning
   rammet fra før 127-flytting (`_matArrEnd` → `_matPathMoveValid`) av en 129-bit med skjøt midt i
   bredden. Tegning/ghost snapper som før.
10. **Nabomatter**: `_matRunWorldRects` leser `mat._runRects` når satt (kapittel-/banestubb), og
    `_matPriorMatsFor` tar nå også frihånds-/auto-baner i rommet som «andre matter» (Regel 27 pkt. 2).
11. **Panel/ctxbar**: en bit med `auto: true` heter «Auto-matte (Regel 28)» / «Auto-matte» i stedet for
    «Frihånds-matte». 124-justering per bredde, «Mellomrom i denne matta», Sentrer, Slett, 127 «Flytt
    alle», PDF, romliste og materialliste virker uendret (det er frihånd-maskineriet).
12. **Mattebenk**: `_matBenchPathsResult` — sone-rom måles på bitene (dekning fra geometrien, antall =
    ruller, Regel 1/22 via `_matFreeRunsWithinRoom`, Regel 27 parvis). Regel 27-utelatelsen i
    `_matChapterBlock` logges som `warn` (ventet utfall, vises i panelet).
13. **Tester**: `_matZoneRegressionTest` skrevet om til kapittelplanen (11 → **17** sjekker: 1102-analog
    2 kapitler, 17 × 384 + 5 × 288, 3 × 26 m, 39,0 m² (var 32,0 med 4 matter); bilde 1-geometrien
    uendret (rød 5 × 384 x 23–277, blå 4 × 192 x0 = 278, slakk mot høyre vegg); bilde 2 start (48, 392),
    hopp ved bredde 6, 26 m, siste 104; velger i alkoven; bånd-flyten uten priorMats fortsatt 3 bredder).
    Ny **`_matChapterRegressionTest`** (14 sjekker): rekkefølge fra velgeren på tre soner,
    `_matRectsAdjacent`, trapperom tre kapitler/to hopp/ingen overlapp/innenfor rommet, Σ = biter +
    udekket, `from` bare på hopp, rullplaner (50 m: like 2 × 24, blandet 26 + 24; 1,5 m: shortfall),
    dryRun-form, siste bredde 104 godtatt av vakten, commit/undo, gammelt prosjekt med to `S.mats`
    uendret og aldri overlagt, rektangel null/single.

### Bilde 2 — før og etter (loddrett låst, 1 cm mellomrom, velger nede til venstre)

| | Før (`321722e`) | Etter 131 |
|---|---|---|
| Matter | 2 (18 m + 7 m) | **1** — én 26 m-rull |
| Bredder | 5 × 360 + 4 (192/192/192/120) | **5 × 384 + 3 × 192 + 1 × 104** (Σ bredder 26,88 m, rull 26,0 m, 0,88 m udekket) |
| Forbindelse 5 → 6 | to separate matter | **hopp**: stiplet, 51 cm på tvers / 5 cm på langs (bredde 5 slutter øverst, bredde 6 starter øverst) |
| Dekning / effekt | 12,48 m² / 1248 W | **13,0 m² / 1300 W** |
| Velger i alkoven (øvre høyre) | samme to matter | kapittel 1 = alkoven (start x 456, y 3, ned), hopp 4 → 5, kapittel 2 = hoveddelen; samme rull og Σ |
| Skjermbilder | `131-01` | `131-02` (panel), `131-03`, `131-04` (hopp, zoom), `131-05` (valgt bane), `131-06`/`131-06b` (velger i alkoven), `131-10` (PDF) |

### Test (prompten)

| # | Krav | Resultat |
|---|---|---|
| 1 | Bilde 2: én matte, 1–5 i hoveddelen, 6–9 i alkoven inntil bredde 5, hopp stiplet, Σ = Σ bredder, rullvalg som for samme lengde i ett rom | Ja (tabellen over). Antall i hoveddelen er 5 (128-marginen: 295 cm tvers / 51). Rull: 26 m = største ≤ 26,88 m, samme som `autoFillMatSerpentine` ville valgt for et rektangel med den kapasiteten. Låst i `_matZoneRegressionTest`. |
| 2 | Velger i alkoven: kapittel 1 alkoven, kapittel 2 hoveddelen | Ja (`131-06`, låst). |
| 3 | T-rom med tre soner: tre kapitler, to hopp, ingen overlapp, ingen bredde over en ekte vegg | Trapperom (600×200 + 400×200 + 200×200): 3 kapitler, 2 hopp, 2 × 20 m, alle bredder innenfor rommet, ingen overlapp (`131-08`, låst i `_matChapterRegressionTest`). Merk: et T-rom 600×200 + 200×300 stamme deles i **to** soner av `_decomposeRoomToRects`, ikke tre — det ble to kapitler og ett hopp. |
| 4 | Rektangulære rom bit-identisk | `_matPlanZones` null → uendret ETT-blokk-vei; benken: alle 106 rektangulære rader identiske (dekning og poeng). `_matRegressionTest` 2/2. |
| 5 | Gammelt prosjekt med to matter i et L-rom: uendret | `S.mats`-modellen og alle leserne er urørt; låst i `_matChapterRegressionTest` (to matter i bilde 2-rommet: uendret av planen, og en ny plan legger seg aldri oppå dem). |
| 6 | Mattebenk: ingen rom lavere; antall matter ned i sonerom; testbatterier grønne | Antall ruller ned eller likt i **alle** sonerom (ingen opp). Dekning opp i 16 av 19 endrede rom, **tre rom litt lavere** (se under). `_matRegressionTest` 2/2 · `_matZoneRegressionTest` **17/17** · `_matChapterRegressionTest` **14/14** · `_matFreeRegressionTest` 26/26 · `_matPathClickRegressionTest` 28/28 · `_matRunAdjustRegressionTest` 70/70 · `_matArrangementRegressionTest` 55/55 · `_foilRegressionTest` 9/9 · `_pdfExportSmokeTest` 20/20. Ingen konsollunntak. |

### Mattebenk-differansen (`_matBench(42, 64)`, før = `321722e` (130), etter = 131; vei 1 = vei 2)

| Rom | Dekning før | etter | Ruller før → etter | Poeng før → etter |
|---|---|---|---|---|
| 1102 Garderobe | 83,9 % | **90,8 %** | 2 → 2 | −98603 → −33000 |
| 1108 Garderobe (L) | 54,9 % | **84,1 %** | 2 → 1 | −48038 → −59878 |
| Kenneth L-rom (500×400, hakk) | 86,4 % | 84,1 % ↓ | 2 → 1 | −34214 → −59878 |
| L #16 | 73,7 % | **82,2 %** | 2 → 1 | −41313 → −25341 |
| U #17 | 0,0 % | **79,1 %** | 1 → 1 | −43252 → −13406 |
| L #18 | 89,0 % | 89,3 % | 2 → 1 | −30694 → −70098 |
| T #19 | 85,7 % | **92,8 %** | 2 → 2 | −28329 → −129711 |
| T #20 | 97,4 % | 96,0 % ↓ | 2 → 2 | −91370 → −66655 |
| T #21 | 91,8 % | 91,8 % | 2 → 1 | −97643 → −60893 |
| U #22 | 63,4 % | **89,2 %** | 3 → 2 | −71550 → −91913 |
| L #23 | 68,1 % | 69,0 % | 2 → 1 | −37838 → −88723 |
| hindring #24 | 69,1 % | **82,6 %** | 2 → 1 | −37252 → −20256 |
| hindring #25 | 45,1 % | **61,0 %** | 1 → 1 | −32681 → 849 |
| hindring #26 | 66,0 % | **75,8 %** | 1 → 1 | −6328 → −20902 |
| hindring #27 | 81,7 % | 79,0 % ↓ | 2 → 1 | −3320 → −37559 |
| hindring #28 | 66,1 % | **76,0 %** | 2 → 1 | −20882 → −59160 |
| hindring #29 | 66,9 % | **83,6 %** | 2 → 1 | −29291 → −79497 |
| hindring #30 | 84,0 % | 84,0 % | 2 → 1 | −10276 → −8930 |
| hindring #31 | 48,5 % | **78,3 %** | 1 → 1 | −25818 → 293 |

224 rader, 38 endret (19 rom × 2 veier), 29 ulovlige før og etter (alle i vei 4/frihånd, kjent),
ingen ny ulovlig. Konsollfeil fra benken 47 → **20** (Regel H-løkkene per sone er borte), 2 `warn`
(Regel 27-utelatelse i hindring #24, der 130 avviste samme 24 cm-sone med Regel D). Poengene faller
i flere rom selv om dekningen stiger: `_matBenchScore` straffer «breddespredning» (ulik lengde i to
kapitler, f.eks. 384 mot 192) og måler endevegg-symmetri som 0 for en bane — poengformelen er laget for
én sentrert blokk per matte og sier lite om en kapittelbane. Ikke rørt.

**De tre rommene med lavere dekning** skyldes rullvalget, ikke geometrien (Σ bredder er ≥ før i alle):
- *Kenneth L-rom* og *hindring #27* (benkens 150T, auto-retning): Σ 25,92 m → blandet stopper ved
  K = 1 (24 m, rest 1,92 m < korteste rull 2 m — Regel 22 pkt. 2), 12,0 m² med **én** rull; 130 la to
  ruller (18 m + 7 m / 18 m + 8 m) = 12,4 m². Regel 11 pkt. 1 (færrest matter) foran pkt. 2 (dekning).
  Vannrett hoveddel i 130-tallet har dessuten 128-1-forskyvningen i grunnlaget.
- *T #20*: Σ 65,6 m → «like» (standard) 2 × 32 m = 32,0 m², «blandet» 60 m + 9 m = 32,5 m²; 130 fikk
  32,48 m² med flermatte-løseren. Brukeren ser begge i panelet.

### Funn utenfor scope (ikke rettet)

- **Siste bredde kan bli kortere enn ett kuttintervall** (T-rom 600×200 + 200×300 stamme: Σ 29,76 m →
  28 m-rull, siste bredde **16 cm**). Regel 24 sier «først når det gjenstående er under ett kuttintervall
  faller den bort», men `_matFreeCatalog` utleder rullen av banens lengde (Σ ≥ rullen), så å fjerne
  stubben ville lest biten som en kortere rull. Den gamle motoren kunne også gi en sub-raster siste
  bredde (`last_run_length_cm`). Spørsmål 131-2.
- **«Like» mot «blandet»**: med `_matFreeSplitPlan` sin stopp («rest under korteste rull») kan en annen
  K-kombinasjon dekke mer (Kenneth L-rom: K = 2 gir 25,0 m mot 24,0). Spørsmål 131-1.
- **Auto-retning per kapittel** gir vannrett hoveddel + loddrett alkove i bilde 2 (`131-09`, 3 × 9 m
  med «like», 13,5 m²; blandet 1 × 26 m, 13,0 m²). Virker (kapitlet bærer eget mellomrom), men
  hoveddelen får 7 × 288 i stedet for 5 × 384 — retningsvalget er fortsatt estimatet fra 128-1.
- **Panelet etter commit er frihånd-panelet**: «Kaldt felt/side», «Del så matta går opp»-båndet og
  Regel E-notene (fra `S.mats`-panelet) finnes ikke for en bane. Bredder/Dekker/Udekket/Effekt/areal vises.
- **`_matZonePlanFor`/`_matMultiSolve` per sone** er nå død for nytt utlegg (står for lesbarhet);
  benkens «zoneRect-avvik»-blokk finner ingen `mode === 'single'` lenger og er en no-op.
- **Materiallista i headless-testen** ga tom liste for EcoMat — `_collectMaterialItems` krever trolig
  prosjekt-/romkontekst harnessen ikke setter; PDF-spesifikasjonen viser «Matte · EcoMat 100T 0,5×26m ·
  1 stk · 1300 W» (`131-10`), og romstatistikken 13,0 m² / 1300 W.

### Skal IKKE — holdt
Ingen restfelt på tvers (132). Frihånd-tegningen er ikke endret (kun datamodellen gjenbrukt; `move.gap`
og `noRaster` er tillegg som ikke endrer tegneflyten). Ikke pushet.

### Verifiseringsmetode
`new Function` på inline-scriptet; headless Chrome 156 (CDP, port 9333) mot `serve-varmeplan.js` på
4000 uten innlogging — harness i `/tmp/cdp131/` (`cdp.mjs`, `setup130.js`, `steg0_131.mjs` (i
`/tmp/cdp130/`), `steg2.mjs`, `measure_zone.mjs`, `lower.mjs`, `t20.mjs`, `tests.mjs`, `bench.mjs`,
`shots.mjs`, `zoom.mjs`). Utlegg via `_matFillRoomSmart(dryRun)` og ekte klikk på «Legg ut»; vakter,
overlapp og lengder målt på `S.matPaths` etterpå; PDF fanget via `jsPDF.save`-stubb og rendret med
`pdftoppm`. Benken kjørt mot 130-kjøringen (`/tmp/cdp130/bench-after2.json`) og differansen regnet på
radnivå.

### Endringslogg (kode, alt i `index.html`)
- Nye: `_matPickerCornerPt`, `_matRectEdgeDist`, `_matRectsAdjacent`, `_matZoneOrderFromPicker`,
  `_matChapterBlock`, `_matChapterRunOrder`, `_matChaptersToPath`, `_matChapterRollCands`,
  `_matChapterRollPlans`, `_matChapterPlanStats`, `_matChapterPieces`, `_matPathLaneRects`,
  `_matChapterCommit`, `_matBenchPathsResult`, `_matChapterRegressionTest`.
- Omskrevet: `_matPlanZones` (kapittelplan), `_showMatZoneProposalPanel`, `_matZoneRegressionTest`.
- Endret: `_matFillRoomSmart` (dryRun → `matPaths`), `_matRunWorldRects` (`_runRects`),
  `_matPriorMatsFor` (baner som naboer), `_matFreeDeriveRuns` (`move.gap`), `_matFreeSliceMoves`
  (kopierer `gap`), `_matFreeClampLen` (`noRaster`) + `_matFreeRunsWithinRoom`, `_matPathPanel` og
  ctxbar-etiketten (`auto`), `_matBenchRunVei1/2`.
- Spec `spec-matte-utlegg.md` Regel 28 (Cowork-mappa, utenfor repoet): auto bekreftet og bygget.

## 132

**Auto-matte: restfelt som er for smale for en bredde i hovedretningen fylles med korte tverrlagte
stykker som fortsettelse av samme matte (Regel 29).** Committet på `main`, **ikke pushet**.

### STEG 0 — målt før endring (fila fra `fefc638`, port 4000)

**0.1 Bilde 2-rommet etter 131** (300 × 400 + alkove 200 × 200, 1 cm mellomrom, loddrett låst, velger nede
til venstre), restfeltene (maksimale ledige rektangler etter at de 9 breddene ligger — målt med et eget
rutenett-søk i harnessen, samme metode som senere ble `_matFreeFieldRects`):

| Restfelt | Mål | 100T (grense 2 × 12 + 8 + 5 = **37**) | 150T (grense 2 × 8 + 8 + 5 = **29**) |
|---|---|---|---|
| Venstre for hoveddelen (x 0–23) | 23 × 400 cm, 0,92 m² | under — udekket | under — udekket |
| Høyre for hoveddelen under alkoven (x 277–300) | 23 × 205 cm, 0,47 m² | under | under |
| Høyre for alkoven (x 481–500) | 19 × 200 cm, 0,38 m² | under | under |
| Endestriper (y 0–8, 392–400, 0–3) | 3–8 cm brede | ikke felt | ikke felt |

**Regel 29 gir ingenting i bilde 2-rommet slik det er modellert.** Hoveddelen (300 cm) tar 5 bredder
(254 cm) med 23 cm slakk på hver side, og alkoven (200 cm) tar 4 bredder fra x 278 til 481 — 19 cm igjen.
Kenneths stripe på **61 × 200 cm** finnes ikke i denne geometrien (tegningen hans har 6 + 3 bredder, altså et
bredere rom). Merk også: i motoren ville en 61 cm bred stripe fått en **vanlig** bredde (50 + 1 mellomrom +
2,5 margin = 53,5 ≤ 61) — «Skal IKKE legge tverrstykker der det er plass til en vanlig bredde». Kenneths
eget regnestykke (50 + 8 + 5 = 63 > 61) bruker naboavstand og kabelkrav i stedet for mellomrom og
nettmargin. Spørsmål 132-1. For testene er det derfor laget en **variant A**: 300 × 380 + alkove 226 × 200
(44 cm rest til høyre i alkoven), der 100T får 3 stykker à 24 cm og rullen går fra 24 til 26 m.

**0.2 Hvordan motoren finner restfelt i dag: den gjør det ikke.** `_decomposeRoomToRects` rasteriserer
rommet minus hindringer/forbudte soner i 6–12 cm celler og tar ut største rektangel grådig
(`_largestRectInGrid`, histogram) — uten matter, og for grovt for grenser på 29/37 cm.
`_matZoneFreeRoom` (130) skyver en soneboks 1 cm om gangen inn i ledig naboplass (`_matRectBlockedBy`)
— utvider, søker ikke. Ingen «ledig rektangel»-funksjon på eksakte koordinater fantes. Ny
`_matFreeFieldRects`: komprimert rutenett av **alle** kantkoordinater (rom-, hindrings-, sonehjørner og
breddekanter), hver rute helt ledig eller helt opptatt, alle maksimale rektangler (radpar × kolonneløp som
ikke kan vokse opp/ned). Gjenbruker `ptInPoly`, `_matRectBlockedBy`, `_matZoneAnchorSide`,
`_matRunWorldRects`, `_matResolveGapCm`, `_matWallMarginCm`.

**0.3 Datamodellen fra 131 beskriver et kapittel med annen rotasjon.** Banen er en frihånds-bane:
`_matFreeDeriveRuns` leser `axis` per move, så `jump` inn i en vannrett bredde etter loddrette (og
`uturn` mellom vannrette) virker uendret — ingenting i tegning, kabel, treff, 124-justering, oppdeling i
ruller, PDF eller lister antar én akse. Det eneste nye i modellen er et flagg `cross: true` per move
(etikett «tverr»); `_matFreeSliceMoves` tar det med seg.

### Gjort (alt i `index.html`, ny seksjon «132 · RESTFELT PÅ TVERS» etter `_matChapterBlock`)

1. **Grensene fra produktet:** `MAT_CROSS_NEIGHBOUR_CM = 8` (ny konstant, Kenneths tall),
   `_matCrossMinFieldCm(prod)` = 2 × CC + 8 + `MAT_CABLE_WALL_CM` (150T **29**, 60T/100T **37**),
   `_matCrossMinPieceCm(prod)` = 2 × CC (16 / 24). Ingen tall hardkodet utover de to konstantene.
2. **`_matFreeFieldRects(room, occupied)`** (0.2) og **`_matFieldEdgeBounds(field, occupied)`**: hva som
   begrenser hver kant av et felt — en lagt bredde (`mat`, `full` når bredder dekker hele kanten) eller
   vegg/hindring/forbudt sone. Klaringen følger av det: stykkets **ende** mot en matte 8 cm, mot vegg
   Regel 12-margin (2,5/3 cm); stykkets **side** mot en matte brukerens mellomrom (Regel 9), mot vegg
   margen.
3. **`_matCrossFieldChapter(room, prod, field, occupied)`**: stykkene langs feltets smale akse (smal i x →
   vannrette stykker stablet i y), lengde = smal side − klaringer, avrundet **ned til kuttrasteret** (2 × CC),
   minst 2 × CC; antall = ⌊(lang side − klaringer + mellomrom) / (50 + mellomrom)⌋. Ankring som 131: inntil
   nabomatta når den enden er en matte (slakken mot veggen, Regel 20 pkt. 4), begge vegger → sentrert.
   Vakt per stykke (`_matRectBlockedBy`: rom med margin, hindring, forbudt sone, lagte bredder). **Først**
   sjekkes «Skal IKKE»: får en vanlig bredde plass langs feltets lange akse (50 + klaringer på tvers og
   minstelengde på langs), returneres `skipped: 'normal'` og feltet rører ikke (logges som `warn`).
   Så grensen: smal side < 29/37 → `'under'`.
4. **`_matCrossFillChapters(room, prod, prior)`**: største ledige felt først, legg, søk på nytt (feltene
   endrer seg) til ingen felt kan fylles (tak 12). Returnerer kapitlene og **restfeltene som ble stående**
   (smal side ≥ 10 cm og lang side ≥ mattebredden — margin-striper er ikke «felt») med grunn.
5. **`_matPlanZones`**: etter 131-kapitlene (og velgerens rekkefølge) kalles tverrfyllingen med `prior`
   (kapitlene som nabomatter + det som alt ligger i rommet). Tverrkapitlene legges **sist i banen**,
   nærmest forrige kapittel først (kortest løs kabel). En sone 131 utelot, men som nå har fått stykker,
   fjernes fra «utelatt». Nytt felt `restFields` på planen; `zonePlans[i].cross`/`fieldNarrowCm`.
6. **`_matChaptersToPath`**: inn i et tverrkapittel alltid `jump` (annen akse), stykkene imellom `uturn`
   (de har samme start og lengde, ligger NET + mellomrom unna — 131-vilkåret), `cross: true` på hvert
   move, `chapters[i].cross`. `_matFreeSliceMoves` kopierer flagget (også når en rull begynner i et
   tverrstykke).
7. **Rullvalget** er uendret (`_matChapterRollPlans` over hele Σ). Er rullen brukt opp før stykkene,
   faller de utenfor (`_matChapterPieces` skjærer ved rullens lengde) — Regel 22 pkt. 2-mønsteret.
8. **Panel `_showMatZoneProposalPanel`**: hodelinje «12 bredder (3 tverr)», rad «Kapittel 3 — restfelt
   0,9 m² (44 cm bredt) · 3 tverrstykker à 24 cm · vannrett · på tvers av hovedretningen (Regel 29) · hopp
   fra forrige kapittel»; per kapittel «utenfor rullen — legges ikke (Regel 22 pkt. 2)» / «delvis utenfor
   rullen» når Σ før kapitlet ligger forbi rullen; udekket-teksten sier «tverrstykkene faller utenfor
   rullen» når det er dem det gjelder; ny grå note «Restfelt under grensen for tverrstykker (37 cm for
   EcoMat 100T, Regel 29) — udekket: 23 × 400 cm, … (2,0 m²)» (felt ≥ 0,1 m²). Skjermbilder `132-01`,
   `132-05`, `132-06`, `132-08`, `132-09`.
9. **Etiketten «tverr»**: ctxbar-breddepanelet (`_matRunPanelHtml`: «Bredde 10 av 11 · tverr · 24 cm», og
   «under minste lengde»-merknaden gjelder ikke tverrstykker — Regel 29 pkt. 2 er grensen), bane-panelet
   (`_matPathPanel`: «5 × 3,6 m + 4 × 1,9 m + 1 × 0,2 m tverr + …»), og lengde-etiketten i planen
   («0,2 m tverr», `_drawMatPathObj` — samme tegner gir PDF-en). 124-justering (dra sidelengs, S-håndtak,
   Start +) virker på stykkene som på alle baner (`132-04`).
10. **Ny `_matCrossFillRegressionTest()`** — 23 sjekker: grensene 37/29 og 24/16 fra produktet;
    `_matFreeFieldRects` (tomt rom → ett felt; én bredde midt i → fire maksimale felt);
    `_matFieldEdgeBounds`; «Skal IKKE» (60 × 300-felt → `normal`); variant A 100T (tre kapitler, 3 × 24 cm
    vannrett, x 490,25–514,25 (8 cm fra nabobredden, slakk mot veggen), y 24/75/126 (sentrert), Σ 26,4 m
    → 26 m der 131 (Σ 25,68) ga 24 m, 13,0 m², banen `f u u u u j u u u jX uX uX`, ingen overlapp, vakten
    ok, restfelt meldt fylt/udekket); oppdeling i ruller tar `cross` med (26 m-biten ender i tverrstykkene
    med en 8 cm stubb); dryRun-form; commit (vakten godtar 24 cm-stykker, Σ = rullen), tegneren uten
    unntak, breddepanel «Bredde 10 av 11 · tverr», angre; variant A 150T (3 × 32 cm, Σ 27,04 m); rest 30 cm
    (100T udekket under 37 og 131-banen uendret; 150T 3 × 16 cm); bilde 2 (ingen tverrkapittel, 9 bredder,
    Σ 26,88 m, start (48, 392), restfeltene 23/23/19 meldt udekket).

### Bilde 2 og variantene — før og etter (loddrett låst, 1 cm mellomrom, velger nede til venstre)

| Rom | Produkt | Restfelt (smal side) | Grense | Tverrstykker | Σ bredder før → etter | Rull før → etter | Dekning før → etter |
|---|---|---|---|---|---|---|---|
| Bilde 2 (300×400 + 200×200) | 100T | 23 / 23 / 19 cm | 37 | ingen — udekket | 26,88 m | 26 m | 13,0 m² (81,3 %) — **bit-identisk 131** |
| Bilde 2 | 150T | 23 / 23 / 19 cm | 29 | ingen — udekket | 26,88 m | 26 m | 13,0 m² — bit-identisk |
| Variant A (300×380 + 226×200) | 100T | **44 cm** (x 482–526) | 37 | **3 × 24 cm**, vannrett | 25,68 → 26,40 m | 24 → **26 m** | **12,0 → 13,0 m²** (75,4 → 81,7 % av 15,92 m²) |
| Variant A | 150T | 44 cm | 29 | 3 × 32 cm | 25,68 → 27,04 m | 24 → 26 m | 12,0 → 13,0 m² — stykkene faller utenfor rullen (Σ hovedbredder 26,08 > 26) |
| Rest 30 (300×400 + 211×200) | 100T | 30 cm | 37 | **ingen** — meldt udekket | 26,88 m | 26 m | 13,0 m² |
| Rest 30 | 150T | 30 cm | 29 | **3 × 16 cm** | 26,88 → 27,36 m | 26 m | 13,0 m² — stykkene utenfor rullen |
| Alkove 226 × 200 (bilde 2 med bredere alkove) | 100T | 45 cm | 37 | 3 × 24 cm | 26,88 → 27,60 m | 26 m | 13,0 m² — utenfor rullen |
| T-rom tre soner | 100T | 24 / 24 / 20 / 20 / 16 cm | 37 | ingen | 29,76 m | 28 m | 14,0 m² — uendret |

Stykkene dekker bare når Σ passerer neste rullengde (variant A 100T: 25,68 → 26,40 ≥ 26,0). Ellers planlegges
de, vises i panelet som «utenfor rullen — legges ikke», og `_matChapterPieces` skjærer dem bort ved commit
— dekningen er da uendret, aldri lavere. Variant A 100T etter commit: 26 m-rullen slutter **8 cm inn i
stykke 2** (`j/h+24 · u/h−8`) — en stubb under 2 × CC (spørsmål 132-2, samme sak som 131-2).

### Test (prompten)

| # | Krav | Resultat |
|---|---|---|
| 1 | Bilde 2 med 100T: reststripa fylles, tre stykker, dekning stiger målbart; 150T: 29-grensen | Bilde 2 slik det er modellert har ingen stripe over grensen (STEG 0.1). **Variant A** (44 cm rest): 100T 3 × 24 cm, 12,0 → 13,0 m² (75,4 → 81,7 %); 150T 3 × 32 cm (29-grensen), planlagt, men utenfor 26 m-rullen → 13,0 m² uendret. Låst i `_matCrossFillRegressionTest`. |
| 2 | Reststripe 30 cm: 100T ikke fylt (udekket vises), 150T fylt | Ja: 100T «Restfelt under grensen … 30 × 200 cm» i panelet, 131-banen uendret (`132-06`); 150T 3 × 16 cm (`132-08`). Låst. |
| 3 | Rom uten restfelt: bit-identisk med 131 | Bilde 2 100T/150T: samme 9 moves, start (48, 392), Σ 26,88 m, samme biter (låst). Benken: 216 av 224 rader identiske (dekning, ruller, poeng). `_matZoneRegressionTest` 17/17, `_matChapterRegressionTest` 14/14. |
| 4 | Mattebenk: flere rom høyere, ingen lavere; tid ≤ +20 % | **4 rom høyere** (8 rader, vei 1 = vei 2), **0 lavere**, ingen ny ulovlig (29 før/etter, alle vei 4/frihånd som før). Tid: `_matBench(42, 64)` median av 7 kjøringer **98 → 102 ms** (+4 %, 0,44 → 0,46 ms/rad). |
| 5 | Batterier, `_matChapterRegressionTest`, `_pdfExportSmokeTest`, ny `_matCrossFillRegressionTest` | `_matRegressionTest` 2/2 · `_matZoneRegressionTest` 17/17 · `_matChapterRegressionTest` 14/14 · **`_matCrossFillRegressionTest` 23/23** · `_matFreeRegressionTest` 26/26 · `_matPathClickRegressionTest` 28/28 · `_matRunAdjustRegressionTest` 70/70 · `_matArrangementRegressionTest` 55/55 · `_foilRegressionTest` 9/9 · `_pdfExportSmokeTest` 20/20. Ingen konsollunntak. PDF av variant A (`132-10`): stykkene tegnet med «tverr»-etikett, spesifikasjon «Matte · EcoMat 100T 0,5×26m · 1 stk · 1300 W», romstatistikk 13,0 m² / 1300 W. |

### Mattebenk-differansen (`_matBench(42, 64)`, før = `fefc638` (131), etter = 132; vei 1 = vei 2)

| Rom (150T, auto-retning) | Restfelt → tverrstykker | Σ hoved → Σ | Rull 131 → 132 | Dekning før → etter | Poeng |
|---|---|---|---|---|---|
| L #23 | 41,5 × 260 → 5 × 16 cm | 13,92 → 14,72 m | 12 → **14 m** | 69,0 % → **80,6 %** | −88723 → −91477 |
| hindring #25 | 40 × 126 → 2 × 16; 43 × 284 → 5 × 32; 40 × 105 → 1 × 16 | 8,16 → 10,24 m | 8 → **10 m** | 61,0 % → **76,3 %** | 849 → −58911 |
| hindring #26 | 52 × 242 → 4 × 32 cm | 17,28 → 18,56 m | 16 → **18 m** | 75,8 % → **85,3 %** | −20902 → −58881 |
| hindring #27 | 31 × 69 → 1 × 16; 63 × 77 (for kort for en bredde) → 1 × 48 | 25,92 → 26,56 m | 24 → **26 m** | 79,0 % → **85,6 %** | −37559 → −58651 |
| hindring #24 | 32,5 × 156 → 2 × 16; 32,5 × 82 → 1 × 16 | 22,72 → 23,20 m | 22 → 22 m | 82,6 % uendret — stykkene utenfor rullen | — |
| hindring #28 | 38 × 216 → 4 × 16; 38 × 115 → 2 × 16 | 16,96 → 17,92 m | 16 → 16 m | 76,0 % uendret | — |
| hindring #31 | 43,5 × 219 → 4 × 32 | 16,64 → 17,92 m | 16 → 16 m | 78,3 % uendret | — |

Poengene faller der dekningen stiger: `_matBenchScore` straffer breddespredning (16 cm mot 384 cm) — samme
formel-svakhet som i 131, ikke rørt. Konsoll fra benken: 2 → 4 `warn` (de to nye er «restfelt med plass til
en vanlig bredde — ikke lagt», rom hindring #30, se funn), `error` 35 → 35 (alle Regel H-taket i
`autoFillMatSerpentine`, som før).

### Funn utenfor scope (ikke rettet)

- **Stubb under 2 × CC der rullen slutter i et tverrstykke** (variant A 100T: 24 + 8 cm). Regel 29 pkt. 2
  sier minst to kabelstrenger; `_matFreeCatalog` leser rullen av banens lengde (Σ ≥ rullen), så å fjerne
  stubben ville lest biten som en 24 m-rull — nøyaktig 131-2. Spørsmål 132-2.
- **Restfelt med plass til en vanlig bredde** (benk hindring #30, 378 × 518 med en 49 × 48 cm hindring i
  hjørnet): etter at hovedkapitlet er lagt står feltet x 59–378 × y 0–60 (319 × 60 cm) igjen — en vannrett
  bredde på 319 cm får plass (60 − 1 − 3 ≥ 50). 131 utelot sonen med Regel 27 («kapitlet ville overlappet
  en nabomatte»); 132 legger etter regelen ikke tverrstykker der, logger `warn` og lar det stå. Spørsmål
  132-5.
- **Rektangulære rom** går fortsatt S.mats-veien (`_matPlanZones` null) og får ingen Regel 29 — med «fra
  vegg» ligger 30–41 cm slakk langs én vegg (300 cm bredt rom), som ville kvalifisert. Å ta dem inn
  betyr at rektangulære rom blir `S.matPaths` (frihånd-panelet, ikke auto-panelet). Spørsmål 132-4.
- **Kuttrasteret** gjør stykkene korte: 44 − 8 − 2,5 = 33,5 → 24 cm (100T). Kenneths «ca. 55–60 cm» i en
  61 cm stripe tyder på kutt per kabelstreng (CC), ikke per to. Spørsmål 132-3.
- **Alkove høyere enn ~228 cm** i bilde 2-formen får `_decomposeRoomToRects` til å bytte største sone
  (526 × 258 over 300 × 400) — hoveddelen blir et 142 cm høyt kapittel med 5 × 144 cm. Ikke 132-sak,
  men forklarer hvorfor «alkove 226 × 260» ikke ble et testrom.
- **Panelet viser to like rull-rader** («1 rull … (gir ingenting ekstra her)») — 131-6, står.
- **Kabeltegneren viser én streng i et 24 cm-stykke.** `_drawMatPathCable` finner to strengposisjoner
  (cc/2 og 3cc/2 fra kuttkanten), men flukt-invarianten (`_matCableEntrySide`: inn på siden mot forrige
  bredde, ut mot neste — delt med auto) kapper antallet til oddetall når inn- og utside er lik; i variant A
  (inn ovenfra, stubben under) blir 2 → 1 streng (målt: én strek 496,2 / 32,5–65,5 og endemarkøren der).
  Dekning, effekt og lister er geometriske og uberørt; bare kabelstreken i planen/PDF viser én streng der
  Regel 29 pkt. 2 sier to. Tegnerens paritetsregel, ikke 132-geometrien — ikke rørt.

### Skal IKKE — holdt
Ingen tverrstykker der en vanlig bredde får plass (vaktet i `_matCrossFieldChapter`, låst i testen).
Grensene leses fra produktet (`mat_cc_mm`) og konstantene (`MAT_CROSS_NEIGHBOUR_CM`, `MAT_CABLE_WALL_CM`).
Ikke pushet.

### Verifiseringsmetode
Headless Chrome (CDP, port 9333, egen tab per skript) mot `serve-varmeplan.js` på 4000 uten innlogging —
harness i `/tmp/cdp132/` (`cdp.mjs`, `setup130.js`, `steg0.mjs` (restfelt-måling), `plan.mjs`,
`variantA.mjs` (plan + ekte «Legg ut»-klikk + panel/ctxbar-tekst + angre), `tests.mjs`, `bench.mjs`,
`benchdetail.mjs`, `timing.mjs` (7 kjøringer, median), `shots.mjs`, `zoom.mjs`). Benken kjørt på `fefc638`
før endringen (`bench-before.json`) og etter, differansen regnet på radnivå. PDF fanget via `jsPDF.save`-stubb
og rendret med `pdftoppm`.

### Endringslogg (kode, alt i `index.html`)
- Nye: `MAT_CROSS_NEIGHBOUR_CM`, `_matCrossMinFieldCm`, `_matCrossMinPieceCm`, `_matFreeFieldRects`,
  `_matFieldEdgeBounds`, `_matCrossFieldChapter`, `_matCrossFillChapters`, `_matCrossFillRegressionTest`.
- Endret: `_matPlanZones` (tverrkapitler sist, `restFields`, utelatt-filter), `_matChaptersToPath`
  (`cross` på moves/chapters), `_matFreeSliceMoves` (kopierer `cross`), `_showMatZoneProposalPanel`
  (restfelt-rad, «utenfor rullen», udekket-tekst, grå note), `_matRunPanelHtml` («tverr», ingen
  minstelengde-merknad), `_matPathPanel` (bredder-linja), `_drawMatPathObj` (lengde-etikett).
- Spec `spec-matte-utlegg.md` Regel 29 (Cowork-mappa, utenfor repoet): «UTKAST» fjernet, auto bekreftet og
  bygget i 132. Skjermbilder `docs/serie-128/skjermbilder/132-*`.
