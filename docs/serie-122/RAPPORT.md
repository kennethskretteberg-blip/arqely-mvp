# 122 · Presentasjon: frihånds-matte gjenkjent, areal alltid, «Foreslå endring» med type → gruppe → ▲/▼ og live resultat

Kjørt 22.10.2026 på `main` (fra `6078e59`). **Ikke pushet.**

Testet på Kenneths egen forslagslenke til «Test Kenneth» (Rom 1, EcoMat 150T frihånd, 1500 W).
Lenka ble bare lest. Ingenting er sendt, og ingenting er lagret i prosjektet.

> ⚠ Mappa het `~/Code/arqely-mvp` da jeg startet. Underveis ble den omdøpt til `~/Code/varmeplan-web`
> (ikke av meg). Serveren som allerede kjørte på port 4000 peker fortsatt på den gamle stien og svarer
> nå `ENOENT`. Jeg testet derfor på port 4200 (`varmeplan-main` i `.claude/launch.json`). Der rettet jeg
> stien til den nye mappa. Fila er ikke i git, så den rettelsen ligger bare lokalt.

---

## STEG 0

### 0.1 Reprodusert

Forslagslenka viste nøyaktig det Kenneth beskrev: «Produkt: ikke plassert», «Installert effekt 1500 W»
og «Ingen varme er planlagt i dette rommet». Romlista sa «ingen varme planlagt». Se `foer-desktop.jpg`.

Rotårsaken er bekreftet. `_presentRoomProduct` hadde sin egen liste med fem samlinger
(cables/strips/foilFree/mats/plates). `S.matPaths` og `S.aluboard` manglet. `_roomRatedEffectW` leser
den felles kilden, så effekten ble riktig, men produktet ble `null`.

### 0.2 Kallstedene

| Kallsted | Trenger alle produktene? |
|---|---|
| `_presentForhaandsvalgtRom` (forhåndsvalg) | Nei, bare «har rommet noe» |
| `_presentRoomDetailHtml` (detaljkortet) | **Ja.** Viser nå alle radene, f.eks. «2 × EcoMat 60T 0.5×10m» |
| `_forslagAlternativer` | Nei. Trenger produktet for rommets **type**, ikke det dominerende (se under) |
| `_forslagKanForeslaaVarme` | Nei, bare tomt/ikke tomt |
| `_presentPanelRomlisteHtml` (romlista) | Nei. Én linje per rom, viser det dominerende |
| `_forslagRadTall` (Kenneths vindu) | Nei. «Nå» for typebytte |
| `_forslagResultatHtml` (ny) | Nei. Brukes for «Nå:»-linja |

Funn: Aluboard-kabelen er en rad med `kind: 'Kabel'` i den felles kilden. Hvis `_forslagAlternativer`
hadde brukt det dominerende produktet, ville et Aluboard-rom fått en kabelstige for platesystemets
egen kabel. Derfor slår den nå opp produktet via rommets type (`_forslagNaa`).

### 0.3 Areal

Presentasjonen viste bare **brutto** (`room.area`) under romnavnet, med to desimaler. Netto ble ikke
vist noe sted. Romlista viste også brutto.

Etter «Endre mål» bygges rommets punkter om i tegningen, og `room.area` følger med (målt: 297 → 327 cm
gir 14,87 m², det samme som `compArea(room.points)`). De opprinnelige målene ligger i
`_kundeState.original` (punkter og areal), som lagres når lenka åpnes.

### 0.4 «Foreslå endring» før

| Rom | Før |
|---|---|
| Kabel | Bare ▼/▲ i dagens familie (17T). Tallene på én linje: «800 W · 47 m / Flateeffekt 50 W/m² · CC 34 cm». Ingen typebytte. |
| Vanlig matte | ▼/▲ over 60/100/150 W/m². Bare «60 W/m²» som tall, ingen effekt og ingen dekning. |
| Frihånds-matte | Fikk **tomt-rom-kortet** («Ingen varme er planlagt»). Dette er feilen. |
| Tomt rom | Type → Serie → Variant. ⚠ **Matte var dødt:** gruppene var `EcoMat 60T`, `EcoMat 100T` og `EcoMat 150T` (= `product_family`), med **én** rad hver. Pilene kunne ikke flytte seg. |

