# Tak-modul: Research + arkitekturforslag (fase 1 av arbeidsordre)

Status: **Forarbeid ferdig. Ingen kode skrevet. Ingen POC startet. Satt på vent av Kenneth 21.09.2026 — fortsett neste økt fra «gå videre» (start POC per §16.D).**
Dato: 21.09.2026. Svarer på §16 A/B/C i "ARBEIDSORDRE – VARMEPLAN TAK: Research + RoofModel Proof of Concept", per den samme ordrens §17 (analyser → research → presenter → *deretter* implementer).

Alle kilder under er verifisert direkte (Kartverkets egne katalog-API/JSON, Googles egne ToS-tekster, GitHub-repoer, ISPRS/RS-artikler) av tre uavhengige research-agenter — ikke sekundærkilder eller AI-oppsummeringer av oppsummeringer. Der noe IKKE lot seg verifisere er det eksplisitt flagget som usikkert i stedet for gjettet.

---

## 0. Kort, ærlig konklusjon (svarer på §18/§16.G)

**Ideen er ikke død, men den er vesentlig hardere enn planleggingsdokumentet la opp til.** Kortversjonen:

- Adresse→koordinat, bygningspunkt og selve LiDAR-punktskyen er **reelt gratis og fritt for kommersiell bruk** (CC BY 4.0, verifisert direkte fra Kartverkets rå katalog-JSON, ikke fra en nettside-oppsummering).
- Men **"snarveien" finnes ikke**: FKB-Bygning — datasettet som faktisk inneholder ferdige takkant-/mønelinjer — er **bekreftet IKKE åpne data** ("Norge digitalt begrenset", `AccessIsOpendata: False` i Kartverkets egen metadata, koster fra 650–12 500 kr/km² gjennom forhandler). Selv WMS-visning av FKB-Bygning er betalingsbelagt (`<Fees>Norge digital</Fees>` i den rå GetCapabilities-XML-en).
- Det betyr at **all takgeometri må rekonstrueres fra rå, glissen LiDAR-punktsky** (typisk 2 pkt/m², noen steder 5, noen områder eldre enn 10 år eller kun fotogrammetri i fjellet) — ikke leses ferdig fra en vektordatabase.
- Det mest modne åpne rekonstruksjonsverktøyet som finnes (`roofer`/3DBAG, Nederlands nasjonale løsning) **dokumenterer selv at det trenger ~10 pkt/m² for gode resultater** — 2–5× høyere tetthet enn det vi realistisk får i Norge. Det har heller ingen ekte Python-pakke (GPLv3, C++/CGAL, må bygges fra kildekode).
- Det finnes ingen god gratis luftfoto-erstatning: Norge i bilder er betalingsbelagt/Norge digitalt-bundet, Sentinel-2 er 10 m/piksel (ubrukelig på bygningsnivå), og Google Solar API — det eneste alternativet med god nok oppløsning i sitt gratis-nivå — har to reelle, ikke-avklarte lisensfeller (se §1.4).
- **Konklusjon:** Det finnes en reell, lovlig, gratis datavei (adresse → bygningspunkt → fotavtrykk → LiDAR-punktsky → høyderaster), men den krever at VI selv løser geometrisk rekonstruksjon på tynt datagrunnlag — ikke at vi laster ned et ferdig svar. Det er nettopp derfor arbeidsordren ber om en POC før noe annet: dette er akkurat den typen antakelse en ekte test på ekte bygninger kan avkrefte raskt og billig, i stedet for at vi oppdager det etter at et helt produkt er bygget rundt en falsk premiss.

Fortsett til POC (§16.D) er anbefalingen — men gå inn i den med en skeptisk hypotese, ikke en optimistisk. Se §5 for detaljerte svar på de 7 spørsmålene i §16.G.

---

## 1. Research-rapport (§16.A) — datakilder

### 1.1 Norske kjernekilder (Kartverket)

