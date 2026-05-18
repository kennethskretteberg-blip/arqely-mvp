# Cable algorithm archive

Removed dead legacy cable-coverage functions from `romtegner.html`.
None were called anywhere — kept here purely for reference.

The active fallback chain in `autoFillCable()` is:
`generateCableSerpentine` → `generateCableV6` → `generateCablePolygonV5`
→ `generateCablePolygonAware` → `generateCableLayoutLengthDriven`.

## `_generateCablePolygonAware_v1_LEGACY`

Top-level polygon-aware cable generator, v1. Replaced by `generateCablePolygonAware`
("v2"). Used the older `_computeHeatableArea` / `_decomposeHeatableArea` /
`_generateCellRuns` / `_connectCells` / `_optimizeCableLengthPolygon` helpers.

```js
function _generateCablePolygonAware_v1_LEGACY(roomId, productId, direction, startCorner) {
  const room = S.rooms.find(r => r.id === roomId);
  if (!room || !room.points || room.points.length < 3) return null;
  const prod = HEATING_PRODUCTS.find(p => p.id === productId);
  if (!prod) return null;

  const minSp = (prod.min_spacing_mm || 50) / 10;
  const maxSp = (prod.max_spacing_mm || 200) / 10;
  const startFromHigh = (startCorner === 'br' || startCorner === 'tr');

  // Calculate initial spacing from area and product
  let spacing;
  if (prod.cable_length_m) {
    const areas = roomAreas(room);
    const nettoM2 = areas.net / 10000;
    spacing = Math.max(minSp, Math.min(maxSp, (nettoM2 / prod.cable_length_m) * 100));
  } else {
    spacing = Math.max(minSp, Math.min(maxSp, (prod.recommended_spacing_mm || 100) / 10));
  }

  // Phase 1: Compute heatable area
  const heatableArea = _computeHeatableArea(roomId, productId, direction);
  if (!heatableArea || heatableArea.scanlines.length === 0) return null;

  // Phase 2: Decompose into cells
  const cells = _decomposeHeatableArea(heatableArea, spacing);
  if (cells.length === 0) return null;

  // Phase 3: Generate runs per cell
  const cellResults = [];
  for (const cell of cells) {
    const cellPerpW = cell.perpMax - cell.perpMin;
    const cellSweepH = cell.sweepRange.hi - cell.sweepRange.lo;
    const margin = _effectiveMarginCm(productId);
    const uR = spacing / 2;
    const sweepMarg = margin + uR;

    let cellDir = direction;
    let cellForGen = cell;
    const orthoSweepWidth = cellPerpW - 2 * sweepMarg;
    const orthoN = orthoSweepWidth > 0 ? Math.floor(cellSweepH / spacing) + 1 : 0;

    if (cellPerpW < spacing * 2.5 && cellSweepH > spacing * 3 && orthoN >= 3 && orthoSweepWidth > 0) {
      cellDir = direction === 'v' ? 'h' : 'v';
      cellForGen = {
        ...cell,
        perpMin: cell.sweepRange.lo,
        perpMax: cell.sweepRange.hi,
        sweepRange: { lo: cell.perpMin, hi: cell.perpMax }
      };
    }

    const cellStartHigh = cellDir === direction ? startFromHigh
      : (startCorner === 'tl' || startCorner === 'tr');

    const res = _generateCellRuns(cellForGen, cellDir, spacing, room, productId, cellStartHigh);
    if (res) cellResults.push(res);
  }
  if (cellResults.length === 0) return null;

  // Phase 4: Connect cells
  let { ordered, connections } = _connectCells(cellResults, direction, startCorner);

  // Phase 5: Length optimization
  if (prod.cable_length_m) {
    const targetLen = prod.cable_length_m * 100;
    let totalLen = ordered.reduce((s, c) => s + c.totalLength_cm, 0);
    totalLen += connections.reduce((s, c) => s + c.length_cm, 0);

    if (Math.abs(totalLen - targetLen) > 1) {
      const opt = _optimizeCableLengthPolygon(roomId, productId, direction, startCorner, cells, ordered, connections, targetLen);
      if (opt) {
        ordered = opt.cells;
        connections = opt.connections;
      }
    }
  }

  const flatRuns = [];
  for (const cell of ordered) {
    if ((cell.direction || direction) === direction) {
      for (const run of cell.runs) flatRuns.push(run);
    }
  }

  let totalLength = ordered.reduce((s, c) => s + c.totalLength_cm, 0);
  totalLength += connections.reduce((s, c) => s + c.length_cm, 0);

  const effSpacing = ordered.length > 0 && ordered[0].runs.length > 1
    ? Math.abs(ordered[0].runs[1].pos_cm - ordered[0].runs[0].pos_cm)
    : spacing;

  console.log(`[CablePolygonAware] cells=${ordered.length}, runs=${flatRuns.length}, spacing=${effSpacing.toFixed(1)}cm, total=${(totalLength/100).toFixed(1)}m${prod.cable_length_m ? ', target=' + prod.cable_length_m + 'm, diff=' + ((totalLength - prod.cable_length_m*100)/100).toFixed(2) + 'm' : ''}`);

  return {
    runs: flatRuns,
    totalLength_cm: totalLength,
    spacing_cm: effSpacing,
    cells: ordered,
    connections
  };
}
```

