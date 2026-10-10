# 054 · Kundesiden: pil forbi største kabel → 2 × like kabler (2200, 2400 …), «ønsket flateeffekt» bruker samme stige, og rom uten varme kan få et produktforslag (kabel/matte → serie → variant)

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Normal** · **Størrelse: middels**
**Meldt av Kenneth 10.10.2026.** Linjenumre fra `e2bb6f4` — **symbolnavnene er fasit.**
**Spec:** `docs/kundelenke/spec-kundeforslag.md` regel 3–4 (utvides), «Ikke i v1» (ett punkt oppheves). Se 000 for regel 14–15.
**Forutsetning:** 053 (godkjenningen skriver `cableCount` i `applied_result.resultat`).

---

## Kenneths ord

> «Når man piler seg opp og kommer til den største kabelen, og kunden ønsker litt mer
> flateeffekt enn én av den største, kan neste steg bli 2 stk like som gir et hakk høyere effekt.
> InFloor 10T, maks 2000 W: neste steg 2 stk 1100 W = 2200 W, neste 2 stk 1200 W = 2400 W osv.
> Det samme må hensyntas ved inntasting av flateeffekt. Rom som ikke har produkt: der kan kunden
> også få foreslå produkt — innendørs rom velger kabel eller matte, så gruppe, så type.»

## Hva som finnes

| | I dag | Konsekvens |
|---|---|---|
| Pilelista | `_forslagAlternativer` (:7345) → `selectCableByPower` (:24757) → **én** kabel per rad, sortert etter W. Stigen stopper på største kabel i serien (`_forslagKabelSerie` :7414) | Kunden kan ikke be om mer enn 2000 W i et stort rom |
| Flerkabel | Finnes i hovedmodulen: `selectMultiCables` (:24856) regner `byN` (N = 2..16, **én** beste kandidat per N), `_generateMixedCombos`, og utlegget `autoFillMultiCable(roomId, productId, nCables)` (:26347) → `_autoFillNCables` | Motor og utlegg er klare — bare ikke koblet til kundesiden |
| «Finn» ønsket flateeffekt | `_forslagOnsket` (:7632) → `below`/`above` fra `selectCableByPower` | Samme tak |
| Rom uten produkt | `_presentRoomProduct` null → `_forslagAlternativer` null → `_forslagKortHtml` (:7512) gir tom streng; regresjonssjekk E (:19204) **krever** null | Kunden kan ikke si noe om rommet |
| Godkjenning | `_forslagGodkjennRom` (:68948): `type = _forslagRomType(roomId)` → null → «Rommet har ikke noe utlegg å bytte»; kabel → `autoFillCable` (én) | Må lære flerkabel og nytt rom |
| Produktvalg i hovedmodulen | `_upcState` modType → klasse (`_famKeyOf`/`_familyKlasse` over `_upcScopeProducts(modType)`, :10645) → spenning → resultater | Samme trinn kan gjenbrukes for kunden: type → serie → variant |

## STEG 0

1. Okkenhaugvegen-stue eller et 30 m² testrom med InFloor 10T: list `_forslagAlternativer(room).liste`
   — hva er største W, og hvilken CC får 2 × 1100 W der (`nettoM2 / (2 × 65 m)`)? Er den gyldig
   etter `_ccLimits`?
2. Hva returnerer `autoFillMultiCable(roomId, pid, 2)` — liste av kabler med `multiCableGroup`?
   Trenger den `S.ui.selectedRoomId` (044 målte at `autoFillMatSerpentine` gjør det)?
3. Hvilke produkter ser den **anonyme** presentasjonen? `_loadProducts` (via `_presentLoadByToken`
   :10580) — er leverandør-filteret (:66922, `supplier`) og `active !== false` med? Kunden skal
   bare kunne velge det Kenneth selv kan velge.
4. `_upcScopeProducts('cable')` og `('mat')` uten innlogging — virker de i presentasjonen, eller
   leser de `_userOrg`/`PRODUCT_CATEGORIES` som er tomme der?

## Gjør

### 1. Stigen fortsetter forbi største kabel

Ny `_forslagStige(room, serie)` ved siden av `selectMultiCables` (gjenbruk `_ccLimits`,
`roomAreas` — ingen egen formel):

```
for N in 1..3:                              // SPØRSMÅL: tak på 3? (kundesiden, ikke motoren)
  for prod in serie:
    totalW = N × prod.watt_per_m × prod.cable_length_m
    cc     = nettoM2 / (N × prod.cable_length_m) × 100
    valid  = cc innen [minSp, maxHard] og bøyeradius ok (samme test som selectCableByPower)
    rad    = { productId, cableCount: N, navn, W: totalW, wm2, flateeffekt: W/m ÷ CC, cc, valid, overMax, advarsel }
behold N>1 bare når totalW > største GYLDIGE W for N−1   // stigen skal stige: ikke 2×500 når 1000 finnes
sorter etter W; ved lik W vinner færrest kabler
```

- `_forslagAlternativer` for kabel bruker stigen. `naaIdx` finner raden med rommets
  `productId` **og** antall kabler som ligger der (`S.cables.filter(roomId).length` for samme
  produkt / `multiCableGroup`).
- Kortet (`_forslagKortHtml`): navn for N>1 skrives «**2 stk** InFloor 10T 1100 W = 2200 W»;
  under tallene en grå linje «To kabler → to kurser/termostatutganger» (SPØRSMÅL: ønsket?).
  Pilene hopper over ugyldige som før.
