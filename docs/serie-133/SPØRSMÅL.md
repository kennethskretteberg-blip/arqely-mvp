# 133 — spørsmål til Kenneth

1. **Estimat ≠ levering i 'v' (128-1 (b)).** Koordinatsaken er rettet, så 'h' leverer nå det
   velgeren estimerer. Men 900 × 300 med auto-retning velger fortsatt 'v' (estimat 24,5 mot 22,2 m²)
   og leverer 12,0 m² (24 m, 10 × 240, Regel E) der 'h' leverer 15,0. Skal velgeren (a) stå som den er,
   (b) velge på faktisk levering (begge retninger legges tørt, dyrere), eller (c) estimere med Regel E
   (N × L må gå opp i rullen)?
2. **Mattebenkens syntetiske frihånd (vei 4) i 'h'** er ulovlig i 29 rom før og etter, fordi benkens
   egen bane legger 'h'-breddene nedover fra nedre hjørne (`side: 1`), ikke på grunn av mattene. Skal
   benk-banen rettes (speile `side` for 'h' slik 'v' fikk `dir0 = −1`), slik at vei 4 måler noe for 'h'?

   **Svar (Kenneth 24.10):** Ja, rett benk-banen (speil `side` for 'h' slik 'v' fikk `dir0 = −1`). *Bygget i
   137 / A: `_matBenchRunVei4` leser hjørnet (`_matCornerFlags`) og speiler både `dir0` og `side0`, så 'h'-
   breddene legges oppover (inn i rommet) fra bunnveggen. Vei 4 ulovlige 30 → 15 ('h' 16 → 1); 'v' 14 uendret
   (annen årsak, se 137-rapporten). Vei 1–3 uendret. Rapport `docs/serie-136/RAPPORT.md` («## 137»).*
3. **↻ 90° på en klippet matte.** Knappen holder nå senteret og tar bredde-mønsteret med relativt
   (bredde 0 forblir «første», klippede ender beholder sin side langs blokka). Før roterte bildet
   bokstavelig (og tegnet da feil). Er «snu på stedet, samme mønster» riktig, eller skal en 90°-dreining
   også speile mønsteret som en fysisk rotasjon ville gjort?
4. **Forbandt (InSnow) på gamle vannrette matter:** etter migrering ankres halv-CC-forskyvningen fra
   motsatt ende, så strengene i odde bredder ligger speilet innad i bredden (nettet er identisk, EcoMat
   pikselidentisk). Godt nok, eller skal migreringen bære med et speilflagg for kabelplanen?
5. **Enkelt-matte-drag flytter ikke `runStarts`** (fantes før 133, gjelder 'v' òg). Skal mousemove
   bruke samme `_ROOM_TRANSLATE_SPEC`-vei som 108/127, så vakten og 127 ser matta der den tegnes?

   **Svar (Kenneth 24.10):** Ja, bruk 108-veien (`_ROOM_TRANSLATE_SPEC`) i mousemove. *Bygget i 137 / B:
   mousedown tar et startbilde av matta (`_matDragOrigMat`), og mousemove skriver alle feltene i
   `_ROOM_TRANSLATE_SPEC.mats` (x_cm/y_cm, runStarts, labelPos) som «original + delta» via
   `_translatedFieldsFor` (`_matDragApplySingle`) — delta regnes fra der matta faktisk endte etter klamp og
   magnet. Låst i `_matArrangementRegressionTest` (55 → 65).*
6. **`_renderRoomToImageOffscreen`** er død kode med den gamle tegneformelen. Slette?

   **Svar (Kenneth 24.10):** Slett. *Gjort i 137 / C: funksjonen (164 linjer) er borte; ingen kallere, ingen
   hjelpere som bare den brukte. PDF (`_pdfExportSmokeTest` 20/20) og presentasjon virker uten.*

   **Svar (Kenneth 24.10):** Godt nok. Ingen endring.

   **Svar (Kenneth 24.10):** OK — «snu på stedet, samme mønster» er riktig. Ingen endring.

   **Svar (Kenneth 24.10):** (c) — estimer med Regel E: N × L må gå opp i en rull. *Bygget i 136 / A:
   `_matDirCoverEstimateCm` regner Regel B/E/24/H tørt på boksen per retning (`ctx.rollLensCm` fra
   `autoFillMatSerpentine` og `_matRoomGeomForFill`); 900 × 300 → 'h' 15,0 m², 300 × 900 → 'v' 15,0, rect #10 → 'h'
   10,0. Regel 8-tallet er tie-break, så rom der begge leverer likt beholder retningen. Rapport `docs/serie-136/RAPPORT.md`.*

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

   **Svar (Kenneth 24.10):** Snapp til veggen også for kanter inne i rommet, samme `snapToWalls`-mekanisme.
   *Bygget i 136 / E: en kant inne i rommet innenfor én celle fra en ortogonal vegg som dekker hele kanten (rommet
   fortsetter helt til veggen, prøvepunkt) snappes ut; sonegrenser (delvis vegg) røres ikke. H-broa 300–500 →
   bredder 192 (var 168 / 176). Folie 9/9 uendret.*

   **Svar (Kenneth 24.10):** Låsen vinner, sonen utelates. *Bygget i 136 / D: `_matPlanZones` prøver ikke den andre
   retningen når `S.varmefolie.direction` er satt; sonen får `reason: 'dirLocked'` og panelet sier «utelatt:
   retning låst». Auto-retning som i 134.*

   **Svar (Kenneth 24.10):** Bare når stykkene faktisk havner i valgt rull, ellers `S.mats` bit-identisk. *Bygget i
   136 / C: `_matPlanZones` returnerer null for et rektangel når Σ hovedbredder + første stykke > valgt rull. Benk:
   rect #9 og smal #38 (bare «fra vegg»-variantene) går tilbake til S.mats-veien; hovedradene uendret.*

   **Svar (Kenneth 24.10):** Begrens til ett trinn: velg nest største rull bare når tapet er under én rullengde
   (neste rull ned). Ellers behold største rull og vis stubben gult. *Bygget i 136 / B: `_matChapterRollPlans`
   godtar den stubbfrie bare når Σ største − Σ stubbfri < katalogavstanden fra største rull til neste rull ned;
   ellers `equalStub`/`mixedStub` på den største og den stubbfrie som `equalLess`/`mixedLess` (panelrad «nest
   største, unngår stubben»). De fem benkrommene taper nøyaktig ett trinn (2 m) → tilbake på største rull:
   77,6 → 84,1 %, 69,0 → 80,5, 75,8 → 85,3, 79,0 → 85,6.*

# 135 — spørsmål til Kenneth

1. **Stykke 2 av hopp-streken.** Regelen «først langs veggen bredden slutter mot, så inn til
   startpunktet» gir i bilde 2 (5 bredder i hoveddelen) en strek langs V1 til x = 303 og så rett ned
   *gjennom bredde 6* til startpunktet nederst i alkoven. Skal stykke 2 heller legges langs kanten av
   den nye bredden (x = 278 − mellomrom, utenfor nettet), eller er «gjennom nettet» greit siden den
   bare er orientering?

   **Svar (Kenneth 24.10):** Langs kanten av den nye bredden (utenfor nettet, mellomrommets avstand). *Bygget
   i 137 / D: `_matJumpLinkRoute` legger stykke 2 ved kant − mellomrom på A-siden av den nye bredden, fram til
   startpunktets langs-koordinat, så et kort stykke inn til B. Bilde 2: (252, 8) → (277, 8) → (277, 196) →
   (303, 196). Hopp midt i rommet: rett strek som før. Rundt et hjørne: som i 135. Plan og PDF, samme tegner.*
2. **Grid-dekomponeringen** ble rettet for kanter som stakk *utenfor* veggen (halvcentimeter-vegger),
   fordi A ellers hadde avvist auto-utlegg i T-19/T-20/U-22. Kanter som ligger *inne* i rommet (134-4,
   1–4 cm tapt) står fortsatt. Skal 134-4 tas nå, med samme `snapToWalls`-mekanisme (snapp også
   innover-kanter til veggen når de ligger innenfor én celle)?
3. **Rødmerking av alle bredder** (ikke bare justerte) viser også lagrede baner som ble lovlige under
   den gamle 1 cm-toleransen og baner der en hindring er lagt til etterpå. Riktig at de står røde til
   brukeren flytter dem, eller skal baner lagret før 135 få en engangsmigrering (klem inn ≤ 1 cm)?

   **Svar (Kenneth 24.10):** Engangsmigrering: klem inn ≤ 1 cm ved innlasting, ikke røde. *Bygget i 137 / E:
   `_restoreProject` kjører `_matPathsMigrateMarginV2` én gang per prosjekt (`project.matPathMarginV < 2`,
   stemples ved lagring). På tvers flyttes hele banen bort fra veggen, langs kortes startenden via `startCm` og
   sluttenden via `len` (kaskaden følger kjeden). Mer enn 1 cm feil, hindring, utenfor rommet eller for nær på
   begge sider: urørt og rød som i 135. Konsollen logger antallet, toast «N matte-baner ble justert ≤ 1 cm til
   dagens veggmargin», ingen autolagring før brukeren gjør en endring.*
4. **«Tøm og fyll» tømmer bare matter** (`mats` + `matPaths`); folie/kabel/plater i rommet står. UPC-auto
   tømmer alt. Skal valget tømme alle produkter i rommet som UPC, eller bare matter som nå?

   **Svar (Kenneth 24.10):** OK som nå (bare matter). Ingen endring.


   **Svar (Kenneth 24.10):** Ja, ta 134-4 nå med samme mekanisme. *Bygget i 136 / E, se 134-4.*