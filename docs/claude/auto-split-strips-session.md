# Auto-split varmefolie rundt hindringer

Sist oppdatert: 2026-05-16
Status: Bug analysert, prompt klar for Claude Code. Ikke implementert.

---

## Brukerproblem

Kenneth kan ikke plassere varmefolie på venstre side av en hindring når han
allerede har strips på høyre side. Han ønsker at systemet skal automatisk
splitte en strip-bredde rundt hindringer — slik at én plasseringsoperasjon
resulterer i N strips som hver kan velges, flyttes, strekkes eller slettes
uavhengig.

Konkret scenario (fra skjermbilde): Rom med to vertikale hindringer i midten.
2 stk 100cm bredder ligger til høyre. Bruker vil ha 2 stk 100cm bredder til
venstre, og forventer at hver kolonne automatisk deles i 3 segmenter (over,
mellom, under hindringene).

## Analyse av kodebasen

### Den gode nyheten
Infrastrukturen finnes allerede. `computeClippedSegments()` på linje 20874
returnerer N segmenter per strip-posisjon, og håndterer både vegger,
hindringer (`clipStripAroundHindrings`) og forbudte soner (`_clipStripAroundZones`).

### Stier som fungerer korrekt
Disse pusher allerede én strip per segment:

| Sted | Linje | Bruker |
|------|-------|--------|
| Auto-fill forward | ~3175 | `for (const seg of segments) S.strips.push(...)` |
| Auto-fill backward | ~3194 | samme mønster |
| Drag-fra-palett | ~10653 | samme mønster |

### Bug-en
`doSemiAutoStep()` på linje ~10398 (halvautomatisk placement) bruker IKKE
`computeClippedSegments()`. Den pusher én strip med full romlengde:

```js
S.strips.push({
  ...
  pos_cm: cursor,
  start_cm: baseAlong + MARGIN,
  length_cm: along - 2 * MARGIN   // ← full romlengde, ignorerer hindringer
});
```

Dette er årsaken til at Kenneth ikke får plassert folie der hindringer er i veien.

## Foreslått løsning

### Steg 1 — Delt helper

```js
/**
 * Place strip(s) at a position, automatically splitting around hindringer/zones.
 * Returns array of created strip objects.
 */
function _pushStripsAtPos(roomId, productId, direction, pos_cm) {
  const segments = computeClippedSegments(roomId, direction, pos_cm, productId);
  const created = [];
  for (const seg of segments) {
    const strip = {
      id: S.counters.nextStripId++,
      roomId, productId, direction,
      pos_cm, start_cm: seg.start_cm, length_cm: seg.length_cm
    };
    S.strips.push(strip);
    created.push(strip);
  }
  if (created.length > 0) _invalidateStripCache();
  return created;
}
```

### Steg 2 — Refaktorer alle placement-stier

- `doSemiAutoStep()` (linje ~10398): bytt de to `S.strips.push(...)` i while-loopene
  med `_pushStripsAtPos()`. Behold cursor-fremrykning.
- Auto-fill forward/backward (~3175, ~3194): bytt for-loopen med helperen.
- Drag-fra-palett (~10653): bytt for-loopen med helperen.

### Edge cases
- Segmenter < `MIN_LEN` (5cm) eller < `cut_interval` (20cm) filtreres bort
  i `computeClippedSegments()` allerede.
- Hvis posisjon er helt blokkert: helperen returnerer `[]`. Semi-auto bør
  hoppe over posisjonen.

## Hva som ikke er bestemt

**Re-split ved drag av eksisterende strip:** Hvis bruker drar en strip til
en posisjon som krysser en hindring, skal den re-splittes? Mer kontroversielt
— kan være overraskende. Foreslår: ikke re-split på drag (la `_clampStripToRoom`
håndtere det som før). Re-split skjer kun ved nyplassering.

## Prompt for Claude Code

Sett opp helper, refaktorer alle 4 placement-stier, test manuelt mot
bruksscenarioet. Detaljert prompt med eksakt kode er allerede levert i chat.
