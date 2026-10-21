# Rapport · serie 119 · 120 · 121 — oppfølging (presentasjon, trappesoner, kabelmotor-testene)

Kjørt 21.10.2026 på `main`, fra `8eee272`. **Ikke pushet.** Én commit per prompt.
Ingen av promptene var kjørt fra før (sjekket med `git log --oneline -15`).

| # | commit | hva |
|---|---|---|
| 119 | `b547ea7` | Produktmål skjult for kunden, klikk-styring, forhåndsvalg over etasjer, vegg-tabell per vegg i forslagssvar, UTLEGG-merket ryddes selv |
| 120 | `bca0959` | Alle soner starter på samme side som sone 1, «Antall kabler» i sonen, auto 2 kabler når 1 ikke holder, låst/auto også på trappenivå |
| 121 | `6fba3a4` | Fail-open uten polygonbibliotek gjenopprettet, 7 utdaterte påstander oppdatert, rask variant av batteriet |

---

## 119 — presentasjon, oppfølging

Svarene er skrevet inn under hvert spørsmål i `docs/serie-116/SPØRSMÅL.md` («Svar (Kenneth 21.10): …», 17 stk).

### STEG 0 (målt på forslagslenka til «Vestre Hals 43», bare lest — lagring stubbet)

| | funn |
|---|---|
| 0.1 produktmål | Tegnes i `drawAllDimAnnotations` på rommets egne brytere `stripDimSnap`/`cableDimSnap`/`matDimSnap` (lagret i prosjektet). Rommet hadde `stripDimSnap: true` → hele foliekjeden («3.2 cm», «871.8 cm», «2.5 cm» + sidekjeden) sto i kundens lenke. PDF-en slår bryterne på selv i `_pdfMode` og var alt utenfor. |
| 0.2 hover | `_presentHover` (mousemove) byttet rom ved hover i ren presentasjon; bare forslagslenka var klikk-styrt (`_forslagAktiv()`). Klikk-veien fantes i `_canvasMouseUp` (tap uten drag). |
| 0.3 forhåndsvalg | `_presentForhaandsvalgtRom` så bare på `_roomOnActiveFloor`. Etasjebyttet fra 117/4 lå som fire linjer inne i `_presentPanelVelgRom`. `_presentEnter` kalte `fitAll()` FØR forhåndsvalget. |
| 0.4 vegg-tabellen | `_kundeRevRender(groups)` var bundet til `_kundeLinkCache` (navn, dato, kommentar, `answer.points`, `axisBalance`) og til mållenkas knapper (`_kundeApplyRoom/All`, `_kundeBrukKundePunkter`, `_kundeRejectAnswer`, `_kundeNyeRomHtml`). Avkryssingen (`_kundeRevState.picked`) og `_kundeApplyWalls(groups, onlyPicked)` fantes allerede. Det som måtte bli argument: svaret (`k`) og knappenes mål. |
| 0.5 felles kanal | Alle plasseringsveier ender i `renderSidebar()` (det 109 brukte). `_clearRoomProductCollections` fjernet merket, men manuell plassering og frihånds-matte rydder ikke først. |

### Gjort

1. **Produktmål skjult** — `_presentProduktMaalSkjult()`: presentasjon/forslagslenke uten `_pdfMode` og uten annen kundemodus. `drawAllDimAnnotations` tegner veggmålene og hopper så over de tre kjedene. Rommets brytere røres ikke; editor, PDF og mållenka er uendret.
2. **Klikk-styring** — `_presentHover` setter bare markøren, i alle kundevisninger.
3. **Forhåndsvalg over etasjer** — `_presentRomIEtasjerekkefolge()` (etasjerekkefølge, så romrekkefølge) og `_presentByttTilRommetsEtasje(roomId)` (delt med romlista). `_presentEnter`: forhåndsvalg → etasjebytte → `fitAll`.
4. **Vegg-tabell per vegg** — `_kundeRevRender(groups, ctx)`; `ctx = { forslag, k }` i `_kundeRevState.ctx`, så avkryssing og re-tegning finner samme svar. «Arbeid inn målene» åpner vinduet. Knappene går til `_forslagRevBrukAlle/Rom/Punkter` → den eksisterende innarbeidingen → `_forslagMaalEtterInnarbeiding` (merke + protokollrad). Uten ctx er mållenkas vindu bit-identisk.
5. **UTLEGG-merket** — settes med `utleggMerkeSig = _roomProduktSignatur(roomId)` (id-ene i alle `ROOM_PRODUCT_KEYS`); `_utleggMerkeRydd()` i `renderSidebar` fjerner det når signaturen avviker. Klikk fjerner fortsatt.

