# Romtegner Project History

## 2026-03-14: Auto-fill comparison UI + obstacle-aware strip placement
- **Strip rendering clips around obstacles**: `drawStrips()` uses `evenodd` clip path to subtract obstacle polygons — strips never render visually over obstacles
- **Cold zones pushed to walls**: `_centerStripDefs()` detects obstacle positions and pushes cold zones toward the farthest wall. `_obstacleAwareFill()` and `_fillZone()` also push strips tight against obstacles
- **Both-direction auto-fill comparison**: New `_autoFillBothDirections()` runs all strategies (greedy, beam search, zone-fill, obstacle-aware) for both H and V directions
- **Comparison panel UI**: Floating panel (`showAutoFillComparison()`) shows both options with stats (strip count, coverage %, watt, W/m²), ★ marks best option
- **Preview rendering**: Blue dashed preview strips on canvas when hovering/selecting an option before applying
- **UI wiring**: Product menu buttons now call `showAutoFillComparison` instead of `startAutoFill`
- Commit: `efdcd77`

## 2026-03-08: Initial setup and migration
- Renamed local branch `master` -> `main`
- Connected local repo to GitHub remote `kennethskretteberg-blip/arqely-mvp`
- Force-pushed romtegner code (replaced old Next.js boilerplate)
- Changed Vercel build settings: Next.js -> Other (static), Output Directory: `.`
- Added custom domains: `arqely.com` (redirect to www) + `www.arqely.com` (production)
- DNS records provided to user for configuration at domain registrar
- Verified deployment works: `arqely-mvp.vercel.app/romtegner.html` loads correctly

## 2026-03-08: Background drawing improvements
- Added fileName tracking to background objects for smart replacement
- Same filename replacement preserves position, scale, and opacity
- Rooms auto-assign to active floor when created from canvas/top button
- fileName persisted in project save data

## 2026-03-08: Cursor fix for Shift+pan in draw mode
- Panning mouseup handler now restores `crosshair` cursor when in any drawMode (not just WBW)
- Space keyup handler also restores `crosshair` for all draw modes
- Affected lines: mouseup (~7742) and keyup Space (~8047)

## 2026-03-08: Standard button pattern for all modals (`.floor-choice-btn`)
- All modal choice buttons changed from `btn-acc`/`btn-ghost` to `floor-choice-btn`
- Buttons are neutral by default, turn blue on `:focus` (Tab or click)
- Enter triggers the focused button via `onkeydown` on container
- Applied to: `#np-screen`, `#modal-room1`, `#modal-shape`, `#modal-hindring`, `#modal-rect`, `#modal-lshape`, `#modal-floor`, `#modal-bg-calib`

## 2026-03-08: BG panel made draggable + always visible on import
- BG panel restructured with `.bg-handle` drag header and `.bg-body` wrapper
- Uses `_initPaletteDrag()` for drag functionality
- `showBgPanel()` / `hideBgPanel()` functions added
- Panel auto-shows when background image is imported
- Position state stored in `S.ui.bgPanelPosX` / `bgPanelPosY`

## 2026-03-08: Draw toolbar made persistent + calibration warning
- Draw toolbar stays visible after floor creation (not hidden on ESC/exitDrawing)
- `showDrawToolbar()` called from `_createFloor()`, `_restoreProject()`, `closeModal()`, `exitDrawing()`
- Calibration warning (`#dt-calib-warn`) shows when bg exists but `widthCm === 0`
- Warning has "Ignorer" and "Sett målestokk" buttons

## 2026-03-08: 3-section Action Bar (replaces floating panels)
- **Replaced** floating `#bg-panel` and `#draw-toolbar` with unified `#action-bar`
- Action bar sits between `#topbar` and `#content` in DOM — never overlaps anything
- Three sections:
  1. **🗺 Bakgrunn** — visible only when bg image exists. Controls: visibility checkbox, opacity slider, Målestokk, Bytt, Fjern
  2. **✏️ Rom** — always visible when floor exists. Room name input + shape buttons
  3. **🛒 Produkter** — Importer (Excel) and Legg til buttons
- **Context-aware room buttons:** With bg imported → only canvas-click shapes (Rektangel/rect2, Polygon, Yttervegg). Without bg → all shapes incl. L-form and WBW
- **Calibration warning** (`#ab-calib-warn`) shown inline when uncalibrated bg
- New functions: `updateActionBar()`, `abStartDraw(shape)`
- Old `showBgPanel()`, `hideBgPanel()`, `showDrawToolbar()` kept as wrappers that call `updateActionBar()`
- `updateActionBar()` called from: `_createFloor()`, `_restoreProject()`, `closeModal()`, `exitDrawing()`, `setActiveBgFloor()`, `_installBgImage()`, `removeBgImage()`, `openBgImportPanel()`, `showAddRoomModal()`
- `_resetToNpScreen()` hides action-bar directly

