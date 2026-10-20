# Rapport · serie 104 · 105 · 106 — trappesoner, del 2

Kjørt 20.10.2026 på `main`, fra `2cbc31f` (103). **Ikke pushet.** Tre commits, én per prompt.

| # | commit | hva |
|---|---|---|
| 104 | `c667136` | Hver sone legges nedenfra og opp |
| 105 | `3eb4500` | Avstand sider i sonen: tomt = auto, tall = låst nøyaktig |
| 106 | `c54cc96` | Produktgruppe først, fullt produktnavn, flere kabler per sone |

Ingen av promptene var kjørt fra før (sjekket med `git log`).

---

## 104 — hver sone nedenfra og opp

### Det du meldte

«I sone 2 starter repos i motsatt retning slik at kabelendene på sone 1 og sone 2 møtes og ligger
et trinn fra hverandre.»

### STEG 0 — tabellen (4 trinn / repos / 6 trinn, bygd nedenfra)

Tallene er verdens-y, og **større y = lenger ned** (målt med `w2s` i 103).

| sone | flater | start | slutt | nedenfra og opp? |
|---|---|---|---|---|
| 1 (trinn 1–4) | 0–3 | flate 0, y=418 | flate 3, y=302 | ✅ |
| 2 (repos) | 4 | flate 4, **y=185** | flate 4, **y=295** | ❌ motsatt |
| 3 (trinn 5–10) | 5–10 | flate 5, y=178 | flate 10, y=2 | ✅ |

Sone 1 sluttet ved y=302, sone 2 startet ved y=185 — **117 cm unna, i motsatt ende** — og sluttet
ved y=295, rett ved der sone 1 sluttet. Begge startet på **venstre** side (alle tre sonene gjør det).

### Årsak: rutingen, ikke markørene

Prompten foreslo to mistenkte. Målingen pekte på en tredje: posisjonsformelen i `generateStairCable`
hadde `(isLanding || startFromTop)`, med begrunnelsen «repos har ingen retningspreferanse». Marginen
er symmetrisk, men **retningen kabelen traverserer flaten i er det ikke**. Feilen gjaldt også
trapper **uten** soner — soner gjorde den bare synlig som to kabelender ved siden av hverandre.

### Etter

| oppsett | før | etter |
|---|---|---|
| bunn, med soner | sone 2: 185 → 295 | **295 → 185** |
| bunn, uten soner | to hopp på 117 cm | 4–7 cm, sammenhengende |
| `buildDirection:'top'` | 56 cm hopp på **hvert** trinn | 4–7 cm |

Strengantall, CC og total kabellengde er uendret (10 036,8 cm med soner).
Plan, sidevisning og PDF leser nå **én** kilde for start/slutt (`_stairCableEndpoints`) — det lå tre
ordrette kopier av samme algoritme.

**Se det:** åpne trappa, sett tre soner. Grønn prikk ligger nederst i hver sone, rød øverst.
[Før](../trapp/skjermbilder/104-for-plan-og-side.png) · [Etter](../trapp/skjermbilder/104-etter-plan-og-side.png) ·
[Sidevisning før](../trapp/skjermbilder/104-for-sidevisning.png) · [etter](../trapp/skjermbilder/104-etter-sidevisning.png)

---

## 105 — avstand sider brukes nøyaktig

### Det du meldte

«Det skjer ingen endring når jeg reduserer avstand til sider nærmere enn 6 cm. Det bør kunne gå.
Da skal kabel bli for kort i enden, og det må vises.»

### STEG 0

- **Bekreftet.** Tastet 9, 7, 5 og 3 cm i sone 2 — løst avstand ble **15,7 cm i alle fire**. Feltet
  var et *gulv*, og løserens eget svar lå allerede over.
- **En for kort kabel ble ikke tegnet i det hele tatt.** Sone 3 med 20 m mot et behov på 48,9 m:
  trinn 5–6 fikk fire løp, trinn 7 fikk to, trinn 8–10 fikk **null** — uten en strek. Samme i PDF.
- `zoneSettings[z].edgeMarginMin_cm` leses tre steder; verken PDF eller venstremeny leser det direkte.

### Migreringsvalget

`edgeMarginMin_cm` **beholder** sin gamle betydning (gulv). Den låste verdien fikk et nytt felt,
`edgeMargin_cm`. Prosjekter fra 102 oppfører seg derfor nøyaktig som før (målt). Et gammelt gulv
vises i feltet merket «(min)» og blir låst først når du redigerer det.

