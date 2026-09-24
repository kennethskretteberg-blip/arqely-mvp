# Varmeplan – ny hovedmodul «Tak»: analyse, arkitektur og trinnvis plan

**Status:** Plan, v1.2 (§19 bakke + klima-fra-posisjon lagt til 23.09) · **Dato:** 21.09.2026 · **Grunnlag:** Kenneths kravdokument «Varmeplan – ny modul: Tak» + kodeanalyse av `arqely-mvp`, `lumelo-backend`, `varmeplan-app` + webresearch på norske datakilder og takrekonstruksjons-verktøy (kilder nederst).
**Ingen kode er endret.** Dette dokumentet er produktretning og arbeidsgrunnlag for prompter til Claude Code.

---

## 0. Svar på hovedspørsmålet

> «Kan vi fra en norsk adresse automatisk generere en tilstrekkelig nøyaktig digital takmodell til at den er nyttig som prosjekteringsgrunnlag for snø- og issmeltingsanlegg i Varmeplan?»

**Ja – for det som betyr mest, og betinget for resten.** Delt i tre:

| Behov | Kan det automatiseres fra åpne data i dag? | Kilde |
|---|---|---|
| **Takrenner og nedløp** (lengde på takkant, gesimshøyde) | **Ja, robust.** Bygningsomriss (2D) + gesimshøyde fra 1 m overflatemodell gir rennelengder på ±0,5 m og høyder på ±0,3–0,5 m. Trenger ingen punktsky. | Matrikkel-bygningspunkt (CC BY 4.0), INSPIRE/OSM-omriss, Høyde DOM1 WCS (CC BY 4.0) |
| **Møner, gradrenner, takflater med helning** | **Ja, med forbehold.** Kartverkets punktsky er åpen (CC BY 4.0) og har 2–5 pkt/m². Det holder for hovedform på vanlige boliger (sal/valm/pult/flatt, ±3° helning), men **flater under ~8–10 m² (arker, kvister) forsvinner** ved 2 pkt/m², og bygningsklassen i punktskyen er opsjonell. Brukeren må kunne korrigere. | hoydedata.no punktsky, FKB-Laser-spek |
| **Kontroll mot flyfoto** | **Nei, ikke med åpne data.** Norge i bilder er lukket for private uten avtale. Erstatning: skyggelagt høydemodell (DOM1) + Kartverkets åpne topokart, evt. brukerens egne bilder. | geonorge.no/nib |

**Det viktigste enkeltfunnet:** den overlegent beste vektorkilden for takgeometri – **FKB-Bygning** med `Mønelinje`, `Takkant` og `Taksprang` i 3D – er **ikke åpne data** (per 19.09.2026: «Norge digitalt begrenset», kjøp via forhandler). Kravdokumentet antar implisitt at FKB kan brukes; det kan det ikke uten avtale. Dette flytter tyngdepunktet til punktsky + egen rekonstruksjon, og gjør et rent **datakilde-adapterlag** (§5) til et krav, ikke et «bør»: den dagen Varmeplan kjøper FKB via Norkart/Geodata, skal takmotoren bare få bedre input.

**Og det andre spørsmålet** («hvor lite må brukeren gjøre manuelt?»): med planen under er målet at brukeren for et vanlig bolighus gjør **tre ting**: bekrefter bygningen på kartet, huker av hvilke takkanter/nedløp som skal varmes, og klikker «Beregn anlegg». Alt annet er korreksjon når automatikken tar feil.

---

## 1. Kortversjon av anbefalingen

1. **Bygg Tak i tre lag** som kravdokumentet sier – men vær nøye med *hvor* de bor: datainnhenting og takrekonstruksjon i Python (ny tjeneste ved siden av `lumelo-backend`), all varmeprosjektering, tegning, PDF og lagring i `index.html` som i dag. Kontrakten mellom dem er én JSON (`RoofModel`, §6).
2. **Ikke bruk `roofer`/City3D som bibliotek** (GPLv3, C++/CGAL-bygg, dokumentert for 10 pkt/m² og påkrevd bygningsklasse). Bygg en **egen lettvekts-pipeline** i Python (`laspy[lazrs]`, numpy/scipy, shapely 2) der **modell-drevet tilpasning** (test sal/valm/pult/flatt mot punktene) er *hovedveien* ved 2 pkt/m², og fri plan-segmentering brukes når tettheten tillater det – og kjør `roofer` i Docker **som benchmark** i POC-en for å vite hva vi gir opp. Grunnen: et 150 m² bolighustak har bare **300–750 laserpunkter** ved 2–5 pkt/m². Det holder til å bestemme takform, helning og møne for enkle tak, ikke til å «oppdage» detaljer.
3. **Snu rekkefølgen på verdi:** takrenne/nedløp (fase 4) trenger bare omriss + høyde, ikke punktsky. Kjør LiDAR-POC-en (fase 2) og en «omriss-først» tak-editor (fase 3a) **parallelt**, slik at den delen av modulen elektrikerne bruker mest kan tas i bruk før takflate-rekonstruksjonen er moden.
4. **Datalogistikk er større jobb enn algoritmen.** Kartverkets punktsky-eksport er asynkron (jobb → e-post/URL, minutter). «Skriv adresse → takmodell på 10 s» krever en egen **tile-cache** (klippede LAZ-biter i objektlager). Planlegg dette som egen leveranse.
5. **Alle geometriske fakta bærer opphav og sikkerhet** (`source`, `confidence`) fra første linje kode – ikke som etterpåklokskap. Dette er også det som gjør «Be om informasjon» (§16 i kravdoket) mulig senere.
6. **Første konkrete jobb for Claude Code:** POC i nytt repo `varmeplan-roof/poc/` (Python) med 12–15 håndplukkede bygg, målt mot FKB-lisensfri fasit (manuell digitalisering + Kenneths kontrollmål). Go/no-go-kriterier i §16.

---

## 2. Hva Varmeplan har i dag som Tak bygger på

Kodeanalysen (linjenumre = `index.html` slik den lå i `~/Code/arqely-mvp` 21.09.2026, siste commit `8ec399e`) viser at mer er forberedt enn forventet:

**Modulsystemet kjenner allerede `roof`.** `MODULE_TYPES` (:2867–2875) har `{ id:'roof', name:'Tak og takrenner', ico:'🏔️', available:false, kind:'room' }` (:2874), og speilregistrene `PROJECT_TYPE_MAP` (:2919), `_MOD_ICON` (:3537), `_PL_TYPE_ICON` (:3545), `_MOD_SHORT` (:45256) og dashboard-flisene `_DASH_PROJ_CARDS` (:56762) har alle `roof`. Å snu `available:true` gir prosjekttype, prosjektliste-ikon og dashboard-flis uten kode. Det som **mangler** er selve innholdet: `_MOD_NAV_ORDER` (:45259), `_moduleEnv` (:3809), `_moduleContext` (:3967 – «når en ny modul legges til, utvides kun dette objektet»), `_enterPart` (:43225), `renderSidebar`-grenen (:34899), `_ctxBarItems` (:42650), topbar `data-modules` (:1819–1856), PDF-seksjoner og feltappens `MODULES`.

**Trapp-modulen er den nærmeste slektningen – ikke snø.** `generateStairCable` (:27696–27857) bygger en **ordnet liste av lineære stykker** (`pieces`: `{kind:'run', len_cm}` og `{kind:'conn', len_cm}` for opptrinn) og `_stairAllocateCables(pieces, capacities_cm)` (:27868) fordeler dem på katalogkabler etter meter, med skjøt midt i et stykke og rest udekket. Det er nøyaktig modellen for «takrenne 18 m × 2 løp + nedløp 6 m × 1 løp» fordelt på standardlengder. Trappa er også presedens for et objekt som **ikke er et rom** (egen `S.stairs[]`, `partId`, ingen `floorId`, egen «side»-visning `_drawStairSide` :24871).

**Snø-modulen gir klima og effekt.** `SNOW_IEC`, `_snowSurfaceLoad`, `_snowDeriveFromWeather` og Supabase-tabellen `weather_by_postcode` (`design_temp_c`, `design_wind_ms`, `altitude_m`; :3003–3333) er direkte gjenbrukbare for takflate-W/m². Snø-grenen i `_moduleContext` (:3967; kommentaren :3925 sier «når en ny modul legges til, utvides kun dette objektet») har verdiene taket trenger (450 W/m² maks, 30 cm maks CC) – men `roof` faller i dag til innendørs-grenen (`_moduleEnv` :3809), så en egen roof-gren må legges til.

