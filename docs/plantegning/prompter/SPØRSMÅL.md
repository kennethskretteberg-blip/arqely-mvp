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

- **«Anbefalt»-merket er flyttet**, slik 046 varslet: PDF og DWG anbefaler nå «Finn vegger og
  rom automatisk». De to gamle valgene står urørt ved siden av.
- **Rom uten varme ble borte, ikke uvarmet.** Første versjon av `_reviewCommit` droppet rader
  med romtype «ingen varme» helt. Det er feil tolkning av avklaringen din: rommet skal
  *finnes* på tegningen, bare uten varmeprodukt. Nå opprettes det med `calcType: 'none'`.
- **`rr.calcType || 'foil'`** gjorde at «ingen varme» likevel fikk folie, fordi `'none'` er
  sant men falt gjennom en senere gren. Rettet; regresjonstest låser det.
- **«Ikke navngitt» er en sammenslått gruppe**, ikke N rader. Et rom motoren ikke fant navnet
  på får ikke et gjettet navn — gruppa kan åpnes og navngis, eller bekreftes som den er.
- Si fra om gjenkjenningen av romtype fra navn skal utvides. Den bruker nå `_pdfGuessRoomType`
  utvidet med arkitekttegningens ord (sov/stue/bad/vask/gang/wc/kjøkken/teknisk/bod).

## 050

- **Fylte flater finnes ikke i DWG** — CAD-vegger er doble linjer. `rect`-veien i 047 er
  ubrukt for DWG, og `double`-tersklene bærer alt. Verdt å vite før du justerer terskler.
- **$INSUNITS gir eksakt målestokk** (`confidence: 1.0`), bedre enn både tittelfelt og
  arealkryss. Derfor står «Anbefalt» på plan-veien også for DWG.
- **Tre feller, alle målt og rettet:** (1) bakgrunnen beskjærer til `MAX_BACKGROUND_SEGMENTS`
  og målte utstrekningen av den beskårne mengden — nå delt kilde, ellers driver veggene bort
  fra underlaget på store tegninger; (2) origo er ikke (0,0) i en DWG, så normaliseringen må
  trekke det fra; (3) **label-vinduet stod i PDF-punkter** og brakk på en DXF i millimeter —
  rommene kom tilbake navnløse. Vinduet er nå i virkelige meter.
- **Ubesvart fra 047c:** skal jeg gjøre 047d (dobbel-paringen + ytre ramme), eller er
  vegg-sjekken den manuelle opprettingen? Den ekte tegningen står på 253 vegger / 134 røde
  prikker / 53,4 % dekning / 0 lukkede rom.
- **Dekningsgrensen (046) er fortsatt 90 %.** Si fra om den skal ned, eller byttes til
  «N vegger mangler».

## 047d

- **Begge hypotesene i mitt eget 047d-forslag var feil, og det er målt.**
  `PAIR_MIN_OVERLAP = 0.60` er ikke flaskehalsen: av 3363 par som avvises *bare* av
  overlapp-testen er medianen 0.000 og **maks 0.590** — terskel 0,5 gir 7 nye par, 0,1 gir 40.
  Grunnen hypotesen var feil: nevneren er den *korteste* av de to, så en kort innervegg mot en
  lang ytterlinje gir overlapp 1,0 — nettopp døråpningstilfellet jeg trodde feilet.
  Og `_drop_outer_frame` feiler ikke fordi kriteriet er for strengt, men fordi `polygonize`
  lager en **plan oppdeling**: ark-flaten inneholder 0 av 17 andre polygoner.
- **Seks tilnærminger ble målt før noe ble skrevet.** Ingen lukket rommene ved å skru på en
  terskel. `MIN_STROKE_PT` ned til 0 ga 87 polygoner, men 2 av 34 med riktig areal. Et
  raster-**flomfyll** fra romlabelene ga 8 av 34 — det lekker gjennom døråpningene.
- **Fire defekter ble funnet og rettet:** 114 av 368 vegger var duplikater; 7851 av 11 174
  segmenter er kortere enn 25 cm så vegger sendt i fragmenter var usynlige; ark-flaten ble
  «rom 1» på 2149 m²; og — den med størst konsekvens — **rommene var senterlinje-areal, ikke
  innvendig.**
- **Den siste er verdt å merke seg:** `polygonize` lukker senterlinjer, så polygonet går
  vegg-midt til vegg-midt. Appens grunnregel er at `room.points` er den *innvendige* grensen,
  og varmen dimensjoneres på arealet. Hvert rom plantegning-flyten lagde var altså for stort,
  systematisk ~1,2×. Rettet i både `/import/plan` og `/plan/rooms`.
- **Resultat på din tegning: 0 → 4 lukkede rom**, alle med riktig navn og nummer, 3 av 4 med
  arealsjekk OK. 168 vegger (mot 253), 177 røde prikker, dekning 48,3 %.
- **Jeg lot 20 navnløse flater stå.** En regel «en flate uten romlabel er ikke et rom» ville
  fjernet alle de 20 tittelfelt-flatene motoren lager — men den ville også fjernet «Ikke
  navngitt», som du avklarte eksplisitt skal finnes. Si fra om du vil ha regelen likevel, evt.
  bare for flater som ligger utenfor alle romlabelenes område.
- **Fortsatt ubesvart:** 30 av 34 rom lukker seg ikke. Resten av veggene må rettes i
  vegg-sjekken. Jeg har ikke flere målte hypoteser — det neste steget er i så fall et
  flomfyll med døråpningene lukket først, som er en annen motor, ikke en terskel.
