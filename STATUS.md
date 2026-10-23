# Status – Varmeplan (nettsiden)

Oppdateres på slutten av hver økt. Leses av prosjektoversikten.

- **Prosjekt:** Varmeplan (nettsiden)
- **Mappe:** `~/Code/varmeplan-web`
- **Fase:** bygger
- **Sist oppdatert:** 24.10.2026
- **Sist gjort:** 133: vannrett matte — én koordinatkonvensjon (x_cm/y_cm = blokkas lave hjørne for 0° og 90°, 90° = transponering) via `_matFrame`/`_matRunWorldGeom` for motor, klipp, tegning, treff, rødmerking, klamp, målkjede, gizmo og PDF; `autoFillMatSerpentine` sin 'h'-gren rettet (totalW/L var byttet); `_matMigrateCoordV2` ved innlasting (gamle 90°-matter pikselidentiske, to prosjekter verifisert med canvas-hash); `_matSetRotationDeg` holder senteret; ny `_matRotationRegressionTest` 35/35 (vaksinert); benk: 29 'h'-rader opp (rect #10 8,0 → 10,0 m² = estimatet), 6 InSnow-rader ned fordi de før telte nett utenfor rommet, ingen 'v'-rad endret, lovlige 195/195. Committet på `main`, ikke pushet (127–132 heller ikke).
- **Neste steg:** Kenneth svarer på `docs/serie-133/SPØRSMÅL.md` (estimat ≠ levering i 'v' = 128-1 (b), benkens vei 4 i 'h', ↻ 90°-semantikk, forbandt på migrerte matter, enkelt-drag og `runStarts`, død offscreen-tegner) og `docs/serie-128/SPØRSMÅL.md` (128–132), og om 127–133 skal pushes. Spørsmålene i `docs/serie-127/RAPPORT.md`, `docs/serie-122/RAPPORT.md` og `docs/serie-119/SPØRSMÅL.md` står fortsatt.
- **Blokkert av:** ingenting
- **Live:** https://varmeplan.no