**Frostsikring gir produktmodellen for selvbegrensende kabel.** `_ensureFrostProtectionProducts` (:58088) med `frost_kind:'ready'|'metervare'`, `_frostSuggestCable` (:2966–2981) og særlig `_frostResolveProduct` (:2982: «nærmeste ferdiglengde ≥ behov, ellers metervare») er riktig valglogikk for renne/nedløp. **Ingen takrenne-kategori finnes** i produktdata i dag (grep `takrenne|gutter` gir bare UI-etiketter).

**Kabelmotorene for flater.** `_skEngineCore(room, holes, CC, margin, angleDeg)` (:18180) tar i praksis en rå punktliste (kalles slik på :18259) og en vinkel – den eneste motoren som ikke slår opp `S.rooms` selv, og derfor perfekt for en takflate i planprojeksjon. `selectCableByPower`/`selectMultiCables`/`_buildNCableZones` (:19566, :19659, :20183) gir produktvalg og N-deling, **men er rom-bundne** (tar `roomId`) – for takflater må de enten få en areal-variant eller kalles via et syntetisk rom (se §14). `labelOnly`-kabel (`_placeCableLabelOnly` :13036) gir «produkt + lengde + antall uten tegning» – en trygg v0.

**Lagring og ny objekttype.** F4a-mønsteret for fri folie (egen liste i `S`, `_buildSaveData` :45323, `_restoreProject` :45529, `pushUndo` :38587, tegning :4393, hit-test :41758, sidebar :35345, `ROOM_PRODUCT_KEYS` :34590) er sjekklisten for alle nye takobjekter. Prosjektet lagres som én JSON-blob i `romtegner_projects.data`; feltappen leser `data.rooms[]` – takobjekter uten `roomId` er usynlige for den i dag.

**Geodata i dag: kun adresse.** Kartverkets adresse-API (`ws.geonorge.no/adresser/v1/sok`, :52239) lagrer `S.project.address.representasjonspunkt` (:52271). Ingen kartflis, ingen WMS, ingen EPSG-håndtering, ingen leaflet/openlayers. Bakgrunnsbilder er PDF/raster med manuell kalibrering (`confirmBgCalibrate` :34372, `confirmFixedScale` :34429).

**lumelo-backend** er FastAPI + shapely 2 + ezdxf + PyMuPDF på Fly.io (1 GB, scale-to-zero, region `arn`), kalles uten auth fra `index.html` med kaldstart-retry (`_engineFetchWithRetry` :44122). Kontrakten er «hellig» og varme-spesifikke felt skal holdes ute (lumelo `CLAUDE.md`:51–58). Store nye avhengigheter krever Kenneths ja (:95–98).

**Testmønster.** `_foilRegressionTest` (:14529), `_cableSkewRegressionTest` (:20410) m.fl.: hardkodede syntetiske rom, `check(name, expected, cond, got)`, kjøres fra konsollen. Regresjonstilfeller er kode, ikke datafiler.

---

## 3. Datakilder – hva som faktisk kan brukes (verifisert september 2026)

| Kilde | Gir | Lisens | Maskinell tilgang | Sanntid? | Dom |
|---|---|---|---|---|---|
| **Adresse-API** `ws.geonorge.no/adresser/v1` | adresse → punkt (lat/lon), gnr/bnr | gratis, ingen auth (CC BY 4.0 antatt) | REST | ja | **Bruk** – finnes alt i appen |
| **Matrikkelen – Bygningspunkt** | bygningsnr, type, status, punkt | CC BY 4.0 | WFS `wfs.geonorge.no/skwms1/wfs.matrikkelen-bygningspunkt` | ja | **Bruk** for å identifisere bygget. Ingen etasjer. |
| **Bygningsomriss 2D** | fotavtrykk | (a) INSPIRE Buildings core2D WFS – «limited test», status uklar; (b) OSM 4,3 mill. Kartverket-importerte omriss – ODbL | WFS / Overpass | ja | **Bruk (a) hvis Kartverket bekrefter; ellers (b)** med ODbL-vurdering (§14) |
| **Høyde DOM1 / DTM1** (1 m raster) | takhøyde, terreng, grov takform | CC BY 4.0 | WCS `wcs.geonorge.no/skwms1/wcs.hoyde-dom-nhm-25833` (finnes også for 25832) | ja (synkront) | **Bruk** for gesimshøyde, «har bygget skråtak?», skyggelagt bakgrunn |
| **Punktsky NDH** (LAZ, 2–5 pkt/m²; 2 pkt/m² «FKB-Laser-C» var standardbestilling i NDH) | takflater, møner, gradrenner | CC BY 4.0 via Kartverkets generelle vilkår for gratisprodukter (eksport uten pålogging = gratis; noen prosjekter lukket) | REST `hoydedata.no/laserservices/rest/startExport.ashx` + `exportStatus.ashx` – **asynkron**, polygon-klipp | **kun med mellomlagring** | **Bruk** – kjernen i fase 2. Klasse 6 (bygning) er *opsjonell* i FKB-Laser → fallback nødvendig |
| **FKB-Bygning** (Takkant, Mønelinje, Taksprang m/ z) | beste 2,5D-takmodell | **Norge digitalt-begrenset**; kjøp via forhandler (priskalkulatoren antyder ca. 12 500 kr/km² tettsted, 650 kr/km² utenfor + påslag – **kontroller**) | nedlasting med GeoID/avtale; WMS åpen kun for *visning* | nei uten avtale | **Ikke i v1.** Design adapteret slik at det kan kobles på. Be om pristilbud fra Norkart/Geodata på «Bygning API» som fase-6-alternativ. |
| **Norge i bilder** (ortofoto) | flyfoto 25 cm | Norge digitalt / kjøp; token-styrt WMS | nei | nei | **Ikke tilgjengelig.** Erstatt med DOM1-hillshade + topokart. |
| **Kartverket topo WMTS** `cache.kartverket.no` | bakgrunnskart | CC BY 4.0 | WMTS | ja | **Bruk** som kartbakgrunn |
| **Google Solar API** | taksegmenter (helning, asimut, areal, høyde), Norge dekket i MEDIUM (≈25 cm DSM) | Google Maps Platform: policies forbyr caching/lagring («content pre-fetching, caching, or storage is generally restricted»); Maps Platform Terms §3.2.3 «No Use With Non-Google Maps» krever Google-kart ved kartvisning | REST, $10/1000 | ja | **Ikke som datakilde** (kan ikke lagres i prosjektet). Evt. som *manuell sammenligning* i POC. |
| **Matrikkel-API / Bygningspunkt utvidet** (etasjer, BRA) | antall etasjer | søknad/avtale | API | etter avtale | Fase 6-kandidat for nedløpshøyde-fallback; **ikke kritisk** (DOM1 gir høyde direkte) |
| Overture / Microsoft-omriss | 2D | åpen | – | – | Dårlig kvalitet i Norge (2015-data, feilklassifisering). Ikke bruk. |
| Norkart 3D Kart API / Bygning API, norgei3d.no | FKB-avledet 3D | kommersiell | API | ja | Sannsynlig vei til FKB-kvalitet senere. Pris må hentes. |

**Konsekvenser for arkitekturen:**
- Ortofoto-kravet i §5/§7 i kravdoket («visualiser oppå ortofoto») kan ikke innfris med åpne data. Planen bruker **DOM1 som hillshade** (skyggelagt høyderaster) – der ser man faktisk møner og takflater – pluss topokartet. Det er også lisensmessig rent å lagre i prosjektet.
- Punktsky-eksporten er en *jobb*, ikke et oppslag. Første gang noen ber om et område tar det minutter; Varmeplan må vise «Henter laserdata … (2–5 min)» og lagre resultatet i en cache som neste bruker i samme område drar nytte av (§13).
- Kobling adresse → bygning må gjøres geografisk (punkt-i-polygon / nærmeste bygningspunkt); adresse-API-et gir ikke bygningsnummer.

---

## 4. Der jeg utfordrer kravdokumentet

