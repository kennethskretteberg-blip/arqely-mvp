# SPØRSMÅL · trapp-serien 084–087

Kenneth svarer når serien er ferdig. Claude Code fyller inn under hver prompt det som var uklart og
hva den valgte.

## Fra Cowork (valgt standard står i promptene — si fra hvis du vil ha det annerledes)

1. **084 — grense for kantavstand ved én kabel.** Standard: minst 75 % av trinnbredden skal ha
   varme (maks 12,5 % av bredden per side, f.eks. 30 cm på en trapp som er 240 cm bred). Over din
   kant + 15 cm vises et gult merke. Skal grensen være strengere eller løsere?
   **Svar:**
2. **087 — dine egne mållinjer i PDF-en?** Standard i denne runden: nei. PDF-en får trappens egne
   mål (085). Vil du også ha mållinjene du tegner selv med på utskriften?
   **Svar:**
3. **087 — feste målet til trappen.** Standard: er en trapp valgt når du trykker D, følger målet
   trappen når den flyttes og slettes med den. Ellers blir målet liggende fritt i trapp-delen. Er
   det riktig?
   **Svar:**
4. **086 — én rasterinnstilling for alle moduler** (skrur du av i trapp, er den av i innendørs også).
   Eller vil du ha egen innstilling per modul?
   **Svar:**

## Fra Claude Code

### 084

1. **Eldre trapper får dagens utleggsmargin som gulv.** Frydenbø har `edgeMargin_cm = 12,5`
   (fra 70 m-kabelen du alt valgte). Ved første åpning blir gulvet 12,5 — forslagene regner da
   fra 12,5, ikke 5. **Valgt:** migrering uten gjetting (prompten §4). Du setter «Avstand sider»
   til 5 én gang, så står gulvet. Vil du heller at migreringen setter 5 for alle gamle trapper?
2. **Test 5 i prompten («3 like kabler» på Trapp 1) går ikke opp** — 3 × 20 m krever +23 cm,
   over +15-taket. Det var slik før 084 også. Testen bruker en 24-trinns trapp (3 × 70 m).
   Skal +15-taket også gjelde for N like kabler, eller skal 75 %-grensen brukes der også?
3. **75 %-grensen måles mot smaleste flate** (inkl. repos). Riktig?

### 085

1. **Opptrinn-kjeden viser 9 × 16 = 144 for 8 trinn.** Sidevisningen tegner et opptrinn fra bakken
   opp til trinn 1 OG ett over trinn 8 (opp til planet over), slik den alltid har gjort. Kjeden
   følger tegningen. **Valgt:** tallet skal stemme med det som tegnes. Vil du heller ha «8 × 16»
   (trinn 1 på bakken, ingen opptrinn under)?
2. **Geometrimålene vises på skjerm bare når trappa er valgt** — det finnes ingen global
   «vis mål»-bryter for rom (`dimSnap` er per rom). Kabelmålene vises alltid, som før.
3. **Sidevisningen i PDF roteres aldri** (profilen er liggende av natur); liggende side velges
   fortsatt bare av plan-båndene. Lang trapp deles i bånd langs lengden.

### 086

Ingen. Felles innstilling (spørsmål 4 over), ikke lagret med prosjektet (som før).

### 087

1. **Å klikke et mål avvelger trappa.** Delete-tasten sjekker trapp før mål; ellers ville Delete
   på et valgt trappemål slettet hele trappa. Trappas mål vises uansett.
2. **Frie mål hadde ingen gizmo før** (heller ikke innendørs etter kalibrering) — rettet som
   sidefunn, siden samme kode nå dekker alle tre måltyper.
3. **Gjemte mål (lesende):** 5 i rom (Knut Arne og Bente: 1, Fossilveien 18: 4), 1 fritt uten
   etasje («Trapp»). Ikke rørt. Si fra om de skal slettes eller flyttes.

### 101

1. **Frydenbø Trapp 1 blir rød med dagens kabel.** 70 m-kabelen er 8 cm lengre enn behovet ved
   kantavstanden du har satt (12,5 cm). Regel 11/12 sier da «går ikke opp», og panelet sier det nå
   i stedet for å stå grønt på «Passer». Utlegget er uendret — marginen står på gulvet. Skal det
   finnes en toleranse (f.eks. «overskudd under ett mm-snapp i margin, her 6,4 cm, telles som
   eksakt»), eller er rødt riktig for 8 cm?
   **Svar (Kenneth 20.10):** Ikke rødt for 8 cm. Bruk samme grense som resten av panelet
   (`_stairFitFromLengths`: ≤ 2 % = Passer, 2–5 % = gul, > 5 % = rød). Gjort i 103 (Del B.1):
   overskudd ved gulvet vurderes nå med den ene felles regelen, for både manuelt sett og sone.
