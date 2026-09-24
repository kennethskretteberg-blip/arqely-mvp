# SPØRSMÅL til Kenneth — samles under kjøringen, besvares til slutt

Skriv ett punkt per spørsmål. Ta med **ditt midlertidige valg** (det du gikk videre med) så Kenneth
bare trenger å si «ok» eller «nei, gjør X».

## Kenneth må gjøre (kan ikke gjøres av Claude Code)

- [ ] **Fly-deploy av `varmeplan-roof`**: `fly auth login` → `fly launch --no-deploy --copy-config
      --name varmeplan-roof` → `fly secrets set ROOF_API_KEY=<lang tilfeldig streng>` → `fly deploy`.
      (Forberedt i 001. Til da kjører alt mot `localhost:4100`.)
- [ ] **App-nøkkel i klienten**: hvor skal nøkkelen ligge? Midlertidig valg i 005: `localStorage`
      `varmeplan_roof_key` (dev) + `window.VARMEPLAN_ROOF_KEY` (deploy). Alternativ: kolonne på
      `organizations` i Supabase så den følger org-en.

## Avklaringer (midlertidig valg står i parentes)

- [x] Bygningsomriss-kilde: **avgjort 24.09** — kun CC BY 4.0: INSPIRE → DOM1-avledet (004) →
      brukeren tegner. OSM (ODbL) brukes ikke. *(Gjenstår: send e-posten til Kartverket om
      INSPIRE-status — utkast i `varmeplan-roof/docs/epost-kartverket-inspire.md` etter 002.)*
- [ ] Ble INSPIRE-WFS verifisert live under 002, eller kjørte testene på syntetisk fixture?
      *(Claude Code fyller ut.)*
- [ ] Standard utsnitt rundt adressen: *(valg: 80 × 80 m, valg 60/80/120 i dialogen)*.
- [ ] Skal eiendomsgrenser tegnes som standard? *(valg: ja, tynn oransje, kan skjules)*.
- [ ] Skal DOM1-hillshade (skyggelagt høydemodell) ligge i kartbildet? *(valg: av som standard,
      bryter i dialogen — det tar 1–3 s ekstra)*.

## Oppdaget underveis

### Fra 001

- [ ] **Kontakt-e-post i User-Agent.** Kartverket ber om en identifiserbar klient. Midlertidig
      valg: `varmeplan-roof/0.1 (+kontakt@varmeplan.no)` i `ROOF_USER_AGENT`. **Er det en adresse
      som faktisk leses?** Hvis ikke, oppgi riktig — det er den de kontakter hvis vi lager for mye
      trafikk, så feil adresse betyr at vi blir blokkert uten forvarsel.
- [ ] **Docker er ikke installert på maskinen** → `Dockerfile` er skrevet, men *aldri bygget*.
      Fly bruker remote builder, så `fly deploy` vil fungere uten lokal Docker — men første deploy
      er også første gang dockerfila kjøres. Midlertidig valg: ingen apt-pakker (alle wheels er
      manylinux med bundlede GEOS/PROJ/GDAL). Klager bygget på en manglende `.so`, legg den til
      i `Dockerfile` og noter i endringsloggen.
- [ ] **`mypy` utelatt** (lumelo har det). Midlertidig valg: `ruff` alene. Si fra hvis du vil ha
      typesjekk på denne tjenesten også.
- [x] **`rasterio`-wheel:** installerte rent på Python 3.12 — `tifffile`-reserveplanen fra 001
      er ikke nødvendig. Ingen systempakker kreves.
