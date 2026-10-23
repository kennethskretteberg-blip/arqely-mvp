# 125 — Materialliste: foliemengde (meter per produkt) i tilbehørsdialogen, justerbar og lagret

Kjørt 23.10.2026 på `main` fra `6c32745`. Pushet som `89c1cd7`. Skjermbilder i `skjermbilder/` (headless Chrome,
fikstur med to folieprodukter i tre rom, dialogen åpnet direkte med `showAccessoriesModal()`).

## STEG 0 — lest før endring

### 0.1 Hvor foliemengden ble regnet
Ikke tre steder, men **fire**, og de regnet **ikke likt**:

| Flate | Funksjon | Mengde før 125 |
|---|---|---|
| PDF-materialliste | `exportPDF` (egen `matList`-løkke over `S.strips`+`S.foilFree`) | `(totalLen/100).toFixed(1)` → «47.3 m» (desimal) |
| XLSX «Bestilling» | `_exportMaterialListXLSX` via `_aggregateMaterialItems` | `${count} stk · ${totalLen.toFixed(1)} m` → «3 stk · 47.3 m» |
| Kopier til Visma | `_vismaPasteBuild` | `Math.ceil(totalLen)` → 48 |
| Visma-fil (GBAO10) | `_gbao10Build` | `Math.ceil(totalLen)` → 48 |

Altså: Visma/GBAO10 rundet opp til hele meter, PDF og XLSX viste desimaltallet. Ingen felles funksjon.
PDF-en hadde i tillegg sin egen aggregering (alle strips, også i utkast-rom), mens de tre andre leste
`_collectMaterialItems` (utkast-rom ekskludert, fri folie inkludert).

### 0.2 Formen på en rad i `S.project.accessories.items`
`{ id, name, art_no, el_no, unit, qty, source: 'auto'|'manual'|'rkk', type: 'foil'|'cable'|'mat', rooms?, flag? }`.
Leserne filtrerer på `it.type || 'foil'` (PDF og XLSX: grupper «foil»/«cable», resten til «annet») og
`_aggregateAccessoryItems` aggregerer per `it.id` (Visma, GBAO10, XLSX Bestilling). En rad med
`type: 'foilProduct'` ville derfor **ikke** forstyrret de kjente gruppene — men den ville havnet i
«Tilbehør — annet» og blitt limt inn i Visma som en ekstra varelinje med samme artikkelnummer.
Løst ved at `_aggregateAccessoryItems` hopper over `foilProduct`, og PDF/XLSX leser `_accessoryOnly(items)`.
`savedById` er nøkkeldrevet på `id`, så folieradene bruker `foil_product_<productId>`.

### 0.3 Lagret tall mot nytt forslag
For tilbehør vinner lagret alltid (bevisst, `renderRow`). For folien er det farlig fordi Visma-pasten og
GBAO10 **gjenbruker lagret valg uten å åpne dialogen** (`_showVismaPasteDialog`, `_showGbao10ExportDialog`):
et tall bekreftet mot 48 m ville stått selv om tegningen nå gir 55 m — bestilt for lite, i stillhet.
Valget er beskrevet under «Gjort».

## Gjort

- **Ny seksjon «Varmefolie (meter)» øverst i dialogen** (skjermbilde `01`): én rad per folieprodukt med
  navn, «tegnet 47,3 m i 2 rom», «forslag: 48 m», tallfelt i hele meter (min 0) og knappene **+1 m** /
  **+5 m** (skjermbilde `02`: 48 → 54).
- **Lagring:** `{ type: 'foilProduct', productId, qty, autoQty, drawnM, … }` i `S.project.accessories.items`,
  samme plass som tilbehøret. `autoQty` er forslaget raden ble bekreftet mot. Raden lagres **også ved 0**
  (tilbehør med 0 lagres ikke) — 0 er et bevisst valg som skal huskes.
- **Forhåndsutfylling i dialogen:** lagret ≥ forslag → lagret (skjermbilde `03`: 54). Lagret < forslag →
  **forslaget** med gul merknad «Tegnet mengde har økt siden sist (var 54 m)» (skjermbilde `04`: tegning
  vokst til 59,3 m → 60). Har tegningen ikke vokst, men brukeren bevisst valgt lavere, er merknaden
  «Lagret N m er under beregnet mengde» — feltet viser forslaget uansett, så tallet aldri står under
  beregnet mengde uten at brukeren ser det.
- **Én kilde:** `_foilOrderQtyM(productId, accItems, drawn?)`. Alle fire eksportene leser den; de fire
  kopiene av regnestykket er borte. Forslaget regnes i `_foilSuggestQtyM` (tegnet lengde avrundet til mm,
  så opp til hele meter — `48,0000000001` blir 48, ikke 49). Tegnet mengde per produkt kommer fra
  `_foilDrawnByProduct()` (over `_collectMaterialItems`, som fikk `roomId` på folieraden).