1. **«Ambisjonen er ikke en enkel kalkulator»** – enig som mål, men **den enkle kalkulatoren er det elektrikeren trenger 80 % av tiden** (renne + nedløp), og den trenger *ikke* takrekonstruksjon. Anbefaling: bygg tak-editoren «omriss-først» (fase 3a) parallelt med LiDAR-POC-en, så modulen får verdi før POC-en er konkludert. LiDAR-resultatet kobles på som «forslag» når det er klart.
2. **Ortofoto** kan ikke brukes (§3). DOM1-hillshade er en fullgod erstatning for *geometrikontroll* (man ser møner tydelig), men ikke for «se om det er snøfanger». Snøfanger må uansett bekreftes av bruker/montør – kravdoket sier allerede «snøfanger: ikke funnet».
3. **«FKB kan gi mønelinjer»** – ja, men ikke uten kjøp. Dette bør avklares kommersielt tidlig (fase 1): hva koster Norkart «Bygning API» per oppslag? Hvis prisen er lav per bygg, kan det være billigere enn å modne egen LiDAR-rekonstruksjon på komplekse tak. POC-en bør derfor måle *egen pipeline mot FKB-fasit* for noen bygg der Kenneth kan skaffe FKB-utsnitt lovlig (f.eks. via en kommune eller en forhandlers testtilgang).
4. **3D (§13)** – utsett helt til fase 8, men **bygg datamodellen 3D fra dag én** (alle hjørner har z). En enkel «sidevisning»/isometri kan lages med samme canvas-motor (trappa gjør det alt). Ikke WebGL i første omgang.
5. **«Vannveien som system» (§11)** – riktig, og billig hvis `RoofEdge`/`Gutter`/`Downspout` har `connectsTo`-felter fra starten. Selve analysen («flytter du fryseproblemet?») er fase 6+.
6. **Google Solar API** ser fristende ut (ferdige taksegmenter for Norge), men vilkårene forbyr lagring og krever Google-kart. Det passer ikke en prosjekteringsfil som skal leve i årevis. Ikke bygg på den.
7. **«Tusenvis av brukere»** – realistisk volum for Varmeplan er titalls bygg per dag, ikke tusenvis per time. Dimensjoner for det (én liten VM + objektlager), men bygg cache-nøklene slik at det skalerer.

---

## 5. Arkitektur

```
┌──────────────────────────────────────────────────────────────────────────┐
│ index.html (Varmeplan web)                                                │
│  Tak-modul: kart/bakgrunn · RoofModel-editor (2D) · RoofHeatingDesign     │
│  (renner/nedløp/gradrenner/flater → kabel, soner, produkter) · PDF        │
│  Lagres i S.roof{} → romtegner_projects.data (som i dag)                  │
└───────────────▲──────────────────────────────────────────────────────────┘
                │ JSON: RoofModel (meter, lokalt origo, z på alt, provenance)
┌───────────────┴──────────────────────────────────────────────────────────┐
│ roof-service (Python/FastAPI) — eget endepunkt-sett /roof/*               │
│  1. BuildingLocator   adresse → punkt → bygningspunkt → omriss             │
│  2. DataFetchers      DOM1/DTM1 WCS · punktsky-jobb (startExport) · cache  │
│  3. RoofReconstructor punktsky+omriss → planer, kanter, høyder, confidence │
│  4. Fallbacks         omriss+DOM1 → «flatt/skrå + gesimshøyde»             │
└───────────────▲──────────────────────────────────────────────────────────┘
                │ adaptere (byttbare)
   Kartverket adresse · Matrikkel WFS · INSPIRE/OSM omriss · WCS DOM/DTM ·
   hoydedata.no eksport · [senere: FKB via forhandler · Norkart Bygning API]
```

**Hvorfor Python for lag 2, og hvor:**
- Punktsky (LAZ), raster (WCS/GeoTIFF) og plan-segmentering er Python-territorium (`laspy[lazrs]`, `numpy`, `scipy`, `shapely`, `rasterio`). Ingenting av dette hører hjemme i en 3,4 MB `index.html`.
- **Egen tjeneste, eget repo – besluttet nå, ikke etter POC.** Nytt repo `varmeplan-roof` (Python 3.12, FastAPI, `uv`), egen Fly-app `varmeplan-roof`. POC-koden ligger i samme repo under `poc/` og vokser inn i `app/`. Grunn: lumelo sin kontrakt er hellig og varmefri (lumelo `CLAUDE.md`:51–58), store deps krever godkjenning, og punktsky-jobber trenger en **ventekø** (jobbene kjøres én og én i bakgrunnen) som lumelo ikke har. Klienten gjenbruker mønsteret fra lumelo (`_resolveEngineUrl`, `_engineFetchWithRetry`) med ny base-URL. Roof-service får **app-nøkkel** fra dag én (lumelo har ingen).
- **Alt om varme blir i frontend**: regler, produktvalg, soner, tegning, PDF, undo, lagring. Hele økosystemet (feltapp, materialliste, garantibevis) forventer sannheten i `S`.

**Hvorfor JSON-kontrakten er poenget:** samme `RoofModel` skal kunne komme fra (a) punktsky-rekonstruksjon, (b) omriss + DOM1, (c) FKB via forhandler, (d) manuell tegning i editoren, (e) DXF/PDF-takplan via lumelo. Takmotoren i frontend bryr seg ikke om hvilken.

---

## 6. Datamodell

*I klartekst:* tre «skjemaer». **BuildingModel** = huset (hvor det står, omrisset, høyder). **RoofModel** = taket (flater, linjer mellom flatene, renner/nedløp/snøfangere som egne ting med mening). **RoofHeatingDesign** = hva vi vil varme og hva Varmeplan regnet ut. Hvert tall som kan være usikkert bærer med seg *hvor det kom fra* og *hvor sikkert det er*.

Alle koordinater i **meter**, lokalt origo (bygningens omriss-sentroide) for å unngå flyttallsproblemer på canvas; `origin` bærer EPSG:25833-koordinat + `ground_z`. Alle hjørner har z (høyde). Alle felt som er *utledet* har `source` og `confidence`. Kodeblokkene under er for Claude Code; prosaen over hver er for lesing.

### 6.1 Provenance (felles for alle tre modeller) – «hvor kom tallet fra?»

```ts
type Source = 'MEASURED'        // brukeren/montøren har målt
            | 'USER_CONFIRMED'  // brukeren har sett og godkjent
            | 'USER_DRAWN'      // tegnet manuelt
            | 'FKB'             // offentlig vektordata
            | 'LIDAR'           // rekonstruert fra punktsky
            | 'DOM_RASTER'      // fra 1 m høyderaster
            | 'FOOTPRINT'       // fra bygningsomriss
            | 'ESTIMATE'        // regel/standardverdi (f.eks. etasjer × 2,8 m)
            | 'AI_SUGGESTION';  // tolkning/forslag (aldri autoritativ)
type Provenance = { source: Source; confidence: number /*0–1*/; note?: string;
                    by?: string; at?: string /*ISO*/ };
```

### 6.2 BuildingModel

```ts
interface BuildingModel {
  id: string;                      // uuid
  bygningsnr?: string;             // matrikkel
  address?: { text: string; representasjonspunkt: [lon, lat] };
  origin: { epsg: 25833; x: number; y: number; ground_z: number; prov: Provenance };
  footprint: { polygon: [x,y][]; prov: Provenance };          // vegglinje i 2D
  roofprint?: { polygon: [x,y][]; prov: Provenance };         // takutstikk hvis kjent
  heights: { eave_m?: Meas; ridge_m?: Meas; floors?: Meas };  // Meas = {value, prov}
  terrain: { dtm_z_at_corners?: number[]; prov: Provenance };
  roof: RoofModel;
  quality: { lidar_density_pt_m2?: number; has_class6?: boolean;
             nodata_frac?: number; reconstruction_rmse_m?: number };
}
```

### 6.3 RoofModel – «taket»

En takflate er et polygon med helning og retning. En kant er en linje av en bestemt *type* (møne, grat, gradrenne, takkant, gavlkant, taksprang). Renner, nedløp og snøfangere er egne objekter som *ligger på* en kant og *kobles til* hverandre (renne → nedløp), så vannveien kan følges senere.

```ts
interface RoofModel {
  planes: RoofSurface[];       // takflater
  edges: RoofEdge[];           // typede linjer
  nodes: RoofNode[];           // hjørner (delt av kanter/flater)
  obstacles: RoofObstacle[];   // piper, takvinduer, sluk – v1: kun manuelt
  features: RoofFeature[];     // Gutter, Downspout, SnowGuard, RoofDrain — semantiske
  roof_type: 'flat'|'shed'|'gable'|'hip'|'complex'|'unknown';
  prov: Provenance;
}
interface RoofSurface { id; polygon: [x,y,z][]; normal: [nx,ny,nz];
  slope_deg: number; azimuth_deg: number; area_m2: number; true_area_m2: number;
  n_points?: number; rmse_m?: number; prov: Provenance }
type EdgeType = 'ridge'|'hip'|'valley'|'eave'|'rake'|'step'|'wall';
interface RoofEdge { id; type: EdgeType; a: [x,y,z]; b: [x,y,z];
  length_m: number; planes: string[]; prov: Provenance }
interface RoofFeature {
  id; type: 'GUTTER'|'DOWNSPOUT'|'VALLEY_GUTTER'|'SNOW_GUARD'|'ROOF_DRAIN';
  geometry: { kind:'polyline'; pts:[x,y,z][] } | { kind:'point'; pt:[x,y,z]; height_m: Meas };
  on_edge?: string;                 // GUTTER ligger på en 'eave'-kant
  connects_to?: string[];           // §11 vannvei: GUTTER → DOWNSPOUT → outlet
  width_mm?: Meas;                  // renne-/nedløpsdimensjon
  prov: Provenance }
```

