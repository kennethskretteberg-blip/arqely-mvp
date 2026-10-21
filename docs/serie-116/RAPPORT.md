# Rapport · serie 116 · 117 · 118 — kundepresentasjonen

Kjørt 21.10.2026 på `main`, fra `ecb71c4` (115). **Ikke pushet.** Én commit per prompt.

| # | commit | hva |
|---|---|---|
| 116 | `70feed0` | Forhåndsvalgt rom, mål på alle vegger, blå «Send forslag» |
| 117 | `a2b3691` | Ett venstre panel; skuff på mobil |
| 118 | (se under) | Endre mål / Lås mål i forslagslenka, mål i svaret, Arbeid inn målene |

Ingen av promptene var kjørt fra før (sjekket med `git log --oneline -15`).

---

## 116 — forhåndsvalgt rom, mål på alle vegger, blå Send

### STEG 0 (målt på forslagslenka til «Vestre Hals 43», bare lest)

| | før | etter |
|---|---|---|
| 0.1 valgt rom ved åpning | `presentRoomId = null`, kortet `display:none` | rom 1 (eneste med produkter), kortet åpent med hjelpelinje |
| 0.2 veggmål | bare rom med `dimSnap` (Kenneths bryter; `false` her) → ingen | alle tegnede rom, uten hindringsmål; ved liten zoom bare det valgte |
| 0.3 «Send forslag» | aktiv: `--accent` = turkis #0891b2, mørk tekst | aktiv: `--info` = blå rgb(37,99,235), hvit tekst; dempet som før |

Et funn utenfor prompten: ren presentasjon på desktop nullet valget straks musa forlot et rom
(`_presentHover`). Et forhåndsvalg hadde forsvunnet ved første musebevegelse. Hover utenfor rom lar
nå valget stå; hover over et annet rom bytter som før.

### Skjermbilder

- [Før, desktop](skjermbilder/116-foer-desktop.png) · [Før, 390 px](skjermbilder/116-foer-mobil.png)
- [Etter, desktop ved åpning](skjermbilder/116-etter-desktop.png) ·
  [Etter, desktop med ett valg (blå Send)](skjermbilder/116-etter-desktop-valgt.png)
- [Etter, ren presentasjon desktop](skjermbilder/116-etter-ren-presentasjon-desktop.png)
- [Etter, 390 px ved åpning](skjermbilder/116-etter-mobil.png) ·
  [390 px med valg, kortet lukket (mål + blå Send)](skjermbilder/116-etter-mobil-kort-lukket.png)

### Batterier

- `_kundeforslagRegressionTest()` — 99/99 grønne (14 nye i seksjon K)
- `_kundelenkeRegressionTest()` — 330/330 grønne

---

## 117 — ett venstre panel

### STEG 0 — elementene før (forslagslenka «Vestre Hals 43»)

| element | desktop | 390 px |
|---|---|---|
| Topplinje: navn, «Prosjektert av … for … · dato» | 58 px, øverst over lerretet | 92 px |
| Detaljkort: produkt, effekt, flateeffekt, spenning, motstand, toppgulv, «Hva synes du?» | 320 px, høyre | bunnark, 522 av 844 px |
| Bunnlinje: «0 rom OK · 0 forslag», Send | 59 px nederst | 67 px |

Kan 032-panelet gjenbrukes? **Monteringen ja** — `_kundeMonterBar` setter panelet inn som
flex-søsken før `#canvas-wrap` (PC) eller som fast bunnark (mobil), og lerretet følger av seg selv.
**Innholdet nei** — vegg-tabellen er mål-spesifikk. Det er delt mekanisme, ikke delt markup.

### Etter

Ett panel på 320 px (`#_present-panel`): Prosjekt → Rom → Valgt rom (+ Hva synes du) → [plass for
Endre mål] → fot med «1 av 1 rom vurdert» og blå Send. Lerretet er 1120 px bredt (var 1440 med
tre ting oppå). Topplinje, kort og bunnlinje finnes ikke i panelmodus. Mobil: skuff på 69 px lukket
(valgt rom + Send + ▲), 658 px åpen. Trykk og sveip på hodet er målt med berøring i Playwright.

### Skjermbilder

- Før: [desktop](skjermbilder/116-etter-desktop.png) · [390 px](skjermbilder/116-etter-mobil.png) (tilstanden etter 116)
- Etter, desktop: [ved åpning](skjermbilder/117-etter-desktop.png) ·
  [med ett valg](skjermbilder/117-etter-desktop-valgt.png) ·
  [ren presentasjon](skjermbilder/117-etter-ren-presentasjon-desktop.png)
- Etter, 390 px: [skuff lukket](skjermbilder/117-etter-mobil-lukket.png) ·
  [skuff åpen](skjermbilder/117-etter-mobil-apen.png) ·
  [lukket med valg (blå Send)](skjermbilder/117-etter-mobil-lukket-valgt.png) ·
  [åpen med valg](skjermbilder/117-etter-mobil-apen-valgt.png)

### Batterier

- `_kundeforslagRegressionTest()` — 124/124 grønne (25 nye i seksjon L: panel som flex-søsken,
  kortet og bunnlinja borte, romliste med areal/produkt, listeklikk velger + zoomer, foten tegnes
  alene ved tastetrykk, skuff lukket/åpen, ren presentasjon uten Send, mållenka urørt)
- `_kundelenkeRegressionTest()` — 330/330 grønne

---

## 118 — Endre mål / Lås mål

### STEG 0