---

## Endringslogg

### 1. Riktig produkt (feilen)

- `_presentRoomProduct` leser nå `_roomDominantProduct`, altså `_roomProductRows`. Frihånd (via
  `_matFreeCatalog(mp).segments`), Aluboard og kalkyle er med. Funksjonen har ingen egen liste lenger.
- Ny `_presentRoomProduktNavn(room)` lister alle radene, f.eks. «2 × EcoMat 60T 0.5×10m».
  Reservekabelen tas ikke med.
- `_forslagRomType` kjenner nå igjen `matPaths` (matte) og `foilFree` (folie). Aluboard og plater
  meldes som egne typer, så godkjenningen sier «byttes ikke automatisk» i stedet for å kjøre
  folie-motoren.

### 2. Areal

- Detaljkortet viser alltid en rad **Areal: netto X m²** med **brutto Y m²** under.
- Har kunden endret målene, står det «13,5 m² → 14,9 m²» for både netto og brutto
  (`_presentRomAreal` / `_presentArealTekst`).
- Romlista viser netto, og «før → etter» når målene er endret.

### 3. Én velger: type → produktgruppe → ▲/▼ → live resultat

- `_forslagVelgerHtml` brukes av **både** rom med produkt og tomme rom (etter «Foreslå varme»).
- **Type:** Kabel / Matte. Folie står som eget valg hvis rommet har folie i dag.
  - Snørom og fryserom får ikke bytte type (054-regelen).
- **Produktgruppe:** henter gruppene fra `_forslagSerier`. Standardvalget er rommets nåværende gruppe.
  - Kabel: `product_family` («InFloor 17T», «InFloor 10T»).
  - Matte: familien uten W/m²-leddet («EcoMat»). Spenningen legges til når den ikke er 230 V.
- **▲/▼:** for dagens gruppe kommer radene fra `_forslagAlternativer`. Det er samme liste som
  godkjenningen validerer mot. For en annen gruppe kommer de fra `_forslagNyeRader`. Ugyldige rader
  hoppes over, som før.
- **Live resultat:**

  | Felt | Kabel | Matte |
  |---|---|---|
  | Installert effekt | radens W | `_forslagMatteEffekt`: dagens matter/baner med ny variant |
  | Flateeffekt | radens flateeffekt | W/m² |
  | CC | cm (⚠ over anbefalt) | — |
  | Dekning | — | m² og % av netto |
  | Mot ønsket | `_roomTargetWm2` og avviket | samme |

  Under boksen står «Nå: … · W · W/m² · tilbakestill».
- **Frihånds-matte:** alternativene er 60/100/150. Effekten regnes med `_matFreeCatalog` på **samme
  bane** med ny familie, så dekningen er dagens dekkede areal. Det er ingen ny matte.
- **Matte i et rom uten matte i dag** (tomt rom eller kabel → matte): effekt og dekning står som
  «avgjøres ved utlegg». Det finnes ikke noe dekket areal å regne fra uten å legge ut, og det skal
  ikke skje hos kunden.
- «Ønsket flateeffekt» for kabel er beholdt. Den skjules når kunden har byttet til matte.
- **Svaret er uendret i format.** `nyType` sendes bare når typen er en annen enn dagens. `serie` lagres
  i kundens valg, men går ikke i svaret (det gjorde den ikke før heller). Testen sjekker at det ikke
  er noen nye felt.

### 4. Kenneths side (nødvendig for «kan godkjennes som før»)

- **Typebytte** (kabel → matte og motsatt): rommets produkter ryddes før den nye motoren kjører. Uten
  dette ville en matte-`productId` blitt kjørt gjennom kabelmotoren. Feiler motoren, settes rommet
  tilbake slik det var (gjenopprettingen fantes fra før).
- **Frihånds-matte:** ny `_forslagMatteFrihaandBytt` bytter bare produktfamilien på banene. Banen blir
  liggende. Før ville godkjenningen enten feilet («ikke noe utlegg å bytte») eller erstattet den
  håndtegnede matta med et autoutlegg. Målt på Kenneths rom: 100 W/m² gir 1000 W, fortsatt 1 bane og
  0 autolagte matter.
