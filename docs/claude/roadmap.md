# Arqely Romtegner — Prioritert Utviklingsplan

Sist oppdatert: 2026-03-11

## Visjon
Arqely skal bli den ledende webappen for design av elektriske varmesystemer.
Støtte for varmefolie, varmekabel, varmematter og platesystemer med kabelspor.
Brukt av elektrikere og varme-rådgivere i hele Norden.

---

## FASE 1: Fundament (gjør eksisterende system robust)
> Mål: Rydde teknisk gjeld og legge grunnlag for flere produkttyper.

### 1.1 Kutte-intervall i layout-motor ✅
- **Hva:** `cut_interval_mm` finnes i produktdata men brukes ikke
- **Hvorfor:** Strips har vilkårlige lengder som ikke matcher fysiske kuttepunkter → gir avfall
- **Hvordan:** Avrund strip-lengder i `computeClippedSegments()` med `Math.floor(length / cutInterval) * cutInterval`
- **Fullført:** 2026-03-09

### 1.2 Romindeksert strip-oppslag ✅
- **Hva:** `S.strips.filter(s => s.roomId === ...)` kalles ~30 steder, O(n) per kall
- **Hvorfor:** Under drag kalles dette mange ganger per frame → tregt med 100+ strips
- **Hvordan:** Versjonert lazy cache `_stripsForRoom()` / `_stripsForRoomDir()`, ~20 steder erstattet
- **Fullført:** 2026-03-09

### 1.3 Dirty-flag rendering ✅ → ⚠️ Delvis tilbakestilt
- **Hva:** `render()` kalles på hver mousemove, selv uten endringer
- **Infrastruktur:** `_needsRender` flag + `markDirty()` finnes, men rAF-loop er tilbake til ubetinget
- **Hvorfor tilbakestilt:** ~12 mousemove-handlers (pan, drag, vertex, hindrings, strips) kaller ikke `render()` — de baserte seg på ubetinget rAF-loop. Dirty-flag brøt alle drag-operasjoner.
- **Fremtidig:** Må legge til `render()` eller `markDirty()` i alle ~12 handlers før dirty-flag kan aktiveres igjen

### 1.4 Generalisert produkt-type-system i Supabase ✅
- **Hva:** Utvide `product_categories` med type-felt (folie/kabel/matte/plate)
- **Hvorfor:** Grunnlag for alle fremtidige produkttyper
- **Hvordan:** `module_type ENUM('foil','cable','mat','plate')` + client-side helpers
- **Fullført:** 2026-03-09

---

## FASE 2: Layout-forbedringer (smartere varmefolie)
> Mål: Gjøre varmefolie-modulen profesjonell og ferdig.

### 2.1 Symmetrisk layout ✅
- **Hva:** Auto-fill plasserer strips sentrert med lik kaldsone på begge sider
- **Hvorfor:** Installatører foretrekker visuelt symmetriske layouts
- **Hvordan:** `_centerStripDefs()` beregner shift for lik kaldsone begge sider
- **Fullført:** 2026-03-09

### 2.2 Automatisk retningsdeteksjon ✅
- **Hva:** Systemet foreslår optimal folie-retning basert på romgeometri
- **Hvorfor:** Brukeren slipper å gjette — systemet velger mest effektiv retning
- **Hvordan:** `_suggestDirection()` sammenligner bounding box dimensjoner
- **Fullført:** 2026-03-09

### 2.3 Seed-basert layout ✅
- **Hva:** Bruker klikker et punkt, layout vokser utover fra det punktet
- **Hvorfor:** Rask manuell kontroll over startposisjon
- **Hvordan:** `_autoFillFromSeed()` + `seedFillRoom()` med bidireksjonal fill
- **Fullført:** 2026-03-09

### 2.4 Breddeoptimalisering (beam search) ✅
- **Hva:** Velg optimal kombinasjon av foliebredder for minimalt avfall
- **Hvorfor:** Grådige valg (widest-first) gir ikke alltid best resultat
- **Hvordan:** `_beamSearchFill()` med top-5 kandidater, integrert i `autoFillRoom()`
- **Fullført:** 2026-03-09

---

## FASE 3: Varmekabel-modul ✅
> Mål: Legge til varmekabel som nytt produkttype.
> **Fullført:** 2026-03-10

