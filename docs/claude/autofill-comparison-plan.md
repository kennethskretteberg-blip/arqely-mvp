# Auto-Fill: Smart Direction Comparison + Obstacle-Tight Placement

## Context

The user wants the auto-fill system to be smarter and more autonomous. Currently it relies on user-selected direction and start corner, centers strips symmetrically (cold zones split evenly on both sides), and immediately applies one solution. The user wants:

1. **Both directions tried automatically** — show "Løsning A: Horisontal" and "Løsning B: Vertikal" with strip count and coverage %
2. **Strips tight against obstacles** — cold zones pushed to walls, not centered. The important heating zones are in the middle of the room near obstacles.
3. **Direction/start corner ignored** — the system finds the optimal layout automatically

---

## File Modified

- **`romtegner.html`** — all changes (single-file architecture)

---

## 1 — Cold Zone Placement: Tight Against Obstacles

### Current behavior (`_centerStripDefs`, line 3654)
Cold zones are split 50/50 on both sides of the strip group. This pushes strips to the center, leaving equal gaps at both walls.

### New behavior
Cold zones should be pushed **toward the nearest wall**, so strips sit tight against obstacles (and each other). The middle of the room gets full coverage.

### Implementation

**Modify `_centerStripDefs(defs, room, direction)`** (line 3654):

Instead of centering:
```javascript
const coldEach = (available - totalWidth) / 2;
const shift = (basePos + MARGIN + coldEach) - cols[0];
```

Push all cold zone to the wall that's **farthest from any obstacle**:
```javascript
// Find obstacle projections on placement axis
const hindrings = (S.hindrings||[]).filter(h => h.roomId === room.id && h.points?.length >= 3);
if (hindrings.length === 0) {
  // No obstacles — center as before
  coldEach = totalCold / 2;
  shift = (basePos + MARGIN + coldEach) - cols[0];
} else {
  // Find obstacle center of mass on placement axis
  const obsCenters = hindrings.map(h => {
    const vals = h.points.map(p => isV ? p.x : p.y);
    return (Math.min(...vals) + Math.max(...vals)) / 2;
  });
  const obsAvg = obsCenters.reduce((a,b)=>a+b,0) / obsCenters.length;
  const roomCenter = (basePos + baseMax) / 2;

  // If obstacles are closer to the high end, push cold zone to low end (and vice versa)
  if (obsAvg > roomCenter) {
    // Obstacles toward right/bottom → push strips toward right/bottom, cold zone at left/top
    shift = (baseMax - MARGIN - totalWidth) - cols[0]; // align strips to high end
  } else {
    // Obstacles toward left/top → push strips toward left/top, cold zone at right/bottom
    shift = (basePos + MARGIN) - cols[0]; // align strips to low end
  }
}
```

**Also modify `_obstacleAwareFill` gap-section centering** (line ~3598):
Change from:
```javascript
const coldZone = (available - totalWidth) / 2;
let cur = section.from + Math.max(0, coldZone);
```
To: push strips tight against the obstacle side of each gap:
```javascript
// For gaps between wall and obstacle: push strips toward the obstacle
// For gaps between obstacle and wall: push strips toward the obstacle
const isBeforeObs = sectionIndex < sections.findIndex(s => s.type !== 'gap');
const cur = isBeforeObs
  ? section.to - totalWidth  // push toward obstacle (right/bottom of gap)
  : section.from;            // push toward obstacle (left/top of gap)
```

**Also modify `_fillZone` centering** (line ~3483):
Same principle — push cold zones toward walls, not centered.

---

## 2 — Try Both Directions Automatically

### Current behavior (`autoFillRoom`, line 3692)
Tries both directions internally but only to pick the single best. The alternate direction needs to beat the preferred direction by >10% to be chosen.

### New behavior
`autoFillRoom` returns **both** solutions. A new function `startAutoFillComparison` orchestrates the UI.

### Implementation