- `_forslagRadTall` viser «Nå: EcoMat 150T 0.5×20m → InFloor 17T 800W 47m (nytt)» når kunden har
  byttet type.

### 5. To feil funnet i testene

- **`_kundeforslagRegressionTest` var miljøavhengig.** Oppsettet tømte aldri `S.matPaths`, `S.foilFree`
  eller `S.aluboard`. Kenneths ekte frihånds-matte (rom-id 1) lekket derfor inn i testrom 1 så snart
  `_presentRoomProduct` begynte å se frihånd. Tre sjekker ble røde (H, K, L). De tre samlingene
  lagres, tømmes og settes nå tilbake.
- **Timeren for automatisk lagring av valget lekket inn i den ekte tilstanden.** Et testbatteri tegnet
  panelet på nytt, satte tilstanden tilbake, og så fyrte timeren på den ekte lenka. Timeren lagrer nå
  bare hvis det er samme lenke, samme type og samme gruppe, og valget fortsatt er uten produkt.
  Målt: 1 lekket valg før, 0 etter.

---

## Test

| | Resultat |
|---|---|
| `_kundeforslagRegressionTest` | **227/227 grønn** (ny seksjon M: frihånd, to ruller, aluboard, kalkyle, kabelgruppe/typebytte, tomt matterom, areal, ingen motor/pris) |
| `_kundelenkeRegressionTest` | **330/330 grønn** |
| Kenneths lenke, desktop | Produkt + 1500 W + areal; ▼ gir 150T → 100T → 60T = 1500 → 1000 → 600 W, dekning 10,0 m² · 74 % (`etter-desktop-frihaand.jpg`) |
| Endre mål, ekte sti | Vegg 297 → 327 cm gir «13,5 m² → 14,9 m²» i kortet og i romlista (`etter-desktop-endret-maal.jpg`) |
| Typebytte i frihåndsrommet | Kabel → 17T/10T, ▲/▼, «3 stk InFloor 10T 700W 70m · 2100 W · 155 W/m² · CC 6,4 cm» |
| 390 px | Ingen vannrett rulling (`scrollWidth` 390), knappene 44–46 px (`etter-mobil-kabel.jpg`) |

**Ikke testet:** at et svar faktisk blir sendt og så godkjent gjennom vinduet hos Kenneth fra start til
slutt. Da måtte jeg ha sendt et ekte svar på lenka hans. Logikken er testet i minnet på hans geometri
(se 4) og i seksjon M.

## Spørsmål

1. **Matte-gruppa er «EcoMat», ikke «EcoMat 150T».** Prompten sa «samme kilde som `_forslagSerier`»,
   men der hadde hver W/m² sin egen gruppe med én rad, og pilene var døde. Jeg valgte at det kunden
   piler over i en matte er W/m²-variantene, slik pilelista for matterom alltid har gjort. Lengden er
   fortsatt motorens valg (043). Vil du heller at kunden skal pile over **lengdene** (0,5×18 m,
   0,5×20 m …) med dekning i %? Da må godkjenningen også endres, fordi den i dag beholder dagens
   lengde.
2. **«Mot ønsket» viser 310 W/m² i Test Kenneth.** Det er `S.varmekabel.targetWm2 = 310` i selve
   prosjektet (`_roomTargetWm2`, samme tall som ditt eget panel bruker). Rommet har ingen romtype. Er
   310 en testverdi, eller skal kunden se noe annet når rommet mangler eget mål?
3. **Kunden kan nå bytte type i et rom som har produkt** (kabel ↔ matte). 043-regelen sa «et rom som
   alt har kabel bytter aldri kabeltype». Jeg tolket ordene dine («velg matte eller kabel» også ved
   endring) som at regelen er opphevet. Stemmer det?
4. Frihånds-matte med bare **retning** foreslått kan ikke godkjennes automatisk. Banen er håndtegnet,
   så du får beskjeden «retning endres manuelt i tegningen». OK?

## Utenfor omfang (funnet, ikke rettet)

- **`_kundelenkeRegressionTest` tømmer `S.matPaths` i det åpne prosjektet** (1 → 0). Målt på den gamle
  koden også (`git stash`), så dette er ikke en følge av 122. Det er ufarlig i en lenke, men i editoren
  kan det bli lagret.
