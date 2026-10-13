# Arkitektur — ny geometrisk utleggsmotor for varmekabel

Forslag etter 068s målinger. Følger lag A–H i `spec-kabelmotor.md` §4.
Status 13.10.2026: **forslag, ikke bygget.** Bygges i 069 bak en bryter.

---

## 0. Det målingene endrer på premisset

Prompten antok at feilen satt i celleoppdelingen (lag B–D). Det stemmer — men den
sitter **ett lag lenger ned enn som så**, og den sitter også i renderingen:

> **Kabelen har ingen geometri i datamodellen.** `runs[]` beskriver bare de *rette løpene*.
> U-svingene, vegg-følge-linjene og overgangene mellom celler finnes bare som tegne-
> instruksjoner i `_drawCableUTurns`, i skjermkoordinater, og regnes om på nytt — med
> *andre formler* — i `_calcTotalCableLength` og `_cableWorldSegments`.

Tre representasjoner, tre svar. Målt på Kenneths bad, vertikalt:

| Hvem spør | Hva den sier |
|---|---|
| Rendereren (det Kenneth ser) | 51,03 m |
| `_calcTotalCableLength` (lengden i panel/materialliste) | 46,99 m |
| `_cableWorldSegments` (dekningen i romstatistikken) | 46,39 m |

Ingen av dem er feil *i seg selv* — de regner bare på hver sin ting. Men så lenge det er
slik, kan **ingen** kontroll si noe sant om utlegget, og en ny motor ville arve problemet
i det øyeblikket den leverte `runs[]`.

**Konsekvens for arkitekturen:** den nye motoren produserer en **eksplisitt senterlinje**
som førsteklasses data, ikke som en bieffekt av tegning.

---

## 1. Dataformat (kontrakten mot resten av appen)

`_cableCenterlinePaths(cable)` (bygget i 068) er allerede den felles leseren: den
rekonstruerer senterlinjen fra begge dagens former, tro mot rendereren. Den nye motoren
snur dette rundt og **leverer** senterlinjen direkte.

### Hva nedstrøms faktisk leser

Kartlagt i 068 (STEG 0.5). Disse feltene må fortsatt finnes, uendret:

| Felt | Lest av | Merknad |
|---|---|---|
| `roomId`, `productId`, `id` | alt | |
| `totalLength_cm` | `_computeRoomStats` (effekt, lengde), materialliste, PDF, XLSX, Visma, kabelpanel | **må bli lik den lagte lengden** — i dag er den det ikke |
| `spacing_cm` | `_computeRoomStats` (flateeffekt = W/m ÷ CC), label, `_ccLimits`-sjekker | |
| `cc_mm` | label | avledet av `spacing_cm` |
| `direction` | `drawCables`, `_cableWorldSegments`, dra-redigering, `_buildNCableZones` | |
| `startCorner` | `_uTurnIsHigh` (hvilken ende svingen går ut) | bare meningsfull i `runs`-form |
| `runs[{pos_cm, segments[{start_cm,end_cm}]}]` | `drawCables`, `_calcTotalCableLength`, `_cableWorldSegments`, `_shiftCableRuns`, `_buildCellInfo`, dra-redigering, sone-statistikk | |
| `pathEls[{kind:'run'/'uturn'/'connector', …}]` | `_drawCableSkewPath`, `_cableWorldSegments`, `_offsetCableClone` | skew-formen |
| `connections[{path:[{x,y}]}]` | `drawCables` | tegnes, men telles ikke i lengden |
| `coverage` (0–1) | `_finishCableAutoFill`, `_cableCoverageFrac` | bare `pathEls`-form |
| `_engine` | debug, `_computeRoomStats`-gren, sone-splitt | |
| `labelOnly`, `reserve`, `zoneId`, `multiCableGroup`, `leadRun`, `zoneBounds`, `lockedStart/End`, `_chainBreaks` | respektive moduler | røres ikke |

### Valget

**Motoren leverer `pathEls`-form** (den skew allerede bruker), utvidet med et
`centerline`-felt:

```
cable.pathEls   = [...]              // uendret kontrakt, tegnes av _drawCableSkewPath
cable.centerline = [{x,y}, ...]      // NY: én ordnet punktliste, world-cm, kilden til alt
cable.totalLength_cm                 // målt på centerline, ikke gjettet
cable.runs = []                      // tom, som skew i dag
```

Grunner:
1. `pathEls` er **allerede** en ordnet bane — ingen gjetting om U-svinger.
2. Rendering, lengde og dekning kan alle lese `centerline` → **én sannhet**, og uenigheten
   over forsvinner av seg selv for nye utlegg.