| Kilde | Gratis/åpen? | Lisens (primærkilde) | Auth | Kommersielt brukbart uten avtale? |
|---|---|---|---|---|
| Adresse-API (`ws.geonorge.no/adresser/v1`) | Ja | CC BY 4.0 — bekreftet via rå katalog-JSON (`AccessConstraints: "Åpne data"`) | Nei | Ja — allerede integrert i appen (representasjonspunkt lagres, ubrukt i dag) |
| Matrikkelen – Bygningspunkt (WFS) | Ja | CC BY 4.0 — bekreftet via rå katalog-JSON, `UseLimitations: "Ingen begrensninger"` | Nei | Ja, men gir kun ETT representasjonspunkt per bygning, ikke fotavtrykk |
| INSPIRE bu-core2d WFS (fotavtrykk) | Usikkert/trolig ikke i drift | Utydelig; "limited"/test, ikke i katalogsøk, endepunktet svarte ikke på to forsøk (55s timeout) | Usikkert | Nei — ikke noe å bygge på |
| INSPIRE Buildings WMS (visning) | Nei for kommersiell bruk | **CC BY-NC 4.0** (ikke-kommersiell), bekreftet via rå JSON | Nei | Nei |
| NDH LiDAR-punktsky (`hoydedata.no`) | Stort sett, med unntak | Datasett-metadata: "de fleste prosjekt er åpne, noen er Norge digitalt-begrenset"; generelle vilkår CC BY 4.0 | Nei for åpne prosjekt / Ja (BAAT-innlogging) for lukkede + større uttak | Ja for åpne prosjekt, med reelle dekning/alder-forbehold |
| Høyde DOM1/DTM1 (1m raster, WCS) | Ja | CC BY 4.0, bekreftet via rå JSON | Nei | Ja |
| FKB-Bygning (takkant/mønelinje/taksprang) | **Nei** | "Norge digitalt begrenset", `AccessIsOpendata: False`, WMS også `<Fees>Norge digital</Fees>` | Ja — avtale/forhandler | **Nei** |
| Kartverket topo-WMTS (kartbakgrunn, ikke foto) | Ja | CC BY 4.0, bekreftet via rå katalog-JSON | Nei | Ja, som visningslag — ikke flyfoto |

**Nøkkelfunn utover tabellen:**
- FKB-Bygning-spesifikasjonen er dessuten **kun 2,5D** (linjer med z-verdier), ikke ekte 3D-volumer — selv om vi hadde kjøpt tilgang, må geometrien fortsatt konstrueres/dreneres mot en terrengmodell, ikke bare leses rett av.
- LiDAR-dekningen er ikke ensartet fersk eller tett: noe data er 10+ år gammelt, ~37 000 km² i fjellet er fotogrammetri (lavere høydenøyaktighet enn laser), og noen enkeltprosjekter er avtalebundet selv innenfor "åpne data"-paraplyen.
- Ingen dokumenterte rate-limits funnet for NDH-eksport — dette betyr udokumentert, ikke ubegrenset; bør avklares direkte med Kartverket før høyvolum-automatikk.

### 1.2 Bygningsfotavtrykk (2D-omriss)

- OpenStreetMap har ~4,3 mill. norske bygningsomriss importert fra Matrikkelen (2020–2021), CC BY 4.0-kildedata, men distribueres selv under **ODbL 1.0** — som har en share-alike-klausul for "Derivative Databases" som gjøres offentlig tilgjengelig. Dette er en reell juridisk gråsone (skiller "Produced Works" fra selve databasen) som bør avklares med jurist basert på faktisk arkitektur (lagrer vi rå omriss, eller bare avledet geometri?), ikke noe jeg kan avgjøre her.
- Microsoft/Overture sine ML-genererte fotavtrykk har et dokumentert kvalitetsproblem for Norge (data fra ~2015-bilder, dokumentert i Overtures egen issue-tracker) — MEN Overture prioriterer selv OSM/Kartverket-kilden over ML-dataene for Norge, så i praksis er det stort sett de samme autoritative Matrikkelen-dataene uansett hvilken av de tre man henter fra.
- Uansett kilde: fotavtrykk gir KUN et 2D-omriss — ingen takform, mønelinje, høyde eller helning. Det er kun et utgangspunkt (footprint-as-prior) for rekonstruksjonen, ikke et svar i seg selv.

