# RAPPORT · serie 098 · 075 · 099 · 065

Kjørt 17.10.2026 på `main` fra `cd72f0e`. **Fire commits, ikke pushet.** Alt er testet på
dupliserte/lesende prosjekter (autosave stubbet), ingenting er skrevet til skyen.

| # | commit | hva |
|---|---|---|
| 098 | `a3e9c32` | Trapp, sidevisning: grønn start ytterst til venstre på trinn 1, rød slutt ytterst til høyre på øverste trinn. «Sidevisning» står på samme side som tegningen |
| 075 | `1422d23` | Høyreklikkmenyene måler sin egen høyde og holdes innenfor skjermen. Romtyper i to kolonner |
| 099 | `9c9e102` | Kabelmotor: Rom 5 tåler 1 cm veggflytting (700W: 20 → 1 brudd av 40). Porten grønn, ingen rad dårligere |
| 065 | `da5b006` | Varmeplan som installerbar app på Windows (PWA): ikon, manifest, service worker, «Installer Varmeplan»-knapp |

Dev-serveren kjører på **http://localhost:4000** (startet av meg). Åpne `http://localhost:4000/?dev`
for automatisk innlogging.

---

## 098 · Trapp, sidevisning

**Hva som ble gjort.** Sidevisningen tegnet både løpsmerkene og start-/sluttprikken på
`xStart + pos_cm`. Men `pos_cm = 0` er opptrinnssiden (Regel 14), og sidevisningen har opptrinnet i
HØYRE ende av hvert trinn. Hele løpsrekka var altså speilet innenfor trinnet — det syntes bare på
prikkene. Ny hjelper `_stairSideX` speiler riktig, og brukes av PDF og skjerm. Skjermens sidevisning
hadde ingen prikker før; nå har den grønn/rød som PDF-en.

**STEG 0-funn.**
1. `pos_cm = 0` ligger ved opptrinnet (den delte kanten mot neste trinn) når byggeretningen er
   «nedenfra» (standard). Målt: start 2 cm fra forkanten i planen, men 28 av 30 cm fra venstre i
   sidevisningen. **Det avhenger av byggeretning:** med «ovenfra» ligger neste trinn ved økende y, og
   da legger kabelmotoren selv starten 2 cm fra opptrinnet i planen — en motorsak utenfor 098, står i
   SPØRSMÅL.
2. Skjermens `_drawStairSide` hadde samme speiling (og ingen prikker).
3. Repos har symmetriske marginer — bildet er likt, hvert løp får riktig side.

**PDF-side før → etter.** Før: side 3 hadde bare «Start kabel · Slutt kabel» og «Sidevisning»,
tegningen kom på side 4 (7 sider). Etter: side 2 = plan + tegnforklaring, side 3 = «Sidevisning» +
tegning (6 sider). Årsak: plasskontrollen sjekket `min(bildehøyde, 60) + 10` i stedet for hele
blokken, og tegnforklaringen hadde ikke reservert plass under planbildet.

**Test.** Ny `_stairSideRegressionTest()` — 25 sjekker grønne (med/uten repos, begge byggeretninger,
snudd kabelstart, to kabler). `_stairRegressionTest()` 24/24.

**Kenneth sjekker:** åpne **Test Kenneth** (eller en kopi) → Trapp 1 → på skjermen skal grønn prikk
ligge nederst til venstre på trinn 1 og rød øverst til høyre på trinn 10 i sidevisningen, likt
planen. Skriv ut PDF: «Sidevisning» og tegningen på samme side, prikkene som på skjermen.
Skjermbilder: `docs/serie-098/skjermbilder/098-*`.

---

## 075 · Høyreklikkmenyen

**Hva som ble gjort.** `showCtxAt` gjettet 230 px høyde for alle 15 menyene; rom-menyen var 740+ px.
Ny `_placePopupAt` viser menyen usynlig, måler den, og legger den under pekeren hvis det er plass,
ellers OVER pekeren, ellers klemt inn med 8 px marg — samme mot høyre/venstre kant. Brukes av alle
15 høyreklikkmenyene og produkt-dropdownen. CSS: menyen kan rulle hvis den er høyere enn vinduet.
Romtypene står i to kolonner med gjeldende romtype uthevet (12 typer i Oslo Elektriske-kopien → 6
rader i stedet for 12).