### 6.4 RoofHeatingDesign (kun frontend, lagres i `S.roof.design`) – «varmen»

Lista over hva brukeren har merket for varme (renne X, nedløp Y, takområde Z) pluss resultatet: en ordnet rekke av kabelstrekk (samme idé som trappa), hvilke katalogkabler som dekker dem, soner, totaler og advarsler.

```ts
interface RoofHeatingDesign {
  building_id: string;
  climate: { design_temp_c; design_wind_ms; altitude_m; usage: 'normal'|'exposed'; prov };
  items: HeatingItem[];          // hva som skal varmes
  rules_version: string;         // hvilken regelsett-versjon som ga tallene
  result?: DesignResult;
}
type HeatingItem =
  | { kind:'GUTTER';   feature_id; length_m; runs: number; w_per_m_target?: number; overrides? }
  | { kind:'DOWNSPOUT'; feature_id; height_m: Meas; runs: number; overrides? }
  | { kind:'VALLEY';   edge_id; length_m; runs: number; overrides? }
  | { kind:'ROOF_AREA'; polygon:[x,y][]; plane_id; area_m2; true_area_m2; slope_deg;
      wm2_target: number; overrides? };
interface DesignResult {
  pieces: Piece[];               // ordnet liste av lineære strekk (trappe-modellen)
  cables: CableAssignment[];     // produkt, lengde, hvilke pieces, sone
  zones: Zone[];                 // {id, name, cable_ids, total_w, current_a?}
  totals: { cable_m; installed_w; per_zone };
  warnings: Warning[];           // «nedløp lengre enn kabelens maks», «renne 2 løp anbefalt»
}
```

**Designvalg:**
- `RoofFeature` er semantiske objekter (§9 i kravdoket) med `connects_to` (§11) fra dag én.
- `true_area_m2` = planareal / cos(helning). Kabelmotoren kjører i planprojeksjon og skalerer lengder langs fallretningen.
- `overrides` er der brukeren slår av regler («1 løp selv om renna er bred»); regelmotoren logger at det er overstyrt.
- `Meas = {value, prov}` overalt der noe *kan* være estimert (høyder, bredder).

---

## 7. API-kontrakt (roof-service)

```
POST /roof/locate            { address } | { lon, lat }
  → { candidates: [{ bygningsnr, footprint, center, type, source }] }        (synkront, <2 s)

POST /roof/model             { bygningsnr | footprint, level: 'quick'|'full' }
  level=quick → synkront: omriss + DOM1/DTM1 → RoofModel med planes=[] eller ett flatt/skrått plan,
                eave_m fra DOM1-median langs kanten, roof_type fra DOM1-varians. (mål < 5 s –
                avhenger av svartid hos WFS/WCS, må måles i POC)
  level=full  → { job_id, status:'queued', eta_s } — punktsky hentes/klippes (cache-treff: sekunder,
                miss: minutter via hoydedata.no-eksport), rekonstruksjon kjøres, resultat lagres.
GET  /roof/model/{job_id}    → { status:'queued'|'fetching'|'reconstructing'|'done'|'failed',
                                progress, model?: BuildingModel, diagnostics? }
GET  /roof/background        ?bbox&layer=dom_hillshade|topo → PNG (proxy/cache av WCS/WMTS med attribusjon)
POST /roof/reconstruct       { points: base64-LAZ | url, footprint }   (kun POC/test)
```

- Laserjobber i en enkel ventekø (én tabell i Postgres/Supabase + én arbeidsprosess på Fly som tar neste jobb). Ingen Celery/Redis i første omgang.
- Alle svar bærer `attribution: ['© Kartverket (CC BY 4.0)']` – lisensen krever kreditering; PDF-en skal skrive det.
- Ingen auth i dag på lumelo; roof-service **må** ha minst en app-nøkkel, siden den henter data på vegne av bruker og har cache/kostnad.

---

## 8. Takrekonstruksjon – valgt tilnærming

**Beslutning: egen pipeline (b), `roofer` som benchmark.** Begrunnelse fra research: `roofer` er GPLv3, bygges fra kilde (Conan/Nix + CMake + CGAL 6; dev-oppsett krever Python ≥3.13; pip-pakke ikke verifisert), dokumentert for ~10 pkt/m² med *påkrevd* klasse 2+6 – norske data er 2–5 pkt/m² og klasse 6 er opsjonell. Den gir dessuten bare flater, ikke typede linjer; linjetyping må vi gjøre uansett. Regnejobben per hus er liten: et bolighus med 1,5 m buffer gir ~500–1 000 punkter → under 1 s i Python. Det er *få* punkter, og det er hele poenget: med 300 punkter på et tak er det tryggere å **teste kjente takformer mot punktene** enn å la punktene «finne» formen selv.

*Ekstern bekreftelse (LinkedIn, sept. 2026):* Thomas Heggestads 3D-Bergen bruker nettopp
«flat extrusions with measured heights» fra Kartverkets høydemodell og etterlyser takgeometri; en
nederlandsk kommentator peker på at Nederland løser det per bygning fra nasjonal LiDAR (= 3D BAG /
`roofer`), ikke fra en ferdig bymodell. Det er samme vei som planen her – med den forskjellen at
norsk punktsky er 2–5 pkt/m² mot nederlandske ~10, derav den parametriske hovedveien under.

*I klartekst:* laseren gir oss en sky av høydemålinger over huset. Vi ser etter grupper av punkter som ligger i samme skrå flate (en takside), regner ut hvor flatene møtes (møne = toppen, gradrenne = innvendig hjørne), og klipper det hele mot husets omriss. Der det er for få punkter, prøver vi de vanlige takformene én etter én og velger den som passer best.

**Pipeline (per bygning):**
1. **Klipp:** punkter i `footprint.buffer(1,5 m)`. Klasse 6 hvis finnes; ellers alle punkter med z > DTM + 2 m og klasse ∉ {2, 7, 9}. Bakke = klasse 2 i 2–5 m ring (gesims).
2. **Rens:** normaler via PCA (k=10–15, `cKDTree`); forkast |n_z| < 0,2 (vegg), høy lokal ruhet (vegetasjon), punkter > 0,5 m over lokal medianflate.
3. **Plan-segmentering** («finn flate grupper som peker samme vei»): region growing på normaler (vinkel < 10–15°, ortogonal avstand < ε). ε skaleres til Kartverkets nøyaktighet (0,03–0,07 m std) + takstein-ruhet → **0,15–0,25 m**. Minimum punkter per plan: 15 (≈7,5 m² ved 2 pkt/m²). Ved 2 pkt/m² kjøres steg 9 (parametrisk) *først*, og segmentering bare som kontroll.
4. **Slå sammen** koplanære segmenter (< 5°, planavstand < ε), tilpass planet på nytt (minste kvadraters metode).
5. **Helning/asimut** per plan.
6. **Skjæring og typing:** for naboplan A∩B: begge faller *bort fra* linjen → **møne** (horisontal) / **grat** (skrå); begge faller *mot* → **gradrenne**. Omriss-kant med plan-z → **takkant** (eave hvis lav side, rake hvis gavl).
7. **Klipp mot omriss** med shapely (`split`/`polygonize`), tildel hver celle planet med flest punkter.
8. **Høyder:** takkant-z − DTM = gesimshøyde. Merk: omriss er ofte *vegglinje* mens laseren ser *takutstikk* → buffer 0,3–0,6 m eller bruk `roofprint` når kjent.
9. **Modell-drevet fallback (viktig ved 2 pkt/m²):** dekomponer omrisset i rektangler og test parametriske taktyper (flatt / pult / sal / valm) mot alle punkter (Henn et al. 2013 gjorde dette ned til ~1 pkt/m²). Velg med residual-kriterium. Bruk omrisset som prior: møne parallelt med lengste side, sentrert, symmetrisk helning – med mindre punktene tydelig sier annet.
10. **Confidence** per plan/kant: punkttetthet, RMSE, andel av omriss dekket, om resultatet kom fra segmentering (høy) eller parametrisk fallback (middels) eller DOM1 (lav).

**Fallback-stige** (alltid ett svar, aldri tomt):
`LIDAR-segmentering` → `LIDAR parametrisk (sal/valm/pult/flatt)` → `DOM1: ett plan + gesimshøyde` → `omriss + brukeren oppgir høyde/helning`.