### 1.3 Ortofoto / satellitt — ingen gratis erstatning finnes

| Kilde | Oppløsning | Kommersielt brukbart? |
|---|---|---|
| Norge i bilder | Høy (luftfoto) | **Nei** uten Norge digitalt-avtale eller kjøp — "lisensierte produkter", eksplisitt utenfor Kartverkets CC BY 4.0 |
| Sentinel-2/Copernicus | 10 m/piksel | Ja, men **ubrukelig** — et hus er ~1 piksel |
| Maxar Open Data | Sub-meter | Nei — CC BY-NC (ikke-kommersielt), kun katastrofehendelser |
| Planet | Sub-meter til 3–5m | Nei — betalt, gratis-nivå er kun tropisk skog/forskning |
| Google Solar API | 0,1–0,25 m der dekket | Se §1.4 — reelle lisensfeller, ikke en enkel "ja" |

### 1.4 Google Solar API — to konkrete, ikke-avklarte fallgruver

Dekning i Norge er bekreftet empirisk (punkt-i-polygon mot Googles egne dekningsfiler): store byer (Oslo, Bergen, Trondheim, Stavanger m.fl.) har HIGH-dekning (0,1 m/piksel), men landlige/nordlige områder (Voss, Røros, Lofoten, Hammerfest, Kirkenes) har **ingen dekning i det hele tatt**. Ikke en "virker overalt"-kilde.

Sitert direkte fra Googles egne vilkår:
- **§20.1 Permitted Use** (Maps Service Specific Terms): API-en er kun lisensiert til "determine feasibility of installing energy systems... design or install an energy system... Downstream Transaction." Om elektrisk *varme*design (ikke solenergi) faller innenfor "energy system" er **udefinert i dokumentet** — dette må avklares direkte med Google, ikke antas.
- **§20.2 Caching**: Rådata fra Solar API må slettes etter 30 dager **med mindre** de er bakt inn i et "fixed media"-sluttprodukt for en konkret transaksjon. En **levende, redigerbar RoofModel-fil** som brukeren åpner på nytt og endrer over tid ligner mer på beholdt kildedata enn et avsluttet sluttdokument — dette taler MOT at unntaket gjelder.

Begge punktene er reelle, sitatbaserte funn — ikke antakelser — og bør avklares skriftlig med Google før noen avhengighet bygges på dem.

### 1.5 Takrekonstruksjon — algoritmer og bibliotek

**Mest modne åpne verktøy (`roofer`/3DBAG, Nederland):**
- Dokumenterer selv **~10 pkt/m²** som forutsetning for gode resultater, pluss forhåndsklassifisering (bakke=klasse 2, bygning=klasse 6).
- **GPLv3**, C++/CGAL/Conan/Nix — ingen reell Python-pakke (kun `rooferpy`-bindings som må bygges fra kildekode, ikke pip-installerbare).
- Konklusjon: egnet som **offline benchmark-fasit** (kjør én gang mot ekte data, sammenlign vår egen løsning mot resultatet) — ikke som kjøretids-avhengighet.

**City3D / PolyFit:** Samme familie (hypotese-og-seleksjon via lineær programmering), også GPLv3, krever CGAL+OpenCV(+Qt)+SCIP/Gurobi. Ikke roof-spesifikt (PolyFit), ingen relevant Python-tilgjengelighet for vårt bruk.

**Faglitteratur om punkttetthet:**
- RoofN3D-datasettet (~4,7 pkt/m², nær vårt forventede nivå) filtrerer bort ~90% av bygningene sine (beholder kun de med 700+ punkter) før man i det hele tatt kjører eksperimenter — et sterkt signal om at mange enkeltbygg rett og slett ikke har nok punkter ved denne tettheten.
- ISPRS Vaihingen-referansebenchmarken rapporterer offisielt kun kvalitetsmål for takflater **over 10 m²** — under den grensen regnes ikke resultatet som pålitelig evaluerbart av dem selv.
- Henn et al. (2013) — modelldrevet/parametrisk tilpasning mot 10 forhåndsdefinerte takarketyper — er trolig den riktige algoritmefamilien for vårt datavolum (300–1000 punkter/bygg), men artikkelen selv er bak betalingsmur og de eksakte tetthets-/nøyaktighetstallene kunne IKKE verifiseres. Dette bør hentes via bibliotektilgang før vi lener oss tungt på den som presedens.

