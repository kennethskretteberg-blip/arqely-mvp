# Rapport · serie 116 · 117 · 118 — kundepresentasjonen

Kjørt 21.10.2026 på `main`, fra `ecb71c4` (115). **Ikke pushet.** Én commit per prompt.

| # | commit | hva |
|---|---|---|
| 116 | `70feed0` | Forhåndsvalgt rom, mål på alle vegger, blå «Send forslag» |
| 117 | (se under) | Ett venstre panel; skuff på mobil |

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

