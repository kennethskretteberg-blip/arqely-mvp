# 136 — spørsmål til Kenneth

1. **«Ett trinn» er tolket strengt (B).** Den stubbfrie rullen velges bare når tapet (Σ største − Σ stubbfri) er
   *mindre enn* katalogavstanden fra største rull til neste rull ned. Med like ruller er tapet alltid K × trinnet,
   så for én rull er det nøyaktig ett trinn og aldri «under» — den største beholdes alltid, med gul stubb. Bare en
   blandet plan med en finere rull under den største (f.eks. 24 + 6 m → 24 + 5 m med trinn 2 m) kan havne under.
   Var det meningen (= «stubbvalget er i praksis borte, stubben vises gult»), eller skal ett trinn ned (nest største
   rull, tap = trinnet) fortsatt velges, og bare to eller flere trinn avvises? Da ville de fem benkrommene stått
   på 24/12/16/24 m som i 134.
2. **C-bestillingen forutsatte 134 / B.** «300 × 400 «fra vegg» 100T → S.mats 5 × 360» gjaldt da 18 m ble valgt. Med
   ett-trinn-regelen beholdes 20 m, og da kommer stykkene med (19,20 + 0,24 ≤ 20 m) → kapittelbanen med 3 hele
   stykker + 8 cm stubb, 10,0 m². Riktig at B vinner her (regelen er låst to andre veier: auto-retning 'h' og en
   16/18 m-katalog gir S.mats)?
3. **Fallbackens korte siste bredde vrakes utenfor rasteret** (funnet i STEG 0): 900 × 300 'v' med 28 m gir 16 × 168
   + 112, men `_matClipRunToRoom` flater 112 → 96 og vraker den under minstelengden 100, så Regel H går ned til 24 m.
   Regel 24 sier «siste tar resten». Skal den korte siste få ligge på nærmeste raster *under* (96, selv om det er
   under minstelengden — den er en del av samme bredde-sekvens), eller på resten eksakt (112, utenfor rasteret)?
   Velgeren (A) speiler dagens oppførsel, så den er riktig uansett.
4. **A i flermatte-domenet.** Retningen estimeres med én rull også der rommet trenger flere (kapasitet > største
   rull → `_matMultiSolve`). I benken ble alle slike uavgjort (begge retninger legger hele største rull) og Regel 8-
   tallet avgjorde som før. Skal flermatte-veien få sitt eget estimat (K ruller, `_matMultiSolve` tørt per retning),
   eller er «uendret» godt nok?
5. **Delvise vegger (E).** T-20s hoveddel ligger 2 cm fra underveggen, men veggen dekker bare sidene av stammen —
   kanten er vegg og sonegrense samtidig, og røres ikke (stammens kapittel bruker plassen via Regel 27). Skal en
   slik kant deles (snapp der veggen er, sonegrense der stammen er), eller er 1–3 cm i fem benkrom greit?
6. **InSnow-retningen i vei 3** (grense-minlengde #51, 232 × 113): A snudde den fra 'v' 4 × 112 (336 av 400 cm lagt)
   til 'h' 2 × 208 (hele rullen). `_packSnowMats` leser `_matRoomGeomForFill`, så snø-auto følger den nye velgeren.
   Ønsket, eller skal utendørs beholde Regel 8-tallet?

# 137 — spørsmål til Kenneth

1. **Vei 4 'v' står på 14 ulovlige (og 1 'h') etter A.** Alle er L/T/U-rom, hindringsrom og fasit-rommene
   1102/1108/L-rommet: benkens syntetiske bane legger N bredder i FULL lengde (`floor(alongSpan / raster)`
   fra boksen) og klipper ikke mot utsparinger og hindringer slik en ekte frihånds-økt gjør
   (`_matFreeClampLen` per bredde). Skal benk-banen klippe hver bredde som appen (da måler vei 4 noe i
   uregelmessige rom òg), eller er «vei 4 = rektangler» godt nok?
2. **Frihånds-matte-drag flytter bare `start`,** ikke `labelPos` (`_ROOM_TRANSLATE_SPEC.matPaths` har begge).
   Samme sak som 133-5, bare for frihånd: skal matpath-grenen i mousemove også gå 108-veien, så labelen
   følger matta ved flytting (som den gjør i 127 «flytt alle»)?
3. **Migreringen gir lengder utenfor kuttrasteret** (384 → 383,7 når sluttenden lå 0,3 cm inne i marginen).
   Katalogvalget er upåvirket (rullen er ≥ Σ), men «Dekker» viser nå 25,97 m i stedet for 26,0. Greit — eller
   skal klemmingen gå ned til nærmeste raster under (inntil 24 cm kortere, synlig udekket)?
4. **Toast i `?present=`/`?kunde=`.** Migreringen kjører også der (bare i minnet, lagres aldri), og toasten
   «N matte-baner ble justert …» vises for kunden. Skal den undertrykkes i kunde-/presentasjonsmodus?
5. **Stempelet skrives først ved neste lagring.** Et prosjekt som bare åpnes (aldri endres) migreres på nytt
   ved hver åpning — idempotent, ingen toast andre gang (ingenting igjen å klemme). Greit, eller skal
   migreringen alene få lov til å lagre stempelet (bryter «ingen autolagring før brukeren gjør en endring»)?