**Hva vi realistisk ikke får automatisk:** arker/kvister < 8–10 m², snøfangere, nedløpsplassering (ikke synlig i laser), rennebredder, taksluk. Alt dette er «bruker legger til» – og «Be om informasjon» senere.

---

## 9. UX i Tak-modulen

**Plassering i appen:** ny `kind:'room'`-modul `roof` (flippen finnes). Sidebar-gren `_renderRoofPartContent` med tre nivåer: *Bygning* → *Takmodell* (flater, kanter, objekter) → *Varme* (hva som varmes, kabler, soner). Ingen «etasjer»; én del = én bygning (flere bygg = flere deler, som i dag).

**Steg 1 – Finn bygningen.** Adressesøk (finnes). Kart med Kartverkets topokart + bygningsomriss som klikkbare polygoner. Brukeren klikker bygget → «Bygg takmodell». Svar innen 5 s (`quick`) med omriss + gesimshøyde; «Henter laserdata (2–5 min)» kjører i bakgrunnen og oppgraderer modellen når den er klar (toast: «Takmodell oppdatert: 4 takflater, 1 møne, 2 gradrenner»).

**Steg 2 – Kontroller takmodellen.** Bakgrunn: DOM1-hillshade (møner synes) med topokart-overlay. Statuskort som i kravdoket §6 («6 takflater ✓ · takvinkel 32° (LiDAR) · gesimshøyde 6,8 m (estimat) · nedløp: ikke bekreftet»). Hver linje har fargekodet kilde-badge (§17). Verktøy: flytt/slett/tegn linje, del/slå sammen flate, sett høyde/helning, legg til takrenne/nedløp/gradrenne/snøfanger. **Gjenbruk:** rom-editoren sin vertex-drag/gizmo-mønster, `Ctrl+R/Ctrl+F`, samme hurtigtast-panel.

**Steg 3 – Marker hva som skal varmes.** Klikk på en takkant → «Takrenne 12,4 m · 2 løp». Klikk på et punkt på kanten → «Nedløp · 7,6 m (estimat fra DOM1) [✎]». Klikk gradrenne → «8,2 m · 2 løp». Dra ut et polygon på en takflate mellom takkant og snøfanger → «Oppvarmet takområde 22,1 m² (skrå 25,3 m²) · 250 W/m²». Alle tall redigerbare; alle regler viser *hvorfor* («2 løp fordi rennebredde > 120 mm – regel R-G2»).

**Steg 4 – Beregn anlegg.** Ett klikk. Resultat: totalt kabelbehov, installert effekt, forslag til kabler (standardlengder), sonedeling (øst/vest, per nedløp), advarsler, og **røde kabeltraseer** på tegningen. Brukeren kan overstyre. Egenskapspanel per kabel som i dag.

**Steg 5 – Arbeidstegning.** PDF-side per bygning: planvisning med traseer, kabelnummer, soner, lengder; tabell over renner/nedløp/flater; materialliste (gjenbruk 5-kolonne-malen); kildeattribusjon «Kartgrunnlag © Kartverket (CC BY 4.0)». Senere: enkel sidevisning (fasade) der nedløp og kabel ned fasaden vises – med trappas `_drawStairSide`-mønster.

**Tom-tilstand (ingen data):** «Fant ingen laserdata for dette området» → editoren starter med omriss + felt for høyde/helning. Aldri blokkert.

---

## 10. Beregningsregler (konfigurerbare, versjonerte)

Regler lever i én tabell `ROOF_RULES` (JSON, versjonert, redigerbar i admin senere), aldri hardkodet i motoren. Alle tall under er **plassholdere som Kenneth må sette fra datablad og prosjekteringsanvisninger** – ikke fakta.

| Regel | Eksempel (plassholder) | Kommentar |
|---|---|---|
| R-G1 renne, effekt | 30–40 W/m per løp | avhengig av kabeltype (selvbegrensende vs. konstant) |
| R-G2 renne, antall løp | 1 løp ≤ 120 mm bredde, 2 løp over | klima-justert |
| R-D1 nedløp, løp | 1 løp; 2 ved diameter > 100 mm eller lengde > X m | nedløp må ha kabel helt ned til frostfri sone/utløp |
| R-V1 gradrenne | 2 løp, W/m som renne | |
| R-A1 takflate | 200–300 W/m² etter klima (`weather_by_postcode`) | samme kilde som snø-modulen |
| R-A2 takflate CC | CC (på taket) = W/m ÷ W/m², regnet på **sann** (skrå) flate | To leggeretninger, ulik omregning til plan: **langs fallretning** → kabellengder i plan × 1/cos θ, CC uendret (måles på tvers, som i plan). **På tvers** (langs høydekurver) → lengder uendret, men CC i *plan* = CC·cos θ (tettere i planprojeksjon). Motoren må vite retningen før den tegner. |
| R-C1 kabelvalg | «nærmeste ferdiglengde ≥ behov, ellers metervare» (`_frostSuggestCable`-mønster) | selvbegrensende |
| R-C2 maks lengde | fra produkt (`max_length_m`) og kurs (A) | sonedeling utløses |
| R-Z1 sonedeling | per nedløp / per takside / per kurs; fasebalanse ved 400 V | «ikke bare maks lengde» – §12 i kravdoket |

Motoren: `items → pieces` (trappe-modellen: `{kind:'run'|'conn', len_m, runs, feature_id}`) → `_stairAllocateCables`-tilsvarende fordeling per sone → produkt via katalog. Alt deterministisk, alt testbart.

**Produktdata som må på plass (fase 4):** ny kategori «Takrenne/nedløp» (`module_type:'roof'`, `available_contexts:['outdoor']`) med felt for `w_per_m` (evt. ved is/vann for selvbegrensende), `max_length_m`, ferdiglengder, tilbehør (festeklips, endeavslutning). Mal: `_ensureFrostProtectionProducts`. Hvilke Cenika-produkter dette er, avgjør Kenneth.

---

## 11. Deterministisk vs. AI

| Deterministisk (alltid) | AI kan hjelpe (aldri autoritativ) |
|---|---|
| Alt geometri: klipp, segmentering, skjæring, typing, areal, skrålengde | Tolkning ved usikkerhet: «dette ser ut som valmtak med ark» når segmenteringen gir 3 flater og 40 % udekket |
| Alle beregninger: W, m, løp, CC, soner, kabelvalg | Forslag til navn på soner/objekter («Nedløp sørvest») |
| Confidence-tall (fra tetthet/RMSE/dekning) | Oppsummering av statuskortet i klartekst |
| Regelmotor og advarsler | Tolkning av brukerens frie tekst i «Be om informasjon»-svar («7,65 m med bilde» → `height_m=7.65, MEASURED`) |
| Validering (kollisjon, maks lengde) | Klassifisering av takbilde brukeren laster opp («ser du snøfanger?») – kun som forslag med badge `AI_SUGGESTION` |

Regel: AI-utdata lagres alltid med `source:'AI_SUGGESTION'` og må bekreftes av bruker før den blir `USER_CONFIRMED`. Ingen AI i regne-stien.

---

## 12. Validering, confidence, fallback og testing

**Confidence-visning:** fire badges – *Målt* (grønn), *Bekreftet* (grønn), *Fra data* (blå: LiDAR/DOM/FKB), *Estimat* (gul), *Forslag* (grå, AI). PDF-en skriver kilde per høyde/lengde i tabellen. Prosjektet kan ikke merkes «Klar for montasje» mens et nedløp står som *Estimat* – bare som «Klar med forbehold».

**Validering i motoren:** kabel-maks-lengde, minste bøyeradius i renne-hjørner, nedløpslengde ≤ kabel, overlappende traseer, takflate-polygon innenfor plan, renner kun på `eave`-kanter, sone uten kabel, kurs over grense.

**Automatisk testing (kravdoket §18) – to nivåer:**
1. **Syntetisk tak-generator (Python + JS):** parametrisk generator for sal/valm/pult/flatt/L-form/flere møner/flere nivåer med kjent fasit; genererer *både* en syntetisk punktsky (med 2 og 5 pkt/m², støy 5 cm, valgfritt uten klasse 6) *og* fasit-`RoofModel`. Tester rekonstruksjonen (plan-completeness, mønelinje-avvik, helning, gesims) og regelmotoren (kabelmeter, soner, kollisjoner). Samme mønster som `_foilRegressionTest`, men fasit i **datafiler** (`tests/roofs/*.json`), ikke i koden – så reelle feil kan legges til som permanente regresjonstilfeller (kravdoket: «alle reelle feil lagres»).
2. **Ekte bygg-fasit:** POC-byggene (§16) med manuelt digitalisert fasit blir faste integrasjonstester mot cache-lagret punktsky (så testene ikke treffer Kartverket).

