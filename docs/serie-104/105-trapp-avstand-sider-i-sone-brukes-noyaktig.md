# 105 · Trapp: «Avstand sider» i en sone brukes nøyaktig når den er tastet. Under 6 cm skjer ingenting i dag. Blir kabelen for kort eller for lang, skal det synes i tegning, panel og PDF

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Gren:** `main` · **Kjøres etter 104.**
**Spec:** ny **Regel 22**, og Regel 11, 12, 15, 19, 20 og 21.

---

## Kenneths ord (20.10.2026)

> «Jeg ser også at det ikke skjer noe endring når jeg reduserer avstand til sider nærmere enn 6 cm. Det bør
> kunne gå. Da skal kabel bli for kort i enden, og det må vises.»

**Avklart med Kenneth:** tallet han taster i en sone **brukes nøyaktig** (låst). **Tomt felt = appen
justerer avstanden selv**, som i dag.

## Hvorfor ingenting skjer i dag (lest i koden)

Feltet i sonepanelet heter «Avstand sider (min)» (`_setStairZoneEdgeMargin`, ≈ :40174) og er et **gulv**
(Regel 12/084). Løseren (`_stairFitFixedSet` / `_stairSolveExactCableSet` via `_stairMarginProbe`)
regner selv ut avstanden som får kabelen til å gå opp, for eksempel 6,3 cm. Et gulv **under** det svaret
endrer ingenting. Det er riktig etter dagens regel, men ikke det Kenneth vil ha. Bekreft i STEG 0.

## STEG 0

1. Bekreft forklaringen over på en duplisert trapp med soner: sett 9, 7, 5 og 3 cm i en sone, og noter
   løst avstand og status.
2. Når kabelen er for kort i dag (manuelt valgt), hvordan tegnes delen som ikke dekkes? Vises den i
   tegningen, eller bare som tekst? Hvordan i PDF?
3. Hvor brukes `zoneSettings[z].edgeMarginMin_cm` (motor, panel, PDF og venstremeny)?

## Gjør

### 1. To tilstander for «Avstand sider» i sonen

- **Tomt felt = auto.** Appen justerer avstanden som i dag, med trappas gulv som minimum. Feltet viser
  løst verdi som grå plassholder («auto: 6,3»).
- **Tall = låst.** Avstanden brukes **nøyaktig** (snappet til hele mm, Regel 15). Løseren endrer den ikke.
  - Feltet merkes som låst (lite hengelås-ikon eller «låst») og har en liten «auto»-knapp som tømmer det.
  - Nytt felt: `zoneSettings[z].edgeMargin_cm`. Det gamle `edgeMarginMin_cm` på sonen migreres slik at
    eksisterende prosjekter oppfører seg som før (gulv). Skriv i rapporten hva du valgte.
- Grense: 1–20 cm som i dag. 75 %-grensen (Regel 19) gjelder **ikke** en låst avstand, fordi brukeren har
  valgt den selv. Varmet bredde under 75 % vises som en gul merknad.

### 2. Kabelen med låst avstand

- **Manuell kabel:** behovet regnes ved den låste avstanden. Avviket vurderes med
  `_stairFitFromLengths`:
  - ≤ 2 % gir «Passer»
  - 2–5 % gir gul
  - > 5 % gir rød
- **Auto-kabel:** velg den kabelen i produktgruppen som er nærmest behovet ved den låste avstanden.
  Foretrekk en kortere kabel (Regel 11: kabelen kan ikke kappes). Vis status med samme terskler.

### 3. Det skal synes

- **For kort:** løpene som ikke dekkes på slutten av sonen, tegnes **stiplet og rødt** i planen og i
  sidevisningen. Panelet sier «Kabelen er X m for kort — Y løp dekkes ikke». PDF-ens trappeside sier det
  samme.
- **For lang:** «X m til overs» i panel og PDF (gul eller rød etter tersklene). Tegningen er uendret.
- Venstremenyens sonerad får ⚠ ved gul eller rød.

### 4. Trapper uten soner

**Uendret.** «Avstand sider» på trappenivå er fortsatt gulvet for Forslag (084). Er det naturlig å bruke
samme låst/auto-modell der også, skriver du forslaget i SPØRSMÅL, men ikke bygg det.

## Skal IKKE

- Endre trapper uten soner.
- Skrive over trappas `edgeMarginMin_cm`.
- Endre strengantall eller CC.
- Pushe.

## Test

1. Sone 2 med manuell kabel. Tast 5 cm: avstanden blir 5,0 cm. Kabelen er for kort, og udekkede løp er
   stiplet rødt. Panelet og PDF-en sier hvor mye.
2. Tøm feltet: auto tar over, og avstanden er som før 105.
3. Tast en avstand som gir for lang kabel: «X m til overs», gul eller rød.
4. Auto-kabel med låst 5 cm: kabelen som er nærmest (kortere) velges, og status er riktig.
5. Et eldre prosjekt med sone-gulv fra 102 åpnes og oppfører seg som før.
6. Angre og gjør om, lagre og åpne på nytt.
7. Utvid `_stairZoneRegressionTest102` (låst, auto og migrering) og kjør alle trapp-batteriene.

## Rapport

STEG 0.1–0.3 · migreringsvalget · skjermbilder: låst 5 cm med rød stiplet slutt, panel og PDF.
Commit: «105: trapp — avstand sider i sone: tomt = auto, tall = låst nøyaktig (Regel 22); for kort kabel tegnes stiplet rødt og står i panel/PDF».
**STOPP** (se 000-KJØR-MEG).
