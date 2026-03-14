# Arqely — Planning Mode UX Redesign

## Context

The planning mode sidebar, contextual toolbar, and room/floor tree need a professional UX overhaul. Currently the sidebar is flat, rooms show too much inline detail, there's no room type support, no search, and the contextual toolbar (`#ctxbar`) is a simple bottom bar. The goal is a 3-level sidebar, compact visual room list, room types/status indicators, floating contextual toolbar, and reduced visual noise — all within the single-file `romtegner.html` architecture.

---

## Files Modified

- **`romtegner.html`** — all changes (single-file architecture)

---

## 1 — Sidebar 3-Level Structure

Restructure the sidebar into three clear visual zones:

**Level 1: Module Navigation** (top, already moved here)
- `#tb-module-nav` — Dashboard chip separated visually from planning module chips (Gulvvarme, Trapp, Snøsmelting, Tak & renne)
- Dashboard gets a subtle divider/separator after it
- Chips remain compact (32px height) with wrap layout

**Level 2: Project Structure Tree** (middle, scrollable)
- `#sb-tree` — Floor/room tree with collapsible floors
- Compact room items with type icons, area, and status dots
- Inline "+" buttons for adding floors/rooms (small icon buttons, not full-width block buttons)
- Room search input at top of tree when project has 5+ rooms

**Level 3: Detail / Info Panel** (bottom, collapsible)
- `#sb-obj-info` — Shows details for selected room/strip/object
- Wall list, strip list, obstacle list move HERE (out of room tree)
- Only visible when something is selected
- Stats widget (`#sb-widget-zone`) stays at bottom

### HTML changes
```
<div id="sidebar">
  <div id="tb-module-nav" class="tb-module-nav">...</div>
  <div class="sb-hdr">
    <div class="sb-hdr-label" id="sb-proj-lbl">Prosjekt</div>
    <div class="sb-hdr-actions">
      <!-- Replace full-width buttons with small icon buttons -->
      <button class="sb-icon-btn" onclick="showAddFloorModal()" title="Ny etasje">＋🏢</button>
      <button class="sb-icon-btn" onclick="showAddRoomModal(null)" title="Nytt rom">＋🚪</button>
    </div>
  </div>
  <div id="sb-search" class="sb-search" style="display:none">
    <input type="text" id="sb-search-inp" placeholder="Søk rom..." oninput="_filterSidebarRooms(this.value)">
  </div>
  <div class="sb-tree" id="sb-tree"></div>
  <div id="sb-detail-panel" class="sb-detail-panel" style="display:none">
    <div class="sb-detail-hdr">
      <span id="sb-detail-title">Detaljer</span>
      <button class="sb-detail-close" onclick="_closeDetailPanel()">✕</button>
    </div>
    <div id="sb-detail-content"></div>
  </div>
  <div id="sb-obj-info" style="display:none"></div>
  <div id="sb-widget-zone"></div>
</div>
```

### CSS
- `.sb-hdr` gets `flex-direction: row; justify-content: space-between; align-items: center` so label and action buttons are on one line
- `.sb-icon-btn` — small 28px circular icon buttons replacing the full-width block buttons
- `.sb-search` — search input with magnifying glass icon, border-bottom separator
- `.sb-detail-panel` — bottom section with max-height 40%, overflow-y auto, border-top separator
- `.sb-tree` — gets `flex: 1; min-height: 0` for proper scrolling between search and detail panel

---

## 2 — Dashboard Separated from Planning Modules

In `_renderModuleNav()` (or wherever module chips are rendered):
- Render Dashboard chip first, then a small vertical or gap separator, then planning module chips
- Dashboard chip gets a slightly different style (outline instead of filled, or different bg)
- This visually communicates "Dashboard = overview, rest = planning tools"

### CSS
```css
.tb-mod-btn.dashboard { border: 1px solid var(--border); background: transparent; }
.tb-mod-btn.dashboard.act { background: var(--surface2); border-color: var(--accent); }
.tb-module-nav .mod-sep { width: 100%; height: 1px; background: var(--border); margin: 2px 0; }
```

---

## 3 — Floor/Room Tree Improvements

### Collapsible floors like a file tree
Current implementation already has `fl.collapsed` and toggle arrows — keep this.

**Changes:**
- Floor header: reduce padding, add room count badge, make toggle arrow more visible
- Floor header right side: small "+" button to add room to that floor (replaces full-width "＋ Legg til rom" button at bottom)
- Room items under floor: indented with subtle left border line (tree connector visual)

### Floor header redesign
```
▼ 1. Etasje  [3]  [🗺] [+]
  🛁 Bad         4.2 m²  ●
  🍳 Kjøkken    12.8 m²  ●
  🛋 Stue       22.0 m²  ○
```

