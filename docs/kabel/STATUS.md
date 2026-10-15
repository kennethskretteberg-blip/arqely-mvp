# Kabelmotor 068–076 — status, merge-sjekkliste og hva som ikke er løst

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

---

## 10 · Status 14.10.2026 — hva som virket, hva som ikke virket, og hvorfor

Skrevet på Kenneths bestilling: «gi meg heller en status på hva som gjorde at det funket veldig
bra i sta.» Underlag for sparring før neste runde.

### 10.1 Tidslinje med Kenneths egne dommer

| commit | hva den gjorde | Kenneths dom |
|---|---|---|
| `884fc74` 072 | transittløp — én reservert bane forbi veggstubben | — |
| `5463546` 074 | stille kandidatsøk, én beskjed, riktig produktforslag | — |
| `baa6e37` 074b | hullet flyttet ut til veggen (**ved uendret CC**) | «47 m er perfekt» |
| `9f60af9` 074c | finere hullmåling + **fritt søk over CC-stigen** | **«nå ble det dårligere»** |
| `cad5ee0` | tilbakerulling av 074c | — |
| `30ea330` 074d | 074c på nytt, + dominans-vakt, + CC-sperre på trinnsøket | **«mye bedre»** ← beste kjente |
| `c6d198c` 074e | hullmåling per bane-BIT + bredere trinnsøk | **«like dårlig igjen»** |

**Beste kjente tilstand er `30ea330` (074d).**

### 10.2 Mønsteret: å flytte CC ødelegger, å flytte BANER gjør det ikke

Dette er den ene linja som forklarer alle tre rundene.

| type endring | hva den rører | resultat |
|---|---|---|
| **Baneeierskap** (072 transitt, 074b skjøvet/kappet) | hvilken celle som eier hvilken bane. **CC uendret.** | Virket hver gang. «47 m perfekt». |
| **CC-flytting** (074c og 074e sitt trinnsøk) | hvilket trinn på CC-stigen utlegget legges på | Ødela hver gang, i Kenneths rom. |

CC er ikke en fri knapp. Den henger sammen med **lengden** (produktet skal brukes opp, ±1 %),
**flateeffekten** (016: 36 m i 10 m² TRENGER CC 27,8 for 60 W/m²) og **celleinndelingen** (et
nytt CC gir et nytt rutenett, nye celler, en ny rute). Når søket flytter CC for utseendets
skyld, rives alle tre.

### 10.3 Hva ⚠ på etiketten faktisk betyr

Jeg tok feil om dette én gang, og det kostet en runde. Etiketten (`:35138`):

```js
(_ccOverWarn(prod, ccCm) || cable._geomDefects.length) ? '⚠ ' : ''
```

Romtypen «Bad» har hverken nedre eller øvre CC-grense, og produktets anbefaling er 20 cm. Når
Kenneth ser «⚠ CC 14,9» betyr det derfor **ikke** at CC er utenfor anbefalingen — det betyr at
utlegget **bryter en hard regel** (utenfor lovlig område, kryssing, bøy, nærføring, lengde).
«Krysser vegger» i 074e er nøyaktig det.

### 10.4 ⚠ Den egentlige svakheten: jeg tester mot feil rom

Alle tre rundene er målt mot `badHakk` / `badHakk41` — badet i **Ekebergveien 28**, 5,887 m²,
rekonstruert fra prosjektets koordinater i 072.

Kenneths skjermbilder er fra et **annet** bad: **Rom 5, 5,70 m²**, V1 260 · V2 75 · V3 39 ·
V4 129 · V5 300 · V8 13 · V9 100 · V10 93. Annen bredde, annen stubbe, annet trinn.

Målt på fixturene etter 074e: **null rom krysser vegger, null rom er ugyldige.** Samme kode gir
et ugyldig utlegg i Kenneths rom. Jeg har altså tre ganger på rad erklært noe som «grønt» på et
grunnlag som ikke dekker tilfellet det skulle løse.

**Dette er blokkeringen, ikke geometrien.** Uten Rom 5 som fixture er hver neste runde like
blind som de tre foregående.

### 10.5 Det som står igjen, teknisk

- **Vannrett** har fortsatt tomme baner for 500/600/700 W (loddrett er ryddet).
- `flereHindringer` trenger seks transittkorridorer; taket er to. «2 kabler» er riktig svar der.
- `kabelForLang` og `boyUmulig` er fysisk umulige og merkes.
- CLAUDE.md sin låste like-lengde-regel må oppdateres ved merge (begrenset i 072).
- Rent rektangel vannrett byttet motor i 072 (geo dominerer på hvert mål) — må godkjennes.

### 10.6 Spørsmål til sparringen

1. **Skal CC i det hele tatt få flyttes for jevnhetens skyld?** Alternativet: lås CC til
   lengde/effekt, og la jevnheten bare avgjøres av baneeierskapet (det som alltid har virket).
   Prisen er at noen rom beholder én tom bane.
2. **Hva er riktig når jevn avstand og full kabellengde slåss?** I dag vinner lengden (±1 % er
   et hardt krav). Skal et utlegg kunne være 2 % kort hvis det blir jevnt?
