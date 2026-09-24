# 001 · Nytt repo `varmeplan-roof` — skjelett, nøkkel, tester, dokumentasjon

**Repo:** `~/Code/varmeplan-roof` (**opprettes**) · **Størrelse: liten** · Del av serien «Stedfestet tegneflate» (les `000-KJØR-MEG.md` først)

## Mål

En kjørbar FastAPI-tjeneste med `GET /health`, app-nøkkel, CORS, strukturert logging, tester og
deploy-filer — så 002–004 bare legger til endepunkter. Mønsteret er `~/Code/lumelo-backend`
(FastAPI, Pydantic 2, `uv`, Fly.io `arn`, scale-to-zero). **Kopier mønsteret, ikke koden** — lumelo
skal ikke røres, og roof-tjenesten skal ikke arve ifcopenshell/PyMuPDF/ezdxf.

## STEG 0

1. Les `~/Code/lumelo-backend/pyproject.toml`, `fly.toml`, `Dockerfile`, `app/main.py`,
   `app/core/config.py` (CORS-liste, settings-mønster) og `tests/conftest.py`. Noter hva som er
   verdt å gjenbruke (settings via `pydantic-settings`, structlog, `uv sync --frozen`).
2. Sjekk at `uv` og Python 3.12 finnes lokalt (`uv --version`, `uv python list`).
3. Sjekk at port 4100 er ledig.

## Gjør

1. `git init` i `~/Code/varmeplan-roof`. Struktur:
   ```
   app/            main.py  core/{config,logging,auth}.py  api/__init__.py
   app/geo/        __init__.py            (adaptere kommer i 002–004)
   app/models/     __init__.py            (Pydantic-kontrakter kommer i 002–004)
   tests/          conftest.py  test_health.py  fixtures/.gitkeep
   scripts/        record_fixtures.py     (tom skall — fylles i 002)
   docs/           endringslogg.md  README.md
   pyproject.toml  uv.lock  Dockerfile  fly.toml  .gitignore  .env.example
   ```
2. **Avhengigheter** (kun rene pip-wheels — ingen PDAL/GDAL/open3d): `fastapi`, `uvicorn[standard]`,
   `pydantic>=2.7`, `pydantic-settings`, `structlog`, `httpx`, `shapely>=2`, `pyproj`, `numpy`,
   `pillow`, `rasterio` (for DTM/DOM i 004 — sjekk at wheel finnes for python 3.12 på Linux/macOS;
   hvis ikke, bytt til `tifffile` + egen GeoTIFF-lesing og skriv det i SPØRSMÅL). Dev: `pytest`,
   `pytest-asyncio`, `httpx`, `respx` (mock av httpx-kall i tester), `ruff`.
3. **Settings** (`app/core/config.py`): `ROOF_API_KEY` (str, tom i dev), `ROOF_DEV` (bool),
   `CORS_ORIGINS` (liste; default `http://localhost:3000, http://localhost:4000,
   https://arqely.com, https://varmeplan.no` — sjekk lumelo sin liste og speil den),
   `CACHE_DIR` (default `./.cache`), `USER_AGENT` (`varmeplan-roof/0.1 (+kontakt@…)` — Kartverket
   ber om identifiserbar klient; sett en placeholder-e-post og legg i SPØRSMÅL).
4. **Nøkkel** (`app/core/auth.py`): dependency som krever header `X-Varmeplan-Key == ROOF_API_KEY`
   på alle `/roof/*`-ruter. Når `ROOF_DEV=1` **og** nøkkelen er tom → slipp gjennom, logg én
   advarsel ved oppstart. `/health` er alltid åpen.
5. `GET /health` → `{ "ok": true, "service": "varmeplan-roof", "version": "0.1.0" }`.
6. **Logging**: structlog JSON, én linje per request (metode, sti, status, ms).
7. **Tester**: `test_health.py` (200, felt), `test_auth.py` (401 uten nøkkel når nøkkel er satt;
   200 i dev-modus). `pytest` grønn.
8. **Deploy-filer**: `fly.toml` (`app = "varmeplan-roof"`, `primary_region = "arn"`, scale-to-zero,
   `memory = "1gb"`, port 8000), `Dockerfile` (uv-image, `uv sync --frozen --no-dev`, ingen
   apt-pakker med mindre rasterio krever det — test bygget lokalt med `docker build` hvis Docker
   finnes; ellers skriv i STATUS at bygget ikke er verifisert).
9. `docs/README.md`: hva tjenesten er, hvordan kjøre lokalt
   (`uv run uvicorn app.main:app --port 4100 --reload`), miljøvariabler, deploy-kommandoer
   (for Kenneth), lisensnotat (CC BY 4.0, kreditering). `docs/endringslogg.md` med første innslag.
   `.env.example` med `ROOF_DEV=1`.
10. Commit: «001: varmeplan-roof — skjelett, nøkkel, tester, deploy-filer».

## Skal IKKE

- Røre lumelo-backend eller arqely-mvp.
- Deploye til Fly (Kenneth gjør det — se SPØRSMÅL).
- Legge inn noe Kartverket-kall ennå.

## Rapport (i STATUS.md)

- Hva som ble kopiert fra lumelo-mønsteret, og hva som bevisst ble utelatt.
- Om `rasterio`-wheel installerte rent; om Docker-bygg ble verifisert.