### Hva Kenneth skal klikke

1. Åpne forslagslenka til Vestre Hals 43 i et privat vindu: den oransje foliekjeden er borte, veggmålene står. I Varmeplan (editor) står kjeden som før.
2. Åpne en ren presentasjonslenke med flere rom (f.eks. «Varmematter 60W»): før musa over et annet rom — valget står. Klikk — rommet byttes.
3. I et prosjekt med to etasjer der første etasje er tom: ▶ Presentasjon åpner på andre etasje med det første rommet som har produkter.
4. Et forslagssvar med rettede mål: «Arbeid inn målene» åpner vegg-tabellen (Vegg · Estimert · Kunde · Avvik · Blir · ☑). Kryss bort en vegg, «Arbeid inn valgte mål». Rommet får UTLEGG-merket; «Vis målene» åpner tabellen igjen.
5. Legg ut på nytt i rommet (hvilken som helst vei, også manuell folie): merket forsvinner av seg selv.

### Målt etter

- Forslagslenka: kjeden borte ([skjermbilde](skjermbilder/119-etter-forslag-desktop.png), [før](skjermbilder/119-foer-desktop.png)).
- Ren presentasjon «Varmematter 60W» (5 rom): hover over rom 4 → valgt rom fortsatt 2, markør `pointer` ([hover](skjermbilder/119-etter-ren-presentasjon-hover.png)); klikk → 4 ([klikk](skjermbilder/119-etter-ren-presentasjon-klikk.png)).
- Kenneths side (Vestre Hals lest med stubbet lagring og dummy prosjekt-id): [målblokk](skjermbilder/119-kenneth-maalblokk.png) → [vegg-tabell](skjermbilder/119-kenneth-veggtabell.png) → [vegg 3 krysset bort](skjermbilder/119-kenneth-veggtabell-to-valgt.png) → «Arbeid inn valgte mål»: vegg 1/2 = 454/204 (kundens tall). Vegg 3 fulgte geometrien (215 → 203, slik «Blir»-kolonnen viste) — ikke kundens 205. [UTLEGG-merket](skjermbilder/119-kenneth-innarbeidet-utlegg.png); én ny folie + `renderSidebar` → merket borte.
- Et funn utenfor prompten: test L i `_kundeforslagRegressionTest` var rød på HEAD når batteriet kjøres i editoren (seksjon C etterlot en fast `#_fors-bunn`; grønn i en levende lenke). Rettet i testen (L kaller `_forslagRenderBunn()` selv).

### Batterier

| batteri | resultat |
|---|---|
| `_kundeforslagRegressionTest()` | 189/189 (33 nye: M/119 + seksjon N) |
| `_kundelenkeRegressionTest()` | 328/328 |

---

## 120 — trapp, svar på serie-104

Svarene er skrevet inn under hvert spørsmål i `docs/serie-104/SPØRSMÅL.md` (15 stk). Spec-linjene står i
`spec-trapp-kabelutlegg.md` under Regel 21 og Regel 22.

### STEG 0 (målt med syntetisk katalog, 104-fixturen og to trinn-soner)

**0.1 Startside — premisset holdt ikke helt.** Alle soner startet ALT fra venstre (104-trappa 4 trinn / repos /
6 trinn: V/V/V, også med «Kabelstart: Topp»). Sonens første flate har ingen innkommende forbindelse, og
tegningen begynner da fra venstre. Det som fulgte paritetskjeden var kjeden INNE i neste sone: med oddetall
strenger (CC 13 → 3 per trinn, soner 3 + 5 trinn) forlot flate 3 sonen til høyre, og flate 4 ble møtt fra
venstre — et sidebrudd.

| trapp | sone | kjede (flate: inn>ut) før | etter |
|---|---|---|---|
| 3 + 5 trinn, CC 13 | 1 | `0:V>H 1:H>V 2:V>H` | uendret |
| | 2 | `3:V>H 4:V>H 5:H>V 6:V>H 7:H>V` — **1 brudd** | `3:V>H 4:H>V 5:V>H 6:H>V 7:V>H` — 0 |
| 104-trappa (N=4, repos 14) | 1–3 | alle V, 0 brudd | uendret, 10 036,8 cm |

**Kostnaden ved samme side: 0 cm.** Verken en ekstra overgang eller et halvt løp: forbindelsen over sonegrensen
tilhører ingen kabel, og sonens strenger er like lange uansett side (4850 cm før og etter).

