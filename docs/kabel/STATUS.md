# Kabelmotor 068–074e — status, merge-sjekkliste og hva som ikke er løst

Gren `kabelmotor`. `main` er urørt.
Galleriet: `docs/kabel/galleri.html` · Arkitektur: `docs/kabel/arkitektur.md` ·
Spørsmål: `docs/kabel/prompter/SPØRSMÅL.md`

---

## 1. Hva som er bygget, på én side

**Geometrikontrollen `_cableGeometryCheck(cable, room)` (068)** er fasiten. Den leser kabelens
senterlinje slik rendereren faktisk tegner den, og måler den mot de harde kravene i spec §1:
ligger kabelen i lovlig område, krysser den seg selv, kommer to deler nærmere hverandre enn
produktets minsteavstand, er noen sving trangere enn bøyeradien, stemmer lengden med produktet
(±1 %), er CC innenfor intervallet, og er banen sammenhengende. Myke mål (CC-variasjon,
kantsymmetri, hopp, dekning) måles også, men avviser ikke.

**Motoren `generateCableGeo(roomId, productId)` (069)** bygger utlegget lagvis:

| Lag | Hva den gjør |
|---|---|
| **A** Normalisering | Lovlig område = rom − kantavstand − hindringer − forbudte soner, med ekte polygon-offset (clipper-lib@6.4.2). |
| **B** Celler | Rommet deles i celler der skanlinjene skifter karakter: enten fordi de splittes/slås sammen (et hakk sett på tvers), eller fordi grensen gjør et **trinn** større enn én CC. |
| **C** Global avstand | **Ett** løpsrutenett for hele rommet: `pos_i = x0 + i × CC`, der `x0` velges én gang mot hele det lovlige området. Cellene sier bare hvilke løp de inneholder. Dette er rettelsen av «ulik CC». |
| **D** Rute | Cellene kobles til **én** bane. To celler kan bare kobles når løpene deres ligger ved siden av hverandre på rutenettet og begge snur i samme ende. Finnes ingen slik kjede → «ingen løsning». |
| **E** Svinger | Halvsirkler med radius CC/2, lagt på et nivå begge løp når. Løpene slutter CC/2 inne i lovlig område, så svingen får plass. |
| **F** Lengde | Søk over CC (bisekssjon) og symmetrisk inntrukne vendepunkter, mot produktets lengde ±1 %. Lengden **måles**, den tilordnes aldri. |
| **G** Start/slutt | Brukerens starthjørne brukes når det er lovlig; ellers nærmeste lovlige. |
| **H** Optimalisering | Harde krav er **filter** — et ulovlig utlegg kan aldri vinne på poeng. Myke mål er poeng. |

**I kaskaden (070):** ny motor og dagens kaskade kjøres begge, begge måles, og en dominans-test
avgjør. Ny motor tar bare over når den ikke er dårligere på noe mål. Bryter et utlegg likevel et
hardt krav, legges det ut **merket** — rød stiplet romkontur, røde ringer på bruddene, ⚠ i
labelen, defektliste og forslag i panelet, egen linje på PDF-romsiden.

---

## 2. Galleriet, rom for rom

30 rader = 15 fixture-rom × 2 retninger (`badHakk41` kom til i 074).
«Før» = kaskaden slik den var ved `1519bb0`.

| | består | bryter et hardt krav |
|---|---|---|
| **Før (068)** | 5 | 23 |
| **Etter (070)** | 20 | 8 |
| **Etter (072)** | 22 | 6 |
| **Etter (074)** | **24** | **6** (av 30) |

De to som kom til i 072 er **Kenneths bad loddrett** (var «ingen løsning» — fantes ingen lovlig
én-kabel-bane) og **`enHindring` i begge retninger** (var ⚠ i begge). Begge løses av
transittløpet. `enHindring` loddrett erstatter dermed «2 kabler»-forslaget med én kabel.

Dekningen steg bredt da løpsrutenettet begynte å nå helt ut til det lovlige områdets kant
(lag C, se §7): rektangel 98,8 → 99,5 %, L-rom 97,9/98,5, U-rom 92,6/93,1,
asymmetriske vegger 93,9 → 96,1 %.

