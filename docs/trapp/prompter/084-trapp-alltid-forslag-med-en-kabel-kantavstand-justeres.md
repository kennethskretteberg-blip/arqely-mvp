# 084 · Trapp: det skal alltid komme et forslag med **én kabel** når behovet er kortere enn den lengste kabelen i katalogen — nærmeste kortere kabel, og kantavstanden trekkes inn til lengden går opp

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Høy** · **Størrelse: liten–middels**
**Kjøres på `main`** (ikke i kabelmotor-worktreen). Linjenumre fra `3b07568` — symbolnavn er fasit.
Spec: `~/Documents/Claude Cowork/Romtegner/Romtegner/spec/spec-trapp-kabelutlegg.md` (Regel 7, 11–13, 15, 18) — Regel 19 er lagt inn der av Cowork, se §5.

---

## Kenneths ord

> «Jeg ønsker at det alltid kommer opp et forslag med 1 stk kabel så lenge beregnet lengdebehov på
> kabel er mindre enn den lengste kabelen i katalogen. I stedet for at det kommer opp et forslag med
> 2 små kabler for å treffe beregnet lengde best, vil jeg heller ha en kabel som er nærmest, gjerne da
> valget som er kortere, og så trekke inn avstand fra kant helt til kabellengden treffer godt.»

Skjermbildet: Trapp 1, 8 trinn, 240 cm bred, utendørs, InSnow 30T 230V.

## Hva som skjer — lest i koden

1. `_generateStairProposals` (:38085) lager **ett** kandidatsett per margin-variant (dine nese/opptrinn
   + 3/3), og hvert sett kommer fra `_stairSolveExactCableSet` (:37950), som bare returnerer **sin
   beste** kombinasjon. Forslag A og B er altså to margin-varianter av *samme* kabelvalg — aldri «1
   kabel» mot «2 kabler».
2. `_stairSolveExactCableSet` prøver alle multisett av 1–3 lengder, forkaster alt som er lengre enn
   behovet (riktig — kan ikke gå under din kantavstand), og **sorterer på minst marginøkning**;
   færrest kabler er bare tiebreak innen 0,5 cm. To små kabler som summerer tett opp til behovet slår
   derfor nesten alltid én kabel som er litt kortere.
3. `maxSaneMargin = min(smaleste bredde/2 − 1, gulvmargin + 15)` (:37984) kaster i tillegg ut
   enkeltkabelen helt hvis gapet ned til nærmeste kortere lengde krever mer enn +15 cm.
4. `_scoreStairProposal` gir +30 for én kabel, men det hjelper ikke når én-kabel-kandidaten aldri
   kommer fram til scoren.
5. **Mulig følgefeil:** `_applyStairProposal` (:38207) skriver den løste marginen inn i
   `stair.edgeMargin_cm`, og `_stairSolveExactCableSet` bruker samme felt som «gulv» (:37959). Neste
   gang forslag regnes, er gulvet altså forrige forslags justerte margin (12,5 i skjermbildet?) — en
   skralle som bare kan gå oppover.

## STEG 0

1. Reproduser på en **duplisert** kopi av Trapp 1: logg `neededAtFloor_cm`, `totalStrands`,
   katalogens InSnow 30T 230V-lengder, alle `candidates` (lens, margin) og hvilken som vant — for
   forslag A og B.
2. Hva er Kenneths egen kantavstand på trappen, og hva står i `stair.edgeMargin_cm` nå? Bekreft eller
   avkreft skrallen i punkt 5.
3. Hvordan påvirker en større sidemargin W/m² i panelet (CC-basert, Regel 16 — skal være uendret) og
   dekket areal/varmet bredde (som blir mindre)?

## Gjør

### 1. Én-kabel-kandidat garantert

I `_stairSolveExactCableSet`, ved fritt søk (ingen `desiredCableCount`, ingen `maxCables:1`-sone):

- `L1` = **lengste katalogkabel ≤ behovet** ved gulvmarginen (samme familie/spenning). Det er «den
  nærmeste, gjerne kortere» Kenneth ber om. En lengre kabel tas **ikke** (den ville krevd mindre
  kantavstand enn gulvet — Regel 12 står).
- Margin = `gulv + (behov − L1) / (2 · strenger)`, snappet til hele mm som i dag (Regel 15),
  restavvik regnet på nytt.
- Grenser for én-kabel-kandidaten (erstatter +15-taket **for denne**):
  - **varmet bredde ≥ 75 %** av smaleste trinn (dvs. margin ≤ 12,5 % av bredden per side; 240 cm →
    30 cm, 120 cm → 15 cm). Over det: ikke foreslått, men forklart (se §3).
  - margin > gulv + 15 cm: foreslås fortsatt, men med gult merke (se §3).
