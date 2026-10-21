# 121 · Kabelmotor: rett den ekte feilen fra 103 (uten polygonbiblioteket blir det **ingen** kabel, fail-open er brutt av 083), oppdater de 7 utdaterte påstandene i `_cableGeometryRegressionTest`, og lag en rask variant av batteriet

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Gren:** `main`. Grunnlag: `docs/kabel/STATUS.md` §44.
Svar skrives i `docs/trapp/prompter/SPØRSMÅL.md` under «103».

---

## Kenneths svar (21.10.2026)

| | Svar |
|---|---|
| 103/2 | **Ja: oppdater de sju utdaterte påstandene** til målte verdier, med kommentar om hvorfor (som `_cableZoneRegressionTest` B i 096) |
| 103/3 | **Ja: rett fail-open i motoren.** Uten biblioteket skal det legges ut, merket «tilnærmet» |
| 103/4 | **Behold dagens oppførsel:** valgt retning er hard (Kenneths låste regel fra 083/088b, «start der jeg setter innsettet … vinner over dekning»). Påstanden oppdateres til det, og panelets melding («nærmeste er X cm unna») beholdes |
| 103/5 | **Ja: flytt påstanden** til hjørnet den egentlig gjaldt |
| 103/6 | **Ja: rask variant** permanent |

## STEG 0

1. Kjør de åtte påstandene (den raske kjøringen fra 103) på `HEAD`. Er de fortsatt de samme åtte?
2. **Fail-open:** hvor i kaskaden (083: «filter på kaskadenivå») returneres `null` når clipper mangler? Hva gjorde
   077/060 før 083 (hvilken tilnærmet kandidat)? Hva skal «tilnærmet» merkes med i dag?
3. Er `badHakk41|v|tr` i `baseline.json` fortsatt 63,3 %, og gir `tl`/`br` CC 13,81 · 94,9 %?

## Gjør

1. **Fail-open i motoren:** når ingen kandidat passerer hjørnefilteret **fordi clipper mangler**, slippes beste
   tilnærmede kandidat gjennom (samme vei som 077/060), merket «tilnærmet» i panelet. Med clipper lastet er
   oppførselen **uendret**. R-START er fortsatt hard. Fail-open gjelder bare når biblioteket mangler.
2. **De sju påstandene** (§44 #1, #2, #3, #4, #5, #6, #8): oppdater forventningene til målte verdier. Hver får én
   kommentarlinje med hvorfor og hvilken commit:
   - **#1:** 5,711 m² (089 hentet fixturen på nytt)
   - **#2–4:** −1040 er toppen (088)
   - **#5:** ny ordlyd (088b)
   - **#6:** 600W starter ved nærmeste lovlige punkt, og panelet melder avstanden (088b, Kenneths svar 103/4)
   - **#8:** flyttet til hjørnet den gjaldt (103/5)
3. **Rask variant:** `_cableGeometryRegressionTest({ bare: [...] })` eller en egen `_cableGeometryQuickTest()` som
   kjører et utvalg (de åtte + én per motor) på under 20 s. Dokumenter den i STATUS ved siden av
   `_cableGeoSuite()`.

## Skal IKKE

- Endre motoren utover fail-open-grenen.
- Løsne R-START, R-VEGG eller R-ENDE.
- Gjøre en eneste av de 142 radene i `_cableGeoSuite()` dårligere. Endret rad = **stopp**.
- Pushe.

## Test

1. `_cableGeometryRegressionTest()` er **helt grønn** (127 påstander). Oppgi tiden.
2. Den raske varianten er grønn på under 20 s.
3. Fail-open: clipper av gir kabel lagt ut med «tilnærmet». Clipper på gir bit-identisk med før.
4. `_cableGeoSuite()`: 142 rader, 0 endret, 0 nye, 0 borte.
5. Forstyrrelsestesten (`_cableForstyrrelsesTest`) er ikke verre enn sist målt (31 av 164).

## Rapport

STEG 0.1–0.3 · tabell over de åtte (gammel forventning → ny, og hvorfor) · fail-open før og etter · tider ·
STATUS §45. Commit: «121: kabelmotor — fail-open uten polygonbibliotek gjenopprettet (tilnærmet kandidat), 7 utdaterte påstander oppdatert med begrunnelse, rask variant av batteriet».
**STOPP** og skriv den samlede rapporten.
