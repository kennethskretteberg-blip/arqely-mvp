# Status – Varmeplan (nettsiden)

Oppdateres på slutten av hver økt. Leses av prosjektoversikten.

- **Prosjekt:** Varmeplan (nettsiden)
- **Mappe:** `~/Code/varmeplan-web`
- **Fase:** bygger
- **Sist oppdatert:** 24.10.2026
- **Sist gjort:** 134: matte — Kenneths svar på serie-128 (motor): sone klemt mellom to matter sentreres (`_matZoneAnchorSide` `'mid'`), rullvalget hopper over planer som ender i en stubb under ett raster / under to strenger i et tverrstykke og viser den større som alternativ (`_matChapterStubAt`, `equalAlt`/`mixedAlt`), senere kapitler starter i velgerens ende (`_matChapterRunOrder`), rektangulære rom med kvalifisert restfelt går kapittelbanen (`zonePlan.single`), utelatt sone prøves i andre retning (`_matChapterBlock` `opts.dir`); snapp-feil i `_matZoneFreeRoom` rettet (hindring #30 84,0 → 94,5 %); svar skrevet inn i `docs/serie-128/SPØRSMÅL.md`, spec Regel 11/24/27/28/29; tester 22/22 + 30/30; benk: 2 opp, 10 ned (alle stubbvalget). Committet på `main`, ikke pushet (127–133 heller ikke).
- **Neste steg:** Kenneth svarer på `docs/serie-133/SPØRSMÅL.md` (133-1…6 og 134-1…4: stubbvalgets dekningstap i benken, rektangel når stykkene faller utenfor rullen, retningslås mot E, grid-dekomponeringens cm-tap), og om 127–134 skal pushes. Spørsmålene i `docs/serie-127/RAPPORT.md`, `docs/serie-122/RAPPORT.md` og `docs/serie-119/SPØRSMÅL.md` står fortsatt.
- **Blokkert av:** ingenting
- **Live:** https://varmeplan.no