**Bibliotekvalg for en lettvekts Python/FastAPI-tjeneste** (vurdert bibliotek for bibliotek):

| Bibliotek | Anbefaling | Begrunnelse |
|---|---|---|
| `laspy[lazrs]` | **Bruk** | Ren pip-install, ingen systemavhengighet, aktivt vedlikeholdt |
| `shapely>=2.0` / GeoPandas | **Bruk** | Wheels med GEOS bundlet, ingen systemavhengighet |
| `numpy` / `scipy.spatial.cKDTree` | **Bruk — hovedarbeidshest** | SVD-planfitting, k-NN, PCA-normaler — alt vi trenger for parametrisk fitting uten tunge geometri-kjerner |
| PDAL | Kun ved behov | Python-bindings krever separat native PDAL-installasjon (ikke selvstendig wheel) |
| Open3D | Unngå | 100–400 MB wheel for kapasitet numpy/scipy allerede dekker |
| PCL / `pclpy` | Unngå | Python-bindings er reelt forlatt/ustabile |
| CGAL (Python) | Unngå som avhengighet | Egne vedlikeholdere kaller Python-bindingene "eksperimentelle"; GPLv3 |
| GDAL | Kun ved behov | Unødvendig for ren footprint-clipping (Shapely dekker det) |
| PostGIS | Ikke nå | Ikke berettiget for enkeltbygg-på-forespørsel; revurder ved batch-skala |

**Anbefalt kjerne-tilnærming:** Modelldrevet/parametrisk tilpasning (fotavtrykk + noen få takarketyper: saltak, valmtak, pulttak, flatt) tilpasset med robust minste-kvadraters-metode direkte i numpy/scipy — IKKE fri-form plansegmentering (RANSAC/region-growing i klassisk forstand), fordi litteraturen konsekvent viser at fri-form-segmentering blir upålitelig under ~10 m²/noen hundre punkter per flate, og det er nettopp der sekundære takelementer (arker, mindre valmer) havner ved vår punkttetthet.

---

## 2. Arkitekturforslag (§16.B)

### 2.1 Hvorfor egen tjeneste, ikke lumelo-backend

Bekreftet direkte fra `lumelo-backend/CLAUDE.md`: rom-modell-kontrakten der er eksplisitt beskrevet som "hellig", delt mellom Romtegner og en ny lys-app ("Lumelo"), og varme-/domenespesifikke felt skal **eksplisitt ikke** inn i den delte kontrakten ("Varme-spesifikke felt... hører hjemme på Romtegner-siden — ikke i den delte kontrakten"). Samme logikk gjelder tak-geometri — det er en ny, uavhengig domene-modell. Konklusjon: egen tjeneste (arbeidsnavn `varmeplan-roof`), egen repo, egen Fly.io-app. Ikke bygd inn i `lumelo-backend`, ikke i `index.html`.

### 2.2 Lagmodell med eksplisitte grensesnitt