## 2026-03-08: Five usability fixes for Action Bar & calibration

### Fix 1: Rect2 room starting offset from cursor
- **Root cause:** `canvas.height` didn't match `canvas-wrap.clientHeight` after action bar appeared
- Action bar took 36px from layout but `resizeCanvas()` wasn't called
- **Fix:** Added `resizeCanvas()` call at end of `updateActionBar()`

### Fix 2: Post-calibration hint
- Added `#ab-hint` element inside action bar
- After calibration completes, shows "✅ Kalibrert — velg romtype →" for 8 seconds
- Auto-scrolls into view with `scrollIntoView({ inline:'nearest' })`
- Focuses and selects room name input after calibration

### Fix 3: Redesigned calibration distance inputs
- Split into two fields: `#bg-calib-dist` (meters) + `#bg-calib-dec` (decimals)
- Monospace font (`DM Mono`), 20px size, 80px+56px widths
- Prominent comma separator (22px bold, accent color)
- Unit label (`#bg-calib-unit-lbl`) synced by `setCalibUnit()`
- `confirmBgCalibrate()` combines both fields: `parseInt(dist) + parseInt(dec)/100`

### Fix 4: Auto-select input values on focus
- Global `focusin` event listener on `document`
- Targets `input[type=number]` and `input[type=text]`
- Uses `setTimeout(() => el.select(), 0)` for cross-browser compat
- Opt-out via `data-no-auto-select` attribute

### Fix 5: Product import hidden by default
- `#ab-import-prod` button has `style="display:none"` in HTML
- Ctrl+Shift+M master toggle controls visibility of both sidebar and action bar import buttons

## 2026-03-08: Replace Action Bar with Canvas Context Menu
- **Removed** permanent `#action-bar` (36px bar between topbar and content)
- **Extended** existing `#ctxbar` to show room creation tools when nothing is selected
- **New "nothing selected" state** in `_ctxBarItems()`:
  - Shows "Tegn rom" label + room name input + shape buttons (rect2, polygon, lshape, wbw, yttervegg)
  - With BG: hides L-form and WBW, shows BG controls (Vis, opacity slider, 📏, 🔄, ✕)
  - Without BG: shows all 5 shape buttons
- **Ctxbar flow:** Click room → rom-handlinger | Click empty space → rom-opprettelse | Draw mode → hidden
- **Leggeretning widget** now only visible when a room is selected (`_updateVfDirVisibility()`)
- **Removed all action-bar code:** HTML, CSS (`#action-bar`, `.ab-*`), JS (`updateActionBar()`)
- **New CSS:** `.ctxbar-inp`, `.ctxbar-slider` for input/slider inside ctxbar
- **New JS:** `_showCalibWarningInCtxbar()`, `_updateVfDirVisibility()`
- **Updated:** `abStartDraw()` reads `#ctxbar-room-name`, `showAddRoomModal()` deselects room to show ctxbar
- Legacy wrappers (`showBgPanel`, `hideBgPanel`, `showDrawToolbar`) now call `updateCtxBar()`
- `startDrawMode()` now calls `updateCtxBar()` to hide ctxbar during drawing

## 2026-03-08: Forced calibration overlay after BG import
- **Problem:** `_installBgImage()` auto-calculates `widthCm` from image dimensions, so the old `widthCm === 0` check never triggered for newly imported images
- **Solution:** Added `bg._needsCalibration` flag and fullscreen overlay
- **New HTML:** `#bg-calib-overlay` inside `#canvas-wrap` — dark blurred overlay with centered modal card
- **Overlay content:** 📏 icon, "Sett målestokk" heading, explanation text, "Sett målestokk nå" and "Fjern bakgrunn" buttons
- **Flag lifecycle:**
  - Set `true` in `_installBgImage()` for new (non-same-filename) files
  - Cleared `false` in `confirmBgCalibrate()` after successful calibration
  - Cleared `false` in `removeBgImage()` when bg is removed
  - Checked in `_ctxBarItems()` to block room creation buttons
  - Checked in `abStartDraw()` to prevent drawing when uncalibrated
- **cancelBgCalibrate():** Re-shows overlay if `_needsCalibration` still true
- **startBgCalibrate():** Hides overlay when calibration mode starts

## 2026-03-08: Enter lukker polygon
- Enter-tast lukker polygon, yttervegg og hindring-polygon ved ≥3 punkter
- Lagt til i keydown-handler etter WBW Enter-handler (~linje 8127)
- Hjelpetekst i statusbar oppdatert med "Enter lukk polygon"