- Floor toggle: `▶`/`▼` (already exists)
- Floor name: editable on click (already exists)
- Room count badge: already exists as `.floor-badge`
- Background image button: already exists
- New: small "+" icon button for adding room to this floor
- Remove: full-width "＋ Legg til rom" block button below rooms

### Room item redesign
Compact single-line items:
- Room type icon (from room type system, see section 11)
- Room name (truncated)
- Area in m² (right-aligned, mono font)
- Status dot (right edge)

Remove from room items: walls list, strips list, obstacles list, cables list, mats list — all of these move to the detail panel (Level 3) shown when room is selected.

### Implementation in `roomItemHtml()`
- Remove the `wallsHtml`, strips, groups, cables, mats, obstacles, and plates sections from the inline expansion
- Return only the compact single-line room row with icon + name + area + status dot
- When a room is selected, populate `#sb-detail-panel` with the detailed content (walls, strips, etc.)

---

## 4 — Room Status Indicators

Add a status dot to each room item showing progress:

| Status | Dot | Condition |
|--------|-----|-----------|
| Not started | `○` gray | No strips, cables, mats, or plates in room |
| Has product | `◐` yellow | Has at least one heating element but coverage < target |
| Complete | `●` green | Coverage meets or exceeds target W/m² |
| Has issue | `⚠` red | Has violation warnings on any strip |

### Implementation
Add `_roomStatus(room)` function:
```javascript
function _roomStatus(room) {
  const strips = S.strips.filter(s => s.roomId === room.id);
  const cables = S.cables.filter(c => c.roomId === room.id);
  const mats = (S.mats||[]).filter(m => m.roomId === room.id);
  const plates = (S.plates||[]).filter(p => p.roomId === room.id);
  const hasProduct = strips.length + cables.length + mats.length + plates.length > 0;
  if (!hasProduct) return { id: 'empty', dot: '○', color: '#6b7280', label: 'Ikke startet' };
  // Check violations
  const hasViolation = strips.some(s => _getViolation(s.id).hasAny);
  if (hasViolation) return { id: 'issue', dot: '⚠', color: '#ef4444', label: 'Har problem' };
  // Check coverage vs target
  const targetWm2 = room.targetWm2 || _defaultTargetWm2(room.roomType);
  const actualWm2 = _roomInstalledWm2(room);
  if (actualWm2 >= targetWm2 * 0.95) return { id: 'complete', dot: '●', color: '#22c55e', label: 'Ferdig' };
  return { id: 'partial', dot: '◐', color: '#eab308', label: 'Har produkt' };
}
```

### CSS
```css
.room-status { font-size: 10px; flex-shrink: 0; margin-left: auto; }
```

---

## 5 — Detail Panel (Move Detail Out of Room List)

When a room is selected in the tree, the bottom detail panel shows:

1. **Room info header**: Name, type, area, target W/m²
2. **Walls section** (collapsible): Wall list with lengths (currently inline in room item)
3. **Heating elements section** (collapsible): Strips, cables, mats, plates, groups
4. **Obstacles section** (collapsible): Hindringer list
5. **Room actions**: Quick action buttons (rename, delete, duplicate, change type)

### Implementation
- New function `_renderDetailPanel(roomId)` called from `renderSidebar()` when `S.ui.selectedRoomId` is set
- Reuses existing HTML generation from `roomItemHtml()` — extract wall/strip/cable/mat/plate/obstacle rendering into `_renderRoomDetail(room)`
- The detail panel replaces `#sb-obj-info` functionality for rooms

---

## 6 — Inline Add Buttons (Not Block Buttons)

Replace the current full-width block buttons:
```html
<!-- Current -->
<button class="floor-add" onclick="showAddRoomModal(${fl.id})">＋ Legg til rom</button>
<button class="floor-add" onclick="showAddFloorModal()">＋ Legg til etasje</button>
```

With small inline icon buttons in the floor header and sidebar header:
```html
<!-- Floor header -->
<button class="sb-add-sm" onclick="showAddRoomModal(${fl.id});event.stopPropagation()" title="Legg til rom">+</button>

<!-- Sidebar header -->
<button class="sb-icon-btn" onclick="showAddFloorModal()" title="Ny etasje">+</button>
```

### CSS
```css
.sb-add-sm { width: 22px; height: 22px; border-radius: 4px; border: 1px solid var(--border);
  background: transparent; color: var(--muted); font-size: 14px; cursor: pointer;
  display: flex; align-items: center; justify-content: center; }
.sb-add-sm:hover { border-color: var(--accent); color: var(--accent); }
```

---

## 7 — Planning Type Switcher Redesign

The part headers (`.part-hdr`) currently look like accordion items. Redesign to be more tab-like:

- Active part: highlighted with accent left border (already exists) + slightly elevated bg
- Inactive parts: subtle, low contrast
- Part count badge: more compact, pill-shaped
- "Legg til del" button: becomes a small "+" at the end of the parts list, not a full-width block button

### CSS changes to `.part-hdr`
```css
.part-hdr { padding: 7px 12px; font-size: 12px; border-radius: 0; }
.part-hdr .floor-badge { font-size: 10px; padding: 1px 6px; border-radius: 8px;
  background: rgba(255,255,255,0.06); }
```

---

## 8 — Reduce Visual Noise

- Reduce font sizes: room names 12px (from 13px), area 10px (from 11px)
- Reduce padding: room items 7px 12px (from 10px 16px), floor headers 7px 14px (from 10px 16px)
- Remove heavy borders, use subtle 1px separators between sections only
- Mute icon colors (use `var(--dim)` instead of full color for shape icons)
- Remove the `⊡ WBW`, `⌐ L-form` shape icons from room items — replace with room type icon
- Dim unselected room areas further
- Remove unnecessary hover effects on non-interactive elements

### Key CSS changes
```css
.room-item { padding: 6px 12px; gap: 6px; }
.room-item.indented { padding-left: 28px; }
.room-ico { font-size: 13px; color: var(--dim); opacity: 0.7; }
.room-nm { font-size: 12px; }
.room-area { font-size: 10px; color: var(--dim); }
.floor-hdr { padding: 7px 14px; font-size: 12px; }
```

---

## 9 — Room Search / Filter

Add a search input at the top of the tree when project has 5+ rooms.

### Implementation
- In `renderSidebar()`, check total room count. If ≥ 5, show `#sb-search`
- `_filterSidebarRooms(query)`: filters `.room-item` elements by name match (simple `display:none` toggle)
- Also filters floor groups: hide floor if all its rooms are filtered out
- Search is instant (oninput), no debounce needed for DOM filtering
- Clear button (✕) inside search input to reset filter

### CSS
```css
.sb-search { padding: 6px 12px; border-bottom: 1px solid var(--border); }
.sb-search input { width: 100%; background: var(--surface2); border: 1px solid var(--border);
  border-radius: 6px; padding: 5px 8px; font-size: 11px; color: var(--text); }
```

---

## 10 — Room Type Support

Add room type to room objects. Types determine default icon, target W/m², and display in sidebar.

### Room types
```javascript
const ROOM_TYPES = [
  { id: 'bathroom',    label: 'Bad',         ico: '🛁', defaultWm2: 100 },
  { id: 'kitchen',     label: 'Kjøkken',     ico: '🍳', defaultWm2: 60 },
  { id: 'living',      label: 'Stue',        ico: '🛋', defaultWm2: 60 },
  { id: 'bedroom',     label: 'Soverom',     ico: '🛏', defaultWm2: 40 },
  { id: 'hallway',     label: 'Gang',        ico: '🚪', defaultWm2: 60 },
  { id: 'entrance',    label: 'Entré',       ico: '🏠', defaultWm2: 80 },
  { id: 'laundry',     label: 'Vaskerom',    ico: '🧺', defaultWm2: 80 },
  { id: 'garage',      label: 'Garasje',     ico: '🚗', defaultWm2: 40 },
  { id: 'office',      label: 'Kontor',      ico: '💼', defaultWm2: 50 },
  { id: 'storage',     label: 'Bod',         ico: '📦', defaultWm2: 0 },
  { id: 'other',       label: 'Annet',       ico: '⬡',  defaultWm2: 60 },
];
```

NOTE: Room type selection already exists in the app (added in a previous commit). Check existing `ROOM_TYPES` / `S.rooms[].roomType` to avoid duplication. If it exists, integrate with sidebar icons. If not, add `roomType` field to room objects.

### Integration
- `roomItemHtml()` uses `ROOM_TYPES.find(t => t.id === room.roomType)?.ico` instead of shape icon
- Room creation modal gets a room type dropdown (if not already present)
- Room type can be changed in detail panel
- `_defaultTargetWm2(roomType)` returns the room type's default target

---

## 11 — Contextual Floating Toolbar

Replace the fixed-bottom `#ctxbar` with a floating toolbar that appears near the selection.

### Design
- Floating bar positioned above the selected element on canvas
- Semi-transparent dark background with rounded corners and subtle shadow
- Adapts content based on selection state (same logic as current `_ctxBarItems()`)
- Follows selection on canvas pan/zoom
- Falls back to bottom position if floating would be off-screen

### Implementation approach
- Keep `#ctxbar` element but change CSS to `position: absolute` within `#canvas-wrap`
- Add `_positionCtxBar()` function that calculates position based on selected element's screen coordinates
- Call `_positionCtxBar()` from `updateCtxBar()` and on pan/zoom events
- If no specific element position available (e.g., room selected but room is large), position at top-center of canvas

