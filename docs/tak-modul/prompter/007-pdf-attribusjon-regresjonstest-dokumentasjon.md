# 007 · PDF-kreditering, hurtigtaster, regresjonstest og dokumentasjon — avslutning av serien

**Repo:** `~/Code/arqely-mvp` (`index.html`, `docs/`, `CLAUDE.md`) + `~/Code/varmeplan-roof/docs/` · **Størrelse: liten** · Forutsetter 005–006

## Mål

Alt som gjør serien **ferdig og trygg**: lisenskravet på papir, hjelpetekster, testdekning samlet,
og dokumentasjon som gjør at neste person (eller Tak-editoren) kan bygge videre uten å lese kode.

## STEG 0

1. Les hvordan PDF-romsiden legger inn bakgrunnsbildet (`_renderRoomToImage` ≈ :48069, og romsiden
   ≈ :46896) og hvor forsiden har metadata (`_pdfCoverMetaRows` ≈ :46301).
2. Les `_SHORTCUTS` og CLAUDE.md-regelen om hurtigtaster.
3. Sjekk `docs/endringslogg.md`-formatet og at 005/006 fikk innslag.

## Gjør

### 1. Kreditering i PDF (lisenskrav CC BY 4.0)

- Hver romside der rommets etasje har `bg.geo`: liten grå linje under tegningen
  «Kartgrunnlag © Kartverket (CC BY 4.0) · hentet 24.09.2026». (Ingen OSM — avgjort 24.09;
  alle kilder er Kartverket, én kreditering holder.)
- Forsiden: én rad «Kartgrunnlag: Kartverket» i metadata når minst én etasje har `bg.geo`.
- Kartutsnitt uten produkter skal **ikke** tvinge fram en romside (samme regel som PDF-bakgrunner).

### 2. Hjelpetekster og hurtigtaster

- `_SHORTCUTS`: ny gruppe «Kart (snø)»: `['Shift']` «Tegn uten snapping til omriss»,
  `['klikk omriss']` «Bytt bygg». (CLAUDE.md-regelen: ny hurtigtast → ny rad.)
- Tom-tilstand for snø-etasje uten bakgrunn: teksten nevner «Hent fra kart» som første valg.

### 3. Tester samlet

- `_geoRegressionTest()` skal dekke 005 + 006 og kjøres som del av «fullt regresjonsbatteri» der
  de andre listes (endringslogg-mønsteret «alle regresjonstester OK»). Legg til ett tilfelle for
  lagre → gjenopprette av `S.geo` + `bg.geo` + `room.terrain`.
- I `varmeplan-roof`: `pytest` grønn, `ruff` uten feil; `scripts/record_fixtures.py` dokumentert.

### 4. Dokumentasjon

- `arqely-mvp/docs/kart-lag.md` (ny, kort): hva `bg.geo`/`S.geo`/`room.terrain` er, koordinat-
  regelen (SV-hjørne = (0,0), nord = −y), hvordan klienten finner tjenesten, hvilke ctxbar-valg
  som er skjult for geo-bakgrunner og hvorfor, og **hva Tak-editoren skal gjenbruke** (kartbilde,
  vektorlag, snapping, `_roofApi.modelQuick`).
- `arqely-mvp/CLAUDE.md`: to linjer under arkitektur: «Kartbakgrunn = vanlig `S.bgs`-objekt med
  `bg.geo`; aldri kalibrer/roter/skaler en geo-bakgrunn» og «Karttjeneste = `varmeplan-roof`, klient
  `_roofApi`, aldri direkte Kartverket-kall fra nettleseren».
- `varmeplan-roof/docs/README.md`: endepunkt-oversikt med eksempler, cache-mapper, hvordan tømme
  cache, lisens/kreditering, «Kenneth må gjøre»-listen (deploy, nøkkel).
- `varmeplan-roof/docs/roof-contract.md` fra 004 lenkes fra `planer/`-notatet? Nei — Cowork-mappa
  rører vi ikke; nevn stien i STATUS så Kenneth kan lenke selv.

### 5. Avslutning

- Oppdater `STATUS.md`: alle sju rader, commit-hasher, og seksjonen «Til Kenneth når alt er kjørt»
  sortert: (1) Fly-deploy + nøkkel, (2) omriss-lisens (INSPIRE-epost), (3) helningsregel, (4) resten.
- Commit: «007: kart-lag — PDF-kreditering, hurtigtaster, regresjonstest, dokumentasjon».

## Skal IKKE

- Endre noe i 001–006 utover det som trengs for punktene over (skriv heller i STATUS hva som bør
  bli egen sak).

## Rapport (STATUS.md)

- Antall tester i `_geoRegressionTest`; om PDF-krediteringen synes på A4 ved 300 DPI (mål mm).