3. Ingen nedstrøms ombygging: `pathEls`-veien er bygget og i bruk (skew), `_offsetCableClone`
   (fryserom-reserve) håndterer den, PDF/materialliste leser bare `totalLength_cm`/`spacing_cm`.

**Prisen:** dra-redigering er slått av for `pathEls` i dag («skew cables are auto-fill-only»).
Den nye motorens utlegg blir dermed også auto-fill-only i første runde. Det er et bevisst
valg — et utlegg som er validert mot §1 og så dras ut av lovlig område er verre enn et
som ikke kan dras. Manuell redigering tas som egen runde, med kontrollen på hvert dra-steg.

---

## 2. Lag A–H — hva som gjenbrukes, hva som er nytt

| Lag | Gjenbruk | Nytt |
|---|---|---|
| **A** Normalisering | `_cableLegalRegion` (068, clipper-lib) er ferdig — rom − kantavstand − hindringer − soner, ekte polygon-offset | validering av smale passasjer og små restområder |
| **B** Celleoppdeling | `_v6AnalyzeTopology` + `_v6DecomposeCells` er brukbare som **analyse** (de finner kritiske punkter riktig) | cellene må bære *hvilke løp i det globale rutenettet* de inneholder — ikke sin egen lokale bredde |
| **C** Global avstand | ingenting | **kjernen i hele runden** (se §3) |
| **D** Rute | `_v6ConnectCells`' idé (exit/entry-valg, ortogonal ruting langs cellegrensen) | graf over celler, flere rekkefølger prøves, overgangen må *erstatte* U-svingen, ikke komme i tillegg |
| **E** Svinger | `_skUturnPolyline` (ren halvsirkel, samplet) | plassering: svingen må ligge **innenfor** lovlig område, ikke CC/2 utenfor løpets ende |
| **F** Lengde | `generateCableSkew`s bisekssjon på CC er riktig mønster | søket må også variere faseforskyvning og symmetrisk inntrukne vendepunkter — og måle, ikke tilordne |
| **G** Start/slutt | `S.varmefolie.startCorner`, `_scoreCableCandidate` | hjørnekandidater må ha samme kantmargin som vendepunktene |
| **H** Optimalisering | `_scoreCableCandidate` | `_cableGeometryCheck` som **filter** (harde krav), poeng bare blant de som består |

---

## 3. Lag C — global fase, den egentlige rettelsen

Dagens feil, i `_v6SweepCell` (:24702):

```js
const cellWidth = pMax - pMin;
const nRuns     = Math.floor(cellWidth / spacing_cm) + 1;
const sideM     = (cellWidth - (nRuns - 1) * spacing_cm) / 2;
const firstPos  = pMin + sideM;          // ← HVER CELLE SENTRERER SITT EGET RUTENETT
```

To naboceller med ulik bredde får ulik `sideM`, altså ulik fase. Over cellegrensen blir
avstanden mellom to løp hva som helst. Målt i badet: 11,09 cm på den ene siden, **22,18 cm**
over grensen — Kenneths «forskjellige CC-avstander», i to tall.

Den nye motoren snur det:

```
ÉTT rutenett for hele rommet:   pos_i = x0 + i × CC,  i = 0 … N-1
x0 velges én gang, av rommets lovlige område:  x0 = perpMin + (W − (N−1)×CC)/2
Hver celle sier bare HVILKE i den inneholder. Ingen celle regner sin egen x0.
```

Da er CC konstant per konstruksjon, og kantavstanden symmetrisk fordi `x0` er valgt én gang
mot hele rommet. Formelen er spec §4C, generalisert fra bredde W til lovlig områdes
perpendikulære utstrekning.

---

## 4. Lag E — svingene innenfor lovlig område

Dagens regel (LÅST i CLAUDE.md, og riktig *som regel*): `sweepMargin = margin + CC/2`,
U-sving = halvsirkel med radius CC/2. Problemet er ikke regelen, men at **ingen sjekker at
den holder**:

- Marginen settes mot **omsluttende rektangel**, ikke mot polygonet
  (`_skGenerateRotated` :25418 `bb.minX + margin`; `_v6BuildHeatableArea` :24394
  `Math.min(...perpVals) + margin`). En skrå eller trappet vegg ligger innenfor det
  rektangelet, og løpet havner for nær den. Målt i badet: **0,83 cm** fra veggen der 5 cm
  kreves, over 213 cm av banen — også i det «perfekte» horisontale utlegget.