### CSS
```css
#ctxbar {
  position: absolute;
  bottom: auto; top: auto; left: 50%;
  transform: translateX(-50%);
  background: rgba(20, 22, 28, 0.92);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 10px;
  padding: 4px 8px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.4);
  z-index: 20;
  pointer-events: auto;
  max-width: 90%;
}
```

### Position logic
```javascript
function _positionCtxBar() {
  const bar = document.getElementById('ctxbar');
  if (!bar || !bar.classList.contains('show')) return;
  const wrap = document.getElementById('canvas-wrap');
  const wrapRect = wrap.getBoundingClientRect();

  // Try to position above selected strip/object
  let targetY = null, targetX = null;
  if (S.ui.selectedStripId) {
    const strip = S.strips.find(s => s.id === S.ui.selectedStripId);
    if (strip) {
      const room = S.rooms.find(r => r.id === strip.roomId);
      // Convert strip world coords to screen coords via w2s()
      // Position bar 40px above the strip's top edge
    }
  }

  // Fallback: centered near top of canvas
  if (targetY === null) {
    bar.style.top = '12px';
    bar.style.left = '50%';
    bar.style.transform = 'translateX(-50%)';
    return;
  }

  // Clamp to canvas bounds
  bar.style.top = Math.max(8, targetY - 50) + 'px';
  bar.style.left = Math.min(Math.max(80, targetX), wrapRect.width - 80) + 'px';
  bar.style.transform = 'translateX(-50%)';
}
```

---

## 12 — Other Professional UX Improvements

### a) Keyboard shortcuts hint
- Show small hint text in empty canvas: "Trykk R for rektangel, P for polygon" (if no rooms exist)

### b) Drag-to-reorder rooms
- Defer to future — adds significant complexity. Note in code as `// TODO: drag-to-reorder rooms`

### c) Right-click context menus
- Already partially implemented. Ensure all objects (rooms, floors, strips) have consistent right-click menus.

### d) Toast notifications
- `_showToast()` already implemented. Use it consistently for user feedback on actions.

---

## Phased Implementation Order

### Phase A: Room Types + Status Indicators
1. Check if `ROOM_TYPES` already exists in code; if so, integrate. If not, add `ROOM_TYPES` array and `roomType` field.
2. Add `_roomStatus(room)` function
3. Update `roomItemHtml()` to show type icon + status dot
4. Update room creation to include type selection (if not already there)

### Phase B: Compact Room Items + Detail Panel
1. Strip down `roomItemHtml()` to single-line compact format (remove inline walls/strips/etc.)
2. Add `#sb-detail-panel` HTML + CSS
3. Add `_renderDetailPanel(roomId)` — shows walls, strips, cables, mats, obstacles for selected room
4. Wire up: when room is selected, populate detail panel

### Phase C: Sidebar Structure + Inline Actions
1. Restructure sidebar HTML (3-level layout)
2. Replace block "Add" buttons with small icon buttons
3. Add "+" buttons to floor headers
4. Adjust `.sb-hdr` to horizontal layout with icon buttons
5. Reduce padding/font-sizes across sidebar CSS
6. Add Dashboard separator in module nav

### Phase D: Room Search
1. Add search input HTML to sidebar
2. Implement `_filterSidebarRooms(query)` — DOM-based filtering
3. Show/hide search based on room count (≥ 5)

### Phase E: Floating Contextual Toolbar
1. Change `#ctxbar` CSS from fixed-bottom to floating absolute
2. Add `_positionCtxBar()` function
3. Call positioning from `updateCtxBar()`, pan/zoom handlers, and `render()`
4. Test all selection states (strip, cable, zone, plate, mat, stair, hindring, wall, room, nothing)

### Phase F: Visual Polish
1. Fine-tune colors, spacing, shadows
2. Reduce visual noise (mute icons, dim non-selected items)
3. Test responsive behavior with narrow sidebar
4. Ensure keyboard navigation still works

---

## Verification Plan

After each phase:
1. Start preview server (`romtegner` on port 4000)
2. Open a project with multiple floors and rooms
3. Verify sidebar 3-level layout renders correctly
4. Verify room items show type icons and status dots
5. Click a room → verify detail panel appears with walls/strips/etc.
6. Verify "+" buttons work for adding floors and rooms
7. Type in search → verify rooms filter correctly
8. Select a strip → verify floating toolbar appears near it with correct buttons
9. Pan/zoom → verify toolbar follows
10. Test all selection states in ctxbar
11. Check visual noise reduction (spacing, font sizes, icon colors)
12. Screenshot and share visual result with user
