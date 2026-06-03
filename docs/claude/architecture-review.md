# Romtegner — Arkitektur- og Funksjonsstatus

> Sist oppdatert: 2026-06-03 (regenerert fra faktisk kode)

---

## 1. Oversikt

| Egenskap | Verdi |
|----------|-------|
| **Fil** | `romtegner.html` (single-file app) |
| **Linjer** | 33 356 (HTML + CSS + JS) |
| **Funksjoner** | ~995 `function`-deklarasjoner + et stort antall arrow-funksjoner (callbacks) |
| **Byggsteg** | Ingen — ren HTML/JS/CSS |
| **Server** | `serve-romtegner.js` (Node.js, port 4000) |
| **Backend** | Supabase (produktkatalog, prosjektlagring) |
| **Deploy** | Vercel auto-deploy fra `main` → arqely.com |
| **Repo** | github.com/kennethskretteberg-blip/arqely-mvp |

---

## 2. Arkitektur

### 2.1 Design-filosofi
- **Deterministisk, objektbasert CAD-arkitektur** — all geometri i verdens-koordinater (cm)
- **Rendering derivert fra state** — ingen pikseldata lagres
- **Sentralt state-objekt `S`** med ~14 top-level properties, ~50 UI-flagg
- **Undo-stack** med dyp kopi av state (maks 50 nivåer)
- **Dirty-flag rendering** (aktiv — betinget rAF-loop, se §11.1)

### 2.2 Scene-hierarki

```
S (state)
 ├─ project    { id, name, description, createdAt }
 ├─ floors[]
 ├─ rooms[]    (polygon-baserte, via floorId)
 │    ├─ walls[]      (beregnet fra polygon-punkter)
 │    ├─ points[]     (polygon-hjørner)
 │    ├─ strips[]     (varmefolie, via roomId i S.strips)
 │    ├─ cables[]     (varmekabel, via roomId i S.cables)
 │    ├─ mats[]       (varmematte, via roomId i S.mats)
 │    ├─ plates[]     (varmeplate m/kabelspor, via roomId i S.plates)
 │    ├─ stairs[]     (trapp-modul, via roomId i S.stairs)
 │    ├─ hindrings[]  (hindringer, via roomId)
 │    └─ zones[]      (forbudt/foretrukket, via roomId i S.zones)
 ├─ groups[]   (strip-grupper for multi-select)
 ├─ view       { zoom, panX, panY }
 ├─ drawing    { active, points, wbw, skillevegg, ... }
 ├─ snap       { grid, a90, a45 }
 └─ counters   { nextRoomId, nextStripId, nextCableId, nextMatId, ... }
```

### 2.3 Rendering-lag (bunn → topp)

Rekkefølge slik den faktisk står i `render()` (bunn → topp):

| Lag | Funksjon | Beskrivelse |
|-----|----------|-------------|
| 1 | `drawBgImage()` | Bakgrunnstegning (PDF/JPG/PNG) |
| 2 | `drawGrid()` | Rutenett (50cm + 10cm subgrid) |
| 3 | `drawRooms()` | Rom-polygoner med veggtykkelse |
| 4 | `drawStrips()` | Varmefolie-strips |
| 5 | `drawCables()` | Varmekabel-serpentiner med U-svinger |
| 6 | `drawMats()` | Varmematter (roterte rektangler) |
| 7 | `drawPlates()` | Varmeplater m/kabelspor |
| 8 | `drawStairs()` | Trapp-modul |
| 9 | `drawDropPreview()` / `drawStripGapLine()` | Drop-preview + gap-linje (under drag) |
| 10 | `drawAllDimAnnotations()` | Vegg-dimensjoner |
| 11 | `drawHindrings()` | Hindringer (kjøkkenøy, skap, pipe, etc.) |
| 12 | `drawZones()` | Forbudte/foretrukne soner |
| 13 | `drawPreview()` / `drawImportOverlay()` | Tegnemodus-preview / import-overlay |
| 14 | Gizmoer | Strip/mat/plate/trapp/hindring/gruppe-gizmoer |
| 15 | `drawUserDimLines()` / `drawDimMoveGizmo()` | Bruker-dimensjonslinjer |
| 16 | `drawRoomCards()` | Rom-infokort |
| 17 | `drawScaleBar()` | Målestokk-referanse |
| 18 | `drawMinimap()` | Minimap-widget (når synlig) |
| 19 | `drawSnapDot()` | Rødt snap-punkt ved cursor |
| 20 | `_positionCtxBar()` | Plasserer flytende ctxbar over valgt objekt |