| Rom | v | h |
|---|---|---|
| Rektangel 400×300 | ok 97,9 % | ok 99,5 % |
| L-rom | ok 97,9 % | ok 98,5 % |
| U-rom | ok 92,6 % | ok 93,1 % |
| **Én hindring** | **ok 94,2 %** (1 transitt) | **ok 91,8 %** (1 transitt) |
| Flere hindringer | ⚠ (se §3a) | ⚠ (se §3a) |
| Smal passasje | ok 90,3 % | ok 90,3 % |
| Utsparing | ok 95,1 % | ok 93,8 % |
| Asymmetriske vegger | ok 96,1 % | ok 96,1 % |
| Kabel for lang | ⚠ (§3b) | ⚠ (§3b) |
| Kabel for kort | ok | ok |
| Bøyeradius umulig | ⚠ (§3c) | ⚠ (§3c) |
| Umulig starthjørne | ok 99,0 % | ok 99,1 % |
| Skrå (18°) | ok 97,4 % | ok 96,8 % |
| **Kenneths bad** (47 m) | **ok 92,7 %** (1 transitt) | ok 88,5 % |
| **Kenneths bad, 41 m** (074) | **ok 91,0 %** · +0,07 % · CC 13,18 | **ok 91,4 %** · +0,57 % · CC 13,45 |

⚠ **Én endring i et rom som alt var gyldig:** rent rektangel vannrett lå på boustrophedon og
ligger nå på ny motor. Den er bedre på hvert eneste mål (CC 12,40 → 12,60 cm, dekning
98,8 → 99,5 %, lengdeavvik −0,94 → −0,91 %, klaring 12,40 → 12,60, bøyeradius 6,20 → 6,30) og
dårligere på ingen, så overtakelsen følger dominans-regelen fra 070. Påstanden i
`_cableGeometryRegressionTest` er endret fra «identisk utlegg som før» til «identisk ELLER bedre
på hvert mål», med målingene i koden ved testen. **Dette må godkjennes før merge.**

## 3. Hva motoren IKKE løser — og hva brukeren får se

### a) Hindring midt i rommet
**`enHindring`: LØST i 072.** Transittløpet (§7) reserverer én bane langs hindringens kant, og
begge retninger gir nå én sammenhengende, lovlig kabel (94,2 % / 91,8 % dekning).

**`flereHindringer`: står igjen.** Målt: rommet deler seg i **10 celler** i begge retninger, og
**6 av cellepartene er stablet** — de ligger på samme løpsposisjoner, bare oppå hverandre, og
krever hver sin transittkorridor. Søket bygger varianter i to lag (inntil 2 reserverte baner);
ingen av de 11–12 variantene × alle Hamilton-rekkefølgene gir en lovlig kjede. Det er altså ikke
at transitten ikke virker — det er at rommet trenger flere korridorer enn det er plass til.
Seks reserverte baner i et 4 m²-rom er mesteparten av gulvet, og hver av dem er en kald stripe.
**Brukeren får:** dagens V6-utlegg, merket ⚠ med defektlista, pluss et prøvd «2 kabler»-forslag
med målte lengder. Kenneths beslutning 5 gjelder altså for én hindring; for flere er «2 kabler»
fortsatt riktig svar.

### b) Kabel for lang for rommet (`kabelForLang`)
Et 3 m² rom med 96 m kabel: CC klemmes til produktets minimum 5 cm, og bøyeradien 3,2 cm krever
CC ≥ 6,4. Ingen lovlig CC finnes.
**Brukeren får:** ⚠ og forslag om et kortere produkt i samme familie.

### c) Bøyeradius umulig (`boyUmulig`)
Samme mekanisme: 10 m² med 200 m kabel gir CC 5,0 cm, og en U-sving med radius 2,5 cm er
trangere enn produktets 3,2 cm.
**Brukeren får:** ⚠ og forslaget om et produkt med mindre bøyeradius eller kortere lengde.