## 2026-03-08: Fargepalett i topbar
- **8 predefinerte farger:** Cyan, Grønn, Oransje, Rød, Lilla, Gul, Hvit, Rosa (`DRAW_COLORS` konstant)
- **To kategorier:** Tegnefarge (`S.ui.drawColor`) og veggfarge (`S.ui.wallColor`)
- **Topbar:** "Farge"-knapp med fargedot, åpner dropdown (`#color-menu`) med sirkel-swatches
- **Tegnefarge:** Endrer polygon/rect preview-linjer og punkter under tegning
- **Veggfarge:** Endrer stroke/fill for valgt rom sine vegger + hjørnedots + valgt vegg-highlight
- **CSS:** `.color-sw` (22px sirkel, border-highlight ved hover/selected)
- **Lagring:** Farger lagres i prosjektdata og gjenopprettes ved åpning
- **Funksjoner:** `openColorMenu()`, `_closeColorMenu()`, `setDrawColor()`, `setWallColor()`

## 2026-03-08: Per-vegg tykkelse og side for yttervegg
- **Datamodell:** Hvert wall-objekt har nå `thicknessCm` (5-50) og `side` ('out'/'in')
- **compWalls():** Nye felter med defaults (`thicknessCm: 0`, `side: 'out'`)
- **createRoom():** Setter per-wall defaults for outer-wall rom (bruker `room.wallThicknessCm || 20`)
- **Rendering:** Yttervegg rendres som filled quads per vegg (ikke lineWidth-stroke)
  - Normal-vektor beregnes vinkelrett på veggen
  - `side: 'in'` inverterer normalen → veggen bygger innover
  - Gjelder både pass 1 (ikke-valgte rom) og pass 2 (valgt rom)
- **Sidebar:** Vegg-info-panelet (`updateWip()`) viser nå Tykkelse-input + Utside/Innside-knapper for outer-wall vegger
- **Room-info:** For outer-wall rom vises "Veggtykkelse Xcm (klikk vegg)" i stedet for global input
- **Funksjoner:** `setPerWallThickness(roomId, wallId, val)`, `setWallSide(roomId, wallId, side)`
- **Bakoverkompatibilitet:** `_restoreProject()` migrerer gamle vegger uten thicknessCm/side
- **IKKE implementert ennå:** Interaktiv vegg-konfig under tegning (velg side/tykkelse med mus etter hvert segment)

## 2026-03-09: 3-stegs skillevegg med interaktiv veggtykkelse + UX
- Commit: `56358c3`
- **Skillevegg (3-stegs):** Klikk startpunkt → klikk sluttpunkt → klikk side for tykkelse
- **Interaktiv veggtykkelse under tegning** for yttervegg: etter hvert segment velger bruker side med mus
- **UX-forbedringer:** Diverse forbedringer til tegneverktøy

## 2026-03-09: 4-kant avstandslinjer, arkitektonisk målsett, veggtykkelse utover
- Commit: `7fe16a8`
- **4-kant avstandslinjer:** Viser avstand fra varmefolie-kant til alle 4 vegger (venstre, høyre, topp, bunn)
- **Arkitektonisk målsett (Målsett Folie):** Dimensjonskjeder utenfor romvegg som viser strip-bredder, gap og marginer
  - Toggle via "Målsett Folie" chip i ctxbar (rom-valgt og strip-valgt)
  - Oransje farge, stiplet forlengelseslinje, roterte labels, dynamisk offset
  - Across-chain: marginer + strip-bredder + gap mellom strips
  - Along-chain: topp-margin + strip-lengdeområde + bunn-margin
- **"Målsett Rom" chip** tilbake i strip-valgt ctxbar
- **setWallThickness()** fikset: manglende `pushUndo()` og `render()`
- **Veggtykkelse retning:** Vegger bygger nå alltid utover fra innvendig rom
  - `computeWallOutline()`: detekterer polygon-vindingsretning (CW/CCW via signed area) med `windFlip`
  - `drawWallThicknessOverlay()`: offset vekk fra centroid (utover)
- **Gap-label formatering:** Fikset Math.round(2.5)=3 → bevarer desimaler

## 2026-03-09: Magnetisk snap ved folie-drop
- Commit: `9c64ff0`
- **Ny funksjon `_snapStripToNearest(strip)`:** Finner nærmeste lovlige pos_cm inntil en nabo med gap-avstand
  - Prøver begge sider av hver nabo, velger nærmeste
  - Verifiserer rom-grenser og overlap med andre strips
- **Drop fra sidebar:** Overlappende strip snapper i stedet for å avvises
- **Mouseup for strip-drag og gizmo-drag:** Snapper til nabo hvis overlap etter drag
- **Grønn ghost-preview:** Under dragover vises grønn stiplet kontur ved snap-posisjon

