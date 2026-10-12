# Spec: Hurtig prosjektering — utendørs produkter

> **Merk (059, 12.10.2026):** Denne filen fantes ikke i repoet da seksjonen under ble skrevet —
> den er bare referert fra kodekommentarer (DEL A/B/C i `_listCatFor`, `_listFamKey`,
> `_listFinalizedRowHtml`). Filen er derfor opprettet med KUN den nye seksjonen. De eldre
> DEL A–C-reglene for listemodulen selv er ikke gjengitt her; de bor fortsatt i kommentarene
> ved funksjonene de gjelder.

---

## Listevisning i tegnede deler (059, Kenneth 12.10.2026)

> «Jeg har tegnet opp 15 utendørs områder for snøsmelting på en LARK-tegning. Ofte er vi i
> tilbudsfase og vil ikke bruke tid på å detaljprosjektere. Kan vi få alle rom/områdene over til
> listevisningen, så jeg kan gå inn på hvert område og sette inn den InSnow 300T-matta som passer
> best, eller 1, 2 eller 3 kabler?»

### 1. Visning per del

- Inne- og utedelen har en segmentert bryter **Lerret | Liste** i topplinja
  (`#tb-partview`, `_setPartView`). Trapp og listedelen er urørt.
- Valget ligger per del i `S.ui.partView[partId]` og lagres med prosjektet (`_buildSaveData`
  → `ui.partView`), slik at delen åpnes i den visningen man forlot den i.
- Liste viser samme overlay som Hurtig prosjektering (`#list-module`), men **92 % opakt** i en
  tegnet del, slik at rommet man klikker lyser opp på lerretet bak. Gjennomsikten utledes av
  `--bg` (`color-mix`) — aldri en hardkodet farge, ellers forsvinner tabellen i lyst tema.
- Toppen har delens navn, «15 områder · 412,6 m² · 128 400 W» og samme knapperad som listedelen,
  **minus** «Importer tegning (PDF)» og utkast-kortet: rom lages på lerretet i disse delene.

### 2. Arealet kommer fra tegningen

- **Netto er lesbart, aldri redigerbart.** `roomAreas(room)` regner polygonet selv; tooltip viser
  «Fra tegningen — brutto 16,50 m², hindringer 1,80 m²». Hindring-feltet finnes ikke.
- **Varmetype er låst** til delens type. Kolonnen vises bare når delen faktisk har begge slag
  (samme regel som Bygg-kolonnen i listedelen).
- Ingen ny areal-, produkt- eller statistikk-logikk: `_listSetRoomProduct`, `_computeRoomStats`
  og `roomAreas` er uendret og virker like godt på et tegnet rom som på et listerom.

### 3. Én sannhet per rom

Status per rad (`_listRoomDrawnState`):

| Status | Betyr | Raden |
|---|---|---|
| `—` | ingen produkter | Type/Klasse/Produkt/antall kan velges |
| `Kun label` | produkt valgt, utlegg ikke tegnet | kan velges + **«Tegn utlegg»** |
| `Tegnet` | ekte utlegg (kabel med strenger, matte/folie/plate/frihånd) | **LÅST** — «Endre på lerretet» |

- Lista erstatter **aldri** et tegnet utlegg. Verken radens egne kontroller, «Grovprosjekter alle»
  eller arv-kaskaden rører et rom med status `Tegnet`.
- **«Tegn utlegg»** kjører det ekte auto-utlegget med radens produkt og antall — kabel via
  `_cablePreviewPlace` + `_confirmCablePreview`, snø-matte via `_upcPlaceMat`/`_confirmMatPreview`,
  innendørs matte via hele `_matFillRoomSmart`-veien. Snø-pakkeren kan velge en annen variant i
  samme familie enn raden foreslo; raden viser etterpå det som faktisk ligger der.
- **Ett angre-steg.** `_listDrawLayout` pusher selv én gang og undertrykker motorens egne
  (`_undoSuppress`) — snø-matta pusher ellers to ganger, og Ctrl+Z landet på et tomt rom.
  Feiler motoren, rulles alt tilbake og raden står som før, med årsaken i en toast.
- **«Grovprosjekter alle»** foreslår produkt for alle rom **uten** produkt. Rom som allerede har
  noe (label eller tegnet) røres ikke.

### 4. Arv av familie radvis

