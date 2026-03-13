# UI Design Principles

## Gizmo (Room Selection Handle)
Standard behavior when a room is selected:
- **Red arrow:** Horizontal movement (constrained to X-axis)
- **Green arrow:** Vertical movement (constrained to Y-axis)
- **Cross in center:** Free movement (both axes)
- **Default mode:** Move
- **Ctrl+R:** Switch to rotation mode
- **Ctrl+F:** Switch back to move mode
- Mode can also be toggled via chips/buttons in the UI

## Unsaved Changes Warning
**Mandatory principle:** The user must ALWAYS be warned before losing unsaved work.
- `beforeunload` must trigger whenever the user is inside a project (app visible)
- Never allow refresh, close, or navigation without a save warning
- The check is based on project state (app visible), NOT on whether rooms exist
- `_skipUnloadWarning` may only be set after explicit user action (save+quit or quit without saving)

## Panning During Draw Mode
- **Space+drag:** Temporary pan (original method)
- **Shift+drag:** Also pans during draw mode (for precision work on background drawings)
- **Shift+click (no drag):** Releases angle snap (no conflict with pan)
- Middle mouse button and Alt+left also pan in all modes

## Background Drawings
- Default opacity: **100%** (full visibility), adjustable with slider
- Calibration line snaps to 90° (H/V) by default, respects snap chips and Shift
- Floor creation offers choice: "Importer plantegning" or "Tegn fritt"
- Same-filename replacement preserves position, scale, and opacity
- **Forced calibration:** After importing a new BG, a fullscreen overlay (`#bg-calib-overlay`) blocks the canvas until the user calibrates the scale or removes the background
- `bg._needsCalibration` flag tracks uncalibrated state; cleared after `confirmBgCalibrate()` or `removeBgImage()`
- Ctxbar also blocks room buttons when `_needsCalibration` is true

## Modal Button Pattern (`.floor-choice-btn`)
- All modal choice buttons use neutral style by default (transparent bg, muted color)
- On `:focus` (Tab or click): blue background (`var(--accent)`) with dark text
- Enter key triggers the focused button via `onkeydown` handler on modal container
- Applied to all modals: new project, floor, room, shape, hindring, rect, lshape, bg-calib

## Canvas Context Menu (via `#ctxbar`)
The `#ctxbar` element serves dual purpose — it shows contextual tools based on what's selected:
- **Room selected:** Skillevegg, Hindring, Produkt, Sentrer, Gap, Målsett Rom, Mållinje
- **Nothing selected (floors exist):** Room creation tools — name input + shape buttons
- **Draw mode active:** Hidden
- **No floors:** Hidden

### "Nothing selected" state:
- **Room creation:** Input field `#ctxbar-room-name` + Rektangel, Polygon, L-form, WBW, Yttervegg buttons
- **Context filtering:** With bg imported → only rect2, polygon, yttervegg. Without bg → all 5 shapes
- **BG controls (when bg exists):** Vis checkbox, opacity slider, 📏 calibrate, 🔄 replace, ✕ remove
- **Calibration warning:** `_showCalibWarningInCtxbar()` temporarily replaces ctxbar content with warning + "Ignorer"/"Sett målestokk" buttons
- **Post-calibration hint:** "✅ Kalibrert — velg romtype →" prepended to ctxbar for 5 seconds

### Key functions:
- `_ctxBarItems()` — generates HTML based on selection state (extended with "nothing selected" block)
- `updateCtxBar()` — rebuilds ctxbar content + calls `_updateVfDirVisibility()`
- `abStartDraw(shape)` — reads room name from `#ctxbar-room-name`, starts draw mode
- Legacy wrappers: `showBgPanel()`, `hideBgPanel()`, `showDrawToolbar()` all call `updateCtxBar()`

## Leggeretning Widget (`#vf-dir-widget`)
- Only visible when a room is selected (enforced by `_updateVfDirVisibility()`)
- Hidden automatically when room is deselected
- `initVfDirWidget()` has room-selection guard at top

## Input Fields
- **Auto-select on focus:** All `input[type=number]` and `input[type=text]` auto-select their value on focus via global `focusin` listener
- Opt-out with `data-no-auto-select` attribute
- Uses `setTimeout(() => el.select(), 0)` for cross-browser compatibility

## Calibration Modal
- **Two-field input:** Whole number (`#bg-calib-dist`) + decimal (`#bg-calib-dec`)
- Large monospace font (20px, DM Mono) for clarity
- Prominent comma separator (22px bold, accent color) between fields
- Dynamic unit label synced by `setCalibUnit()` (m/cm/mm)
- Unit chips: m (default), cm, mm
