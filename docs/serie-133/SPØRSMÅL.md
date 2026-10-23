# 133 — spørsmål til Kenneth

1. **Estimat ≠ levering i 'v' (128-1 (b)).** Koordinatsaken er rettet, så 'h' leverer nå det
   velgeren estimerer. Men 900 × 300 med auto-retning velger fortsatt 'v' (estimat 24,5 mot 22,2 m²)
   og leverer 12,0 m² (24 m, 10 × 240, Regel E) der 'h' leverer 15,0. Skal velgeren (a) stå som den er,
   (b) velge på faktisk levering (begge retninger legges tørt, dyrere), eller (c) estimere med Regel E
   (N × L må gå opp i rullen)?
2. **Mattebenkens syntetiske frihånd (vei 4) i 'h'** er ulovlig i 29 rom før og etter, fordi benkens
   egen bane legger 'h'-breddene nedover fra nedre hjørne (`side: 1`), ikke på grunn av mattene. Skal
   benk-banen rettes (speile `side` for 'h' slik 'v' fikk `dir0 = −1`), slik at vei 4 måler noe for 'h'?
3. **↻ 90° på en klippet matte.** Knappen holder nå senteret og tar bredde-mønsteret med relativt
   (bredde 0 forblir «første», klippede ender beholder sin side langs blokka). Før roterte bildet
   bokstavelig (og tegnet da feil). Er «snu på stedet, samme mønster» riktig, eller skal en 90°-dreining
   også speile mønsteret som en fysisk rotasjon ville gjort?
4. **Forbandt (InSnow) på gamle vannrette matter:** etter migrering ankres halv-CC-forskyvningen fra
   motsatt ende, så strengene i odde bredder ligger speilet innad i bredden (nettet er identisk, EcoMat
   pikselidentisk). Godt nok, eller skal migreringen bære med et speilflagg for kabelplanen?
5. **Enkelt-matte-drag flytter ikke `runStarts`** (fantes før 133, gjelder 'v' òg). Skal mousemove
   bruke samme `_ROOM_TRANSLATE_SPEC`-vei som 108/127, så vakten og 127 ser matta der den tegnes?
6. **`_renderRoomToImageOffscreen`** er død kode med den gamle tegneformelen. Slette?

# 134 — spørsmål til Kenneth

1. **Stubbvalget koster dekning i benken.** Fem rom faller 6,5–11,5 % (26 → 24 m, 14 → 12 m, 18 → 16 m)
   fordi den største rullen endte 8 cm (én 150T-streng) inn i en bredde. Står det slik — eller skal
   stubbvalget bare gjelde når nedgangen er under én rullengde / når det finnes en rull imellom? I alle
   fem er den større rullen ett klikk unna i panelet.
2. **Rektangel uten plass til stykkene i rullen.** 300×400 «fra vegg» med 100T: tverrstykkene planlegges
   (7 × 24), men 20 m ender 8 cm inn i stykke 4, så 18 m velges og ingen stykker legges — rommet får 5 × 384
   + 264 cm i stedet for `S.mats`-veiens 5 × 360, samme 9,0 m². Skal et rektangel bare gå til kapittelbanen
   når stykkene faktisk havner i den valgte rullen (ellers `S.mats` bit-identisk), eller er det greit at
   bildet endrer seg med lik dekning?
3. **Retningslås og E.** Når brukeren har låst retningen og en sone avvises av Regel 27-vakten, prøves
   likevel den andre retningen (tverrstykkene legges uansett på tvers). Riktig, eller skal låsen vinne og
   sonen utelates?
4. **Grid-dekomponeringen** gir sonerektangler 1–4 cm inne i de ekte veggene (H-rommets bro 300–500 → 301–497:
   168 cm bredder der 192 får plass). Skal `_decomposeRoomToRects` snappes til polygonets kantkoordinater
   for ortogonale rom (samme kompresjon som `_matFreeFieldRects`), eller er tapet akseptabelt?
