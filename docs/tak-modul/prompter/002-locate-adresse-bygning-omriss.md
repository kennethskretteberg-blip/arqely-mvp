# 002 · `/roof/locate` — adresse → punkt → bygning(er) → omriss

**Repo:** `~/Code/varmeplan-roof` · **Størrelse: middels** · Forutsetter 001

## Mål

Ett kall som gir klienten alt den trenger for å vise «hvilket bygg mener du?»: adressens punkt i
EPSG:25833, bygningspunkt(er) fra Matrikkelen i nærheten, og bygningsomriss (2D-polygon) for hvert.
Alle koordinater ut som **meter i EPSG:25833** pluss lat/lon for visning.

## Datakilder (alle uten nøkkel — verifisert i tak-planen §3)

| Steg | Kilde | Kall |
|---|---|---|
| adresse → punkt | Kartverket adresse-API | `GET https://ws.geonorge.no/adresser/v1/sok?sok=<tekst>&utkoordsys=25833&treffPerSide=10` (bekreft `utkoordsys`-parameteren i `https://ws.geonorge.no/adresser/v1/openapi.json`; ellers konverter 4326→25833 med pyproj) |
| bygningspunkt | Matrikkelen – Bygningspunkt WFS (CC BY 4.0) | `https://wfs.geonorge.no/skwms1/wfs.matrikkelen-bygningspunkt?service=WFS&version=2.0.0&request=GetFeature&typeNames=<fra GetCapabilities>&bbox=<E1,N1,E2,N2,EPSG:25833>&outputFormat=application/gml+xml` (STEG 0 finner typeName og om GeoJSON-output støttes) |
| omriss | INSPIRE Buildings core2D WFS (CC BY 4.0) | `https://wfs.geonorge.no/skwms1/wfs.inspire-bu-core2d_limited?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature&typeNames=bu-core2d:Building&bbox=…` (GML 3.2). **Kjent: svarte ikke 21.09** (to forsøk, 55 s timeout). Timeout her = 8 s, aldri mer. |
| omriss, fallback | DOM1 − DTM1 (Kartverket, CC BY 4.0) | **Bygges i 004** (den prompten eier WCS-klienten). 002 leverer bare `footprint: null` når INSPIRE ikke gir treff. |

**Avgjort 24.09 — OSM/Overpass brukes ikke.** ODbL har share-alike på avledede databaser, og et
bygningsomriss som lagres i et kundeprosjekt *er* avledet data. Vi holder hele datavegen på
CC BY 4.0 (Kartverket) + brukerens egne tegninger. Ingen `osm_overpass.py`, ingen ODbL-kreditering.
Kandidatlista trenger ikke omriss for å være nyttig: Matrikkelens bygningspunkt gir type, status
og avstand — det holder for «hvilket bygg mener du?». Omrisset er en bonus (snapping i 006).

Bygningsnummer finnes i bygningspunktet, ikke i adresse-API-et — kobling er geografisk:
bygningspunkt innen 40 m fra adressepunktet, sortert på avstand; omriss = polygonet som inneholder
bygningspunktet (eller nærmeste innen 5 m).

Kjeden for `footprint.source` etter 004 er kjørt: `'INSPIRE'` (confidence 0,9) → `'DOM1'`
(0,5, ~1 m nøyaktighet, kan ta med trær inntil veggen — se 004) → `null` (klienten sier «tegn
omrisset selv»). 002 implementerer de to ytterpunktene; 004 fyller midten via en felles
`resolve_footprint(point, bbox)` som 002 legger klar med en tydelig `# TODO(004): DOM1-fallback`.

## STEG 0

1. Hent GetCapabilities for de to WFS-ene, noter `typeNames`, støttede `outputFormat`, om `bbox`
   med `EPSG:25833` aksepteres, og maks antall features. Skriv funn i `docs/datakilder.md`.
2. Gjør ett ekte kall per kilde på en kjent adresse (bruk `Storgata 1, 0155 Oslo` eller Kenneths
   testadresse hvis den ligger i `SPØRSMÅL.md`) og lagre rå svar som fixtures i
   `tests/fixtures/locate/`. Dette er de eneste live-kallene; testene bruker fixtures via `respx`.
   **Svarer ikke INSPIRE-WFS innen 8 s (×2):** ikke vent. Skriv en liten **syntetisk** GML 3.2-
   fixture for hånd (ett `bu-core2d:Building` med et rektangel rundt testbyggets bygningspunkt,
   samme navnerom som GetCapabilities oppgir), merk den `SYNTETISK` i filnavnet, og noter i
   STATUS at INSPIRE ikke ble verifisert live. Parseren skal uansett tåle både treff og «nede».