### 2.4 Hit-detection (prioritert rekkefølge)

| Prioritet | Funksjon(er) | Mål |
|-----------|-------------|-----|
| 1 | `hitMatGizmo/RotHandle` | Mat gizmo-håndtak |
| 2 | `hitStripGizmo`, `hitStripEndArrow` | Strip gizmo og resize |
| 3 | `hitGroupGizmo`, `hitGroupEndHandle` | Gruppe-håndtak |
| 4 | `hitCableStart/EndGizmo` | Kabel endepunkter |
| 5 | `hitHindringGizmo`, `hitHindringRotHandle` | Hindring gizmo |
| 6 | `hitMat()` | Mat-kropp (invers rotasjon → AABB) |
| 7 | `hitStrip()`, `hitCable()` | Strip/kabel-kropp |
| 8 | `hitZone()` | Sone-polygon |
| 9 | `hitHindring()`, `hitHindringWall()` | Hindring-kropp/vegg |
| 10 | `hitAnnotation()`, `hitDimGizmo()` | Annotasjoner |
| 11 | `hitVertex()`, `hitTransformHandle()` | Rom-hjørner/transform |
| 12 | `hitTest()` | Rom-kropp og vegger |
| 13 | `hitRoomCard()` | Rom-infokort |
| 14 | `hitAutoFillArrow()` | Auto-fill retningspiler |

### 2.5 Koordinat-system

| Funksjon | Retning |
|----------|---------|
| `w2s(wx, wy)` | Verden → Skjerm (cm → piksler) |
| `s2w(sx, sy)` | Skjerm → Verden (piksler → cm) |
| `BASE_SCALE = 1.5` | Piksler per cm ved zoom 1x |
| `GRID = 50` | Rutenett-intervall (cm) |

---

## 3. Produktmoduler — Status

### 3.1 Varmefolie (Fase 1-2) ✅ Komplett

| Funksjon | Status | Detaljer |
|----------|--------|----------|
| Strip-datamodell | ✅ | `S.strips[]` med id, roomId, productId, direction, pos_cm, start_cm, length_cm |
| Polygon-clipping | ✅ | `computeClippedSegments()` med kutte-intervall avrunding |
| Klipp rundt smal hindring | ✅ | `clipStripAroundHindrings()` / `_clipStripAroundZones()` bruker `_obstacleUnionInBand()` — tett sampling (steg ≤2cm) så en smal søyle under en bred folie blir korrekt utsparet (tidligere 3-linjers union bommet på smale hindringer) |
| Automatisk layout | ✅ | Live-bane: `showAutoFillComparison`/`_runWidthPickerAutoFill` → `_autoFillBothDirections` → `_applyAutoFillOption` (sammenligningspanel + gap-pack-etterpass). Den gamle `autoFillRoom`/`startAutoFill`/`confirmAutoFill`-banen er fjernet som død kode (P4). Delte hjelpere: `_autoFillRoomOnce`, `_beamSearchFill`, `_zoneFillRoom`, `_obstacleAwareFill` |
| Symmetrisk sentrering | ✅ | `_centerStripDefs()` — lik kaldsone begge sider |
| Auto-retning | ✅ | `_suggestDirection()` — PCA-basert (Ixx/Iyy) |
| Seed-basert layout | ✅ | `_autoFillFromSeed()` — bidireksjonal fill fra klikkpunkt |
| Halvautomatisk | ✅ | Steg-for-steg plassering med produktvalg |
| Manuell plassering | ✅ | Drag-and-drop fra sidebar med snap |
| Magnetisk snap | ✅ | `_snapStripToNearest()` — snapper til nabo med gap |
| Leverandør-regler | ✅ | `_effectiveGapCm()`, `_effectiveMarginCm()` — per produkt |
| Gizmo (flytt/resize) | ✅ | Piler + endemarkører for lengdejustering |
| Gruppe-seleksjon | ✅ | Multi-select med Shift, gruppe-gizmo |
| Strip-dimensjonskjede | ✅ | Målsett Folie — arkitektonisk dimensjonskjede utenfor vegg |
| 4-kant avstandslinjer | ✅ | Avstand fra strip til alle 4 vegger |
| Ctxbar + ObjInfo | ✅ | Produkt, posisjon, lengde, effekt, slett |
| Validering | ✅ | `getStripViolations()` — gap, margin, overlap |
| Cache | ✅ | `_stripsForRoom()` med versjonert lazy cache |

