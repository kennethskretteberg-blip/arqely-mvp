# STATUS — prompt-serie «Stedfestet tegneflate» (001–007)

| # | Status | Commit | Repo | Notat |
|---|---|---|---|---|
| 001 | **ferdig** | `50461f7` | varmeplan-roof | skjelett, nøkkel, 9 tester grønne, ruff rent |
| 002 | **ferdig** | `7c5c331` | varmeplan-roof | `/roof/locate`, 21 tester grønne · **INSPIRE er oppe, men dekker ikke Oslo** |
| 003 | ikke startet | | varmeplan-roof | |
| 004 | ikke startet | | varmeplan-roof | |
| 005 | ikke startet | | arqely-mvp | |
| 006 | ikke startet | | arqely-mvp | |
| 007 | ikke startet | | arqely-mvp | |

---

## 002 — `/roof/locate` · commit `7c5c331` · 24.09.2026

**Gjort:** Adresse/lat-lon/east-north → adressepunkt i EPSG:25833 + bygningspunkt fra Matrikkelen
innen 40 m (sortert på avstand, SOSI-koder oversatt til tekst) + omriss fra INSPIRE der det
finnes. Disk-cache, delt httpx-klient, `resolve_footprint()` som eier kilde-kjeden. 21 tester
grønne, ruff rent. Full kildedokumentasjon i `varmeplan-roof/docs/datakilder.md`.

### To funn som endrer premissene i prompten

**1. INSPIRE-WFS er oppe.** Prompten (og research-notatet fra 21.09) sier den ikke svarte — to
timeouts på 55 s. Målt 24.09: GetCapabilities svarer på **0,13–1,2 s**, hver gang. Ingen syntetisk
fixture var nødvendig; alle fixtures er ekte svar.

**2. Men dekningen utelukker Oslo — og det er den viktige nyheten.** GetCapabilities oppgir
WGS84-bbox **9,73–29,07 °Ø / 60,03–70,68 °N**. Oslo ligger på 59,91 °N, altså *under* sørgrensa.

| Adresse | Bygg fra INSPIRE |
|---|---|
| Storgata 1, 0155 Oslo (59,91 °N) | **0** |
| Steinliveien 3, 3518 Hønefoss (60,19 °N) | **20** |

Konsekvenser, i rekkefølge etter hvor mye de betyr:
- **`footprint: null` er normalt, ikke en feil.** Det blir utfallet for en stor del av landets
  befolkning (hele Oslo/Sørlandet/Vestlandet sør for 60 °N) inntil 004 leverer DOM1-omriss.
- **004 sin DOM1-fallback er ikke en reserveløsning — den er hovedveien i Sør-Norge.** Det bør
  prege hvor mye arbeid som legges i den.
- Promptens foreslåtte testadresse (Storgata 1) kan ikke brukes til omriss-testen. Den er i
  stedet den *naturlige* null-fixturen — ekte svar, ikke konstruert.
- E-posten til Kartverket er derfor verdt å sende: finnes en produksjonsvariant med nasjonal
  dekning? Utkast ligger klart i `varmeplan-roof/docs/epost-kartverket-inspire.md`.

### Andre målte funn

- **Adresse-API-felle:** med `utkoordsys=25833` heter feltene fortsatt `lat`/`lon`, men inneholder
  **nord/øst i meter**. Koden leser `epsg`-feltet og tolker deretter — aldri navnene.
- Klienten (`_addrFetch` i index.html) kaller *uten* `utkoordsys` → lagrer EPSG:4258-grader.
  Derfor tar endepunktet imot `{lat, lon}` i grader. Det er veien 005 skal bruke.
- Matrikkel: `typeNames=app:Bygning`, **kun GML** (ingen GeoJSON). `numberReturned` står som `0`
  selv når svaret har features — vi teller elementene selv.
- `bygningstype`/`bygningsstatus` er SOSI-koder (`111`, `TB`), ikke tekst. Oversettelsestabell i
  `matrikkel_wfs.py`; ukjent kode gir «Bygningstype 999» (finnes i ekte Oslo-data), aldri tomt.

### Avvik fra prompten (bevisste)

1. **Testadresse byttet** til Steinliveien 3, Hønefoss for omriss-veien (se over). Storgata 1
   beholdt som null-fixture.
2. **Omriss hentes kun for de 5 nærmeste** kandidatene, ikke alle — ett WFS-kall per kandidat, og
   lista blir lang i tett bebyggelse (Oslo ga 7, Hønefoss 8). De øvrige har `footprint: null`.