### d) Skrå og roterte rom (`skraa`)
Utenfor denne runden (spec §0.5). Rom med en vegg mer enn 5° fra aksen svarer «ikke
akseparallelt» og overlates til skew-motoren, som består galleriet for dem.
**Brukeren får:** samme utlegg som før.

### e) Flerkabel-soner
`_buildNCableZones` tvinger felles CC i alle soner (lik W/m² over sømmen). Ny motor søker sin
egen CC og kjenner ikke bindingen. Soner kjører derfor uendret på dagens kaskade.

### f) Utlegg som allerede er lagret — LØST i 072
Kenneths beslutning 6: «Lagrede utlegg kontrolleres **ved åpning** — bare merkes (⚠), aldri
endres.» `_geomSjekkLagredeUtlegg()` kjører fra `_restoreProject`, som er DET ENE punktet alle
lastinger går gjennom (sky, fil, versjon, duplisering). Den skriver bare merkefeltene
(`_geomDefects`/`_geomMetrics`/`_geomOk`), rører ikke geometrien, markerer ikke prosjektet som
endret og utløser ingen autolagring. Er noe merket, kommer banneret
«⚠ N kabelutlegg i prosjektet bryter regler — se ⚠ i romlista.» Kontrollen er asynkron og
fail-soft: laster ikke polygonbiblioteket, skjer ingenting.

### g) Dekningen har et ARITMETISK tak
Dekning er andelen av netto areal som ligger innenfor ½ CC fra kabelen. En slynge med lengde L og
avstand CC dekker derfor høyst `L × CC`. For badet: 47,00 m × CC mot 5,887 m² netto.

| CC | tak | merknad |
|---|---|---|
| 11,21 cm (vannrett, N=19) | **89,5 %** | motoren måler 88,5 — 1 poeng under taket |
| 11,60 cm (loddrett, N=18 + transitt) | **93,1 %** | motoren måler 92,7 |
| 11,65 cm | 93,0 % | det som trengs for målet «≥ 93 %» |
| 12,53 cm | 100 % | nøyaktig det referansen (skew) brukte — men den lå 0,83 cm fra veggen |

Vannrett kan rutenettet bare tilby CC 11,21 (19 løp) eller 11,87 (18 løp). 18 løp gir **44,31 m**,
altså 5,7 % for kort — utenfor ±1 %. **Målet «≥ 93 % i begge retninger» er derfor ikke oppnåelig
vannrett med InFloor 17T 47 m**, og det er ikke en mangel i koden. Kenneths EGEN vannrette fasit,
bygget og målt, lander på 92,1 % — og bruker da 48,83 m, 3,9 % mer kabel enn produktet har.

## 4. Legge til et nytt testrom i galleriet

Én oppføring i `_cableFixtures` i `index.html`:

```js
mittRom: {
  name: 'Beskrivende navn',            // vises som overskrift i galleriet
  klasse: 'rettvinklet uregelmessig',  // fri tekst, grupperer i rapporten
  productId: 31,                       // et ekte produkt fra katalogen
  points: [{x:0,y:0},{x:400,y:0},{x:400,y:300},{x:0,y:300}],   // innvendig polygon, cm
  hindrings: [[{x:150,y:110},/* … */]],                        // valgfritt
  zones: [{ type:'forbidden', points:[/* … */] }],             // valgfritt
  note: 'Hvorfor dette rommet er med'                          // valgfritt
}
```

Deretter, i konsollen med dev-serveren i gang:

```
await _cableGalleryExport()
```

Den kjører alle rom × begge retninger × kaskaden + fem motorer, skriver
`docs/kabel/galleri.html` og legger tabellen i konsollen. For ett rom:
`await _cableGalleryExport({ only: ['mittRom'] })`.

---

## 5. Merge-sjekkliste (spec §8)