## 2026-03-09: Leverandør-bevisst gap/margin arkitektur
- Commit: `6f3bf82`
- **Sentrale hjelpefunksjoner** erstatter alle hardkodede gap (1.0cm) og margin (2.5cm):
  - `_productMinGapCm(productId)` — leverandørens minimum gap
  - `_productMinMarginCm(productId)` — leverandørens minimum margin
  - `_effectiveGapCm(productId)` — max(bruker-gap, leverandør-min)
  - `_effectiveGapCmPair(id1, id2)` — strengeste gap mellom to produkter
  - `_effectiveMarginCm(productId)` — leverandørens margin
  - `_roomMaxMarginCm(roomId, dir?)` — strengeste margin i et rom
- **Produktlasting:** Client-side defaults (Cenika: 10mm gap, 25mm margin) settes for produkter uten verdier
- **Erstattede steder:** `_clampStripToRoom`, `_stripOverlapsAny`, `_snapStripToNearest`, `autoAddStrips`, `_autoFillRoomOnce`, `centerRoomStrips`, `setRoomGap`, `startSemiAutoFill`, `doSemiAutoStep`, `_semiAutoRemaining`, `drawStripGapLine`, dragover/drop, `computeClippedSegments`, `computePotentialLength`, end-drag handlers, `getStripViolations`, `marginWarnSnap`
- **Prinsipp:** Brukerens gap kan aldri gå under leverandørens minimum; mellom to ulike leverandører gjelder strengeste regel

## 2026-03-09: Supabase — nye kolonner for leverandør-regler
- **`min_gap_mm`** kolonne lagt til i `heating_products` (integer, default 10)
- **`min_wall_margin_mm`** kolonne lagt til i `heating_products` (integer, default 25)
- Alle 8 Cenika FlexFoil-produkter oppdatert med 10mm gap / 25mm margin
- `cut_interval_mm` var allerede i tabellen (20mm = 2cm for alle FlexFoil)
- Nye leverandører kan ha egne verdier per produkt direkte i databasen

## 2026-03-09: Fase 1 — Fundament (4 oppgaver)

### 1.1 Kutte-intervall i layout-motor
- **`computeClippedSegments()`** avrunder nå strip-lengder ned til nærmeste `cut_interval_mm`
- Bruker `Math.floor(len / cutCm) * cutCm` etter polygon-clipping
- Eks: 295cm rå lengde med 2cm intervall → 294cm (reell klippbar lengde)
- Segmenter kortere enn `MIN_LEN` (5cm) etter avrunding filtreres bort

### 1.2 Romindeksert strip-oppslag (versjonert cache)
- **Ny infrastruktur:** `_stripsForRoom(roomId)` og `_stripsForRoomDir(roomId, direction)`
- Versjonert lazy cache (`_stripCacheVer`) — invalideres kun ved add/remove/reassign
- `_invalidateStripCache()` lagt til ved 16 mutasjonspunkter (push, pop, filter, undo, reset)
- **Erstattet ~20 steder** som brukte `S.strips.filter(s => s.roomId === ...)`:
  - Kollisjonsfunksjoner: `_clampStripToRoom`, `_stripOverlapsAny`, `_snapStripToNearest`
  - Rendering: `_drawStripDimChainForRoom`, `_buildRoomTreeItem`, `_getStripListHTML`
  - Beregninger: `_computeRoomPower`, `_computeStripGaps`, `_roomMaxMarginCm`
  - Validering: `getStripViolations`, `marginWarnSnap`
  - UI: `centerRoomStrips`, `setRoomGap`, `_dragWidthPreview`, arrow key navigation
  - Wall resize: 4 gizmo-handlers
- **Ytelse:** pos_cm/length_cm-endringer invaliderer IKKE cache (referanser er stabile)

### 1.3 Dirty-flag rendering
- **`_needsRender`** flag + **`markDirty()`** funksjon
- `render()` setter `_needsRender = false` ved starten
- rAF-loopen endret: `if (_needsRender) render()` — rendrer bare ved behov
- **Eliminerer ~60 unødvendige renders/sek** under idle (ingen state-endring)
- Alle eksisterende `render()` kall fungerer uendret (backward-kompatibelt)

### 1.4 Generalisert produkt-type-system i Supabase
- **Ny `module_type` ENUM** i Supabase: `'foil' | 'cable' | 'mat' | 'plate'`
- Kolonne `module_type` lagt til i `product_categories` (default: 'foil')
- Varmefolie → `foil`, Varmekabel → `cable`
- **Client-side hjelpefunksjoner:** `_categoryModuleType(catId)`, `_productModuleType(prodId)`
- Grunnlag for å rute produkter til riktig layout-motor i fremtidige moduler

## 2026-03-09: Fase 2 — Layout-forbedringer (4 oppgaver)

