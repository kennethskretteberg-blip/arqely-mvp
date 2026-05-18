# Render Performance — Dirty-Flag Reactivation

Sist oppdatert: 2026-05-16
Status: Endringer gjort, venter på brukerverifisering.

---

## Kontekst

Kenneth ba om å finne bedre løsninger på enkelte ting i Arqely Romtegner. Etter
en gjennomgang av kodebasen anbefalte jeg å starte med å reaktivere
dirty-flag-rendering — `_needsRender`-infrastrukturen finnes (linje 2372–2375 i
`romtegner.html`), men rAF-loopen sjekket den aldri. Dette ble dokumentert som
"⚠️ Delvis tilbakestilt" i `architecture-review.md` (seksjon 11) og
`roadmap.md` (1.3).

Grunnen til at det ble tilbakestilt sist: ~12 mousemove-handlere muterte state
uten å kalle `render()` — de baserte seg på den ubetingede rAF-loopen.

## Endringene som er gjort

Alle i `romtegner.html`. Filen er nå 30 360+ linjer (ikke 13 700 som
arkitekturdokumentet sier — det er stale).

### 1. Conditional rAF-loop (linje 30389–30412)

```js
(function loop(){
  if (_needsRender) {
    render();
    _renderCount++;
    _renderTickCount++;
    const now = performance.now();
    if (now - _renderTickStart >= 1000) {
      _renderFps = Math.round(_renderTickCount * 1000 / (now - _renderTickStart));
      _renderTickStart = now;
      _renderTickCount = 0;
      _updateRenderStatsWidget();
    }
  }
  requestAnimationFrame(loop);
})();
```

### 2. `_anyInteractionActive()` helper (linje 2377–2400)

Sjekker alle 24 drag/rotasjons-flagg på én linje:

```
_panning, _dragging,
_roomDragging, _movingWall, _hwMoving,
_stripDragging, _sgDragging, _sgEndDragging,
_groupDragging, _groupEndDragging,
_dhDragging, _dhRotating,
_matDragging, _matRotating,
_plateDragging, _stairDragging,
_vdDragging, _vdPending,
_dimOffDragging, _annotDragging,
_cardDragging, _cableLabelDragging, _cableGizmoDragging,
_thDragging, _mmDragging, _vfPickDrag
```

**OBS:** Dersom en ny drag-flagg legges til i framtiden uten å oppdatere
denne listen, vil dragingen virke frossen til mouseup. Det er en fotnote i
kommentaren over funksjonen.

### 3. Safety net i canvas mousemove (linje ~22388)

```js
canvas.addEventListener('mousemove', e=>{
  if (_anyInteractionActive()) markDirty();
  // ... resten av handleren uendret
});
```

Dette er hovedmekanismen som gjør conditional rAF trygg uten å redigere alle
12+ drag-branchene individuelt.

### 4. `markDirty()` i felles funksjoner

- `pushUndo()` (linje ~21316) — fanger alle undo-trackede mutasjoner
- `undo()` (linje ~21404) — pluss invalideringer av violations
- `renderSidebar()` (toppen) — fanger alt som påvirker sidebar
- `updateCtxBar()` (slutten) — fanger alle seleksjons-endringer
- `resizeCanvas()` — buffer cleares ved resize
- `keydown`-handler (rett etter INPUT-guard) — alle taster trigger 1 render
- `wheel`-handler (slutten) — zoom/pan
- `_vfDirEvt()` — retningsvelger påvirker autofill-piler

### 5. FPS-widget bak Ctrl+Shift+P

HTML-element `#render-stats` lagt til i `#canvas-wrap` (linje ~1280).
Toggle i keydown-handleren (linje ~23439–23454).
Format: `0 fps · 12345 total`.

Idle-tikker via `setInterval(500ms)` (linje ~2415) resetter visningen til 0
når render-loopen står stille — ellers ville visningen frosset på siste verdi.

## Hvordan teste

1. Start serveren: `cd ~/Documents/Claude\ Code/arqely-mvp && node serve-romtegner.js`
2. Åpne `http://localhost:4000`
3. Trykk **Ctrl+Shift+P** for å vise FPS-telleren midt-øverst på canvas
4. Verifiser:
   - Musa stille → `0 fps` etter ~1 sekund
   - Pan (space+drag eller midt-museknapp) → 60 fps under drag, 0 etter slipp
   - Wheel-zoom → enkeltvise render-pulser
   - Tegn rom, drag strip, undo/redo → alt skal fungere som før
   - `total`-telleren skal slutte å øke når man ikke gjør noe