- [x] **badHakk får gyldig utlegg i BEGGE retninger, med én kabel.**
      Loddrett: **47,24 m, avvik +0,51 %, CC 11,60 cm, dekning 92,7 %**, 0 kryssinger, 0 knekker,
      minste klaring 11,60 cm, bøyeradius 5,79 cm (krav 3,2), 1 sammenhengende bane, 1 transittløp.
      Vannrett: **47,00 m, avvik 0,00 %, CC 11,21 cm, dekning 88,5 %**, 0 utenfor.
- [x] **Kenneths fasit er bygget og kontrollert** (`_cableFasitCable`, vist i galleriet).
      Loddrett-fasiten **består** — og er numerisk identisk med det motoren legger.
      Vannrett-fasiten **faller på lengden alene**: formen rommer 48,83 m (+3,9 %) der produktet
      har 47,00. Alt annet er rent (0 utenfor, 0 kryssinger, klaring 11,21, dekning 92,1 %).
      Nærmeste lovlige variant er samme form med vendepunktene trukket symmetrisk inn — det er
      nøyaktig det motoren gjør, og det koster 3,6 prosentpoeng dekning.
- [ ] **Dekning ≥ 93 % i begge retninger** — loddrett 92,7 %, vannrett 88,5 %.
      **Ikke oppnåelig** med dette produktet; aritmetikken står i §3g. Kenneth må avgjøre om
      målet skal justeres, eller om badet skal ha et annet produkt/en annen kabellengde.
- [x] **Ingen galleri-rom dårligere enn før.** 22 gyldige mot 20, ingen tapte dekning.
      Ett rom BYTTET motor uten å bli dårligere (rektangel vannrett, se §2) — må godkjennes.
- [x] **Alle regresjonsbatterier grønne: 22 batterier.** `_cableGeometryRegressionTest` utvidet
      fra 24 til **36 påstander** (badHakk begge retninger, hindringsrom, åpningskontroll).
- [x] **Ingen endring i lagret dataformat.** Transittløpet er vanlige punkter i den samme
      `pathEls`-kjeden; ingen nye felt i prosjekt-JSON-en utover merkefeltene 070 alt skrev.
- [x] **`docs/kabel/galleri.html` oppdatert** — med Kenneths tegninger i tre kolonner for badet.
- [ ] **Kenneth har sett galleriet og forhåndsvisningen, og sagt «merge».**

---

## 6. Åpne beslutninger før merge

1. **Dekningsmålet ≥ 93 %** (§3g). Vannrett kan ikke nå det med InFloor 17T 47 m. Skal målet
   justeres til «så nær taket som mulig», eller skal badet ha et annet produkt?
2. **Rektangel vannrett bytter motor** (§2). Bedre på hvert mål, men det er en endring i et rom
   som alt var gyldig. Godkjennes?
3. **Dra-redigering** (Kenneths beslutning 3: uavklart). Ingenting bygget. Spørsmålet står.
4. **`flereHindringer`** (§3a) beholder «2 kabler» som forslag. Godtas det?
6. **Jevnhet som koster CC** (§6c): to rom har fortsatt et hull på 2 × CC. Den jevne løsningen
   der krever en mindre CC og koster ~6 prosentpoeng dekning. Skal motoren ta den prisen?
5. **`auto`-retningen på badet** velger fortsatt vannrett (lengdeavviket 0,00 % veier tyngre i
   poengsummen enn 4,2 prosentpoeng dekning). Loddrett får man ved å velge retningen selv.
   Skal poengsummen vekte dekning høyere når begge retninger er lovlige?

---

## 6b. 074 — bugen Kenneth meldte 14.10.2026

> «Jeg velger retning og innsetting, men den hopper tilbake og bytter visning av seg selv.
> Varselen kommer opp flere ganger, det hjelper ikke å trykke den bort.»

### Hva som var galt, målt

