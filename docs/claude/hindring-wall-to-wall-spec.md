# Hindring vegg-til-vegg — velg side

Sist oppdatert: 2026-05-16
Status: Spek og prompt klar for Claude Code. Ikke implementert.

---

## Brukerproblem

Når Kenneth tegner en hindring fra vegg til vegg (typisk en kjøkkenbenk
eller annen innredning som spenner over rommet), deles rommet visuelt i
to deler. I dag må han tegne hele hindring-polygonet manuelt, som er
upresist og slitsomt.

**Ønsket flow:**
1. Bruker velger "Hindring vegg-til-vegg" fra hindring-menyen.
2. Tegner en strek (med valgfrie mellompunkter) fra én vegg til en annen.
3. Streken deler rommet i to deler — begge markeres tydelig.
4. Hint-tekst: "Trykk på området som skal være hindring."
5. Bruker klikker den ene delen → den blir hindring, den andre forblir rom.

## Eksisterende kode-grunnlag

Skillevegg-flowen har samme geometri-problem (polyline mellom to vegger
deler rom). `splitRoomWithPolyline(room, polyline, startWallIdx, endWallIdx)`
på linje ~19865 returnerer `[polyA, polyB]` — vi gjenbruker den.

**Forskjell fra skillevegg:**
- Skillevegg erstatter rommet med to nye rom (begge får vegger med tykkelse)
- Hindring lar rommet være uendret, og den ene polygon-delen blir en
  hindring innenfor rommet

## Arkitektur

### Ny draw mode

```js
S.ui.drawMode = 'hindring-w2w';   // wall-to-wall
```

Lagt til i `drawMode`-kommentar på linje ~2009 ved siden av eksisterende
`'hindring'` og `'hindring-polygon'`.

### State

Gjenbruk skillevegg-state-mønsteret. Ny state-blokk:

```js
S.drawing.hindringW2W = {
  startWallIdx: null,
  startPt: null,
  endWallIdx: null,
  endPt: null,
  phase: 0,              // 0=ikke startet, 1=tegner polyline, 2=velg side
  pendingSplit: null,    // {polyA, polyB, polyline, room}
  hoverSide: null,       // 'A' | 'B' under fase 2
};
```

### Tegnflyt — tre faser

**Fase 0 → 1**: Bruker klikker på vegg. `startWallIdx` og `startPt` settes.
`phase = 1`. Cursor blir crosshair.

**Fase 1**: Bruker tegner polyline. Klikk legger til mellompunkt. Hint:
"Klikk på neste vegg for å avslutte, eller legg til mellompunkt."

**Fase 1 → 2**: Bruker klikker på annen vegg.
- `endWallIdx`, `endPt` settes
- Kall `splitRoomWithPolyline(room, polyline, startWallIdx, endWallIdx)`
- Valider at begge polygoner har areal > 100 cm² og er gyldige
- Lagre `pendingSplit = {polyA, polyB, polyline, room}`
- `phase = 2`
- Hint: "Trykk på området som skal være hindring."
- Cursor: pointer

**Fase 2**: Begge polygoner rendres med distinkt overlay (se Rendering).
Hover detection oppdaterer `hoverSide` til 'A' eller 'B'. Klikk:
- Konverter valgt polygon til en hindring
- `S.hindrings.push({id, type: hindringType, label, roomId: room.id, points: chosen})`
- Rommet selv endres ikke
- `exitDrawing()`, render, oppdater sidebar

### Rendering — fase 2 visuelle

