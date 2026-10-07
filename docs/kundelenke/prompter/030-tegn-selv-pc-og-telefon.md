# 030 · Tegn selv: kunden/elektrikeren tegner rommene — Mål, Polygon, L-form og WBW på PC; WBW med piler og talltastatur på telefon

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Høy** · **Størrelse: stor**
**Spec:** regel 5, 6. Krever 027 og 028. Linjenumre fra `d43d1d8`.

---

## Kenneths ord

> «Elektrikere på befaring kunne gått inn på vår app (web eller telefon), opprettet prosjekt,
> romnavn og tegnet opp rommet med de forskjellige valgene, for så å sende oss en lenke … Mål,
> Polygon, L-form og WBW. WBW på PC kan virke som det gjør på vår PC, mens WBW på telefon kan
> virke med pilknapper som legger veggene og inntasting av mål ved tall. Det bør da være et
> tastatur med tall og piler.»

## Hva som finnes — tegneverktøyene er der alt

| Modus | Finnes som | Inngang |
|---|---|---|
| Mål (lengde × bredde) | `startDrawMode('rect-dim')` (:39847) + dimensjonspanelet (:39889) | Tast to tall |
| Polygon | `startDrawMode('polygon')` | Klikk punkter |
| L-form | `startDrawMode('lshape')` (:2136 `startDrawFromBar('lshape')`) | Klikk hjørner |
| WBW | `startDrawMode('wbw')` → `#wbw-panel` (:596/2073), `#wbw-len`, `setDir(d)` (:40028), `addWbwWall()` (:40034), `wbwDirPlace(d)` (:40033 = sett retning + legg vegg) | **Nøkkelen for telefon:** `wbwDirPlace` er allerede «pil = legg vegg i den retningen med lengden i feltet» |
| Ferdig rom | `createRoom(pts, shape, name, floorId, …)` (:35355) | Brukes **ikke** på kundesiden — kunden sender punkter, Kenneth oppretter via 028 |

Så 030 er ikke nye tegnemotorer. Det er: (1) tegneverktøyene tilgjengelig i kundemodus på en
tom/midlertidig tegning, (2) en telefon-HUD for WBW, (3) romskjema per rom, (4) innsending som
`tegn`-svar, (5) 028-panelet som oppretter rommene.

## STEG 0

1. Kjør `startDrawMode('wbw')` i kundemodus (027) — hva knekker? (sidebar, `pushUndo`,
   `_supabaseProjectId`, lagring, `S.floors`.) Lag lista.
2. Test `wbwDirPlace('up')` fra konsollen med `#wbw-len` = 320 → legges det en vegg uten mus?
   Hvordan lukkes rommet (siste vegg til startpunkt — finn «Lukk»/`finishWbw`)?
3. Mål på en ekte telefon (eller devtools med `pointer: coarse`, 390 px): hvor stor er
   `#wbw-panel`, og hva skjer med mobilens tastatur når `#wbw-len` får fokus (det er dét vi vil
   unngå — talltastatur på skjermen i stedet, spec regel 5).
4. Hvilke felter trenger `_listCreateRoomObj` (:46742) / `createRoom` for et komplett rom
   (navn, romtype, etasje, varmetype, W/m²) — det er skjemaet per rom.

## Gjør

### 1. Kundemodus `tegn`

- 027-modalen: modus **Tegn** aktiv. En `tegn`-lenke kan lages på et **tomt** prosjekt (Kenneth
  oppretter prosjektet, evt. bare med navn) eller et med rom (kunden legger til).
- Kundesiden i `tegn`: samme skall som `maal`, men med en **verktøylinje** med fire knapper
  (Mål · Polygon · L-form · Vegg for vegg) + «Angre» + «Nytt rom». Eksisterende rom fra
  prosjektet vises grå og låst (kan ikke endres i tegn-modus — mål rettes via en `maal`-lenke).
- Nye rom tegnes inn i et **lokalt** `S.rooms` med `id` < 0 og `_kunde: true`, aldri lagret til
  Supabase annet enn som svar. `createRoom` kan brukes lokalt for å lage romobjektet (den er ren
  JS) — men alt som kaller lagring/autosave/`_projectDirty` må være gatet på `S.ui.kundeMode`.
  STEG 0.1-lista avgjør hva som gates.
- Etter hvert rom: **romskjema** (bunnark på telefon, panel på PC): Romnavn (forslag «Rom N»),
  Romtype (fra `ROOM_TYPES` — labels, ingen W/m²-tall vises), Etasje (fra prosjektet, eller
  fritekst), Varmetype-ønske (Folie / Kabel / Matte / Vet ikke), «Ønsket komfort» (Lav/Normal/Høy
  → mappes til W/m² hos Kenneth, ikke hos kunden), Kommentar. Ingen produkter.
