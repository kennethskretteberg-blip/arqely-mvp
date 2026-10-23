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
