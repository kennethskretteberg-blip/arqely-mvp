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