---

## 13. Ytelse og kostnad

- **Regning:** under 1 s per bygg i Python (500–1 000 punkter for et bolighus), < 100 MB RAM. `roofer` i C++ gjør det på ~0,4 s – ikke flaskehalsen.
- **Data er flaskehalsen:** hoydedata.no-eksport er asynkron (jobb + URL/e-post, minutter). En 1 km²-tile er 2–5 mill. punkter. Løsning: **tile-cache** – første forespørsel i et område bestiller f.eks. 500×500 m, klipper til 100×100 m LAZ-biter og lagrer i objektlager (Supabase Storage / Tigris på Fly). Neste bygg i samme rute: sekunder. Lagring: et bolighus-utsnitt er 50–300 KB; 10 000 bygg ≈ 1–3 GB. Ingen grunn til å cache hele landet.
- **DOM1 via WCS** er synkront og lett (100×100 m @ 1 m = 10k celler) – bruk det som `quick`-nivå og som hillshade-bakgrunn (cache PNG per bbox/zoom).
- **Rate limits** er ikke dokumentert hos Kartverket; tjenesten må ha egen kø med maks samtidige eksportjobber (f.eks. 2) og backoff. Kreditering «© Kartverket» er lisenskrav.
- **Kostnad ved «tusenvis av brukere»:** roof-service på Fly (1–2 GB, scale-to-zero) + objektlager: tosifret antall dollar per måned ved realistisk volum. Det som koster er *eventuelt* FKB/Norkart per oppslag – hent pris i fase 1.
- **Kaldstart:** Fly scale-to-zero + Python med numpy/scipy/shapely/laspy: 3–8 s. Bruk bare biblioteker som installeres uten spesialoppsett (ren `pip`); `open3d` (100+ MB) og PDAL (krever conda/apt) holdes ute – de ville doblet kaldstarten og komplisert deploy.

---

## 14. Risiko

| Risiko | Sannsynlighet | Tiltak |
|---|---|---|
| Fri segmentering blir for dårlig på komplekse tak ved 2 pkt/m² (bare 300–750 punkter på et bolighustak) | **svært høy** | Parametrisk tilpasning er hovedveien, ikke reserve; bruker-korreksjon er *forventet* flyt. POC måler andel bygg som trenger korreksjon. |
| `selectCableByPower`/`selectMultiCables` er rom-bundne | sikker | Areal-variant eller syntetisk rom (fase 5 STEG 0). |
| Klasse 6 mangler i mange prosjekter | middels | Fallback «z > DTM + 2 m» fra dag én. POC rapporterer per bygg. |
| Omriss = vegglinje, laser = takutstikk (0,3–0,6 m kantfeil) → rennelengder litt korte | høy | Buffer + la brukeren snappe takkant til laserkant; rennelengde tas fra *takkant*, ikke vegglinje. |
| OSM-omriss under ODbL i et kommersielt produkt | middels | Bruk INSPIRE core2D WFS hvis Kartverket bekrefter status; ellers juridisk vurdering av ODbL for *input* (omrisset lagres i prosjektet → kan regnes som avledet). Alternativ: la brukeren tegne omriss på topokart (2 min). |
| Kartverket-eksport for treg/ustabil | middels | Tile-cache; `quick`-nivå fungerer alltid uten punktsky. |
| Ingen ortofoto → bruker stoler ikke på modellen | middels | DOM1-hillshade + «last opp eget bilde»; POC viser Kenneth om hillshade er nok. |
| Produktregler for takrenne mangler i Varmeplan | sikker | Fase 4 starter med Kenneths regelsett fra datablad; regler versjoneres. |
| Feltapp ser ikke takobjekter | sikker | `prefill.ts`/`MODULES` må utvides (fase 7); til da: `labelOnly`-kabler med `roomId` på et syntetisk «Tak»-rom som bro. |

---

## 15. Trinnvis plan

Hver fase har en leveranse, et go/no-go, og angir hvilket repo den berører. **Fase 2 og 3a kjører parallelt.**

### Fase 1 – Research og avklaringer (1–2 uker, ingen kode)
- ✅ Datakilder og lisenser (dette dokumentet, §3).
- Be Kartverket bekrefte status/lisens for INSPIRE Buildings core2D WFS til kommersiell bruk (e-post).
- Be Norkart (Bygning API / 3D Kart API) og Geodata om pris per oppslag / per km² for FKB-Bygning-avledede takdata.
- Kenneth: hvilke Cenika-produkter for renne/nedløp/takflate, og hvilke dimensjoneringsregler (datablad) → `ROOF_RULES` v1.
- Kenneth: velg 12–15 POC-bygg (§16) han kan kontrollmåle eller kjenner.
- **Go/no-go:** ingen – research bare informerer fase 2/3.

- Besluttet her (ikke etter POC): roof-service = nytt repo `varmeplan-roof`, egen Fly-app, POC under `poc/`.

### Fase 2 – RoofModel-POC (2–4 uker) · `varmeplan-roof/poc/` (Python, `uv`)
- Skript: adresse → omriss (INSPIRE/OSM) → DOM1/DTM1 via WCS → punktsky via `startExport.ashx` (manuelt utløst er OK i POC) → pipeline §8 → `RoofModel`-JSON + PNG-visualisering (planer fargelagt oppå DOM1-hillshade + topokart).
- `roofer` i Docker på samme bygg som benchmark.
- Syntetisk tak-generator (§12) med 2 og 5 pkt/m².
- Målinger per bygg: tetthet, klasse 6 ja/nei, taktype riktig, helningsfeil, mønelinje-avvik (xy/z), gesimshøyde-avvik, plan-completeness, kjøretid, confidence.
- **Go/no-go for full LiDAR-vei:** ≥ 70 % av vanlige boliger får riktig taktype + helning < 3° + gesims < 0,3 m uten korreksjon, og resten er *korrigerbare* (ikke ubrukelige). Under det: fase 5 baseres på parametrisk fallback + manuell tegning, og FKB-kjøp vurderes.

### Fase 3a-0 – Stedfestet tegneflate, først i snø-modulen (2–3 uker) · se §19
- Kart-laget (topo WMTS, omriss, eiendomsgrense, DTM-helning, georeferert canvas) bygges én gang,
  med «Hent fra kart» i snø-modulen som første bruker. Tak-editoren under gjenbruker det.

### Fase 3a – Tak-editor «omriss-først» (3–5 uker) · `index.html` + `varmeplan-roof/app/` (parallelt med fase 2, etter 3a-0)
- **Startbetingelse:** omriss-kilde avklart (INSPIRE WFS bekreftet, eller OSM med ODbL-vurdering) – **ellers starter fasen med «bruker tegner omrisset på topokartet»** som eneste omriss-kilde, og automatikken kobles på senere. Fasen er aldri blokkert av fase 1.
- `MODULE_TYPES.roof.available = true` + alle roof-grener (§2-lista). Ny `S.roof` (F4a-sjekklisten), `_moduleContext` roof-gren.
- Kart-bakgrunn: Kartverket topo WMTS + DOM1-hillshade via roof-service proxy (`/roof/background`), georeferert canvas (ny: `EPSG:25833 ↔ canvas`-transform; bakgrunn låst, ikke kalibrerbar som PDF).
- `POST /roof/locate` + `POST /roof/model?level=quick` i `varmeplan-roof/app/` (første produksjonskode; kan begynne som frontend-mock med fast JSON til tjenesten er oppe).
- Editor: omriss som `RoofEdge[type:'eave'|'rake']` med z fra DOM1; verktøy for takrenne/nedløp/gradrenne/snøfanger (manuelt); statuskort med kilde-badges; undo/lagring/PDF-stubb.
- **Leveranse:** man kan finne et bygg, få omriss + gesimshøyde automatisk, og tegne renner/nedløp – uten LiDAR.

### Fase 3b – LiDAR-forslag inn i editoren (2–3 uker) · begge repo · etter fase 2 go
- `level=full`. Editoren mottar planer/kanter som *forslag* med confidence; «Godta alle» / per-objekt.
- Editor-verktøy: del/slå sammen flate, flytt møne, sett helning.

### Fase 3c – Infrastruktur for laserdata (1–2 uker) · `varmeplan-roof` · før 3b kan slippes
- Ventekø for eksportjobber (maks 2 samtidige mot Kartverket, backoff), tile-cache i objektlager (Supabase Storage eller Fly Tigris) med 100×100 m LAZ-biter, app-nøkkel, attribusjon i alle svar, overvåking av feilrate/kjøretid. Egen Fly-app med 1–2 GB.
- **Go/no-go:** cache-treff gir modell < 15 s; miss viser ærlig «2–5 min» og fullfører.