### 3.1 Kabel-datamodell ✅
- `S.cables[]` med `{ id, roomId, productId, direction, spacing_cm, startCorner, runs, totalLength_cm }`
- Supabase: InFloor 17T og 10T serier med `cable_length_m`, `min_spacing_mm`, `max_spacing_mm`
- **Fullført:** 2026-03-09

### 3.2 Kabel-layout-motor ✅
- **Sentrert serpentin:** `generateCableSerpentine()` med deterministisk N-beregning og symmetrisk sentrering
- **PCA retningsdeteksjon:** `_suggestDirection()` med area-weighted second moments (Ixx/Iyy)
- **CC-optimalisering:** `_adjustSpacingForLength()` med direkte N-iterasjon + binærsøk finjustering
- **Auto corner:** `autoFillCable()` prøver alle 4 hjørner × 2 retninger, scorer best
- **Polygon-inset:** `_offsetPolygon()` gjenbrukbar utility
- **Fullført:** 2026-03-10

### 3.3 Kabel-rendering ✅
- Serpentin-baner som røde linjer med U-svinger (semicircle arcs)
- Cross-product basert bueretning (alltid mot vegg)
- `_uTurnIsHigh()` for korrekt alternering alle 4 hjørner
- Visuell randsone (`_drawCableMarginZone()`) langs alle vegger
- Start/slutt-markører, produkt-label, selection highlight
- **Fullført:** 2026-03-10

### 3.4 Kabel-validering ✅
- `getCableViolations()` sjekker CC-grenser, avlesingsregel (soft warning), veggmargin
- Avlesingsregel (CC ≤ 3× screed) er soft warning, ikke hard limit
- **Fullført:** 2026-03-10

---

## FASE 4: Varmematte-modul ✅
> Mål: Legge til varmematter som nytt produkttype.
> **Fullført:** 2026-03-10

### 4.1 Matte-datamodell ✅
- `S.mats[]` med `{ id, roomId, productId, x_cm, y_cm, width_cm, length_cm, rotation_deg }`
- Test-produkter: TestMatte 50cm (500mm, 100 W/m²) og TestMatte 80cm (800mm, 150 W/m²)
- Produktfelt: `mat_width_mm`, `mat_min_length_mm`, `mat_max_length_mm`, `mat_length_step_mm`, `watt_per_m2`
- Save/restore, undo, versjonert cache (`_matsForRoom()`)
- **Fullført:** 2026-03-10

### 4.2 Matte-layout og interaksjon ✅
- **Plassering:** Produktmeny → velg matte + lengde → klikk i rom → matte sentrert på klikkpunkt
- **Rendering:** Rotert rektangel med blå fyll, mesh-linjer, produkt-label, dimensjoner
- **Drag & drop:** Fri/X/Y-akse drag med grid-snap og rom-clamping via gizmo-system
- **Rotasjon:** Rotasjonshåndtak (↻) med 45°-snap + ctxbar 90°-knapp
- **Hit detection:** Invers rotasjons-transform for korrekt AABB-sjekk i matte-lokale koordinater
- **UI-integrasjon:** Ctxbar (produkt, dimensjoner, effekt, ↻, 🗑), ObjInfo-panel, sidebar (🟫-ikon), romstatistikk
- **Seleksjon:** Følger hindring-mønster med gjensidig utelukkende seleksjon (mat/cable/strip/zone)
- **Fullført:** 2026-03-10

---

## FASE 5: Platesystem med kabelspor ✅
> Mål: Støtte platesystemer (f.eks. Uponor, Devi) med prefabrikkerte kabelspor.
> **Fullført:** 2026-03-11

### 5.1 Platesystem-datamodell ✅
- `S.plates[]` med `{ id, roomId, productId, x_cm, y_cm, width_cm, length_cm, direction }`
- Test-produkter: TestPlate 60×120cm (60 W/m²) og TestPlate 60×60cm (100 W/m²)
- Save/restore, undo, versjonert cache (`_platesForRoom()`)
- **Fullført:** 2026-03-11

### 5.2 Platesystem-layout ✅
- **Auto-fill:** `_autoFillPlates()` — grid-basert plassering, prøver begge orienteringer, sentrerer
- **Manuell plassering:** Klikk i rom → plate sentrert på klikkpunkt
- **Drag & drop:** X/Y-akse drag med grid-snap og rom-clamping via gizmo
- **Rendering:** Varm brun/gull-farger, groove-linjer (kabelspor) med U-turn arcs
- **UI:** Ctxbar, sidebar, romstatistikk, Delete-tast, Escape
- **Fullført:** 2026-03-11