3. **Kandidater filtreres til radius**, ikke bare bbox — et kvadrat på ±40 m har hjørner 56 m ute.

**Røyktest (live):** Steinliveien 3 → 8 kandidater, enebolig 105,2 m² / garasje 59,1 m², alle med
INSPIRE-omriss. Storgata 1 → 7 kandidater, 0 omriss, 200. Ugyldig adresse → 404. Cache: 16 ms.

**Tid:** ~45 min.

---

## 001 — Nytt repo `varmeplan-roof` · commit `50461f7` · 24.09.2026

**Gjort:** Kjørbar FastAPI-tjeneste på `~/Code/varmeplan-roof`. `/health`, app-nøkkel
(`X-Varmeplan-Key`) på `roof_router`, CORS, structlog-request-logging, `fly.toml` + `Dockerfile`,
`docs/README.md` + `docs/endringslogg.md`, `scripts/record_fixtures.py` (skall). 9 tester grønne,
`ruff check` rent.

**STEG 0-funn:**
- `uv` 0.11.20 ✓, Python 3.12.13 ✓, port 4100 ledig ✓.
- **Docker finnes ikke på maskinen** → Dockerfile er *uverifisert*. Fly bygger med remote builder,
  så det blokkerer ikke deploy, men det er utestet kode.
- Lumelos CORS-liste inneholder `varmeplan.no` + `www.varmeplan.no` i tillegg til det prompten
  listet. Speilet den faktiske lista, ikke prompten.

**Avvik fra prompten (bevisste):**
1. **Nøkkelen er strengere enn bedt om.** Prompten: «Når `ROOF_DEV=1` **og** nøkkelen er tom →
   slipp gjennom». Implementert nøyaktig sånn — men i tillegg: er en nøkkel SATT, kreves den også
   i dev (ellers tester utvikleren en annen kodesti enn produksjon), og feilkonfigurert produksjon
   (ingen nøkkel, `ROOF_DEV=0`) **stenger** med 401 i stedet for å åpne. Begge tilstander logger
   advarsel ved oppstart.
2. **`/health` gir `{ok, service, version}`** som spesifisert — merk at lumelo gir `{status:"ok"}`.
   Klienten i 005 må kunne skille «tjenesten svarer» fra «noe annet svarer på porten», derfor
   `service`-feltet.
3. **`rasterio` trengte ingen reserveplan.** Prompten ba om å bytte til `tifffile` hvis wheelen
   ikke fantes. `rasterio` 1.5.1 installerte rent på py3.12/macOS-arm64 — ingen systempakker.
   Samme gjelder shapely/pyproj/pillow, derfor **ingen apt-pakker** i Dockerfile (lumelo trenger
   `libgl1` m.fl. kun for ifcopenshell/OpenCASCADE).
4. **`mypy` utelatt.** Lumelo har det; ruff dekker behovet på denne størrelsen. Lett å legge til.
5. Auth-testene monterer en minimal rute med *samme* kobling som `app/main.py`, i stedet for å
   teste en kopi av regelen — 002 arver dekningen når ekte ruter legges på `roof_router`.

**Røyktest (manuell, live):** tjenesten startet på 4100, `/health` svarte
`{"ok":true,"service":"varmeplan-roof","version":"0.1.0"}`, dev-advarselen ble logget, og
request-middlewaren ga `{"method":"GET","path":"/health","status":200,"ms":0.5}`.

**Tid:** ~25 min.

---

## 24.09.2026 — første kjøreforsøk: serien startet IKKE

**Ingen prompter kjørt. Ingen commits. Ingen filer endret utenom denne.**

### Blokkering: prompt-filene finnes ikke

Kjøreinstruksen (000) viser til sju filer som skal kjøres i rekkefølge. Ingen av dem finnes.
Søkt i: arbeidsmappa, hele git-historikken (`--all --diff-filter=A`), alle brancher, untracked
filer, samt `~/Downloads`, `~/Desktop`, `~/Documents` (maxdepth 5).

| Forventet | Status |
|---|---|
| `001-varmeplan-roof-repo.md` … `007-*.md` | **finnes ikke** noe sted |
| `planer/Varmeplan-plan-tak-modul.md` (§19, fase 3a-0) | **finnes ikke**; `planer/` finnes ikke |
| `~/Code/varmeplan-roof` | **finnes ikke** (skal opprettes av 001) |

Eneste eksisterende artefakt fra dette sporet: `docs/tak-modul/research-og-arkitektur.md`
(skrevet 21.09.2026 — datakilder, lisenser, arkitekturforslag, RoofModel-skjema).

