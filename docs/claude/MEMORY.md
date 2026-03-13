# Romtegner Project Memory

## Project Setup (established 2026-03-08)
- **Local working dir:** `C:\Users\kes\.claude`
- **GitHub repo:** `kennethskretteberg-blip/arqely-mvp` (branch: `main`)
- **Remote:** `origin` -> `https://github.com/kennethskretteberg-blip/arqely-mvp.git`
- **Vercel project:** `arqely-mvp` (team: `kenneths-projects-57456d22`)
- **Live URL:** `arqely-mvp.vercel.app/romtegner.html`
- **Custom domain:** `arqely.com` / `www.arqely.com` (live, DNS verified)
- **Vercel build config:** Framework=Other, Build Command=empty, Output Directory=`.`

## GitHub Account
- Username: `kennethskretteberg-blip`
- Other repos: `iconz-platform` (public), `iconz-prototype` (private)

## Domain DNS (configured at Domeneshop)
- **arqely.com:** A record `@` -> `216.198.79.1` (redirects to www)
- **www.arqely.com:** CNAME `www` -> `0c2d8f13e29d5b7e.vercel-dns-017.com.` (production)
- **Domain registrar:** domeneshop.no

## Deployment Flow
- Push to `main` -> Vercel auto-deploys as static site
- No build step needed (pure HTML/JS/CSS)

## Key Decisions
- Replaced old Next.js code in arqely-mvp with romtegner single-file app (2026-03-08)
- Branch renamed from `master` to `main` to match GitHub default
- arqely.com is now live and connected to Vercel
- All modal buttons use `.floor-choice-btn` pattern: neutral by default, blue on focus (2026-03-08)
- Floating panels (`#bg-panel`, `#draw-toolbar`) replaced by unified `#action-bar` (2026-03-08)
- Action bar is structural (in layout flow, never overlaps) with 3 sections: Bakgrunn, Rom, Produkter
- Room creation buttons are context-aware: bg imported → only canvas-click shapes; no bg → all shapes

## Architecture Notes
- **Action bar** (`#action-bar`): sits between `#topbar` and `#content` in flex layout
- **Z-index hierarchy:** ctxbar(20) < widgets(150) < modals(1000). Action bar uses layout flow (no z-index needed)
- **State syncing:** `updateActionBar()` is the central function — called from floor creation, project restore, modal close, exit drawing, bg import/remove, floor switch
- **Legacy wrappers:** `showBgPanel()`, `hideBgPanel()`, `showDrawToolbar()` all redirect to `updateActionBar()`

## Supplier-Aware Rules (established 2026-03-09)
- **Supabase columns:** `min_gap_mm`, `min_wall_margin_mm` on `heating_products` table
- **Cenika defaults:** 10mm gap, 25mm wall margin (applied as DB defaults + client-side fallback)
- **Central helpers:** `_effectiveGapCm()`, `_effectiveGapCmPair()`, `_effectiveMarginCm()`, `_roomMaxMarginCm()`
- **Principle:** User gap preference can never go below supplier minimum; between two different suppliers, strictest rule applies
- **cut_interval_mm:** Already in DB (20mm for FlexFoil); varies per product/supplier
- **Future suppliers:** Just add products with their own min_gap_mm / min_wall_margin_mm values in Supabase

## Magnetic Snap (established 2026-03-09)
- `_snapStripToNearest(strip)` — finds nearest valid pos_cm adjacent to a neighbor
- Used in: drop handler (snap instead of reject), mouseup (snap after drag), green ghost preview during dragover