**Produkter i Supabase:** 8 Cenika FlexFoil 60W varianter (49-99cm bredde)

### 3.2 Varmekabel (Fase 3) ✅ Komplett

| Funksjon | Status | Detaljer |
|----------|--------|----------|
| Kabel-datamodell | ✅ | `S.cables[]` med direction, spacing_cm, startCorner, runs[], totalLength_cm |
| Serpentin-layout | ✅ | `generateCableSerpentine()` — sentrert, deterministisk N-beregning |
| CC-optimalisering | ✅ | `_adjustSpacingForLength()` — direkte N-iterasjon + binærsøk |
| Auto corner | ✅ | `autoFillCable()` — prøver alle 8 kombo (4 hjørner × 2 retninger) |
| U-svinger | ✅ | `_drawCableUTurns()` — cross-product bueretning, `_uTurnIsHigh()` |
| Randsone | ✅ | `_drawCableMarginZone()` — polygon-inset med even-odd fill |
| Multi-kabel | ✅ | Flere kabler per rom med sone-tilordning |
| Rendering | ✅ | Røde serpentin-linjer med arc U-turns, start/slutt-markører |
| Ctxbar + ObjInfo | ✅ | CC, baner, total lengde, utnyttelse%, kabel-info |
| Validering | ✅ | `getCableViolations()` — CC-grenser, avlesingsregel (soft warning) |

**Produkter i Supabase:** 25 InFloor 17T + 19 InFloor 10T = 44 Cenika kabel-varianter

**Layout-motorer (7 stk, orkestrert av `autoFillCable()`):**

Auto-fill kjører motorene i en **kaskade** og returnerer ved første motor som gir
et godkjent resultat. Serpentine kjøres først som *forarbeid* (velger retning,
hjørne og CC-spacing) men returneres normalt ikke direkte. Deretter prøves
motorene i denne rekkefølgen (søk på funksjonsnavn — linjenr drifter):

| # | Motor | Funksjon | Rolle i kaskaden |
|---|-------|----------|------------------|
| — | Serpentine | `generateCableSerpentine()` | **Forarbeid** — sentrert deterministisk N-beregning som setter retning/hjørne/spacing. Siste fallback hvis alt annet feiler |
| 1 | Skew | `generateCableSkew()` | Skråvegg/rotert ramme + hindringer. **Gated**: kjøres kun når `needSkew` (ikke-rettvinklet rom ELLER hindring ELLER forbudt sone). Returnerer additive `pathEls` (ikke `runs`) hvis `coverage ≥ 0.70`. Auto-fill-only (ingen drag-edit i v1) |
| 2 | Boustrophedon | `generateCableBoustrophedon()` | **Primær for rene rom** — selvvelger hjørne+side for garantert hjørne-til-hjørne-landing og rene celleskift. Returnerer `null` for hull/stablede celler → faller til V6 |
| 3 | V6 | `generateCableV6()` | Area-first pipeline (topologi → celler → per-celle sweep → dekningsvalidering). Fallback for komplekse rom |
| 4 | V5 | `generateCablePolygonV5()` | Area-first (dekomponer → fyll celler → koble). Fallback |
| 5 | V4 (polygon-aware) | `generateCablePolygonAware()` | Polygon-klippet multi-celle fallback |
| 6 | Length-driven | `generateCableLayoutLengthDriven()` | Kun fastlengde-produkter: eksakt match mot målsatt kabellengde |

