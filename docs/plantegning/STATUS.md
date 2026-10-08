# STATUS — serien Plantegning (046–050)

**Kodeferdig 08.10.2026.** Alt er bygget, målt og testet. Det som gjenstår for deg står under
«Til Kenneth» nederst.

---

## Flyten som nå finnes

Slipp en PDF eller en DWG/DXF på startskjermen (eller høyreklikk → Importer plantegning):

1. **Valgdialogen** gir tre veier. Den nye heter **«Finn vegger og rom automatisk»** og er
   merket *Anbefalt*. De to gamle — «Legg inn som plantegning» (bare underlag) og «Prøv å finne
   rommene automatisk» (rasterveien) — står urørt ved siden av.
2. **Vegg-sjekken** (046): motorens vegger legges oppå underlaget. Du kan flytte en vegg, slette
   den, eller tegne en ny. Veggene snapper til hverandre. En teller viser dekning, og røde
   prikker viser strek motoren ikke forsto.
3. **Gjennomgangen** (049): rommene motoren lukket, med nummer, navn og areal fra tegningen.
   «Bekreft alle med navn fra tegningen» er standardvalget; rom-for-rom er alternativet. Rom
   uten funnet navn samles i én gruppe «Ikke navngitt» som kan åpnes og navngis.
4. Rommene opprettes som vanlige rom med romtype gjettet fra navnet. Rom med romtype «ingen
   varme» opprettes også — de skal finnes på tegningen, bare uten varmeprodukt.

Veggene lagres **sidenormalisert** (u,v av underlagsbildet, origo øverst til venstre), ikke i
verdens-cm. Det er seriens bærende beslutning: `bg.widthCm/heightCm/originX/originY` endres
etter installering (kalibrering, «Flytt underlag», bytte av fil), så verdens-cm ville drevet
bort fra tegningen uten at noe så galt ut.

---

## Målte tall

### Den syntetiske fixturen (låst med tester)

| | PDF 1:100 | DXF i mm |
|---|---|---|
| senterlinjer ut | 6 | 6 |
| lukkede rom | 2 | 2 (101 Stue, 102 Bad) |
| dekning | 100 % | 96,8 % |
| rester | 0 | 1 (møbelet, som skal forkastes) |
| kalibrering | tittelfelt «1 : 100», tillit 0,9 | `$INSUNITS`, 0,001 m/enhet, **tillit 1,0** |

### Den ekte arkitekttegningen (`Forprosjekt golvplan 23.09.26.pdf`)

| | før 047b | etter 047c | etter 047d |
|---|---|---|---|
| vegger | 372 | 253 | **168** (97 var duplikater) |
| røde rester | 10 489 | 134 | 177 |
| dekning | 13,2 % | 53,4 % | 48,3 % |
| lukkede rom | 8 (ett på 2218 m²) | 0 | **4**, alle med riktig navn og nummer |
| arealsjekk OK | — | — | **3 av 4** |
| rom-labels lest | — | **34/34** | 34/34 |

Rester og dekning går «feil vei» i 047d med vilje: kjedingen finner flere *ekte*
vegg-kandidater, og de som ikke parer seg blir røde prikker i stedet for å være usynlige.

**Tykkelses-histogrammet motsa planens antagelse.** Tegningen har 6 fylte rektangler (2/16/32
cm), ikke «28 à 20 cm, 16 à 10 cm, 28 à 5 cm». Veggene er **doble linjer** — 252 av 372
senterlinjer kom fra paring, ikke fra flater. Hele 047 ble bygget rundt den målingen.

**Labels og målestokk er i orden**, veggene er ikke. Tillit 0,5 på den ekte fila kommer av at
areal-kryss-sjekken gir 0,00152 m/pt mot tittelens 0,0353 — arealene hviler på polygonene, og
polygonene er søppel fordi veggene er det. Tittelen vinner, som den skal.

---

## Fellene som ble funnet

- **`pushUndo` manglet `S.planWalls`** — Ctrl+Z i vegg-sjekken var en stille no-op. Tredje gang
  denne feilklassen dukker opp (etter `matPaths` og `floatingDims`). Den gjorde også at tre av
  mine egne påfølgende tester målte feil tilstand.
- **Fylte flater ble dobbelttalt** (både som flate og som fire kanter) → dekningen falt fra 95
  til 35 %. Og møbellinjer ble vegger fordi strektykkelsen ble forkastet. I PyMuPDF er det
  `path["type"]` (`'f'`/`'fs'`/`'s'`) som skiller fylt fra strøket, ikke `items`.
- **`leftovers` var invertert** — den telte alt som aldri var en kandidat, derav 10 489 røde
  prikker over skravur og tekstkonturer.
- **Jeg oppgav feil mekanisme i 047b.** `unary_union` noder allerede alle kryss; den ekte
  årsaken er at stammen i et T-kryss *ikke rekker fram* — gapet er nøyaktig halve kryssveggens
  tykkelse. Toleransen i `weld_t_junctions` er derfor utledet (`thickness/2 + slakk`), ikke et
  rundt tall. Og fiksen **korrigerte 047b**: uten `allow_single` lukkes ingenting på den ekte
  tegningen — de 116 uparede linjene bærer en tredel av lukkegeometrien.