| # | Funn |
|---|---|
| 1 | `confirm(...)` ble kalt fra `_finishCableAutoFill` **inne i kandidatsøket**. Målt stakk: `confirm ← _finishCableAutoFill ← _autoFillCableLegacy ← _cableLegacyInDirection ← _cableCandidatesForDirection`. Én per kjøring — og `autoFillCable` kjøres på nytt ved hvert produktklikk, hver retningsendring (`_reapplyCableDirection`) og hver romflytting (mouseup-grenen som regenererer kabler). «Avbryt» ga `return null`, som utløste neste forsøk. |
| 2 | **25 % gjaldt et utlegg Kenneth aldri så.** Tallet kom fra den GAMLE kaskadens kandidat med den gamle formelen (Σ segment × CC). Vinneren (ny motor) hadde **91 %** målt av `_cableGeometryCheck`. |
| 3 | Produktforslaget brukte `getProductFamily` (blander 17T og 10T, målt i 043) og valgte på **lengde alene** → «InFloor 10T 300W 30m» i et rom som skal ha 706 W. |
| 4 | Retningsbyttet ble meldt med en toast som druknet i dialogene. |

### Hva som er rettet

- **`_finishCableAutoFill` måler og merker — den snakker ikke.** Ingen `confirm`, ingen toast,
  ingen `return null` på grunn av dekning.
- **`_cableSearchDepth`** er vakten: alt som kjøres mens den er > 0 er kandidatmåling, og
  `_cableStille()` leses av toast-veiene. En ny vei inn i søket kan ikke begynne å snakke igjen.
- **`_cableStatusLines(cable, room)` er den ene kilden** til alt brukeren ser om et utlegg:
  dekning fra `_geomMetrics.coveragePct` (068-definisjonen), gyldighet fra `_geomDefects`,
  retning fra `_dirFallback`, forslag fra `_betterProduct`. Panelet tegner linjene, toasten slår
  dem sammen — ingen av dem regner selv.
- **`_cableBetterProduct`** henter forslaget fra samme serie (`_forslagKabelSerie`, samme
  `watt_per_m` og spenning) og fra `selectCableByPower` for rommets ønskede W/m². Badet får nå
  **InFloor 17T 800W 47m (799 W)**, ikke 10T 300 W.
- **Valgt retning står.** `S.varmefolie.direction` skrives ikke av et fallback (målt: den var
  faktisk aldri skrevet — `_cableLegacyInDirection` legger den tilbake i `finally`), og panelet
  sier nå eksplisitt «Retning: loddrett (valgt)» med «Prøv loddrett likevel» når noe annet ble lagt.
- **Effekt-merket er merket som effekt.** «129 W/m² ● ok» leste som en dom over hele utlegget;
  det står nå «● ok effekt», så det ikke forveksles med dekningen rett under.

### Målt etter

Badet med **InFloor 17T 700W 41m, 120 W/m², start nedre høyre, loddrett valgt**:
**null nettleserdialoger, null toasts**, ett gyldig loddrett utlegg (geo, CC 13,18 cm, 41,03 m,
+0,07 %, dekning 91 %), retningsvelgeren uendret. Panelet sier:

> ● Forhåndsvises — InFloor 17T 700W 41m
> 129 W/m² ● ok effekt · CC 13,2 cm · 41,0 m kabel
> Retning: loddrett (valgt)
> ⚠ 0,53 m² (9 %) uten kabel
> Bedre: InFloor 17T 800W 47m (799 W) · **Bytt**

**Loddrett med 41 m ER gyldig** (STEG 0.2) — fallbacken slår altså ikke inn på denne geometrien.
Forhåndsvisning → Godkjenn kjører kaskaden **én** gang totalt (målt teller: 1 før, 1 etter).

---

## 6c. 074b — jevn avstand går foran dekning

Kenneths regel, 14.10.2026: **«Det er alltid viktigere å få en jevn avstand mellom kabelløpene
enn å dekke helt ut mot veggene — heller dra inn kabel fra vegg for å få jevnest mulig utlegg.»**

⚠ Dette måles **per bånd**, ikke globalt. Transittbanen brukes bare på den ene siden av
hindringen, så en global CC-måling sa «helt jevnt» mens båndet over stubben hadde et hull på
2 × CC. `_geoWorstBandGap` sampler sju høyder, og teller bare mellomrom der midtpunktet ligger i
lovlig område — et stort mellomrom over en hindring er ikke en feil.

