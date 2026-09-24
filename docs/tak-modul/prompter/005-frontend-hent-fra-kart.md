# 005 · Klient: `_roofApi` + «Hent fra kart» i snø-modulen — kartutsnitt som ferdig kalibrert bakgrunn

**Repo:** `~/Code/arqely-mvp` (`index.html`) · **Størrelse: middels** · Forutsetter 001–003 kjørende på `localhost:4100`

## Mål

I et snø-prosjekt: «Hent fra kart» → adresse (prosjektets adresse forhåndsutfylt) → velg bygg →
velg utsnitt (60/80/120 m) → kartbildet ligger som bakgrunn på aktiv etasje **med riktig
målestokk, uten kalibrering**, låst, med kreditering. Alt annet i appen uendret. Tjenesten nede →
en tydelig melding, ingen feil.

## STEG 0

1. Les `_resolveEngineUrl` (≈ :44969), `_engineHealthCheck` (≈ :44954), `_engineFetchWithRetry`
   — mønsteret for URL-oppløsning (override → lagret → localhost → Fly) og kaldstart-retry. Roof-
   klienten skal gjøre det samme med egne konstanter (`ROOF_FLY_URL = 'https://varmeplan-roof.fly.dev'`,
   `ROOF_LOCAL_URL = 'http://localhost:4100'`, `window.VARMEPLAN_ROOF_URL`, `localStorage
   varmeplan_roof_url`), **ikke** dele `_engineResolved`-cachen med lumelo.
2. Les bakgrunnsmodellen: `_newBgObj` (≈ :3992), `_serializeBgFields` (≈ :4008),
   `_installBgImageForFloor` (≈ :34897), `drawBgImage` (≈ :33877), `_fitViewToBg` (≈ :43143),
   gjenoppretting av `S.bgs` i `_restoreProject`. Bekreft at et bakgrunnsobjekt med
   `widthCm/heightCm` satt, `originX = 0`, `originY = −heightCm`, `_needsCalibration = false`,
   `locked = true` rett og slett *er* en kalibrert bakgrunn — ingen annen tilstand trengs.
3. Les hvor prosjektets adresse ligger: `S.project.address = { text, representasjonspunkt }`
   (≈ :57872, satt via `_addrSearch` ≈ :53202). Hva er koordinatsystemet i `representasjonspunkt`
   (lat/lon, EPSG:4258?) — send det som `{lat, lon}` til `/roof/locate`.
4. Finn hvor snø-modulens etasjerad tegnes (`_renderSnowPartContent` ≈ :35916, «Legg til område»)
   og bakgrunnens ⋯-meny (`_bgSelMore`) — der skal knappen inn.
5. Sjekk `_moduleContext`/`_isSnowModule()` så knappen bare vises i snø (og senere tak).

## Gjør

### 1. `_roofApi` (klient-lag, ett sted)

```js
const ROOF_FLY_URL = 'https://varmeplan-roof.fly.dev', ROOF_LOCAL_URL = 'http://localhost:4100';
async function _roofResolveUrl(force) { /* som _resolveEngineUrl, egne konstanter/cache */ }
function _roofKey() { return window.VARMEPLAN_ROOF_KEY || localStorage.getItem('varmeplan_roof_key') || ''; }
async function _roofFetch(path, opts) { /* header X-Varmeplan-Key, kaldstart-retry som _engineFetchWithRetry,
                                          kaster RoofError{kind:'offline'|'auth'|'http'|'nodata'} */ }
const _roofApi = {
  locate: (q) => _roofFetch('/roof/locate', { method:'POST', body: q }),
  background: (p) => _roofFetch('/roof/background.json?' + new URLSearchParams(p)),
  slope: (polygon) => _roofFetch('/roof/slope', { method:'POST', body: { polygon, epsg: 25833 } }),
  modelQuick: (footprint) => _roofFetch('/roof/model?level=quick', { method:'POST', body: { footprint, epsg: 25833 } }),
};
```
Feilmeldinger på norsk, én per `kind`: «Karttjenesten svarer ikke (starter den lokalt?)», «Mangler
nøkkel til karttjenesten», «Fant ikke adressen», «Ingen bygg innen 40 m — tegn omrisset selv».

### 2. Geo-koblingen på bakgrunnen

