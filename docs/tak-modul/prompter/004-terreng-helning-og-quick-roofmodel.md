# 004 · `/roof/slope` og `/roof/model?level=quick` — terreng, helning, gesimshøyde, RoofModel-kontrakt v0

**Repo:** `~/Code/varmeplan-roof` · **Størrelse: middels** · Forutsetter 003 (DOM1/DTM1-henting)

## Mål

To ting bakke og tak trenger fra terrenget, uten punktsky:
1. **Helning for et område** (bakke): polygon inn → gjennomsnittlig helning i %, fallretning, maks
   helning. Brukes i 006 («9 % — vurder høyere W/m²»).
2. **Quick RoofModel** (tak, forberedelse): bygningsomriss inn → gesimshøyde fra DOM1 − DTM1 langs
   omrisset, grov taktype (flatt/skrått) fra DOM1-varians, mønehøyde-anslag. Alt med `prov` og
   `confidence` etter kontrakten i tak-planen §6. Dette blir **datakontrakten** Tak-editoren
   bygger på senere — den skal ligge i `docs/roof-contract.md` og i Pydantic-modeller.

## Datakilder

- DTM1 (terreng) og DOM1 (overflate): WCS 25833 (se 003), GeoTIFF 1 m. CC BY 4.0.
- Kjent svakhet (fra planen): DOM1 er «Bin with Maximum Value» → svak oppoverbias; 1 m er for grovt
  til møner/gradrenner. Quick-modellen lover derfor **bare** gesimshøyde ±0,5 m og taktype.

## STEG 0

1. Hent DTM1 og DOM1 for testbyggets bbox (fra 002/003), lagre som fixtures. Sjekk NoData-verdi,
   CRS, og at rasterio leser dem uten GDAL-krøll. Hvis rasterio ikke fungerer i miljøet, bruk
   `tifffile` + manuell georeferanse fra WCS-svaret (bbox er kjent) — skriv i SPØRSMÅL.
2. Mål manuelt: gesimshøyde for testbygget via DOM1 − DTM1 langs omrisset (median) — er tallet
   fornuftig (2,5–9 m)?

## Kontrakter

```
POST /roof/slope
{ "polygon": [[e,n],…], "epsg": 25833 }
→ { "slope_pct_mean": 8.7, "slope_pct_max": 14.2, "aspect_deg": 212,   // retning fallet peker (0 = nord)
    "z_min": 112.3, "z_max": 114.1, "samples": 640,
    "prov": { "source": "DOM_RASTER", "confidence": 0.8, "note": "DTM1 1 m, Kartverket" },
    "attribution": "© Kartverket (CC BY 4.0)" }

POST /roof/model?level=quick
{ "footprint": [[e,n],…], "bygningsnr": "80123456"? , "epsg": 25833 }
→ BuildingModel (v0):
{ "id": "…", "bygningsnr": "…",
  "origin": { "epsg": 25833, "east": E_c, "north": N_c, "ground_z": 112.4, "prov": {…} },
  "footprint": { "polygon": [[x,y],…]  /* lokale meter, origo = footprint-sentroide */, "prov": {…} },
  "heights": { "eave_m": { "value": 5.9, "prov": { "source": "DOM_RASTER", "confidence": 0.6 } },
               "ridge_m": { "value": 8.4, "prov": {…, "confidence": 0.4 } } },
  "terrain": { "dtm_z_at_vertices": [...], "prov": {…} },
  "roof": { "planes": [], "edges": [ { "id":"e1","type":"eave","a":[x,y,z],"b":[x,y,z],"length_m":12.4,"planes":[],"prov":{…} }, … ],
            "nodes": [], "obstacles": [], "features": [],
            "roof_type": "flat"|"pitched"|"unknown", "prov": {…} },
  "quality": { "dom_nodata_frac": 0.02, "method": "quick" },
  "attribution": "© Kartverket (CC BY 4.0)" }
```
Kanter: **alle** omrisskanter blir `edge.type = "eave"` med z = gesims i quick-modellen (Tak-editoren
lar brukeren endre til `rake`/`step` senere). `Provenance`-typen og `Source`-enum tas ordrett fra
tak-planen §6.1 (`MEASURED | USER_CONFIRMED | USER_DRAWN | FKB | LIDAR | DOM_RASTER | FOOTPRINT |
ESTIMATE | AI_SUGGESTION`).