I praksis: **Skew** vinner for ikke-rettvinklede rom og rom med hindring/forbudt
sone; **Boustrophedon** vinner for rene rektangel/L/T-rom; **V6/V5/V4** er
fallback for tilfeller de to primære ikke dekker.

> ⚠️ **Teknisk gjeld:** Motorene deler nesten ordrett duplisert scoringslogikk
> (sone-straff, hjørne-bonus, lengde-match — gjentatt i hver motor-gren i
> `autoFillCable`). Se forbedringsplanen (P1 — konsolider kabel-layout-motoren,
> trekk scoringen ut til ett `_scoreCableCandidate`). Skew + Boustrophedon er nye
> og skal beholdes; kandidatene for fjerning er gamle V4/V5/length-driven HVIS
> logging viser at de aldri vinner. Alle LOCKED-regler i CLAUDE.md
> (U-svinger = halvsirkler r=CC/2, lik banelengde / ingen Y-splits,
> `sweepMargin = margin + CC/2`) gjelder uavhengig av motor.

### 3.3 Varmematte (Fase 4) ✅ Komplett

| Funksjon | Status | Detaljer |
|----------|--------|----------|
| Matte-datamodell | ✅ | `S.mats[]` med x_cm, y_cm, width_cm, length_cm, rotation_deg |
| Plasseringsmeny | ✅ | `showMatPlacePanel()` — gruppert per familie med lengde-dropdown |
| Klikk-plassering | ✅ | Klikk i rom → matte sentrert på klikkpunkt med ghost-preview |
| Rendering | ✅ | `drawMats()` — rotert rektangel, mesh-linjer, labels |
| Drag & drop | ✅ | Fri/X/Y-akse via gizmo, grid-snap, `_clampMatToRoom()` |
| Rotasjon | ✅ | Gizmo-håndtak (45°-snap) + ctxbar 90°-knapp |
| Hit detection | ✅ | `hitMat()` — invers rotasjon → AABB i lokale koordinater |
| Gizmo | ✅ | `drawMatMoveGizmo()` — X/Y-piler, senter-ring, ↻-håndtak |
| Ctxbar + ObjInfo | ✅ | Produkt, bredde, lengde, areal, rotasjon, effekt |
| Sidebar | ✅ | 🟫-ikon, produktnavn, dimensjoner, watt |
| Save/restore + undo | ✅ | Komplett integrasjon |
| Cache | ✅ | `_matsForRoom()` med versjonert lazy cache |

**Produkter klar for Supabase:** 57 Cenika EcoMat (3 familier × 19 lengder):
- EcoMat 60T (60 W/m²) — stue, soverom, kjøkken — OK brennbart
- EcoMat 100T (100 W/m²) — entre, generell — OK brennbart
- EcoMat 150T (150 W/m²) — bad, WC, vaskerom — IKKE brennbart

SQL-migrasjon: `supabase-migration-mats.sql` (kjøres i Supabase SQL Editor)

### 3.4 Platesystem med kabelspor (Fase 5) ✅ Implementert