Nytt felt `bg.geo = { epsg: 25833, east0, north0, widthM, heightM, mPerPx, layers, attribution,
fetchedAt }` (fra `X-Roof-Geo`/`background.json`). **Serialiseres** i `_serializeBgFields` og
gjenopprettes. Hjelpere:
```js
function _geoToWorld(bg, east, north) { return { x: (east - bg.geo.east0) * 100, y: -(north - bg.geo.north0) * 100 }; }
function _worldToGeo(bg, wx, wy)     { return { east: bg.geo.east0 + wx / 100, north: bg.geo.north0 - wy / 100 }; }
```
Regel: sørvestre hjørne = verdens (0,0); nord = negativ y (verdens-Y øker nedover, som i dag).
Bakgrunnen installeres med `originX = 0`, `originY = −heightCm`, `widthCm = widthM·100`,
`heightCm = heightM·100`, `rotation = 0`, `locked = true`, `_needsCalibration = false`,
`fileName = 'Kart ' + adresse`, `paperWidthCm = null`. Én etasje = ett utsnitt (vanntett-regelen
står — «Hent fra kart» på en etasje som alt har bakgrunn går via samme Bytt/Ny versjon-dialog som
i `8bdf684`).

### 3. Dialogen «Hent fra kart»

- Inngang: knapp «🗺 Hent fra kart» i snø-etasjeraden ved «Legg til plantegning», i bakgrunnens
  ⋯-meny, og i tom-tilstanden for et snø-område uten bakgrunn.
- Steg 1: adressefelt (forhåndsutfylt fra `S.project.address.text`, samme søk som `_addrSearch`)
  → `_roofApi.locate`.
- Steg 2: kandidatliste «Enebolig · 8 m unna · 121 m²» (velg én; ingen kandidater → «Fortsett uten
  bygg» = utsnitt rundt adressepunktet). `footprint: null` → «Enebolig · 8 m unna · omriss
  mangler» — kandidaten kan fortsatt velges (utsnittet sentreres på bygningspunktet).
- Steg 3: utsnitt 60 / **80** / 120 m, brytere «Eiendomsgrenser» (på) og «Terrengskygge» (av).
- «Hent» → spinner («Henter kart fra Kartverket …») → `_roofApi.background` → installer bakgrunn →
  `_fitViewToBg` → `S.geo[floorId] = { center, candidates, chosen }` (vektorene brukes i 006) →
  toast «Kart hentet — 80 × 80 m, © Kartverket». Escape/Avbryt overalt.
- Lagre den valgte kandidaten (`bygningsnr`, `footprint` i **verdens-cm** via `_geoToWorld`) på
  `S.geo[floorId]` — serialiseres i `_buildSaveData` som `geo` (F4a-sjekklisten: lagring,
  gjenoppretting, dupliser etasje/rom-registre der det gir mening, `delFloor` rydder).

### 4. Ctxbar og lås

- Bakgrunnens ctxbar viser «🗺 Kart · 80 m · © Kartverket» i stedet for «⚠ ikke kalibrert»/mål,
  og **skjuler** kalibrerings-/skaler-/roter-/speilvend-valg for geo-bakgrunner (de ville
  ødelegge målestokken). «Fjern» og opacity beholdes. «Bytt plantegning» erstattes av «Hent nytt
  utsnitt».
- Prosjekt uten snø: knappen finnes ikke; ingen endring.

## Tester

- Ny `_geoRegressionTest()` (samme mønster som `_foilRegressionTest`): `_geoToWorld`/`_worldToGeo`
  rundtur på 5 punkter (< 0,01 cm), bakgrunn fra et syntetisk geo-svar får riktig `widthCm`/`originY`,
  `_serializeBgFields` → gjenoppretting bevarer `geo`, lagre → åpne beholder `S.geo`.
- Manuelt: tjeneste **av** → «Hent fra kart» gir offline-melding, ingen konsollfeil. Tjeneste på →
  full flyt på testadressen; huset i midten; ctxbar viser kreditering; `_foilRegressionTest()` og
  `_matRegressionTest()` uendret.

## Skal IKKE

- Kartbibliotek (leaflet/openlayers), live pan/zoom av kart — bildet er statisk, det er poenget.
- Endre kalibreringsflytene for vanlige PDF-bakgrunner.
- Vise noe i innendørs-modulen.

## Commit / rapport

Commit: «005: Hent fra kart — georeferert bakgrunn i snø-modulen (_roofApi, bg.geo)».
STATUS: hvor nøkkelen ble lagt (SPØRSMÅL), koordinatsystem for `representasjonspunkt`, om
Bytt-dialogen fra `8bdf684` lot seg gjenbruke rett av.
