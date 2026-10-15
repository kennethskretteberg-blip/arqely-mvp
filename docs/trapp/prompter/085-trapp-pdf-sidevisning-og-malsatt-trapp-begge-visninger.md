# 085 · Trapp: sidevisningen kommer med i PDF-en, og trappen målsettes i begge visninger (plan og side) — på skjerm og i utskrift

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Normal** · **Størrelse: middels**
**Kjøres på `main`**, etter 084. Linjenumre fra `3b07568` — symbolnavn er fasit.
Spec: `spec-trapp-kabelutlegg.md` Regel 17 (Cowork-mappa `spec/`); kommentarene i koden om `spec-trapp-utskrift-feil.md`/`spec-trapp-detaljutsnitt.md`.

---

## Kenneths ord

> «Trapp utendørs: jeg ønsker at sidevisning av trapp kommer med i eksport-PDF og at trappen er
> målsatt, begge visninger.»

Skjermbildet (Trapp 1, 8 trinn, 240 cm): planvisningen har kabelmål (12,5 kantavstand, 9,3 CC, 2,
«8,6 m (×8 trinn)»), sidevisningen «Side Trapp 1» har **ingen mål**.

## Hva som finnes

| | Hvor | I dag |
|---|---|---|
| Plan på skjerm | `_drawStairPlan` (:33763) + `_drawSurfDepthDims`/`_drawSurfWidthDims` | Kabelmål på ett trinn per kabel (kantavstand, CC, opptrinn/nese) |
| Side på skjerm | `_drawStairSide` (:34239) | Profil + kabelstrenger, **ingen mål** |
| PDF, trapp-side | `exportPDF` → `_renderStairPrintImages` (:64076) → `_stairDrawToCanvas` (:63671) | **Bare plan**, i bånd ved lange trapper. Kabelmål fra STEG 4 (:63934). Detaljutsnitt `_renderStairDetailInsets` (:64180). Ingen sidevisning |
| Trapp-tabell i PDF | `_stairSoneGeometryBlocks` (:37817) | Tall per sone |

Ingen av visningene målsetter selve **trappen**: total bredde/lengde/høyde, inntrinn, opptrinn,
repos.

## Gjør

### 1. Felles målsetting av trappens geometri

Én hjelpefunksjon som gir mållinjer i trappens egne cm, brukt av både skjerm og utskrift (så de aldri
blir uenige):

- `_stairGeometryDims(stair, view)` → liste av `{ a:{x,y}, b:{x,y}, label, side, level }`.
- **Plan** (`view:'plan'`):
  - Total bredde (per trinnserie hvis bredden varierer).
  - Total lengde i plan (sum dybder inkl. repos), som ytre målkjede langs siden.
  - Indre kjede: hvert inntrinn (dybde) og hvert repos. Like trinn på rad slås sammen: «8 × 30 = 240».
- **Side** (`view:'side'`):
  - Opptrinn (høyde) per trinn som kjede langs fremkanten; like slås sammen «8 × 17 = 136».
  - Inntrinn (dybde) som kjede langs bunnen; repos med egen lengde.
  - Total høyde og total lengde som ytre kjeder.
- Mållinjer i samme stil som rommenes målkjeder (grå/blå, piler/tikk, tall midt på), **utenfor**
  trappen. Kabelmålene fra i dag (kantavstand, CC) beholdes som de er, på innsiden.

### 2. Skjerm

- `_drawStairPlan` og `_drawStairSide` tegner `_stairGeometryDims` når trappen er valgt **eller** når
  målvisning er slått på (bruk samme bryter som rom-målkjedene — finn den i STEG 0).
- Ikke oppå kabelmålene: geometrimål på venstre/under, kabelmål til høyre/over som i dag.

### 3. PDF: sidevisning

- Ny `_stairDrawSideToCanvas(stair, opts)` — samme profil som `_drawStairSide`, tegnet off-screen
  (150 dpi-prinsippet fra `_stairDrawToCanvas`), med kabelstrenger, start/slutt-prikker og målene
  fra §1.
- `_renderStairPrintImages` returnerer i tillegg `{ kind:'side', … }`. I `exportPDF` plasseres
  sidevisningen **etter planen** med overskrift «Sidevisning» og før detaljutsnittene. Lang trapp:
  samme båndprinsipp som planen (`_stairSurfaceBands`), men i lengderetningen.
- Plan-bildet i PDF-en får geometrimålene fra §1 i tillegg til dagens kabelmål.
- Valg i eksportdialogen: under hver trapp (`.exp-stair-cb`) en underavkrysning «Sidevisning» (på som
  standard).

## STEG 0

1. Hvilken bryter styrer målkjeder på rom (`S.ui.showDims` el.l.)? Tegnes trappemål i dag bare når
   trappen er valgt?
2. Finnes `stepHeight_cm` på alle flater (også gamle trapper uten `segments`)? Fallback som i
   `_drawStairSide` (`stair.step_height_cm || 17`).
3. Ta et PDF-skjermbilde av Trapp 1 (duplisert kopi) før endring.

## Skal IKKE

- Endre kabelutlegget eller tabellen i `_stairSoneGeometryBlocks`.
- Fjerne dagens kabelmål eller detaljutsnitt.

## Test

1. Trapp 1 på skjerm, valgt: plan med bredde 240, «8 × inntrinn», total lengde; side med «8 ×
   opptrinn», total høyde/lengde. Tallene = det som står i trapp-byggeren.
2. Trapp med repos og ulik bredde: repos målt for seg, bredde per serie.
3. PDF: plan (med geometri- og kabelmål) → «Sidevisning» med mål → detaljutsnitt. Lang trapp (20+
   trinn): sidevisningen deles i bånd og er lesbar.
4. Avhuking «Sidevisning» av → ingen sidevisning, resten uendret.
5. Innendørs trapp / prosjekt uten trapper: PDF uendret.
6. Mål kolliderer ikke med kabelmålene eller «↓ Nederste trinn».

## Rapport

STEG 0.1–0.3, før/etter-skjermbilde av skjerm og PDF-side. Endringslogg. Commit: «085: trapp —
sidevisning i PDF, trappen målsatt i plan og side (inntrinn, opptrinn, repos, totaler) på skjerm og i
utskrift».