### Etter (sone 2 = repos, behov 28,0 m ved 5 cm)

| oppsett | avstand | kabel | status |
|---|---|---|---|
| auto | 15,7 cm | 25 m | 🟢 Passer |
| låst 5 cm | **5,0 cm** | 25 m | 🔴 3,0 m for kort — **2 løp** stiplet rødt |
| låst 9 cm | **9,0 cm** | 25 m | 🔴 1,9 m for kort — 1 løp |
| låst 20 cm | **20,0 cm** | 25 m | 🟡 1,2 m for lang |
| låst 20 cm, auto-kabel | 20,0 cm | **20 m** (nærmeste kortere) | — |
| tomt igjen | 15,7 cm | 25 m | som før 105 |

**Se det:** velg en sone, skriv 5 i «Avstand sider». Feltet får hengelås, og de to løpene kabelen
ikke rekker, tegnes stiplet rødt.
[Tegning](../trapp/skjermbilder/105-laast-5cm-for-kort.png) · [Panel](../trapp/skjermbilder/105-panel-sone-2-laast.png)

---

## 106 — produktgruppe og flere kabler per sone

### STEG 0

- **Elleve steder** antok én kabel per sone (at `cables[zi]` ER sone `zi`). Alle leser nå `zone`.
- **Åtte produktgrupper** finnes. `product.name` er alltid «\<familie\> \<W\>W \<lengde\>m», og
  400 V-familiene bærer «400V» i familienavnet — den gamle etiketten ga «InSnow 30T 400V 400V».

### Etter

Sone 3 (behov 45,0 m) med 25 m + 20 m: begge lagt, margin 13,0 cm — **samme som auto fant for én
45 m-kabel** — 🟢 Passer. Skjøten ligger midt i trinn 8, og K2 starter innenfor 1 cm av der K1
slutter. Sone 1 og 2 uendret. «Tilbake til auto» gir bit-identisk samme utlegg som før 106.

**Fargevalget:** sonen eier fargen, kabel 2 får en lysere nyanse av den. Markørene heter «S1/S2» per
sone og «K1/K2» innenfor en sone med flere.

**Sidefunn rettet:** tegningen hentet kabelfargen fra et indeksoppslag i en global liste — og PDF-en
hadde sin egen liste med bare **tre** farger. Sone 3s andre kabel ble tegnet i sone 1s oransje, og
markøren het «K4».

**Se det:** velg en sone → «Produktgruppe» → «Kabler». Legg til en kabel til med «＋ Legg til kabel».
[Panel](../trapp/skjermbilder/106-panel-sone-3-gruppe-og-to-kabler.png) · [Tegning](../trapp/skjermbilder/106-sone-3-to-kabler.png)

---

## Batterier

Kjørt etter hver prompt, og til slutt:

| batteri | påstander | resultat |
|---|---|---|
| `_stairRegressionTest` | 24 | ✅ |
| `_stairSideRegressionTest` | 25 | ✅ |
| `_stairManualSetRegressionTest` | 42 | ✅ |
| `_stairZoneRegressionTest102` | **77** (var 36 før serien) | ✅ |
| `_cableGeoSuite()` | 142 rader | ✅ **uendret** — 0 endret, 0 nye, 0 borte |

De nye seksjonene i `_stairZoneRegressionTest102`: **F** (104 — hver sone nedenfra og opp),
**H** (105 — låst avstand, udekkede løp, migrering), **I** (106 — flere kabler, skjøten, gruppe).
F-sjekkene er vaksinetestet: med den gamle repos-retningen blir fem av dem røde.

Kabelmotoren for rom er ikke rørt.

## Hva som står igjen

`SPØRSMÅL.md` i denne mappen har 15 punkter — fire på 104, fem på 105 og seks på 106. De viktigste:

- **104/2:** feilen gjaldt også trapper uten soner, og jeg rettet den for alle. Si fra hvis du heller
  ville hatt den gated på soner.
- **105/2:** terskelen på 5 cm for hva som teller som et «udekket løp».
- **106/1:** fargevalget — lysere nyanse av sonefargen, eller egne farger per kabel?
- **106/6:** auto er fortsatt én kabel per sone. Skal auto kunne foreslå to?