3. **Rom 5 som fixture** — kan jeg få koordinatene (f.eks. prosjekt-JSON for rommet)? Uten dem
   kan jeg ikke etterprøve det du faktisk ser.

---

## 11 · 076 — Rom 5 er fasiten, CC er låst, og beste tilstand er merket

### 11.1 Hvilken commit ga fasiten (STEG 0.2)

Rom 5, InFloor 17T 700W 41m, loddrett, start øverst til høyre:

| commit | CC | lengde | gyldig | kryss/knekk | ⚠ |
|---|---|---|---|---|---|
| `30ea330` 074d | **13,20** | 40,97 m (−0,07 %) | ja | 0 / 0 | nei |
| `c6d198c` 074e | **13,20** | 40,97 m (−0,07 %) | ja | 0 / 0 | nei |

⚠ **De er identiske.** Alle fire kabellengder og begge retninger ga bit for bit samme resultat
på de to versjonene. Forskjellen Kenneth så i nettleseren lå altså IKKE i `generateCableGeo`.

Jeg klarte heller ikke å reprodusere ⚠-et fra den LAGREDE Rom 5-geometrien: gjennom hele
kaskaden (`_autoFillCableImpl`), alle fire starthjørner, begge retninger og auto — alt gyldig,
ingen defekter, ingen CC-advarsel, på begge versjoner. Den mest sannsynlige forklaringen er at
rommet på skjermen var redigert og ikke identisk med det lagrede (Rom 5 har ingen lagret kabel).
**Dette står åpent** — se 11.5.

Tag satt på den eldste av de to, altså den med færrest bevegelige deler:
`kabelmotor-fasit-rom5` → `30ea330`.

### 11.2 Veien videre ble bygget PÅ tagen, ikke ved tilbakerulling

`git diff e7a37b2 30ea330 -- index.html` var tom — koden i HEAD var allerede 074d (074e ble
rullet tilbake i `e7a37b2` på Kenneths ord). 076 er derfor bygget rett oppå, uten ny revert.

### 11.3 CC er låst

Nabotrinn-søket — det eneste som flyttet CC for utseendets skyld — er **fjernet**
(`generateCableGeo`, lengdesøket). CC regnes av lengden og netto areal som 016 bestemte, og
klemmes til grensene. Hullstraffen i `_geoScore` står: en jevn variant vinner fortsatt over en
holete **på samme CC**, men kan ikke lenger kjøpe jevnhet ved å flytte CC.
`fastLenHullfri` er borte. Dominans-vakten fra 070/074d står.

**Prisen, målt:** `badHakk41` mister sin hullfrie løsning. Ved CC 13,18 er kappet-varianten den
eneste uten hull, og den lander på 42,23 m = +3,01 % — utenfor ±1 %. Rommet beholder derfor
én tom bane (91,0 % dekning mot 94,9 % med trinnsøket). `rom5` og `badHakk` er hullfrie.

### 11.4 Rom 5 som fast regresjon

`_cableFixtures.rom5` — ekte geometri hentet lesende fra «Ekebergveien 28 (kopi)» / «Rom 5»,
5,698 m² netto, ti punkter, ingen hindringer/soner/kundedata. Veggmålene stemmer med Kenneths:
V1 260 · V2 75 · V3 39 · V4 129 · V5 300 · V6 99 · stubbe 100/13/98 · V10 93.

`_cableGeometryRegressionTest` låser nå: gyldig · CC 13,2 ± 0,2 · én sammenhengende bane ·
ett transittløp · ingen tom bane midt i en celle · start i valgt hjørne · 0 kryss / 0 knekk.
De andre lengdene og vannrett: gyldige, eller en BEGRUNNET «ingen løsning».
Galleriet viser Rom 5 øverst, med tegning · fasit bygget og kontrollert · motoren.

**Rom 5 i galleriet:** loddrett ok 93,4 % CC 13,20 · vannrett ok 93,4 % CC 12,93.
500 W og 800 W loddrett gir «ingen løsning» (begrunnet: fire soner); begge går vannrett.

### 11.5 Fremgangsmåte for hver videre runde — ufravikelig

Før Kenneth ser noe som helst:

1. Kjør galleriet med **rom5 + badHakk + badHakk41**, alle lengder, begge retninger.
2. Sammenlign rom for rom mot `kabelmotor-fasit-rom5` (`git show kabelmotor-fasit-rom5:index.html`
   kan serveres som en egen side og måles med samme probe).
3. **Avvis endringen** hvis ett eneste av dem blir dårligere på noe mål.

Kenneths dom i nettleseren er sluttkontrollen, ikke måleinstrumentet. ⚠ Og `rom5`-fixturen er
den LAGREDE geometrien — er rommet redigert på skjermen, måler fixturen noe annet. Spør om en
fersk kopi når et skjermbilde og en måling er uenige.

---

## 12 · ⚠ FEIL DIAGNOSE — TRUKKET TILBAKE (se §13)

Her sto påstanden «en LÅST CC hopper over hele den nye motoren», basert på hengelåsen ved
«149 mm» i Kenneths skjermbilde. **Den var feil.** Hengelåsen er ikke en CC-lås, og Rom 5 går
ikke den veien. Rettelsen og den etterprøvde forklaringen står i §13.

