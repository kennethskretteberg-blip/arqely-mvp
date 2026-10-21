# 118 · Presentasjon: «Endre mål» i forslagslenka. Kunden flytter vegger og hjørner, trykker «Lås mål», og målene følger med i samme svar som «Hva synes du?». Produktene dempes til Kenneth har lagt ut på nytt

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Gren:** `main` · **Kjøres etter 117.**

---

## Kenneths ord (21.10.2026)

> «Jeg lurer på om vi også skulle hatt mulighet til å flytte på veggene i presentasjonen? Det vil være fint om
> man kunne tegne opp rom og legge ut løsning og så sende til kunde. Da kan kunde se over både mål og løsning og
> gi en tilbakemelding. Slik det er nå, så må vi først sende en e-post med spørsmål om mål, så får vi den tilbake
> og legger ut produktene for så å sende presentasjon. Det bør fremkomme at man kan endre mål ved å trykke på
> vegg og flytte den til en av sidene. Bør være knapp: Endre mål — da blir veggene valgbare og kan flyttes. Når
> kunde har flyttet vegger, må hen trykke på "Lås mål". Så kan man fylle inn "hva synes du om" som vanlig og
> velge "send forslag".»

**Avklart med Kenneth:** når kunden flytter en vegg, **dempes produktene** i rommet («Utlegget oppdateres etter at
målene er bekreftet»). Kunden ser aldri et utlegg Kenneth ikke har godkjent. Ingen ny utlegging hos kunden.

## Hva som finnes (lest i koden)

- **Mållenka** (`?kunde=`, modus `'maal'`) har alt **alt** for å endre mål:
  - veggvalg og flytting, og hjørnevalg og flytting (`_kundeVelgHjorne` ≈ :10685, `_kundeFlyttHjorne` ≈ :10700,
    `_kundeRebuildRoomMedHjorner` ≈ :10611)
  - berøring (`_kundeKobleBeroring` ≈ :10837)
  - originalen å regne fra (`_kundeLagreOriginal` ≈ :10262)
  - svaret `_kundeBuildAnswer()` = `{ walls, points, geometryMode, comment, axisBalance }` (≈ :9510)
  - Kenneths side som **arbeider målene inn** (028/033, «innarbeid»)
- **Forslagslenka** (`?present=…&forslag=…`) sender `_forslagPayload()` via `kundelenke_answer` (≈ :8752).
  `p_answer` er fri `jsonb` (`supabase-migration-kundelenke.sql` :122, maks 200 kB), så et ekstra felt krever
  **ingen migrasjon**.
- Kenneths gjennomgang av forslagssvar: 044 «KUNDEFORSLAG HOS CENIKA» (≈ :84420) og kundeforslag v2 (053).

## STEG 0

1. Kan mållenkas maskineri (veggvalg, hjørner, berøring, original, `_kundeBuildAnswer`) kjøres **inne i**
   forslagslenka? Hva antar det om `S` (mållenka bygger en **minimal** `S` uten produkter, ≈ :9070)? List det som
   må gjøres generelt.
2. Hvordan arbeider Kenneths side inn et mål-svar i dag (028/033), og hvordan vises et forslagssvar (044/053)?
   Kan mål-innarbeidingen kalles fra forslagsgjennomgangen uten kopi?
3. Bekreft at `kundelenke_answer` godtar et ekstra felt uten endring, og at størrelsen holder seg godt under
   200 kB for et prosjekt med 15 rom.

## Gjør

### 1. Kundesiden (forslagslenka)

- I panelet (117), seksjonen **«Mål»**: tekst «Stemmer målene? Du kan rette dem.» og knappen **«Endre mål»**.
- «Endre mål» slår på **målmodus** med mållenkas maskineri:
  - veggene og hjørnene blir valgbare
  - en valgt vegg kan **dras til en av sidene** eller få et mål tastet inn
  - et hint ved første vegg: «Dra veggen inn eller ut, eller skriv inn riktig mål»
  - Lag ingen kopi av koden. Trekk den ut til felles funksjoner om nødvendig.
- Rom som er endret, får **dempede produkter** og merket «Utlegget oppdateres etter at målene er bekreftet».
  Effekt og flateeffekt i detaljene merkes som «før endring».
- **«Lås mål»** avslutter målmodus. Veggene er ikke lenger valgbare, og endringene vises som en liste i panelet
  («Stue: vegg 2 400 → 412 cm»). Hver endring har «Angre». **«Endre mål»** kan åpnes igjen.
- **Send forslag** krever at målmodus er låst. Hvis den ikke er det: «Trykk «Lås mål» først».
- Svaret: `_forslagPayload()` + `maal: _kundeBuildAnswer()` når det finnes endringer. Ellers ingen `maal`.

### 2. Kenneths side

- I forslagsgjennomgangen (044/053): har svaret `maal`, vises en egen blokk **«Kunden har rettet målene»** med
  listen over endringer (samme visning som mål-svar i dag) og knappen **«Arbeid inn målene»**. Den kaller den
  **eksisterende** innarbeidingen fra 028/033.
- Etter innarbeiding: rommene med nye mål merkes «Utlegg må oppdateres». Kenneth legger ut på nytt og kan sende
  en ny presentasjon. **Ingen automatisk ny utlegging.**
- Mål-svar og forslags-svar skal kunne behandles hver for seg. Å innarbeide målene skal ikke merke hele svaret
  som ferdig.

### 3. Lage lenka

Når Kenneth lager en forslagslenke, er «Kunden kan rette mål» **på** som standard (en avkrysning i dialogen). Er
den av, vises ikke «Endre mål». Lagres i lenkas `note`/innstillinger uten ny kolonne, med mindre STEG 0 viser at
det er nødvendig. Da skal du stoppe og skrive det.

## Skal IKKE

- La kunden skrive noe annet sted enn `kundelenke_answer`.
- Legge ut produkter på nytt hos kunden.
- Endre mållenka (`?kunde=`) sin egen oppførsel, utover å dele kode.
- Lage nye RPC-er eller migrasjoner uten å stoppe først.
- Pushe.

## Test

1. Kenneth (kopi): tegn to rom, legg ut produkter og lag forslagslenke.
2. Kunde (privat vindu, desktop og 390 px):
   - «Endre mål», flytt en vegg 12 cm og et hjørne
   - produktene i rommet dempes
   - «Lås mål», gjør valg i «Hva synes du?» og trykk Send
3. Kenneth: svaret viser både valg og mål. «Arbeid inn målene» endrer rommet nøyaktig som et mål-svar gjør i dag.
   Rommet merkes «Utlegg må oppdateres».
4. Send uten å låse gir en melding. Send uten målendring gir et svar uten `maal`, som før.
5. En lenke med «Kunden kan rette mål» av viser ingen «Endre mål».
6. `_kundeforslagRegressionTest`, mållenke-batteriene og `_kundelenkeRegressionTest` grønne. Legg til en test
   for forslag + mål i ett svar.

## Rapport

STEG 0.1–0.3 · skjermbilder: kunde i målmodus, låst liste, Kenneths gjennomgang med målblokk ·
endringslogg. Commit: «118: forslagslenke — Endre mål / Lås mål (mållenkas maskineri gjenbrukt), mål følger med i forslagssvaret, Arbeid inn målene hos Kenneth; produkter dempes til nytt utlegg».
**STOPP** og skriv den samlede rapporten.
