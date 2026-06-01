# Tilbehør-modul for varmefolie

Sist oppdatert: 2026-05-16
Status: Arkitektur og prompt klar for Claude Code. Ikke implementert.

---

## Bakgrunn

Materiallisten skal inkludere tilbehør som hører til varmefolie-installasjon.
Mengder beregnes automatisk basert på prosjektdata, men bruker skal kunne
overstyre og velge manuelt i en modal før eksport.

## Kravsamling fra Kenneth

### Auto-beregnet
- **Tilkoblingsklemmer**: 2 stk per varmefolie (per strip)
- **Lerretstape**: 1 rull per 20 m² varmefolie
- **Vulk tape**: 1 rull per 24 varmefolie-bredder (strips)
- **Kapton disc**: samme antall som tilkoblingsklemmer (= 2 per strip)
- **Underlagsplater**: dekker hele brutto rom-areal (selv der det ikke er folie)
  - 1 plate = 60×120 cm = 0,72 m²
  - +10 % for kapp/svinn
  - Rundes opp til hele 10 stk
- **Byggplast over varmefolie**: påbud, default checked. 1 rull = 39 m²
- **Byggplast under varmefolie**: valgfri (samme formel som over)

### Kun manuell inntasting
- **Dobbeltsidig tape**
- **RKK 1,5mm / 2,5mm** (blå og sort): selges kun som hele 50m-ruller, må
  alltid ha både blå og sort av valgt dimensjon, de fleste velger 1,5mm.
  Kunden har enten på lager eller må kjøpe hele ruller.

### UX
- Modal vises kun ved eksport-handling (PDF eller Excel)
- Sjekkbokser for auto-foreslåtte varer
- Override-felter ved siden av auto-foreslått antall
- Egen seksjon for RKK med radio for dimensjon
- Siste valg huskes i localStorage

## Arkitektur-prinsipper

1. **Tilbehør som data, ikke kode.** En `FOIL_ACCESSORIES`-konstant beskriver
   hver vare deklarativt. Nye varer = endre data, ikke logikk.
2. **Skille auto vs manuell.** To grupper i modalen.
3. **RKK som spesialtilfelle** med egen UI-seksjon.
4. **Kontekst-objekt** for beregninger (`stripCount`, `totalFoilArea_m2`,
   `roomGrossArea_m2`, `stripWidthCount`).
5. **Modal kun ved eksport.** Ingen state-forurensing i `S` mellom eksporter.
6. **Plast under/over som separate poster** i stedet for "dobling" —
   tydeligere både i UI og materialliste.

## Prompt for Claude Code

Implementer tilbehør-modul for varmefolie i materiallisten i `romtegner.html`.
Tilbehør beregnes automatisk basert på prosjektdata, vises i en modal før
eksport, og inkluderes i både PDF-materialliste og Excel-eksport.

### 1. Tilbehør-katalog (konstant)

Definer en const `FOIL_ACCESSORIES` i nærheten av `HEATING_PRODUCTS`-håndteringen.

