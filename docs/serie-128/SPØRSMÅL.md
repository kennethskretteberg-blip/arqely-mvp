# 128 — spørsmål til Kenneth

1. **Retningsvalget etter 128.** Når marginen krymper får flere rom plass til én bredde til på
   tvers, og auto-velgeren bytter til vannrett ('h') fordi *estimatet* blir høyere. Men 'h'-veien har
   124-feilen (to koordinatkonvensjoner): rect #10 (420 × 259) leverer 8,0 m² i 'h' mot 8,96 i 'v', og
   matta får `y_cm = −30,5`. Skal jeg (a) rette vannrett matte i en egen prompt først (anbefalt — da
   blir 'h' faktisk bedre, slik estimatet sier), eller (b) la velgeren velge på *faktisk* resultat i
   stedet for estimat (dyrere, men immun mot slike avvik)?
2. **Frihånd-vakten** godtar en bane inntil 1 cm innenfor marginen langs banen, og sjekker ikke
   marginen på tvers (fantes før 128 — plasseringen holder marginen eksakt, så det slår bare ut hvis
   noen flytter banen manuelt). Skal vakten strammes til 0,1 cm og få tverr-sjekk?
3. **`min_wall_margin_mm`** betyr nå bare «0 = ute». Skal feltet omtolkes til kabelkravet (50/0 — det
   er det radene allerede inneholder) og evt. omdøpes `mat_cable_wall_mm`, med migrasjon og opprydding
   i reservekatalog + innlastingsstandard? Da kan en annen leverandør få et annet kabelkrav uten kode.
4. **Produktkatalogen (admin)** viser fortsatt kolonnen «5,0 cm» (DB-feltet). Skal den vise den
   effektive nettmarginen (2,5/3,0) for matte, eller kabelkravet?

# 129 — spørsmål til Kenneth

1. **Forbindelsens strek.** Nå tegnes den rett fra forrige ende til nytt startpunkt (slik Regel 28 pkt. 2
   sier). I bildet ditt limes kabelen langs veggen. Skal streken rutes langs nærmeste vegg (to rette
   stykker) for å ligne monteringen, eller holde seg rett? Den teller uansett ikke.
2. **Snapp-avstanden.** Startpunktet snapper inntil forrige bredde (± mellomrom) og til 10 cm-raster
   innen ca. 14 skjermpiksler. Er 10 cm riktig raster, eller skal den følge kuttrasteret (24 cm for
   60T/100T, 16 cm for 150T) langs banen?
3. **Hopp uten H.** I dag må du trykke H / «Hopp» / Shift. Vil du i tillegg at et vanlig klikk langt
   fra fri ende (der ingen U-sving/90° gir mening) skal tolkes som hopp automatisk? Jeg lot det være,
   fordi et slikt klikk i dag avslutter banen («tilgivende avslutning»), og jeg ville ikke endre den
   uten å spørre.

# 130 — spørsmål til Kenneth

1. **Langsaksen også?** Regel 27 pkt. 1 sier sonen aldri bestemmer hvor en bredde må stoppe, så jeg
   utvidet både på tvers (bilde 1) og på langs (alkove under hoveddelen: blå går opp til 1 cm under røds
   bredder). Er det riktig, eller skulle bare tvers-aksen få bruke nabosonen? Gevinsten på langs
   kommer bare når kuttrasteret og katalogen gir en lengre rull.
2. **Matter som alt ligger i rommet** regnes nå som naboer (Regel 27 pkt. 2: «andre matter»). «Fyll
   rom»-knappen i det gamle produktpanelet tømmer ikke rommet først — den legger nå rundt det som
   ligger der i stedet for oppå. Er det ønsket, eller skal «Fyll rom» alltid tømme først?
3. **Begge sider stoppet av en matte** (en sone klemt mellom to naboer): blokka ankres til den lave
   siden. Skal den heller sentreres mellom dem?
4. **Vannrett retning (128-1) før 131?** Auto-retning velger vannrett for hoveddelen i bilde 1 og for
   T-stammen, og den veien tegner matta forskjøvet. 130 unngår naboen der den *tegnes*, så det ser
   riktig ut, men stammen får 0 cm lagt. Anbefaler å rette 128-1 (a) før 131, så 131 ikke bygges oppå
   to koordinatkonvensjoner.
5. **Søyle i nabosonen:** en hindring som bare delvis blokkerer stripa stopper hele utvidelsen. Greit
   inntil videre, eller skal utvidelsen gå rundt den per bredde?

# 131 — spørsmål til Kenneth

1. **«Like» mot «blandet» ruller.** Begge velger først *antall* ruller etter Regel 22 pkt. 3 (K klatrer
   bare til resten er under korteste rull), så lengder. Det gir færrest ruller (Regel 11 pkt. 1), men
   kan koste litt dekning: Kenneth L-rom i benken (150T) får 24 m i én rull (1,92 m udekket) der to
   ruller (22 + 3 m) hadde dekket 25,0 m, og T #20 får «like» 2 × 32 m (32,0 m²) som standard der
   «blandet» (60 + 9 m) gir 32,5 m². Skal (a) det stå slik — færrest ruller er primært, brukeren ser
   begge tallene, eller (b) skal «blandet» også prøve K + 1 når det dekker mer, og/eller (c) skal
   standardvalget være det som dekker mest?
