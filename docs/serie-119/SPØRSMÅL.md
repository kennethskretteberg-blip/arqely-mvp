# SPØRSMÅL · serie 119 · 120 · 121

## 119 · Presentasjon, oppfølging

1. **Mållenka (`?kunde=`) på det nye panelet** står igjen (117/1: «senere»). Ikke rørt i 119.
2. **Innlogget presentasjon** (din egen ▶ Presentasjon-knapp) skjuler også produktmålene — gaten er
   «presentasjon», ikke «offentlig lenke», fordi det er kunden som ser den skjermen. Editoren og PDF-en
   viser dem som før. Si fra om din egen presentasjon skal beholde kjedene.
3. **«Følger»-vegger:** når du krysser bort en vegg og arbeider inn de andre, kan den likevel endre seg
   som følge av geometrien — som i mållenka, og som «Blir»-kolonnen viser (målt: vegg 3 i Vestre Hals
   gikk 215 → 203 cm uten å være avkrysset; kunden hadde sagt 205). Det er ikke kundens tall som
   brukes, men rommet lukkes. OK, eller skal vinduet advare når en bortkrysset vegg flytter seg?
4. **Status etter delvis innarbeiding:** én innarbeiding (to av tre vegger) gir protokollraden
   «innarbeidet» og «✓ Innarbeidet» i målblokka, med «Vis målene» for å åpne tabellen igjen og ta
   resten. Rommene fra flere innarbeidinger slås sammen i samme rad. Alternativet var «delvis»-status;
   jeg valgte det minste.
5. **Merket uten signatur** (satt av 118 før denne endringen) står til du klikker det bort — vi vet ikke
   hvilke produkter rommet hadde da. Gjelder bare prosjekter som fikk merket i dag.
6. **Test L var rød på HEAD** når batteriet kjøres i editoren (grønn i en levende forslagslenke):
   seksjon C etterlot en fast `#_fors-bunn`. Rettet i testen (L kaller bunnlinje-tegneren selv), ikke i
   appen.

## 120 · Trapp, svar på serie-104

1. **STEG 0 avvek fra premisset:** sonene startet allerede fra venstre, alle sammen (sonens første flate har
   ingen innkommende forbindelse, og tegningen begynner da fra venstre). Det som fulgte paritetskjeden var
   kjeden INNE i neste sone: ved oddetall strenger (CC 13 → 3 per trinn) forlot flate 3 sonen til høyre og
   flate 4 ble møtt fra venstre — et sidebrudd. Rettet ved å starte kjeden på nytt ved hver sonegrense. Med
   partall strenger (104-trappa) endres ingenting (10 036,8 cm, bit-identisk).
2. **Et eldre avvik jeg IKKE rettet:** `_stairCableEndpoints` (098, «én kilde» for start/slutt) leser
   `run.isGoingRight`, som er `ri % 2` uten paritet. For en kabel hvis SISTE flate møtes fra høyre (f.eks. to
   flater à 3 strenger) sier den at kabelen slutter til høyre, mens tegningen slutter til venstre. Gjelder
   trapper med og uten soner, og å rette det ville endret sluttmarkøren i trapper uten soner («Skal IKKE»).
   Si fra om du vil ha det rettet (det er én linje: les inngangssiden fra paritetskjeden).
3. **Auto-grensen for én kabel i en sone er ikke 75 %:** målt i `_stairSolveExactCableSet` med `maxCables: 1`
   er taket `maxSaneMargin` = min(halve smaleste flate − 1, gulv + 15 cm). 75 %-regelen (Regel 19) gjelder
   én-kabel-FORSLAGET i det frie søket. Jeg lot grensen stå (å bytte den ville endret eksisterende soner) og la
   to-kabel-fallbacken bak den. Skal sonens én-kabel-grense flyttes til 75 %?
4. **Hengelåsens plass på trappenivå:** feltet «Avstand sider» har alltid et tall (det er også gulvet), så
   «tomt felt» finnes ikke der slik det gjør i sonen. Jeg la en 🔒/🔓-knapp ved feltet: lås på = tallet brukes
   nøyaktig; tøm feltet eller trykk 🔓 = tilbake til auto (gulvet står). Si fra om du heller vil ha sonens form
   (tomt = auto, tall = låst) også her — da må gulvet få et eget felt.
5. **Låst margin og «Antall kabler»:** står det et tall i «Antall kabler», søker Forslag bare blant sett med
   så mange kabler (Regel 18), også med lås. Et valgt forslag som ikke passer eksakt, tegnes med det som
   mangler stiplet rødt (som 105).
6. **Trappas lås arves av sonene som gulv**, ikke som lås (sonen har sin egen hengelås fra 105).
7. **Sidefunn rettet uten å spørre:** med «Kabelstart: Topp» fikk den nedre sonen forbindelsen over
   sonegrensen (et opptrinn som ikke er dens, og feil inngangsside). Rettet i sonefilteret (begge ender må
   ligge i sonen). Trapper uten soner er urørt.

## 121 · Kabelmotor-testene

1. **Fail-open-årsaken var ikke hjørnefilteret.** §44 skrev «083s harde kaskadefilter … slipper ingen
   tilnærmet kandidat gjennom». Målt: `_cableFilterByCorner` returnerer hele lista når ingen treffer
   hjørnet — den kaster aldri alle. Det som ga `null` var at kandidatlista var TOM: uten clipper gir
   geo «ingen løsning», og 083 (samme commit) tok V6 ut av konkurransen, så ingen kaskademotor ble
   lagt i lista (skew bare for roterte rom). Fiksen ligger derfor der lista er tom (`if (!chosen)`),
   ikke i filteret. Med clipper lastet er veien uendret (låst av en ny påstand).
2. **Den tilnærmede kandidaten er dagens kaskade** (`_autoFillCableLegacy` via
   `_cableLegacyInDirection`, innenfor 074-dybdetelleren så den ikke åpner dialoger). Den måles med
   `_cableGeometryCheck` og merkes `_geomOk` ærlig (kan være ugyldig — det var den også før 083:
   «v6/CC 14,14/ugyldig»). Panelet sier «Lagt uten polygonbiblioteket — kantene er tilnærmet».
3. **Batteriet tok 30 s her, ikke 127 s** som §44 målte 20.10 — samme 127 påstander. Jeg vet ikke
   om forskjellen er maskinen, nettleserens tilstand eller noe i koden siden `ffb8db7`; tallet står
   som målt i dag.
4. **Den raske variantens utvalg** er én fixture per motorfamilie (`_CABLE_GEO_RASK_FIXTURES`), valgt
   så den holder seg under 20 s — se STATUS §45 for tidene per fixture. Vil du ha andre fixturer i
   utvalget, er det én liste.