## Product Roadmap (established 2026-03-09)
- Arqely skal bli en fullverdig webapp for elektrisk varmelegeme-design
- **Produkttyper som skal inn:** Varmefolie (✅), Varmekabel (✅), Varmematter (✅), Platesystemer med kabelspor (✅)
- **Arkitektur-prinsipp:** Alle produkttyper bruker samme primitiver (polygon-clipping, rule validation, world coordinates)
- **Prioritert rekkefølge:** Se [roadmap.md](roadmap.md) for detaljert plan
- **Fase 1 fullført (2026-03-09):** Kutte-intervall, strip-cache, dirty-rendering, module_type i Supabase
- **Fase 2 fullført (2026-03-09):** Symmetrisk layout, auto-retning, seed-basert layout, beam search breddeoptimalisering
- **Fase 3 Varmekabel fullført (2026-03-10):** Serpentin-layout, U-svinger, randsone, CC-optimalisering
- **Robust kabel-layout (2026-03-10):** Sentrert layout, PCA-retning, auto corner, direkte N-beregning
- **Fase 4 Varmematte fullført (2026-03-10):** Datamodell, plassering, rendering, drag/rotate gizmo, UI-integrasjon
- **Fase 5 Platesystem fullført (2026-03-11):** Grid-basert auto-fill, groove-rendering, drag gizmo, AABB-plassering
- **Fase 6.1 Brukerpreferanser fullført (2026-03-11):** localStorage-basert, tema/snap/gap/labels persists
- **Fase 6.4 PDF-eksport fullført (2026-03-11):** jsPDF, forside, tabeller, romtegninger, materialliste
- **Fase 6.6 Band-clipping fullført (2026-03-12):** 3-scanline band-clipping, zone subtraction, gap merging
- **Fase 6.2 Auto-soner fullført (2026-03-12):** Flood-fill sub-region detection, auto zone creation
- **Fase 6.3 Lærende system fullført (2026-03-12):** Product usage tracking, "Mest brukt" badges
- **Fase 6.5 Dokumentasjon fullført (2026-03-12):** 5-tab modal (sjekkliste/målinger/bilder/signatur/notater), PDF-integrasjon
- **Fase 7 Trappemodul fullført (2026-03-12):** Frittstående trapp-entitet, dual visning (plan+side), serpentin-kabel, validering, drag-gizmo

## Stair Module Architecture (established 2026-03-12)
- **`S.stairs[]`** — `{ id, name, x_cm, y_cm, width_cm, step_depth_cm, step_height_cm, step_count, landing_depth_cm, landing_position, cableProductId, cableSpacing_cm, edgeMargin_cm, viewMode, runs, connections, totalCableLength_cm, surfaces }`
- **Frittstående:** Ingen roomId/floorId — trapper er globale entiteter
- **`_generateStairSurfaces(stair)`** — genererer overflater (treads + landings) fra parametere
- **`generateStairCable(stair)`** — sentrert serpentin per overflate, U-svinger, connections mellom trinn
- **`_drawStairPlan(stair)`** — utbrettet visning med overflater, kabel, markører
- **`_drawStairSide(stair)`** — trapp-profil polygon med kabel på trinn
- **`drawStairMoveGizmo()`** — X/Y piler + senterdot
- **`hitStair(wx,wy)`** / `hitStairGizmo(sx,sy)` — bounding box + gizmo hit detection
- **`selectStair(id)`** — mutual exclusion med alle andre seleksjoner
- **`getStairCableViolations(stairId)`** — maxCC(10cm), minSpacing, lowDensity(300W/m²), cableLengthMismatch
- **`showAddStairModal()`** — parameter-modal med kabelprodukt-dropdown fra Supabase
- **Sidebar:** "Trapper"-seksjon i renderSidebar() for frittstående trapper
- **Konstanter:** `STAIR_MAX_CC_CM = 10`, `STAIR_MIN_DENSITY_WM2 = 300`

