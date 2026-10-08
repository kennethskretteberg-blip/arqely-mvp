# 050 · DWG gjennom samme flyt, regresjon og STATUS

**Repo:** `lumelo-backend` + `arqely-mvp` · **Prioritet: Normal** · **Størrelse: middels**
**Spec:** `spec-plantegning.md`. Krever 047–049. **Symbolnavnene er fasit.**

---

## Kenneths ord

> «DWG skal gå samme vei. Og jeg vil ikke oppdage om tre måneder at plantegning-flyten er
> ødelagt fordi noe annet ble endret.»

## Hva som finnes — målt 08.10.2026

| | Finnes | Hvor |
|---|---|---|
| DWG → DXF | ODA (`odafc`, lisens-gated) → LibreDWG (`dwg2dxf`) → `DwgConversionError` | `app/parsers/dwg_parser.py` (`_load`) |
| DWG-bakgrunn | `POST /import/dwg/background` → SVG + utstrekning + `$INSUNITS` | i produksjon |
| Klient | `_loadBgDwg` (:41795) speiler `_loadBgPdf`, installerer vanlig `S.bgs` | i produksjon |
| Feilskille | **415** = ingen konverterer finnes · **400** = en fantes, men klarte ikke fila | bevisst, speiles i klienten |
| Kalibrering | `$INSUNITS` kode 4 = mm → **ferdig kalibrert**, bedre enn PDF | 021 |
| Lag-velger | `/import/dwg/layers` | i produksjon |

**`$INSUNITS` er en fordel DWG har over PDF:** skalaen er eksakt, så `calibration.method` kan
være `'insunits'` med `confidence=1.0` — tittelfelt og arealer trengs ikke.

## STEG 0

1. **Hva gir `dwg_parser` i dag — strek, eller strek + fylte flater?** Senterlinje-steget (047)
   hviler på fylte rektangler for PDF. Har DXF dem i det hele tatt, eller er CAD-vegger
   **alltid** doble linjer? Mål på en ekte DXF. Rapportér — hvis CAD bare har doble linjer, er
   `source:'rect'`-veien ubrukt der, og `'double'`-terskelverdiene bærer alt.
2. **Lag-velgeren: skal den stå foran plan-flyten?** I dag velger brukeren vegg-lag før
   auto-tolkningen. Med vegg-sjekken (046) er lag-valget mindre kritisk — men et plantegnings-lag
   med møbler gir mer støy. Mål hvor mange senterlinjer man får med og uten lag-filter.
3. **Løse streker blåser opp rammen** (021: bygget 10,1 × 13,9 m mot utstrekning 20,1 × 24,3 m).
   Påvirker det `coverage`-prosenten? Mål — hvis målsettingsstrek teller i `total_length`, blir
   dekningen kunstig lav og den gule advarselen fyrer uten grunn.

## Gjør

1. **`/import/plan` tar DXF/DWG** gjennom `dwg_parser`, samme kontrakt. `calibration.method =
   'insunits'` når `$INSUNITS` er entydig; ellers tittelfelt/arealer som for PDF.
2. **Klienten:** DWG får det samme tredje valget i `_rasterMethodChoice` som PDF fikk i 046.
   Vektorveien (`/import/dwg`) **beholdes** som eget valg — den er i produksjon.
3. **`coverage` skal ikke straffes for målsetting.** Hvis STEG 0.3 viser at løse streker teller
   med, ekskluder segmenter som ikke er på et vegg-lag, eller som er kortere enn 20 cm.
   **Ikke beskjær tegningen** — 021 slo fast at å kutte deler av brukerens tegning stille er
   verre enn en stor ramme.
4. **Regresjon, begge repoer:**
   - lumelo `pytest`: senterlinjer på syntetisk PDF **og** syntetisk DXF, dekning, labels, skala,
     og at `/import/pdf` + `/import/dwg` svarer som før (låst).
   - arqely `_planRegressionTest`: hele kontrakten inn → `S.planWalls` → «Lag rom» →
     `_reviewState` → navngitte/ikke navngitte. Kjør alle 16 batterier.
5. **`docs/plantegning/STATUS.md`:** hva som er bygget, de målte tallene (tykkelses-histogram,
   dekning, antall rom før/etter), fallgruvene som ble funnet, og **«Til Kenneth»** med det han
   må gjøre (deploy av lumelo, evt. secrets) og det som står ubesvart i `SPØRSMÅL.md`.

## Skal IKKE

- Endre `/import/dwg` eller `/import/dwg/background` — de er i produksjon.
- Fjerne vektorveien som valg.
- Beskjære tegningen automatisk.

## Test

1. Ekte DWG → plan-flyt: vegger i rav på underlaget, ferdig kalibrert fra `$INSUNITS`
   (ingen målestrek-spørsmål), «Lag rom» → navngitte rom.
2. En DWG uten entydig `$INSUNITS` → faller til tittelfelt/arealer, og spør om målestrek hvis
   begge mangler.
3. 415 og 400 gir fortsatt to ulike meldinger i klienten (lås med en test).
4. Dekning på en tegning med målsetting er > 90 % (altså at STEG 0.3-fiksen virker).
5. Alle 16 arqely-batterier + hele `pytest` grønne.

## Rapport

STEG 0.1–0.3 (har DXF fylte flater, lag-filterets virkning, om målsetting senket dekningen),
og STATUS.md + «Til Kenneth».
Commit: «050: plantegning — DWG gjennom samme flyt med $INSUNITS-kalibrering, dekning uten målsettingsstøy, regresjon i begge repoer»
