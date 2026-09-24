# 003 · `/roof/background` — ett georeferert kartbilde (PNG) for et utsnitt

**Repo:** `~/Code/varmeplan-roof` · **Størrelse: middels** · Forutsetter 001

## Mål

Klienten ber om et kvadratisk utsnitt rundt et punkt og får **ett PNG** med nøyaktig kjent
utstrekning i meter: Kartverkets topokart som bunn, eiendomsgrenser (valgfritt) og DOM1-hillshade
(valgfritt) oppå, kreditering brent inn nederst. Bildet blir en vanlig Varmeplan-bakgrunn med
`widthCm = width_m × 100` — derfor ingen kalibrering.

## Datakilder

| Lag | Kilde | Lisens |
|---|---|---|
| topokart | WMTS `https://cache.kartverket.no/v1/wmts/1.0.0/WMTSCapabilities.xml`, lag `topo` (evt. `topograatone` som dempet variant), TileMatrixSet **EPSG:25833** | CC BY 4.0 |
| eiendomsgrenser | WMS `https://wms.geonorge.no/skwms1/wms.matrikkelkart?service=wms&request=getcapabilities` — lagnavn fra capabilities (grenser/teig) | CC BY 4.0 |
| hillshade (valgfritt) | WCS DOM1 `https://wcs.geonorge.no/skwms1/wcs.hoyde-dom-nhm-25833?service=wcs&request=getcapabilities` → GeoTIFF for bbox → egen hillshade i numpy | CC BY 4.0 |

## STEG 0

1. Les WMTS-capabilities: TileMatrixSet for 25833 (origo, tile-størrelse, skala per nivå), og finn
   nivået som gir **≈ 0,2–0,4 m per piksel** (trolig nivå 17–18). Skriv tabellen i `docs/datakilder.md`.
2. Les matrikkelkart-WMS-capabilities: lagnavn for eiendomsgrenser, støttet CRS (25833), format
   (`image/png` med transparens?), maks bildestørrelse.
3. Test WCS DOM1 for en 100 × 100 m bbox: format (`image/tiff`), oppløsning, svartid. Hvis WCS
   er treg (> 4 s) eller ustabil, gjør hillshade **av som standard** (SPØRSMÅL).
4. Ta opp fixtures: 4 topo-fliser, ett WMS-svar, ett WCS-svar (små) i `tests/fixtures/background/`.

## Kontrakt

```
GET /roof/background?east=262010.5&north=6649120.2&size_m=80&px=1600&layers=topo,eiendom[,hillshade]
→ 200 image/png  (+ header X-Roof-Geo: JSON)
X-Roof-Geo: { "epsg": 25833, "east0": 261970.5, "north0": 6649080.2,   // SØRVESTRE hjørne
              "width_m": 80.0, "height_m": 80.0, "px": 1600,
              "m_per_px": 0.05, "layers": ["topo","eiendom"],
              "attribution": "Kartgrunnlag © Kartverket (CC BY 4.0)",
              "fetched_at": "2026-09-24T10:11:12Z" }
```
Også `GET /roof/background.json?…` som returnerer samme geo-objekt + `"png_base64"` — klienten
bruker denne (enklere enn å lese headere, og Varmeplan lagrer bakgrunner som dataUrl uansett).
`size_m` ∈ {40, 60, 80, 120, 200}; `px` ≤ 2400. Utsnittet **snappes** slik at `east0/north0` er
runde til 0,01 m og bildet er nøyaktig kvadratisk.

## Gjør

1. `app/geo/wmts.py`: regn hvilke fliser (kolonne/rad) som dekker bbox på valgt nivå, hent
   parallelt (`asyncio.gather`, maks 8 samtidige), lim sammen med Pillow, klipp til bbox,
   resample til `px` (LANCZOS). Disk-cache per flis (`CACHE_DIR/tiles/<z>/<x>/<y>.png`, 30 dager)
   — fliser er det som gjør neste kall raskt.
2. `app/geo/wms.py`: ett GetMap-kall for bbox i 25833, transparent PNG, komponeres oppå.
3. `app/geo/dom1.py` (bak flagget `hillshade`): WCS GetCoverage → GeoTIFF (rasterio) → hillshade
   (azimut 315°, høyde 45°) → halvtransparent grå oppå topo. Feiler WCS → hopp over laget, svar
   likevel (og sett `layers` i geo-objektet til det som faktisk kom med).
4. Kreditering brent inn i nedre høyre hjørne (liten hvit boks, 10 px tekst) **og** i geo-objektet.
5. `app/api/background.py` + modell. Rate-vern: maks 4 samtidige bakgrunnskall per prosess
   (semafor) — vi er høflige mot Kartverket.
6. Tester (fixtures): flisvalg for kjent bbox (riktige x/y), sammensatt bilde har riktig px-størrelse
   og geo-objekt med eksakt `width_m`; WMS-feil → topo alene + `layers` uten `eiendom`; ugyldig
   `size_m` → 422.
7. Røyk-test manuelt: kjør tjenesten, hent bilde for testadressen fra 002, åpne PNG-en og se at
   huset ligger midt i og at nord er opp. Legg PNG-en i `docs/eksempler/`.
8. Commit: «003: /roof/background — georeferert kartutsnitt (topo + eiendomsgrenser [+ hillshade])».

## Skal IKKE

- Bruke Google-kart/-fliser eller Norge i bilder.
- Tegne bygningsomriss inn i bildet — de kommer som vektorer i 006 (så de kan snappes til).

## Rapport (STATUS.md)

- Valgt WMTS-nivå og faktisk m/px; svartid kaldt/varmt; om hillshade ble standard av/på.
