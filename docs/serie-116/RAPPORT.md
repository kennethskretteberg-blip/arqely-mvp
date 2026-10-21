# Rapport · serie 116 · 117 · 118 — kundepresentasjonen

Kjørt 21.10.2026 på `main`, fra `ecb71c4` (115). **Ikke pushet.** Én commit per prompt.

| # | commit | hva |
|---|---|---|
| 116 | (se under) | Forhåndsvalgt rom, mål på alle vegger, blå «Send forslag» |

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