Det som ble målt den gangen STEMMER fortsatt, og er verdt å beholde: setter man
`room._forcedSpacingCm = 14,9` på Rom 5, kjøres utlegget på V6 og lander 293 cm utenfor rommet
med 34 kryssinger. Det er en ekte svakhet i den veien — men det var ikke det Kenneth så.

---

## 13 · Hva hengelåsen faktisk er, og hva «den gamle veien» er

### 13.1 «149 mm 🔒» er `cable.lockedEnd` — ikke en CC-lås

Ctxbar-koden (`updateCtxBar`, kabelgrenen):

```js
const ccLocked = cable?.lockedEnd;
const spDisabled = ccLocked ? ' disabled style="opacity:0.4;pointer-events:none"' : '';
… `${spMm} mm${ccLocked ? '<lås-ikon>' : ''}`
```

`lockedEnd` settes automatisk for **ethvert produkt med fast kabellengde**:
`lockedEnd: !!prod.cable_length_m` (sju steder i motorene). Den er altså PÅ for alle InFloor-
kabler, uten at noen har trykket på noe.

Hva den gjør: sperrer ⟷ − og ⟷ + (`_cableSpacingDelta` returnerer tidlig på `lockedEnd`).
Det er riktig oppførsel — en kabel med fast lengde kan ikke kappes, så CC kan ikke settes fritt;
CC følger av lengden og arealet. Låsen er med andre ord **normaltilstanden**, ikke en feil, og
ikke noe Kenneth har slått på.

### 13.2 `_forcedSpacingCm` er noe HELT annet, og har ingen knapp

Det er feltet §12 forvekslet låsen med. Det settes **bare to steder**, begge i flerkabel-sone-
maskineriet (`_buildNCableZones` og sone-orkestreringen), aldri fra verktøylinja.

### 13.3 «Den gamle veien» — hva det betyr

Siden 070 er kabelmotoren en konkurranse: ny motor (`generateCableGeo`) og de fire gamle
(skew, boustrophedon, V6, serpentine) legger hvert sitt forslag, alle måles med
`_cableGeometryCheck`, og ny motor tar bare over når den ikke er dårligere på noe mål.

Men `_autoFillCableImpl` har en tidlig retur FØR konkurransen:

```js
if (room._forcedSpacingCm != null || room._zoneId != null || S.ui.fillTargetZoneId != null) {
  return _autoFillCableLegacy(roomId, productId, opts);   // ← «den gamle veien»
}
```

Altså: **et rom som er delt i flerkabel-soner kjører kun de gamle motorene.** Begrunnelsen fra
070 er ekte: sonene må ha SAMME CC for å få lik W/m² over sømmen, og ny motor søker sin egen CC
per sone uten å kjenne den bindingen — målt 20,67 cm i én sone mot 20,6 i nabosonen.

⚠ **Rom 5 har ingen soner og ingen tvungen CC.** Det går gjennom konkurransen som alle andre rom.
§12 sin forklaring gjaldt derfor ikke Kenneths tilfelle.

### 13.4 Hva som er utelukket — og hva som gjenstår

Målt på `rom5`-fixturen, gjennom hele kaskaden (`_autoFillCableImpl`), alt gyldig, ingen defekter:

| prøvd | resultat |
|---|---|
| 074d mot 074e | identisk, begge gyldige |
| alle fire starthjørner | gyldig |
| begge retninger + auto | gyldig |
| flateeffekt null og 120 W/m² | gyldig (endrer bare produktforslaget) |
| veggmargin 0 → 10 cm | gyldig i hele området |
| 500/600/700/800 W | gyldig (500/800 loddrett: begrunnet «ingen løsning») |

**Ingen av dem gir CC 14,9 i loddrett.** Fixturen gir 15,28 loddrett og 14,91 VANNRETT — og
Kenneths panel sa «Retning: loddrett (valgt)» med loddrette løp og CC 14,9.

**Konklusjonen står åpen.** Mest sannsynlig er rommet på skjermen ikke identisk med det lagrede
Rom 5 (det har ingen lagret kabel, så det er aldri godkjent). Det som ville avgjøre det:
Kenneth trykker GODKJENN og lagrer, og sier fra — da kan rommet OG kabelen leses ut som de
faktisk var, i stedet for å gjettes.

---

## 14 · ✅ ROTÅRSAKEN, MÅLT PÅ KENNETHS EGET LAGREDE UTLEGG

Kenneth godkjente og lagret kabelen i Rom 5 15.10.2026 03:33 UTC. Da kunne den leses ut, og
spørsmålet som sto åpent i §13.4 er nå besvart.

### Den lagrede kabelen

| felt | verdi |
|---|---|
| motor | **`v6`** — den gamle motoren, ikke `geo` |
| CC | 14,949 cm (= «149 mm» i verktøylinja) |
| form | 20 `runs`, 2 `connections`, **0 `pathEls`** |
| `_geomOk` | **false** |
| `_geomDefects` | **utenfor · kryssing · nærføring · lengde · brudd** |

