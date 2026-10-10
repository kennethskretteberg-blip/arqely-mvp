# SPØRSMÅL — serien Kundeforslag 2 (053–055)

Claude Code: legg spørsmål under riktig prompt mens du kjører, med valget du tok i mellomtiden.
Kenneth svarer til slutt.

## Avklart av Kenneth før start (10.10.2026)

- Presentasjonen og forslagskortet hos kunden ser bra ut — ingen endring der utover stigen (054).
- Godkjenn + lukk skal være nok. «Send svar til kunden» skal **ikke** være påkrevd.
- Gjennomgangen skal skje på lerretet med rommet synlig, rom for rom.
- Rom med kundeønske skal være merket i romlista; vinduet kan krysses vekk.
- Logg over hele dialogen, med alle runder.

## Til Kenneth (ubesvart)

- **053:** Når siste rom er behandlet og forslaget blir «ferdig» — skal kunden få en automatisk
  kort e-post («Vi har gått gjennom forslaget ditt»), eller bare når du trykker «Send svar»?
  (Prompten sier: bare ved knappen.)
- **054:** Tak på antall like kabler i kundens stige — 3 (prompten) eller flere? Ved 4–6 kabler
  er fasebalanse (3/6) et poeng motoren alt kjenner; skal kunden se det?
- **054:** Skal kortet si «To kabler → to kurser/termostatutganger»? (Elektriker-kunder forstår
  det; sluttkunder kanskje ikke.)
- **054:** Rom uten varme — folie som tredje valg, eller bare kabel/matte som du sa?
- **054:** Skal kunden kunne foreslå varme i rom Varmeplan har satt til «ingen varme» med vilje
  (bod, lager), eller bare i rom som rett og slett ikke er prosjektert ennå? (Prompten: alle
  innendørs rom uten produkt, unntatt snø og fryserom.)
- **055:** Skal loggen også kunne eksporteres til PDF-rapporten (vedlegg «Kundedialog»), eller
  holder kopier-som-tekst?
- Fra forrige serie, fortsatt ubesvart: **Godkjenn hele prosjektet — formelt eller signal?**

## 053

- **STEG 0 bekreftet alt, og svarte på parentesen:** to påfølgende Godkjenn gir **1 kabel, ikke
  2** — `_clearRoomProductCollections(roomId, ['cables'])` rydder før motoren kjører. Dobbelt
  utlegg var aldri risikoen; tapt beslutning var det.
- **`svar_sendt_at` ble en ny kolonne på `kundelenker`**, ikke et felt inni `applied_result`.
  Grunnen: `applied_result` er en liste per rom, og «når ble svaret sendt» gjelder hele lenka.
  Migrasjon: `supabase-migration-kundeforslag-053.sql` (idempotent, ren ASCII).
- **Angre kunne bruke `_restoreRoomProductSnapshot` som den var.** `_forslagGodkjennRom` brukte
  allerede nøyaktig det samme paret på feil-veien, `_cloneRoomProductItem` tar `{...item}` så
  `multiCableGroup`/`multiCableIndex` følger med, og soner/hindringer ligger ikke i
  `ROOM_PRODUCT_KEYS` og røres aldri. Eneste endring: snapshotet tas og BEHOLDES ved suksess
  (det ble før forkastet).
- **Én ekte feil funnet ved kjøring:** etter «Send svar» blir lenka `applied`, og
  `_kundeRefreshStatus` plukker bare open/answered → `_forslagLinkCache` ble **null**, og
  vinduets re-render krasjet på `k.answered_by_name`. `_forslagSisteCache` bærer den nå videre.
- **«Avslå» fra romlista åpner vinduet** på det rommet i stedet for å bygge et eget
  begrunnelsesfelt i sidepanelet — ellers ville det vært to felt å vedlikeholde. Si fra om du
  heller vil ha det inline i sidepanelet.

## 054

-

## 055

-
