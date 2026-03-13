# Romtegner — Arkitektur- og Funksjonsstatus

> Sist oppdatert: 2026-03-11

---

## 1. Oversikt

| Egenskap | Verdi |
|----------|-------|
| **Fil** | `romtegner.html` (single-file app) |
| **Linjer** | ~13 700 (HTML + CSS + JS) |
| **Funksjoner** | 453 top-level functions |
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
- **Dirty-flag rendering** (infrastruktur finnes, men rAF-loop kjører ubetinget pga. drag-handlers)

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
 │    ├─ hindrings[]  (hindringer, via roomId)
 │    └─ zones[]      (forbudt/foretrukket, via roomId i S.zones)
 ├─ groups[]   (strip-grupper for multi-select)
 ├─ view       { zoom, panX, panY }
 ├─ drawing    { active, points, wbw, skillevegg, ... }
 ├─ snap       { grid, a90, a45 }
 └─ counters   { nextRoomId, nextStripId, nextCableId, nextMatId, ... }
```

### 2.3 Rendering-lag (bunn → topp)

| Lag | Funksjon | Beskrivelse |
|-----|----------|-------------|
| 1 | `drawBgImage()` | Bakgrunnstegning (PDF/JPG/PNG) |
| 2 | `drawGrid()` | Rutenett (50cm + 10cm subgrid) |
| 3 | `drawRooms()` | Rom-polygoner med veggtykkelse |
| 4 | `drawHindrings()` | Hindringer (kjøkkenøy, skap, pipe, etc.) |
| 5 | `drawZones()` | Forbudte/foretrukne soner |
| 6 | `drawMats()` | Varmematter (roterte rektangler) |
| 7 | `drawCables()` | Varmekabel-serpentiner med U-svinger |
| 8 | `drawStrips()` | Varmefolie-strips |
| 9 | `drawAllDimAnnotations()` | Vegg-dimensjoner |
| 10 | `drawUserDimLines()` | Bruker-dimensjonslinjer |
| 11 | `drawHindringDistances()` | Avstandslinjer fra hindring |
| 12 | `drawStripGapLine()` | Gap mellom strips |
| 13 | `drawRoomCards()` | Rom-infokort |
| 14 | Gizmoer | Strip/mat/hindring/gruppe/transform-gizmoer |
| 15 | `drawPreview()` | Tegnemodus-preview |
| 16 | `drawSnapDot()` | Rødt snap-punkt ved cursor |
| 17 | `drawScaleBar()` | Målestokk-referanse |
| 18 | `drawMinimap()` | Minimap-widget |

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
| Automatisk layout | ✅ | `autoFillRoom()` med beam search breddeoptimalisering |
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

### 3.4 Platesystem med kabelspor (Fase 5) ⬜ Ikke startet

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
| **Ctxbar** | Kontekstbar nederst — dynamisk basert på seleksjon |
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
| Dirty-flag | ⚠️ | Infrastruktur finnes, men deaktivert (krever render() i ~12 handlers) |
| Viewport culling | ⬜ | Planlagt for >50 rom |
| Spatial indexing | ⬜ | Planlagt for >200 objekter |
| Per-rom rendering | ✅ | Kollisjon/validering filtrerer på roomId først |

---

## 12. Nøkkeltall

| Metrikk | Antall |
|---------|--------|
| Kodelinjer totalt | ~13 700 |
| Top-level funksjoner | 453 |
| Seksjons-headers | 83 |
| Rendering-funksjoner (draw*) | ~34 |
| Hit-test funksjoner (hit*) | ~35 |
| S.ui properties | ~50 |
| HTML element IDs | ~80 |
| Modaler | 7 |
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
| Fase 5 | Platesystem med kabelspor | ⬜ |
| Fase 6 | Avanserte funksjoner (PDF-eksport, dokumentasjon, etc.) | ⬜ |