| Funksjon | Status | Detaljer |
|----------|--------|----------|
| Plate-datamodell | ✅ | `S.plates[]` med x_cm, y_cm, width_cm, length_cm, roomId, productId |
| Plasseringsmeny | ✅ | `showPlatePlacePanel()` |
| Auto-fyll | ✅ | `_autoFillPlates()` — rutenett-pakking i rommet |
| Rendering | ✅ | `drawPlates()` + `drawPlateMoveGizmo()` |
| Drag & drop | ✅ | Gizmo (fri/X/Y), `_clampPlateToRoom()` |
| Hit detection | ✅ | `hitPlate()` (AABB) + gizmo-håndtak |
| Cache | ✅ | `_platesForRoom()` versjonert lazy cache |

> Trapp-modul (`S.stairs[]`, `generateStairCable()`, `_stairBounds()`,
> `drawStairs()`) finnes også som egen kabel-basert modul for trappetrinn.

---

## 4. Rom-system

| Funksjon | Status | Detaljer |
|----------|--------|----------|
| Rektangel-rom | ✅ | Lengde + bredde input |
| L-form rom | ✅ | 6-punkts polygon |
| Polygon-tegning | ✅ | Fritt polygon med Enter for å lukke |
| Vegg-for-vegg (WBW) | ✅ | Interaktivt med HUD-panel |
| Yttervegg | ✅ | Polygon med per-vegg tykkelse og innside/utside |
| Skillevegg | ✅ | 3-stegs: startpunkt → sluttpunkt → side |
| Per-vegg tykkelse | ✅ | Individuelle verdier per vegg (5-50cm) |
| Bakgrunnstegning | ✅ | PDF/JPG/PNG med kalibrering (målestokk) |
| Tvangs-kalibrering | ✅ | Overlay blokkerer romtegning til bg er kalibrert |
| Etasje-system | ✅ | Flere etasjer med etasje-isolering |
| Rom-statistikk | ✅ | Areal, effekt, dekning — oppdateres automatisk |
| Rom-infokort | ✅ | Overlay på canvas med nøkkeldata |

---

## 5. Hindringer (Obstacles)

| Funksjon | Status | Detaljer |
|----------|--------|----------|
| 5 typer | ✅ | Kjøkkenøy, skap, pipe, vegg, annet |
| Polygon-tegning | ✅ | Fritt polygon per hindring |
| Drag/flytt | ✅ | Gizmo med X/Y-piler og fri-drag |
| Rotasjon | ✅ | Rotasjonshåndtak med snap |
| Avstandslinjer | ✅ | `drawHindringDistances()` — til vegger |
| Vegg-flytt | ✅ | Individuelle kanter kan flyttes |
| Rename | ✅ | Egendefinert navn |

---

## 6. Soner (Zones)

| Funksjon | Status | Detaljer |
|----------|--------|----------|
| Forbudte soner | ✅ | Dusj, fast innredning, termostat, kanal, egendefinert |
| Foretrukne soner | ✅ | Markerer ønsket dekningsområde |
| Polygon-tegning | ✅ | Fritt polygon med snapping |
| Kabel-integrasjon | ✅ | `autoFillCable()` respekterer sone-tilordning |

---

## 7. UI-komponenter

### 7.1 Layout

| Komponent | Beskrivelse |
|-----------|-------------|
| **Topbar** | Verktøy-chips (Flytt/Angre/Snap/90°/45°), fargevelger, tema, lagre |
| **Sidebar** | Prosjektnavn, etasje/rom-tre, vegg-liste, objekt-info |
| **Canvas** | Hoved-tegneflate med pan/zoom |
| **Ctxbar** | Flytende kontekstbar — dynamisk basert på seleksjon; `_positionCtxBar()` plasserer den ~40px over valgt objekt (faller til øverst-midt for rom/ingen seleksjon) |
| **Statusbar** | Koordinater, snap-status, modus, rom-antall |

### 7.2 Widgets (flyttbare)

| Widget | Funksjon |
|--------|----------|
| Stats | Rom-statistikk (areal, effekt, dekning) |
| Snap | Snap-innstillinger (grid, 90°, 45°) |
| Scale | Zoom og målestokk |
| Minimap | Miniatyrkart over prosjektet |