```
Adresse (streng)
   │  AddressResolver.resolve(query: str) -> AddressCandidate[]
   │  (allerede i index.html: ws.geonorge.no/adresser/v1 — ubrukt utover søk i dag)
   ▼
Bygning (koordinat + evt. bygningsnummer)
   │  BuildingResolver.resolve(point: Point2D) -> BuildingCandidate[]
   │  (Matrikkelen Bygningspunkt WFS)
   ▼
Fotavtrykk (2D-polygon)
   │  FootprintProvider.get(building_id | point) -> Footprint | None
   │  (impl: OSM/Overture Kartverket-kilde; fallback: bruker tegner selv i Varmeplan)
   ▼
Høydedata (punktsky + evt. raster)
   │  PointCloudProvider.fetch(bbox: BBox) -> AsyncJob[PointCloud]
   │  HeightRasterProvider.fetch(bbox: BBox) -> Raster
   │  (NDH hoydedata.no REST — asynkron jobb-kø, samme mønster som
   │   _resolveEngineUrl/_engineFetchWithRetry i index.html, men med polling
   │   i stedet for helsesjekk-cache)
   ▼
Takrekonstruksjon (ny kjerne-logikk, varmeplan-roof)
   │  RoofReconstructor.reconstruct(footprint, point_cloud, height_raster)
   │      -> RoofModel  (med Provenance/confidence per faktum, se §3)
   │  Primærmetode: modelldrevet/parametrisk fitting av takarketyper
   │  Sekundær/støtte: RANSAC/region-growing KUN på store hovedflater
   │  Fallback: eksplisitt FAILED-status med begrunnelse — aldri en stille gjetning
   ▼
RoofModel (JSON, se §3)
   │  (fase 2, IKKE del av denne POC-en)
   ▼
RoofHeatingDesign — Varmeplan-side, samme separasjon som eksisterende
"hellig kontrakt"-prinsipp fra lumelo-backend
```

Hver pil er et **pluggbart grensesnitt** — konkret motivert av forskningsresultatet: FootprintProvider kan i dag være OSM-basert og senere byttes til en direkte Kartverket-kilde eller (om Norge digitalt-avtale inngås) FKB-Bygning, uten at RoofReconstructor endres. Det samme gjelder PointCloudProvider (NDH i dag, evt. Google Solar DSM senere hvis lisensspørsmålene i §1.4 avklares positivt) — reconstructor-laget skal aldri vite hvilken kilde dataene kom fra, kun konsumere et standardisert `PointCloud`-objekt.

### 2.3 Teknologivalg for `varmeplan-roof`

Python 3.12, FastAPI (samme mønster som lumelo-backend), Pydantic v2 for all I/O (aldri rå dict), `laspy[lazrs]` + `shapely>=2.0` + `numpy`/`scipy.spatial`. Ingen GDAL/PDAL/CGAL/PCL/Open3D/PostGIS i første omgang (se §1.5-begrunnelse). `roofer` kan installeres separat, KUN i et offline evaluerings-script (aldri i produksjonstjenesten), for å score vår egen løsning mot en ekstern fasit på et lite utvalg bygg.

### 2.4 Produksjonstenkning (§13, kort — ikke overbygd)

- **Caching:** LiDAR-uttak per bygg cachelagres lokalt (jobb-kø-mønsteret fra NDH er tregt — timer, ikke sekunder — så re-fetch per forespørsel er ikke aktuelt). Footprint/bygningspunkt kan cachelagres lenge (endrer seg sjelden). Ingen cache av Google Solar-data uten avklart lisens.
- **Kildeversjonering:** Hver RoofModel lagrer hvilken kilde + tidsstempel dataene ble hentet fra (del av Provenance, se §3) — nødvendig for å kunne re-kjøre rekonstruksjon når en kilde oppdateres.
- **Invalidering:** Ikke løst i POC — dokumenteres som åpent spørsmål for fase 2 (når/om en bygning re-scannes av Kartverket).
- **Prosesseringskostnad:** LiDAR-uttak er asynkront og kan ta minutter–timer per NDH sin egen dokumentasjon — dette er en UX-forutsetning (vi kan ikke love et synkront svar), ikke bare en teknisk detalj.

---

## 3. RoofModel-skjema (§16.C)

Kjerneprinsipp, ufravikelig per arbeidsordrens §12: **ethvert geometrisk faktum bærer sin egen kilde og konfidens.** Ingen felt skal se "sikkert" ut når det egentlig er en modellantakelse.