## Gjør

1. `app/geo/dtm.py`: felles henting/caching av DTM1/DOM1-GeoTIFF for bbox (gjenbruk 003 sin WCS-
   klient), sampling av z i punkt (bilineær), maske for NoData.
2. `app/geo/slope.py`: rasteriser polygonet (shapely `contains` på 1 m-gitter), gradient med numpy,
   middel/maks/aspekt. Hvis < 20 celler i polygonet → `confidence 0.3` og note «lite område».
3. `app/geo/roofmodel_quick.py`: gesims = median(DOM1 − DTM1) på punkter 0,5 m **innenfor** hver
   omrisskant (unngå kantceller), taktype = `flat` hvis (DOM-max − DOM-median innenfor omriss) < 0,8 m
   ellers `pitched`, `ridge_m` = maks DOM − terreng (confidence 0,4). `roof_type: unknown` når
   NoData > 30 %.
3b. **DOM1-omriss som fallback i `/roof/locate`** (erstatter OSM — avgjort 24.09). I
   `app/geo/footprint.py::resolve_footprint` (fra 002, ved `# TODO(004)`), når INSPIRE ga `None`:
   - Hent DOM1 og DTM1 for 40 × 40 m rundt bygningspunktet (gjenbruk `dtm.py`).
   - Maske: `(DOM1 − DTM1) > 2.0 m`. Morfologisk **åpning** med 1 celle (scipy.ndimage) for å
     kutte tynne broer til trær/hekker. Velg den sammenhengende komponenten som inneholder
     bygningspunktet (ingen → `None`).
   - Polygoniser (rasterio.features.shapes eller egen kantsporing), `simplify(0.5)` i shapely.
     Hvis `minimum_rotated_rectangle` har IoU ≥ 0,85 med polygonet → bruk rektangelet (renere
     hjørner for snapping), ellers det forenklede polygonet.
   - `Footprint(source='DOM1', prov={source:'DOM_RASTER', confidence: 0.5})`. Er arealet > 400 m²
     eller polygonet har < 4 eller > 24 hjørner → `confidence 0.3` og `note: 'sjekk omrisset —
     kan inneholde vegetasjon'` (klienten viser ⚠ i 006).
   - Bump cache-versjonen i locate til `v2`.
   - Tester (syntetisk raster som i punkt 5): hus 6 m høyt → omriss med areal ± 10 % av fasit og
     IoU ≥ 0,8; hus + tre inntil veggen (5 m høy «blob» 2 × 2 m) → treet er borte etter åpning;
     ingen forhøyning → `None`.
4. `app/models/roofmodel.py`: Pydantic for BuildingModel/RoofModel/Provenance — **kilden** til
   `docs/roof-contract.md` (generer JSON-schema fra modellene inn i docs).
5. Tester (fixtures): kjent syntetisk DTM/DOM (numpy-generert: flatt terreng + «hus» 6 m høyt med
   saltak 8,5 m) → gesims 6,0 ± 0,3, `pitched`; flatt hus → `flat`; skrå bakke 10 % → slope 10 ± 1,
   aspect riktig; polygon med NoData → `unknown`.
6. Commit: «004: /roof/slope + /roof/model?level=quick + DOM1-omriss — terreng, gesims, RoofModel-kontrakt v0».

## Skal IKKE

- Punktsky/LAZ (fase 2-POC, egen serie).
- Love mer enn quick-modellen kan: ingen møner/gradrenner fra DOM1.

## Rapport (STATUS.md)

- Målt gesims for testbygget og hva du tror riktig er; WCS-svartid; om rasterio virket.