3. Sjekk hvordan `S.project.address.representasjonspunkt` ser ut i Varmeplan
   (`~/Code/arqely-mvp/index.html`, `_addrSearch` ≈ :53202 og :57872) — klienten har allerede
   lat/lon; endepunktet må akseptere **både** adressetekst og `{lat, lon}`.

## Kontrakt

```
POST /roof/locate
{ "address": "Storgata 1, 0155 Oslo" }      // eller
{ "lat": 59.91, "lon": 10.75 }               // eller
{ "east": 262000.0, "north": 6649000.0 }     // EPSG:25833
→ 200
{
  "query": { "text": "...", "point": { "east":…, "north":…, "lat":…, "lon":… }, "source": "KARTVERKET_ADRESSE" },
  "candidates": [
    { "bygningsnr": "80123456", "type": "Enebolig", "status": "Tatt i bruk",
      "point": { "east":…, "north":… }, "distance_m": 8.2,
      "footprint": { "polygon": [[e,n],…], "area_m2": 121.4, "source": "INSPIRE" | "DOM1" | null,
                     "prov": { "source": "FKB"|"DOM_RASTER", "confidence": 0.9|0.5 } }   // eller footprint: null
    }
  ],
  "attribution": ["© Kartverket (CC BY 4.0)"]
}
```
`prov.source` bruker `Source`-enumen fra tak-planen §6.1 (`FKB` for INSPIRE-omriss, `DOM_RASTER`
for 004-fallbacken). `footprint` er `null` — ikke tomt objekt — når ingen kilde ga polygon.
Feil: 404 `{ "error": "no_address" }` når adressen ikke finnes; 200 med tom `candidates` når
ingen bygg innen 40 m (klienten lar brukeren tegne omriss selv).

## Gjør

1. `app/geo/kartverket_addr.py`, `app/geo/matrikkel_wfs.py`, `app/geo/footprint_wfs.py` — hver
   med én async funksjon, `httpx.AsyncClient` med `USER_AGENT`, timeout 8 s, én retry. GML parses
   med `xml.etree` (ingen ny dep) til shapely.
2. `app/geo/footprint.py`: `async def resolve_footprint(point, bbox) -> Footprint | None` — prøver
   INSPIRE; `None` ellers. Én tydelig `# TODO(004): DOM1-fallback her` — 004 legger DOM1-steget inn
   i **denne** funksjonen, ikke i API-laget.
3. `app/api/locate.py` som setter det sammen; `app/models/locate.py` (Pydantic, `footprint:
   Footprint | None`).
4. Enkel disk-cache (`CACHE_DIR/locate/<hash>.json`, 7 dager) så samme adresse ikke treffer
   Kartverket to ganger under utvikling. Cache-nøkkelen inkluderer versjon (`v1`) så 004 kan
   ugyldiggjøre gamle `null`-omriss ved å bumpe til `v2`.
5. Tester: adresse → 1 kandidat med INSPIRE-omriss; adresse uten bygg → tom liste; INSPIRE nede
   (timeout/500) → kandidater med `footprint: null` og **200**, aldri 5xx; ugyldig adresse → 404.
   Alle mot fixtures.
6. `scripts/record_fixtures.py locate "<adresse>"` som tar opp fixtures på nytt.
7. E-postutkast til Kartverket om status for INSPIRE core2D («limited» — er tjenesten ment for
   produksjonsbruk, og finnes en stabil variant?) — skriv til `docs/epost-kartverket-inspire.md`
   (kort, ydmyk tone, tre setninger + spørsmålet) og pek på det i `SPØRSMÅL.md`.
8. Commit: «002: /roof/locate — adresse → bygningspunkt → omriss (INSPIRE eller null)».

## Skal IKKE

- Hente ortofoto (lukket) eller FKB-Bygning (ikke åpne data).
- **OSM/Overpass i noen form** (avgjort, se over). Ikke som «hint», ikke bak et flagg.
- Vente på INSPIRE: nede = `null`, og serien går videre.

## Rapport (STATUS.md)

- typeNames/format som faktisk virket; om INSPIRE-WFS svarte for testadressen; svartider.