**0.2 Låst på trappenivå:** `edgeMarginMin_cm` (084) er gulvet for Forslag, `edgeMargin_cm` det løste utlegget.
«Låst» for Forslag = behovet regnes ved den låste avstanden, settene rangeres på passform, ingen margin-løsning.
**0.3 Auto i sonen:** `_stairSolveExactCableSet(subStair, { maxCables: 1 })` svarer `{ ok:false, reason: 'Ingen
kombinasjon … dekker behovet' }` når ingen enkeltkabel holder. Grensen er `maxSaneMargin` (gulv + 15 cm / halve
smaleste flate), ikke 75 % — se SPØRSMÅL 120/3.

### Gjort

1. **Samme startside** — paritetskjeden starter på nytt ved hver sonegrense i `generateStairCable`.
   Sidefunn rettet: med «Kabelstart: Topp» slapp sonefilteret grenseforbindelsen inn i den nedre sonen
   (antok fromSurf < toSurf) — sonen fikk et opptrinn som ikke var dens, og feil inngangsside.
2. **«Antall kabler» i sonen** — `_setStairZoneCableCount`, tallfelt over kabellista.
3. **Auto 2 kabler** — `_stairSolveZones` prøver `maxCables: 2` når én kabel feiler; panelet sier
   «Auto: 2 kabler (én rakk ikke)».
4. **Låst/auto på trappenivå** — `edgeMarginLocked_cm` (null = som før), 🔒/🔓 ved «Avstand sider», tomt felt
   = lås av. Forslag ved lås: `_stairSolveLockedCableSet` (bare settet varierer, A = best passform, B = annet
   sett). Manuelt sett ved lås: `_stairFitLockedMargin` (for kort = stiplet rødt, for lang = «til overs»).

### Hva Kenneth skal klikke

1. Trapp med tre soner og «Maks CC trinn» 13 (3 løp per trinn): alle soner starter nederst til venstre, og
   U-svingene i sone 2 henger sammen (før: ett diagonalt hopp).
2. Velg en sone: «Antall kabler» over kabellista. Skriv 2 → to rader. Tøm → auto.
3. Lag en sone ingen enkeltkabel rekker (f.eks. 20 trinn × 250 cm): sonen får to kabler, og panelet sier
   «Auto: 2 kabler (én rakk ikke)».
4. Trapp uten soner: trykk 🔓 ved «Avstand sider» → 🔒 låst. Skriv 6. Forslag: alle kort «Avstand sider låst
   6,0 cm», bare kabelsettet varierer. Velg et manuelt sett som er for kort: «X m for kort — N løp dekkes
   ikke», stiplet rødt. Tøm feltet eller trykk 🔒 → som før.

### Skjermbilder

- [Før: sidebrudd i sone 2](skjermbilder/120-foer-sidebrudd-plan.png) · [Etter](skjermbilder/120-etter-samme-side-plan.png)
- [Sonepanel med «Antall kabler»](skjermbilder/120-sonepanel-antall-kabler.png)
- [Trapp låst 6 cm, 49,7 m for kort](skjermbilder/120-trapp-laast-6cm-for-kort.png) · [Forslag med lås](skjermbilder/120-forslag-laast.png)

### Batterier

| batteri | resultat |
|---|---|
| `_stairRegressionTest` | 47/47 |
| `_stairSideRegressionTest` | 25/25 |
| `_stairManualSetRegressionTest` | 42/42 |
| `_stairZoneRegressionTest102` | **106/106** (29 nye i seksjon J; J1 vaksinert) |
| `_stairBuilderMoveRegressionTest110` | 59/59 |
| `_pdfExportSmokeTest` | 20/20 |

---

## 121 — kabelmotor-testene

Svarene er skrevet inn under «103» i `docs/trapp/prompter/SPØRSMÅL.md` (6 stk). Full måling i
`docs/kabel/STATUS.md` §45.

### STEG 0

| | funn |
|---|---|
| 0.1 | De åtte på `bca0959`: nøyaktig de samme åtte, 127 påstander. **30 s**, ikke 127 s som §44 målte — ikke forklart. |
| 0.2 | **§44s mekanisme var feil.** `_cableFilterByCorner` kaster aldri alle kandidatene (returnerer hele lista når ingen treffer hjørnet). `null` kom fra `if (!chosen) return null` i `_autoFillCableImpl`, fordi kandidatlista var TOM: uten clipper gir geo «ingen løsning», og 083 (samme commit) tok V6 ut av konkurransen. Før 083 lå V6 der (ugyldig, men til stede) — det var 077/060s «tilnærmede kandidat». «Tilnærmet» = `cable._geomApprox` → panellinja «Lagt uten polygonbiblioteket — kantene er tilnærmet». |
| 0.3 | `baseline.json`: `badHakk41\|v\|tr` = cc 9,06 · 63,3 % · 0 hull · gyldig; `tl`/`br` = cc 13,81 · 94,9 %. Bekreftet. |