2. **Siste bredde under ett kuttintervall.** T-rommet (600×200 + stamme 200×300) gir Σ 29,76 m →
   28 m-rull og en siste bredde på 16 cm (24 cm raster for 100T). Regel 24 sier den da «faller bort»,
   men frihånd-katalogen leser rullen av banens lengde, så fjernes stubben leses biten som en 26 m-rull.
   Skal stubben (a) stå (hele rullen tegnet, som nå), (b) fjernes og rullen låses på biten
   (`productId` må da gå foran `_matFreeCatalog`), eller (c) skal rullvalget unngå planer som ender i
   en stubb under ett raster (velge nest største rull)?
3. **Geometri størst først, rekkefølge fra velgeren.** Med velgeren i alkoven la første versjon alkoven
   først og lot den (Regel 27) ta hele stripa over hoveddelen, som da ble tom. Nå regnes geometrien
   alltid størst først (som 130) og velgeren bestemmer bare hvor kabelen starter og hoppene. Er det
   riktig lesning av «retningsvelgeren bestemmer rekkefølgen»?
4. **Startende i senere kapitler.** Kapittel 2 starter i den ytterste bredden og enden som ligger nærmest
   der kapittel 1 sluttet (kortest løs kabel). I bilde 2 med 5 bredder i hoveddelen slutter bredde 5
   øverst, så bredde 6 starter øverst (hopp 51 cm) — i tegningen din (6 bredder) starter bredde 7
   nederst (hopp 200 cm). Skal senere kapitler heller følge velgeren konsekvent (alltid samme startende
   som bredde 1)?
5. **Panelet etter utlegg.** Resultatet er en frihånds-bane og får frihånd-panelet («Auto-matte (Regel 28)»:
   bredder, dekker, udekket, effekt, areal, mellomrom, sentrer, slett) — ikke auto-panelets «Kaldt
   felt/side», «Del så matta går opp» og Regel E-notene. Greit, eller skal noe av det løftes til banen?
6. **Rullvalget i panelet** viser to like rader («1 rull … (gir ingenting ekstra her)») når like og
   blandet er samme plan. Skal den andre raden skjules da?

# 132 — spørsmål til Kenneth

1. **Hva er «plass til en vanlig bredde»?** I motoren får en 61 cm bred stripe en vanlig loddrett bredde
   (50 + 1 mellomrom + 2,5 nettmargin = 53,5 cm), så bilde 2-stripa di ville aldri blitt tverrstykker her.
   Ditt regnestykke bruker 50 + 8 (nabo) + 5 (vegg) = 63 cm. Skal grensen for en vanlig bredde også regnes
   med 8 + 5 (da blir striper på 54–62 cm tverrlagt), eller står mellomrom + margin?
2. **Stubb der rullen slutter i et tverrstykke.** Variant A med 100T: 26 m-rullen slutter 8 cm inn i stykke 2
   — under to kabelstrenger. Samme sak som 131-2 (katalogen leser rullen av banens lengde). Skal (a) stubben
   stå, (b) rullvalget unngå å ende inne i et tverrstykke med rest under 2 × CC (nest største rull), eller
   (c) stubben fjernes når 131-2 (b) er avgjort?
3. **Kuttraster for stykkene.** Stykkene avrundes ned til kuttrasteret (2 × CC: 24/16 cm) som alle andre
   bredder — 44 cm rest gir 24 cm stykker (100T). «Ca. 55–60 cm» i en 61 cm stripe tyder på at du kutter
   per kabelstreng (CC). Skal tverrstykker få kutt per CC (24 → 36 cm i samme felt)?
4. **Rektangulære rom.** Regel 29 virker bare i sonerom (kapittelbanen). Et rektangulært rom med «fra vegg»
   har 30–41 cm slakk langs én vegg og ville kvalifisert, men det går S.mats-veien. Skal rektangulære rom
   med et kvalifisert restfelt gå over til kapittelbanen (resultatet blir da en `S.matPaths`-matte med
   frihånd-panelet), eller er det greit at Regel 29 bare gjelder sonerom?
5. **Restfelt der en vanlig bredde får plass** (benkrom hindring #30: 319 × 60 cm igjen etter at 131 utelot
   sonen med Regel 27). 132 lar det stå (logger). Skal 131 prøve den utelatte sonen i den andre retningen,
   eller skal 132 legge tverrstykker der likevel?
6. **Rekkefølge og ankring.** Tverrkapitlene kommer sist i banen (nærmest forrige kapittel først), stykkene
   stables sentrert når begge ender er vegg og inntil nabomatta når én ende er en matte — som 131. Og de
   legges alltid etter hovedbreddene, så det er stykkene som faller utenfor rullen. Riktig prioritet?