### 2.1 Symmetrisk layout
- **`_centerStripDefs(defs, room, direction)`** — sentrerer strip-definisjoner symmetrisk
- Beregner unikke kolonner, total bredde med gap, og fordeler kaldsoner likt begge sider
- Integrert i `autoFillRoom()` retur og `autoAddStrips()` etter strip-plassering
- Verifisert: venstre kaldsone = høyre kaldsone (10.5cm = 10.5cm i 400cm rom)

### 2.2 Automatisk retningsdeteksjon
- **`_suggestDirection(room)`** — sammenligner bounding box bredde vs høyde
- Foreslår strips langs lengste akse (bedre dekning, mindre avfall)
- Integrert i retnings-widget (viser "(anbefalt: horisontalt/vertikalt)" hint)
- `autoAddStrips()` setter retning automatisk for rom uten eksisterende strips

### 2.3 Seed-basert layout
- **`_autoFillFromSeed(room, prods, dir, seedPosCm)`** — bidireksjonal fill fra seed-punkt
- **`seedFillRoom(roomId, seedPosCm)`** — entry point med produkt-kontekst
- **`startSeedMode()` / `cancelSeedMode()`** — UI-modus med crosshair cursor
- `_autoFillRoomOnce()` utvidet med valgfri `startCursor` parameter (5. argument)
- **UI:** "📍 Fra punkt" knapp i ctxbar (rom-valgt), seed-modus overlay med "✕ Avbryt"
- **Canvas mousedown handler:** fanger seed-klikk, konverterer til world-koordinater
- **Escape-tast:** avbryter seed-modus

### 2.4 Breddeoptimalisering (beam search)
- **`_beamSearchFill(room, sortedProds, direction, beamWidth)`** — utforsker bredde-kombinasjoner
- Beam width=5 (top-5 kandidater per kolonne), scorer på area - 5*cols
- Dedupliserer produkter per bredde for å unngå redundante branches
- Integrert i `autoFillRoom()`: prøver beam search + greedy for begge retninger, velger best
- **Verifisert:** Beam search slår greedy i 157cm rom (99+49=148cm vs greedy 139cm = +6.5%)

## 2026-03-10: Varmekabel — U-sving fix, randsone, CC-optimalisering
- Commit: `4ed9cb3`

### U-sving alternerings-mønster (5 steder fikset)
- **`_uTurnIsHigh(i, direction, startCorner)`** — ny hjelpefunksjon (linje ~2713)
- Bestemmer om U-sving `i` kobler til HIGH- eller LOW-enden av sweep-aksen
- Avhenger av startCorner: for TR/BR-hjørner flippes mønsteret vs TL/BL
- Erstatter hardkodet `(i % 2 === 0)` som bare var korrekt for TL/BL
- Fikset i: `generateCableSerpentine()` inset-logikk, `_drawCableUTurns()`, hit-test, `_adjustSpacingForLength()` overshoot-trimming, `_cableEndpoints()`

### U-sving bueretning (cross-product basert)
- Bueretning (`counterclockwise` flag i `ctx.arc()`) beregnes nå med cross-product:
  ```
  rightDot = dy * wallDirX + (-dx) * wallDirY
  ccw = rightDot < 0
  ```
- Verifisert korrekt for alle 8 kombinasjoner (2 retninger × 2 sider × 2 traverseringsordener)

### Visuell randsone langs alle vegger
- **`_drawCableMarginZone(cable, room)`** — ny funksjon
- Beregner polygon-inset ved å offsette kanter med normaler, kryssende påfølgende offset-kanter
- Bruker even-odd fill rule med compound path (ytre rom + reversert indre polygon)
- Tegner stiplet indre grense-linje

### CC-optimalisering: avvekstyrke for avlesingsregel
- Avlesingsregel (CC ≤ 3× avlesninsgstykkelse) endret fra hard grense til soft warning
- `_adjustSpacingForLength()` bruker nå bare produktets max_spacing som øvre grense
- Tillater kabel å ende i hjørne med fulle baner selv om CC > 3× avlesning

## 2026-03-10: Robust sentrert varmekabel layout-algoritme
- Commit: `a4259ca`

### 1. `_offsetPolygon(pts, dist)` — ny utility
- Ekstrahert fra `_drawCableMarginZone()`
- Gjenbrukbar polygon inset/outset: positiv dist = krympe, negativ = utvide
- Beregner vindingsretning via signed area, offsetter kanter med normaler, krysser påfølgende kanter
- Brukes nå av `_drawCableMarginZone()` og auto corner scoring

