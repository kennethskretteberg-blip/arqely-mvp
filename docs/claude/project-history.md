# Romtegner Project History

## 2026-03-23: Cable engine overhaul — polygon-aware layout, zone support, dev-bypass

### Session summary
Major rework of the cable layout engine across ~20 commits. Started with zone support for forbidden zones, evolved into a full polygon-aware cable engine.

### Forbidden zones clip cable layout (commit 95b0e10)
- `generateCableSerpentine()` now subtracts forbidden zones from cable runs (same pattern as hindrings)
- Room area calculations (`roomAreas`, `_calcNetArea`, `_computeRoomStats`) subtract forbidden zone area from netto
- Room card and PDF export show: zone area, cable coverage area, total heated area, W/m² (rom), flateeffekt

### Dev auto-login (commit 95b0e10)
- `?dev=1` URL parameter on localhost auto-logs in using `.dev-auth.json` credentials
- Server endpoint `/__dev-auth` in `serve-romtegner.js`
- Client code in `initSupabase()` detects dev flag and auto-signs in

### Cable equalization for L-shaped rooms (commits eb8405a → b6a8fb4)
- Skip equalization when run heights vary >15% (L-shaped rooms)
- Then reverted: equal-length runs are mandatory to prevent Y-splits
- Final approach: drop runs <70% of median, equalize the rest

### Length-driven cable generator (commit 6b6aee2)
- New `generateCableLayoutLengthDriven()` function
- Uses cable length as primary constraint instead of CC spacing
- Solves for n (runs) and margin using closed-form math + binary search refinement
- All callers (autoFillCable, flip direction, toggle lock, corner flip) updated

### Exact product cable length enforcement (commit 3b83569)
- Overshoot trimming added directly in `generateCableSerpentine`
- When product has `cable_length_m`, any overshoot is trimmed symmetrically from both ends
- Cable always uses exactly the product length

### Polygon-aware cable coverage engine (commits 62bb553 → f29eaf5)
Multiple iterations of a polygon-aware engine:

**v1 — Cell decomposition (62bb553)**
- `_computeHeatableArea`: scanline map of valid heatable area
- `_decomposeHeatableArea`: groups scanlines into cells by interval compatibility
- `_generateCellRuns`: per-cell serpentine with independent equalization
- `_connectCells`: orders cells and generates connection paths
- Cell-aware renderer with connection path drawing

**v2 — Polygon-clipped serpentine (0488fe2)**
- Replaced cell-based approach with ONE continuous serpentine
- Each run independently clipped to room polygon
- `_generatePolygonClippedRuns`: clips each run to actual room polygon
- `_groupAndEqualizeRuns`: per-group equalization (not global)
- `_calcTotalCableLength`: includes extension lines for height transitions

**v3 — Auto direction + mandatory equalization (f29eaf5)**
- Auto-selects optimal cable direction (V or H) based on run height uniformity
- For L-shaped rooms, horizontal direction naturally includes protrusions
- Mandatory equalization with "best overlapping group" selection for T-shaped rooms
- `_equalizeRuns()` helper: finds largest consecutive group with common overlap, equalizes
- Simple half-circle U-turn arcs (no extension lines — all runs guaranteed equal)

### Hard rules established
- **No Y-splits**: Extension lines between different-height runs ARE Y-splits (forbidden)
- **Equal-length runs**: Mandatory equalization, NEVER optional
- **Exact product length**: Cable must use exactly the specified product length

### Current architecture (as of f29eaf5)
```
generateCablePolygonAware(roomId, productId, direction, startCorner)
├── _tryDirection(dir) — evaluate V and H, pick best uniformity
├── _generatePolygonClippedRuns() — clip each run to room polygon
├── _equalizeRuns() — find best overlapping group, clip to common range
├── Length optimization:
│   ├── Phase 1: Multi-N + binary search on CC
│   ├── Phase 2: Sweep margin adjustment
│   └── Phase 3: Symmetric trim
└── Output: { runs, totalLength_cm, spacing_cm, direction, cells }
```

### Known limitations
- T-shaped rooms: equalization clips to the overlapping section only, leaving some areas uncovered
- This is a geometric constraint of single-serpentine cable layout
- Full coverage of complex rooms would require multi-serpentine (cell decomposition with inter-cell routing)

---

## 2026-03-20: Fix cable cache, dim lines, romkort power, remove calc-results box

### _cablesForRoom() cache bug — root cause of 3 issues
- `_cablesForRoom()` used a version-based cache (`_cableCacheStore`, `_cableCacheVer`) that returned stale empty arrays
- Removed cache entirely — now does direct `S.cables.filter()` every time
- This single fix resolved all three reported bugs below

### Målsett Kabel (cable dimension lines) — fixed
- Dimension lines were not appearing when "Målsett Kabel" was toggled on
- Root cause: `_drawCableDimChainForRoomInner()` called `_cablesForRoom()` which returned empty from stale cache
- Now works correctly — shows CC distances, wall margins, and cable run lengths

### Romkort showing "Installert effekt 0 W" — fixed
- Floating room info card on canvas showed 0 W even though cable label showed correct power
- Root cause: `_computeRoomStats()` called `_cablesForRoom()` → stale cache → no cables → 0 W
- Now shows correct installed power (e.g. 1632 W)

### Calc-results info box removed
- The blue "Beregningsresultater" box at the bottom was removed
- All its info (brutto, netto, hindringer, dekning, effekt) is now in the room card instead
