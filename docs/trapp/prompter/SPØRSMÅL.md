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