### 2. PCA-basert `_suggestDirection()` (oppgradert)
- Erstatter bounding-box sammenligning med area-weighted second moments of inertia (Ixx/Iyy)
- Shoelace-stil beregning over polygon-kanter
- Korrekt for L-form, trapesrom, uregelmessige polygoner der bounding-box er misvisende
- Verifisert: L-form → 'h', tall smal → 'v', bred → 'h', kvadrat → 'h'

### 3. Sentrert `generateCableSerpentine()` — KJERNEENDRING
- **Før:** `while(inBounds()) { pos += step }` — starter fra én vegg, asymmetrisk
- **Etter:** Deterministisk sentrert layout:
  ```
  usableWidth = (perpMax - margin) - (perpMin + margin)
  N = floor(usableWidth / spacing) + 1
  actualSpan = (N-1) * spacing
  sideMargin = (usableWidth - actualSpan) / 2
  firstPos = perpMin + margin + sideMargin
  ```
- Garanterer lik avstand fra kabel til begge vegger
- Verifisert: gapLow = gapHigh for alle 8 hjørne/retnings-komboer

### 4. Direkte N-beregning i `_adjustSpacingForLength()`
- **Fase 1:** For hvert kandidat-N: beregn CC = usableWidth/(N-1), generer serpentin, sjekk total lengde
- **Fase 2:** Finjuster med binærsøk innenfor beste N sitt CC-område
- Fikset binærsøk-retning: `diff > 0 → hi = mid` (ikke `lo = mid`)
- Fjernet `_findSpacingRangeForRunCount()` — ikke lenger nødvendig
- **Resultater:** 100% kabelutnyttelse for 2×2m+27m, 3×3m+50m, trapesrom+54m

### 5. Auto start corner selection
- `autoFillCable()` prøver nå ALLTID alle 4 hjørner × 2 retninger (ikke bare med soner)
- Scoring: sonetilordning + hjørnenærhet (via `_offsetPolygon` inset-vertices) + kabelutnyttelse + PCA-retning
- Velger hjørne som gir best kombinasjon av dekning, hjørnelanding, og sone-respekt

### Testresultater
| Rom | Kabel | Baner | CC (mm) | Utnyttelse | Symmetrisk | Konsistent CC |
|-----|-------|-------|---------|------------|------------|---------------|
| Rektangel 4×3m | 96m | 24 | 126.1 | 99.2% | ✅ | ✅ |
| L-form | 65m | 18 | 170.6 | 96.7% | ✅ | ✅ |
| Lite bad 2×2m | 27m | 14 | 135.7 | 100% | ✅ | ✅ |
| Trapesrom | 54m | 16 | 181.3 | 100% | ✅ | ✅ |
| Kvadrat 3×3m | 50m | 17 | 170.6 | 100% | ✅ | ✅ |

## 2026-03-10: Fase 4 — Varmematte-modul (komplett)

### 4.1 Matte-datamodell
- **`S.mats[]`** med `{ id, roomId, productId, x_cm, y_cm, width_cm, length_cm, rotation_deg }`
- **`_ensureMatTestProducts()`** — injiserer 2 test-produkter (98001: 50cm/100W/m², 98002: 80cm/150W/m²)
- **Produktfelt:** `mat_width_mm`, `mat_min_length_mm`, `mat_max_length_mm`, `mat_length_step_mm`, `watt_per_m2`
- **Save/restore:** `_buildSaveData()` og `_restoreProject()` inkluderer mats + counter reset
- **Undo:** `pushUndo()` snapshot av mats + nextMatId, `undo()` restorer + stale selection cleanup
- **Cache:** `_matsForRoom(roomId)` med versjonert lazy cache (`_matCacheVer`, `_invalidateMatCache()`)

### 4.2 Matte-layout og interaksjon (30 edits i 9 grupper)
- **Plasseringsmeny:** `showMatPlacePanel()` med produkt-kort, lengde-input (min→max i steg), "Plasser matte"-knapp
- **Plassering:** Klikk i rom → matte sentrert på klikkpunkt, ghost-preview under plassering
- **Rendering (`drawMats()`):**
  - Rotert rektangel via `ctx.translate()` + `ctx.rotate()` (blå farger, ulike for sel/hov/normal)
  - Intern 5cm mesh-mønster ved zoom > 0.3, produkt-label + dimensjoner ved zoom > 0.38