## Plate Module Architecture (established 2026-03-11)
- **`S.plates[]`** — `{ id, roomId, productId, x_cm, y_cm, width_cm, length_cm, direction }`
- **`_ensurePlateTestProducts()`** — injects test products (97001: 60×120cm, 97002: 60×60cm)
- **`showPlatePlacePanel()`** — product cards with "Plasser plate" and "Fyll rom" buttons
- **`_autoFillPlates(productId)`** — grid-based, tries both orientations, centers, ptInPoly check
- **`drawPlates()`** — warm brown/gold colors, groove lines with U-turn arcs
- **`drawPlateMoveGizmo()`** — X/Y arrows + center dot (no rotation, axis-aligned)
- **`hitPlate(wx, wy)`** — simple AABB check (no rotation)
- **`selectPlate(id)`** — clears all other selections (mutual exclusion)
- **`_clampPlateToRoom()`** — simple AABB clamping
- **`_platesForRoom(roomId)`** — versioned lazy cache

## PDF Export Architecture (established 2026-03-11)
- **`exportPDF()`** — jsPDF-based A4 PDF generation
- **`_renderRoomToImage(room)`** — offscreen canvas 800×440, renders polygon + all heating objects
- **jsPDF CDN:** `https://unpkg.com/jspdf@2.5.2/dist/jspdf.umd.min.js`
- **Pages:** Cover, project summary, per-floor tables, room details (image + stats + products), material list

## User Preferences (established 2026-03-11)
- **localStorage key:** `arqely_prefs`
- **Persisted:** theme, snap settings, varmefolie gapCm, showStripLabels
- **Functions:** `_savePrefs()`, `_loadPrefs()`, `_applyPrefs()`
- **Hooks:** setTheme, toggleSnap, setRoomGap, toggleStripLabels

## Cable Layout Architecture (established 2026-03-10)
- **`_offsetPolygon(pts, dist)`** — reusable polygon inset/outset utility
- **`_suggestDirection(room)`** — PCA via area-weighted second moments (Ixx/Iyy)
- **`generateCableSerpentine()`** — centered layout: N = floor(usableWidth/cc)+1, sideMargin = (usableWidth - (N-1)*cc)/2
- **`_adjustSpacingForLength()`** — direct N iteration + binary search fine-tuning within fixed N
- **`_uTurnIsHigh(i, direction, startCorner)`** — determines U-turn connection side (accounts for all 4 corners)
- **`_drawCableUTurns()`** — cross-product based arc direction (always faces wall)
- **`_drawCableMarginZone()`** — even-odd fill ring using `_offsetPolygon()`
- **`autoFillCable()`** — tries all 4 corners × 2 directions, scores by zone + corner proximity + utilization
- **Screed rule (CC ≤ 3× screed):** soft warning in UI, not hard limit in algorithm
- **`_findSpacingRangeForRunCount()`** — REMOVED (replaced by direct N calculation)

## Mat Module Architecture (established 2026-03-10)
- **`S.mats[]`** — `{ id, roomId, productId, x_cm, y_cm, width_cm, length_cm, rotation_deg }`
- **`_ensureMatTestProducts()`** — injects test products (98001: 50cm, 98002: 80cm) when no real mat products in Supabase
- **`showMatPlacePanel()`** — product cards with length input (min→max in steps)
- **`drawMats()`** — rotated rectangle rendering with mesh lines, labels, ghost preview
- **`drawMatMoveGizmo()`** — X/Y arrows + center ring + rotation handle (follows hindring pattern)
- **`hitMat(wx, wy)`** — inverse rotation transform → AABB check in mat-local coords
- **`selectMat(id)`** — clears all other selections (mutual exclusion with cable/strip/zone)
- **`_clampMatToRoom(mat, room)`** — simple AABB clamping (ignores rotation for now)
- **`_matsForRoom(roomId)`** — versioned lazy cache (same pattern as strips/cables)
- **Gizmo state vars:** `_matDragging`, `_matDragAxis`, `_matRotating` etc.
- **Rotation:** 45° snap via gizmo handle, 90° via ctxbar button

See [project-history.md](project-history.md) for detailed change log.
See [ui-principles.md](ui-principles.md) for UI design principles (gizmo, interactions).
See [roadmap.md](roadmap.md) for prioritized development plan.
See [architecture-review.md](architecture-review.md) for full architecture analysis.