- Når to naboløp har **ulik** lengde, tegnes svingen ved den korteste enden pluss to rette
  «vegg-følge»-linjer. De linjene er Y-greiner — nøyaktig det CLAUDE.md forbyr — og de
  klippes ikke mot rommet.

Ny regel: **hver sving kontrolleres mot lovlig område før den godtas.** Går den ikke inn,
trekkes *begge* vendepunktene symmetrisk inn til den gjør det (lag F har allerede dette som
søkeparameter). Er `min_bend_radius > CC/2`, brukes en validert alternativ sving eller CC økes
— aldri en halvsirkel som ikke passer.

---

## 5. Romklasser motoren tar i 070

Rangert etter hva galleriet viser at dagens motorer taper mest på:

| Prioritet | Romklasse | I dag | Hvorfor |
|---|---|---|---|
| 1 | **Akseparallelt med hakk/utsparing/trinn** | V6 — brudd, kryssing, dobbel CC | Kenneths bad. Størst gevinst. |
| 2 | **Akseparallelt med hindringer** | V6 — 8–12 kryssinger, 3–7 deler | Samme rotårsak (fase + overgang). |
| 3 | **L/U/T uten hindringer** | boustrophedon — `utenfor` 150–363 cm | Bare kantavstanden må rettes. |
| 4 | Rene rektangler | boustrophedon — består allerede | Ingen grunn til å flytte dem. |
| — | **Skrå/roterte vegger** | skew | Utenfor denne runden (spec §0.5). Består galleriet i dag (4 av 8). |

Bryteren i 069/070 (`S.ui.newCableEngine`) lar motoren konkurrere **per romklasse**: den tar
over bare der galleriet viser at den er bedre på hvert enkelt mål, aldri der den er lik eller
dårligere.

---

## 6. Størrelse og risiko

**Anslag:** 700–1000 linjer ny kode i `index.html`, i én seksjon ved siden av de fire
eksisterende motorene. Ingen av dem røres. Lag A er ferdig (068). Lag B gjenbruker V6s
analyse. Lag C+E er de nye kjernene og er små (~150 linjer til sammen). Lag D (grafen) og
F (søket) er det meste av volumet.

**Risiko:**

1. **`pathEls` låser dra-redigering.** Avklart som bevisst over, men Kenneth bør si ja.
2. **Lengdetoleransen.** Med ±1 % feiler 99 av 140 rader i galleriet — også et rent
   rektangel på −1,18 %. Enten er toleransen for stram, eller så er lengdestyringen for
   svak. Spørsmålet ligger i `SPØRSMÅL.md`; svaret flytter mye.
3. **«Del i to kabler» er ofte det riktige svaret.** Galleriet viser rom der én kabel ikke
   *kan* legges lovlig (`kabelForLang`: CC klemmes til 5 cm = produktets minimum, og
   bøyeradius 3,2 cm krever 6,4). Motoren må kunne svare «dette går ikke, og her er hvorfor»
   uten å levere et utlegg som ser gyldig ut (spec §5).
4. **clipper-lib fra CDN.** Fail-soft er bygget (faller tilbake på `_offsetPolygon`, setter
   `legalAreaApprox`), men en motor som *bygger* på offset trenger den for alvor. Vurder å
   legge den i `<head>` sammen med de andre tre når 069 starter.
5. **Flerkabel-soner og fryserom-reserve.** `_buildNCableZones` tvinger felles CC og vinkel;
   `_offsetCableClone` klonerer banen. Begge er bygget for dagens former og må testes mot den
   nye — de står ikke i galleriet i dag.

---

# Som bygget (069, 13.10.2026)

`generateCableGeo(roomId, productId, opts)` ligger i `index.html` ved siden av de fire gamle
motorene. Den er **ikke** i kaskaden — galleriet og konsollen kaller den direkte. Bryter:
`S.ui.cableGeoEngine` (av som standard; brukes først i 070).

## Avvik fra forslaget over, og hvorfor

**1. Akseparallellhet måles i grader, ikke i centimeter.**
Kenneths bad har to vegger som bøyer 5,2 cm over 197 cm og 1,1 cm over 95 cm — altså 1,5° og
0,6°. En cm-terskel kastet badet ut som «skrått» sammen med et ekte 18°-rotert rom. Grensen er
nå 5°, og den handler om *kvalitet*, ikke korrekthet: skanlinjene klippes mot det lovlige
området uansett form, men ved større vinkler blir akseparallelle løp et trappetrinn-dekke, og
da er skew bedre (spec §0.5).