**0.1 Kan mållenkas maskineri kjøres inne i forslagslenka?** Ja. Det var gatet 13 steder på
`S.ui.kundeMode === 'maal'` (lerret-håndtererne, tastatur, fem tegne-/treff-funksjoner, berøring) og
på `_kundeState`. Antakelsene om S er små: originalen må være lagret (`_kundeLagreOriginal`), og rom
må ha `points`/`walls`. I det fulle prosjektet bygges `walls` om med `compWalls` (visuelt, ingenting
lagres), og produktene blir liggende — derfor dempes de. Det som måtte gjøres generelt: én delt
gate (`_kundeMaalAktiv`), og `_kundeRenderBar` (19 kallsteder) må tegne panelet i stedet for sitt
eget sidepanel. Ingen kopi av maskineriet.

**0.2 Kenneths side.** Mål-svar: `_kundeAnswerByRoom` → `_kundeApplyWalls` → `_kundeFinishApply`
(vegg-modus) / `_kundeBrukKundePunkter` (punkt-modus). Alle leste `_kundeLinkCache.answer`, og
`_kundeFinishApply` satte mållenka til applied. De tar nå svaret som argument og en
`ikkeLukkLenke`-opsjon, så forslagsgjennomgangen kaller dem uten kopi. Forslagssvar:
`_forslagRevRender` + `applied_result` per rom; målene fikk sin egen rad der.

**0.3 `kundelenke_answer`** tar fri jsonb ≤ 200 kB (migrasjonen :133). Målt svar med ett rom: 368
tegn; 15 rom ≈ 5,5 kB. Ingen migrasjon, ingen ny RPC.

### Målt ende til ende (forslagslenka til «Vestre Hals 43», RPC stubbet — ingenting sendt)

| steg | målt |
|---|---|
| «Endre mål» | `_kundeMaalAktiv()` true, `body.kunde-maal`, originalen lagret for alle rom |
| Ekte klikk på vegg 9 (447 cm) | veggen valgt, tallfelt `_kf-1-8` i panelet, gizmo-piler og lås tegnet |
| Ekte drag av gizmo-pila 10 / 15 / 22 px | naboveggene 327 → 335 / 339 / 345 cm, 118 → 114 / 112 / 110 cm |
| Hjørne 1 flyttet 10 cm | «Stue/gang/trapp: hjørne 1 flyttet 10 / 0 cm», `geometryMode: 'points'` |
| Produkter | dempet med tekst, kortet sier «(før endring)» |
| Send uten å låse | toast «Trykk «Lås mål» først», ingen dialog |
| «Lås mål» | maskineriet av, lista med Angre, «Endre mål» igjen |
| Send (stubbet `kundelenke_answer`) | `p_answer` = `{ rooms: [{roomId:1, ok:true}], maal: { walls, points: {1}, geometryMode } }`, 368 tegn |
| Kenneths side (syntetisk prosjekt, DB stubbet) | målblokk med «Stue: vegg 1 500 → 512 cm»; «Arbeid inn målene» → vegg 1 = 512, badge UTLEGG, «✓ Innarbeidet», status fortsatt `answered` |

Et første drag på 15 px flyttet ingenting og lot seg ikke reprodusere (se SPØRSMÅL 118/6).

### Skjermbilder

- Kunde, desktop: [målmodus, vegg valgt](skjermbilder/118-kunde-maalmodus-vegg-valgt.png) ·
  [vegg flyttet, produkter dempet](skjermbilder/118-kunde-maalmodus-vegg-flyttet.png) ·
  [hjørne](skjermbilder/118-kunde-maalmodus-hjorne.png) · [låst liste](skjermbilder/118-kunde-laast-liste.png) ·
  [sendt](skjermbilder/118-kunde-sendt.png)
- Kunde, 390 px: [målmodus i skuffen](skjermbilder/118-kunde-mobil-maalmodus.png) ·
  [låst](skjermbilder/118-kunde-mobil-laast.png)
- Kenneth: [målblokk](skjermbilder/118-kenneth-maalblokk.png) · [innarbeidet](skjermbilder/118-kenneth-innarbeidet.png)

### Batterier

- `_kundeforslagRegressionTest()` — 156/156 grønne (32 nye i seksjon M)
- `_kundelenkeRegressionTest()` — 330/330 grønne (tre sjekker oppdatert fra gamle gate-strenger til `_kundeMaalAktiv()`)

---

## Slik lager du en testlenke og ser endringene

1. Åpne (eller dupliser) et prosjekt med utlegg, lagret i skyen. Trykk **Presentasjon** → **Del lenke**.
2. I dialogen: «Kunden kan foreslå endringer» (som før) og den nye **«Kunden kan rette mål»** (på som
   standard). Kopier adressen (`…/?present=<token>&forslag=<token>`).
3. Åpne den i et privat vindu (og på telefon). Du ser: et rom valgt med detaljer (116), veggmål på
   alle rom (116), venstrepanelet / skuffen (117), og «Mål → Endre mål» (118).
4. Trykk Endre mål, trykk på en vegg, dra pila eller skriv et tall, trykk Lås mål, si hva du synes,
   Send forslag (blå).
5. Tilbake i Varmeplan: prosjektet åpner forslagsvinduet med «Kunden har rettet målene» →
   **Arbeid inn målene**. Rommet får merket UTLEGG i romlista til du har lagt ut på nytt.

## Batterier kjørt

| batteri | resultat |
|---|---|
| `_kundeforslagRegressionTest()` | 156/156 (99 → 124 → 156 gjennom serien) |
| `_kundelenkeRegressionTest()` | 330/330 |

## Det som står igjen

Se `SPØRSMÅL.md`: 5 punkter for 116 (bl.a. blått = `--info`, tetthetsregel 120 px, produktkjedene),
6 for 117 (mållenka ikke lagt over på panelet, zoom ved listeklikk, etasjer) og 7 for 118
(«Blir»-tabellen, innstilling i `note`, Send med bare mål, ett uforklart første drag).
**Ikke pushet.**
