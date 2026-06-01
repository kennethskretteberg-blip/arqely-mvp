# Utskrift og Excel-eksport — Design-spek

Sist oppdatert: 2026-05-16
Status: Design-forslag basert på research. Klar for implementering.

---

## Bakgrunn

Eksisterende `exportPDF()` (linje ~25268) og Excel-`exportMaterialliste()` (linje ~28806) fungerer, men er ikke optimalisert for sluttmottakeren: **saksbehandler på kontoret** som videresender tegninger til elektriker på byggeplass.

Saksbehandler trenger oversikt for kvalitetssikring, bestilling og kundekommunikasjon. Elektriker trenger romspesifikke detaljer for installasjon.

## Designprinsipper

Følgende prinsipper er hentet fra profesjonell CAD-/MEP-dokumentasjon og norske
krav til el-installasjonsdokumentasjon (NEK 400 753.514):

- **Hierarkisk struktur**: forside → oversikt → detaljer → materialliste → vedlegg
- **Skanning før detaljer**: oversiktssiden lar mottaker forstå prosjektet på 5 sekunder
- **Én side per rom**: tegning + spec + validering + notater — alt en installatør trenger
- **BOM-format**: gruppert per modultype, unike artikkelnummer, klar for bestilling
- **NEK 400 753.514**-relevante felt på rom-siden: produkt-type, lengde/areal,
  flateeffekt, plassering, effekt, motstand (tom for utfylling)
- **Dokumentasjon for installasjon**: serienummer-felt og motstandsfelt tomme på
  print, fylles ut for hånd av installatør og fotograferes
- **Revisjonskontroll**: forside og footer viser revisjon-nummer for sporbarhet

---

## Foreslått sidestruktur

Total: ~8 sider for et typisk prosjekt (7 rom, 2 etasjer)

| Side | Innhold | Lengde | Status |
|------|---------|--------|--------|
| 1 | Forside | 1 | Eksisterer — forbedres |
| 2 | Innholdsfortegnelse | 1 | Ny |
| 3 | Prosjektoversikt | 1 | Eksisterer — forbedres |
| 4–N | Én side per rom | 1 per rom | Eksisterer — forbedres |
| N+1 | Materialliste | 1–2 | Eksisterer — forbedres |
| N+2 | Garantiskjema | 1 | Ny |

## Side-for-side spek

### Side 1 — Forside

**Layout:**
- Topp: liten "Varmeplan"-tekst i grå (label, ikke logo)
- Midten: stort prosjektnavn (18–20px, accent farge) + 6-felts metadata-tabell:
  - Kunde
  - Adresse
  - Ansvarlig
  - Prosjekt-nr
  - Generert (dato)
  - Revisjon (n, forrige dato)
- Bunn: bare sidenummer

**Forbedring fra eksisterende:**
- Legg til **revisjon-teller** — kritisk for å vite hvilken versjon som er sist sendt
- Strukturert metadata-tabell i stedet for fritekstlinjer
- **Ingen firma-info på forsiden** — dette er et nøytralt Varmeplan-dokument

### Side 2 — Innholdsfortegnelse (NY)

Enkelt listet:
```
1. Forside ............................. 1
2. Prosjektoversikt .................... 3
3. Romdetaljer
   3.1 1. etasje
       Bad ............................. 4
       Kjøkken ......................... 5
       ...
   3.2 2. etasje
       ...
4. Materialliste ....................... 11
5. Garantiskjema ....................... 13
```

Klikkbar (PDF-anchors) hvis jsPDF støtter det.

### Side 3 — Prosjektoversikt

**Top — Metric cards (4 i rad):**
- Totalt areal (m²)
- Installert effekt (W)
- Antall rom
- Antall etasjer

**Per-etasje tabell:**

| Rom | Type | m² | W/m² | W | Status |
|-----|------|----|------|---|--------|
| Bad | Bad | 4,2 | 140 | 588 | ● |
| Kjøkken | Kjøkken | 12,8 | 80 | 1024 | ● |

Status-prikker matcher UX-redesign-planen:
- `●` grønn = ferdig (≥95% av target W/m²)
- `◐` gul = delvis dekket
- `○` grå = ikke startet
- `⚠` rød = har validerings-warning

### Side 4–N — Per rom (kritisk side)

**Layout (top-til-bunn):**

1. **Tittellinje** (8–10% av siden):
   - Venstre: Rom-navn (stor, accent farge), under: etasje · romtype · areal
   - Høyre: Total effekt i rommet + W/m²

