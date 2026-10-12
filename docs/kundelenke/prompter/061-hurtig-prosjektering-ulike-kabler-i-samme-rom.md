# 061 · Hurtig prosjektering: «Ulike kabler» på et rom — flere linjer med valgfri kabel og antall, pluss for flere, samme resultatfelt (installert, W/m², felles CC, dekning, bestilles)

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Normal** · **Størrelse: middels**
**Meldt av Kenneth 12.10.2026** (skjermbilde av «Nytt rom»-kortet). Linjenumre fra `9785c32` — **symbolnavnene er fasit.**
**Spec:** `spec-utendors-produkter-hurtig-prosjektering.md` + 059-seksjonen «Listevisning i tegnede deler» — ny underseksjon «Ulike kabler» (§6).

---

## Kenneths ord

> «Kan vi få en knapp for å velge ulike kabler på et rom? Trykk «Ulike kabler», så kommer det opp
> to linjer hvor man kan velge valgfrie kabler, og en pluss for å legge til en linje til hvis man
> skal ha enda flere. Må fortsatt se samme resultater: total effekt, flateeffekt, CC.»

## Hva som finnes

| | Hvor | Hva det betyr for 061 |
|---|---|---|
| Ett produkt × antall | `room.listModType`, `room.listFamily`, `room.listCount`; `_listSetRoomProduct(roomId, modType, productId, count)` (:54823) lager N **like** `labelOnly`-kabler | Datamodellen har plass til én produkt-id. Trenger en liste |
| CC for «kun label» | `_cableLabelOnlyStats(roomId, productId, count)` (:18426): netto / N per kabel → CC per kabel | Riktig for like kabler. For ulike kabler er regelen **felles CC = netto / Σ lengde** — samme som hovedmodulens blandede kombinasjoner |
| Blandede kabler i hovedmodulen | `_generateMixedCombos(familyProducts, desiredW, netM2, tol)` (:24799-området) regner kombinasjoner av to ulike kabler med felles CC; `_placeMixedCables('id,id')` tegner dem; «Komponer ulike kabler selv…» (`_openMixComposer`) | Regnemåten finnes. Tegneveien finnes (til 059s «Tegn utlegg») |
| Kortet | `_listDraftCardHtml` (:55441): feltene Type · Klasse · Foreslått produkt · Antall, resultatboksen `li-net/want/eff/wm2b/wm2f/cc/cov/ant`, oppdatert av `_listRefreshComputed` (:55393) | Resultatboksen leser `_computeRoomStats` + `_roomRatedEffectW` — de summerer alle kabler i rommet uansett produkt (STEG 0.1 bekrefter) |
| Ferdig rad | `_listFinalizedRowHtml` (:55511): `_listRoomProductId` tar **første** label-kabel → «2× InFloor 10T 1800W» | Må vise alle produktene |
| Bestilles | `_listCountStr` (025b: «2 stk (1 + 1 reserve)») | Må liste per produkt |
| 059 | Tegnede rom bruker samme `_listSetRoomProduct`; «Tegn utlegg» per rad | Får «Ulike kabler» gratis hvis det bygges i samme funksjoner |

## STEG 0

1. Lag et listerom og kall `_listSetRoomProduct(rid,'cable',<1800W-id>,1)`; push deretter manuelt
   én `labelOnly`-kabel til med et annet produkt (1200 W) og `spacing_cm` lik den første. Hva sier
   `_computeRoomStats(room)` — `cableCcCm` (første? snitt?), `cableLenM`, `heatedM2` — og
   `_roomRatedEffectW`? Rapportér, så vi vet om resultatboksen summerer riktig uten endring.
2. `_syncReserveCables` (025b) på et fryserom med to ulike label-kabler — lages én reserve per
   kabel (riktig) eller én per produkt?
3. Materialliste (`_exportMaterialListXLSX`) og Romoversikt-PDF for rommet i 0.1: to linjer
   (1 × 1800 W, 1 × 1200 W)?