### Fase 4 – Enkel varmeprosjektering: renne + nedløp + gradrenne (3–4 uker) · `index.html`
- Produktkategori «Takrenne/nedløp» i Supabase (migrasjon, additiv) + `_ensureRoofProducts`-mal.
- `ROOF_RULES` v1, `items → pieces → cables` med `_stairAllocateCables`-mønster, `_frostSuggestCable`-valg, soner per nedløp/takside, advarsler.
- Tegning: røde traseer langs kanter, nedløp som vertikal «pinne» med lengde, kabelnummer.
- PDF: takside + tabell + materialliste + attribusjon. Regresjonstest `_roofRegressionTest` mot `tests/roofs/*.json`.
- **Leveranse: modulen kan brukes i produksjon for renne/nedløp.**

### Fase 5 – Takflater (3–4 uker)
- «Oppvarmet takområde»-verktøy på et plan; `true_area`, W/m² fra klima (`weather_by_postcode`), CC på sann flate, routing med `_skEngineCore` i planprojeksjon – vinkel = fallretning (lengder × 1/cos θ, CC uendret) *eller* på tvers (lengder uendret, plan-CC = CC·cos θ), jf. R-A2.
- Areal-variant av `selectCableByPower`/`selectMultiCables` (i dag rom-bundne) eller syntetisk rom – avgjøres i STEG 0 for den prompten.
- Snøfanger som avgrensning; advarsel når område ikke ender i renne (vannvei).

### Fase 6 – Optimalisering (2–3 uker)
- Automatisk produktvalg over hele anlegget, kurs-/fasebalanse (gjenbruk snø-modulens fasebalanserte forslag), sonedeling med praktiske kriterier (per nedløp, per takside, samme styring), vannvei-varsler (§11).
- Evt. FKB/Norkart-adapter hvis fase 1 ga akseptabel pris.
- **Klima fra posisjon, ikke postnummer** (tillegg 23.09): når kart-laget kjenner adressens
  koordinat, hentes dimensjonerende temperatur/vind fra nærmeste MET-stasjon via **Frost-API**
  (klimanormaler, gratis, uten nøkkel – merk at Frost krever en gratis klient-ID for
  produksjonsbruk; verifiser vilkår) i stedet for den statiske tabellen `weather_by_postcode`.
  Gjelder snø, bakke og tak likt. Tabellen beholdes som fallback når koordinat mangler
  (hurtig prosjektering uten kart). Verdien lagres med kilde-badge («MET, stasjon X, 12 km»).

### Fase 7 – Montør og dokumentasjon (2–3 uker) · `varmeplan-app` + `index.html`
- Feltappens `MODULES` + `prefill.ts` leser `data.roof` (renner/nedløp/flater som «elementer»).
- «Be om informasjon» v1: objekt → forespørsel (Supabase-tabell `roof_requests {project_id, object_id, question, answer, photo, by, at}`) → svar oppdaterer `Meas` med `MEASURED` + historikk. Dette er første versjon av samarbeidsfunksjonen og bør designes generelt (gjelder også rom).
- **Leveranse:** hele flyten leverandør → elektrobedrift → montør → dokumentasjon i samme prosjekt.

### Fase 8 – 3D (kun hvis fase 2/3 viser behov)
- Enkel isometri/sidevisning med canvas først (nedløp, fasadekabel, nivåer). WebGL bare hvis brukerne faktisk ber om det.

**Anslått total for fase 1–7:** 5–8 måneder i Kenneths tempo (én prompt om gangen, med slakk for avklaringer mot Kartverket/leverandører), der fase 4 er første produksjonsverdi etter ~2–3 måneder.

---

## 16. POC-spesifikasjon (første konkrete jobb)

**Repo:** `varmeplan-roof/poc/` (nytt repo, Python 3.12, `uv`; bare biblioteker som installeres uten spesialoppsett – ikke `open3d`, ikke PDAL). Ikke i lumelo.
**Bygg (Kenneth velger, 12–15):** 3 saltak (ulik helning), 2 valmtak, 2 L-formede, 1 med flere møner, 1 komplisert bolig med arker, 2 flate (bolig + næring), 1 næringsbygg med to taknivåer, 1 bygg i område med 5 pkt/m², 1 i område uten klasse 6 (finnes via `projectMetadata.ashx`).
**Fasit:** manuell digitalisering av møne/takkant fra Kenneths kunnskap/tegninger/kontrollmål; helning fra tegning eller målt; gesims målt der mulig. FKB-utsnitt hvis lovlig tilgjengelig for noen bygg (kommune/forhandler-test).
**Leveranser:** per bygg: `RoofModel.json`, PNG (planer + kanter oppå DOM1-hillshade), måltabell; samlet rapport med go/no-go mot kriteriene i fase 2; `roofer`-benchmark på samme bygg; syntetisk generator med 20 tilfeller.
**Skal måle:** punkttetthet på tak · klasse 6 finnes · taktype riktig · helning per plan (mål < 3°) · mønelinje lateral (< 0,3 m) og z (< 0,15 m) · gesimshøyde (< 0,2 m) · plan-completeness · kjøretid varm/kald · hvor mange klikk korreksjonen ville krevd.

---

## 17. Åpne spørsmål til Kenneth (før første prompt)

1. Hvilke produkter selger Cenika for takrenne/nedløp/takflate i dag (selvbegrensende? konstant effekt? ferdiglengder?), og hvilke dimensjoneringsregler bruker dere (W/m i renne, løp-regel, W/m² på tak)?
2. Har du tilgang til FKB-Bygning-utsnitt via noen (kunde/kommune/forhandler) til POC-fasit?
3. Er det greit at roof-service koster litt drift (objektlager + evt. egen Fly-app), og at den får app-nøkkel (lumelo har ingen)?
4. Hvor mange takprosjekter i uka er realistisk det første året? (Styrer hvor mye cache som trengs.)
5. Skal Tak-prosjekter kunne ha flere bygg (deler) – ja i planen, si fra hvis nei.

---

## 19. Bakke-anlegg deler kart-laget (tillegg 23.09.2026)

Kenneth: «Kan det gå an å få en tilsvarende modul for bakkeanlegg? Gårdsplass eller oppkjørsel: gå
inn på adresse, definere areal/område og legge ut matter. Kan det gjøres i samme motor?»

**Ja – og det er den enkle varianten.** Tak-planen består egentlig av to deler: (1) **kart-laget**
(adresse → kart med riktig målestokk → bygningsomriss, eiendomsgrense, terreng → tegne oppå) og
(2) **takrekonstruksjonen** (punktsky → flater/møner/høyder). Bakke trenger bare del 1. Alt annet
finnes i snø-modulen i dag: områder, InSnow-matter (`_packSnowMats`) og kabel, W/m² fra klima,
kursdeling med fasebalanse. Det eneste som mangler er at brukeren må importere PDF og kalibrere –
og **kartet har målestokk innebygd**, så kalibreringen forsvinner.

**Beslutning som endrer faseplanen:** «Kart som bakgrunn» tas ut av fase 3a og blir en egen,
felles leveranse – **fase 3a-0 «Stedfestet tegneflate»** – med **snø-modulen som første bruker**,
før tak-editoren. Grunn: billigst, verdi umiddelbart (hver oppkjørsel), og det georefererte
lerretet blir testet på en modul som allerede virker før tak skal stå på det. Uavhengig av
tak-POC-en.

**Fase 3a-0 – Stedfestet tegneflate (2–3 uker) · `index.html` + `varmeplan-roof/app/`**
- Én knapp i snø-modulen: «Hent fra kart» → adressesøk (finnes) → kart (Kartverket topo WMTS +
  bygningsomriss + eiendomsgrense) → brukeren tegner polygonet → det blir et vanlig `snow`-område
  med riktige mål, uten kalibrering. Georeferert canvas: `EPSG:25833 ↔ canvas-cm`, bakgrunn låst.
- Datakilder (alle åpne, CC BY 4.0): adresse-API; Matrikkelen – Bygningspunkt (WFS); omriss
  (INSPIRE core2D / OSM, jf. §3); **Matrikkelen – Eiendomskart Teig** (WMS
  `wms.geonorge.no/skwms1/wms.matrikkelkart`, nedlasting via Geonorge) – viktigere for bakke enn
  for tak, fordi gårdsplassen stopper ved grensen; DTM1 (WCS) for terrenghelning.