## `_drawDebugCableCells_v1_LEGACY`

Debug overlay for the v1 cell decomposition. Replaced by the v2 `_drawDebugCableCells`.

```js
function _drawDebugCableCells_v1_LEGACY() {
  if (!S.ui._debugCableCells) return;
  const room = S.rooms.find(r => r.id === S.ui.selectedRoomId);
  if (!room) return;
  const cable = S.cables.find(c => c.roomId === room.id);
  if (!cable || !cable.cells) return;

  const colors = ['rgba(255,100,100,0.15)', 'rgba(100,255,100,0.15)', 'rgba(100,100,255,0.15)', 'rgba(255,255,100,0.15)'];

  ctx.save();
  for (let i = 0; i < cable.cells.length; i++) {
    const cell = cable.cells[i];
    const b = cell.bounds;
    if (!b) continue;
    const dir = cable.direction;
    const tl = dir === 'v' ? w2s(b.xMin, b.yMin) : w2s(b.yMin, b.xMin);
    const br = dir === 'v' ? w2s(b.xMax, b.yMax) : w2s(b.yMax, b.xMax);
    ctx.fillStyle = colors[i % colors.length];
    ctx.fillRect(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
    ctx.strokeStyle = colors[i % colors.length].replace('0.15', '0.6');
    ctx.lineWidth = 2;
    ctx.setLineDash([6, 4]);
    ctx.strokeRect(tl.x, tl.y, br.x - tl.x, br.y - tl.y);
    ctx.setLineDash([]);
    ctx.fillStyle = 'rgba(0,0,0,0.7)';
    ctx.font = "bold 11px 'DM Sans',sans-serif";
    ctx.textAlign = 'center';
    ctx.fillText(`Cell ${i} (${cell.runs.length} runs)`, (tl.x + br.x) / 2, tl.y + 14);
  }
  if (cable.connections) {
    ctx.strokeStyle = 'rgba(255,140,0,0.7)';
    ctx.lineWidth = 2;
    ctx.setLineDash([4, 3]);
    for (const conn of cable.connections) {
      if (conn.path.length < 2) continue;
      const p0 = w2s(conn.path[0].x, conn.path[0].y);
      const p1 = w2s(conn.path[1].x, conn.path[1].y);
      ctx.beginPath();
      ctx.moveTo(p0.x, p0.y);
      ctx.lineTo(p1.x, p1.y);
      ctx.stroke();
    }
    ctx.setLineDash([]);
  }
  ctx.restore();
}
```