**2. En celle deles også ved TRINN i grensen, ikke bare ved kritiske punkter.**
Lærebok-BCD starter en ny celle bare når koblingen mellom to skanlinjer ikke er 1:1. Det er
ikke nok her, fordi alle løp i én celle utjevnes til cellens felles sveipeområde (den låste
like-lengde-regelen). Badet sett langsetter har ett smalt bånd (190 cm forbi hakket) og en bred
del (250 cm) uten at koblingen endrer seg — og utjevningen klipper da HELE rommet ned til 190.
Målt: 22,4 m lagt der 46 m skulle vært. Terskelen er én CC: et trinn mindre enn avstanden mellom
to løp er ikke et trinn, det er en skrå vegg, og den skal ikke fragmentere rommet.

**3. Lengden er en sagtann i CC, ikke en jevn kurve.**
Antall løp N er et heltall. På et 400×300-rom med 96 m kabel gir N=32 → 94,9 m og N=33 → 97,8 m;
**96,00 m finnes ikke for noen CC.** Søket holder derfor to kandidater: den nærmeste, og den
nærmeste *som er for lang*. Bare den siste kan trimmes ned med symmetrisk inntrukne vendepunkter,
og det er den veien lengden faktisk treffes. Etter fiksen: 96,00 m, avvik 0,00 %.

**4. Celleovergangen er en U-SVING, ikke en L-formet omvei.**
Første forsøk rutet overgangen ortogonalt fra forrige celles utgang til neste celles inngang.
Det beinet går tvers over løpenes ender og ga kryssing, klaring 0 og skarpe knekker i hvert
eneste flercelle-rom. Riktig svar: to celler kan bare kobles når løpene deres ligger ved siden
av hverandre på det globale rutenettet (nøyaktig CC fra hverandre) og begge snur i samme ende.
Svingen legges på nivået begge når; er cellene flukt i den enden, kortes ingenting. Finnes ingen
slik kjede, er svaret «ingen løsning» — og det er et ærlig svar, ikke en omvei som ser ut som
en kabel.

## Hva motoren ikke løser, og hvorfor

**Hindring midt i rommet** (`enHindring`, `flereHindringer`, og badet LODDRETT).
Cellene ligger som `0 < {1,2} < 3` langs tverraksen: to endekolonner og to celler stablet i
midten. En bane som skal innom alle fire må ut i en endekolonne og tilbake igjen, og
tilbaketuren har ingen lovlig korridor — den ville ligget nærmere løpene enn produktets
minsteavstand. **Dette er en geometrisk kjensgjerning, ikke en mangel i koden.** V6 «løste» det
ved å tegne en koblingsbane tvers over; det er nettopp feilen 068 målte.

Motoren svarer derfor med spec §5-formatet, og `_geoTrySplitTwo` **prøver todelingen ut** før
den foreslås: cellene deles i to sammenhengende grupper, hver gruppe rutes for seg, og bare når
begge gir en lovlig bane foreslås to kabler — med de målte lengdene og et produkt i riktig
størrelse. For `enHindring` loddrett: 39,2 m + 39,2 m.

En senere runde kan åpne dette med en **validert transittkorridor** (reservert plass langs en
vegg, slik `leadRun` allerede gjør for flerkabel-soner). Det koster dekning og bør være et
bevisst valg, ikke en stille omvei.

## Målt, 069

| | Kaskaden i dag | `generateCableGeo` |
|---|---|---|
| består alle harde krav | 5 av 28 | **13 av 28** |
| bryter et hardt krav | **23 av 28** | **0 av 28** |
| ærlig «ingen løsning» | 0 | 15 |

Ytelse: median **13 ms** per rom, maks 83 ms (`boyUmulig`, der søket uttømmer hele CC-intervallet
før det gir opp). Målet var «godt under 500 ms».

Kjente svakheter å ta med til 070:
- **Dekning er litt lavere enn kaskaden i noen rom** (badet vannrett: 88,3 % mot skews 96,5 %;
  rektangel vannrett 97,1 % mot 98,8 %). Det er prisen for at alle løp i en celle er like lange.
  Merge-kriterium §8.2 sier «ikke dårligere på hvert mål» — dette må Kenneth ta stilling til.
- `kabelForKort` godtas med CC 48,6 cm og 44 % dekning. Det er innenfor `_ccLimits.maxHard` (50),
  altså lovlig etter reglene slik de står — men det er ikke et godt utlegg. Hører hjemme i
  romtypens CC-grenser, ikke i motoren.
- Skrå rom returnerer «ikke akseparallelt» og overlates til skew, som spec §0.5 sier.