- **Regelen i `_foilOrderQtyM` for veier uten dialog** (STEG 0.3): brukerens tall gjelder hvis det er
  ≥ forslag. Er det lavere, gjelder det bare når forslaget ikke har økt siden tallet ble bekreftet
  (`forslag ≤ autoQty`) — ellers vinner forslaget. Slik blir et bevisst 0 («kunden har folie») respektert
  i Visma/GBAO10 uten dialog, mens en tegning som har vokst aldri gir en for lav bestilling i stillhet.
  Rad uten `autoQty` (finnes ikke i praksis) behandles som ukjent historikk → forslag.
- **PDF-materiallista** viser nå hele meter (f.eks. «48 m», før «47.3 m»), samme tall som XLSX/Visma.
  XLSX Bestilling viser «48 m» (før «3 stk · 47.3 m»). 0 m → ingen linje i alle fire.
- **Tilbehør som regnes av folien** (tape, underlagsplate, klemmer, Kapton, RKK): uendret, leser
  `foilCtx` (strips/areal) — altså **tegnet** mengde, ikke det justerte tallet. Det stemmer med
  virkeligheten (tapen går med til det som legges, ikke til reserven på rullen), og slik var det før.
  Synlig på skjermbilde `04`: «Tilkoblingsklemme AMP forslag: 12» følger 6 strips, ikke 60 m.
- Dialogen hoppes over som før når prosjektet ikke har varme (skjermbilde `05`: kun kabel → ingen
  folie-seksjon, dialogen som før).

## Test

| Nr | Krav | Resultat |
|---|---|---|
| 1 | To folieprodukter (50/30 cm) i tre rom: to rader, forslag 48 og 19 = `Math.ceil(totalLen)` som Visma ga før | ✓ (`01`) |
| 2 | 48 → 54 (via +1/+5): Visma 54, GBAO10 54, XLSX «54 m», PDF «54 m»; åpne på nytt → 54 foreslås | ✓ (`02`, `03`, regresjonstest med 55) |
| 3 | Mer folie → forslag 60: feltet viser 60 med gul merknad, ikke 54 | ✓ (`04`) |
| 4 | +1 m / +5 m virker; 0 m gir ingen linje | ✓ (DOM + regresjonstest i alle fire eksporter) |
| 5 | Prosjekt uten folie: ingen seksjon | ✓ (`05`) |
| 6 | `_pdfExportSmokeTest` grønn (20/20); ny `_accessoryFoilQtyRegressionTest()` grønn (38/38) | ✓ |

`_accessoryFoilQtyRegressionTest()` (async, kjør med `await` i konsollen) dekker: avrunding, tegnet
mengde per produkt, alle grenene i `_foilOrderQtyM` (uten lagret, ≥, =, bevisst lavere, 0, uten
`autoQty`, tegning vokst), at folieradene ikke lekker inn som tilbehør, og **én kilde i fire eksporter**
(Visma-paste, GBAO10, XLSX Bestilling via stubbet `XLSX`, PDF via stubbet `jsPDF` med tekstfangst) —
pluss en vaksine som bytter ut `_foilOrderQtyM` og krever at Visma-linja følger med.

## Funn utenfor scope (ikke rørt)

- `_assertProductSurfacesCoverAllCollections` logger ved oppstart på dev-vert at
  `_exportMaterialListXLSX` «nevner ALDRI strips/foilFree/cables/…». Den feiler også på `6c32745` uten
  125 — XLSX-eksporten leser alt via `_collectMaterialItems`, som sjekken ikke kjenner. Enten bør
  `_collectMaterialItems` inn i `ROOM_PRODUCT_SURFACE_PATTERNS`, eller sjekken bør følge kallet.
- PDF-ens egen `matList`-løkke teller strips i utkast-rom (`listDraft`), mens `_collectMaterialItems`
  ekskluderer dem. Folieraden i PDF-en følger nå den siste (én kilde). Utkast-rom har i praksis ikke
  strips, så ingen synlig endring, men de to tellingene er fortsatt to.
- PDF-tilbudsdelen (`opts.pricing`) priser folie per **stripe** (`info.count`), ikke per meter. Uendret.

## Endrede symboler
`_collectMaterialItems` (roomId på folierad) · `_aggregateAccessoryItems` · nye `_foilDrawnByProduct`,
`_foilSuggestQtyM`, `_foilAccId`, `_foilOrderQtyM`, `_accessoryOnly`, `_accessoryFoilQtyRegressionTest` ·
`showAccessoriesModal` (seksjon, +-knapper, lagring) · `exportPDF` (materialliste) ·
`_exportMaterialListXLSX` (Bestilling + tilbehørsfilter) · `_vismaPasteBuild` · `_gbao10Build`.