**Målt (1440 × 900).** Rom-menyen 543 px (før ≈ 740). Høyreklikk 40 px over bunnen → menyen åpner
OVER pekeren, «Slett rom» klikkbar. Øverst → under pekeren. Helt til høyre → speilet til venstre.
Vindu 500 px høyt → menyen rullbar, alt innenfor. Vegg-, hjørne- og produktmenyene åpner riktig.

**Kenneth sjekker:** høyreklikk på et rom helt nederst på lerretet på laptopen → hele menyen synlig,
«Slett rom» nederst kan klikkes. Romtypene i to kolonner, din romtype uthevet, klikk setter den som
før. Skjermbilder: `docs/serie-098/skjermbilder/075-*`.

---

## 099 · Kabelmotor — robust mot 1 cm veggflytting

**Med teskje.** Vi målte først, og hypotesen i prompten stemte ikke:

* **Hvilken celle forsvinner (STEG 0.1):** ingen ekte celle. Trinnene ved cellegrensene i Rom 5 er
  75–111 cm — langt over én CC (13 cm), hverken før eller etter forstyrrelsen. «Celle 5» var en
  12,6 cm lang én-banes «celle» som 093-varianten (forskjøvet ytterbane) lager i nedre venstre felt
  fordi V10 er litt skrå. Den finnes ikke i tegningen.
* **Det som faktisk brakk:** lengdesøket. På Kenneths rom gir CC 12,6 en kabel som er 3,9 cm for
  KORT og CC 13,2 en som er 30 cm for LANG. Begge prøves, og 13,2 vinner (ingen hull, 93,4 %).
  Flytter du vegg 2 én cm, blir CC 12,6 nøyaktig 0,1 cm for lang — da regnes den som «nærmeste for
  lange», CC 13,2 prøves aldri, og motoren ender på CC 11,6 og 84 %. **Fire centimeter kabel avgjorde
  ni prosentpoeng dekning.**
* **Én mekanisme eller flere (0.2):** for 700W og 600W er det denne, pluss fire tilfeller der
  ytterbanen ikke når øvre felt (093-forskyvningen rakk 0,5 cm, gapet var 1,1–2,1 cm). **For 10T var
  §38 feilmålt:** 28 av 40 «R-START tapt» kom av at REFERANSEN selv starter 118 cm fra hjørnet.
  badHakk vegg 5 −2 («ingen løsning») er ikke undersøkt.
* **Er 5-celle-utlegget gyldig på forstyrret geometri (0.3):** ja — vegg 2 +1 gir 41,34 m (+0,8 %),
  94,2 %, gyldig; vegg 0 +2 og vegg 8 +1 likeså.

**Hva som ble bygget.** (1) Etter lengdesøket prøves hvert CC-trinn som treffer lengden innenfor
±1 %, pluss nabotrinnene — som VARIANTER; hjørnetreff først, så poeng. Kjører bare når søket ikke
alt fant et hullfritt treff, så rader som virket, er urørt. (2) 093-forskyvningen rekker 0,2 × CC.
(3) Forstyrrelsestesten retter to målefeil (R-START mot referansen; slivere teller ikke som celler).
Cellesnitt-varianten fra prompten er IKKE bygget, fordi målingen viste at den ikke ville truffet.

**Forstyrrelsestesten før → etter** (loddrett, øverst til høyre, hver vegg ± 1 og ± 2 cm):

| rom / produkt | før | etter |
|---|---|---|
| rom5 / 700W | 20 av 40 | **1** (vegg 4 −2 cm: 93,4 → 84,4) |
| rom5 / 600W | 20 av 40 | 23 — ⚠ referansen står igjen alene på 78,4 %; de forstyrrede finner 88–92,6 % (se SPØRSMÅL 1) |
| rom5 / 10T | 40 av 40 (28 feilmålt) | 6 |
| badHakk | 1 av 44 | 1 |
| sum | 81 av 164 | 31 |

**Porten `_cableGeoSuite()`:** GRØNN, 142 rader, **19,8 s** (tre biter: 7,8 + 6,0 + 6,1 s).
To rader bedre (enHindring loddrett tr/tl: 89 → 95,3 %), **ingen dårligere**. Baselinjen er skrevet
på nytt. Fem andre kabelbatterier grønne. Tid per utlegg i Rom 5: 181 → 132 ms (referansen),
861 → 330–550 ms (forstyrret).

