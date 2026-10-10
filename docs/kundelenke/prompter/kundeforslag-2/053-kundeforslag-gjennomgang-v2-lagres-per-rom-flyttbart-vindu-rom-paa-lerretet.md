# 053 · Kundeforslag-gjennomgang v2: beslutningene lagres per rom (flagget forsvinner når alt er behandlet, uten «Send svar»), flyttbart vindu som viser rommet på lerretet, kundeønske synlig i romlista

**Repo:** `arqely-mvp` · **Fil:** `index.html` (+ liten migrasjon) · **Prioritet: Høy** · **Størrelse: middels–stor**
**Meldt av Kenneth 10.10.2026.** Linjenumre fra `e2bb6f4` — **symbolnavnene er fasit.**
**Spec:** `docs/kundelenke/spec-kundeforslag.md` regel 7 (endres) + nye regler 11–13 (se 000).

---

## Kenneths ord

> «Når kunde sender endringene, mottar jeg e-post og prosjektet merkes med tag i lista. Den
> taggen forsvinner ikke etter at jeg har gjort endringene. Når jeg går inn på prosjektet på
> nytt, kommer samme vindu opp med kundeforslaget. Jeg trykker godkjenn og lukk — ikke «send
> svar til kunde». Det står fortsatt en tekst oppe til venstre ved prosjektinfo om at forslag fra
> kunde må gås gjennom.»
>
> «Det føles litt utrygt å bare endre løsningen med en knapp uten å se hva som skjer. Kan vinduet
> flyttes på, så trykker man på et rom i vinduet og rommet i canvas blir valgt, man kan zoome inn,
> så trykker man bytt — slik at jeg ser hva som faktisk endres i rommet. Så neste rom.»
>
> «Jeg vil kunne krysse vekk vinduet, og alle rom i romlista i venstre bar er markert med en farge
> som indikerer et kundeønske. Jeg trykker meg inn på de markerte rommene, rommet vises i canvas,
> kundeønsket vises i egen rute.»

## Hva som skjer — målt i koden

| Symptom | Årsak |
|---|---|
| Taggen «💬 Forslag fra kunde» blir stående | `_plKundeBadge` (:68254) og `_renderSbForslagRad` (:55157) viser så lenge `status === 'answered'`. **Eneste** vei til `applied` er `_forslagSendSvar` (:69200) — knappen «Send svar til kunden». Godkjenn/Avslå endrer bare `_forslagRevState.behandlet` (:68927), som er et **Map i minnet** |
| Samme vindu kommer igjen ved neste åpning | `_kundeMaybeOpenReview` (:68899) sperrer med `_kundeReviewShownFor` — også bare i minnet. Ny innlasting → `behandlet` er tom, status fortsatt `answered` → panelet åpner med alle rom «ubehandlet», selv om utlegget alt er byttet |
| Teksten i prosjektinfo | Samme rad: `_renderSbForslagRad` på `status === 'answered'` |
| Kan ikke se rommet mens man godkjenner | `_forslagRevRender` (:69083) lager `#fors-rev-ov` som `position:fixed; inset:0` med mørk bakgrunn — en modal som dekker lerretet. Klikk utenfor lukker |
| Avslå-dialogen | `window.prompt` (:69176) |

Kort: **044 lagret aldri hva Kenneth bestemte**, bare hva kunden sendte. Alt Kenneth gjør i
panelet forsvinner ved neste innlasting, og lenka lever til han trykker en knapp han ikke vil
trykke.

## STEG 0

1. Åpne et prosjekt med besvart forslag → Godkjenn ett rom → last siden på nytt → bekreft at
   panelet åpner igjen med rommet «ubehandlet» og at utlegget i rommet **er** byttet (dobbelt
   utlegg-risiko ved nytt Godkjenn? Mål: `_clearRoomProductCollections` rydder først — bekreft).
2. `kundelenke_get` på en lenke med `status='applied'` → returnerer `null` (migrasjonen sier det).
   Bekreft at kundens åpne side da faller tilbake til ren presentasjon (`_forslagStart` :7445
   returnerer `false` → `?present=` virker fortsatt). Det er ønsket oppførsel.
3. Mål hvor `.room-item`-radene bygges i `renderSidebar` (:44002 → rom-rader med `room-nm`), og
   hvilket element som er «prosjektinfo oppe til venstre» (`_renderSbProjInfo` :55098,
   `#spi-kundesvar`, `#spi-forslag`).
4. Hva gjør `_restoreRoomProductSnapshot` med `multiCableGroup`/soner — kan den brukes som
   «Angre dette rommet» etter en godkjenning? (054 legger flerkabel inn i godkjenningen.)

## Gjør