### 7.3 Modaler (7 stk)

| Modal | Formål |
|-------|--------|
| `np-screen` | Nytt prosjekt / åpne prosjekt |
| `modal-floor` | Legg til etasje |
| `modal-room1` | Romnavn |
| `modal-shape` | Romform-velger |
| `modal-rect` | Rektangel-dimensjoner |
| `modal-lshape` | L-form dimensjoner |
| `modal-hindring` | Hindring-type |
| `modal-bg-calib` | Kalibrerings-avstand |

### 7.4 Kontekstmenyer

| Meny | Trigger |
|------|---------|
| Produktmeny | Ctxbar "Legg til" → Varmefolie / Varmekabel / Varmematte |
| Familiemeny | Kategori-klikk → produktfamilier |
| Plasseringsmeny | Familie-klikk → layout-valg (auto/halvauto/manuell/seed) |
| Vegg-kontekstmeny | Høyreklikk vegg → sett inn hjørne, slett vegg |
| Farge-meny | Topbar → fargevelger (8 farger) |

---

## 8. Prosjekt I/O

| Funksjon | Status | Detaljer |
|----------|--------|----------|
| Lagre til fil | ✅ | File System Access API (`.arqely` JSON) |
| Åpne fra fil | ✅ | `_restoreProject()` med bakoverkompatibilitet |
| Supabase-lagring | ✅ | Prosjekt lagres som JSON i `romtegner_projects` (org-scopet via RLS), `_fetchProjectList()` med kandidat-fallback for kolonnenavn |
| Papirkurv (soft-delete) | ✅ | `deleted_at`-kolonne (timestamptz). Alle org-medlemmer kan slette (UPDATE → `deleted_at=now()`) og gjenopprette (`_restoreTrashedProject`). Permanent sletting (`_confirmPurgeProject`/DELETE) kun owner/admin/superadmin (RLS håndhever). Statusfilter «🗑️ Papirkurv» i prosjektlista, batch-handlinger kontekst-avhengige |
| Kunde-synk | ✅ | `_resolveCustomerName()`/`_syncProjectCustomerName()` — når `customer_id` finnes er kunde-raden sannhetskilde; omdøpt kunde gir nytt navn, slettet kunde markeres «(slettet)». Fri tekst beholdes når ingen kunde valgt |
| PDF-eksport | ✅ | jsPDF — én side pr rom, tvunget hvit bakgrunn + lyst tema under capture (`_renderRoomToImage` komposit på hvitt før JPEG), CC-info, produkt-/effektliste |
| Prosjektnavn | ✅ | Redigerbart i topbar |
| Undo/redo | ✅ | 50-nivå stack med dyp kopi |
| Quit-dialog | ✅ | Advarsel ved ulagrede endringer |
| `beforeunload` | ✅ | Browser-advarsel ved lukking |

---

## 9. Supabase-integrasjon

| Tabell | Innhold | Antall rader |
|--------|---------|-------------|
| `product_categories` | Varmefolie, Varmekabel, Varmematte | 3 |
| `heating_products` | Alle produktvarianter | 52+ (8 folie + 44 kabel) |

**Ventende migrasjon:** `supabase-migration-mats.sql` — 57 EcoMat matte-produkter

| Kolonne | Type | Brukes av |
|---------|------|-----------|
| `module_type` | ENUM | Kategori-ruting (foil/cable/mat/plate) |
| `min_gap_mm` | INTEGER | Leverandør-minimum gap |
| `min_wall_margin_mm` | INTEGER | Leverandør-minimum veggavstand |
| `mat_width_mm` | INTEGER | Matte-bredde |
| `mat_length_mm` | INTEGER | Matte-lengde (fast per produkt) |
| `watt_per_m2` | INTEGER | Effekttetthet |
| `cable_length_m` | DECIMAL | Kabellengde |
| `min_spacing_mm` / `max_spacing_mm` | INTEGER | CC-grenser for kabel |