```js
function _drawHindringW2WPhase2() {
  const hw = S.drawing.hindringW2W;
  if (!hw.pendingSplit) return;
  const { polyA, polyB } = hw.pendingSplit;

  // Begge polygoner med semi-transparent fyll
  // A: blå-grønn ("forblir rom"), B: oransje-rød ("blir hindring")
  // Men begge i NEUTRAL farge initielt — fargen byttes ved hover

  for (const [poly, side] of [[polyA, 'A'], [polyB, 'B']]) {
    const isHovered = hw.hoverSide === side;
    ctx.fillStyle = isHovered
      ? 'rgba(249, 115, 22, 0.35)'    // oransje på hover
      : 'rgba(148, 163, 184, 0.20)';  // nøytral grå
    ctx.strokeStyle = isHovered ? '#f97316' : '#94a3b8';
    ctx.lineWidth = isHovered ? 2 : 1;
    ctx.setLineDash(isHovered ? [] : [4, 3]);
    _fillStrokePolygon(poly);

    // Sentroide-label
    const c = _polyCentroid(poly);
    const sp = w2s(c.x, c.y);
    ctx.fillStyle = isHovered ? '#f97316' : '#64748b';
    ctx.font = isHovered ? "bold 14px sans-serif" : "12px sans-serif";
    ctx.textAlign = 'center';
    ctx.fillText(
      isHovered ? 'Klikk for hindring' : 'Klikk her',
      sp.x, sp.y
    );
  }
  ctx.setLineDash([]);
}
```

Kalles fra hovedrender etter `drawRooms()` når `drawMode === 'hindring-w2w'`
og `phase === 2`.

### Hover detection

I canvas mousemove (~linje 22388), legg til etter eksisterende drag-detection:

```js
if (S.ui.drawMode === 'hindring-w2w' && S.drawing.hindringW2W.phase === 2) {
  const hw = S.drawing.hindringW2W;
  const wp = getWorldPos(e);
  const inA = ptInPoly(wp.x, wp.y, hw.pendingSplit.polyA);
  const inB = ptInPoly(wp.x, wp.y, hw.pendingSplit.polyB);
  const newHover = inA ? 'A' : inB ? 'B' : null;
  if (newHover !== hw.hoverSide) {
    hw.hoverSide = newHover;
    canvas.style.cursor = newHover ? 'pointer' : 'default';
    markDirty();
  }
  return;
}
```

### Klikk-håndtering

I canvas mousedown for fase 2:

```js
if (S.ui.drawMode === 'hindring-w2w' && S.drawing.hindringW2W.phase === 2) {
  const hw = S.drawing.hindringW2W;
  const wp = getWorldPos(e);
  let chosen = null;
  if (ptInPoly(wp.x, wp.y, hw.pendingSplit.polyA)) chosen = hw.pendingSplit.polyA;
  else if (ptInPoly(wp.x, wp.y, hw.pendingSplit.polyB)) chosen = hw.pendingSplit.polyB;
  if (!chosen) return;

  pushUndo();
  const hType = HINDRING_TYPES.find(t => t.id === S.ui.hindringType) || HINDRING_TYPES[0];
  const customName = S.ui.hindringCustomName || '';
  S.hindrings.push({
    id: S.counters.nextHindringId++,
    type: S.ui.hindringType,
    label: customName || hType.name,
    roomId: hw.pendingSplit.room.id,
    points: chosen,
  });
  exitDrawing();
  renderSidebar(); markDirty();
  return;
}
```

### Hint-tekst

I `updHint()`, legg til cases for de tre fasene:
- Fase 0: "Klikk på en vegg for å starte hindringen."
- Fase 1: "Klikk på neste vegg for å avslutte, eller legg til mellompunkt."
- Fase 2: "Trykk på området som skal være hindring."

### Escape-håndtering

I keydown Escape-handler (~linje 23404), legg til:
```js
if (S.ui.drawMode === 'hindring-w2w') {
  S.drawing.hindringW2W = { startWallIdx:null, startPt:null, endWallIdx:null,
                            endPt:null, phase:0, pendingSplit:null, hoverSide:null };
  exitDrawing(); return;
}
```

I fase 2 bør Escape gå tilbake til fase 1 (la bruker tegne om polylinen),
ikke avbryte helt. Nice-to-have.

### Entry point — UI

I hindring-typen-velgeren (modal eller meny der bruker velger
"polygon" / "rektangel" i dag), legg til en tredje knapp:
"Vegg-til-vegg".