- **`close_gaps` betyr «smalere enn», ikke «til og med»** (målt: grensen går mellom 90 og 91 cm).
- **Bakgrunnen og planveggene målte forskjellig utstrekning.** `dwg_background` beskjærer til
  `MAX_BACKGROUND_SEGMENTS` og regnet utstrekningen av den *beskårne* mengden. Delt kilde nå —
  ellers driver veggene bort fra underlaget på akkurat de tegningene som er store nok.
- **Label-vinduet stod i PDF-punkter.** En DXF i millimeter har 200 mm mellom linjene, ikke 8,4
  pt, så nummer og navn falt utenfor og rommene kom tilbake navnløse. Vinduet er nå i virkelige
  meter.
- **114 av 368 vegger var duplikater av en annen vegg** (047d). Rundt ett rom lå tre nesten
  identiske senterlinjer. `_merge_collinear` fanger dem ikke: den krever sammenfallende
  *ender*, mens duplikater overlapper i hele lengden.
- **Vegger sendt som fragmenter er usynlige for hele motoren.** 7851 av 11 174 segmenter er
  kortere enn 25 cm, og `MIN_WALL_LEN_CM` kaster hver enkelt. Toppveggen over ett av rommene
  finnes ikke som en lang strek — etter kjeding er den 293 cm. Kjedingen må skje *før*
  kandidatvalget; `_merge_collinear` kjører på vegger og kommer for sent.
- **Rommene var senterlinje-areal, ikke innvendig** (047d) — defekten med størst konsekvens i
  hele serien. `polygonize` lukker senterlinjer, så polygonet går vegg-midt til vegg-midt,
  mens appens grunnregel er at `room.points` er den innvendige grensen og varmen dimensjoneres
  på arealet. Hvert rom flyten lagde var systematisk ~1,2× for stort. Og fixturens oppgitte
  arealer var satt nær senterlinje-arealet, så tre arealtester *bestod* ved å låse den gale
  konvensjonen.
- **`segment_widths` er en tom liste for DWG, ikke `None`** — «ingen informasjon», som
  `centerlines` slipper gjennom. Første utgave av kjedingen bygget en ny liste med 0.0 per
  kjede, altså «informasjon om at streken er 0 tykk», og da forsvant alle 6 DXF-veggene.
- **Et redigeringsanker jeg antok var unikt fantes to steder** og slettet 1475 linjer i
  `index.html`. Fanget på linjetallet, rullet tilbake, gjort om med unike ankere og
  `assert s.count(anker)==1`.

---

## Regresjon

- **arqely:** 17 batterier, **618 sjekker**, alle grønne. Det nye batteriet `_planRegressionTest`
  dekker A–I (lagring, undo, snap, dekning, rom fra vegger, «Ikke navngitt», DWG-valget, origo).
- **lumelo-backend:** **107 tester** grønne (`uv run pytest`), `ruff` og `mypy app` rene.
  `/import/pdf`, `/import/dwg` og `/import/dwg/background` er uendret og låst med tester.
  020s feilskille består: **415** = ingen konverterer finnes, **400** = en fantes men klarte
  ikke fila.

---

## Til Kenneth

**Du må gjøre:**

1. **Deploy lumelo-backend.** Hele motorveien (`POST /import/plan`, `POST /plan/rooms`) er ny og
   finnes bare lokalt på port 4100. Vegg-sjekken virker ikke i produksjon før den er ute.
2. **Ingen nye secrets og ingen migrasjon.** Planveggene ligger i prosjekt-JSON (`S.planWalls`
   per etasje), ikke i egne tabeller.
3. `Forprosjekt golvplan 23.09.26.pdf` ligger i `lumelo-backend/local/` som er gitignorert.
   Den er ikke i repoet og blir ikke pushet.

**Du må svare på (står i `prompter/SPØRSMÅL.md`):**

1. **30 av 34 rom lukker seg fortsatt ikke.** 047d tok det fra 0 til 4, og begge hypotesene i
   mitt eget 047d-forslag viste seg målt feil (se `SPØRSMÅL.md`). Jeg har ikke flere målte
   hypoteser som er en terskeljustering. Neste steg vil i så fall være et **flomfyll fra
   romlabelene med døråpningene lukket først** — en annen motor, ikke en innstilling. Prototypen
   jeg målte ga 8 av 34 fordi den lekker gjennom døråpningene. Si fra om du vil at jeg går den
   veien, eller om vegg-sjekken er god nok som manuell oppretting.
2. **Dekningsgrensen er 90 %.** På en ekte arkitekttegning er 53 % kanskje normalen. Skal
   grensen ned, eller skal teksten si «N vegger mangler» i stedet for en prosent?
3. **Skal høyreklikk → Importer plantegning fortsatt gi valgdialogen?** Den gikk tidligere rett
   til underlag; jeg rutet den om til dialogen fordi ordene var de samme. Si fra hvis høyreklikk
   skal være snarveien «bare legg et underlag, ikke spør».
4. **Skal en flate uten romlabel forkastes?** Motoren lager 20 slike tittelfelt-flater på din
   tegning. Regelen ville fjernet dem alle — men også «Ikke navngitt», som du avklarte skal
   finnes. Jeg lot dem stå.
5. Småting: skal `m2` uten superskrift godtas i arealene (bare `m²` er målt), og skal
   romtype-gjenkjenningen fra navn utvides?