2. **Tegning** (45–50% av siden):
   - Bruker eksisterende `_renderRoomToImage()` med `_pdfMode` flag
   - Inkluderer: vegger med tykkelse, hindringer, varmeelementer, soner, mål
   - Liten skalalabel nederst høyre (M 1:25)
   - Start-/slutt-markører for kabel
   - Lett-grå rutenett bak (valgfri toggle)

3. **Spec-tabell venstre + Valideringsstatus høyre** (20%):

   **Spec-tabell:**
   - Type (Folie/Kabel/Matte/Plate)
   - Produkt (navn)
   - Art.nr / El-nr
   - Lengde eller m²
   - CC eller produktbredde
   - Dekket areal (med prosent)
   - Motstand (kald) — **tom for utfylling for hånd**
   - Motstand (varm) — **tom**
   - Isolasjon — **tom**
   - Serienummer — **tom**

   **Validering:**
   - ✓ CC innen min/max
   - ✓ Veggmargin OK
   - ✓ Bøyeradius OK
   - ✓ Sluk-/hindring-avstand OK
   - ✓ Effekt innen anbefalt område

   Status-symboler: ✓ grønn, ⚠ gul, ✕ rød. Generes fra `getStripViolations()` /
   `getCableViolations()` som allerede finnes.

4. **Hindringer + soner** (8%):
   - To-kolonne. Liste over hindringer i rommet med navn og dimensjoner. Liste over
     soner med type og merknad.

5. **Notater** (8%):
   - Boks med lett bakgrunn
   - Hentes fra Dokumentasjonsmodulen (`S.documentation[roomId].notes`) hvis utfylt
   - Plass til termostat-plassering, gulvføler-info, etc.

6. **Footer** (3%):
   - Venstre: Prosjektnavn · rom-navn · rev. N
   - Høyre: Side X av N
   - Ingen firma-info

### Side N+1 — Materialliste

**Layout — gruppert per modultype:**

For hver gruppe (Varmekabel, Varmefolie, Varmematte, Platesystem, Tilbehør):
- Liten gruppe-tittel i accent farge
- Tabell med kolonner:

| Art.nr | El-nr | Produkt | Antall | Watt |
|--------|-------|---------|--------|------|
| CVA-17T-600 | 12345678 | InFloor 17T 600W | 2 stk | 1 200 |

**Tilbehør-gruppe (NY):**
- Termostater
- Følerrør
- Jordfeilbrytere
- Krever ny datakilde — kan starte med hardkodet liste, senere som egen Supabase-tabell

**Nederst:**
- Sum effekt (tykk linje)
- Liten merknad: "Eksporter til Excel for kopiering til bestillingsverktøy"

### Side N+2 — Garantiskjema (NY, valgfri)

Generelt pre-utfylt format for varmekabel-/folie-/matte-dokumentasjon:
- Anleggsinfo (auto-utfylt fra prosjekt)
- Eier (auto-utfylt)
- Per rom: produkt, dato installert, motstand før/etter, isolasjon
- Installatør info (tom, fylles ut for hånd)
- Signaturfelt

Bør være valgbart ved eksport — ikke alle prosjekter trenger det.

---

## Excel-eksport — Forbedringer

### Eksisterende
Ett ark `Materialliste` med 12 kolonner: el_no, article_no, name, family, type, room, qty, area_m2, watt, watt_per_m2, price_list, cost_price.

### Foreslått — Tre ark i samme fil

**Ark 1: `Bestilling`** (NY — det saksbehandler faktisk vil bruke)
| Art.nr | Antall | Produkt |
|--------|--------|---------|
| CVA-17T-600 | 2 | InFloor 17T 600W |

3 kolonner, gruppert per produkt (aggregert). Klar til å kopiere i bestillingsverktøy.

**Ark 2: `Materialliste`** (eksisterende, forbedret)
Beholdes som det er, men:
- Legg til underseksjon-rader (modultype-headers)
- Subtotaler per modultype
- Bedre kolonnebredde

**Ark 3: `Per rom`** (NY — for kvalitetssjekk)
| Rom | Etasje | Type | Areal | Effekt | W/m² | Antall produkter | Validering |
|-----|--------|------|-------|--------|------|-----------------|------------|
| Bad | 1 | Bad | 4,2 | 588 | 140 | 1 | OK |

En linje per rom, for crosscheck.

---

## Implementeringsplan

### Fase A — Refinement av eksisterende PDF (~3–5 timer)
1. Legg til revisjon-teller på forsiden (state: `S.project.revision`, økes ved hver `exportPDF()`)
2. Restrukturer prosjektoversikt med metric cards + status-prikker
3. Forbedre rom-siden: separate spec/validering-paneler, validation status fra eksisterende functions
4. Legg til notater-seksjon fra `S.documentation[roomId].notes`