Klikk på den knappen: setter `S.ui.drawMode = 'hindring-w2w'`,
`S.drawing.hindringW2W` initialiseres til alle null, fase 0, vis hint.

## Edge cases

1. **Bruker klikker samme vegg som start og slutt** → varsel "Hindringen
   må gå mellom to forskjellige vegger." Behold drawMode, reset til fase 0.

2. **Polyline gir ugyldig split** (en polygon for liten, eller selvkryssende)
   → varsel "Ugyldig form. Prøv igjen." Reset til fase 0.

3. **Hindringen overlapper eksisterende hindring i rommet** → tillat, men
   marker med valideringsvarsel etterpå (`getHindringViolations` hvis den
   finnes, eller skipp for v1).

4. **Bruker klikker utenfor rommet under fase 1** → ignorer (krev klikk
   på en vegg).

5. **Skrå/kurvet polyline** — `splitRoomWithPolyline()` håndterer dette
   for skillevegg, så det fungerer her også.

## Akseptansekriterier

1. Ny knapp "Vegg-til-vegg" finnes i hindring-velgeren.
2. Klikk på knappen starter modus, hint vises.
3. Klikk på første vegg → fase 1, hint endres.
4. Klikk på mellompunkter → polyline forlenges, vises live.
5. Klikk på annen vegg → fase 2, begge regioner highlighted.
6. Hover over region → den lyser opp med oransje + "Klikk for hindring".
7. Klikk på region → hindring opprettes, modus avsluttes.
8. Rommet er uendret etter operasjonen (kun en ny hindring lagt til).
9. Hindringen kan deretter velges, flyttes, slettes som andre hindringer.
10. Escape avbryter modus i alle faser.

## Prompt for Claude Code

Les `docs/claude/hindring-wall-to-wall-spec.md` for full kontekst.

Implementer en ny "Vegg-til-vegg"-modus for hindring-tegning i
`romtegner.html`. Modusen lar bruker tegne en polyline fra vegg til vegg
som deler rommet i to deler — bruker klikker så på den delen som skal bli
en hindring.

Gjenbruk eksisterende `splitRoomWithPolyline()` (linje ~19865) som allerede
brukes av skillevegg-flowen. Forskjellen er at hindring-w2w ikke endrer
rommet — bare oppretter en hindring fra den valgte halvdelen.

### Hovedendringer i `romtegner.html`

1. Ny state-blokk `S.drawing.hindringW2W` (etter `S.drawing.skillevegg`).
2. Ny draw mode-verdi `'hindring-w2w'`.
3. Mousedown-håndtering for fase 0 (start på vegg), fase 1 (mellompunkter
   eller slutt på annen vegg), fase 2 (klikk på halvdel).
4. Mousemove-håndtering for hover-detection i fase 2.
5. Ny tegnefunksjon `_drawHindringW2WPhase2()` kalles fra `render()`.
6. `updHint()` får tre nye case for de tre fasene.
7. Escape i keydown håndterer alle tre faser (fase 2 → tilbake til fase 1
   er nice-to-have; minimal: avbryt helt).
8. Ny knapp "Vegg-til-vegg" i hindring-typen-velgeren (finn der "polygon"
   og "rektangel" defineres som valg).

### Visuelle detaljer

- Polyline under tegning: stiplet oransje, samme som skillevegg fase 1.
- Begge regioner i fase 2:
  - Default: lett grå fyll (`rgba(148,163,184,0.20)`), stiplet grå border.
  - Hover: oransje fyll (`rgba(249,115,22,0.35)`), heltrukket oransje border.
- Sentroide-label: "Klikk her" (default), "Klikk for hindring" (hover).
- Hint-tekst i `updHint()`: "Trykk på området som skal være hindring."

### Følg `CLAUDE.md`

Direkte på `main`, ingen nye filer, alle endringer i `romtegner.html`.
Test visuelt — særlig fase 2 med ulike romformer (rektangel, L-form,
polygon). Bruk det nye dirty-flag-systemet: kall `markDirty()` ved
state-endringer (allerede dekket av safety net i mousemove).