Rommet er bit for bit identisk med `rom5`-fixturen (samme ti punkter), ingen soner, ingen
hindringer, ingen tvungen CC. Den nye motoren deltok altså ikke i konkurransen — V6 vant fordi
den var alene.

### Hvorfor: clipper-lib var ikke lastet

`_cableLegalRegion` trenger clipper-lib for ekte polygon-offset. Biblioteket lastes **lat fra et
CDN** (`_cblLoadClipper`, 068), og er det ikke lastet, faller funksjonen tilbake på
`_offsetPolygon` — hjørnevis offset, som kommentaren selv sier er «mindre riktig i konkave
hjørner». Rom 5 har en konkav veggstubbe.

Målt på fixturen, samme rom og samme innstillinger:

| | motor | CC | gyldig | defekter |
|---|---|---|---|---|
| `_cblClipperReady() === false` | **v6** | 14,14 | **nei** | utenfor · kryssing · nærføring · lengde · brudd |
| clipper lastet | **geo** | 15,28 | **ja** | ingen |

Den øverste raden er Kenneths utlegg.

### ⚠ Ingen venter på lastingen før kabel legges

`_cblLoadClipper()` kalles bare **tre** steder:

| sted | hva |
|---|---|
| `_cableGalleryRun` | galleriet |
| `_cableGeometryRegressionTest` | testbatteriet |
| `_geomSjekkLagredeUtlegg` | 072-kontrollen ved prosjektåpning |

**Ingen av dem er utleggsveien.** `_autoFillCableImpl` er synkron og sjekker aldri om
biblioteket er klart — den bare kjører. Første auto-utlegg i en økt treffer derfor et
`_cblClipperState === 'idle'` med mindre prosjektåpningen rakk å laste det først.

Det forklarer alt som har vært uforklart:

- **hvorfor det vekslet mellom Kenneths skjermbilder** — et kappløp mot CDN-et,
- **hvorfor alle mine målinger var grønne** — jeg `await _cblLoadClipper()` alltid først,
- **hvorfor 074d og 074e var identiske** — ingen av dem rører dette,
- **hvorfor det så ut som en geometrifeil** — utlegget KOM fra en motor 068 allerede hadde målt
  til å krysse seg selv.

Tilbakefallet er dessuten **stumt**: `_cableLegalRegion` setter `approx: true`, men ingenting
leser det, og brukeren får ingen beskjed.

### Forslag (BYGGET 15.10.2026 som 077 — se §15)

1. **Forhåndslast ved oppstart.** Ett `_cblLoadClipper()` i oppstarten fjerner kappløpet i
   praksis.
2. **Ikke tap stumt.** `_autoFillCableImpl` bør vite at området er tilnærmet: enten utsette
   utlegget til biblioteket er klart, eller merke kabelen slik 070 merker alt annet.
3. **Egen fixture-variant** i galleriet som kjører med clipper slått av, så dette ikke kan
   komme tilbake uoppdaget.

⚠ Dette er en **gren-feil**, ikke i drift: hele clipper/geo-maskineriet kom i 068, og `main`
står på 073 (bygget på 1519bb0, før 068).

---

## §15 · 077 — fiksen (bygget 15.10.2026)

Alle tre forslagene i §14 er bygget. Ingen terskel og ingen motor er rørt; dette handler bare om
at biblioteket er på plass før noe legges ut.

**1. Forhåndslast ved oppstart.** Ett `_cblLoadClipper()` rett etter `initSupabase()`.
Målt på en kald lasting: skriptet hentes 112 ms etter navigasjonsstart og er i minnet etter 114 ms
— lenge før noen kan rekke å klikke et produkt. Kommentaren på `_cblLoadClipper` som fortsatt
påsto «LAT, bare når kontrollen faktisk kjøres» er oppdatert; den var blitt usann.

**2. Utleggsveien venter — betinget.** `_cablePreviewPlace` er delt i to:
en vakt som venter, og `_cablePreviewPlaceNow` med den gamle kroppen.

> ⚠ **Første forsøk gjorde hele funksjonen `async`, og det var feil.** Jeg skrev i kommentaren at
> «ingen kallsted leser tilstand synkront etter kallet». Det var en antakelse, ikke en måling:
> `_soneRegressionTest` (8 påstander) og «Fyll rom automatisk» (`room._cablePreviewMeta`,
> `_confirmCablePreview`) gjør nøyaktig det. Testbatteriet fanget det. Vakten venter derfor bare
> når biblioteket faktisk ikke er klart — er det klart, er kallet synkront akkurat som før.

**3. Ikke tap stumt.** `_autoFillCableImpl` setter `cable._geomApprox = true` når området bare var
tilnærmet, og `_cableStatusLines` gir en advarsel: *«Lagt uten polygonbiblioteket — kantene er
tilnærmet. Legg på nytt for et eksakt utlegg.»* Fail-open som 060: det legges fortsatt ut.

**4. Låst med en test.** Seks nye påstander i `_cableGeometryRegressionTest` kjører Rom 5 **med
clipper slått av** og sammenligner:

| | motor | gyldig | merket |
|---|---|---|---|
| clipper av | v6 | nei (utenfor · kryssing · nærføring · lengde · brudd) | `_geomApprox` + panellinje |
| clipper på | **geo** | **ja** | — |

