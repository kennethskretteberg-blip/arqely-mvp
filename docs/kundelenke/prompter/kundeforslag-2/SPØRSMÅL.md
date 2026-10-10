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

- **Taket er N ≤ 3**, som prompten foreslo. Med 3 er stigen i et 30 m² rom allerede 38 trinn.
  Si fra om du vil ha flere — fasebalanse (3/6) er en annen diskusjon, og motoren kjenner den
  alt; den hører etter min mening hjemme i ditt panel, ikke i kundens.
- **⚠ Terskelen måtte være mot N−1, ikke mot N=1.** Med terskel mot største enkeltkabel
  overlevde «3 stk 700 W = 2100 W» og ble det FØRSTE steget over 2000 W — tre kurser for 100 W
  mer, i stedet for din «2 stk 1100 W = 2200 W». Med riktig terskel er sekvensen nøyaktig din:
  2000 → 2200 → 2400 → 2600.
- **«To kabler → to kurser/termostatutganger» står der** (grå linje under tallene), men bare
  når N > 1. Si fra om det er for teknisk for en sluttkunde.
- **Folie er holdt utenfor** i «Foreslå varme», som du sa — bare Kabel og Matte.
- **Alle innendørs rom uten produkt** kan få forslag, unntatt snørom og fryserom. Jeg skiller
  altså ikke mellom «bevisst uten varme» (bod) og «ikke prosjektert ennå» — 052s `_planNoHeat`
  kunne brukt til det. Si fra om boder skal utelates.
- **Målt om leverandørfilteret holder anonymt:** `_upcScopeProducts` gir nøyaktig det samme
  innlogget og utlogget (44 kabler, 57 matter), inaktive er borte, og `_productVisibleToOrg`
  er med. Kunden ser altså bare det du selv kan velge.
- **Bøyeradius stanset ingen rader** i testrommet (32 mm krever 1,6 cm, smaleste CC var 5,0).
  Den stopper først ved svært tette utlegg.
- **⚠ `_famKeyOf` må kalles med `true` som andre argument.** Uten det splitter den navnet og
  gir «InFloor 10T 1100W» som «serie» — altså én serie per produkt. Prompten antok «10T · 17T»,
  og det stemmer, men bare med flagget.

## 055

-
