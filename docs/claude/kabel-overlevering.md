# Overlevering — Varmekabel-layout (til Claude Cowork)

> Skrevet av Claude Code etter en feilsøkingsøkt på varmekabel-auto-fill i `romtegner.html`.
> Formål: gi deg full kontekst så du ikke må re-diagnostisere fra bunnen.
> Brukeren (Kenneth) er fortsatt **ikke fornøyd** med kabelkvaliteten på uregelmessige rom og rom med hindringer, selv etter fiksen beskrevet under.

---

## TL;DR

- Kabel-auto-fill kjører **5 motorer i kaskade** i `autoFillCable()`. V6 er primær og vinner nesten alltid → V5/V4 er **ikke** trygt å slette (i motsetning til hva `forbedringsplan-arqely.md` antok).
- Jeg fant og fikset én konkret bug (commit `2a901a4`): V6 valgte kabelretning *per celle*, men datamodellen støtter kun **én retning per kabel** → runs ble tegnet utenfor rommet («bare en strek») eller ujevnt rundt hindringer.
- **Den dypere flaskehalsen står igjen:** at en kabel kun har én `direction` begrenser hvor godt uregelmessige rom kan dekkes. En virkelig god løsning trenger sannsynligvis per-celle/per-run-retning gjennom hele kjeden — eller en helt annen layout-strategi.

---

## Arkitektur — slik henger det sammen

### Datamodell (viktigst å forstå)
En kabel lagres i `S.cables` som:
```
{
  id, roomId, productId,
  direction,        // 'v' eller 'h' — ÉN verdi for hele kabelen
  spacing_cm,       // CC (senter-til-senter)
  startCorner,      // 'bl'|'br'|'tl'|'tr'
  runs: [ { pos_cm, segments: [ {start_cm, end_cm}, ... ] } ],
  totalLength_cm, cells, connections
}
```
- For `direction='v'`: `pos_cm` er en **X**-koordinat, `segments` spenner i **Y**.
- For `direction='h'`: motsatt (`pos_cm`=Y, `segments`=X).
- `drawCables()` (~linje 11137, kjernelinje 11182–11188) tolker **alle** runs med kabelens ene `direction`. Det finnes ingen per-run-retning.

### Motorkaskade — `autoFillCable(roomId, productId)` (~linje 9254)
Rekkefølge, hver med `return` ved første ikke-tomme resultat:
1. **Serpentine-forarbeid** (`generateCableSerpentine`) — brukes egentlig bare til å velge `bestDir` + i aller siste fallback.
2. **V6** (`generateCableV6`, ~8779) — primær. Vinner ~alltid.
3. **V5** (`generateCablePolygonV5`)
4. **V4** (`generateCablePolygonAware`)
5. **Length-driven** (`generateCableLayoutLengthDriven`) — for produkter med fast `cable_length_m`.
6. **Serpentine-fallback** (siste return).

Fordi V6 nesten alltid lykkes, kortslutter den kaskaden — V4/V5 kjøres sjelden. De er **latent** kode, ikke død kode: fjerner du dem mister du fallback for tilfellene V6 *ikke* klarer.

### V6-pipeline (`generateCableV6`, ~8779)
```
_v6BuildHeatableArea   (7866) → scanline-kart, trekker fra hindringer + forbudte soner
_v6AnalyzeTopology     (7961) → finner nakker/bredde-overganger/split-kandidater
_v6DecomposeCells      (8034) → deler heatable area i sveipbare celler
_v6SweepCell           (8160) → genererer serpentin-runs per celle   ← buggen var her
_v6ValidateCellCoverage(8246) → Stage 5: finner udekte lommer, prøver recovery
_v6ConnectCells        (8349) → kobler celler til én sammenhengende bane
_v6OptimizeLength      (8459) → binærsøk på CC for å treffe produktlengde
```

---

## Buggen jeg fikset (commit `2a901a4`)

**Symptom (brukerens skjermbilder):**
- Rom med mange vinkler → kabel tegnes som «bare en strek».
- Rom med hindring (kjøkken) → kabel fyller seg ujevnt.

**Rotårsak:** `_v6SweepCell` valgte retning *per celle* (primær vs. ortogonal, den med best score):
```js
const primary = _tryDir(ha.direction);
const ortho   = _tryDir(ha.direction === 'v' ? 'h' : 'v');
return primary._score >= ortho._score ? primary : ortho;   // ← kunne returnere ortho
```
En celle som valgte ortogonal retning produserte runs med X/Y byttet om relativt til kabelens ene `direction`. `_v6ConnectCells` slår alle cellers runs sammen til én flat liste uten å ta vare på retning, og `drawCables()` tegner alt med den ene retningen → runs havner utenfor rommet / kollapser til en strek. Samme mekanisme rammer hindring-rom via Stage 5 (`_v6ValidateCellCoverage` sveiper lommer ortogonalt og pusher dem inn i samme liste, ~linje 8839).

**Fiks:** `_v6SweepCell` sveiper nå **kun** `ha.direction`. Global retning velges fortsatt øverst i `generateCableV6` via `_quickTry('v')` vs `_quickTry('h')`. Stage 5 går gjennom samme funksjon og fikses automatisk.

**Verifisert:** L-form (multi-celle) + rektangel med hindring, begge retninger → 0 runs utenfor rommet (var ikke-null før). Se reproduksjons-harness nederst.

---

## Hva som FORTSATT ikke er bra (den egentlige oppgaven)

Brukeren er ikke fornøyd selv etter fiksen. Mistanker / hypoteser å undersøke:

1. **Én-retning-begrensningen er fundamental.** Når et L/T-rom egentlig burde ha kabel i to ulike retninger i to deler, kan dagens modell ikke uttrykke det. Fiksen tvinger én retning → noen lommer forblir udekket. Det er «riktig» ift. dagens modell, men kan se dårlig ut. Vurder per-celle-retning gjennom hele kjeden (connect + drawCables + U-svinger i `_drawCableUTurns` + hit-testing), eller å splitte i flere kabelobjekter per rom.
2. **Lengde-likhet (equalization) vs. dekning.** LOCKED-regelen krever at alle runs er like lange → for uregelmessige rom klippes runs til felles overlapp, som ofrer dekning. Sjekk om dette er for aggressivt i praksis.
3. **`_v6DecomposeCells`-heuristikkene** (split-terskler på 0.30 bredde-endring, 0.20 osv.) kan dele rom på uheldige steder. Verdt å visualisere cellene.
4. **Connection-baner mellom celler** (`_v6ConnectCells`) er forenklet (rett linje + ev. ett veggpunkt). Kan gi stygge/urealistiske hopp.

---

## LOCKED-regler — MÅ respekteres (fra `docs/claude/CLAUDE.md`)

- **U-svinger:** alltid halvsirkler, radius = CC/2. Lengde = π × (CC/2). Aldri hårnål/ellipse.
- **sweepMargin = margin + CC/2** (margin fra produktregler + U-sving-radius). Aldri bend-radius.
- **Lik banelengde (equalization) er obligatorisk** — forhindrer Y-splits. For uregelmessige rom betyr det at noen områder ikke dekkes — det er akseptert.
- **Ingen Y-splits / forgreninger.** Kabel har nøyaktig én start og én slutt. Forlengelseslinjer mellom runs av ulik høyde ER Y-splits og er forbudt.
- **W/m² synk med romtype.** Velger bruker romtype, skal Flateeffekt-feltet oppdateres og produktforslag rekalkuleres. Prioritet: bruker > org > global.
- **Innvendige mål:** `room.points` = innvendig boundary. Veggtykkelse går utover, aldri innover. `_calcNetArea` trekker kun fra hindringer, aldri veggtykkelse.

---

## Reproduksjon / verifisering (uten å laste et ekte prosjekt)

Preview-serveren (`romtegner`, port 4000) sliter med å laste ekte prosjekter pga. RLS i dev-innlogging, men produktkatalogen lastes fint. Slik testet jeg fiksen — kjør i nettleserkonsollen (eller via preview `eval`) på en innlogget `localhost:4000/?dev`-side:

```js
// Krever at HEATING_PRODUCTS er lastet (await _loadProducts() hvis 0).
// PID 50 = "InFloor 10T 1200W 120m" (ekte innendørs gulvkabel).
const PID = 50;
const _r=S.rooms,_h=S.hindrings,_z=S.zones;
const mk=(id,pts)=>({id,name:'T'+id,points:pts.map(([x,y])=>({x,y})),floorId:null});
const roomA=mk(90001,[[0,0],[500,0],[500,300],[250,300],[250,500],[0,500]]); // L-form
const roomB=mk(90002,[[0,0],[400,0],[400,300],[0,300]]);                      // rektangel
const obsB={id:990001,roomId:90002,points:[{x:150,y:100},{x:250,y:100},{x:250,y:200},{x:150,y:200}]};
S.rooms=[roomA,roomB]; S.hindrings=[obsB]; S.zones=[];
function chk(room,dir){
  const res=generateCableV6(room.id,PID,dir,'bl'); if(!res||!res.runs)return{dir,err:1};
  const xs=room.points.map(p=>p.x),ys=room.points.map(p=>p.y);
  const bb={minX:Math.min(...xs),maxX:Math.max(...xs),minY:Math.min(...ys),maxY:Math.max(...ys)};
  const pl=dir==='v'?bb.minX:bb.minY,ph=dir==='v'?bb.maxX:bb.maxY,sl=dir==='v'?bb.minY:bb.minX,sh=dir==='v'?bb.maxY:bb.maxX;
  let bad=0; for(const r of res.runs){ if(r.pos_cm<pl-5||r.pos_cm>ph+5)bad++; for(const s of r.segments){ if(s.start_cm<sl-5||s.end_cm>sh+5)bad++; } }
  return {dir,runs:res.runs.length,cells:res.cells?res.cells.length:1,utenfor:bad};
}
console.log(JSON.stringify({A:{v:chk(roomA,'v'),h:chk(roomA,'h')},B:{v:chk(roomB,'v'),h:chk(roomB,'h')}}));
S.rooms=_r;S.hindrings=_h;S.zones=_z;
// Forventet etter fiks: utenfor=0 i alle fire tilfeller.
```

For visuell test: tegn `res.runs` på et eget canvas med samme tolkning som `drawCables` (`dir==='v' ? w2s(pos_cm, seg) : w2s(seg, pos_cm)`).

---

## Filer / referansepunkter
- Hele appen: `romtegner.html` (single-file, ~32k linjer, ingen build).
- Kabel-auto-fill: `autoFillCable()` ~9254.
- V6: `generateCableV6` ~8779 + `_v6*`-hjelpere 7866–8459.
- Tegning: `drawCables()` ~11137, `_drawCableUTurns()`.
- Arkitektur-oversikt: `docs/claude/architecture-review.md` (oppdatert commit `91f46c5`).
- Forbedringsplan (med utdatert antakelse om at V4/V5 er død kode): `forbedringsplan-arqely.md`.