**To ting ble målt og rullet tilbake:** «099 alltid på» (4 røde rader) og hjørnerunden på N-stigen
(7 røde rader). Begge står forklart i STATUS §40.

**Kenneth sjekker på localhost:** åpne en KOPI av Ekebergveien 28, Rom 5. Legg ut InFloor 17T 700W
med start øverst til høyre, loddrett. Dra så V6 eller V10 1 cm (eller V3/V1 1–2 cm), slett og legg
ut på nytt. Utlegget skal se likt ut: CC 13,2, ingen hull, ~93–94 %. Unntaket som gjenstår: V5
(toppveggen) 2 cm INN gir fortsatt CC 11,6.

---

## 065 · Varmeplan som app på Windows

**Hva som ble gjort.** Varmeplan-ikon (V + kabelslynge, Varmeplans farger — ikke Cenika),
`manifest.webmanifest`, en minimal service worker som ALDRI cacher appen (bare nettverk først på
navigasjon, og en «Varmeplan trenger internett»-side når nettet er borte), «⬇ Installer Varmeplan» i
menyen øverst til høyre og en engangslinje på dashbordet, instruks i `docs/pwa/INSTALLER.md`.

**STEG 0.** Ingen `package.json` i repoet (ikonene er laget med den lokale Chromium-en, ingen
pakke lagt til). Vercel svarer 404 på `/sw.js` i dag — trygt. Kundeflatene `?present=`, `&forslag=`,
`?kunde=`, `?invite=` får verken knapp eller service worker (målt).

**`window-controls-overlay`:** droppet — bare `standalone`. Topplinja har knapper oppe til høyre som
ville havnet under Windows-knappene, og det kan ikke måles uten en Windows-PC.

**16/32 px-ikonet:** `favicon.svg` har bare V-en (større). V-en er lesbar i 16 px; slyngen blir grøt
under 32 og er derfor bare med fra 48 px og opp. Se **`docs/pwa/ikon-forhandsvisning.html`** (åpne
fila i nettleseren) — alle størrelser på lys og mørk bakgrunn og en simulert oppgavelinje.

**Slik installerer Kenneth på Windows-PC-en:**
1. Åpne **varmeplan.no** i Microsoft Edge (eller Chrome) og logg inn — *etter* at dette er pushet.
2. Klikk **«Installer Varmeplan»** i menyen under initialene øverst til høyre (eller ⊕-ikonet
   «Installer app» i adresselinja).
3. Varmeplan ligger nå i Start-menyen; høyreklikk → «Fest til oppgavelinjen».

**Sjekk før push (på PC-en, etter deploy):** DevTools → Application → Manifest uten feil og
«Installable»; installer → eget vindu med mørk tittellinje (lys når appen står i lyst tema);
deploy en synlig endring → åpne appen → endringen er der uten omstart; slå av nettet → «Varmeplan
trenger internett»; åpne appen to ganger fra Start → samme vindu. Lokalt er alt dette målt i
headless Chromium unntatt selve installasjonen og Lighthouse.

---

## Står igjen i `SPØRSMÅL.md`

* **098:** byggeretning «ovenfra» legger starten ved opptrinnet i PLANEN (motoren, Regel 14) — skal
  motoren rettes for `top`-trapper? (Egen prompt; endrer utlegget for eksisterende `top`-trapper.)
* **099 / 1:** rom5 600W — referansen står på 78,4 % mens forstyrrede geometrier finner 92,6 %.
  «Alltid på» henter det, men koster fire andre rader. Gate som nå, eller egen «aldri bytt bort
  dekning»-regel?
* **099 / 2:** hjørnerunden går fem grove trinn og mister nabotrinn (enHindring: 90,7 % finnes,
  den fant 77,4 %). Egen prompt?
* **099 / 3:** 10T 400W i Rom 5 treffer aldri hjørnet (start 118 cm, også på referansen).
* **099 / merknad:** to måledefinisjoner er endret (R-START mot referansen; celler ≥ 2 baner).
* **065 / 1:** skal `admin.html` også kunne installeres? (Har bare fått ikonet.)
* **065 / 2:** en installatør som alt har logget inn har service workeren på hele origin-et, også på
  `?present=`-lenker i samme nettleser. Ufarlig (nettverk først), men ikke «tom».