Pluss to oppførselspåstander som hindrer at `async`-feilen kommer tilbake: klart bibliotek skal
gi et **synkront** kall, ulastet skal gi et løfte.

**Status:** 22 av 22 batterier grønne (`_cableGeometryRegressionTest` 77 påstander).
Galleriet er ikke regenerert — det `await`-er biblioteket selv og har derfor uendrede tall.

**Sidefunn, rettet i samme runde:** `_prosjektlaasRegressionTest` sin påstand «i går gir «i går
HH:MM»» brukte «30 timer siden», som før kl. 06 lander i forgårs. Den var rød av klokka, ikke av
koden. Bygger nå i går eksplisitt (kl. 12 lokalt).

---

## §16 · 078 — «GODKJENN lagrer ikke» var feil. Indikatoren løy.

Jeg tilbød en fiks for at GODKJENN ikke lagret. **Den feilen finnes ikke, og målingen viste det
med en gang.** Diagnosen var en grep etter `_scheduleAutoSave` i bekreftelsesveien — ikke en
måling av kodestien. `pushUndo` kaller `_scheduleAutoSave()` på siste linje, og `_cablePreviewPlace`
kaller `pushUndo`. Målt på den ekte veien:

| steg | planlagte lagringer |
|---|---|
| `_cablePreviewPlace` | **1** |
| `_confirmCablePreview` | 0 (trenger ikke) |
| `finishRoomWorkflow` | 0 (trenger ikke) |

Den ene grenen i `pushUndo` som hopper over planleggingen (`_undoSuppress > 0`) er også tett:
alle fem undertrykkelsene kaller `pushUndo()` **før** de skrur den på.

**Men symptomet Kenneth opplevde var ekte, og årsaken lå i indikatoren.** Målt: etter GODKJENN er
`_projectDirty === true`, mens lagre-indikatoren er **byte-identisk** med før endringen —
«Lagret 05:54:47», grønn prikk. Den hadde ingen tilstand for «ikke lagret ennå»; de fem den kjente
var `saving`, `saved`, `offline`, `error`, `readonly`. I vinduet mellom en endring og at
autolagringen fyrer (≥ 5 s, lenger hvis man fortsetter å jobbe) påsto den at alt var lagret.
Derfor trykket han Lagre manuelt — indikatoren ga ham ingen grunn til å tro noe annet.

**Fiksen** er en sjette tilstand, satt i `_scheduleAutoSave` — funnelen alle 50 mutasjonsveiene
går gjennom, ikke på 50 kallsteder, samme arkitektur som 030 og 060 §3 bruker:

| tilstand | prikk | tekst | tittel |
|---|---|---|---|
| `saved` | grønn, fylt | 05:56:52 | Lagret 05:56:52 |
| `dirty` | grå, **åpen ring** | 05:56:52 | Ulagrede endringer – sist lagret 05:56:52. Lagres automatisk. |
| `saving` | oransje, fylt | — | Lagrer… |

Dempet og åpen, ikke rød: autolagringen tar det om fem sekunder, så dette er en opplysning, ikke
en feil. Tidspunktet står igjen fordi «sist lagret 05:56» er nyttig. Kontrast regnet (panelet var
skjult, så ikke sett): `#9097a8` på `#1b1d21` ≈ 5,8:1.

Fem nye påstander i `_prosjektlaasRegressionTest`, som alt eier regelen «indikatoren lyver ikke»:
skitten ≠ lagret, teksten sier «Ulagrede endringer», tidspunktet beholdes, kundemodus rører den
ikke (030), og skrivebeskyttet vinner over skitten (060 §3).

**Lærdom, samme som §15:** jeg skrev en grep som om den var en måling. Begge gangene i samme
serie. STEG 0 er ikke å lese koden — det er å kjøre den.

---

## §17 · 079 — jevn CC over hele gulvet (15.10.2026)

Kenneths regel, ordrett 15.10.2026:

> «Kabelstrengen som går vannrett langs utstikkeren må fortsette litt lenger inn i rommet, slik
> at løpet som skal gå loddrett flukter med løpet ovenfor. Da skal siste løp mot yttervegg under
> utstikker flukte med siste løpet mot yttervegg over utstikker. Dersom kabel blir litt for kort,
> justeres dette med at alle løp reduseres litt på lengde. Dersom kabel er for lang, justeres
> dette med tettere cc og flere løp.»

### Hva som faktisk var galt (målt, ikke antatt)

Fixturet `rom5` ble først verifisert **bit-identisk** med Kenneths live-rom i Supabase, og det
lagrede utlegget ble lest ut og målt. Banene i det var:

```
ØVRE:  697,2 … 788,9   [804,2 TOM]   819,4 … 972,3
NEDRE: 681,9 … 972,3   (alle 20 baner)
```

Hullet oppstår **i rutingen, ikke i celledelingen.** Rutenettet ga 804,2 full høyde
(−1027→−849). Transitten kapper bane 788,9 ned til A-siden men lar den ligge igjen *inne i*
nabocellens serpentin, og U-svingen ut av en kappet bane må ligge på det kappede nivået — da
dras naboen 804,2 ned til 58 cm. Det var de 30,5 cm Kenneth så.