### Hvorfor jeg ikke gikk videre

Å kjøre serien uten filene ville betydd å finne på sju detaljerte spesifikasjoner —
endepunkt-former, responsskjemaer, symbolnavn i `index.html`, UI-oppførsel — og så bygge et nytt
repo på dem. Kjøreinstruksen behandler prompt-innholdet som fasit («symbolnavnene er fasit»), så
oppdiktet spec ville gitt mye kode som ser ut som planen, men ikke er den.

Regel 4 («spørsmål stilles ikke — de skrives») gjelder designvalg UNDERVEIS i en prompt. Her
mangler selve inndataene: det finnes ikke noe å utføre. Regel 3 sier at serien skal stoppes når
noe ikke kan fikses innenfor omfanget.

### Hva kjøreinstruksen ALLEREDE låser (gjenbrukbart når filene kommer)

Dette trenger ikke gjentas i promptene — det er allerede bestemt i 000:

- Nytt repo `varmeplan-roof` i `~/Code/`, Python 3.12, FastAPI, `uv`, lokal port **4100**
- Klient: `arqely-mvp/index.html` (prompt 005–007)
- Kartbildet: **ett georeferert PNG per etasje**, installert som vanlig bakgrunn (`S.bgs`) med
  kjent cm-størrelse → ingen kalibrering, ingen kartbibliotek i nettleseren
- Lokalt verdensrom per etasje: (0,0) = utsnittets **sørvestre** hjørne, x mot øst, y positiv
  nedover, nordkant på `y = −heightCm`. Alt i `bg.geo` (prompt 005)
- Lisens: Kartverket CC BY 4.0 → «© Kartverket» i `bg.geo.attribution`, vist i ctxbar og PDF
- Bygningsomriss: INSPIRE-WFS først, OSM (ODbL) kun som merket fallback
- Tester: ingen eksterne kall — fixtures i `tests/fixtures/`, tatt opp av
  `scripts/record_fixtures.py`
- Frontend uten tjeneste skal virke (pen feilmelding, alt annet uendret)

Koordinatkonvensjonen stemmer med kodebasen: `w2s()`/`s2w()` har ingen fortegnsbytte på Y —
verdens Y øker nedover, og `drawBgImage()` tegner med `(originX, originY)` som øvre venstre hjørne.
Samme konvensjon `_installBgImage` allerede bruker (`originY = −heightCm`).

### Kenneth må gjøre

1. **Legg prompt-filene 001–007 et sted jeg kan lese dem** (f.eks. `docs/tak-modul/prompter/`),
   eventuelt lim dem inn i chatten. Blokkerer HELE serien.
2. **`planer/Varmeplan-plan-tak-modul.md`** — samme; 000 viser til §19 og fase 3a-0 som kontekst
   for hvorfor kart-laget gjenbrukes av Tak-modulen.
3. Avklar om `docs/tak-modul/research-og-arkitektur.md` fortsatt er gjeldende grunnlag, eller om
   planen har gått videre siden 21.09. Særlig §1.4 (Google Solar API sine to lisensfeller) og
   §1.1 (FKB-Bygning er ikke åpne data) er fortsatt ubesvarte og påvirker 002–004.

### Åpne spørsmål fra research-dokumentet som fortsatt står

Disse ble dokumentert 21.09 og er ikke besvart — de treffer prompt 002–004 direkte:

- Bygningsomriss via OSM er **ODbL** (share-alike på «Derivative Database»). 000 sier «OSM bare som
  fallback og merket som det — Kenneth avgjør til slutt». Trenger et faktisk svar før 002 lander,
  ellers bygges en datavei som kanskje ikke kan brukes kommersielt.
- INSPIRE bu-core2d WFS svarte **ikke** på to direkte forsøk (55 s timeout) og står ikke i
  Kartverkets eget katalogsøk — «limited dataset for test purpose». Fungerer den ikke i praksis,
  faller 002 tilbake på OSM, og da er ODbL-spørsmålet over blokkerende, ikke teoretisk.
- NDH-LiDAR: noen enkeltprosjekter er Norge digitalt-begrenset, og uttak er **asynkront**
  (jobb-kø, minutter–timer). Det er en UX-forutsetning for 004, ikke bare en teknisk detalj.

### Neste steg

Ingen. Serien står til prompt-filene foreligger. Ingenting er halvferdig — repoet er urørt og
`main` er i sync med `origin/main`.
