# 044 · Kundeforslag hos Cenika: panel med Godkjenn/Avslå per rom → nytt utlegg, e-post begge veier, «Godkjenn hele prosjektet» som signal

**Repo:** `arqely-mvp` · **Filer:** `index.html`, `supabase/functions/kundelenke-mail/index.ts` · **Prioritet: Høy** · **Størrelse: middels**
**Spec:** `spec-kundeforslag.md` regel 7–9. Krever 043. Linjenumre fra `2147753`.

---

## Kenneths ord

> «Vi får melding om at kunden ønsker endring, vi trykker godkjenn forslag, og det endrer seg
> med layout og alt.»

## Hva som finnes

| | Finnes | Gjenbruk |
|---|---|---|
| Panel for kundesvar | `openKundeReviewPanel` (:≈8717, 028/033/035) + auto-åpning ved prosjektåpning (037) + merker i prosjektlista (038) | Samme ramme, ny fane/variant «Kundeforslag» |
| Auto-utlegg | kabel `autoFillCable(roomId, productId)` (:22391) / `_autoFillCableImpl`; folie `autoAddStrips(roomId, productId)` (:5754); matte `autoFillMatSerpentine`/matte-motoren; retning via `S.varmefolie.direction` (:18155/:23759) og `cable.direction` | Godkjenn = fjern dagens utlegg i rommet + kjør motoren med nytt produkt/retning |
| E-post | `kundelenke-mail` (`invite`/`answered`, 029/031) | Nye `kind`: `forslag_answered` (til Kenneth), `forslag_svar` (til kunden: hva ble godkjent/avslått) |

## STEG 0

1. Hvordan «legger man på nytt» i et rom i dag med et annet produkt — hvilken funksjon rydder
   gamle kabler/striper/matter i rommet før ny auto? (`_clearRoomHeating`? finn den som
   «Legg ut på nytt»/produktbytte i kabelpanelet bruker.) Hindringer/soner skal stå.
2. Hvordan settes retning før auto-utlegg for hver type (kabel: `opts.direction`? folie:
   `S.varmefolie.direction`; matte: ?). List inngangene.
3. 038s merke: `_fetchKundeStatus` henter `open/answered` uansett `mode` — forslag-svar får
   dermed «✓ Mål mottatt». Teksten må skille: «💬 Forslag fra kunde».

## Gjør

### 1. Panel «Kundeforslag»

Åpnes av 037-mekanismen når lenken med `mode='forslag'` er `answered`. Per rom en rad:

| Rom | Nå | Kunden foreslår | Kommentar | |
|---|---|---|---|---|
| Stue | InFloor 10T 800 W · 50 W/m² · CC 20 | **900 W** · 56 W/m² · CC 17,8 · loddrett | «Vil ha varmere ved vinduet» | [Godkjenn] [Avslå] |
| Bad | EcoMat 150 | ✓ OK som det er | | — |

- «Nå»/«foreslår»-tallene regnes med samme `selectCableByPower`-kandidat som kunden så (043) — ikke
  nye tall.
- **Godkjenn** (per rom): `pushUndo()` → rydd rommets utlegg (STEG 0.1) → sett retning (STEG 0.2) →
  kjør auto-utlegg med `productId` (kabel via `autoFillCable`, folie via `autoAddStrips`, matte
  via matte-motoren) → `_invalidateCableCache` osv. → rommet får brikke «Godkjent · <dato>».
  Feiler motoren (f.eks. får ikke plass) → toast med årsak, rommet står, raden får ⚠.
- **Godkjenn alle** → samme per rom i rekkefølge, ett `pushUndo` totalt.
- **Avslå** → kort begrunnelse (fritekst, forslag: «Beholder dagens — gir jevnere varme») lagres
  per rom.
- Når alle rader er behandlet → «Send svar til kunden» → status `applied`, e-post `forslag_svar`
  med tabell (rom · godkjent/avslått · begrunnelse) og lenke til presentasjonen (oppdatert).
- Rom med `ok:true` vises med grønn hake, ingen handling.

### 2. «Godkjenn hele prosjektet» (signal)

- Kundesiden (043): når alle rom er OK (ingen forslag), vises knappen «Godkjenn hele prosjektet»
  → navn (påkrevd) + dato → `approveAll:{name, at}` i svaret.
- Varmeplan: prosjektinfo-blokken viser «✓ Godkjent av <navn> <dato>» (fra svaret), prosjektlista
  får grønn ✓-brikke «Godkjent av kunde». **Ingen** låsing, ingen PDF-stempel (spec regel 9 —
  SPØRSMÅL.md avgjør om det skal bli formelt).

### 3. E-post

- `kundelenke-mail`: `kind='forslag_answered'` → til `notify_email`: «<navn> har sendt forslag til
  <prosjekt>: N rom OK, M endringer» + knapp «Åpne i Varmeplan» (`?project=&kundesvar=`, 029).
  `kind='forslag_svar'` → til `invite_sent_to` (kundens e-post fra 029) hvis den finnes, ellers
  ingen e-post (kunden ser svaret i presentasjonen uansett: 043-kortet viser «Godkjent/Avslått»
  per rom når lenken er `applied`). Samme rate-/auth-regler som 029.

### 4. Prosjektlista og sidebar

- 038-merket: `mode='forslag'` + `answered` → «💬 Forslag fra kunde» (oransje-blå?) — bruk blå
  (`var(--accent)`) så det skiller seg fra mål-merkene. `approveAll` → «✓ Godkjent av kunde»
  grønn. Sidebar-raden likedan.

## Skal IKKE

- Endre auto-motorene selv — bare kalle dem.
- Låse prosjektet eller endre PDF ved godkjenning (ikke før SPØRSMÅL er besvart).
- Sende e-post til kunden uten en adresse vi faktisk har fra 029.

## Test

1. Forslag «900 W loddrett» i Stue + OK i Bad → panelet åpner ved prosjektåpning → Godkjenn →
   Stue har 900 W-kabel loddrett, hindringer står, Bad urørt, Ctrl+Z gir 800 W tilbake.
2. Avslå med begrunnelse → Send svar → status `applied`, kunden ser «Avslått: …» i presentasjonen,
   e-post hvis adresse finnes.
3. Motor som ikke får plass (velg en kabel som er for lang) → ⚠ på raden, rommet uendret.
4. Godkjenn hele prosjektet fra kundesiden → «✓ Godkjent av Ola 08.10» i prosjektinfo og lista.
5. Prosjektlista: «💬 Forslag fra kunde» for forslag, «✓ Mål mottatt» for mål — aldri blandet.
6. `_kundeforslagRegressionTest` utvidet: godkjenn-flyt på syntetisk rom gir nytt produkt-id og
   retning, ett undo-steg; avslå lagrer begrunnelse; `approveAll` vises.

## Rapport

STEG 0.1–0.3 (rydde-funksjonen, retningsinnganger, merketekst), om folie/matte-godkjenning
virket likt som kabel. STATUS.md-seksjon «Kundeforslag» + «Til Kenneth». Endringslogg.
Commit: «044: kundeforslag — panel med Godkjenn/Avslå per rom som kjører auto-utlegg, e-post begge veier, Godkjent av kunde som signal».
