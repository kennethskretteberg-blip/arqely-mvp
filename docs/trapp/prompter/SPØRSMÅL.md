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
2. **Meldingen bruker cm under én meter.** Prompten skrev «Kablene er X m for lange»; «0,1 m» er
   misvisende for 8 cm, så teksten bytter til cm under en meter (samme valg som varslene ellers i
   trappepanelet). Si fra om du heller vil ha meter alltid.
3. **«Antall kabler» viser nå antall rader** (var tomt/«auto» før). Tomt felt betyr fortsatt at
   Forslag-søket står fritt; endrer du tallet, legges rader til eller fjernes bakfra. OK?
4. **Et manuelt bytte nullstiller «valgt forslag»** (som prompten ba om), men forslaget huskes, og
   «Tilbakestill» gir deg hele forslaget tilbake — nå også kabelsettet, ikke bare målene. OK?
5. **Marginen løses også på nytt når du endrer et mål etterpå** (maks CC, dybdemargin, trinnbredde,
   din egen kantavstand) så lenge settet er manuelt. Alternativet var at den bare løses idet du
   bytter kabel, og så blir stående feil etter en CC-endring. Valgt: løses på nytt.
6. **Produktlinja over lista står dobbelt** for én kabel («InSnow 30T 2100W 70m 70m») — den er
   uendret fra før, men blir overflødig nå som lista viser produktet. Skal jeg fjerne den?
7. **Soner er urørt** (prompt 102). Med soner på vises fortsatt det gamle enkeltvalget.