```js
const FOIL_ACCESSORIES = [
  {
    id: 'tilkoblingsklemmer',
    name: 'Tilkoblingsklemmer',
    art_no: '',          // tom, fylles inn av Kenneth senere
    el_no: '',
    unit: 'stk',
    group: 'auto',       // 'auto' | 'manual' | 'rkk'
    defaultEnabled: true,
    calc: (ctx) => ctx.stripCount * 2,
    overheadPct: 0,
    roundTo: 1,
  },
  {
    id: 'kapton_disc',
    name: 'Kapton disc',
    unit: 'stk',
    group: 'auto',
    defaultEnabled: true,
    calc: (ctx) => ctx.stripCount * 2,
    overheadPct: 0,
    roundTo: 1,
  },
  {
    id: 'lerretstape',
    name: 'Lerretstape',
    unit: 'rull',
    group: 'auto',
    defaultEnabled: true,
    calc: (ctx) => Math.ceil(ctx.totalFoilArea_m2 / 20),
    overheadPct: 0,
    roundTo: 1,
  },
  {
    id: 'vulk_tape',
    name: 'Vulk tape',
    unit: 'rull',
    group: 'auto',
    defaultEnabled: true,
    calc: (ctx) => Math.ceil(ctx.stripWidthCount / 24),
    overheadPct: 0,
    roundTo: 1,
  },
  {
    id: 'underlagsplater',
    name: 'Underlagsplater 60×120cm',
    unit: 'stk',
    group: 'auto',
    defaultEnabled: true,
    calc: (ctx) => ctx.roomGrossArea_m2 / 0.72,
    overheadPct: 10,       // +10% kapp/svinn
    roundTo: 10,           // rundes opp til hele 10
  },
  {
    id: 'plast_over',
    name: 'Byggplast over varmefolie',
    unit: 'rull',
    group: 'auto',
    defaultEnabled: true,    // påbud
    calc: (ctx) => Math.ceil(ctx.totalFoilArea_m2 / 39),
    overheadPct: 0,
    roundTo: 1,
  },
  {
    id: 'plast_under',
    name: 'Byggplast under varmefolie',
    unit: 'rull',
    group: 'auto',
    defaultEnabled: false,   // valgfri
    calc: (ctx) => Math.ceil(ctx.totalFoilArea_m2 / 39),
    overheadPct: 0,
    roundTo: 1,
  },
  {
    id: 'dobbeltsidig_tape',
    name: 'Dobbeltsidig tape',
    unit: 'rull',
    group: 'manual',
    defaultEnabled: false,
    calc: () => 0,
    overheadPct: 0,
    roundTo: 1,
  },
];

const RKK_PRODUCTS = [
  { id: 'rkk_15_bla',  name: 'RKK 1,5mm blå',  dim: '1.5', color: 'blå',  unit: 'rull 50m' },
  { id: 'rkk_15_sort', name: 'RKK 1,5mm sort', dim: '1.5', color: 'sort', unit: 'rull 50m' },
  { id: 'rkk_25_bla',  name: 'RKK 2,5mm blå',  dim: '2.5', color: 'blå',  unit: 'rull 50m' },
  { id: 'rkk_25_sort', name: 'RKK 2,5mm sort', dim: '2.5', color: 'sort', unit: 'rull 50m' },
];
```

### 2. Beregnings-kontekst

```js
function _computeFoilContext() {
  const foilStrips = S.strips.filter(s => {
    const p = HEATING_PRODUCTS.find(pp => pp.id === s.productId);
    return p && p.module_type === 'foil';
  });
  const stripCount = foilStrips.length;
  let totalFoilArea_m2 = 0;
  for (const s of foilStrips) {
    const p = HEATING_PRODUCTS.find(pp => pp.id === s.productId);
    if (!p) continue;
    const widthCm = (p.netto_width_mm || p.width_mm) / 10;
    totalFoilArea_m2 += (s.length_cm * widthCm) / 10000;
  }
  // Brutto rom-areal: sum av areal for rom som har minst én folie-strip
  const roomsWithFoil = new Set(foilStrips.map(s => s.roomId));
  let roomGrossArea_m2 = 0;
  for (const rid of roomsWithFoil) {
    const r = S.rooms.find(rr => rr.id === rid);
    if (r) roomGrossArea_m2 += (r.area || 0) / 10000; // area er i cm²
  }
  return {
    stripCount,
    stripWidthCount: stripCount,   // 1 bredde = 1 strip
    totalFoilArea_m2,
    roomGrossArea_m2,
  };
}

function _applyAccessoryCalc(acc, ctx) {
  let qty = acc.calc(ctx);
  if (acc.overheadPct) qty = qty * (1 + acc.overheadPct / 100);
  qty = Math.ceil(qty);
  if (acc.roundTo > 1) qty = Math.ceil(qty / acc.roundTo) * acc.roundTo;
  return qty;
}
```

### 3. Modal

Modal med id `modal-accessories`, vises ved `showAccessoriesModal(onConfirm)`.

Layout:
- **Auto-foreslått** (seksjon)
  - Per vare: `[✓] Navn ............ [auto-qty] [override-felt] enhet`
  - Override-feltet er tomt initielt med placeholder "auto: 12".
    Hvis bruker skriver tall, overstyrer det.