Og forslaget hans var forbudt av én linje i `_geoFindTransits`:
`if (Math.abs(nearB.pos - t.pos) > cc * 1.25) continue;` — klatrebanen måtte ligge inntil
ytterste bane over hindringen, så 804,2 ble aldri vurdert.

### Fire endringer

1. **079 · A-eid transittbane** (ny fjerde variant ved siden av skjøvet/kappet/fjernet).
   A-siden av transittbanen gis til celle A i stedet for å bli liggende i nabocellen. Nabocellen
   står da uklippet.
2. **079b · ytterste løp flukter.** A gir fra seg sitt ytterste løp slik at det flukter med
   cellen over hindringen. ⚠ Dette er ikke kosmetikk: med transittbanen lagt til fikk A et
   **partall** baner (8), og boustrophedon gir da inn- og utgang i samme ende — hullet flyttet
   seg bare én bane. Med oddetall kan A komme inn nede og gå ut oppe. Kenneths to instruksjoner
   viste seg å være én og samme løsning.
3. **079c · `jtRound` i `_cableLegalRegion`.** Ved et innstikkende hjørne strekker en gjæring seg
   `delta/sin(θ/2)` fra hjørnepunktet — 7,07 cm for et rett hjørne med 5 cm margin. Transittens
   sving lå 5,36 cm fra stubbenesen, lovlig etter produktkravet, men ble underkjent med «1,1 cm
   utenfor». Det ugyldiggjorde **hele CC-trinnet** for alle varianter. Kantavstand er en avstand,
   ikke en gjæring. Endringen kan bare gjøre området større.
4. **079d · for lang kabel → tettere CC og flere løp.** Kjører bare når vinneren har et hull.
   ⚠ Dette er ikke nabotrinn-søket 076 fjernet: der ble CC flyttet for å *lete etter* jevnhet, og
   det ble rullet tilbake tre ganger. Her er jevnheten allerede avgjort av baneeierskapet, og det
   eneste som gjenstår er at det jevne utlegget bruker mindre kabel enn produktet har.

### To målefeil funnet underveis

**`_geoInteriorHoles` leste `grid.lanes`,** som ikke oppdateres når en transittvariant fjerner en
bane (`Object.assign({}, grid, {cells, …})` lar `lanes` følge med urørt). Blind flekk: en bane
tom i det nedre båndet men i bruk i det øvre meldte «0 hull». Målingen leser nå senterlinja, og
teller to former for hull: sprang over 1,5 CC mellom naboløp i samme bånd, **og** en kolonne som
ikke dekker det båndet begge naboene dekker. Den siste manglet helt.

**Min egen instrumentering løy.** Jeg satte taggen i `_geoPlanTraversals`, og den siste sjekken
`_autoFillCableImpl` kjører på vinneren arvet forrige tagg. Jeg leste «A-EID GYLDIG» for tall som
kom fra `kappet`, og var i ferd med å melde en seier som ikke fantes. Tellingen per steg
(bygget / plan / sjekk / scoret) avslørte det.

### Målt resultat

| fixture | før | etter |
|---|---|---|
| rom5 600W | CC 15,28 · 34,89 m (−0,32 %) · dekning 91,5 % · **1 hull** | CC 14,52 · **35,00 m (0,00 %)** · 89,1 % · **0 hull** |
| rom5 700W | CC 13,20 · 40,97 m (−0,07 %) · 93,4 % · 0 hull | **uendret** |
| badHakk 41 m | CC 13,18 · 41,03 m (+0,07 %) · 91,0 % · **1 hull** | CC 12,61 · **41,00 m (0,00 %)** · 86,7 % · **0 hull** |

Begge rommene ga fra seg dekning og fikk jevn CC **og** eksakt produktlengde tilbake. Dekningsgulvet
i regresjonen er senket 88 → 85 %, og innrømmelsen «badHakk41 får ha ett hull» (076) er fjernet:
ingen fixture har lenger lov til å ha hull. 22/22 batterier grønne, 996 påstander.

Motoren bruker 338 ms mot 173 ms på rom5 600W — 079d kjører bare når vinneren har hull.

---

## §18 · 080 — hjørnevelgeren betyr noe (15.10.2026)

Kenneth, etter at utlegget ble godkjent: *«Det eneste som ikke stemmer er start kabel ifht
velgeren øverst til venstre i menyen hvor man setter innsetningspunkt og retning.»*

### Hva som var galt

**Hjørnevalget var dødt i geo-motoren.** Målt: alle fire valg ga identisk start, (972, −923),
oppe til høyre. To uavhengige grunner:

1. `_geoMakeCable` bar `startCorner` videre som en ren **etikett**. Ingenting orienterte banen.
2. `_geoScore` fikk `corner: wantCorner, wantCorner` inn, så `ctx.corner === ctx.wantCorner` var
   **alltid sant**. De tre poengene for riktig hjørne ble delt ut uansett hvor kabelen startet.

### Fiksen

