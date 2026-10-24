# Status – Varmeplan (nettsiden)

Oppdateres på slutten av hver økt. Leses av prosjektoversikten.

- **Prosjekt:** Varmeplan (nettsiden)
- **Mappe:** `~/Code/varmeplan-web`
- **Fase:** bygger
- **Sist oppdatert:** 24.10.2026
- **Sist gjort:** 137: matte — Kenneths svar på serie-133 (resten): benk vei 4 speiler `side` etter hjørnet ('h'-bredder legges inn i rommet; vei 4 ulovlige 30 → 15, 'h' 16 → 1), enkelt-matte-drag flytter alle feltene i `_ROOM_TRANSLATE_SPEC.mats` (runStarts/labelPos) via `_translatedFieldsFor` (`_matDragApplySingle`), `_renderRoomToImageOffscreen` slettet (164 linjer), hopp-streken går langs kanten av den nye bredden (kant − mellomrom, `_matJumpLinkRoute` med `nextRun`), engangsmigrering av frihånds-baner ≤ 1 cm inne i veggmarginen ved innlasting (`_matPathMigrateMarginV2`, `project.matPathMarginV: 2`, toast, ingen autolagring); `_matPathRunMarginShort` er én måler for rødmerking og migrering. Tester 36→44 / 55→65, benk 209 uendret, 15 opp (alle vei 4), 0 ned. Committet på `main`, ikke pushet (127–136 heller ikke).
- **Neste steg:** Kenneth svarer på `docs/serie-136/SPØRSMÅL.md` (136-1…6 og 137-1…5: vei 4 i uregelmessige rom, frihånds-label ved drag, lengder utenfor raster etter migrering, toast i kunde-/presentasjonsmodus, stempel uten lagring), og om 127–137 skal pushes. 137 / E STEG 0 (telling i Kenneths egne prosjekter) kunne ikke kjøres uten innlogging — konsollsnutt i `docs/serie-136/RAPPORT.md`. Spørsmålene i `docs/serie-127/RAPPORT.md`, `docs/serie-122/RAPPORT.md` og `docs/serie-119/SPØRSMÅL.md` står fortsatt.
- **Blokkert av:** ingenting
- **Live:** https://varmeplan.no