Transitt-variantene prøves nå i denne rekkefølgen:

1. **skjøvet** — cellen gir fra seg sitt ytterste løp (mot veggen) og overtar den tomme
   transittbanen. CC uendret, hullet flyttes ut til veggen. *Dette er Kenneths regel.*
2. **kappet** — banen beholdes av eieren, kappet til A-siden.
3. **fjernet** — den opprinnelige 072-varianten, med en overgang på 2 CC.

Poengsummen straffer hull tungt (−40 × overskytende), tyngre enn dekningsleddet (30), så et
jevnt utlegg vinner over et med hull selv når det dekker mer.

**Badet loddrett, 47 m:** 0 tomme baner, CC uendret 11,60, dekning 92,7 → 92,5 %.
**Badet loddrett, 41 m:** 0 tomme baner, CC 13,18 → 13,81, dekning 91,0 → **94,9 %**.

⚠ **074e: samme regel for alle kabellengder.** `_geoInteriorHoles` dømte hele banen under ett
(«dekket > 40 % → brukt»), og var derfor blind for at 600 W brukte transittbanen BARE under
stubben mens 700 W brukte den både over og under. Nå måles de udekkede BITENE av hver bane hver
for seg. I tillegg: nabotrinn-søket prøver trinnet det alt står på (dN = 0), bisekterer
trimmingen mot den HULLFRIE variantens egen lengde (`fastLenHullfri`), og stopper ikke på
første treff. Badet loddrett er nå hullfritt for 500/600/700/800/900 W.

⚠ **074d: CC-valget er 016 sitt, men jevnhets-søket får ikke røre det.** Kenneth ba om at «CC
aldri skal utenfor anbefalt område». En GLOBAL sperre går ikke: 016 bestemte bevisst at CC over
anbefalingen er en advarsel, ikke en sperre, fordi kabelens lengde styrer flateeffekten (36 m i
10 m² trenger CC 27,8 for 60 W/m²; klemt til 20 blir det 85). Sperren ligger derfor på
nabotrinn-søket alene, sammen med en dominans-vakt: et nabotrinn får bare overta når det er
bedre eller likt på HVERT mål (gyldig · lengde · dekning · klaring · bøyeradius · utenfor · ⚠ CC).

⚠ **Og ⚠-et på etiketten betyr ikke «CC utenfor anbefaling»** — det tennes også av
`_geomDefects`. I Kenneths bugrapport betydde det at utleggene BRØT EN HARD REGEL. Det var den
ekte skaden i 074c, og dominans-vakten er svaret på den.

⚠ **074c rettet selve målingen.** Avstandsmålingen fra 074b slo ut på kantsonen mellom løpenes
ender og stubben, og rapporterte «9 × CC» for et utlegg der hver naboavstand var 13,8 cm — den
straffet altså det jevneste utlegget hardest. Riktig måling er BANEBRUK (`_geoInteriorHoles`):
en bane som står helt tom med brukte naboer på begge sider er et hull; ligger den ytterst, er
det stripen inntil veggen. CC er dessuten TRINN, ikke en skala — den jevne løsningen for 41 m lå
på nabotrinnet, og søket prøver nå N ± 1 og N ± 2 når vinneren har et hull.

**Ikke løst:** `enHindring` loddrett og `uRom` begge veier har fortsatt én tom bane — der er den
skjøvede varianten ikke gyldig, og den eneste jevne løsningen krever en annen CC. Målt på 47 m
ville det kostet **6 prosentpoeng dekning** (92,7 → 86,7 %). Det er en annen avveining enn den
Kenneth beskrev, og er derfor ikke tatt av motoren — se §6 åpen beslutning 6.

---

## 7. Transittløpet (072) — hva det er, og hva det koster

**Problemet, målt:** veggstubben i badet deler de ni venstre løpene i to celler som ligger på
NØYAKTIG samme løpsposisjoner, bare stablet oppå hverandre. En U-sving kobler to naboløp ved
siden av hverandre — ikke to biter av samme løp. `_geoHandoff` svarte «samme løpsposisjon», og
hele retningen endte som «ingen løsning». Det var ikke en geometrisk kjensgjerning; det var en
manglende korridor.