### De åtte (gammel forventning → ny, og hvorfor)

| # | påstand | gammel | ny | hvorfor |
|---|---|---|---|---|
| 1 | 076 rom5 areal | 5,698 m² | 5,711 m² | 089 `a365c70` hentet fixturet på nytt |
| 2 | 081 OPP/NED | tl > bl + 50 | tl < bl − 50 | 088 `5c929ef`: world-y øker nedover, topp = minst y |
| 3 | 081 tl nær taket | y > −860 | y < −1020 | samme |
| 4 | 081 bl nær gulvet | y < −1020 | y > −860 | samme |
| 5 | 081 panel-linja | `Start: N cm fra` | `start N cm fra hjørnet` | 088b `b11dc9e` ny ordlyd |
| 6 | 082 600W hjørnet | ≤ 40 cm | > 40 cm, fortsatt loddrett; panelet melder avstand + «nærmeste er N cm unna» | 088b: retningen er hard (ditt svar 103/4) |
| 7 | 077 fail-open | kabelobjekt | **uendret forventning — motoren rettet** | se under |
| 8 | 074b badHakk41 ≥ 85 % | hjørne `tr` | hjørne `tl` (94,9 %) | 088 flyttet hjørnene; `tr` = 63,3 % er baselinjens aksepterte rad |

### Fail-open før og etter

| | uten clipper | med clipper |
|---|---|---|
| før | `null` — rommet får ingen kabel | geo, gyldig |
| etter | dagens kaskade som tilnærmet kandidat, målt (`_geomOk` ærlig), merket `_geomApprox`, panelet sier «tilnærmet» | **bit-identisk** (ny påstand låser senterlinja med og uten grenen) |

Grenen ligger inne i `if (!chosen)` og er gatet på `!_cblClipperReady()`. R-START/R-VEGG/R-ENDE er urørt.
Kaskaden kjøres innenfor 074-dybdetelleren, så ingen dialog åpnes.

### Rask variant

`_cableGeometryQuickTest()` = `_cableGeometryRegressionTest({ rask: true })`: hovedløkka på én fixture per
motorfamilie + bare seksjonene som bærer de åtte (076, 080 — der 081 ligger —, 082, 077, 074b). Målt: det
var SEKSJONENE som bar tiden (21 s), ikke hovedløkka (~8 s for alle 20 fixturer). Dokumentert i STATUS §45 og
i batteri-indeksen ved `_cableGeoSuite()`.

### Hva Kenneth skal klikke

1. Konsollen: `_cableGeometryQuickTest()` → grønn på under 20 s. `_cableGeometryRegressionTest()` → 132 grønne.
2. Fail-open: i konsollen `window._cblClipperReady = () => false`, legg ut kabel i Rom 5 → kabel legges, panelet
   sier «Lagt uten polygonbiblioteket — kantene er tilnærmet». Last siden på nytt → som før.

### Tider og batterier

| hva | resultat |
|---|---|
| `_cableGeometryRegressionTest()` | **132/132** (127 + 5 nye), 30,0 s |
| `_cableGeometryQuickTest()` | 67/67, **18,8 s** |
| `_cableGeoSuite()` | 142 rader · **0 endret · 0 nye · 0 borte · 0 feil**, 19,7 s |
| `_cableForstyrrelsesTest()` | **31 brudd** (sist målt 31), 67,9 s |

---

## Det som står igjen

`docs/serie-119/SPØRSMÅL.md`: 6 punkter for 119 (mållenka på panelet venter, innlogget presentasjon skjuler
også produktmål, «følger»-vegger, status etter delvis innarbeiding, merker uten signatur, test L),
7 for 120 (premisset holdt ikke helt, et eldre endepunkt-avvik ikke rettet, én-kabel-grensen er +15 cm ikke
75 %, hengelåsens form, lås + Antall kabler, arv til soner, sidefunn Topp) og 4 for 121 (mekanismen bak
`null`, hva den tilnærmede kandidaten er, 30 s mot 127 s, utvalget i den raske varianten).
**Ikke pushet.**
