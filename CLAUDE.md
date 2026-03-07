# Project: Romtegner (Room Designer)

A browser-based engineering tool for designing electric heating systems in buildings.
Built for electricians and heating professionals.

---

# Current Codebase

The entire application lives in a single HTML file:
- **App:** `romtegner.html` (HTML + CSS + JS, all-in-one)
- **Server:** `serve-romtegner.js` (minimal Node.js static server, port 4000)
- **Backend:** Supabase (product catalog, project storage)
- **No build step.** No npm, no bundler. Pure HTML/JS/CSS.
- **Launch config:** `.claude/launch.json` — start with preview server name `romtegner`

When modifying code, respect that this is a single-file architecture.
Do not split into multiple files unless explicitly requested.

---

# Core Design Philosophy

The system follows a deterministic, object-based CAD-like architecture.
All geometry is stored as objects in a world coordinate system (centimeters).
Rendering is always derived from state — no graphical data is stored as pixels.

---

# World Coordinate System

All geometry exists in world coordinates (cm).
Rendering to screen uses the transform function `w2s()` (world-to-screen).
Screen coordinates must never be stored in state.

---

# State Object (S)

The central state object `S` holds all project data. Key properties:

```
S.rooms        — array of room objects (polygon points, metadata)
S.strips       — array of heating foil strip objects
S.varmefolie   — foil placement settings (direction, startCorner, gapCm)
S.ui           — UI state (selections, mode, hover, etc.)
S.counters     — auto-increment IDs (nextStripId, etc.)
S.project      — project metadata (name, description)
```

All rendering and calculations derive from `S`. Push to undo stack with `pushUndo()` before mutations.

---

# Object Model — Heating Foil Strips

Heating foil strips are stored in `S.strips`.

Structure:
```
{
  id,            // unique auto-increment ID
  roomId,        // reference to parent room
  productId,     // reference to product in HEATING_PRODUCTS
  direction,     // 'v' (vertical) or 'h' (horizontal)
  pos_cm,        // position across the room (cm)
  start_cm,      // start position along the strip (cm)
  length_cm      // length of the strip (cm)
}
```

Product data (via `productId`) contains:
- width (mm / netto mm)
- power (W/m²)
- article number and name

This enables automatic calculation of installed power, covered area, and material lists.

---

# Interactive Objects

Strips support full interaction:
- selection (stored in `S.ui.selectedStripIds`)
- hover
- move and resize
- grouping

Objects remain editable after placement.

---

# Rule System

The system includes installation rules:
- 25 mm safety zone from walls
- no overlapping heating foil
- no placement inside obstacles

Rules may be overridden by the user, but the system must always show warnings.

---

# Rooms

Rooms are the primary container for all objects.
Creation methods:
- rectangle (length + width)
- L-shape
- polygon drawing
- wall-by-wall input

Room geometry uses room-local coordinates.

---

# Background Drawings

Rooms may use background drawings (PDF, JPG, PNG) as visual references.
Background files are loaded per project.
If a background file is replaced with the same filename, the system reloads it automatically, preserving scale and placement.

---

# Rendering Layers

Rendering follows a layer-based approach (bottom to top):
1. Background drawing
2. Walls
3. Rooms
4. Obstacles
5. Heating elements
6. Labels
7. UI overlays

---

# Performance Principles

Avoid heavy recalculations during rendering.
Preferred techniques:
- cached calculations
- bounding boxes
- incremental updates

Rendering must remain smooth even with many heating elements.

---

# Code Style Guidelines

When modifying code:
- prefer small, incremental changes
- do not rewrite large parts of the system
- explain architectural changes before implementing
- maintain backward compatibility
- prioritize clarity over cleverness
- always test changes visually via the preview server

---

# Future (not yet implemented)

The following features are planned but do not exist in the codebase yet.
Do not build infrastructure for these unless explicitly requested.

## Additional Heating Modules
- Heating Cable
- Heating Mats
- Outdoor Snow Melting

Each future module will use the same architecture: object-based geometry, product references, rule validation, and power calculations.

## Documentation Module
Mobile-friendly installation documentation for electricians:
- electrical measurements
- installation checklists
- photo upload to cloud
- link documentation to project/room
- generate final installation document (project info, products, measurements, images, signature)

## Project Export (PDF)
Export functionality for:
- room drawings with heating layouts
- installed power and equipment lists
- product information
- suitable for customer delivery and project documentation

## Long-Term Vision
Professional engineering tool for electric heating design with:
- automatic heating layout
- power optimization
- installation validation
- full project documentation
- integration with supplier product databases