- **Send inn** → `kundelenke_answer` med `{ rooms: [{ name, roomType, floorName, shape, points
  (cm, absolutte i kundens tegning), modType, comfort, comment }], comment }`.

### 2. Telefon-HUD for WBW (spec regel 5)

Når `pointer: coarse` eller bredde < 900 px og modus WBW:
- Skjul `#wbw-panel`. Vis `#wbw-pad` fast nederst: øverst **visning** av gjeldende lengde
  («3,20 m») og neste retning; midten et **talltastatur** `7 8 9 / 4 5 6 / 1 2 3 / , 0 ⌫` som
  skriver i `#wbw-len` (cm internt; vis m med komma); høyre kolonne **piler** ↑ → ↓ ← som kaller
  `wbwDirPlace(d)`; nederst «Angre vegg», «Lukk rom», «Avbryt». Alle knapper ≥ 48 px.
- `#wbw-len` får `inputmode="none"` + `readonly` i kundemodus på telefon så mobil-tastaturet ikke
  dukker opp (STEG 0.3). På PC uendret.
- Lerretet viser det som er tegnet, auto-zoom til rommet mens man legger vegger
  (`fitAll`-varianten `startDrawMode` alt bruker).
- Lukk rom: når siste vegg havner ≤ 5 cm fra startpunktet → snap og lukk; ellers knappen «Lukk
  rom» trekker siste vegg til start og viser lengden den fikk («Lukkende vegg: 2,95 m — stemmer
  det?»). I tillegg `_roomAxisBalance` (027 §2b) **mens** veggene legges: pad-en viser «↕ opp 8,15 ·
  ned 11,25» og «↔ høyre 6,45 · venstre 6,45», så elektrikeren ser *hvilken* retning som mangler
  før han lukker — det er feilen i skissen fra 07.10 (enkeltmål riktige, summen ikke).

PC: WBW som i Varmeplan (`#wbw-panel`), Mål/Polygon/L-form som i Varmeplan, bare uten sidebar.

### 3. 028-panelet tar imot rom

Gjennomgangspanelet (028) får fanen **«Nye rom fra kunde (N)»**: liste med navn, romtype,
areal (fra punktene), varmetype-ønske, komfort, kommentar, og en miniatyr-forhåndsvisning.
**Bruk** per rom / **Bruk alle** → `createRoom(points, shape, name, floorId, true /*keepPosition*/)`
+ romtype (`setRoomType`), `moduleType/listModType` fra ønsket, `targetWm2` fra romtypen (komfort
Lav/Høy ±20 %), alt i ett `pushUndo`. Rommene plasseres der kunden tegnet dem i forhold til
hverandre; hvis prosjektet alt har rom, flyttes hele gruppen til høyre for eksisterende (samme
100 cm-regel som `startDrawMode('wbw')` bruker). Ingen romnavn-kollisjon: «Stue (kunde)» ved
duplikat.

## Skal IKKE

- Lage nye tegnemotorer eller endre eksisterende tegnefunksjoner for innloggede brukere.
- La kunden velge produkt, W/m²-tall eller se Varmeplans forslag.
- Lagre kundens tegning i `romtegner_projects` før Kenneth trykker Bruk.

## Test

1. PC, tegn-lenke på tomt prosjekt: tegn ett rom med hver metode (Mål 3,2 × 4; Polygon 5 pkt;
   L-form; WBW 4 vegger) → fire rom i lokal liste, skjema fylt, Send inn → `answer.rooms.length === 4`.
2. Telefon (390 px): WBW med pad — tast 320, ↑, tast 400, →, tast 320, ↓, «Lukk rom» → rektangel
   3,20 × 4,00; mobil-tastaturet dukket aldri opp; alle knapper treffbare.
3. Kenneth åpner prosjektet → «Nye rom fra kunde (4)» → Bruk alle → fire rom i prosjektet med
   riktig navn/romtype/varmetype, plassert til høyre for eksisterende, Ctrl+Z fjerner alle fire.
4. Tegn-lenke på prosjekt med rom: eksisterende rom grå og låst, nye kan tegnes ved siden av.
5. Innlogget bruker: ingen endring i tegneverktøy, `#wbw-panel` som før (bit-for-bit på
   `_foilRegressionTest`/`_cableSkewRegressionTest`).
6. `_kundelenkeRegressionTest`: `tegn`-payload → `createRoom` gir riktig areal og `points[0]`
   relativt; ugyldige punkter (< 3, NaN, > 100 m) avvises med melding.

## Rapport

STEG 0.1-lista (hva som måtte gates), 0.3-målingene, hvordan «Lukk rom» ble løst, og hvor stor
HUD-en ble på 390 px. Endringslogg. STATUS.md for hele serien (se 000). Commit: «030: tegn selv via kundelenke — Mål/Polygon/L-form/WBW på PC, WBW med piler + talltastatur på telefon, rom inn via gjennomgangspanelet».