- **Manuell inntasting** (seksjon)
  - Per vare: `[✓] Navn ........... [tomt-felt] enhet`
- **RKK** (egen seksjon)
  - Radio: `(•) 1,5mm   ( ) 2,5mm`
  - `Blå:  [____] rull · Sort: [____] rull`
  - Hjelpetekst: "Selges kun som hele 50m-ruller. Begge farger må kjøpes
    hvis ikke på lager. La stå tomt hvis kunden har RKK på lager."
- Knapper: `[Avbryt]` `[Generer rapport →]`

Lagre siste valg i `localStorage['varmeplan_accessories_v1']` (kun
checkbox-states og RKK-dim, ikke qty-overrides — de bør være tomme hver gang).

### 4. Returverdi fra modal

```js
{
  items: [
    { id, name, art_no, el_no, unit, qty, source: 'auto' | 'manual' | 'rkk' },
    ...
  ]
}
```

Bare varer med `qty > 0` og `enabled === true` inkluderes.

### 5. Integrasjon med eksport

#### PDF (`exportPDF()`, linje ~25268)
Etter materialliste-seksjonen: ny underseksjon "Tilbehør" som rendres som
tabell med kolonner: Navn, Antall, Enhet, Art.nr (tom hvis ikke satt).

#### Excel (`exportMaterialliste()`, linje ~28806)
Legg til en `Tilbehør`-blokk på `Materialliste`-arket etter de eksisterende
modultype-blokkene. Når 3-arks Excel er implementert per `print-design-spec.md`:
tilbehør inn som egne rader på `Bestilling`-arket også, med aggregering på `id`.

#### Flow
Begge eksport-funksjonene må kalle `showAccessoriesModal()` først:

```js
async function exportPDF(opts) {
  const accessories = await showAccessoriesModal();
  if (!accessories) return;   // bruker avbrøt
  // ... rest
}
```

## Akseptansekriterier

1. Etter klikk på "Eksporter PDF" eller "Eksporter Excel", åpnes
   accessories-modal.
2. Auto-foreslåtte verdier er korrekt beregnet basert på faktisk folie-data.
3. Bruker kan overstyre hver auto-verdi med eget tall.
4. Bruker kan krysse av/på hver linje.
5. RKK-seksjonen tillater å velge dimensjon og antall per farge, eller la
   stå tomt.
6. Siste valg (checkbox-states og RKK-dim) huskes mellom eksporter.
7. Eksporterte filer inkluderer en `Tilbehør`-seksjon i materiallisten.
8. Hvis prosjektet ikke har varmefolie, vises modalen fortsatt, men
   auto-verdier er 0 og seksjonene kan være tomme.

## Edge cases

- Kun kabel/matte i prosjekt: modal vises fortsatt, tilbyr RKK + manuelle.
- Rom med folie og hindringer: brutto rom-areal er totalt rom-areal (ikke
  trukket fra hindringer — Kenneth presiserte "for hele brutto arealet").
- `roundTo: 10` for underlagsplater: 23 → 30, 30 → 30, 31 → 40.

## Filer endret

`romtegner.html` — alle endringer (single-file arkitektur):
- Ny `FOIL_ACCESSORIES`-konstant
- Ny `RKK_PRODUCTS`-konstant
- Ny `_computeFoilContext()` helper
- Ny `_applyAccessoryCalc()` helper
- Ny `showAccessoriesModal()` (HTML + JS)
- Ny `#modal-accessories` HTML-element
- Integrasjon i `exportPDF()` og `exportMaterialliste()`

## Følger Cenika-konvensjon, men er bevisst nøytralt

Konstantene har tomme `art_no`-felt. Kenneth fyller inn egne artikkelnumre
senere. Produktnavnene er generiske ("Kapton disc", "Vulk tape") — ingen
leverandørbinding i koden.

## Fremtidige utvidelser

- Tilsvarende tilbehør-katalog for varmekabel (`CABLE_ACCESSORIES`):
  termostater, følerrør, kald-/endeskjøt-tape, jordfeilbryter
- Tilsvarende for matte og plate
- Migrasjon til Supabase-tabell `accessories` med samme skjema når katalogen
  vokser