- «Finn» (`_forslagOnsket`): nærmeste **under** og **over** ønsket flateeffekt hentes fra stigen
  (`liste.filter(valid)`), ikke fra `selectCableByPower.below/above`.
- Payload (`_forslagPayload` :7714): `rooms[].cableCount` (utelates når 1). Spec-datamodellen
  oppdateres.

### 2. Godkjenningen lærer flerkabel

`_forslagGodkjennRom`, grenen `type === 'kabel'`:
```
N = rad.cableCount || 1
_clearRoomProductCollections(roomId, ['cables'])
N === 1 → autoFillCable (som nå)
N  >  1 → autoFillMultiCable(roomId, pid, N)  → push alle, ok = liste med N kabler
```
`_forslagKandidatGyldig` matcher på `productId` **og** `cableCount`. `_forslagRadTall` og 053s
«Ble:»-linje viser «2 stk … = 2200 W». `resultat.cableCount` i `applied_result` (053).

### 3. Rom uten varme får kortet «Foreslå varme»

- `_forslagKortHtml` for rom uten produkt (og **ikke** snørom — `room.kind`/snø-modul utelates;
  fryserom utelates): kort med tekst «Ingen varme er planlagt i dette rommet» og knapp
  **«Foreslå varme»** (+ «✓ OK uten varme» som tilsvarer `ok: true`).
- «Foreslå varme» åpner tre trinn **i kortet**:
  1. **Type:** `Kabel` · `Matte` (brikker). Folie holdes utenfor (SPØRSMÅL).
  2. **Serie:** brikker fra samme kilde som hovedmodulens produktvalg
     (`_upcScopeProducts(modType)` → `_famKeyOf`/`_familyKlasse`, STEG 0.4), f.eks. «10T · 17T»
     for kabel, «EcoMat 60T · 100T · 150T» for matte. Én rad i katalogen = én serie; vis bare
     serier som har minst én gyldig rad i rommet.
  3. **Variant:** samme pilekort som i dag (stigen for kabel, W/m²-variantene for matte), startet
     på raden nærmest rommets standard-flateeffekt (`_roomTargetWm2(room.id)` — bad 100, stue 80
     osv., som Kenneths eget panel).
- Payload: `{ roomId, ok: false, nyType: 'kabel'|'matte', productId, cableCount?, targetWm2?,
  direction?, comment? }`.
- Godkjenning: `_forslagRomType(roomId)` er null → bruk `rad.nyType`. Matte: `_forslagMatteProdukt`
  faller i dag tilbake på `naaProd` som ikke finnes → returner `rad.productId` direkte når rommet
  er tomt. `_forslagRadTall`: «Nå: ingen varme».
- 053-vinduet og romlista viser disse som vanlige kundeønsker («Kunden foreslår: InFloor 10T 800W
  (nytt)»).
- Regresjonssjekk E (:19204) endres: tomt rom gir **ingen pileliste, men kortet «Foreslå varme»**.

## Skal IKKE

- Endre `selectCableByPower`, `selectMultiCables` eller `autoFillMultiCable`.
- La kunden velge blandede kabler (1100 + 1300) — bare N × like. Blandet er en samtale.
- La kunden velge mellom kabeltyper **i et rom som alt har kabel** (043-regelen står: 10T blir 10T).
  Serievalget gjelder bare rom uten varme.
- Vise pris, artikkelnummer eller leverandør.

## Test

1. 30 m² rom med InFloor 10T 1300 W: pil opp til 2000 W → neste «2 stk 1100 W = 2200 W» → «2 stk
   1200 W = 2400 W» → … ; ingen 2 × 500. Flateeffekt/CC per rad stemmer med Kenneths eget
   forslagspanel for samme antall (sammenlign tall).
2. Tast ønsket 130 W/m² i samme rom → under/over hentes fra stigen og kan være 2 stk.
3. Send → Kenneth godkjenner «2 stk 1200 W» → to kabler i rommet (`multiCableGroup`), «Ble: 2 stk
   InFloor 10T 1200 W = 2400 W · 80 W/m² · CC 12». Ctrl+Z fjerner begge.
4. Tomt innendørs rom → kortet «Foreslå varme» → Kabel → 10T → pil til 800 W → Send → godkjent →
   kabel lagt. Samme med Matte → EcoMat 100T → godkjent → matte lagt. Snørom uten produkt → ingen
   «Foreslå varme».
5. Anonym presentasjon viser nøyaktig de seriene Kenneth ser i sitt produktvalg (STEG 0.3/0.4) —
   ikke inaktive, ikke andre leverandører.
6. `_kundeforslagRegressionTest`: stigen stiger monotont, N>1 først over største gyldige enkelt-W,
   `cableCount` i payload, godkjenning med N=2 gir 2 kabler, tomt rom gir «Foreslå varme»-kort,
   snørom gir ikke.

## Rapport

STEG 0.1–0.4 (tallene for 2 × 1100, hva `_upcScopeProducts` gjør anonymt), taket på N, og om
bøyeradius-testen stanset noen rader. Endringslogg. Spec regel 3–4 og «Ikke i v1» oppdatert.
Commit: «054: kundesiden — stigen fortsetter med 2 × like kabler, ønsket flateeffekt bruker
stigen, rom uten varme får Foreslå varme (type → serie → variant)».