4. `_listCableCandidates`/`_listProductOptionsHtml`: lista over produkter i klassen — kan den
   gjenbrukes rad for rad i blandet modus?

## Gjør

### 1. Datamodell

- `room.listMix = [{ productId, count }, …]` (≥ 2 rader når satt; `null`/udefinert = like kabler
  som i dag). `listFamily` gjelder fortsatt — alle rader velges **innenfor samme klasse**
  (familie + spenning). Ulik klasse ville gitt ulik W/m² i hver sone med felles CC; det er en
  annen sak (SPØRSMÅL).
- Ny `_listSetRoomProductMix(roomId, rader)`:
  ```
  rader = rader.filter(r => r.productId && r.count ≥ 1)
  sumLen = Σ count × cable_length_m ; sumW = Σ count × W
  cc = netto / sumLen × 100 ; klem til [maks(minSp), min(maxHard)] over produktene (016-regelen:
       over maxWarn er lov men ⚠)
  fjern rommets label-kabler; for hver rad: count × { labelOnly:true, productId, spacing_cm: cc,
       cc_mm, totalLength_cm, runs:[] }
  room.listMix = rader ; room.listCount = Σ count
  _invalidateCableCache()  (→ _syncReserveCables, STEG 0.2)
  ```
  `_listSetRoomProduct` (like kabler) setter `room.listMix = null`. `_listRecomputeCurrent`
  (areal endret) går via mix-funksjonen når `listMix` finnes, så CC regnes på nytt.
- Lagres i prosjektet som alt annet på rommet (det er bare felt på `room`).

### 2. Kortet («Nytt rom» / «Rediger rom»)

- Ved siden av **Antall**: knapp **«Ulike kabler»** (bare når Type = Kabel). Klikk → feltene
  «Foreslått produkt» og «Antall» byttes ut med en liste:
  ```
  Kabel 1   [InFloor 10T 1800W 180m · 1800 W  ▾] [▲▼]   × [1] [−/+]   ✕
  Kabel 2   [— velg kabel —                   ▾] [▲▼]   × [1] [−/+]   ✕
  [+ Legg til kabel]      [Foreslå]      [Like kabler i stedet]
  ```
  Rad 1 forhåndsfylles med dagens produkt og antall; rad 2 tom. Produktlista per rad = klassens
  produkter (`_listProductOptionsHtml`-kilden, STEG 0.4). Hver endring → `_listSetRoomProductMix`
  → `_listRefreshComputed` (resultatboksen oppdateres live som i dag). ✕ på en rad fjerner den;
  under to rader → tilbake til like kabler automatisk.
- **Foreslå**: `_generateMixedCombos(klassens produkter, ønsketW, netto)` → første kombinasjon
  som ikke er «balanced» (to ulike) fylles inn i radene; finnes ingen innen ±12 % → toast «Ingen
  to-kabel-kombinasjon treffer 3520 W — velg selv».
- **Like kabler i stedet** → `_listSetRoomProduct` med rad 1s produkt og Σ antall; listen
  kollapser til de to feltene.
- Bytte av **Klasse** i blandet modus → radene tømmes (produktene finnes ikke i den nye klassen)
  og rad 1 fylles med klassens forslag; bytte av **Type** til Matte → like-modus.
- Resultatboksen: **Installert** = Σ W, **W/m² brutto/flate** som i dag (leser summen), **CC** =
  felles CC (⚠ når over anbefalt), **Dekning** som i dag, **Bestilles** = «1 × 1800 W + 1 × 1200 W»
  (med reserve-tillegg fra 025b der det gjelder).
- Tab-rekkefølge og `_listKey`-navigasjon (Enter = Legg til rom) virker også gjennom radene.

### 3. Ferdig rad og eksport