**New function: `_autoFillBothDirections(room, sortedProds)`**

Returns `{ horizontal: { defs, stats }, vertical: { defs, stats } }` where stats = `{ stripCount, coverage, totalWatt, widthTypes }`.

```javascript
function _autoFillBothDirections(room, sortedProds) {
  const results = {};
  for (const dir of ['h', 'v']) {
    // Try all strategies for this direction
    const greedy1 = _autoFillRoomOnce(room, sortedProds, dir, false);
    const greedy2 = _autoFillRoomOnce(room, sortedProds, dir, true);
    const beam = _beamSearchFill(room, sortedProds, dir);

    let best = [greedy1, greedy2, beam].sort((a,b) => score(b) - score(a))[0];

    // Also try obstacle strategies if applicable
    if (hasObstacles) {
      const zone = _zoneFillRoom(room, sortedProds, dir);
      const obs = _obstacleAwareFill(room, sortedProds, dir);
      best = [best, zone, obs].sort((a,b) => score(b) - score(a))[0];
    }

    // Apply cold-zone-to-walls shift
    best = _shiftStripDefsToObstacles(best, room, dir);

    const netArea = _calcNetArea(room);
    const coveredArea = best.reduce((s,d) => s + (d.length_cm * _stripNettoCmById(d.productId)) / 10000, 0);
    const totalW = best.reduce((s,d) => {
      const p = HEATING_PRODUCTS.find(x=>x.id===d.productId);
      return s + (p?.watt_per_m2 || 60) * (d.length_cm * (p?.netto_width_mm||p?.width_mm||0)/10) / 10000;
    }, 0);
    const widthSet = new Set(best.map(d => d.productId));

    results[dir] = {
      defs: best,
      stats: {
        stripCount: best.length,
        coveragePct: Math.round(coveredArea / netArea * 100),
        totalWatt: Math.round(totalW),
        wattPerM2: Math.round(totalW / netArea),
        widthTypes: widthSet.size
      }
    };
  }
  return results;
}
```

---

## 3 — Comparison UI: Show Both Solutions

### Design
When user clicks auto-fill, show a **floating comparison panel** over the canvas with two options:

```
┌──────────────────────────────────────────────┐
│  Automatisk plassering                       │
│                                              │
│  ○ Horisontal        ○ Vertikal              │
│    4 striper           3 striper             │
│    82% dekning         76% dekning           │
│    420 W (48 W/m²)     380 W (43 W/m²)       │
│                                              │
│  [Bruk horisontal]  [Bruk vertikal]          │
│                      [Avbryt]                │
└──────────────────────────────────────────────┘
```

- Hovering/selecting an option shows a **live preview** of that layout on the canvas (temporary strips drawn with dashed outlines)
- Clicking "Bruk" applies the chosen layout
- The better option is pre-selected and marked with a ★

### Implementation

**New HTML element** (inside `#canvas-wrap`):
```html
<div id="autofill-compare" class="autofill-compare" style="display:none">
  <!-- Populated dynamically -->
</div>
```

**CSS:**
```css
.autofill-compare {
  position: absolute;
  top: 50%; left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(20, 22, 28, 0.95);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255,255,255,0.12);
  border-radius: 12px;
  padding: 20px 24px;
  z-index: 50;
  color: var(--text);
  min-width: 340px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.5);
}
.af-option {
  display: inline-block;
  width: 48%;
  text-align: center;
  padding: 12px;
  border: 1px solid var(--border);
  border-radius: 8px;
  cursor: pointer;
  transition: border-color 0.15s;
}
.af-option:hover, .af-option.selected {
  border-color: var(--accent);
  background: rgba(255,255,255,0.04);
}
.af-option .af-dir { font-weight: 600; font-size: 14px; }
.af-option .af-stat { font-size: 12px; color: var(--dim); margin-top: 4px; }
.af-option .af-best { color: var(--accent); font-size: 10px; }
.af-actions { margin-top: 16px; display: flex; gap: 8px; justify-content: center; }
.af-actions button { padding: 7px 16px; border-radius: 6px; font-size: 12px; cursor: pointer; }
.af-btn-primary { background: var(--accent); color: #fff; border: none; }
.af-btn-secondary { background: transparent; border: 1px solid var(--border); color: var(--text); }
```