- **Gizmo (`drawMatMoveGizmo()`):** X-pil (rød), Y-pil (grønn), senter-ring, rotasjonshåndtak (↻)
- **Hit detection (`hitMat()`):** Invers rotasjons-transform til matte-lokale koordinater → AABB-sjekk
- **Drag:** Fri/X/Y-akse via gizmo, grid-snap, `_clampMatToRoom()` AABB-clamping
- **Rotasjon:** Gizmo rotasjonshåndtak med 45°-snap (uten Shift), ctxbar ↻ 90°-knapp
- **Seleksjon:** `selectMat(id)` nuller alle andre seleksjoner, `selectedMatId` lagt til i ~8 deselect-flows
- **UI-paneler:**
  - Ctxbar: produktnavn, dimensjoner, effekt, ↻ 90°, 🗑 Slett
  - ObjInfo: full matte-info (bredde, lengde, areal, rotasjon, effekt)
  - Sidebar: 🟫-ikon med produktnavn, dimensjoner, watt per matte
  - Romstatistikk: `matW` og `matAreaM2` i `_computeRoomStats()`, inkludert i `totalW`
- **Slett:** Delete-tast + ctxbar knapp + ObjInfo knapp
- **Escape:** Avbryter matPlaceMode

## 2026-03-12: Dashboard redesign — Alt-i-ett forside
- Commit: `41db779`

### Ny forside (#project-list-screen)
- **Modulknapper:** 4 store knapper øverst (Innendørs gulvvarme, Snøsmelting i trapper, Snøsmelting i grunn, Tak og takrenner)
- **Quick-start:** Klikk modul → rett inn i canvas uten å opprette prosjekt først
- **Inline prosjektopprettelse:** "+ Opprett prosjekt" knapp ekspanderer til inline-skjema (prosjektnavn + adresse/beskrivelse)
- **Prosjekttabell:** Alle lagrede prosjekter i sorterbar tabell (Prosjektnavn, Beskrivelse, Sist oppdatert, Deler, Slett)
- **Importer fra fil:** Knapp nederst

### Modulvalg-skjerm (lobby)
- **`#module-screen`** — vises ved "Lobby"-klikk eller etter åpning av eksisterende prosjekt
- **`MODULE_TYPES`** array definerer tilgjengelige moduler (id, name, ico, desc, available)
- **Eksisterende deler:** Viser prosjektets deler med klikk-for-å-gå-til
- **"← Tilbake" knapp:** Tilbake til dashboard

### Del-faner i topbar
- **`renderPartTabs()`** — klikkbare faner for prosjektets deler i topbar
- **`.tb-part-tab`** — viser ikon + navn, aktiv del uthevet med accent-farge
- **"+" knapp** — åpner lobby for å legge til ny del
- **`switchActivePart(id)`** — bytter mellom deler uten å gå via lobby

### Navigasjon
- **🚪 Lobby-knapp** i topbar — alltid synlig, tar deg tilbake til modulvalg
- **✕ Avslutt-knapp** i topbar — viser quit-dialog med 3 valg

### Name-project modal (erstatter prompt())
- **`#name-proj-overlay`** — in-app modal for å navngi prosjekter uten navn
- **Promise-basert:** `_showNameProjectModal()` returnerer Promise, `_nameProjectConfirm()` / `_nameProjectCancel()` resolver
- **Brukes av:** `saveProject()` når `S.project.name` er tomt
- **Enter/Escape** tastaturstøtte

### Quit-flyt
- **`showQuitDialog()`** — 3 valg: "💾 Lagre og avslutt", "Avslutt uten å lagre", "Avbryt"
- **`quitSaveAndExit()`** — lagrer (med navne-modal om nødvendig), så tilbake til dashboard
- **`quitWithoutSaving()`** — rett tilbake til dashboard uten lagring
- **`_quitToProjectList()`** — reset state + vis dashboard

### Fjernet
- **`#np-screen`** — egen side for prosjektopprettelse (erstattet av inline-skjema)
- **`startProject()`**, `_newProjectFromList()`, `_showSavedProjects()`, `_hideSavedProjects()`
- **Native `prompt()`** — erstattet med in-app modal
- **Kabel-violation overlay** — røde striplede linjer på canvas fjernet (advarsler vises kun i sidebar)

### CSS
- **Nye klasser:** `.dash`, `.dash-modules`, `.dash-mod-btn`, `.dash-section`, `.dash-create-*`, `.pl-table`, `.pl-tr`, `.pl-td-*`
- **Topbar:** `.tb-part-tabs`, `.tb-part-tab`, `.tb-add-part`, `.tb-lobby-btn`, `.tb-grp`
- **Modulvalg:** `.module-card`, `.module-tile`, `.module-grid`, `.coming-badge`
- **Kompakt topbar:** Redusert fra 48px til 42px, tettere spacing

### Nye JS-funksjoner
- `_showProjectListScreen()`, `_renderDashModules()`, `_toggleCreateProject()`, `_createProjectInline()`
- `_quickStartModule(moduleType)`, `showModuleScreen()`, `addPart(moduleType)`
- `renderPartTabs()`, `switchActivePart(id)`, `updateTopbarForModule()`
- `_showNameProjectModal()`, `_nameProjectConfirm()`, `_nameProjectCancel()`
- `_fetchProjectList()` — JSONB-ekstraksjon for deler-antall via `data->project->parts`
- `_renderProjectList()` — tabell-basert rendering med sortering
- `_toggleProjectSort()`, `_confirmDeleteProject()`, `_openCloudProject()`