### Fase B — Innholdsfortegnelse + garantiskjema (~2–3 timer)
1. Generer TOC etter at alle sider er bygd (kan kreve "second pass" eller jsPDF link/anchor API)
2. Garantiskjema-side fra Cenika-mal, pre-utfylt med prosjektdata

### Fase C — Excel-eksport-omarbeiding (~2 timer)
1. Splitt eksisterende `exportMaterialliste()` i tre ark
2. Aggregering for `Bestilling`-arket
3. Subtotaler per gruppe i `Materialliste`-arket

### Fase D — Tilbehør-modul (~3–5 timer, valgfri)
1. Ny Supabase-tabell `accessories` (eller utvid `heating_products` med `is_accessory` flag)
2. Auto-foreslå antall basert på rom-antall (1 termostat per rom + bad ekstra, etc.)
3. UI for å justere antall før eksport

### Total estimert tid
- Minimal forbedring (Fase A + C): **5–7 timer**
- Komplett (alle faser): **10–15 timer**

---

## Tekniske notater

### jsPDF-begrensninger å være obs på
- Ikoner: Bruk tekst-symboler (●◐⚠✓✕) i stedet for SVG/emoji
- Tabeller: jspdf-autotable plugin gjør tabeller mye lettere — vurder å legge til
- Norske tegn: æøå må ha riktig encoding (jsPDF Helvetica støtter det)
- Sidenummer "X av N": jsPDF kjenner totalside-antall først etter siste side — bruk
  `doc.internal.getNumberOfPages()` i et second pass eller late page numbers

### Data-tilgang
Alt eksisterer allerede i `S`:
- `S.project` — kunde, ansvarlig, navn, etc.
- `S.rooms` med areal, navn, romtype
- `S.strips`, `S.cables`, `S.mats`, `S.plates` — varmeelementer
- `S.hindrings`, `S.zones` — hindringer og soner
- `S.documentation[roomId]` — notater, sjekkliste, målinger, signaturer
- `HEATING_PRODUCTS` — produktkatalog med art.nr, el-nr
- `_userOrg` — branding (logo, kontaktinfo)
- `getStripViolations()`, `getCableViolations()` — valideringsstatus

**Manglende:** `S.project.revision` (ny), tilbehør-data (ny).

### Render-strategi for rom-tegning
`_renderRoomToImage()` (linje 25982) bruker hovedcanvas med temporær view +
`_pdfMode` flag for å skjule grid, gizmoer, room cards. Strategien er solid og
bør gjenbrukes som-er. Vurder å justere padding (`padCm = 120` linje 26010) hvis
spec-tabellen nedenfor tegningen tar mer plass.

---

## Hva som ikke er bestemt ennå

1. **Logo-håndtering**: Den eksisterende `_userOrg`-infrastrukturen i koden
   støtter logo og firma-info i PDF. For Varmeplan-formatet skal disse
   feltene være tomme/ignoreres på forsiden og i footer. Eksisterende kode
   som leser `_pName`, `_pAddr`, `_pPhone` etc. på forsiden (linje
   ~25307–25319) skal fjernes.

2. **PDF-eksport-modal**: Nåværende `opts` er hardkodet. Bør det være en modal
   der man velger inkluderte seksjoner, romutvalg, og om garantiskjema
   skal med?

3. **Print-format**: Bare A4 portrait, eller også A3 for store oversikter? H2x
   støtter A1–A4. Sannsynligvis ikke verdt det for målgruppen — A4 dekker 95 %.

4. **Versjonering av PDF-filer**: Skal filnavnet inkludere revisjon? F.eks.
   `Varmeplan-Storgata45-rev2-2026-05-16.pdf`. Anbefales — gjør det enkelt å
   se hvilken som er nyest i nedlastingsmappen.

5. **Tilbehør**: Termostater, følerrør, jordfeilbrytere bør være med i
   materiallisten. Du kjenner sortimentet bedre enn jeg gjør — vi tar det som
   eget steg når implementering starter.

---

## Filer som vil endres

- `romtegner.html` — alle endringer (single-file arkitektur)
  - `exportPDF()` ca. linje 25268 (utvides)
  - `_renderRoomToImage()` ca. linje 25982 (sannsynligvis ingen endringer)
  - `exportMaterialliste()` ca. linje 28806 (omstruktureres)
  - Eventuelt ny `exportGaranti()` for å bygge garanti-siden separat
- Eventuelt: Supabase-migrasjon for `accessories`-tabell hvis Fase D