2. **Meldingen bruker cm under én meter.** Prompten skrev «Kablene er X m for lange»; «0,1 m» er
   misvisende for 8 cm, så teksten bytter til cm under en meter (samme valg som varslene ellers i
   trappepanelet). Si fra om du heller vil ha meter alltid.
   **Svar (Kenneth 20.10):** OK — cm under én meter. Ingen endring.
3. **«Antall kabler» viser nå antall rader** (var tomt/«auto» før). Tomt felt betyr fortsatt at
   Forslag-søket står fritt; endrer du tallet, legges rader til eller fjernes bakfra. OK?
   **Svar (Kenneth 20.10):** OK. Ingen endring.
4. **Et manuelt bytte nullstiller «valgt forslag»** (som prompten ba om), men forslaget huskes, og
   «Tilbakestill» gir deg hele forslaget tilbake — nå også kabelsettet, ikke bare målene. OK?
   **Svar (Kenneth 20.10):** OK. Ingen endring.
5. **Marginen løses også på nytt når du endrer et mål etterpå** (maks CC, dybdemargin, trinnbredde,
   din egen kantavstand) så lenge settet er manuelt. Alternativet var at den bare løses idet du
   bytter kabel, og så blir stående feil etter en CC-endring. Valgt: løses på nytt.
   **Svar (Kenneth 20.10):** OK — marginen løses på nytt når et mål endres. Ingen endring.
6. **Produktlinja over lista står dobbelt** for én kabel («InSnow 30T 2100W 70m 70m») — den er
   uendret fra før, men blir overflødig nå som lista viser produktet. Skal jeg fjerne den?
   **Svar (Kenneth 20.10):** Fjern den. Gjort i 103 (Del B.2) — både i trappepanelet og i sonens
   eget panel. «Ingen kabel valgt» vises fortsatt når lista er tom.
7. **Soner er urørt** (prompt 102). Med soner på vises fortsatt det gamle enkeltvalget.
   **Svar (Kenneth 20.10):** Løst av 102. Ingen endring.

### 102

1. **«Avstand foran/bak» per sone setter BÅDE nese og opptrinn**, akkurat som feltet gjør på
   trappenivå. Prompten nevnte bare `noseOffset_cm`. Skal sonen kunne sette dem hver for seg?
   **Svar (Kenneth 20.10):** OK som det er — ett felt setter begge, likt som for hele trappa.
   Ingen endring.
2. **Sonens gulv er et eget felt** («Avstand sider (min)»), ikke den løste verdien. Setter du 9 cm
   på sone 2, er 9 cm minimum — løsningen kan fortsatt legge seg lenger inn (084/Regel 12 gjelder
   også per sone). Trappas eget gulv røres aldri.
   **Svar (Kenneth 20.10):** OK — sonens gulv er et eget minimum. Ingen endring.
3. **Én sone uten gyldig kabel tegnes udekket** (auto fant ingen kabel): sonen får ingen kabel,
   marginen står på gulvet, og den røde meldingen står på sonen. De andre sonene tegnes som før.
   Alternativet var å la hele trappa fryse, som i dag. Valgt: per sone (Regel 21).
   **Svar (Kenneth 20.10):** OK — udekket sone med rød melding på sonen. Ingen endring.
4. **Soneinnstillinger ryddes ved LAGRING**, ikke ved hver omregning — slår du en sone midlertidig
   av mens du redigerer, står innstillingene til du lagrer. OK?
   **Svar (Kenneth 20.10):** OK — rydding ved lagring. Ingen endring.
5. **Sidefunn jeg rettet uten å spørre:** et repos fikk SIDE-avstanden tegnet inn som dybdemål i
   målsettingen (både på skjerm og i PDF), og detaljutsnittet av Repos 1 oppga 27 m kabel i stedet
   for 25 m. Motoren har alltid brukt repos-dybdemarginen; bare målsettingen og bildeteksten var
   feil. Samme klasse feil som sonemarginen, så de ble rettet i samme grep.
   **Svar (Kenneth 20.10):** OK — sidefunnene er riktig rettet. Ingen endring.
6. **Klikk mellom flatene** (inne i trappas boks, men ikke på et trinn) lar sonevalget stå. Skal det
   heller nullstille til «Hele trappa»?
   **Svar (Kenneth 20.10):** La sonevalget stå. Ingen endring.
7. **Trapper uten soner er uendret.** Sonevelgeren og underradene vises bare når soner er i bruk.
   **Svar (Kenneth 20.10):** Bekreftet. Ingen endring.

### 103

**Del A og B er gjort.** Svarene dine fra 20.10 står under hvert spørsmål i 101 og 102 over.