---

## 10. Leverandør-regler

| Regel | Folie (FlexFoil) | Kabel (InFloor) | Matte (EcoMat) |
|-------|-------------------|-----------------|-----------------|
| Min gap mellom produkter | 10 mm | 50 mm (CC) | 50 mm |
| Min veggavstand | 25 mm | 50 mm | 50 mm |
| Min hindring-avstand | 50 mm | 50 mm | 50 mm |
| Min sluk-avstand | 100 mm | 100 mm | 100 mm |
| Kutte-intervall | 20 mm | N/A | N/A |
| Min bøyeradius | N/A | 32 mm (17T) | 20 mm |

**Sentrale hjelpefunksjoner:**
- `_productMinGapCm(productId)` — leverandørens minimum gap
- `_effectiveGapCm(productId)` — max(bruker-gap, leverandør-min)
- `_effectiveGapCmPair(id1, id2)` — strengeste gap mellom to produkter
- `_effectiveMarginCm(productId)` — leverandørens veggmargin
- `_roomMaxMarginCm(roomId)` — strengeste margin i et rom

---

## 11. Ytelse

| Mekanisme | Status | Beskrivelse |
|-----------|--------|-------------|
| Versjonert cache | ✅ | `_stripsForRoom()`, `_cablesForRoom()`, `_matsForRoom()` |
| Dirty-flag rendering | ✅ | Aktiv betinget rAF-loop — se §11.1 |
| Viewport culling | ⬜ | Planlagt for >50 rom |
| Spatial indexing | ⬜ | Planlagt for >200 objekter |
| Per-rom rendering | ✅ | Kollisjon/validering filtrerer på roomId først |

### 11.1 Dirty-flag rendering (aktiv)

Render-loopen kjører ikke lenger ubetinget (søk på navn — linjenr drifter):

- `let _needsRender = true;` — global flagg
- `function markDirty() { _needsRender = true; }` — settes ved mutasjon
- Betinget rAF-loop: `if (_needsRender) { render(); }` hver frame,
  ellers hoppes render over → sparer ~60fps tomgangs-CPU
- `render()` nullstiller `_needsRender = false` når tegningen er ferdig
- Mange `markDirty()`-kall i mutasjons-handlere, pluss direkte `render()`-kall der det trengs
- `_anyInteractionActive()` i mousemove fungerer som sikkerhetsnett under aktiv drag
- FPS måles og vises i render-stats-widget (`_renderFps`, `_updateRenderStatsWidget()`)

---

## 12. Nøkkeltall

| Metrikk | Antall |
|---------|--------|
| Kodelinjer totalt | 33 356 |
| `function`-deklarasjoner | ~995 (+ mange arrow-callbacks) |
| Seksjons-headers (`// ───`) | 165 |
| Rendering-funksjoner (draw*) | 42 |
| Hit-test funksjoner (hit*) | 49 |
| Kabel-layout-motorer | 7 (Skew + Boustrophedon primære, V6/V5/V4/length-driven fallback, Serpentine forarbeid) |
| S.ui properties | 82 |
| Modal-IDer (`modal-*`) | 10 |
| Widgets | 4 |
| CSS custom properties | ~20 (lys/mørk tema) |
| Undo-stack dybde | 50 |

---

## 13. Veikart fremover

| Fase | Beskrivelse | Status |
|------|-------------|--------|
| Fase 1 | Fundament (cache, dirty-render, module_type) | ✅ |
| Fase 2 | Layout-forbedringer (symmetri, auto-retning, beam search) | ✅ |
| Fase 3 | Varmekabel-modul | ✅ |
| Fase 4 | Varmematte-modul | ✅ |
| Fase 5 | Platesystem med kabelspor + trapp-modul | ✅ |
| Fase 6 | Avanserte funksjoner (PDF-eksport ✅, papirkurv ✅, kunde-synk ✅, dokumentasjon ⬜) | 🟡 |