**Hva et transittløp er:** ett vanlig løp som får sin egen bane i rutenettet —
(1) et **tverrløp** langs hindringens kant, én CC fra nærmeste U-sving og med kantavstand til
veggen, (2) en **sving rundt hindringens ende**, (3) et **nedløp** i den reserverte banen, der en
helt alminnelig U-sving tar over. Det er ikke et hopp, og det får ingen dispensasjon:
`utenfor`, `naerforing`, `boy` og `kryssing` måles på det som på alt annet.

**Hva det koster:** banen tas ut av cellen den ellers hørte til, så overgangen over den blir én
bredere halvsirkel (radius CC i stedet for CC/2 — en *slakere* sving, ikke en trangere), og
stykket av banen som ikke brukes blir en kald stripe. Søket prøver derfor alltid **uten** transitt
først; færrest transitter vinner når alt annet er likt.

**Kenneths egen tegning viser nøyaktig dette:** over stubben ligger løpene hans på 778 og 801 —
to CC fra hverandre, med bane ~790 tom. Målt i tegningen med pikselprobe, ikke anslått.

**Grensen:** inntil to transitter per utlegg (to lag varianter). `flereHindringer` trenger seks
og løses ikke — se §3a.

---

## 8. Lag C: rutenettet når helt ut til kanten (072)

**Før:** `N = floor(W/cc)+1`, og resten av bredden (opptil én CC) ble delt likt på begge sider.
Symmetrisk — men ytterste løp havnet opptil en halv CC inne i det lovlige området, og hele
kantstripen lå kaldt uten at noe krav var brutt. Målt på badet: 5 cm-marginbåndet rundt rommet
er 0,58 m² av 5,89 m² = **9,9 %**.

**Nå:** antallet løp N er den frie HELTALLS-knappen, og CC utledes av den: `cc = W/(N−1)`.
Rutenettet spenner nøyaktig over det lovlige området, ytterste løp ligger PÅ grensen, og
dekningen deres rekker helt bort til veggen. Kantavstanden er fortsatt symmetrisk — nå med null
slark i stedet for lik slark. Kallerens `cc` er et ØNSKE; `grid.cc` er den faktiske, og kabelen
bærer den videre (uten det siste løy `spacing_cm` om CC, og kontrollen målte dekningen med feil
radius).

---

## 9. Like lange løp — regelen er BEGRENSET, ikke fjernet

Kenneths beslutning 2: «Løpene skal følge vegger og trinn innenfor sin celle … ikke kappes til
lik lengde.» Den låste regelen i CLAUDE.md («Equal-length runs (LOCKED) — after generating
polygon-clipped runs, find the shortest common sweep range and clip ALL runs to match») klippet
hvert eneste løp i cellen til `[max(lo), min(hi)]`.

**Nå gjelder den bare for PARET som faktisk møtes i en U-sving.** Svingen mellom løp k og k+1
legges på det nivået begge når; løp mellom to trinn blir nøyaktig så langt dets eget lovlige
område tillater. Trinn-splitten (et trinn større enn én CC gir en cellegrense) står uendret — uten
den ville «paret» måtte spenne over et 107 cm sprang, og svingen blitt en lang diagonal: nettopp
Y-greina den låste regelen verner mot.

⚠ **Ved merge må CLAUDE.md oppdateres.** Den låste regelen der er skrevet for de gamle motorene og
stemmer ikke lenger for `generateCableGeo`. Endringen er gjort på Kenneths eksplisitte ønske
(beslutning 2), ikke på eget initiativ.

⚠ **Målt, mot forventning:** like-lengde-regelen var *ikke* der dekningen forsvant. Den klippet
bare 0,1 % vannrett og 0,7 % loddrett i badet. De manglende prosentpoengene lå i kantstripen
(§8) og i lengdetrimmingen (§3g).