- Har rommet ingen egen familie, arves `listFamily` **og** `listModType` fra nærmeste rad over med
  et valgt produkt (`_listPrevRowFamily`). Finnes ingen: dagens regel (snø → `InSnow 30T|230`,
  innendørs → nærmest ønsket W/m²). Antall og variant regnes alltid på nytt for rommets areal.
- `room.listFamilyBy` er `'auto'` eller `'user'`. `_listOnType`/`_listOnClass`/`_listOnProduct`/
  `_listOnEnv` stempler `'user'`; `_listAutoSuggest` stempler `'auto'`.
- Et manuelt familie-/type-valg lar alle **senere** `'auto'`-rader følge etter
  (`_listCascadeFamily`). `'user'`-rader står. En `'user'`-rad midt i lista blir i sin tur
  forelder for radene under seg — «forrige rad» betyr alltid nærmeste rad over.
- Gjelder også listedelen: utkast-rommet står ikke i tabellen, så «forrige rad» er der den siste
  opprettede raden.

### 5. Kalkyle-merke

Ett sted avgjør hva som er kalkyle (`_roomIsKalkyle` / `_projectKalkyleStatus`), lest av alle tre
flatene:

- **PDF-forsiden** (`_pdfCoverMetaRows`): «Status: Kalkyle — ikke detaljprosjektert», eller
  «Status: Delvis detaljprosjektert (9 av 15 rom tegnet)». Ingen rad når alt er tegnet.
- **Romoversikten**: liten grå linje «Kalkyle — produkt valgt, utlegg ikke tegnet» under
  produktnavnet, pluss en fotnote. Egen underlinje framfor en ny kolonne, fordi tabellens
  x-posisjoner summerer til nøyaktig 180 mm.
- **Romdetaljsidene** hoppes over for rene kalkyle-rom — det finnes ingen tegning å vise.
- **Sidepanelet**: en liten grå «K» etter romnavnet.
- Materiallista er uendret — den teller label-produkter fra før.

### 6. Regresjon

`_listevisningRegressionTest()` låser kilde per deltype, låsing av tegnede rom, arveregelen
(auto mot user, inkludert kaskaden) og Kalkyle-merkets betingelse.

---

## 061 · «Ulike kabler» på ett rom

Kenneth 12.10.2026: «Kan vi få en knapp for å velge ulike kabler på et rom? Trykk «Ulike kabler»,
så kommer det opp to linjer hvor man kan velge valgfrie kabler, og en pluss for å legge til en
linje til hvis man skal ha enda flere. Må fortsatt se samme resultater: total effekt,
flateeffekt, CC.»

### 1. Modellen

`room.listMix = [{ productId, count }, …]` — radene brukeren ser, i rekkefølge. `null`/udefinert
= LIKE kabler, nøyaktig som før 061. Feltet ligger på rommet og lagres med prosjektet som alt
annet der.

- **Alle radene velges innenfor samme klasse** (`room.listFamily`, familie + spenning). Ulik
  klasse ville gitt ulik W/m i hver sone med felles CC, altså to ulike flateeffekter i samme rom
  — en annen sak enn denne.
- `_listSetRoomProductMix(roomId, rader)` er motparten til `_listSetRoomProduct`. Den rydder
  rommets kabler/matter, legger `count` «kun label»-kabler per rad, og setter
  `room.listCount = Σ count`. `_listSetRoomProduct` nullstiller `listMix` — ett sted, så ingen
  vei kan etterlate et rom som sier «blandet» mens kablene er like.
- **Felles CC = netto / Σ (antall × kabellengde) × 100**, klemt til det strengeste gyldige
  området over produktene i rommet (`max(minSp)` … `min(maxHard)`). Samme regel hovedmodulens
  blandede kombinasjoner bruker. 016 gjelder fortsatt: over anbefalt maks er lov, men merkes ⚠.
- ⚠ `pushUndo` kopierer rommene med en flat spread, så `listMix`-ARRAYET deles med angre-steget.
  Hver mutasjon bygger derfor et **helt nytt array med nye rad-objekter** — aldri `rows[i].count++`
  på plass. Låst av en egen regresjonssjekk.

### 2. Hvorfor felles CC ikke er en finesse