### 1. Beslutningene lagres i databasen — med én gang

- Hver **Godkjenn** og **Avslå** skriver umiddelbart til `kundelenker.applied_result` (finnes,
  jsonb): liste `[{ roomId, roomName, status: 'godkjent'|'avslaatt', grunn?, at, by,
  resultat? }]` der `resultat` for godkjent er det som faktisk ble lagt (`productId`,
  `cableCount`, `W`, `wm2`, `cc`) lest fra rommet etter motoren. Merge per `roomId` (siste vinner).
  `by` = `_currentProfile.full_name` eller e-post.
- `_forslagRevState.behandlet` **seedes fra `applied_result`** når panelet åpnes
  (`openKundeForslagPanel` :69052) — ikke tom Map.
- **Ferdig-regel:** når alle rader som ikke er `ok` har en beslutning → `status = 'applied'`,
  `applied_at = now()` settes **automatisk**, toast «Forslaget er ferdig behandlet». Ingen
  e-post sendes av dette. Rader med `ok: true` og rader der rommet ikke finnes lenger teller som
  behandlet.
- **«Send svar til kunden» blir valgfri:** knappen står i vinduet fra første beslutning, heter
  «Send svar til kunden (valgfritt)», sender `forslag_svar` som i dag (edge-funksjonen leser
  `applied_result` — bekreft at `status='applied'` ikke stopper den: `_kreverInnlogging`-veien,
  ikke `kundelenke_get`). Etter sending: ny kolonne `svar_sendt_at timestamptz` (idempotent
  migrasjon `supabase-migration-kundeforslag-053.sql`) → knappen viser «Svar sendt 10. okt».
- `_fetchKundeStatus` (:67048) henter bare `open`/`answered` → merket i lista forsvinner av seg
  selv ved `applied`. `_kundeRefreshStatus` (:8810) beholder i tillegg **nyeste `applied`
  forslag** i `_forslagSisteCache`, så prosjektinfo kan vise raden
  «✓ Forslag behandlet 10. okt · Se forslaget» (åpner vinduet lesende, alle rader med sin
  beslutning). 055 bytter «Se forslaget» til «Se logg».
- `_kundeMaybeOpenReview`: åpner bare når det finnes **ubehandlede** rader (ikke bare
  `answered`).

### 2. Vinduet: flyttbart, ikke-modalt, lerretet synlig

- `#fors-rev-ov` blir et **vindu** (`position:fixed`, bredde 440 px, maks høyde 70 vh, ingen
  bakdropp, `z-index` over ctxbar), standardplassering **høyre side** med 16 px marg, dras i
  tittellinja (pointer events, klem til viewport). Plasseringen huskes i `sessionStorage`
  (ikke i prosjektet). Lerretet og sidepanelet er klikkbare samtidig.
- Tittellinje: «Kundeforslag · Fra Ola Nordmann · 9. okt» · **▾** (minimer til brikke
  «💬 Kundeforslag · 3 igjen» nederst til høyre, klikk gjenåpner) · **✕** (lukk — flaggene i
  romlista står igjen, §3).
- Romlista i vinduet er **én rad per rom** (ikke tabell med fire kolonner — for smalt): romnavn
  i fet + status-merke til høyre; under: «Nå: InFloor 10T 600W · 68 W/m² · CC 14,7» og
  «Kunden foreslår: InFloor 10T 800W · 92 W/m² · CC 11» + kommentaren i kursiv. Valgt rad får
  rav venstrekant. **Klikk på raden** → `S.ui.selectedRoomId = roomId; fitRoom(roomId)`
  (:44932) `; renderSidebar(); render();` — rommet markeres og fyller lerretet. Piltaster ↑/↓ i
  vinduet bytter rom; **Enter = Godkjenn**, **Esc = lukk**.
- Knappene for valgt rad: **Godkjenn** · **Avslå** · (etter godkjenning) **Angre** ·
  **Neste →**. Godkjenn kjører `_forslagGodkjennRom` som i dag (motoren, ett `pushUndo`), og
  fordi rommet alt står i bildet ser Kenneth utlegget skifte. Raden får så en linje
  «Ble: InFloor 10T 800W · 94 W/m² · CC 10,8» (regnet av det som faktisk ligger der —
  `_computeRoomStats`), slik at forslag og resultat kan sammenlignes. **Angre** = det samme som
  Ctrl+Z for det rommet (`_restoreRoomProductSnapshot` fra `førProdukter`, STEG 0.4) og fjerner
  beslutningen (også i `applied_result` — og `status` tilbake til `answered` hvis den var
  `applied`).
