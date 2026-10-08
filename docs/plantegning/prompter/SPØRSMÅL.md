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

- **Tersklene ble målt mot den ekte tegningen i 048, og de holder ikke.** Kenneth la ved
  `Forprosjekt golvplan 23.09.26.pdf` (ligger i `lumelo-backend/local/`, gitignorert).
  Planens histogram var feil: tegningen har **6** fylte rektangler (2/16/32 cm), ikke
  «28 à 20 cm, 16 à 10 cm, 28 à 5 cm». Veggene er **doble linjer** — 252 av 372 senterlinjer.
- **Dekningen er ubrukelig som den er definert: 13,2 % på den ekte fila.** 6795 av 10489
  rester er kortere enn 10 cm (skravur, tekstkonturer). `total_length` måler «hvor mye av
  tegningen er vegg», som på en A2-arkitekttegning er ~13 % av natur. Den gule advarselen i
  046 ville fyrt alltid. **Fiks:** tell bare vegg-kandidater.
- **`single`-veien bør være AV som standard.** 116 uparede linjer ble «vegger» med tykkelse 0,
  de fleste 50 cm — målsettingsmerker og symboler.
- Begge hører hjemme i et 047b, eller i 050 der STEG 0.3 allerede spør om nettopp dette.
  Si fra hvilket du vil ha.

## 047b

- **Begge fiksene er gjort og målt.** Rester 10 489 → 134, dekning 13,2 % → 53,4 % på den ekte
  tegningen. Syntetisk fixtur: 100 % dekning, 0 rester.
- **Men den ekte tegningen lukker nå 0 rom** (mot 8 søppelrom før, ett på 2218 m²). Null er
  ærligere enn åtte gale, men det er ikke målet.
- **Diagnosen for hvorfor, målt på 506 veggender:** 267 snapper ende-mot-ende, **60 er
  T-kryss** (ende mot en annen veggs midtparti, median 6,4 cm unna), 179 er frittsvevende.
  `_snap_segments` snapper punkter, men `polygonize` krever at kryssveggen **deles** i
  treffpunktet. `_bridge_gaps` kobler ende-til-ende, ikke ende-til-linje.
- **Forslag til 047c:** del kryssvegger i T-punkter før `polygonize`. Det er trolig
  enkeltfiksen som gir mest. De 179 frittsvevende må diagnostiseres videre.
- **Dekningsgrensen i 046 er 90 %.** På en ekte tegning er 53 % kanskje normalen. Si fra om
  grensen skal ned, eller om teksten heller skal si «N vegger mangler» enn en prosent.

## 047c

- **Mekanismen jeg beskrev i 047b var feil.** `unary_union` noder allerede alle kryss. Den
  ekte årsaken: stammen *treffer ikke* — senterlinja stopper ved ytterveggens flate, så gapet
  er nøyaktig halve kryssveggens tykkelse (målt median 6,4 cm = halve 12,8). Toleransen er
  derfor utledet, ikke et rundt tall.
- **Sveisingen virker:** 1 → 2 rom på minimaltilfellet, 8 → 18 på den ekte tegningen.
- **Men den korrigerer også 047b.** Jeg skrev at «en uparet linje er ikke bevis på en vegg».
  Uten `single` lukkes **ingenting** på din tegning — de 116 uparede linjene bærer en tredel
  av lukkegeometrien. `allow_single` er nå en parameter (av som standard).
- **Den ekte tegningen gir fortsatt ikke brukbare rom.** To ting gjenstår, i prioritert
  rekkefølge: (1) dobbel-paringen finner ikke alle vegger — `PAIR_MIN_OVERLAP = 0.60` er
  trolig for strengt når en vegg er delt av døråpninger, og paringen er grådig (første treff
  vinner); (2) ytre ramme droppes ikke — et polygon på 2151 m² overlever.
- **Spørsmål:** vil du at jeg fortsetter på veggdeteksjonen (047d), eller at jeg går til 049
  og lar vegg-sjekken være måten du retter opp de siste veggene manuelt? Flyten er bygget for
  nettopp det — 253 vegger med 134 røde prikker er kanskje nok til å jobbe med.

## 048

- **Alt i 048 er verifisert mot den ekte tegningen** og virker: 34/34 rom-labels med nummer,
  navn og areal; målestokk «1 : 100» lest fra tittelfeltet.
- **Tillit 0,5 på den ekte fila**, fordi areal-kryss-sjekken gir 0,00152 m/pt mot tittelens
  0,0353 — 23 gangers avvik. Det er **ikke** en feil i 048: arealene hviler på at polygonene
  er riktige, og de er søppel fordi veggene er det (se 047). Tittelen vinner, som den skal.
- **Linjeavstanden kan ikke brukes som terskel** — fixturen hadde 6 pt, virkeligheten 8,4.
  Grupperingen går på rekkefølge i stedet. Verdt å vite hvis du ser en tegning med annen
  skriftstørrelse.
- Si fra om `m2` (uten superskrift) skal godtas — jeg har latt det stå, men bare `m²` er målt.

## 049

-

## 050

-