1. **«Tre røde sjekker» var feil — det er ÅTTE.** Feilen var min: i 102-rapporten skrev jeg ut bare
   de tre første (`.slice(0, 3)`) og leste det som tre. Endringsloggen for 102 er rettet.
   Full måling i `docs/kabel/STATUS.md` §44.
   **Svar (Kenneth 21.10):** (Tatt til etterretning.) Gjort i 121: STEG 0 kjørte de åtte på nytt på `bca0959` — fortsatt de samme åtte, 127 påstander.
2. **Sju av åtte er utdaterte påstander, ikke dårligere utlegg.** De låser tall fra før 088 rettet
   den speilvendte y-aksen (målt: `w2s` gir mindre skjerm-y for world-y −1040, så −1040 ER toppen —
   testen tror det motsatte) og før 089 hentet Rom 5-fixturet på nytt fra det ekte prosjektet
   (5,698 → 5,711 m²). **Forslag til retting:** oppdater forventningene i
   `_cableGeometryRegressionTest` til de målte verdiene, med en kommentar om hvorfor — slik
   `_cableZoneRegressionTest` B ble oppdatert i 096 («en påstand som låser et design, må oppdateres
   når designet er det som endres»).
   **Svar (Kenneth 21.10):** Ja, oppdater de sju til målte verdier med kommentar om hvorfor. Gjort i 121: #1 5,711 m² (089), #2–4 topp = minst y (088), #5 088b-ordlyd, #6 se 103/4, #8 flyttet til `tl` (103/5). Hver har én kommentar med commit.
3. **Én er en ekte forverring: `077: uten biblioteket legges det fortsatt ut`.** 083 la inn et hardt
   filter på kaskadenivå («start i valgt hjørne går foran dekning»), og uten polygonbiblioteket
   finnes det da ingen kandidat som slipper gjennom — rommet får **ingen kabel**. Fail-open-regelen
   fra 077/060 sier at det skal legges ut, bare merket «tilnærmet». **Forslag til retting:** la
   hjørnefilteret slippe gjennom en tilnærmet kandidat når ingen eksakt finnes, i stedet for å
   returnere null. Dette er den eneste av de åtte som bør rettes i MOTOREN.
   **Svar (Kenneth 21.10):** Ja, rett fail-open i motoren. Gjort i 121 — men årsaken var ikke hjørnefilteret: uten clipper gir geo «ingen løsning», og siden 083 er V6 ute av konkurransen, så kandidatlista var TOM og `_autoFillCableImpl` returnerte `null`. Nå går dagens kaskade gjennom som tilnærmet kandidat (merket `_geomApprox`, panelet sier «tilnærmet»), bare når biblioteket mangler. Med clipper er utlegget bit-identisk (ny påstand låser det).
4. **`082: 600W når øvre venstre hjørne` (nå 189 cm) er en reell UX-endring.** 088b gjorde valgt
   retning hard — hjørnerunden kan ikke lenger snu retningen for å nå hjørnet. Panelet sier fra
   («start 124 cm fra hjørnet» + en advarsel). Vil du ha hjørnet tilbake på bekostning av retningen,
   eller er dagens oppførsel riktig?
   **Svar (Kenneth 21.10):** Behold dagens oppførsel — valgt retning er hard (083/088b). Gjort i 121: påstanden låser nå «> 40 cm, fortsatt loddrett», og at panelet melder avstanden («start N cm fra hjørnet») og at hjørnet ikke nås («nærmeste er N cm unna»).
5. **`074b badHakk41` måler mot feil hjørne.** `baseline.json` har samme rad som 63,3 % og grønn —
   det er den aksepterte tilstanden. Det gamle resultatet (CC 13,81 · 94,9 %) finnes fortsatt, under
   `tl`/`br`. **Forslag:** flytt påstanden til det hjørnet den egentlig gjaldt.
   **Svar (Kenneth 21.10):** Ja, flytt påstanden. Gjort i 121: badHakk41 måles i `tl` (CC 13,81 · 94,9 %); badHakk 47 m står på `tr`. `tr` for badHakk41 (63,3 %) er den aksepterte raden i `baseline.json` og vaktes av `_cableGeoSuite()`.
6. **Batteriet tar 127 s og har 127 påstander.** En kjøring med kun de åtte tar under 15 s. Vil du
   ha en «rask» variant permanent (f.eks. `_cableGeometryRegressionTest({ bare: [...] })`)?
   **Svar (Kenneth 21.10):** Ja, rask variant permanent. Gjort i 121: `_cableGeometryRegressionTest({ rask: true })` / `_cableGeometryQuickTest()` — hovedløkka på ett utvalg fixturer (én per motorfamilie), alle seksjonene (inkl. de åtte). Dokumentert i STATUS §45.