- **Avslå** åpner et felt **i raden** (ikke `window.prompt`): tekst med tre hurtigvalg
  («Beholder dagens — gir jevnere varme», «For høy effekt for rommet», «Produktet passer ikke
  her») + fritekst, Lagre/Avbryt. Begrunnelsen går til kunden kun hvis svar sendes (§1).
- «Godkjenn alle (N)» beholdes nederst, ett `pushUndo`, deretter samme lagring per rom.
- Vinduet kan **ikke** lukkes ved klikk utenfor (det er nå lerretet).

### 3. Kundeønske i romlista og egen rute

- `renderSidebar`: rom med **ubehandlet** kundeønske får et blått merke på raden
  (`.room-item.kundeonske`: venstrekant 3 px `#4fa2b8` + «💬» etter navnet, tooltip «Kunden
  foreslår InFloor 10T 800W — klikk for å se»). Behandlet → merket vekk. Rom med `ok: true` → ingen
  merke.
- Når et slikt rom er **valgt** (uansett om vinduet er åpent), vises en **rute «Kundeønske»** i
  sidepanelets rom-del, rett under romnavnet: samme innhold som raden i vinduet (Nå / Kunden
  foreslår / kommentar) + **Godkjenn · Avslå · Åpne alle (3)**. Samme funksjoner som vinduet
  (`_forslagGodkjennKlikk`, `_forslagAvslaaKlikk`) — ikke en kopi av logikken. «Åpne alle»
  åpner vinduet.
- Etasje-toppen i romlista: «💬 3 kundeønsker» når det finnes ubehandlede på etasjen.

### 4. Tekster

- Toast etter Godkjenn: «Stue er lagt ut på nytt — Ctrl+Z angrer» (som nå).
- Toast når siste rom er behandlet: «Forslaget er ferdig behandlet. Vil du sende svar til
  kunden?» med knapp «Send svar» i toasten (valgfritt), ellers forsvinner den.

## Skal IKKE

- Endre kundens side (043) eller `kundelenke_answer`.
- Sende e-post automatisk ved `applied`.
- Endre motorene eller `_forslagGodkjennRom`s gjenopprettingslogikk utover Angre-knappen.
- Røre mål-panelet (028/037) — det har sin egen vei.

## Test

1. Besvart forslag med 3 rom → åpne prosjekt → vindu til høyre, lerretet synlig. Klikk rom 1 →
   rommet fyller lerretet og er valgt i sidepanelet. Godkjenn → utlegget skifter i bildet, raden
   viser «Ble: …». Last siden på nytt → vinduet åpner med rom 1 **godkjent**, 2 og 3 ubehandlet;
   rom 1 har ikke dobbelt utlegg.
2. Avslå rom 2 med hurtigvalg, Godkjenn rom 3 → toast «ferdig behandlet» → `status='applied'`,
   `applied_at` satt. Prosjektlista: merket «💬 Forslag fra kunde» **borte**. Prosjektinfo:
   «✓ Forslag behandlet 10. okt · Se forslaget». Last på nytt → **ingen** vindu åpner.
3. Angre på rom 3 → utlegget tilbake, raden ubehandlet, `status` tilbake til `answered`, merket
   tilbake i lista.
4. Lukk vinduet med ✕ mens 2 rom er ubehandlet → romlista viser 💬 på de to; klikk ett → ruten
   «Kundeønske» i sidepanelet; Godkjenn derfra virker og fjerner merket. «Åpne alle» åpner vinduet.
5. Dra vinduet til venstre → plassering huskes ved neste åpning i samme økt. Minimer → brikke →
   klikk → tilbake. Klikk på lerretet lukker **ikke** vinduet.
6. «Send svar til kunden (valgfritt)» → e-post som før; knappen viser «Svar sendt …».
   Kundens forslagsside etter `applied` → ren presentasjon (STEG 0.2).
7. `_kundeforslagRegressionTest` utvidet: `applied_result` skrives ved første Godkjenn (kildesjekk
   på update-kallet i `_forslagGodkjennKlikk`), `behandlet` seedes fra `applied_result`, ferdig-regel
   setter `applied` uten `forslag_svar`, `_kundeMaybeOpenReview` åpner ikke når alt er behandlet,
   `fitRoom` kalles ved radklikk, `window.prompt` finnes ikke lenger i `_forslagAvslaaKlikk`.

## Rapport

STEG 0.1–0.4, hvilken kolonne/tabell du valgte for `svar_sendt_at`, og om Angre kunne bruke
`_restoreRoomProductSnapshot` som den var. Endringslogg. Oppdater `spec-kundeforslag.md` regel 7 og
legg inn regel 11–13 fra 000. Commit: «053: kundeforslag — beslutninger lagres per rom, ferdig
= applied uten e-post, flyttbart vindu med rom på lerretet, kundeønske i romlista».