- To gevinster som ikke finnes i dag: **helning** på området fra DTM1 («9 % – vurder høyere
  W/m²», kilde-badge `DOM_RASTER`) og **avstand hus → område** som forslag til kaldkabel-lengde.
- Sluk/avrenning som eget punkt-objekt (samme idé som nedløp på tak) med advarsel når området ikke
  faller mot et sluk – kan vente til fase 6.
- Kilde-badges på mål: «fra kart ±0,5 m» vs «oppgitt».
- **Leveranse:** adresse → tegn oppkjørsel på kart → matter/kabel som før, ferdig kalibrert.

**Det som ikke går, og som må sies i UI-et:**
- Oppkjørselen er **ikke synlig** på kartet – flyfoto er lukket (§3), og på topokartet er en privat
  gårdsplass grå flate. Brukeren må vite hvor asfalten går (elektrikeren etter befaring gjør det).
  Ikke forsøk å finne oppkjørselen automatisk; det finnes ingen åpen kilde. Tillat opplasting av
  eget bilde/situasjonsplan som ekstra lag (dagens bg-import) oppå kartet.
- Nøyaktighet ~0,5 m ved maks zoom. Nok for matter, ikke for millimeter.

**Skal IKKE gjøres:** ny «bakke-motor» ved siden av snø-modulen (kartet leverer et polygon *inn*
i det som finnes – ellers to steder å vedlikeholde matteregler og PDF); Google Maps/Solar for
flyfoto (kan ikke lagres i prosjektet); vente på tak-POC før bakke får kart.

Tak-editoren (fase 3a) bygger så videre på nøyaktig samme tegneflate – med omriss som takkanter.

## Ordliste

- **WFS / WCS / WMS / WMTS** – standardiserte nett-tjenester for kart: WFS gir *vektordata* (polygoner, punkter), WCS gir *rasterdata* (høydeverdier per rute), WMS/WMTS gir ferdige *kartbilder* til visning.
- **LAZ / punktsky** – komprimert fil med millioner av laser-målte punkter (x, y, høyde, evt. klasse som «bakke»/«bygning»).
- **DOM / DTM** – digital *overflate*modell (med hus og trær) / digital *terreng*modell (bare bakken), som rutenett med høyde per meter.
- **Hillshade** – et høyderaster tegnet som om sola skinte på det, så man ser former (møner, takfall).
- **FKB** – Felles kartdatabase; Norges detaljerte kartdata, eid av Geovekst-partene, ikke åpne.
- **ODbL / CC BY 4.0** – lisenser. CC BY: bruk fritt, oppgi kilde. ODbL (OpenStreetMap): bruk fritt, men avledede *databaser* må deles på samme vilkår – derfor forsiktighet.
- **EPSG:25833** – koordinatsystemet (UTM sone 33) alle norske landsdekkende data leveres i.
- **Provenance / confidence** – «hvor kom tallet fra» og «hvor sikkert er det».

## 18. Kilder

**Datakilder og lisenser**
- Kartverket vilkår (CC BY 4.0): https://www.kartverket.no/en/api-and-data/terms-of-use
- NDH status/dekning: https://www.kartverket.no/en/geodataarbeid/nasjonal-detaljert-hoydemodell · https://www.kartverket.no/en/geodataarbeid/nasjonal-detaljert-hoydemodell/status-hoydemodell
- Punktsky produktspek 1.0.2: https://dokument.geonorge.no/produktspesifikasjoner/punktsky/1.0.2/produktspesifikasjon-punktsky-102.pdf
- FKB-Laser (klasse 6 opsjonell): https://register.geonorge.no/data/documents/Produktspesifikasjoner_FKB-Laser_v8_produktspesifikasjon-fkb-laser-3_0_.pdf
- hoydedata.no webtjenester (startExport/exportStatus/projectMetadata): https://hoydedata.no/LaserInnsyn2/dok/webtjenester.pdf · https://test.hoydedata.no/LaserInnsyn2/help_no/topics/idh-topic130.htm
- Høyde DOM1 (Bin with Maximum Value, CC BY 4.0): https://data.norge.no/en/datasets/235ee40f-2eab-3715-bc4e-c7f9152f771e/hoyde-dom1
- WCS DOM/DTM: https://wcs.geonorge.no/skwms1/wcs.hoyde-dom-nhm-25832?service=wcs&request=getcapabilities
- FKB-Bygning 5.1.1 spek: https://dokument.geonorge.no/produktspesifikasjoner/fkb-bygning/Versjon%205.1.1/index.html · registreringsinstruks: https://github.com/kartverket/prodspek_fkb_bygning
- FKB-Bygning metadata (Norge digitalt begrenset): https://kartkatalog.geonorge.no/api/getdata/8b4304ea-4fb0-479c-a24d-fa225e2c6e97 · data.norge.no: https://data.norge.no/en/datasets/a43ebac8-7b1c-4feb-9832-f77d2fa38b6e/fkb-bygning
- Geovekst priskalkulator: https://kartverket.no/en/geodataarbeid/geovekst/priskalkulatoren · melding 6/2025: https://www.kartverket.no/globalassets/geodataarbeid/geovekst/motedokumenter/melding-nr-6-2025.pdf
- FKB WMS (visning): https://kartkatalog.geonorge.no/api/getdata/84178e68-f40d-4bb4-b9f6-9bfdee2bcc7a
- INSPIRE Buildings core2D WFS + OSM-import: https://wiki.openstreetmap.org/wiki/Import/Catalogue/Norway_Building_Import
- Norge i bilder (lukket): https://www.geonorge.no/nib · https://www.kartverket.no/en/on-land/flyfoto
- Kartverket topo WMTS: https://cache.kartverket.no/
- Matrikkelen – Bygningspunkt (CC BY 4.0, WFS): https://kartkatalog.geonorge.no/api/getdata/24d7e9d1-87f6-45a0-b38e-3447f8d7f9a1 · utvidet (krever auth): https://dokument.geonorge.no/produktspesifikasjoner/matrikkelen-bygningspunkt-utvidet/20221101/produktspesifikasjon-kartverket-matrikkelen-bygningspunktutvidet-versjon20221101.pdf
- Matrikkel-API søknad: https://www.kartverket.no/en/api-and-data/eiendomsdata/soknad-api-tilgang
- Adresse-API: https://ws.geonorge.no/adresser/v1/openapi.json
- Google Solar API: https://developers.google.com/maps/documentation/solar/building-insights · policies: https://developers.google.com/maps/documentation/solar/policies · release notes (Norge MEDIUM 16.01.2024): https://developers.google.com/maps/documentation/solar/release-notes
- Overture/Microsoft-kvalitet i Norge: https://github.com/OvertureMaps/data/issues/458
- Norkart: https://www.norkart.no/datatjenester/3d-kart-api · https://www.norkart.no/datatjenester/bygning-api

**Takrekonstruksjon**
- roofer: https://github.com/3DBAG/roofer · datakrav: https://innovation.3dbag.nl/roofer/data_requirements.html · Python-API: https://innovation.3dbag.nl/roofer/api_py.html · CLI/attributter: https://innovation.3dbag.nl/roofer/cli_application.html
- 3D BAG-artikkelen (algoritme, RMSE, ytelse): https://arxiv.org/pdf/2201.01191 · attributter: https://docs.3dbag.nl/en/schema/attributes/
- City3D: https://github.com/tudelft3d/City3D · PolyFit: https://github.com/LiangliangNan/PolyFit · CGAL: https://doc.cgal.org/latest/Shape_detection/index.html
- PDAL approximatecoplanar: https://pdal.io/en/latest/stages/filters.approximatecoplanar.html · laspy: https://laspy.readthedocs.io/en/latest/installation.html · pyRANSAC-3D: https://github.com/leomariga/pyRANSAC-3D
- Henn et al. 2013 (modell-drevet ved sparsom LiDAR): https://www.sciencedirect.com/science/article/abs/pii/S0924271612002043
- ISPRS-benchmark (flater < 10 m² problematisk): https://www.isprs.org/resources/datasets/benchmarks/UrbanSemLab/detection-and-reconstruction.aspx
- RoofN3D (4,7 pkt/m²): https://isprs-archives.copernicus.org/articles/XLII-2/1191/2018/isprs-archives-XLII-2-1191-2018.pdf · Building3D: https://arxiv.org/pdf/2307.11914
- Google Solar-segmentering (DSM 25 cm, ~5° helningsfeil): https://arxiv.org/abs/2408.14400
- CityJSON 2.0.1: https://www.cityjson.org/specs/2.0.1/

**Kode (arqely-mvp `index.html` @ 8ec399e, lumelo-backend, varmeplan-app)** – linjenumre i §2.
