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