## Mulige etterskjelv

Dersom noe ser frosset ut (objekt som ikke oppdaterer mens man drar):

1. Finn hvilken drag-flagg som er aktiv (sett breakpoint i mousemove eller
   console.log i den spesifikke drag-branchen)
2. Legg flagget til i `_anyInteractionActive()` (linje 2386–2399)
3. Verifiser at flagget er deklarert med `let` på modul-nivå

## Hva som IKKE ble gjort i denne runden

### Violations-recompute (linje 2431–2432 i render())

```js
_violationsDirty = true;
_cableViolationsDirty = true;
_recomputeViolationsIfDirty();
_recomputeCableViolationsIfDirty();
```

Disse "selvsaboterer" violations-cachen — de tvinger recompute hver render.
Beslutning: Beholdt for nå. Med conditional rAF kjører dette kun når render()
faktisk kalles (typisk 1–60 ganger per sekund under drag, 0 ved idle) i stedet
for 60 ganger per sekund alltid. Det er ~99 % av gevinsten.

For å trygt fjerne disse, må alle mutasjonspunkter for `S.strips` audites for
å sikre at de kaller `_invalidateViolations()`. Cable-siden har bedre
dekning (8 invalideringspunkter), strip-siden bare 5.

### Cable-algoritme-opprydding

5+ cable-layout-algoritmer eksisterer side om side: `_v1_LEGACY`,
`generateCablePolygonAware`, `generateCablePolygonV5`, `generateCableV6`,
`generateCableLayoutLengthDriven`, pluss seed/beam-varianter. 68 treff
totalt på `_v\d+\w+|generateCable\w+`.

Neste anbefalte steg: kartlegg hvilken som faktisk brukes (`autoFillCable()`
ved linje 9327 er innfallsporten), arkiver legacy-funksjonene til
`docs/claude/cable-algorithm-archive.md` for referanse.

### Andre identifiserte forbedringsmuligheter

Fra første gjennomgang, ikke implementert:

1. **Single-file vs ES modules** — 30 360+ linjer er over LLM-kontekstgrensen.
   Foreslår migrering til `src/state.js`, `src/render.js`, `src/cable.js`
   osv. med `<script type="module">`. Ingen bundler.

2. **S.ui-restrukturering** — ~80 felter i en flat bucket. Mange modi
   (`pinPlaceMode`, `matPlaceMode`, `platePlaceMode`, `stairPlaceMode`,
   `manualPlaceMode`, `zoneDrawMode`...) burde være en eksplisitt state
   machine. Et deprecated felt (`thermostatPlaceMode`) ligger fortsatt
   igjen.

3. **2 ubrukte worktrees** i `.claude/worktrees/` motsier `CLAUDE.md`-regelen
   "NEVER create worktrees". `compassionate-wu` og `naughty-banzai-ec63a1`.
   Sikker å slette.

4. **Documentation-modul, PDF-eksport, signature pad** sitter i samme fil —
   kandidater for egne moduler hvis du går for ES modules.

### UX-redesign-plan tilbakemelding

`docs/claude/ux-redesign-plan.md` ble lest fullt og kommentert. Hovedpunkter:

- Sterk: 3-nivå sidebar, detail panel, status-prikker, fase-ordning
- Skeptisk til: floating ctxbar (bekreft mot installatør-bruker først)
- Vurder: SVG-ikoner i stedet for emoji (konsistens på tvers av OS)
- Endre: vis søk alltid (ikke skjul ved <5 rom)
- Mangler: tomstate-design, responsivt for iPad på byggeplass
- Foreslår: drag-to-reorder rooms — ikke "fremtid", lavhengende frukt
- Foreslår: status for "overdimensjonert" (>110 % target W/m²)

## Filer endret denne sesjonen

- `romtegner.html` — kun denne filen
- `docs/claude/perf-render-session.md` — dette dokumentet (ny)

## Ingen commit gjort

`CLAUDE.md` foreskriver at commit/push kun skjer på eksplisitt forespørsel.
Endringene står uncommitted i working directory.