## 2026-03-14: Hindring-forbedringer + produktmeny redesign + strip-rotasjon

### Hindring-synlighet under tegning
- **Fix:** Hindringer forsvant mens man tegnet en ny hindring-polygon
- `drawHindrings()` tillater nå `hindring` og `hindring-polygon` drawModes (ikke bare `dim`)
- Alle eksisterende hindringer er alltid synlige under tegning av nye

### Hindring vegg-autolukking
- **Ny:** Når hindring-polygon starter ved en vegg og sluttpunktet er nær en vegg, lukkes polygon automatisk langs romveggene
- `_projectToRoomWall(pt, room, threshold)` — projiserer punkt på nærmeste romvegg (5cm terskel)
- `_traceWallPath(room, startWall, startT, endWall, endT)` — finner korteste sti mellom to veggpunkter via romhjørner
- Eliminerer behov for å manuelt tegne tilbake langs veggen til startpunktet

### Produktmeny redesign — 3 valg
- **Før:** 4 valg (Automatisk → breddemeny, Halvautomatisk, Manuelt, Fra punkt)
- **Etter:** 3 valg:
  1. **⚡ Automatisk** — direkte til `showAutoFillComparison()`, ingen breddevelger
  2. **⚡ Velg bredder ›** — `showWidthPickerPanel()` med avkrysningsbokser per bredde, "Kjør automatisk" + "Tilbake"
  3. **✋ Manuelt** — eksisterende manuell modus med ny rotasjonsstøtte
- Fjernet: Halvautomatisk og Fra punkt fra menyen

### Width Picker Panel
- `showWidthPickerPanel(familyName, categoryId)` — viser avkrysningsbokser for alle tilgjengelige bredder
- `_runWidthPickerAutoFill()` — filtrerer produkter etter valgte bredder, kjører `_autoFillBothDirections()`
- Alle bredder avkrysset som standard, bruker kan velge bort bredder

### Strip-rotasjon
- `_rotateSelectedStrip()` — roterer valgt folie 90° (h↔v) med senter-bevaring og auto-lengde
- **R-tast:** Roterer valgt strip 90° (uten Ctrl — Ctrl+R er rom-rotasjon)
- **R-tast under manuell plassering:** Bytter retning mellom H og V
- **Ctxbar:** "⟲ Roter" chip-knapp som første element i strip-ctxbar

## 2026-03-14: UX redesign — 3-nivå sidebar, kompakte rom, detaljpanel
- Commit: `e9cb8bd`

### Sidebar 3-nivå struktur
- **Nivå 1:** Modulnavigasjon (Dashboard + planleggingsmoduler)
- **Nivå 2:** Etasje/rom-tre med kompakte rom-elementer
- **Nivå 3:** Detaljpanel for valgt rom (vegger, strips, kabler, hindringer)
- Inline "+" knapper erstatter full-bredde blokkknapper
- Romsøk synlig ved 5+ rom (`_filterSidebarRooms()`)

### Kompakte rom-elementer
- Én-linje rom med romtype-ikon, navn, areal og statusdot
- `_roomStatus(room)` — beregner status (tom/delvis/ferdig/problem)
- `_roomTypeIcon(room)` — emoji-ikon fra ROOM_TYPES
- Detaljinnhold (vegger, strips, etc.) flyttet til detaljpanel

### Detaljpanel
- `_renderDetailPanel(roomId)` — komplett romoversikt
- Kollapserbare seksjoner for vegger, varmeelementer, hindringer
- Romhandlinger: romtype-dropdown, W/m²-input, dupliser, slett

### Veggtykkelse — fundamental fix
- **`computeWallOutline()` windFlip invertert:** `signedArea2 < 0 ? 1 : -1`
- Vegger bygger nå UTOVER fra innvendig romgrense (ikke innover)
- `_calcNetArea()` beregner innvendig areal minus hindringer — veggtykkelse trekkes aldri fra
- **Grunnleggende regel:** `room.points` = innvendig grense, `room.area` = brukbart gulvareal
- CLAUDE.md oppdatert med denne regelen

### Beam search — foretrekker like bredder
- `_scoreBeam()` penaliserer breddediversitet (200 cm² per ekstra bredde)
- Uniform bredde-bonus (+2% av areal) når alle strips har lik bredde
- Beam-state tracker `widths` (Set) og `widthCount` gjennom søket
- Final sort bruker færrest unike bredder som tiebreaker
- **Resultat:** 120+120 velges over 140+100 ved lik dekning