---

## FASE 6: Avanserte funksjoner
> Mål: Profesjonelle verktøy for optimal design.

### 6.1 Brukerpreferanser (localStorage) ✅
- Tema, snap-innstillinger, gap, strip-labels lagres i localStorage
- `_savePrefs()` / `_loadPrefs()` / `_applyPrefs()` — kalles automatisk
- **Fullført:** 2026-03-11

### 6.2 Romsoneinndeling ⬜
- Automatisk deling av komplekse rom i soner basert på hindringer
- Krever 2D polygon boolean-operasjoner

### 6.3 Lærende system ⬜
- Statistikk fra brukerprosjekter
- Auto-foreslå bredder basert på historikk

### 6.4 PDF-eksport ✅
- **`exportPDF()`:** Forside, prosjektoversikt, etasje-tabeller, romdetaljer med tegning, materialliste
- **`_renderRoomToImage()`:** Offscreen canvas med polygon, hindringer, strips, kabler, matter, plater
- **jsPDF** via unpkg CDN
- 📄 PDF-knapp i topbar
- **Fullført:** 2026-03-11

### 6.5 Dokumentasjonsmodul ✅
- **Hva:** Per-rom installasjonsdokumentasjon med 5 faner (sjekkliste, målinger, bilder, signatur, notater)
- **Sjekkliste:** Auto-generert per modultype (folie/kabel/matte/plate), egendefinerte punkter, tidsstempling
- **Målinger:** Motstand (Ω), isolasjon (MΩ), temperatur (°C), egendefinert — med tabell og sletting
- **Bilder:** Filopplasting med JPEG-komprimering (maks 800px), bildetekst, galleri
- **Signatur:** Canvas-basert signaturpad (touch + mus), navn, lagring som PNG
- **Notater:** Fritekstfelt
- **Integrasjon:** Save/load, undo/redo, PDF-eksport (sjekkliste, målinger, bilder, signatur, notater per rom)
- **UI:** Modal-overlay med faner, 📋-knapp i ctxbar
- **Fullført:** 2026-03-12

### 6.6 Polygon band-clipping layout ✅
- **Hva:** Robust strip-clipping for komplekse polygoner (L-form, konkave rom)
- **Band-clipping:** 3 scanlines (begge kanter + senter) i stedet for 2
- **Sone-subtrahering:** Forbudte soner trekkes fra i `computeClippedSegments()`
- **Gap-merging:** `_mergeShortGaps()` slår sammen mikro-gaps < 3cm
- **Fullført:** 2026-03-12

---

## FASE 7: Utendørs snøsmelting ✅
> Mål: Støtte utendørs trapper med varmekabel for snøsmelting.
> **Fullført:** 2026-03-12

### 7.1 Trappemodul ✅
- **Frittstående entitet:** `S.stairs[]` — ikke tilknyttet rom/etasje
- **Parametrisk geometri:** Bredde, trinndybde, trinnhøyde, antall trinn, repos (ingen/topp/bunn/begge)
- **Kabel-layout:** Sentrert serpentin per overflate (trinn + repos), U-svinger, forbindelser mellom overflater
- **Dual visning:** Plan-visning (utbrettet) + Side-visning (trapp-profil)
- **Validering:** Maks CC 10cm, min 300 W/m², kabellengde-match mot produkt
- **UI:** Modal for parametere, ctxbar med CC-kontroller + visnings-toggle, sidebar-seksjon
- **Interaksjon:** Hit-testing, drag-gizmo (X/Y + free), hover, seleksjon
- **Save/Load/Undo:** Full integrasjon med eksisterende system
- **Fullført:** 2026-03-12

---

## Gjennomgående prinsipper

1. **Én arkitektur for alle moduler:** Polygon-clipping, rule validation, world coordinates
2. **Produktdata i Supabase:** Alle regler og spesifikasjoner lagres i DB, ikke hardkodes
3. **Inkrementell utvikling:** Hver fase bygger på forrige, ingenting kastes
4. **Test visuelt:** Alltid verifiser i preview før commit
5. **Bakoverkompatibilitet:** Eksisterende prosjekter skal alltid kunne åpnes
