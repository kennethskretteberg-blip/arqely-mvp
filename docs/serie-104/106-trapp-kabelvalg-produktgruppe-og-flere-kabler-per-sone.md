# 106 · Trapp: kabelvalget i sonepanelet. Velg først produktgruppe (InSnow 30T 230V / … 400V), så kabel med fullt navn («InSnow 30T 3000W 100m»). Flere kabler i én sone. «Tilbake til auto»

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Gren:** `main` · **Kjøres etter 105.**
**Spec:** Regel 20 og 21 (endres: én **eller flere** kabler per sone), Regel 22.

---

## Kenneths ord (20.10.2026)

> «Når jeg velger en del på trappen så vises et fint panel. Her er det ett valg som heter "Kabel" med
> nedtrekksmeny. Jeg kan velge mellom auto og alle InSnow 30T 230V-variantene. Når man skal endre til en
> kabel manuelt, bør man kunne først velge produktgruppe: InSnow 30T 230V eller InSnow 400V. Så bør listen
> komme opp med "InSnow 30T 3000W 100m". Man kan fint ha et valg for antall kabler også, det kan tenkes at
> vi ønsker flere kabler i en sone. En knapp for "tilbake til auto" er fint.»

## Hva som finnes i dag (lest i koden)

- Sonepanelet (≈ :40680) har ett nedtrekk «Kabel»: «Auto» + `_varOptsFor()`. Det viser bare
  **trappas** familie og spenning (`stair.preferredFamily/Voltage`), med etiketten «100m · 3000W».
- Familie og spenning finnes som liste i panelet for hele trappa (`famVoltKeys`, ≈ :40495).
- `zoneSettings[z].productId` er **én** kabel. Sone-grenen i `generateStairCable` (≈ :43589) kaller
  `_stairAllocateCables(zonePieces, [capacity])` med **én** kapasitet. `_stairAllocateCables` og
  `_stairFitFixedSet` takler allerede flere.
- «↩ Tilbake til auto» finnes (≈ :40690).
- Kabellista fra 101 (trapp uten soner) har rader med etiketten «lengde · W».

## STEG 0

1. Bekreft punktene over. List alle steder som antar **én kabel per sone** (`cables[zi]` = sone `zi`,
   `zoneResults`, panel, venstremeny, PDF Regel 17, `_stairProductRows`, materialliste).
2. Hvilke produktgrupper (familie + spenning) finnes i katalogen for trappekabel? Hvordan ser
   `product.name` ut for dem, er det alltid «InSnow 30T 3000W 100m»-formen?

## Gjør

### 1. Produktgruppe først

I sonepanelet, under «Kabel»:
- **Produktgruppe:** nedtrekk med familie + spenning («InSnow 30T 230V», «InSnow 30T 400V» …). Lista kommer
  fra samme kilde som `famVoltKeys`, uten ny liste. Standard er trappas gruppe. Lagres i
  `zoneSettings[z].preferredFamily/preferredVoltage` (tomt = som trappa).
- Auto i sonen bruker sonens gruppe.

### 2. Kabelliste per sone, med fullt navn og antall

- **«Auto»** (standard) eller **en liste med rader**, samme komponent som kabellista fra 101. Lag ingen
  kopi. Hver rad har K-nummer, farge og kabelvelger med **`product.name`** («InSnow 30T 3000W 100m»), samt ✕.
- **«Antall kabler»** og «＋ Legg til kabel» virker som i 101. Ny rad kopierer siste rads produkt.
- **«↩ Tilbake til auto»** tømmer lista.
- Data: `zoneSettings[z].productIds = [...]`. Eksisterende `productId` migreres til `[productId]`.
- Bytte produktgruppe når lista har rader: radene byttes til nærmeste lengde i den nye gruppen. Finnes
  ingen, går sonen til auto. Skriv valget i SPØRSMÅL.

### 3. Flere kabler i én sone i motoren

- `stair.cables` får én oppføring **per kabel** med `zone` satt. Sonen er ikke lenger lik indeksen. Grupper
  på `zone` overalt der STEG 0.1 fant antakelsen.
- Sone-grenen kaller `_stairAllocateCables(zonePieces, kapasiteter)` med **alle** sonens kabler i
  listerekkefølge, nedenfra og opp (104).
- Sonens margin: `_stairFitFixedSet(subStair, productIds)` når sonen er auto-margin. Med låst margin (105)
  vurderes summen mot behovet ved den låste avstanden.
- Skjøten mellom to kabler i samme sone følger samme regler som i trapp uten soner (Regel 11, eksakt kjede).
- Farger: én farge per kabel. Kablene i samme sone kan ha nyanser av sonens farge, eller egne farger. Velg
  det mest lesbare og skriv det i SPØRSMÅL.

### 4. Det samme i trapp uten soner

Kabellista fra 101 får **samme** produktgruppe-velger og **samme** etikett (`product.name`). Det er én
komponent for begge, så de ikke skiller lag.

### 5. Utskrift og lister

- Panelet for sonen viser hver kabel (lagt m, W) og sonens sum.
- Venstremenyens sonerad viser «2 kabler · 4500 W».
- PDF Regel 17 lister alle kabler i sonen med el.nr og art.nr.
- Materialliste og XLSX går via `_stairProductRows`.

## Skal IKKE

- Endre auto-valget (auto er fortsatt én kabel per sone, `maxCables:1`).
- Tillate ulike produktgrupper **innenfor samme sone** (ulike soner kan ha ulike grupper).
- Endre trapper uten soner utover punkt 4.
- Pushe.

## Test

1. Sone 2: velg «InSnow 30T 400V» (eller det som finnes) og så «InSnow 30T 3000W 100m». Kabelen legges, og
   etiketten vises med fullt navn.
2. Sone 2 med **2 kabler** (ulike lengder): begge legges etter hverandre nedenfra og opp i sonen, og
   sonens sum og status er riktig. Sone 1 og 3 er uendret.
3. «Tilbake til auto»: samme utlegg som før 106 (sammenlign med `zoneResults` fra før).
4. Et eldre prosjekt med `productId` fra 102 åpnes med samme utlegg.
5. PDF og materialliste viser begge kablene i sone 2.
6. Trapp uten soner: produktgruppe og fullt navn i kabellista. Utlegget er uendret.
7. Angre og gjør om, lagre og åpne, kopier og lim inn.
8. Utvid `_stairZoneRegressionTest102` (flere kabler, migrering og gruppe per sone), og kjør alle
   trapp-batteriene. `_cableGeoSuite()` skal være uendret.

## Rapport

STEG 0.1–0.2 · fargevalget · skjermbilder: sonepanel med gruppe og to kabler, tegning og PDF.
Commit: «106: trapp — kabelvalg: produktgruppe først, fullt produktnavn, flere kabler per sone (Regel 21), felles kabelliste med trapp uten soner».
**STOPP** (se 000-KJØR-MEG). Skriv den samlede rapporten.