**New function: `showAutoFillComparison(familyName, categoryId, maxWidthMm)`**

Replaces direct call to `startAutoFill` from product menu buttons:

```javascript
function showAutoFillComparison(familyName, categoryId, maxWidthMm) {
  const room = S.rooms.find(r => r.id === S.ui.selectedRoomId);
  if (!room) { alert('Velg et rom først'); return; }

  let prods = HEATING_PRODUCTS
    .filter(p => p.category_id === categoryId && p.active !== false && ...)
    .sort(widest first);
  if (maxWidthMm) prods = prods.filter(p => width <= maxWidthMm);
  if (!prods.length) { alert('Ingen produkter'); return; }

  const results = _autoFillBothDirections(room, prods);

  // Store for preview and application
  S.ui.autoFillCompare = results;
  S.ui.autoFillCompareProds = prods;
  S.ui.autoFillCompareCategoryId = categoryId;

  // Render comparison panel
  _renderAutoFillComparePanel(results);

  // Show preview of better option by default
  const better = results.h.stats.coveragePct >= results.v.stats.coveragePct ? 'h' : 'v';
  _previewAutoFillOption(better);
}
```

**`_renderAutoFillComparePanel(results)`** — builds HTML for the comparison panel.

**`_previewAutoFillOption(dir)`** — temporarily draws the chosen option's strips as dashed outlines on the canvas (stored in `S.ui.autoFillPreviewDefs`), rendered in `drawStrips()` with a special preview style.

**`_applyAutoFillOption(dir)`** — applies the selected option: clears old strips of same category, pushes new strip defs to `S.strips`, hides comparison panel.

---

## 4 — Wire Up: Replace startAutoFill Calls

### Current UI trigger (lines 3187-3192):
```javascript
onclick="startAutoFill(${sq(familyName)},${categoryId},${mm})"
onclick="startAutoFill(${sq(familyName)},${categoryId},null)"
```

### Change to:
```javascript
onclick="showAutoFillComparison(${sq(familyName)},${categoryId},${mm})"
onclick="showAutoFillComparison(${sq(familyName)},${categoryId},null)"
```

Keep `startAutoFill` as fallback for programmatic use but the UI always goes through comparison.

---

## 5 — Preview Rendering

In `drawStrips()`, after drawing real strips, also draw preview strips if `S.ui.autoFillPreviewDefs` is set:

```javascript
// At end of drawStrips():
if (S.ui.autoFillPreviewDefs) {
  for (const def of S.ui.autoFillPreviewDefs) {
    // Draw with dashed outline, semi-transparent fill, no busbars
    // Similar to existing strip rendering but with preview styling
  }
}
```

---

## Implementation Order

1. **Cold zone shift** — modify `_centerStripDefs` to push cold zones to walls when obstacles exist
2. **Both-direction function** — create `_autoFillBothDirections`
3. **Comparison panel** — HTML, CSS, render function
4. **Preview rendering** — dashed preview strips on canvas
5. **Wire up** — replace `startAutoFill` calls with `showAutoFillComparison`
6. **Test** — verify with room+obstacle scenario

---

## Verification

1. Start preview server (`romtegner` on port 4000)
2. Open project with room containing obstacles
3. Click auto-fill product button
4. Verify comparison panel appears with H and V stats
5. Hover each option → verify preview strips appear on canvas
6. Click "Bruk" → verify strips are applied correctly
7. Verify strips are tight against obstacles, cold zones at walls
8. Test room without obstacles → verify centered cold zones still work
9. Screenshot and verify visual result