En varmekabel har ingen egen retning — den kalde halen kan sitte i hvilken som helst ende — så
punktlista snus gratis. `_geoMakeCable` velger nå den av rutens to ender som ligger nærmest det
valgte hjørnet, og `_geoScore` måler det **faktiske** hjørnet, slik at søket kan foretrekke en
rute som virkelig starter der.

### Grensen, og hvorfor den sies fra om

Rutens to ender er gitt av geometrien. På Rom 5 med 600W er **hver eneste** kandidat `tl→tr`
eller `tl→br` — ingen rute ender nede til venstre, fordi nettopp det hjørnet er der transitten
går ut, og den enden kan ikke også være kabelens ende.

Derfor lagres `_startCornerActual` på kabelen, og panelet sier:
*«Start: oppe til venstre — nede til venstre er ikke mulig i dette rommet.»*
Nivå `ok`, ikke `advarsel`: ingenting er galt med utlegget, og `_cableStatusToast` siler bort
`ok`, så dette blir ikke en toast på hvert utlegg. Samme prinsipp som `_geomApprox` i 077 —
aldri et stumt avvik.

### Målt sluttresultat (Rom 5, loddrett, nedre venstre valgt)

| produkt | CC | lengde | hull | maks gap øvre/nedre | start |
|---|---|---|---|---|---|
| InFloor 17T 600W 35m | 14,5 | **35,00 m (0,00 %)** | 0 | 14,6 / 14,6 | tl |
| InFloor 17T 700W 41m | 13,2 | 40,97 m (−0,07 %) | 0 | 13,2 / 13,2 | tl |
| InFloor 10T 600W 60m | 8,8 | **60,00 m (0,00 %)** | 0 | 8,8 / 8,8 | tl |

22/22 batterier grønne, 1003 påstander.

---

## §19 · 081 — opp/ned i hjørnevelgeren, og hindringer målt

Kenneth 15.10.2026: *«Hjørnevelgeren funker fortsatt ikke helt. Spesielt på de vannrette
utleggene, den tar ikke høyde for om jeg setter start opp eller nede, kun venstre eller høyre.
Og når jeg velger loddrett og setter velgeren øverst til venstre, starter den [midt på veggen],
ønsker at den starter helt øverst i venstre hjørnet. Hvordan er denne motoren ifht hindringer?»*

### Hvorfor opp/ned ble ignorert

080 gjorde hjørneleddet levende, men det var fortsatt **binært på kvadrant**
(`ctx.corner === ctx.wantCorner`). ⚠ MÅLT: starten på Rom 5 lå 21 cm over rommets midtlinje og
ble derfor målt som «øvre» — poengleddet så ingen forskjell på den og et punkt 68 cm høyere
oppe. Leddet er nå **gradert på avstand** til det valgte hjørnet
(`_geoCornerDist`, `s += 4 * (1 − d/diagonal)`), og da teller sveipeaksen med.

Målt på Rom 5, 700W vannrett: `tl` → y = −841, `bl` → y = −1035 (rommet er −836 … −1040).
Opp/ned blir hørt på.

### Loddrett: paritet låser starten, og det er den samme loven som 079b

Alle kandidater starter på (695, −917) — **ingen rute ender øverst til venstre**. Det øvre
venstre feltet har **6 baner, et partall**. Kabelen kommer inn nedenfra via transitten under
utstikkeren, og med partall baner må den ut i samme ende den kom inn. For å komme ut øverst må
feltet ha et oddetall baner — altså ett løp mindre, som koster dekning og endrer utlegget
Kenneth nettopp godkjente. **Ikke gjort. Venter på Kenneths beslutning.**

I stedet lagres `_startCornerOffCm` og panelet sier:
*«Start: 83 cm fra oppe til venstre — nærmere er ikke mulig med dette utlegget.»*
(Nivå `ok`, så den ikke toaster.) Kvadrant-meldinga fra 080 står ved siden av, for de tilfellene
der hjørnet er helt umulig.

### Hindringer — målt, ikke antatt

| fixture | resultat |
|---|---|
| `enHindring` loddrett | 96,00 m (0,00 %) · 0 hull · 0 kryssinger · 0 utenfor · dekning 90,7 % · **gyldig** |
| `enHindring` vannrett | 96,00 m (0,00 %) · 0 hull · dekning 91,8 % · **gyldig** |
| `flereHindringer` (3 stk) | **UGYLDIG** — 2139 cm utenfor, brudd, nærføring 0 cm, +24 % lengde |

Med **én** hindring legger motoren seg rundt den på nøyaktig samme måte som rundt veggstubben —
samme transittmekanikk, samme kantavstand. Med **tre** faller den gjennom: 10 celler som trenger
6 transittkorridorer mot et tak på 2. Ny motor finner ingen løsning, og en av de gamle vinner
alene med et ugyldig utlegg. Står fra før på lista over ting som må løses før merge.

### Uendret

| | |
|---|---|
| 600W 35m | CC 14,5 · 35,00 m (0,00 %) · 0 hull · gap 14,6/14,6 · 89,1 % |
| 700W 41m | CC 13,2 · 40,97 m (−0,07 %) · 0 hull · gap 13,2/13,2 · 93,4 % |
| 10T 600W 60m | CC 8,8 · 60,00 m (0,00 %) · 0 hull · gap 8,8/8,8 · 91,8 % |
| badHakk41 | CC 12,6 · 41,00 m (0,00 %) · 0 hull · gap 12,7/12,7 · 86,7 % |