```python
from enum import Enum
from typing import Literal
from pydantic import BaseModel

class Source(str, Enum):
    MEASURED = "measured"              # fysisk oppmålt (fremtidig, montør)
    USER_CONFIRMED = "user_confirmed"  # bruker har eksplisitt bekreftet et forslag
    USER_DRAWN = "user_drawn"          # bruker har tegnet/rettet manuelt
    FKB = "fkb"                        # FKB-Bygning (krever avtale — se §1.1)
    LIDAR = "lidar"                    # utledet fra NDH-punktsky
    DOM_RASTER = "dom_raster"          # utledet fra DOM1/DTM1-raster
    FOOTPRINT = "footprint"            # kun fra 2D-fotavtrykk (ingen høydedata)
    ESTIMATE = "estimate"              # modellantakelse uten direkte datastøtte
    AI_SUGGESTION = "ai_suggestion"    # sekundær, ALDRI autoritativ (jf. arbeidsordre §forbud)

class Provenance(BaseModel):
    source: Source
    confidence: Literal["high", "medium", "low"]
    note: str | None = None
    by: str | None = None      # bruker-ID hvis USER_CONFIRMED/USER_DRAWN
    at: str | None = None      # ISO-tidsstempel

class Point3D(BaseModel):
    x: float  # meter, lokalt prosjekt-koordinatsystem (IKKE verdens-cm som i index.html)
    y: float
    z: float
    provenance: Provenance

class RoofPlane(BaseModel):
    id: str
    vertices: list[Point3D]       # planpolygon, med egen provenance per punkt
    normal: tuple[float, float, float]
    pitch_deg: float
    azimuth_deg: float
    area_m2: float
    provenance: Provenance        # samlet konfidens for selve planet

EdgeType = Literal["ridge", "hip", "valley", "eave", "rake"]

class RoofEdge(BaseModel):
    id: str
    type: EdgeType
    start: Point3D
    end: Point3D
    adjacent_plane_ids: list[str]
    provenance: Provenance

class RoofFeatureType(str, Enum):
    GUTTER = "gutter"
    DOWNSPOUT = "downspout"
    SNOW_GUARD = "snow_guard"
    ROOF_DRAIN = "roof_drain"

class RoofFeature(BaseModel):
    id: str
    type: RoofFeatureType
    geometry: list[Point3D]
    connects_to: str | None = None   # sporer vannvei, f.eks. gutter -> downspout
    provenance: Provenance

class Obstacle(BaseModel):
    id: str
    kind: str            # f.eks. "chimney", "skylight", "vent"
    footprint: list[Point3D]
    height_m: float | None = None
    provenance: Provenance

class BuildingModel(BaseModel):
    id: str
    address: str
    representasjonspunkt: tuple[float, float]  # UTM/lat-lon, kilde: adresse-API
    footprint: list[Point3D]
    footprint_provenance: Provenance
    eave_height_m: float | None = None

ReconstructionStatus = Literal["ok_high_confidence", "ok_medium_confidence", "failed"]

class RoofModel(BaseModel):
    building: BuildingModel
    planes: list[RoofPlane]
    edges: list[RoofEdge]
    features: list[RoofFeature] = []
    obstacles: list[Obstacle] = []
    status: ReconstructionStatus
    warnings: list[str] = []      # menneskelesbare varsler, aldri stille undertrykt
    source_summary: dict[str, str]  # f.eks. {"point_cloud": "NDH prosjekt X, 2019-04-12"}
```

Sentralt designvalg: `status: "failed"` er en **eksplisitt, gyldig** retur — ikke et unntak/krasj. Når rekonstruksjonen ikke klarer å produsere noe pålitelig, skal tjenesten si det rett ut ("AUTOMATISK REKONSTRUKSJON MISLYKTES — manuell takdefinisjon kreves"), aldri returnere en plausibel-men-feil modell stille. Dette er direkte i tråd med arbeidsordrens §12-krav og med den samme "mål, ikke anta"-filosofien `_foilRegressionTest`s `checkNoOutside` allerede følger i eksisterende kode (punktprøver faktiske posisjoner i stedet for å stole på at en høyere-nivå-funksjon "burde" ha klippet riktig).

---

## 4. Testinfrastruktur (§14, kort merknad)

