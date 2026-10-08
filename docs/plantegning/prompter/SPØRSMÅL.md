# SPØRSMÅL — serien Plantegning (046–050)

Claude Code: legg spørsmål under riktig prompt mens du kjører, med valget du tok i mellomtiden.
Kenneth svarer til slutt.

## Avklart av Kenneth før start (08.10.2026)

- **Testfila:** arkitekttegningen (Okkenhaugvegen 20B) blir **ikke** lagt i repoet — adressen
  står i tittelfeltet. 047 lager en syntetisk fixture bygget fra det som måles på den ekte fila
  lokalt. Den ekte brukes bare til manuell verifisering.
- **Rom uten varme:** navngis med romtype «ingen varme» når navnet er kjent. «Ikke navngitt»
  betyr *motoren fant ikke navnet*, ikke *rommet skal ikke varmes*.
- **«Bekreft alle med navn fra tegningen»** er standardknappen; rom-for-rom er alternativet.
- **Rekkefølgen er snudd:** vegg-sjekken (046) bygges før motoren (047/048).

## 046

- **Prompten min sa verdens-cm; målingen sa nei.** `bg.widthCm/originX/originY` endres etter
  installering (kalibrering, «Flytt underlag», bytte), så planvegger i verdens-cm ville drevet
  bort fra tegningen. De lagres nå sidenormalisert (u,v av underlagsbildet). **Dette er en
  endring i kontrakten 047 skal levere:** motoren må normalisere selv, ikke sende PDF-punkter.
- **Høyreklikk-menyens «Importer plantegning» gikk rett til underlag** — samme ord som knappen
  som gir valgdialogen. Rutet om. Si fra hvis du vil at høyreklikk fortsatt skal være
  snarveien «bare legg et underlag, ikke spør».
- **«Anbefalt»-merket står fortsatt på «La appen finne rommene»** for PDF. Det flyttes i 049.
  Fram til da har PDF tre valg der det anbefalte ikke er det nye.
- `_planDevFixture(1)` i konsollen legger inn testvegger på etasje 1 — den er dev-hooken 046
  testes mot, og formen 047 skal levere.

## 047

-

## 048

-

## 049

-

## 050

-