- `_listFinalizedRowHtml`: Produkt-cellen «InFloor 10T **1800 W + 1200 W**» (klasse én gang,
  effekter adskilt med +; ved antall > 1: «2 × 1800 W + 1200 W»), tooltip med fulle produktnavn.
  Klikk → kortet åpner i blandet modus.
- `_listCountStr`: per produkt, «1 + 1 stk» → hold formen «2 stk (1 × 1800 W, 1 × 1200 W)».
- Materialliste, Romoversikt, Visma-eksport: ingen endring hvis STEG 0.3 viser to linjer; ellers
  rett opp der det samler på **første** produkt.
- 059s tegnede rom: samme kort-del i raden («Ulike kabler» tilgjengelig i Produkt-cellen),
  og **«Tegn utlegg»** på et rom med `listMix` kaller `_placeMixedCables(ids…)` med antall
  utvidet (1800,1200 → `'id1800,id1200'`; 2 × 1800 + 1200 → `'id1800,id1800,id1200'`) — bekreft at
  `_placeMixedCables` tåler tre, ellers rapportér.
- Arveregelen (059 §3): neste rad arver **klassen**, ikke blandingen (nytt rom starter som like
  kabler).

### 4. Hovedmodulens «Kun label»-knapp (bonus, liten)

`_placeCableLabelOnly(productId, fam, cat, count)` (:18450) får ikke blandet modus nå —
«Komponer ulike kabler selv…» finnes der. Ikke rør, men bekreft at et rom som fikk blandede
label-kabler fra lista vises riktig i hovedmodulens romstatistikk når prosjektet åpnes der.

## Skal IKKE

- Blande kabler på tvers av klasser (10T + 17T) eller spenninger.
- Endre `_generateMixedCombos`, `_cableLabelOnlyStats` eller `_computeRoomStats` (hvis STEG 0.1
  viser at den summerer riktig — ellers rett opp **der**, ikke i lista).
- Endre matte-flyten.

## Test

1. Stue 45 m² (1 m² hindring), 80 W/m², InFloor 10T 230 V → «Ulike kabler» → rad 1 1800 W, rad 2
   velg 1200 W → Installert 3000 W, W/m² flate ≈ 68, CC = 44 / (180 + 120) × 100 = **14,7 cm**,
   Bestilles «2 stk (1 × 1800 W, 1 × 1200 W)». Legg til rad 3 med 600 W → 3600 W, CC 12,2.
2. «Foreslå» → fyller to rader som til sammen treffer 3520 W ± 12 % (f.eks. 1800 + 1700).
3. ✕ på rad 2 og 3 → tilbake til like kabler, Antall-feltet tilbake med 1.
4. «Legg til rom» → raden viser «InFloor 10T 1800 W + 1200 W + 600 W», 3600 W; klikk → kortet
   åpner i blandet modus med tre rader. Endre brutto areal til 60 → CC regnes på nytt, produktene
   står.
5. Materialliste: tre linjer med riktig antall; Romoversikt-PDF viser alle tre. Fryserom med to
   ulike kabler → reserve per kabel (STEG 0.2).
6. 059 tegnet del: rom med blandede label-kabler → «Tegn utlegg» → tre kabler tegnet med felles
   CC; Ctrl+Z tilbake til label.
7. `_listevisningRegressionTest` (059) utvidet: `listMix` gir felles CC = netto/Σlengde, Σ W,
   `listMix=null` ved like, Klasse-bytte tømmer radene, arv gir ikke `listMix`.

## Rapport

STEG 0.1–0.4 (hva `_computeRoomStats` gjør med ulike `spacing_cm`/produkter, reserve per kabel,
eksportene). Endringslogg. Spec-underseksjon. Commit: «061: hurtig prosjektering — Ulike kabler
på et rom (flere rader, felles CC = netto/Σlengde, Foreslå fra mixedCombos), vises i rad, eksport
og 059s Tegn utlegg».