STEG 0.1 målte at resultatboksen summerer riktig helt uten endring: `_computeRoomStats` tar
`cableLenM` og `cableW` som SUMMER over rommets kabler, `_roomRatedEffectW` likeså, og `heatedM2`
faller til nettoarealet for «kun label». Men `cableCcCm` tar den **første** kabelens `spacing_cm`
og ignorerer resten stille — målt: kabel 1 = 14,7 cm / kabel 2 = 99 cm ga fortsatt «14,7 cm» i
CC-feltet, mens den lengdevektede flateeffekten falt fra 68 til 45 W/m². Felles CC på alle
kablene er derfor betingelsen for at tallene er sanne, ikke en pynt.

### 3. Kortet og raden

- **«Ulike kabler»**-knapp ved siden av Antall, kun når Type = Kabel. Klikk bytter «Foreslått
  produkt» + «Antall» ut med radlista. Rad 1 forhåndsfylles med dagens produkt og antall, rad 2
  er tom. Modusen stemples `listFamilyBy='user'`, så kaskaden (059 §3) ikke kan bytte klassen
  under radene senere.
- Radenes nedtrekk viser **«navn · W»**, uten per-element-CC og W/m². De to tallene gjelder bare
  like kabler (netto/N per kabel); i blandet modus er CC felles og hører til resultatboksen. Det
  gjør i tillegg at et produkt- eller antallsbytte ikke trenger å bygge om nedtrekkene i det hele
  tatt — fokus og TAB står urørt. ⚠ `_listMixSetRow` setter likevel `select.value` eksplisitt:
  kalles den fra modellsiden («Foreslå», test), står nedtrekket ellers igjen på det gamle valget
  mens tallene under er de nye.
- **Foreslå** kjører hovedmodulens `_generateMixedCombos` på klassen og tar første kombinasjon
  som er ULIKE (`!balanced`). Ingen innen ±12 % → toast.
- **Like kabler i stedet** / ✕ ned til én rad → `_listSetRoomProduct` med Σ antall.
- Klassebytte i blandet modus tømmer radene og fyller rad 1 med den nye klassens forslag;
  modusen beholdes. Type → Matte og Varmetype-bytte forlater blandet modus helt.
- **Ferdig rad**: «InFloor 10T 1800 W + 1200 W + 600 W» (klassen én gang, effektene skilt med +;
  antall > 1 gir «2 × 1800 W + …»), tooltip med fulle produktnavn. **Bestilles**:
  «2 stk (1 × 1800 W, 1 × 1200 W)», med 025b-reservetillegget på slutten der det gjelder.
- Alt dette er tilgjengelig i 059s tegnede rader også, i en kompakt variant av samme radliste.
  Arveregelen er uendret: neste rad arver **klassen**, aldri blandingen.

### 4. Det som IKKE trengte endring (STEG 0.3, målt)

`_collectMaterialItems`/`_aggregateMaterialItems` (Materialliste + Visma-paste) og
`_roomProductBreakdown` (Romoversikt-PDF) går allerede per kabel og grupperer per produkt-id —
begge ga to linjer uten en eneste endring. `_syncReserveCables` lager **én reserve per kabel**,
ikke per produkt (målt: «4 stk (2 + 2 reserve)», `mainCableId` riktig satt per kabel).
`_autoFillMixedCables` tåler tre kabler (180 + 120 + 60 m i 45 m² → tre kabler, felles CC
12,5 cm) og avviser ulik familie av seg selv.

### 5. «Tegn utlegg» (059)

Et rom med `listMix` kaller `_placeMixedCables` med produkt-IDene utvidet med antall, i
radrekkefølge («2 × 1800 + 1200» → `id,id,id`). Den leser rommet fra `S.ui.selectedRoomId` og
pusher sitt eget angre-steg, undertrykt av `_undoSuppress` i `_listDrawLayout` — så Ctrl+Z
fortsatt lander presist på kalkylen, ikke på et tomt rom.

### 6. Regresjon

`_listevisningRegressionTest()` § 5 låser: felles CC = netto/Σlengde (ikke netto/N), at CC-en
ligger på ALLE kablene, Σ effekt, én kabel per antall, Bestilles-formen, radteksten, at
arealendring regner CC på nytt uten å røre produktene, at klassebytte tømmer radene og beholder
modusen, at like kabler nullstiller `listMix`, at Matte ikke har blandet modus, at arv ikke tar
blandingen med seg, reserve per kabel, materialliste/Romoversikt per produkt, ID-utvidingen til
«Tegn utlegg», nedtrekk-mot-modell-synkingen, og at `listMix` er et nytt array per mutasjon.