Eksisterende presedens i `index.html` (`_foilRegressionTest`, linje ~14529) bruker et `check(name, expected, cond, got)`-mønster og validerer ved faktisk punktprøving, ikke antakelse. Samme filosofi bør brukes for en syntetisk takgenerator i POC-en: generer kjente geometrier (saltak 30°/45°, valmtak, L-form, flere høyder/flater), injiser støy/hull i punktskyen, og mål avvik i helning/areal/mønehøyde/flateantall mot fasiten — dette er en ren Python-motsvarighet til det testmønsteret som allerede finnes i appen, ikke en ny oppfinnelse.

---

## 5. Anbefaling — svar på de 7 spørsmålene i §16.G

1. **Er datakvaliteten god nok?** Usikkert/marginalt. Punkttettheten er under det det mest modne åpne verktøyet selv sier trengs for gode resultater, og det finnes ingen gratis takkant-/mønelinjedata. Kun en POC mot ekte bygg kan gi et ærlig svar.
2. **Realistisk suksessrate for et typisk bygg?** Ukjent før POC. Hypotese: enkle sal-/valmtak på større fotavtrykk (>150 m²) mest sannsynlig å lykkes; komplekse/små/flerhøyde tak vesentlig mer usikkert.
3. **Hovedfeilmodus (forventet)?** Sekundære takelementer (arker, mindre valmer) under punkttetthets-grensen; områder med kun gammel/fotogrammetrisk høydedata; bygg i Norge-digitalt-bundne LiDAR-prosjekt; komplekse flerdelte tak uten god fotavtrykk-dekomponering.
4. **Forventet manuell korrigeringsbyrde?** Antatt ikke triviell — UI for manuell overstyring/korrigering bør designes inn fra dag én, i tråd med Provenance-prinsippet, ikke som et senere lappeteppe.
5. **Er FKB+LiDAR beste pipeline?** FKB-Bygning er utelukket (betalingsbelagt), så realiteten er "LiDAR + fotavtrykk + modelldrevet fitting" — ingen bedre gratis pipeline er funnet.
6. **Bør Varmeplan gå videre med automatisk RoofModel?** Anbefaling: gå videre til POC-stadiet (som allerede avgrenset i arbeidsordren), IKKE forplikte til en full modul ennå — datakvalitetsspørsmålet er reelt åpent og kan kun besvares ærlig med testing på ekte bygg.
7. **Hva bør neste fase være?** Bygg den minste ende-til-ende-POC-en som arbeidsordrens §16.D allerede spesifiserer, med modelldrevet fitting som kjernemetode, `roofer` kun som offline fasit-verktøy — ikke kjøretidsavhengighet.

---

## Kilder (utvalg — full liste med URL-er i agent-loggene)

- Kartverket katalog-API (rå JSON): `kartkatalog.geonorge.no/api/getdata/{uuid}` for adresse-API, Bygningspunkt, NDH, DOM1, FKB-Bygning, topo-WMTS
- Kartverket vilkår: kartverket.no/en/api-and-data/terms-of-use, kartverket.no/en/geodataarbeid/geovekst/priskalkulatoren
- `hoydedata.no/laserservices/rest/` (direkte fetch av katalog), `test.hoydedata.no/LaserInnsyn2/help_no`
- OSM Wiki: Import/Catalogue/Norway_Building_Import; Overture Maps buildings guide + issue #458
- Google Cloud: cloud.google.com/maps-platform/terms, .../maps-service-terms (§20), developers.google.com/maps/documentation/solar/coverage (rå GeoJSON, egen punkt-i-polygon-test)
- 3DBAG/roofer: github.com/3DBAG/roofer (docs/data_requirements.md, README/lisens); Peters et al. 2022 (PE&RS 88(3))
- City3D: github.com/tudelft3d/City3D; Huang/Nan et al., Remote Sensing 14(9):2254 (2022)
- PolyFit: github.com/LiangliangNan/PolyFit; Nan & Wonka, ICCV 2017
- RoofN3D: Wichmann et al., ISPRS Archives XLII-2 (2018); ISPRS Vaihingen-benchmark (isprs.org)
- Henn et al. 2013, ISPRS J. Photogramm. Remote Sens. 76:17-29 (paywalled — IKKE fullt verifisert, se §1.5)