22/22 batterier grønne, 1008 påstander.

---

## §20 · 082 — ett løp mindre, og hva det faktisk koster

Kenneth 15.10.2026: *«ta ett løp mindre i øvre felt.»*

### Mekanismen virker

Paritetsvarianten er bygget (`_geoParityVariants`): ytterste bane fjernes fra én celle, aldri en
inne i cellen. Det flipper pariteten, og dermed hvilken ende kabelen kommer ut i. **Målt at den
når hjørnet for alle tre produktene på Rom 5: 26 / 33 / 25 cm, hullfritt.**

### Men prisen er høyere enn den så ut

Med fritt søk nedover CC-stigen brøt runden to låste påstander:

| | før | med fritt paritetssøk |
|---|---|---|
| Rom 5 700W | CC **13,2** (Kenneths fasit) · 93,4 % | CC 12,6 · 91,4 % |
| badHakk loddrett | 92,5 % dekning | 89,7 % |
| regresjonssuiten | 14 s | **over 100 s** |

Runden kjøpte altså hjørnet ved å forringe utlegg Kenneth allerede har godkjent — og 076 låser
nettopp CC 13,2 som fasit for Rom 5.

### Hva som står i koden nå

Paritetsrunden kjører **bare på vinnerens egen CC**, ett forsøk, og aksepterer bare når
resultatet er hullfritt, like nær lengden, og ikke har lavere dekning. Da:

| produkt (Rom 5, loddrett, «øvre venstre») | start | utlegg |
|---|---|---|
| InFloor 17T 600W 35m | **26 cm fra hjørnet** | CC 14,52 · 35,00 m · 0 hull · 89,1 % |
| InFloor 17T 700W 41m | 83 cm | CC 13,20 · 40,97 m · 0 hull · 93,4 % (fasit, urørt) |
| InFloor 10T 600W 60m | 83 cm | CC 8,80 · 60,00 m · 0 hull · 91,8 % |

Panelet oppgir avstanden: *«Start: 83 cm fra oppe til venstre — nærmere er ikke mulig med dette
utlegget.»*

### Beslutningen som gjenstår

For 700W og 10T er valget: **hjørnet, eller fasiten.** 33 cm fra hjørnet koster CC 12,6 i stedet
for 13,2 og 2 prosentpoeng dekning. Koden ligger der (`_geoParityVariants` + `_parityOn`); det
som mangler er å slippe runden ned CC-stigen igjen. **Venter på Kenneth.**

22/22 batterier grønne, 1019 påstander, suiten 19,5 s.

---

## §21 · Trenger vi de gamle motorene? (målt 15.10.2026)

Kenneths spørsmål. Målt over alle 16 fixturer × begge retninger = 32 utlegg:

| motor | vinner | av disse gyldige |
|---|---|---|
| **geo** | 24 | **24** |
| **skew** | 2 | 2 — begge er `skraa` (rotert rom 18°), som geo ikke håndterer |
| **v6** | 6 | **0 — alle seks ugyldige** |

De seks v6-seirene er `boyUmulig` (CC under 2 × bøyeradius — umulig per konstruksjon),
`kabelForLang` (96 m i et 200×150-rom) og `flereHindringer` (tre hindringer, kjent hull).
v6 vinner altså bare der INGEN motor har et gyldig svar, og tegner da noe som ser plausibelt ut
i stedet for å si «ingen løsning». Det er nøyaktig feilmodusen bak Rom 5-hendelsen i §14.

**Anbefaling (ikke bygget, venter på beslutning):** behold `skew` — den dekker roterte rom geo
ikke tar. Ta `v6`/boustrophedon/serpentine ut av konkurransen, eller la dem aldri vinne over
`_geoNoSolution`, som allerede gir grunn, konflikter og forslag. De tre fixturene over ville da
gi et ærlig «ingen løsning» i stedet for et ugyldig utlegg.

## §22 · «Nedre venstre» loddrett er strukturelt umulig i Rom 5

Enumerert, ikke sluttet: loddrett gir nøyaktig fire endepar, og to er gyldige —

```
(695,−917) ↔ (972,−1028)        (708,−848) ↔ (972,−1028)
```

Ingen ende ligger ved (677, −1040). Nærmeste er 124 cm unna. Grunnen er at det nedre venstre
feltets frie ende er **brukt opp av transitten**: den må gå under utstikkeren for å nå det øvre
venstre feltet, som er en blindvei. Kabelens frie ender havner derfor i det øvre feltet eller på
høyre side.

Startbanen (x = 695) har to løp — det øvre (−917 → −848) og det nedre (−1028 → −966). Den nedre
enden ligger 22 cm fra hjørnet, men der svinger kabelen videre; den er ikke fri.

**Vannrett klarer det derimot:** `bl` gir start (695, −1035) — **18 cm fra hjørnet**, 41,00 m,
0 hull. Vil man ha starten nede til venstre i dette rommet, er vannrett veien.