- Returner **begge**: `single` (én kabel, eller `null` med årsak) og `best` (dagens sortering —
  vanligvis flere kabler med minst marginøkning). Behold dagens returfelt for kallere som bare leser
  `best`.

### 2. Forslagene

`_generateStairProposals`:
- **Forslag A = én kabel** (dine nese/opptrinn-marginer) når `single` finnes, merket «Anbefalt».
- **Forslag B = beste flerkabelsett** fra samme margin-variant — men bare hvis det er et *annet*
  kabelsett enn A. Ellers B = 3/3-varianten som i dag.
- Finnes ikke `single`: som i dag (A/B fra margin-variantene).
- `desiredCableCount` (N like kabler, Regel 18) og soner (`maxCables:1`) er **uendret** — der har
  brukeren selv valgt antall.
- `_scoreStairProposal`: ingen trekk for `marginAdjusted` på én-kabel-forslaget (det er selve
  meningen med det).

### 3. Panelet (`showStairProposals`)

- Én-kabel-kortet viser (tallene er bare eksempel): «1 × InSnow 30T 2360W 78,7m · kantavstand 18,4 cm (din: 5 cm) · varmet
  bredde 203 av 240 cm (85 %)». CC og W/m² som før.
- Margin > gulv + 15: gult merke «Stor kantavstand — kabelen er kortere enn behovet».
- Ingen én-kabel-løsning: én grå linje under kortene med grunnen — «1 kabel: InSnow 30T 1850W 61,7m
  ville gitt 34 cm kantavstand (under 75 % varmet bredde)», eller «behovet (128 m) er lengre enn
  lengste kabel (115 m)».

### 4. Gulvet er brukerens, ikke forslagets

- Nytt felt `stair.edgeMarginMin_cm` = det Kenneth taster i kantavstand-feltet (`_setStairEdgeMargin`
  :34538 skriver begge). Mangler det på eldre trapper: bruk `edgeMargin_cm` første gang og lagre.
- `_stairSolveExactCableSet` bruker `edgeMarginMin_cm` som gulv. `_applyStairProposal` skriver
  fortsatt løst margin til `edgeMargin_cm` (utlegget), men **rører ikke** `edgeMarginMin_cm`.
- Badge «din: X cm» leser `edgeMarginMin_cm`.

### 5. Spec

Regel 19 (allerede skrevet i Cowork-spec-en; kopier gjerne til `docs/` hvis trapp-spec skal ligge i repoet): *Når behovet er kortere enn lengste katalogkabel, vises
alltid et forslag med én kabel: lengste kabel som ikke er lengre enn behovet, med sidemarginen økt til
lengden går opp (maks 12,5 % av trinnbredden per side). Flerkabelsett vises som alternativ. Brukerens
egen kantavstand er gulvet og endres aldri av et forslag.*

## Skal IKKE

- Endre CC/strengantall for å få en kabel til å passe (Regel 7 står).
- Foreslå en kabel som er lengre enn behovet.
- Endre N-like-kabler (Regel 18) eller sonedeling.

## Test

1. Trapp 1 (8 trinn, 240 cm): forslag A = 1 kabel med justert kantavstand, B = flerkabelsett. Tall i
   panelet stemmer med utlegget etter «Velg».
2. Velg A, åpne forslag på nytt → samme A (gulvet har ikke krøpet).
3. Smal trapp (100 cm) der nærmeste kortere kabel gir > 12,5 cm per side → ingen én-kabel-kort, grå
   forklaring, flerkabel som før.
4. Lang trapp der behovet > lengste kabel → som i dag + grå linje.
5. «3 like kabler» huket → uendret oppførsel.
6. Soneinndelt trapp → uendret.
7. Utskrift/PDF av en trapp med én-kabel-forslaget: kantavstand og varmet bredde stemmer i tabellen
   (`_stairSoneGeometryBlocks`).
8. Utvid trapp-regresjonstesten (finnes den: `_stairRegressionTest` el.l.) med 1–4.

## Rapport

STEG 0.1–0.3 (tabell med kandidater før/etter for Trapp 1, om skrallen fantes). Skjermbilde av
forslagspanelet. Endringslogg. Commit: «084: trapp — alltid et én-kabel-forslag når behovet er kortere
enn lengste kabel (nærmeste kortere, kantavstand justert, maks 12,5 % per side); brukerens kantavstand
er gulv og endres ikke av forslag».
