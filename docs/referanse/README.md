# Referansefiler

## `gbao10-golden-sample.txt`

En EKTE Cenika-fil som Visma Global faktisk importerte: «tilbud HF432.100 Kiwi Søvik REV A»,
98 linjer. Lagret 01.10.2026 på Kenneths forespørsel som fasit for GBAO10-eksporten.

**Inneholder kundedata** (kundenr 38156, kontaktperson, prosjektnavn). Repoet er privat.
Fila skal aldri endres — den er fasit nettopp fordi den er uendret.

Invariantene den koder er låst i `_gbao10RegressionTest()` i `index.html`:

| | Fasit |
|---|---|
| Felt per linje | 33 |
| Utfylte felt | 1, 2, 3, 4, 7, 13, 14, 17, 19, 22 |
| Konstanter | felt 1 = `GBAO10`, 2 = `1`, 13 = `1`, 14 = `1`, 22 = `0` |
| Linjeskill | CRLF |
| Tegnsett | UTF-8, ingen BOM |
| Artikkelnr (felt 17) | `CV`+6 siffer (89×), bare siffer (7×), `CK`+6 siffer (1×), `CV`+7 siffer (1×) |

Siste rad er den viktige: **`CVA`-koder forekommer ikke én eneste gang i fasiten**, men er
det Varmeplan-katalogen sender. Se endringsloggen 01.10.2026.
