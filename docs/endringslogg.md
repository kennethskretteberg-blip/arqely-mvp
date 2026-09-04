# Endringslogg — Romtegner

Kronologisk logg over arbeid i `romtegner.html`. Nyeste øverst.

---

## «Bytt produkt» uten å tømme rommet først — 2026-09-03

Kenneth: «jeg ønsker … å endre produkt og komme tilbake til menyen … slik det er nå, må jeg velge
rom og tømme rommet for produkter for så å legge inn på nytt.» Funksjonen for «kom tilbake til
menyen» fantes allerede, men het `_showPostDeleteActions` og var derfor kun nåbar via en sletting —
navnet var selve grunnen til at ingen tenkte på å kalle den fra noe annet. Fem commits, rekkefølgen
Kenneth ba om (Rettelsen → B → A → C), pluss én oppfølging samme dag.

- **`0628740` — Rettelsen: snø-matte «✕ Avbryt» gjenoppretter nå rommet.** Eksisterende feil funnet
  FØR resten kunne bygges trygt: øktstart tømmer rommet før forhåndsvisningen legges ut, men Avbryt
  fjernet kun forhåndsvisningens EGNE matter — det som ble ryddet ved øktstart kom aldri tilbake,
  området sto tomt. Ny delt snapshot/gjenopprett-mekanisme, lagret PÅ ROMMET (ikke den globale
  angre-stakken) — verifisert live at en annen handling midt i økta overlever avbrytet uendret. Fant
  også en ikke-relatert kvirk (dobbel `pushUndo()` i `autoFillMatSerpentine`) — rapportert, ikke
  rettet.
- **`c18c9f3` — DEL B: nytt produkt ERSTATTER nå, legger ikke til.** Kabel ryddet FØR ingenting ved
  øktstart — velger man et nytt kabelprodukt i et rom som allerede har en kabel, fikk man to. Ny
  delt øktstart-mekanisme rydder nå kun PRODUKTET som byttes, ikke hele rommet (folie i samme rom
  blir stående) — en bevisst innsnevring også for snø-matte, som før tømte alt.
- **`6d24f66` — DEL A: tre nye inngangspunkter, ingen sletting nødvendig.** Omdøpt
  `_showPostDeleteActions` → `_openProductPanelForRoom` (samme kropp, samme fem kallere). Ny
  «⇄ Bytt produkt»-chip i ctxbaren og objekt-info-panelet for valgt stripe/kabel/matte/plate, samt i
  rommets kontekstmeny.
- **`5c98d23` — DEL C: fant og rettet — panelet viste «Ingen produkter funnet».** Under verifisering
  av at Kenneth faktisk fikk det han ba om, dukket en ekte, allerede eksisterende feil opp:
  familyName ble avledet fra KUN FØRSTE ORD i produktnavnet, mens produktfilteret matcher det
  faktiske `product_family`-feltet (nesten alltid flere ord). Panelet viste derfor «Ingen produkter»
  for praktisk talt hele katalogen — rammet også de fem ORIGINALE sletting→panel-veiene, ikke bare
  de nye knappene.
- **Oppfølging samme dag — kan nå bytte MODUL også.** Kenneth bekreftet eksplisitt spec-ens åpne
  punkt («kan bytte modul også»). Alle tre knappene åpner nå den samlede produktvelgeren i stedet
  for ett families eget panel — forhåndsvelger fortsatt riktig type, men har en «Produkttype»-chip
  for å bytte til en helt annen modul (f.eks. kabel→folie).

**Fil:** romtegner.html.

---

## Snøkabel: fasebalanserte forslag og ekte tall i forhåndsvisningen — 2026-09-03

Kenneth: «hvis man velger 2 store kabler … får L1 mye mer belastning enn L2 og L3» — ønsket forslag
på 3 eller 6 like kabler for snøanlegg, og at et 35 m² snøområde ikke lenger skulle gi kun ETT
kabelforslag. Tre commits, rekkefølgen A → C → B.

- **`4f8aa87` — DEL A: N-løkka i `selectMultiCables` kjører nå alltid.** Rotårsak til at et 35 m²
  snøområde ga kun ett forslag: et tidlig `return` hoppet over hele N=2..16-evalueringen når én
  kabel dekket ≥90 % av behovet. Et første forsøk lot N=1 konkurrere direkte i samme rangering som
  N=2..16 — en A/B-test mot 864 syntetiske innendørs-rom viste 37 % avviksrate, reversert til en
  konservativ variant som er bit-for-bit identisk med forrige versjon for innendørs (4400 rom, 0
  avvik), men gjør N-løkkas data alltid tilgjengelig.
- **`ff5ebc4` — DEL C: forhåndsvisning viser nå faktiske tall, snø forhåndsviser.** Snøens
  enkeltkabelforslag plasserte FØR direkte og lukket panelet — ingen «✓ Bruk»/«✕ Avbryt», ingen
  angring uten undo. Forhåndsvisnings-footeren viste kun «● Forhåndsvises», ingen tall — leser nå
  faktiske W/m²/CC/meter fra canvas (ikke forslagets prediksjon; verifisert reelt avvik 121 vs 154
  W/m² på samme forslag i test).
- **`537c4b3` — DEL B: nye «minimum antall»/«fasebalansert»-forslag i snømodulen.** 2 kabler kan
  ALDRI fordeles jevnt over 3 faser (L1-L2 + L3-L1 belaster L1 dobbelt), 3 og 6 kan. Fasebalansert
  (minste multiplum av 3 som når ønsket effekt) er ny ★ Anbefalt i snømodulen; gjelder IKKE
  innendørs (Kenneth bekreftet eksplisitt).

**Fil:** romtegner.html.

---

## Visma GBAO10-eksport: generator-kjerne og portvakt-test — 2026-09-03

Ny fileksport til Visma Global (33-felters GBAO10-format), adskilt fra den eksisterende «Kopier til
Visma»-pasten (UTTRYKKELIG uendret). Spec-en krever en portvakt-test FØR resten bygges: godtar
Vismas import CVA-serien (Cenika Varme-produkter), eller kun CV-serien (Cenika)?

- **`afc528e` — DEL G: generator-kjerne, IKKE koblet til UI.** `_gbaoClean`/`_gbao10Line`/
  `_gbao10FileText` bygget og verifisert (ingen BOM, CRLF på hver linje inkl. siste, 33 felter). To
  testfiler generert utenfor appen (kundenr 38693/Kenneth Skretteberg) og sendt til Kenneth for
  import i et ekte Visma-testtilbud — én med 4 CVA-artikler, én med 16 blandede artikler (CV/CVA/
  el-nummer, merket TEST2) etter ønske fra Cenikas admin. Kenneth bekreftet at testfilen fungerte i
  Visma. DEL A–F (org-bryter, kundenummer, dialog, gjenbruk av materiallista, mappe-skriving) er
  ikke påbegynt.

**Fil:** romtegner.html.

---

## Matte: kabelskjøt følger naboen, halv-CC-forbandt, jevne bredder — 2026-09-02

Kenneth: «kabel ligger feil der matten kappes og vendes. svingene må naturlig gå fra en bredde til
neste bredde.» Fire commits, siste bygget etter en oppfølgende bekreftelse samme dag.

- **`d6a4e86` — DEL A: auto-matte sin kabel følger nå naboen i skjøten.** Rotårsak: `drawMats`
  startet HVER bredde sin første streng på venstre kant uansett hvor forrige bredde sluttet —
  antall strenger per bredde varierer med klippingen mot rommet, så annenhver skjøt landet feil.
  Frihånd hadde allerede løst nøyaktig dette (`entryHi`/`exitHi`/`hi0`/`Nuse`) — løftet UENDRET til
  en delt `_matCableEntrySide()`, brukt av begge motorene nå. Beslutningen flyttet inn i
  `_matCablePlan` (samme kilde vakten `_matRunsWithinRoom` leser).
- **`142a40d` — DEL B: selve skjøten er nå en sving, ikke en strek eller et opphold.** Halvsirkel
  (`_matArcHalf`, samme delte hjelper U-svingene innad i en bredde bruker) mellom breddene, radius
  fra faktisk avstand (ikke `cc/2`, som er LÅST for U-svingene). Frihånd bevisst IKKE rørt — egen
  test krevde at den forblir uendret.
- **`c783da8` — DEL D: «Sentrer» jevner nå ut breddelengder, ikke bare posisjon.** Ny søster til
  LÅST Regel E (`_matNearEqualWidthNL`) som godtar en kort siste bredde, men minimerer
  differansen. Egen bug funnet og rettet underveis: første forsøk rundet lengden NED, som
  matematisk gjorde det umulig for siste bredde å noensinne bli kort — rettet til avrunding.
  `mp._lenBeforeCenter` lagrer original-lengdene så «Sentrer AV» kan gjenopprette dem.
- **`c8d416a` — DEL C: EcoMat legges nå i forbandt, Regel 19 revidert.** Forrige runde målte at
  verken U-sving- eller hjørne-tilkobling i frihånd produserer noen deterministisk halv-CC-
  forskyvning — rapportert, ikke bygget. Kenneth bekreftet deretter med ord («ja, jeg vil ha
  forbandt for ecomat også»). `mat_stagger_half_cc` satt til `true` på alle 57 EcoMat-produktrader
  i Supabase (samme felt `_matCablePlan` allerede leste for InSnow). Frihånd leste feltet ALDRI —
  utvidet til å gjøre det, med samme paritetsprinsipp (`laneIdx%2`) som auto sin `r%2`.
- Testmetodikk: full regresjonsbatteri (mat/matZone/matFree/cableSkew/foil) grønn etter hver
  commit. DEL A/B/C verifisert med ekte canvas-screenshot i tett zoom, ikke bare tallsjekk.

**Fil:** romtegner.html, `supabase-migration-ecomat-forbandt.sql`.

---

## PDF-eksport: nytt filnavn med prosjektnr — 2026-09-02

Kenneth: «endre filnavn på eksport pdf til følgende format:
Varmeplan_P:xxxxx_Prosjektnavn_01.01.2026_rev1».

- **`c0ecbb8` — `Varmeplan_P0142_Navn_dd.mm.åååå_revN.pdf`.** Kolon droppet (ulovlig i filnavn på
  Windows, tolkes som sti-skille i Finder på macOS) — `P0142` uten skilletegn. Fire siffer, delt
  med forsiden/prosjektlista via ny `_fmtProjectNo()`. Dato bygget som bestilt (dd.mm.åååå, ikke
  ISO) — trade-off nevnt: bryter kronologisk mappesortering. Ny delt `_exportFileName()` bytter
  ALLE understreker i prosjektnavnet til bindestrek (understrek er nå feltskillet i filnavnet).
  Uten prosjektnr utelates hele P-feltet — aldri en oppdiktet `P0000`. Excel-eksporten urørt.

**Fil:** romtegner.html.

---

## PDF-forside, prosjektnr og Romoversikt i riktig rekkefølge — 2026-09-02

Kenneth ba om fire ting på én gang: ny forside, et ekte prosjektnummer, Prosjektoversikt uhaket som
standard, og Romoversikten flyttet til riktig sted i utskriften. Bygget i rekkefølgen C → D → A → B,
committet hver for seg.

- **`f2d45ea` — DEL C: «Prosjektoversikt» uhaket som standard.** Én linje.
- **`e264250` — DEL D: Romoversikt/Trappeoversikt flyttet til rett før Materiallista.** Kenneth
  hadde rett i at rekkefølgen var feil — eksportdialogens eget grensesnitt viste allerede riktig
  gruppering, det var byggeren som var uenig med sitt eget grensesnitt.
- **`64cffb0` — DEL A: Adresse fjernet, Kontaktperson lagt til.** Adresse-raden skrev bokstavelig
  «[object Object]» (feltet var aldri en streng). Kontaktperson fantes allerede i state, bare
  aldri lest av forsiden. Ny delt `_pdfCoverMetaRows()` — forsiden og HTML-forhåndsvisningen
  bygger nå radene ett sted.
- **`f724886` — DEL B: ekte, unik prosjektnr-indeks PER FIRMA.** Kenneth valgte per-firma fremfor
  global sekvens etter et eksplisitt spørsmål. Database-trigger (atomisk `INSERT ... ON CONFLICT
  ... RETURNING`, kollisjonsfri også ved samtidige lagringer) + migrasjon kjørt: 271 eksisterende
  prosjekter backfylt, hvert firma sin egen 1..N-serie, eldste = nr. 1.

**Fil:** romtegner.html, `supabase-migration-prosjektnr.sql`.

---

## FERDIG-knapp etter utlegg, og en glemt forhåndsvisning — 2026-09-02

Kenneth: «jeg ønsker også en "FERDIG" knapp etter jeg har lagt ut varmekabler i rom og godkjent
forhåndsvisning. Nå må trykke ut i canvas, for å få opp romlisten.»

- **`b1f0290` — DEL A+C: én FERDIG i panelheaderen dekker alle produktveier.** Fantes fra før, men
  kun i den manuelle paletten. Ny knapp i `#room-workflow-panel` sin header dekker auto-forslag
  (kabel/matte/plate/snø) også, uten å limes inn i fem ulike visningsfunksjoner. Skjules når den
  manuelle paletten (egen FERDIG) er synlig.
- **`eba8711` — DEL B: FERDIG rydder nå opp i en ventende forhåndsvisning.** Ekte feil funnet
  underveis: ingen vei ut av panelet (tomt-canvas-klikk, Escape) tømte en ventende kabel-/matte-
  forhåndsvisning — den kunne bli stille slettet neste gang noe forhåndsvistes i samme rom. FERDIG
  deaktiveres nå mens noe venter (ikke auto-godkjenner), Escape avbryter en ventende
  forhåndsvisning. Åpent funn rapportert, ikke fikset: en forhåndsvisning kan i prinsippet
  overleve et lagre/last siden `_buildSaveData()` sprer hele romobjektet.

**Fil:** romtegner.html.

---

## Soner: kabel per sone og automatisk N-deling — 2026-09-02

Kenneth: «Det som er feil nå, er at jeg ikke får lagt en kabel innenfor hver sin sone, den legger
seg ut over sonene som at rommet fortsatt er en hel sone.»

- **`c2bf0cf` — DEL A: delelinjen låses til vannrett/loddrett.** `getWorldPos()` fikk en ny
  `zoneSplitMode`-gren som gjenbruker samme `angleSnap()` rom-polygontegning allerede bruker.
- **`dc99d4a` — DEL B: kabel legges nå per sone, ikke over hele rommet.** Rotårsak: `autoFillCable`
  tar en roomId og har aldri sett en sone — `showCablePlacePanel()` nullstilte til og med
  sone-flagget eksplisitt før kabelpanelet åpnet. Ny `_fillSoneCable()` (speiler `_fillSoneFoil`,
  delt `_soneTempRoom()`), delt CC på tvers av kabelsoner i samme rom, gate mot rom-nivå kabelvalg
  når rommet har soner.
- **`fc4da08` — DEL C: automatisk deling i N like store soner.** Ny knapp «Del i N soner» ved
  siden av «Del i soner» — bygger EKTE, navngitte `S.zones`-oppføringer (ikke kabelmotorens egen
  flyktige geometri), gjenbruker `_equalAreaBandBounds`.

**Fil:** romtegner.html.

---

## «Kopier til Visma»: tomme rader i stedet for fritekst, to kolonner — 2026-09-02

Kenneth testet fritekstlinjer («VARMEFOLIE» som en varelinje med tomt artikkelnummer) direkte mot
Visma Global: det virker ikke.

- **`676dcde` — utklippet er nå kun `2269`+`2281` (artikkelnr+antall).** Rabatt-avkryssingen
  fjernet helt fra dialogen. Tomme rader (bokstavelig `"\t"`, ikke en tom streng) erstatter
  fritekst-overskrifter — én mellom materialgrupper, to foran tilbehøret. Ny
  `dokumenter/visma-global-tilbudsimport-format.md` dokumenterer at fritekstlinjer er testet og
  IKKE virker, så neste person slipper å teste det på nytt.

**Fil:** romtegner.html, `dokumenter/visma-global-tilbudsimport-format.md`.

---

## «Kopier til Visma»: artikkellinjer, delt tilbehør og PDF-rekkefølge — 2026-09-01

Kenneth fant ut at man kan lime artikler rett inn i et ALLEREDE ÅPENT tilbud i Visma Global — mye
kortere vei enn den parkerte GBAO10-tilbudseksporten (ikke slettet), siden kundenummer/-kobling
(den vanskelige delen der) ikke trengs i det hele tatt. Fem commits samme dag: ny funksjon, ekte
bug funnet og fikset i produksjon samme dag, en migrasjon kjørt mot Supabase, og en oppfølgende
prompt som rettet rekkefølge og fjernet dobbeltarbeid med tilbehørsvalg.

- **`a405a75` — «Kopier til Visma»: tabulatorseparerte artikkellinjer på utklippstavla.**
  Cenikas eget paste-format (felt-ID 2269/2270/2281/2274). `_collectMaterialItems()`/
  `_aggregateMaterialItems(items)` løftet ut og delt med XLSX-eksporten (bekreftet Excel uendret).
  Rabatt gjenbruker `_resolveDiscountPct` (samme kilde som PDF-en), kolonne 2274 tas kun med når
  minst én linje faktisk har rabatt > 0. **Ekte bug funnet og fikset underveis:** Antall-feltet
  brukte en heuristikk laget for Bestilling-arkets tekststreng til mennesker (`!cable_length_m`),
  som feilklassifiserte MATTER som «solgt løpende» — ga antall=10 (meter) for én enkelt EcoMat-
  rull i stedet for 1 (stk), en stille tidoblet bestilling i Visma. Rettet med `kind==='Folie'`
  (satt autoritativt i `_collectMaterialItems`) som eneste «solgt løpende»-signal. Forhåndsvisning
  viser nøyaktig det som limes inn; manglende `article_no` navngir produktet og sperrer
  Kopier-knappen; `navigator.clipboard.writeText()` med ekte fallback (markert, fokusert
  `<textarea>`), verifisert begge veier.
- **`014ffe9` — ny `organizations.erp_format`-kolonne, kjørt mot Supabase.**
  [supabase-migration-erp-format.sql](../supabase-migration-erp-format.sql) — fri streng, ikke
  boolsk, slik at en annen grossist kan få sin egen verdi uten kodeendring. Kjørt via Supabase CLI
  (`supabase link` + `supabase db query --linked`, allerede autentisert). Cenika AS (eneste org i
  databasen på det tidspunktet) satt til `erp_format='visma_paste'`. `erp_format` lagt til
  `_loadUserOrg` sin select-liste (manglet — uten det ville feltet alltid vært `undefined`).
  Knappen er live for Cenikas brukere.
- **`84f86a5` — fiks: «Kopier til Visma» manglet manuelt tastet tilbehør.** Rotårsak: kommentaren
  over `_collectMaterialItems` (skrevet i SAMME commit som opprettet Visma-pasten) sa eksplisitt at
  tilbehør «hører til XLSX-eksportens EGEN flyt» — feil fra øyeblikket den ble skrevet, siden
  `showAccessoriesModal()` allerede var delt mellom PDF og XLSX. `_showVismaPasteDialog()` ble
  `async` og kaller `showAccessoriesModal()` FØR noe annet, samme kontrakt som PDF/XLSX (avbrutt
  modal avbryter hele kopieringen). Ny delt `_aggregateAccessoryItems(list)`, løftet ut av XLSX sin
  egen `_emit`-closure — samme duplikasjon (samme løkke to steder) var nøyaktig hvordan tilbehøret
  manglet fra starten. Produkter først, tilbehør etter — ingen gruppeoverskrifter (en fritekstrad
  limt inn i Visma ville blitt en varelinje uten artikkelnummer). Åpent spørsmål, ikke avgjort:
  skal tilbehør ha samme rabatt som resten av tilbudet (står som 0 i dag)?
- **`de5990b` — DEL A: én kanonisk materialgruppe-rekkefølge for PDF/XLSX/Visma.** Kenneth: «den
  legger seg ikke i samme rekkefølge som materiallisten i PDF-eksporten.» Ny delt
  `MATERIAL_GROUPS`-konstant + `_groupByMaterialGroups()`. PDF er fasiten (`_matGroups =
  MATERIAL_GROUPS`, null atferdsendring). **Ekte bug funnet og fikset i XLSX:** Materialliste-
  arkets flate `groupsOrder` manglet Aluboard-typene helt og hadde ingen fallback-gruppe —
  Aluboard-produkter forsvant stille fra arket, ikke bare feil rekkefølge. Visma-pasten fikk
  eksplisitt sortering (var ren Map-innsettingsrekkefølge før). Sortering internt i hver gruppe:
  stigende produkt-id, matcher hvordan `Object.entries()` på heltalls-nøklede objekter naturlig
  oppfører seg i PDF-en (Map gjør IKKE dette, derfor eksplisitt `.sort()`).
- **`4019649` — DEL C: gjenbruk tilbehør fra PDF/XLSX i stedet for ny modal i Visma-pasten.**
  Kenneth: «i praksis lager jeg først PDF for å sende underlag til kunde, og så må jeg kopiere til
  Visma — da blir valg av tilbehør en jobb som må gjøres dobbelt.» `showAccessoriesModal()` lagrer
  nå det bekreftede resultatet på `S.project.accessories` (samme spre-mønster som pricing/freeText
  via `_buildSaveData`) og forhåndsutfyller hver rad derfra — inkludert RKK-kabel og stålnett, som
  har egen UI utenfor den generiske `data-acc-id`-mekanismen. Visma-pasten bruker lagret valg
  direkte uten å spørre på nytt; ny «Endre tilbehør»-knapp åpner modalen forhåndsutfylt. PDF/XLSX
  lagrer «gratis» siden de allerede kaller samme modal uendret — rekkefølgen (PDF-først eller
  Visma-først) spiller ingen rolle. `_FOIL_ACC_LS_KEY`-preferansene (brukerdefault på tvers av
  prosjekter) er bevisst IKKE blandet med `S.project.accessories` (prosjektets eget valg). Lagrede
  antall leses rått, aldri regnet på nytt. **DEL B (seksjonsoverskrifter «VARMEFOLIE»/«TILBEHØR» +
  blank rad mellom seksjoner i Visma-pasten) er bevisst IKKE bygget** — uklart om Visma Global
  tolererer en pastet linje uten artikkelnummer (kan enten lage en fritekstlinje korrekt, eller
  avbryte/forkaste hele limingen midtveis). Kenneth tester selv med
  `dokumenter/visma-test-fritekstlinje.xlsx` før dette bygges.
- Testmetodikk gjennomgående: live i nettleser mot Kenneths egne Bok6.xlsx-eksempler og/eller ekte
  produktkatalog fra Supabase (ikke mock), full regresjonsbatteri
  (mat/matZone/matFree/cableSkew/foil) bestått uendret etter hver commit.

**Fil:** romtegner.html, `supabase-migration-erp-format.sql`, `docs/endringslogg.md`.

---

## Bakgrunn-gizmoen var usynlig når zoomet inn — oppfølging samme dag — 2026-08-26

Samme dag, ny prompt, etter forrige punkts «Flytt underlag»-fiks: Kenneth fikk fortsatt ikke opp
gizmoen for å flytte bakgrunnen. STEG 1 og DEL C fra forrige økt var fortsatt riktige (bekreftet,
ikke gjenbygget) — den forrige STEG 2-fiksen løste ikke hele problemet alene.

- **`92dca47` — STEG 2: målt, ikke antatt, hvorfor gizmoen er usynlig.** Engangs-diagnose alene.
  HYPOTESE 1 (gizmoen tegnes utenfor skjermen når man er zoomet inn på et rom, siden rammen
  omslutter HELE bakgrunnsbildet) BEKREFTET empirisk — alt annet var riktig satt opp, håndtakene
  var bare usynlige utenfor viewporten. HYPOTESE 2 (klikk-syklingen lar rommet stjele klikket)
  MOTBEVIST empirisk med et ekte dispatchet MouseEvent — bakgrunn-gizmo-sjekken kjører allerede FØR
  klikk-syklingen og vinner korrekt.
- **`4ce976d` — STEG 2b: alltid-synlig reserve-markering + Flytt-underlag zoomer + Shift gir finere
  piltast-steg.** Fast reserve-markering nederst midt på canvas, vises KUN når
  `_bgGizmoAnyCornerVisible()` er false (ikke et konstant ekstra element — rammen er fortsatt
  primær). `_bgStartMove()` («Flytt underlag») zoomer nå til hele tegningen via `_fitViewToBg`
  (gjenbrukt fra forrige punkts STEG 1). Pilene for å flytte en valgt bakgrunn fantes fra før — men
  Shift ga et STØRRE steg (25cm), motsatt av det Kenneth ba om («finere steg ved Shift»); byttet
  hvilken av de to eksisterende verdiene (5/25) hver tast-tilstand bruker.
- Testmetodikk-fallgruve verdt å merke seg: en headless browserfane uten innlogging får aldri et
  ekte layout — `canvas.width` blir stående på HTML5-default (300×150), som ga et falskt negativt
  resultat for «zoomer `_bgStartMove` til synlig?» først. Rettet ved å sette `canvas.width/height`
  direkte i testen (1400×800), ikke via `resizeCanvas()` (som selv avhenger av et fullt rendret
  `#app`-tre appen ikke bygger uten innlogging).
- Verifisert: samme funksjonsnivå-metodikk som forrige punkt. Full regresjonsbatteri bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Plantegninger legges nå alltid fra samme nullpunkt — 2026-08-26

Kenneth: byttet bakgrunnsbilde, kalibrerte på nytt, men «tegningen la seg ikke inn samme sted» som
forrige gang. Tre commits pluss en oppfølging (DEL C) som utvider til flere plantegninger per
etasje, godkjent eksplisitt av Kenneth via AskUserQuestion før bygging.

- **`5a6fc2e` — STEG 1: kartlagt alle `bg.originX/originY`-steder og bekreftet Y-fortegnet.**
  Rapport alene. Rotårsak funnet: `_installBgImage`/`_installBgImageForFloor` sentrerte en ny
  bakgrunn på `S.view.panX/panY` (der visningen tilfeldigvis stod panorert), ikke et fast punkt.
  Fasiten fantes allerede i `_autoReadRunEngine` (auto-rom-gjenkjenningsmotoren):
  `bg.originX=0, bg.originY=-heightCm`. Y-fortegnet BEKREFTET (ikke antatt) mot faktisk
  `w2s()`/`drawBgImage()`-kode: verden er Y-ned, ingen flip — nedre venstre hjørne havner korrekt
  i (0,0).
- **`0892585` — fiks: bakgrunnsbilder plasseres nå på et fast punkt, ikke der visningen stod
  panorert.** Begge installer-funksjonene bruker nå samme formel som `_autoReadRunEngine`.
  Kalibrering/fast målestokk/gizmo-draget bekreftet TRYGGE og urørt (proporsjonal omskalering rundt
  et brukervalgt referansepunkt). Ny `_fitViewToBg(bg)` (samme formel som `fitAll()`) flytter
  visningen til den nye bakgrunnen etter import — ellers tomt lerret siden bakgrunnen nå ligger
  fast, ikke der visningen stod. Verifisert med EKTE Image-objekter (ikke mock): to importer med
  vilt ulik panorering, samme zoom → identisk origin OG bredde/høyde; «Bytt bilde» bekreftet
  uendret (bevarer en manuelt flyttet posisjon).
- **`fdb04a7` — STEG 2: «Flytt underlag» gjør opplåsingen til én synlig handling, ikke en
  gjettelek.** Gizmoen for å flytte bakgrunnen fantes allerede, men hengelåsen (riktig standard:
  låst etter kalibrering) skjulte veien dit. Ny «Flytt underlag» i ⋯-menyen (`_bgStartMove()`:
  låser opp + velger + viser gizmo i én operasjon). Ctxbar viser nå eksplisitt «Ulåst — klikk
  treffer tegningen» når valgt+ulåst, lås-knappen sier «Lås igjen». Alle tre lås-tooltips (ctxbar
  persistent gruppe, ctxbar valgt-tilstand, sidepanel) skrevet om til å forklare hva OPPLÅSING er
  til for, ikke bare hva låsing gjør. Auto-relås ved annet utvalg: vurdert og rapportert (kommentar
  over `toggleBgLock`), IKKE bygget — en avveining, ikke et opplagt svar.
- **`ef6de00` — DEL C: flere plantegninger per etasje — aktiv (én) + referanser (null eller
  flere).** Eksplisitt godkjent av Kenneth via AskUserQuestion FØR bygging (reverserte i prinsippet
  19.08-regelen «én plantegning per etasje» — den regelen gjelder fortsatt for AKTIV). Ny
  `S.bgRefs[floorId]` (array, samme nøkkelkonvensjon som `S.bgs`) — referanser er strukturelt
  identiske aktiv-bakgrunn-objekter, bare aldri registrert der kalibrering/hit-testing/PDF ser
  etter dem (`_bgRefsOnActiveFloor` er en HELT EGEN funksjon fra `_bgsOnActiveFloor`, som
  `_hitBgLayer` leser fra). `_addBgToFloor` degraderer nå den gamle aktive til referanse i stedet
  for å tvinge frem en ny etasje — det ER Kenneths «gammel beholdes sammen med ny».
  `_promoteBgRef` («Gjør til aktiv») bytter ett-trykks, aldri to aktive. `removeBgImage` forfremmer
  automatisk nyeste referanse hvis den aktive slettes og en finnes (eksplisitt valg, dokumentert).
  `drawBgImage` tegner referanser UNDER aktiv, ALDRI i PDF (`S.ui._pdfMode`-gate). Sidepanelet
  viser referanser med samme avkrysning+opasitet-mønster som aktiv allerede hadde, pluss «Gjør til
  aktiv» og slette-knapp. Lagring: delt `_serializeBgFields` (faktorert ut av eksisterende
  bgs-serialisering, ikke duplisert). Filstørrelse: ~200–530 KB per referanse (JPEG 0.85 + base64),
  grovt 1–2,6 MB for 5 etasjer × én gammel versjon hver. Ingen automatisk opprydding —
  `_removeBgRef` for manuell sletting.
- Verifisert: syntetiske rom/etasjer + EKTE Image-objekter og EKTE data-URI-er. Full flyt
  verifisert for DEL C: import→legg-til-på-nytt→demotering→reimport→normal rendering (begge, ref
  under aktiv)→PDF-modus (kun aktiv)→hit-test (ekskluderer ref)→promote→slett-med-ref
  (forfremmer)→slett-uten-ref (uendret)→EKTE rundtripp gjennom
  `_buildSaveData`/`_restoreProject` (bevarer referanse med lastet bilde). Full regresjonsbatteri
  bestått etter hver av de fire commitene.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Tilleggsteksten i PDF-eksporten lagres nå på prosjektet — 2026-08-26

Kenneth: «Hvis jeg i ettertid må endre prosjekteringen og skrive ut på nytt, er teksten jeg skrev
inn borte.»

- **`01a7774` — tilleggsteksten (`#exp-freetext`) lagres nå, som rabattene allerede gjør.**
  Rotårsak bekreftet nøyaktig som antatt: `_runExportPDF()` leste `#exp-freetext` og kastet det;
  rabattene (nabofeltet, tre linjer under) ble lagret til `S.project.pricing` med akkurat den
  begrunnelsen Kenneth etterspurte — tilleggsteksten ble bare aldri tatt med i det. `_runExportPDF()`
  lagrer nå `S.project.freeText = opts.freeText` ved siden av `S.project.pricing`, samme
  autolagring. `_showExportDialog()` forhåndsutfyller `#exp-freetext` fra `S.project.freeText`
  (via `_esc`) — ikke låst, kan endres/tømmes fritt. Lagring/lasting krevde ingen egen kode:
  `S.project` spres allerede i sin helhet i `_buildSaveData`/`_restoreProject`, nøyaktig samme vei
  `S.project.pricing` selv går. Per PROSJEKT (spurt, ikke avgjort selv), ikke per revisjon — rapportert
  konsekvens: et prosjekt skrevet ut i rev. 1 og igjen i rev. 3 med endret innhold bruker SAMME
  tekst i begge.
- Verifisert: syntetisk prosjekt, `exportPDF` stubbet. Tomt før noen tekst; tekst overlever
  eksport+gjenåpning; endring overskriver; tømt felt lagres tomt og forblir tomt; EKTE rundtripp
  gjennom `_buildSaveData()`/`_restoreProject()`; gammelt prosjekt uten feltet åpnes uten feil.
  Full regresjonsbatteri bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Ctxbar fast toppsentrert + manuell utlegging er nå en økt — 2026-08-25

Kenneth (manuell varmefolie): «Det kommer opp en flytende menybar rett over varmefolien jeg legger
ut manuelt... veldig forstyrrende» + «Lista over produkter ved manuell blir borte når jeg gjør noe
annet... det hender jeg må måle litt i rommet.» Branch `ui-flyt-manuell`, merget til main
(`93cdd57`), Kenneth godkjente push+merge eksplisitt.

- **`ca25f0d` — STEG 0: kartlagt ctxbar-posisjonering og hva som skjuler den manuelle paletten.**
  Rapport alene, med én korreksjon til prompten selv: `#draw-toolbar` («BAKGRUNN…TEGN ROM…») er
  DØD MARKUP (display:none, ingen kodesti gjør den synlig, onclick refererer en ikke-eksisterende
  funksjon). Baren Kenneth faktisk ser ER `#ctxbar` selv i idle-tilstand — samme element som blir
  den forstyrrende linja når et objekt velges. Full gjennomgang av alle 15 steder
  `S.ui.selectedRoomId` nullstilles: måling og panorering rører den ALDRI; eneste reelle utløser er
  et mistreff-klikk som bommer på enhver romspolygon, uten sjekk for `S.ui.manualPlaceMode`.
  Matte/snø-paletten deler bokstavelig talt samme `#rwp-manual-palette` og samme
  show/hide-funksjoner som folie — like sårbar, ikke en lignende bug.
- **`c364cf4` — DEL A: ctxbar er nå fast toppsentrert — følger aldri lenger det valgte objektet.**
  `_positionCtxBar()` limte linja ~40px over valgt objekt (eller UNDER hvis trangt, verre).
  Fallback-grenen (toppsentrert) er nå eneste regel. Fjernet `_selectedObjectWorldBBox()` i sin
  helhet (~100 linjer, ingen andre kallere) og `_positionCtxBar()`-kallet fra `render()` (kjørt
  hver frame — unødvendig når posisjonen er fast). Ingen egen kollisjonsjustering nødvendig:
  default CSS (top:12px inni `#canvas-wrap`, under `#topbar` sin faste 56px) ga allerede et rent
  mellomrom.
- **`e8ccfdd` — DEL B: manuell utlegging er nå en økt — overlever måling, ikke bare
  selectedRoomId.** Ny delt øktvariabel `_manualPlaceSession = {roomId, familyName, categoryId}`,
  satt av BÅDE `startManualPlace` (folie) og `startMatManualPlace` (matte/snø).
  `_updateVfDirVisibility()`/`showRoomWorkflowPanel()` bruker nå øktas rom når en økt er aktiv, ikke
  `selectedRoomId`. Økta avsluttes KUN av FERDIG, Escape (ny gren) eller `cancelManualPlace()`
  selv. Følgefiks: `_matPlaceCandidate` og matte-drop-håndtereren brukte `selectedRoomId` direkte
  for validering/plassering — rettet til å bruke øktas rom.
- Forslag rapportert, IKKE bygget (venter på Kenneths ja): skille bakgrunnskontroller (alltid
  relevante) fra objektkontroller (kontekstuelle) i ctxbar.
- Verifisert: ctxbar forblir top:12px/left:50% uansett valgt objekt og drastisk panorering+zoom;
  manuell palett overlever `selectedRoomId=null`+`updateCtxBar()` med riktig romtittel bevart;
  `_matPlaceCandidate` validerer korrekt mot øktas rom selv med null selection; FERDIG og Escape
  avslutter økta korrekt begge veier, for BÅDE folie- og matte-paletten. Full regresjonsbatteri
  bestått etter hver commit og på den mergede koden.
- Ikke testet: ekte innlogget museklikk-flyt (drag-og-slipp fra paletten, faktisk måle-klikk i en
  ekte plantegning).

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Krasj når selectedMatId/selectedPlateId pekte på et fjernet objekt — 2026-08-25

Funnet ved live-testing av modul-per-rom-branchen mot Kenneths ekte innloggede «Gullhaugveien 1 -
3»-prosjekt (ikke syntetisk): `S.ui.selectedMatId` pekte på en matte (id 1) som ikke lenger fantes
i `S.mats` (0 matter i prosjektet — det er InFloor+InSnow, ingen varmematte).

- **`8c9fd7e` — selvhelbredende vern + rotårsaksfiks i `_clearRoomProductCollections`.**
  `_ctxBarItems()` sin matte-gren antok objektet alltid finnes og krasjet ubetinget på
  `Math.round(mat.length_cm)`. Siden `renderSidebar()`/`updateCtxBar()` kalles fra mange steder
  (bl.a. `createRoom` internt), kunne HVILKEN SOM HELST handling som trigget en re-render krasje
  hele appen for Kenneth mens denne hengende referansen stod der. Rotårsak:
  `_clearRoomProductCollections(roomId)` (kalt fra «Tøm rom», «Fyll rom automatisk», enhver
  produktpanel-variant-endring) fjerner produkter fra strips/cables/mats/matPaths/plates/aluboard
  uten noensinne å rydde det tilhørende `S.ui.selectedXxxId`-feltet. Samme bug-form fantes også i
  `selectedPlateId`-grenen (samme mønster, ikke enda observert som krasj, men samme skjøre kode) —
  fikset samtidig. To lag: (1) `_ctxBarItems` sine mat-/plate-grener sjekker nå om objektet
  faktisk finnes; hvis ikke, ryddes UI-valget og grenen returnerer tomt i stedet for å krasje,
  samme mønster kabel/sone/trapp-grenene allerede bruker; (2) `_clearRoomProductCollections`
  rydder nå `S.ui.selectedXxxId` for ethvert produkt som fjernes OG faktisk var valgt (ny
  `ROOM_PRODUCT_SELECTED_UI_KEY`-mapping) — referansen blir aldri hengende i utgangspunktet.
- Verifisert direkte på Kenneths ekte side (bogus id → `updateCtxBar()` → ingen krasj, selvhelbredet
  til null) og isolert med syntetiske `S.mats` (fjerning av rommets matte rydder selektert-feltet
  KUN når det fjernede objektet faktisk var valgt, urelatert valg i annet rom urørt). Full
  regresjonsbatteri bestått på hans ekte innloggede side.
- Uhell underveis, rettet med eksplisitt godkjenning: en allerede planlagt autosave-timer lagret et
  midlertidig test-duplikat-rom («Hovedinngang (kopi)») til Kenneths ekte Supabase-prosjekt.
  Oppdaget ved en fullstendig sideoppfriskning, rettet (fjernet rommet igjen) og lagret korrekt
  tilbake — kun etter at Kenneth eksplisitt bekreftet via AskUserQuestion at skrivingen til
  Supabase skulle skje. Prosjektet endte med nøyaktig de samme fire rommene som før (Støp 3/Støp
  2/Fotskraperrist/Hovedinngang), bekreftet ved fullstendig sideoppfriskning fra Supabase.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Modulen (indoor/snø) er nå en rom-egenskap, ikke en fane-egenskap — 2026-08-25

Kenneth («Gullhaugveien 1 - 3»): måtte lage to «deler» (Del) og importere SAMME plantegning to
ganger fordi innendørs varmekabel ikke var valgbar mens han stod i Ute-fanen (innkjørsel utendørs +
hovedinngang innendørs, samme tegning). Eneste oppgaven denne økten som eksplisitt kjørte på egen
branch (`modul-per-rom`, ikke direkte på main) — Kenneth ba om dette selv siden endringen rører
regelsystemet («jeg må kunne git switch main og revertere mens serveren kjører»). Branchen ble
pushet separat; Kenneth testet selv, ga deretter eksplisitt «merge og push — jeg stoler på at
dette blir bra :)» — MERGET (`--no-ff`, `6cdc090`) og PUSHET til main. Ingen konflikter; full
regresjonsbatteri bestått på den mergede koden før push.

- **`7eb11fa` — STEG 0: kartlagt alle `_activeModuleType`/`_isSnowModule`-kall der rommet er
  kjent.** Kartla hvert kallsted av `_activeModuleType()`/`_isSnowModule()`/`_moduleEnv()`. 13
  bekreftede bugs (5 eksplisitt navngitt i prompten + 8 nye funn: showUnifiedProductPanel,
  _upcPlaceMat, showCablePlacePanel×2, _updateCableSelection×4, mattetegne-løkken,
  _renderDetailPanel, showHindringModal — disse 8 ikke fikset denne runden, kun rapportert).
  `_filteredProductCategories()` kjøres FØR de to STEG2-navngitte linjene i samme kjedede filter —
  en fiks av kun de navngitte linjene ville vært utilstrekkelig. `_effectiveMarginCm` har allerede
  fasit-mønsteret (roomId som valgfri parameter) men ingen av 40+ kallesteder sender den med —
  rapportert, ikke rørt (for stort omfang).
- **`869eef3` — STEG 1: frihånds-matte leser nå kun rommet, ikke fanen.**
  `_matFreeCableMarginCm`/`_matFreeStartFor`/`_matFreeStart` hadde
  `_roomModuleType(roomId)==='snow' || _isSnowModule()` (OR — fanen kunne overstyre). Rene
  rom-oppslag nå. Verifisert: indoor rom i en snow-del, aktiv fane=snow → margin=5 (ikke 0).
- **`3872124` — STEG 2: produktgaten spør nå rommet, ikke fanen — dette skjulte innendørs-kabel.**
  Ny delt helper `_uiModuleType()` (rett etter `_roomModuleType`, samme fasit-mønster som
  `_roomTargetWm2`): rommets modul når valgt, ellers fanen. Brukt i `_upcScopeProducts`,
  `_upcRenderTypeChips` OG `_filteredProductCategories` (sistnevnte var nødvendig). Gaten ikke
  svekket — verifisert med syntetisk to-kategori katalog: Ute-fane+indoor rom valgt → begge
  kategorier synlige; Inne-fane+snow rom valgt → kun utendørs; intet rom valgt → uendret i begge
  faner.
- **`60c70fa` — STEG 3: rommet kan nå bære sin egen modul, uavhengig av delen (GATED, STEG1+2
  grønne).** `_roomModuleType` sjekker nå `room.moduleType` FØR delens. LÅST (Kenneth):
  uforanderlig etter opprettelse, ingen «endre type»-funksjon, trapp IKKE per-rom.
  Lagring/lasting/angre trengte ingen egen kode — rommet spres allerede i sin helhet i
  `_buildSaveData`/`_restoreProject`/`pushUndo`. Verifisert: rom med `moduleType:'snow'` i en
  indoor del → `_moduleContext().ccMaxCm`=30 (snow) mot 12 (indoor); rundtrippet korrekt gjennom
  save OG pushUndo/undo.
- **`26e1677` — STEG 4: dupeRoom får to grener — dette ER hvordan man «endrer type» nå.**
  `dupeRoom(id, opts)` fikk to grener siden modulen nå er uforanderlig: A=med produkter (samme
  modul, ROOM_PRODUCT_KEYS + zones/hindringer), B=kun rom (brukeren velger modul eksplisitt). Ny
  meny `_showDupeRoomMenu` (gjenbruker `#produkt-menu`-dropdownen) på sidepanel-knappen;
  kontekstmenyen fikk de tre valgene inline. Verifisert: gren A kopierer riktig antall
  produkter/soner/hindringer med nye id-er og uavhengige objekter, én undo-ramme fjerner alt i ett
  steg; gren B med samme modul = regresjonsvakt bestått; gren B med motsatt modul gir faktisk den
  valgte typen.
- Bevisst IKKE gjort denne runden (rapportert i STEG 0): Inne/Ute som filter i stedet for modus
  (UI-endring, krever Kenneths beslutning); `S.project.type` fjernet fra Nytt prosjekt; én bakgrunn
  delt av flere etasjer (gjøres unødvendig av STEG 3).
- Testmetodikk: funksjonsnivå (innlogget canvas utilgjengelig), syntetiske to-delte prosjekter.
  Full regresjonsbatteri (mat/matZone/matFree/foil/cableSkew) bestått uendret etter hver av de fem
  commitene. node --check bestått etter hver.
- Ikke testet: ekte innlogget klikk-flyt (Kenneths eget scenario gjennom faktisk UI).

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Utskrift setter nå hele filtertilstanden, ikke halve — utendørs kabel manglet — 2026-08-24

Kenneth («Gullhaugveien 1 - 3» rev. 1): «Varmekabelen på utendørs område vises ikke på utskrift.
Kabel på innendørs vises riktig.» Side 3 «Støp 3» (uteareal, InSnow 30T×3) viste
omriss+skravur+riktig spesifikasjon, men INGEN kabel. Side 6 «Hovedinngang» (innendørs) var
korrekt.

- **`ba33710` — STEG 0: målt Gullhaugveien — MEKANISME 1 bekreftet, MEKANISME 2 også ekte.**
  Rapport alene. Bygget et syntetisk to-delt prosjekt (indoor «Hovedinngang» + snow «Støp 3»,
  samme struktur som `_enterPart` sin egen 'snow'-gren). Instrumenterte `_renderRoomToImage` rett
  før `render()` kalles — fanget en ekte felle i selve målemetoden: funksjonen kaller `render()`
  TO ganger (midt i eksporten + for å gjenopprette skjermbildet); å lese SISTE kall i stedet for
  FØRSTE ga et falskt resultat først, rettet før tabellen ble skrevet. Rotårsak (etasjefilteret,
  «etasje vanntett»-regelen fra 19.08): `_rebuildActiveFloorRoomIds()` filtrerer på TO felt —
  `S.ui.activePartId` OG `S.ui.activeFloorId`. `_renderRoomToImage` (kalt fra `exportPDF` sin
  per-rom-løkke, og fra PDF-forhåndsvisningen) satte kun `activeFloorId` fra rommet som skulle
  tegnes — `activePartId` ble ALDRI rørt, stod igjen på forrige aktive del. Bekreftet: for Støp 3
  ble `activeFloorId` faktisk satt riktig, men `activePartId` stod igjen på indoor — MEKANISME 1
  bekreftet som den faktiske årsaken. MEKANISME 2 (rom uten `floorId`) testet separat, bekreftet
  EKTE og nåbar via «Fjern fra etasje»-menyvalget (`mvRoom(id,null)`) — ikke årsaken til Kenneths
  konkrete sak, men reell og måtte håndteres eksplisitt likevel.
- **`4fe75a5` — fiks + STEG 2-rapport: begge felt settes og gjenopprettes nå.**
  `_renderRoomToImage` setter og gjenoppretter nå BEGGE (`saved.activePartId` lagt til ved siden
  av det eksisterende `saved.activeFloorId`-mønsteret). Ny sentinel `'__none__'` på
  `_effectiveActiveFloorId()` (samme mønster som `'__global__'` allerede er for bakgrunn) — et
  etasjeløst rom uttrykker nå eksplisitt «ingen etasje, IKKE fall tilbake» i stedet for å
  tilfeldig arve forrige etasje eller `S.floors[0]`-fallbacken. Filteret selv er urørt og like
  strengt. STEG 2-rapport over 25 skrivesteder til disse to feltene: legitim innen-del-navigasjon
  (sidebar/kontekstmeny) etterlater bevisst `activePartId` urørt siden konteksten allerede er
  riktig; `undo()`/`_restoreProject`/`_resetProjectState` setter allerede begge korrekt.
  `_renderRoomToImageOffscreen` er død kode (ingen kallesteder) — urørt, ikke fjernet. Ny
  dev-mode-påstand (samme `_floorlessWarned`-mønster som `_onActiveFloor` allerede bruker): rett
  etter `render()` inne i `_renderRoomToImage`, varsler (aldri kaster) hvis rommet som nettopp ble
  tegnet ikke er i `_activeFloorRoomIds`.
- Verifisert: Kenneths eksakte scenario FØR/ETTER; etasjeløst rom verifisert inkludert via
  `'__none__'`; skew-kabel (39 pathEls, 0 runs) på rotert uteareal verifisert overlever eksport
  uendret; tre-roms scenario (2 innendørs-etasjer + 1 uteareal) verifisert at hver runde viser
  utelukkende sitt eget rom; påstanden bekreftet å faktisk fyre når kun etasje (ikke del) settes
  med vilje. Full regresjonsbatteri bestått på fersk sideinnlasting.
- Ikke testet: ekte innlogget PDF-eksport av et flerdels-prosjekt.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Kabel på roterte områder følger nå sidene, ikke skjermens akser — 2026-08-22

Kenneth (utendørs rampe, InSnow 30T 3700W 120,1m 400V × 3): kabelen la seg vannrett/loddrett i
forhold til SKJERMEN, ikke i forhold til den skrå rampen — trappetrinn og udekkede hjørner ved de
skrå endene.

- **`d44b968` — STEG 0-rapport: målt, ikke antatt.** Bygget en syntetisk rampe (likebeint trapes,
  20° rotert) + Kenneths eget produkt (CVA10710) og kjørte den ekte `_autoFillNCables(...,3,null)`.
  Bekreftet: `_buildNCableZones` setter `_noSkew=true` UBETINGET på hver sone-underrom (ingen
  if-vakt) — `needSkew` blir derfor ALLTID false for enhver flerkabel-sone, uansett rotasjon.
  Isolert bekreftet: SAMME rampe-polygon gjennom ETT enkelt-kabel-kall (ikke sonedelt) velger
  korrekt "skew" med angleDeg=20, dekning 97,8 % — motoren virker perfekt når den nås; `_noSkew` er
  den ENESTE årsaken. Én korreksjon til selve prompten: motoren som faktisk PRODUSERTE Kenneths
  utlegg var IKKE `generateCableSerpentine` (kun et siste fallback) — de faktiske vinnerne var
  **v6** og **boustrophedon**, som begge leser retning som skjerm-akse akkurat som serpentinen.
  Verifisert også: en ekte round-trip (skew-kabel, 39 pathEls) gjennom SAMME lagringsserialisering
  appen bruker + fullt JSON-round-trip — byte-for-byte identisk; PDF/materialliste gjenbruker
  allerede motor-uavhengig kode.
- **`b7d7505` — BLOKKERING 1+2 fikset + syntetisk testområde.** `_noSkew` settes nå kun når det
  HELE, udelte området er akseparallelt (uendret der). For et rotert område beregnes rectilinearity
  og en TVUNGET felles vinkel fra HELE polygonet (ikke hver enkelt avkuttede sone-delform) — samme
  vinkel presses inn i ALLE soner (`_forcedSkewAngleDeg`/`_forcedSkewDir`) så utlegget blir
  sammenhengende. Ny `_skPrincipalAngles`/`_skAngleForDir`: den lengste kanten definerer langsiden
  («Horisontal»), kortsiden er vinkelrett («Vertikal») — Kenneths regel, ikke skjermaksene.
  `generateCableSkew` fikk en `angleDeg`-parameter (var alltid hardkodet `null`). Sidefunn fra
  STEG 0 rettet i samme commit: info-panelets `dirLabel` falt til «Horisontal» for enhver
  skew-kabel siden `.direction` aldri ble satt — viser nå faktisk retning eller «Auto».
  Ny `_cableSkewRegressionTest()` (5 fasit-tilfeller A-E: rotert rektangel, eksplisitt kortside,
  rampe-trapes, akseparallelt som regresjonsvakt, tre kabler med identisk vinkel) — alle 13 sjekker
  bestått. Rotert innendørs InFloor-rom testet direkte (STEG 2): samme kodevei, samme fiks virker
  identisk — sagt eksplisitt, ikke oppdaget senere. Kjent, ikke rørt: rotert flerkabel-sone MED
  hindring ignorerer fortsatt hindringen (pre-eksisterende, dokumentert i egen kommentar —
  «Sub-rooms carry no hindrings»); enkelt-kabel hindring-unngåelse er upåvirket.
- Verifisert: Kenneths eksakte scenario — FØR v6/boustrophedon (skjerm-akse, trappetrinn), ETTER
  alle tre soner skew, identisk angleDeg=20°, dekning 86-89 %. Akseparallelt rom (600×300, single
  og multi): fortsatt boustrophedon, ikke skew. Full regresjonsbatteri (matte/sone/frihånd/folie +
  ny kabel-skew-test) bestått på fersk sideinnlasting.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## InSnow og EcoMat: reglene kommer nå fra databasen — 2026-08-22

Kenneth hadde allerede gjort databasesiden 22.08.2026: kategorien «Varmematte utendørs» + 33
InSnow 300T-artikler (CVA, EL, motstand, kaldkabel 15 m, CC 100, min_gap 50, veggmargin 0,
bøyeradius 42, inntrekk 0, forbandt), fem nye kolonner (`mat_edge_inset_mm`/
`mat_required_gap_mm`/`mat_equal_widths`/`mat_stagger_half_cc`/`mat_length_step_mm`), og EcoMat
60T/100T/150T (57 rader) fylt med de samme regelfeltene. Oppgaven var å fjerne kode-kopiene som
ikke lenger hadde en jobb.

- **`4406e26` — slett InSnow-injektoren og EcoMat-normaliseringen, rydd `el_number` ut.** Slettet
  `_ensureOutdoorMatProducts` (33 hardkodede CVA106xx-artikler + alle regelfeltene) og begge
  kallsteder, og `_normalizeEcoMat` (satte `mat_equal_widths`/`mat_required_gap_mm` på hver
  lasting). `el_number` fjernet overalt (9 forekomster) — riktig kolonnenavn er `el_no`. Ekte
  regresjonsrisiko fanget FØR den ble et problem: `_normalizeEcoMat` sin eneste andre bruker var
  `_ensureEcoMatProducts` sin OFFLINE fallback-gren, som satte `mat_equal_widths` direkte men IKKE
  `mat_required_gap_mm` — å slette funksjonen blindt ville brutt offline EcoMat-utlegg (5cm gap
  som spiser en hel bredde, samme feilklasse som FEIL 1 fra 19.08.2026). Rettet ved å sette feltet
  direkte i fallback-pushen, samt i `_matRegressionTest`/`_matZoneRegressionTest` sine egne
  synthetic-kataloger. STEG 4-rapport over de gjenværende injektorene (ingen fjernet denne
  runden): `_ensureOutdoorCableProducts` er i eksakt samme situasjon som den fjernede
  matte-injektoren (alle InSnow-kabelartikler finnes allerede live) — kandidat for samme
  behandling senere. `_ensureFrostProtectionProducts`/`_ensurePlateTestProducts` er derimot ikke
  fallbacker lenger — de ER produktkilden i dag (ingen av kategoriene finnes i databasen).
  `_ensureVarmecomfortProducts` (19 rader finnes live) — Kenneth har bekreftet ikke viktig, kun
  nevnt. STEG 5: uten Supabase finnes InSnow (Varmematte utendørs) ikke lenger i det hele tatt —
  verken kategori eller artikler opprettes offline; EcoMat er upåvirket (fallback selvstendig
  rettet). En bevisst, rapportert endring, ikke en oppdaget en.
- Verifisert LIVE mot Kenneths egen Supabase (samme anon-nøkkel klienten selv bruker, read-only
  REST): CVA10617 (0,5×22m, 3300W, el_no 1001872) og CVA10624 (0,5×24m, 3600W 400V, el_no
  1003535) finnes med eksakt de feltverdiene injektoren tidligere hardkodet — 33 InSnow-rader og
  57 EcoMat-rader bekreftet totalt. `_matRegressionTest()`/`_matZoneRegressionTest()` bestått, rom
  1110/1105/1102 bit-identiske, på fersk sideinnlasting.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Vunnet er nå sluttstasjonen — leveranse-sporing (akse B) fjernet — 2026-08-21

Kenneth: å trykke «Vunnet» skal bety ferdig — ikke starte enda et sporingsløp. Fjerner
leveranse-aksen (akse B) fra arbeidsflyten helt, ikke bare hopper den forbi et mellomsteg.

- **`b8434a9` — Vunnet = ferdig, ingen leveranse-sporing.** Før aktiverte «Vunnet» automatisk
  akse B (`klar_for_montering`/`klar_for_levering` etter rolle) med egen pille + «Start
  montering»/«Marker levert»-knapp — brukeren måtte klikke videre, en reell dobbel operasjon.
  `_applySalesTransition` setter nå `delivery_status=null` ubetinget i samme patch for enhver
  statusendring (én databaseskrivning, ikke to); `_initialDeliveryStatus` fjernet (ingen kallere
  igjen). `_deliveryCellHtml` returnerer alltid tomt — pillen/knappen vises aldri mer.
  `_deliveryNextAction`/`_advanceDelivery` slettet. `DELIVERY_STATUSES` og dashboardets todo-kort
  (leser `p._deliveryStatus` direkte) er urørt — de teller fortsatt riktig for eldre prosjekter
  med data fra før denne endringen.
- Verifisert: stubbet `_setProjectStatus`, kjørte overgangene vunnet/tapt/under_arbeid — ett
  patch-kall per overgang (var to for vunnet), `delivery_status` alltid null. Fullt
  regresjonsbatteri (matte/sone/frihånd/folie) upåvirket.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte-farger regresjon og splitt-diagnose — 2026-08-21

To oppfølgere til DEL B (per-matte label/flytting): en fargebug forrige commit innførte, og en
grundig — men resultatløs — diagnose av et splittavvik Kenneth rapporterte på rom 1108.

- **`a1560f0` — matte-farger: fikset regresjon fra Modell A.** Rotårsak: fargegrenen i
  `_drawMatPathObj` var betinget på `cat.segments.length > 1` («har DENNE BANEN flere ruller») —
  etter forrige commits splitt til uavhengige objekter har hvert committet matPath alltid
  nøyaktig ett segment, så betingelsen ble permanent usann og alt tegnet i standard blå. Riktig
  spørsmål er «har DETTE ROMMET flere fysiske matter» (`_matPathSegColor`/
  `_matRoomPhysicalPieces` svarte allerede på det) — betingelsen fjernet. Ny regresjonstest i
  `_matFreeRegressionTest()` låser begge former (splittede objekter og eldre fler-segment-
  objekter). Verifisert mot Kenneths egen live Supabase-katalog (EcoMat 150T, hentet via
  anon-API): tre distinkte farger på en 6400cm-bane.
- **`77ce87f` — DEL B STEG 0: kan ikke reprodusere 8+26+30.** Kenneth rapporterte splitt
  30+26+8 der 22+22+20 var ventet. Bygget en skrivebeskyttet diagnosekopi av splitt-
  algoritmen og testet mot Kenneths egen live katalog (19 EcoMat 150T-rader, 2–30m, hentet
  direkte fra Supabase): 20m og 22m finnes begge i katalogen (avkrefter hypotese 1), og et
  bredt sveip av totalCm (6380–8000cm) velger korrekt [20,22,22]-kombinasjonen i alle
  tilfeller — [8,26,30] ble aldri reprodusert. Ingen kodeendring gjort; venter på Kenneths
  faktiske lagrede rom 1108-tall.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matpath klikkvalg og per-matte flytting (DEL B) — 2026-08-21

Kenneth (rom 1108): frihånds-matte kunne ikke velges ved klikk, og en bane med flere fysiske
ruller hadde bare én felles label/posisjon. Tre commits løser begge, med en grundig
STEG 0-rapport imellom.

- **`a7043d1` — frihånds-matte og aluboard kan nå velges ved klikk.** Rotårsak: matpath og
  aluboard manglet begge en egen «body click»-gren i mousedown-nedfallet (bg/strip/cable/...
  har hver sin), så klikk falt gjennom til rommet under. Fiks uttrykt som én regel: ny
  `CYCLE_INLINE_TYPES`-liste (typer med egen gren) — alt annet, inkl. fremtidige typer, løses
  automatisk via `_applyCycleSelection`, i stedet for å legge til nok et hardkodet
  spesialtilfelle.
- **`f0832a0` — STEG 0: Modell A valgt for per-matte label/flytting.** Kartla at én matPath i
  dag betyr én label/posisjon/drag for HELE banen, selv når 7428c56 lot den deles i flere
  fysiske ruller. Valgte Modell A (splitt til uavhengige matPath-objekter ved commit) foran
  Modell B (per-segment-nøkling): `_drawMatPathObj` kaller allerede label-renderen én gang per
  objekt, så splitting gir egen label/posisjon gratis uten å røre rendering-maskineriet.
- **`e840b73` — hver fysisk matte får egen label og flyttepil.** Ny `_matFreeSliceMoves`
  skjærer move-sekvensen ved katalogens ruter-grenser til uavhengige matPath-objekter (én rull:
  bit-for-bit uendret ett objekt). `_matDragging` generalisert med `_matDragKind`
  ('mat'|'matpath') — matPath følger musa fritt under drag og validerer først ved slipp
  (`_matPathMoveValid` = romvakt + ny `_matPathOverlapsOthers` kryss-objekt-sjekk, som ikke
  fantes fra før). Fant og fikset en ekte pushUndo-bug underveis: `matPaths`-snapshotet klonet
  `moves` dypt, men spredte `start` med DELT objektreferanse — angre etter en flyttet matte var
  en stille no-op.
- Verifisert: 55,52m-bane splittet til to uavhengige objekter (26m+28m), egen label/flytting
  per objekt, ulovlig overlapp avvist ved slipp, angre gjenoppretter korrekt (etter
  pushUndo-fiksen). Fullt regresjonsbatteri bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte «Manuell» blir en ekte drag-inn-liste — 2026-08-21

Kenneth avviste forrige økts inline «+»-knapp-løsning direkte: ville ha «Manuell» som en ekte
draggbar liste, nøyaktig som varmefolie — ikke en bane-liste (hans ord: «forvirrende»).

- **`251842a` — startMatManualPlace/renderMatManualPalette, bane-lista fjernet.** Ny
  funksjonspar speiler varmefolies egen `startManualPlace`/`renderManualPalette`-mønster, egen
  versjon fordi matte-feltene (`mat_width_mm`) og drop-målet (`S.mats`) er andre. Gjenbruker
  den delte manuell-palett-widgeten og `S.ui.dragWidth` (nå `kind:'mat'`) i SAMME dragover/
  drop-lyttere som folie — folies egen gren urørt. Slippet gjenbruker `_matPlaceCandidate`
  (samme magnet mot vegg/nabomatte som forrige runde) med ny `drawDropPreviewMat`-ghost i
  folies grønn/gul/rød-fargekonvensjon. Den gamle bane-liste-motoren (`_matManual*`,
  `_matRasterCm`, `_matBaneCableM`, `_matStdSizes` m.fl.) fjernet helt — ingen gjenværende
  kallsteder.
- Verifisert: draggbar HTML for begge InSnow-breddene, full dragover→drop-flyt (tre matter,
  riktig magnet-snappet), ingen gjenværende referanse til «bane-liste»-tekst eller de fjernede
  funksjonene. Fullt regresjonsbatteri bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## UPC dra inn matter og ekte Sentrer — 2026-08-21

Kartla og løste tre blokkeringer i «Fyll rom automatisk»-panelet (UPC): artikkelrader tømte
hele rommet på hvert klikk (umulig å legge flere matter manuelt), en plasseringsmodus fantes
men var uknåelig derfra, og Sentrer slettet+kjørte auto på nytt i stedet for å flytte det som
lå der.

- **`63f4c1d` — STEG 0-rapport.** Kartla hvert inngangspunkt som legger en matte mot om det
  tømmer rommet og nås fra UPC i dag. Bekreftet begge blokkeringer, pluss et ekstra funn
  (utenfor scope): «Manuell (bane-liste)»-raden kalte alltid snø-varianten, aldri innendørs.
- **`e92b528` — «+»-knapp per artikkelrad + gruppe-flytting/avstand.** Hver artikkelrad fikk en
  egen «+»-knapp (samme to-knapps-mønster som plater) som kaller ny `_upcStartMatPlace` —
  rører aldri rommet. Ny delt `_matPlaceCandidate(wp, productId)` (magnet mot vegg/nabomatte,
  aldri under Regel 18) brukes av både ghost og commit. Fant og fikset i samme slag:
  `_startMatPlacement` leste lengde fra et felt som i praksis er tomt for utendørs produkter —
  byttet til samme kanoniske kilde `_matFreeCatalog` bruker. Sentrer/Fra vegg flytter nå
  GRUPPEN av manuelt plasserte matter (`_matCenterGroupInRoom`) i stedet for å slette og kjøre
  auto på nytt, gitt at minst én matte i rommet er manuelt plassert (`_manualPlace`-flagg,
  bevisst atskilt fra den gamle bane-listas `_manualGroup`). Ny `_matSetGroupGap` for felles
  avstand mellom manuelt plasserte matter.
- Verifisert: fire manuelt plasserte InSnow-matter, korrekt magnet-snap, Sentrer/Fra vegg
  flytter alle fire matematisk korrekt, gruppe-avstand klemt til Regel 18-minimum. Fullt
  regresjonsbatteri bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Frihånd matte farge, valg, verktøylinje — 2026-08-21

Tre svakheter rundt en allerede verifisert-riktig frihånds-motor: flere ruller per bane
manglet egen farge/valg, og hadde ingen flytende verktøylinje (ctx-bar).

- **`1120ebf` — delt fargeindeks, segIdx-bevisst valg, ny ctxbar-gren.** Ny
  `_matRoomPhysicalPieces(roomId)` — én ordnet liste over ALLE fysiske matter i rommet
  (S.mats + S.matPaths, én oppføring per segment) — brukt av både `_matColor` og ny
  `_matPathSegColor`, så fargeindeksen går på tvers av begge samlinger (samme felle som
  «rommets produkter» tidligere). Ny `S.ui.selectedMatPathSegIdx` ved siden av
  `selectedMatPathId` — klikk identifiserer nå riktig fysisk segment, ikke bare banen.
  `updateCtxBar` fikk en helt ny gren for valgt matPath (produktnavn/lengde/watt,
  avstand-chip, Sentrer, Slett) modellert på auto-mattas egen — fantes ikke fra før.
  «Målsett»-chip bevisst utelatt (rapportert, ikke bygget — dimensjonslinjene leser kun
  S.mats).
- Verifisert: 55,52m tegnet gir fortsatt nøyaktig 26m+28m (uendret); to segmenter får to
  distinkte farger, en tredje matte i rommet et tredje distinkt tall; klikk identifiserer
  riktig segment ved skjøten. Fullt regresjonsbatteri bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte sone flere matter + frihånd utenfor rom — 2026-08-20

To uavhengige feilklasser, samme mønster: to allerede-låste motorer (sone-deling og
fler-matte-søk; frihånds-klipping og polygon-vakt) hadde aldri møttes.

- **`e5187e8` — DEL A: sone tar nå flere matter; DEL B: frihånd starter ikke lenger utenfor
  rommet.** DEL A (rom 1102): `_matFillRoomSmart` kjørte fler-matte-vurdering kun for
  rektangulære rom — sonedelte rom (Regel 20) fikk maks én matte per sone selv når sonen var
  stor nok til flere. Ny `_matZonePlanFor` kjører samme `_matMultiSolve`-vurdering per sone.
  Fant og fikset underveis: `_matPlaceMultiMats` returnerte `true` i stedet for de committede
  objektene på en vellykket commit — ville trigget en falsk «ingen matter»-feil og en angre
  som kastet vekk et vellykket utlegg. DEL B (rom 1108): `_matFreeStartFor` brukte
  boundingboks-hjørnet som startpunkt, som for et uregelmessig rom kan ligge utenfor selve
  polygonet — søker nå innover til en gyldig skannelinje treffes. `_matFreeClampLen` returnerte
  urklippet lengde når startpunktet ikke fantes i noe polygon-intervall (nå: 0). En avvist
  commit nullstilte hele frihånds-tegningen før («trykker jeg stopp, skjer det ikke stort») —
  tegningen beholdes nå, og Backspace fjerner siste bane.
- Verifisert: to nye regresjonstester (`_matZoneRegressionTest`, `_matFreeRegressionTest`)
  låser rom 1102 (30,96 m² dekket, var ~15-20 m² før) og rom 1108 (alle fire feil). Fullt
  regresjonsbatteri bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Foliemotor score rangerer seg selv sist — 2026-08-20

Kenneths «Rom 4»: foliemotorens egen poengscore rangerte konsekvent bak et dårligere utlegg.
To commits — grundig reprodusert diagnose, deretter fiks.

- **`a3ffaa6` — STEG 0-rapport.** Reproduserte alle fire feil mot en «Rom 4»-analog +
  syntetisk katalog. Feil 1: et ukalibrert 3-poengsbånd i `_statsAtLeastAsGood` lot
  dekningsprosent overstyre scoren FØR den ble konsultert — sone vant med 6 poeng bedre
  dekning men 3× dårligere score. Feil 2: `_longStripsLayout` kunne uttrykke kun én uniform
  bredde i hele rommet. Feil 3: sonepakkeren lar aldri en bane krysse en sonegrense. Feil 4:
  `widthTypes` telt på produkt-id ett sted, nettobredde et annet — samme tallgrunnlag
  divergerte tre steder.
- **`8595889` — fjernet 3-poengsbåndet, ny adaptiv flerbredde-kandidat, watt-nyttegrense.**
  Feil 1 fikset ved å fjerne det ukalibrerte båndet. Feil 2 (Regel 21 folie): ny kandidat
  gjenbruker `_autoFillRoomOnce` sin allerede eksisterende adaptive flerbredde-modus, vurdert
  med samme score. Feil 4: `widthTypes` telles nå konsekvent på nettobredde. Ny
  `FOIL_MIN_USEFUL_WATT=15` fanger smale/korte sliver-striper. Ny `_foilRegressionTest()`
  låser Rom 4 som fasit.
- Verifisert: Rom 4 velger nå h-global (score 94290, høyest) i stedet for h-sone (score 40240,
  lavest av fire). Rektangulært rom uendret. `_foilRegressionTest()` og `_matRegressionTest()`
  begge bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte frihånd flere matter + romlista — 2026-08-19

Kenneth: en 52m tegnet frihånds-bane skulle bli to matter (26+26m), ikke én 1×30m — og en
frihånds-matte manglet helt i sidepanel/Excel.

- **`976215d` — STEG 0-rapport.** Svarte fire spørsmål før koding: EcoMat-fallback-katalogen
  har 19 lengder inkl. 26m; kaldkabel finnes ikke på matteprodukter (splitten regner uten
  fratrekk); U-svinger er allerede del av totalCm; delepunkt kan allerede falle midt i en bane
  (gjenbrukbart mønster).
- **`7428c56` — DEL A: én bane kan gi flere matter; DEL B: vises overalt.** Ny
  `_matFreeSplitPlan(totalCm, cands)` deler én tegnet lengde i færrest mulige katalogruller, så
  like som mulig ved uavgjort (26+26 foran 24+28 foran 22+30) — verifisert mot alle Kenneths
  egne tall. `_matFreeCatalog` returnerer nå `{segments[], coverCm, ...}` i stedet for ett
  flatt objekt; alle sju kallesteder oppdatert (materialliste, panel, toast, tegning). DEL B:
  sidepanelets «Varme»-seksjon manglet matPaths helt (rom med kun frihånds-matte fikk
  `totalElements=0`, seksjonen skjult); `_exportMaterialListXLSX` hoppet over matPaths helt.
  Ny `_assertProductSurfacesCoverAllCollections()` (kjørt automatisk i dev) fant i tillegg at
  HTML-materiallisten manglet Aluboard — fikset i samme slag.
- Verifisert: `_matFreeSplitPlan` gir 5200cm→[2600,2600], 3100cm→[3000+rest]. Ekte flyt: toast
  «2 × EcoMat 0,5x26m». Rom med kun frihånds-matte viser nå «Varme (2)». Assertion fant 0
  lekkasjer etter fiksen (7 før). `_matRegressionTest()` bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Fyll rom automatisk bruker nå hele motoren — 2026-08-19

Rom 2104 (26,3 m²) fikk kun 1×15m² med udekkede hjørner via «Fyll rom automatisk ★
Anbefalt» — appens faktiske hovedvei.

- **`c4f4429` — UPC-auto ruter nå gjennom sone-oppdeling og flermatte.** Rotårsak: UPC sin
  'auto'-gren kalte `autoFillMatSerpentine` direkte og hoppet over BÅDE `_matPlanZones`
  (Regel 20) og `_matMultiSolve` (Regel F/G) — begge fantes og var verifisert, men ble i
  praksis kun nådd via et sjelden brukt eldre panel. Ny `_matFillRoomSmart(productId, opts)`
  med `opts.skipPushUndo` — `_upcPlaceMat(...,'auto')` kaller nå denne i stedet: sone-sjekk
  først, så flermatte, så ett-blokk som fallback. Løst med ÉN angre-ramme: tømming +
  fyllforslag + utlegg deler ett undo-steg; «Avbryt» i forslagspanelene kaller `undo()` for å
  gi rommet tilbake.
- Verifisert: rom «2104»-analog (L-formet, 27,5 m²) viser nå sonepanel (2 soner, 27,5 m²
  dekket i stedet for 15 m² i ett blokk), ett angre-steg for hele operasjonen. Stort
  rektangulært rom viser flermatte-panel. Lite rom (plass til én matte) uendret direkte
  utlegg. `_matRegressionTest()` bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Rommets produkter, én kilde — 2026-08-19

Kenneth: «Tøm rom» så ikke frihånds-matter. Kartleggingen fant åtte flere steder med samme
hull.

- **`05390a0` — STEG 0-rapport.** Bekreftet at `_clearRoomProducts` og seks «erstatt rommets
  produkter»-kallsteder kun teller strips/cables/mats/plates — matPaths og aluboard mangler
  overalt, inkl. «Slett rom». Tre ekstra hull funnet: `_listDeleteRoom` («Hurtig
  prosjektering») kaller aldri `_cleanupRoomData` i det hele tatt; XLSX-materiallisten mangler
  matPaths helt; `pushUndo` tar ikke snapshot av `S.matPaths` (nylig tegnet frihånds-matte kan
  ikke angres).
- **`d480535` — ROOM_PRODUCT_KEYS, ni kallsteder samlet.** Ny
  `ROOM_PRODUCT_KEYS = ['strips','cables','mats','matPaths','plates','aluboard']` + to delte
  funksjoner brukt av alle ni kallsteder. `_listDeleteRoom` bruker nå samme `_cleanupRoomData`
  som hoved-«Slett rom» (var: egen, ufullstendig opprydding). Ved prosjektinnlasting fjernes
  nå foreldreløse matPaths/aluboard (roomId som ikke finnes) og logges. Ny
  `_assertRoomFullyDeleted(id)` i dev-modus fanger fremtidige lekkasjer. Bonus: `pushUndo`/
  undo fikk `S.matPaths` (kvalitetskrav for angre-testen). Ryddet en reell TDZ-krasj underveis:
  `ROOM_PRODUCT_KEYS` ble referert før sin egen const-linje hadde kjørt, knakk hele scriptet
  ved første «Slett rom».
- Verifisert: rom med kun frihånds-matte eller kun Aluboard — «Tøm rom» finner og fjerner
  begge nå. Angre etter Tøm rom gjenoppretter matPaths. `_assertRoomFullyDeleted` fant 0
  lekkasjer etter fiksen. `_matRegressionTest()` bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte utendørs tak + frihånd-avslutt — 2026-08-19

Et 4-matters-tak (satt for innendørs bruk) blokkerte store utendørs felt, og frihånds-tegning
kunne ikke avsluttes med Enter.

- **`58e6287` — MAX_MATS skalerer med arealet; Enter/Escape for frihånd.** «Obs Bygg» (195,3
  m², InSnow 300T, trenger 9-10 matter) falt tilbake til én matte fordi søket ikke fant en
  løsning innenfor det faste taket på 4. Taket er nå
  `min(40, max(2, ceil(kapasitetsareal/største matte)))`. Fant og fikset (bekreftet med
  Kenneth før koding — endret en tidligere låst regel): `_matMultiSolve` stoppet ved FØRSTE N
  med noen gyldig løsning, selv om den dekket en brøkdel av arealet — søket klatrer nå N
  oppover til target nås. Frihånd: Enter avslutter+committer, Escape avbryter uten å legge noe
  ut (samme mønster som polygon/wbw-tegning, manglet helt for matte). Stopp-punktets treffsone
  er nå delt kilde med ikonets tegnede radius og vokser ved utzooming.
- Verifisert: Obs Bygg gir nå N=9, 162 m² av 174,8 m² kapasitet (var 36 m² for N=2). Regresjon
  rom 1110/1102 uendret. Frihånd: Enter committer, Escape avbryter, begge nullstiller korrekt.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte dekning slår like bredder i variantvalget — 2026-08-19

Bekreftet med Kenneth via spørsmål før koding, siden endringen svekker en låst regel
(Regel 6).

- **`f2dc648` — Regel 6 (like bredder) rykker ned til tie-break.** Rom «2102 Dusj» (12,78 m²)
  valgte 0,5×20m (10 m², 118 W/m² BTA) fremfor 0,5×22m (11 m², ~129 W/m² BTA) selv om 22m fikk
  plass — fordi 22m ikke gikk opp i hele 16cm-kuttenheter mens 20m gjorde, og variantvelgeren
  prøvde nedover for å redde like bredder på bekostning av dekning. Ny prioritet: velg alltid
  størst variant ≤ kapasitet, punktum — like bredder brukes nå kun som tie-break mellom
  varianter med IDENTISK dekning. Går ikke valgt variant opp i like bredder, brukes
  eksisterende fallback (N−1 like + kortere siste, forankret i skjøtenden — hele rullen legges
  fortsatt ut eksakt).
- Verifisert: rom 2102 velger nå 0,5×22m (5 bredder, 4×448+1×408cm, 2200cm=hele rullen).
  Panelmelding forklarer avveiningen eksplisitt. Regresjon rom 1110/1105 (går allerede opp i
  like bredder) uendret.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte frihånd overlapp og areal — 2026-08-19

Rom «2102 Dusj» (12,70 m²) lot brukeren tegne en frihånds-matte som fysisk overstiger hele
gulvarealet — vakten sjekket kun hver banes lengde mot rommet, aldri baner mot hverandre.

- **`d1f7348` — ny areal- og overlapp-invariant, live-blokkert.** Ny delt
  `_matUsableAreaM2(room, marginCm)` (polygonareal minus omkrets×kantmargin) og
  `_matFreeLanesOverlap` (parvis rektangel-overlapp med 0,5cm toleranse for «inntil»-naboer).
  Blokkerer nå LIVE (ikke bare ved commit): `_matFreeCandidate` setter `overlaps=true`+`len=0`
  for en tentativ bane som ville overlappet, ghosten tegnes rød med forklarende etikett. Samme
  arealsjekk lagt til i auto-veiens `_matRunsWithinRoom` — fanget en direkte konstruert
  6-bredders matte der en tverr-posisjon havnet utenfor rommet (aldri validert av den
  eksisterende, kun langs-akse-baserte klippingen).
- Verifisert mot rom 2102: 5 gyldige baner ingen falsk alarm, 6. bane (side-flip på 3.)
  korrekt avvist. Flush-naboer (0cm gap) fortsatt lovlig. Panelet viser «Brukbart areal»/
  «Dekket areal». `_matRegressionTest()` bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte sonedeling — Regel 20, rom 1102 — 2026-08-19

Kenneths avklaring (spurt, ikke avgjort selv): et L/T-formet rom som 1102 skal deles i soner,
med udekket felt heller mot ytterveggene enn mellom sonene — samme prinsipp folie har hatt
siden juli, aldri løftet til matte.

- **`8684bf2` — sone-oppdeling portert fra folie (`_decomposeRoomToRects`).** Rotårsak: hele
  mattemotoren regnet på ÉN blokk med ETT ankerpunkt — i et L/T-rom bidro store deler av
  arealet med 0 til kapasitetsestimatet (rom 1102: 32,0 m² tegnet, appen fant plass til bare
  14 m², 66 W/m² av 150 W/m²-mål). Ny `_matPlanZones(room, prod)` gjenbruker folies
  `_decomposeRoomToRects`; rektangulære rom (≤1 sone) beholdes uendret (hovedregresjonstest).
  Sone-bevisst margin via `_rectEdgeIsSoneBoundary` — 0 margin på kanter mot en nabosone, full
  margin kun på ekte vegger. Ny `_matClipSegsToZone` hindrer en bredde i å «lekke» inn i en
  nabosone. Ny `_showMatZoneProposalPanel` viser hvilken matte i hvilken sone med ett felles
  undo-steg.
- Verifisert: L-formet 33,1 m²-analog gikk fra 16,16 m² dekket (73 W/m² BTA) til 21,84 m² (99
  W/m² BTA). Rektangulære rom (1110/1105) fortsatt bit-for-bit uendret, ingen sonepanel vises.
  `_matRegressionTest()` bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte min_gap_mm — dobbel betydning skilt i eget felt — 2026-08-19

Tredje gang samme feilklasse denne uken: ett databasefelt med to betydninger blandet sammen.
`min_gap_mm` betyr «kabel-til-kabel-avstand» for EcoMat, men ble lest som «påkrevd mellomrom
mellom bredder» — feilen fanget kapasitetsestimatet, ikke bare selve plasseringen.

- **`6d28f31` — nytt felt `mat_required_gap_mm`, entydig betydning.** EcoMats ekte
  Supabase-rader har `min_gap_mm=50`, men det oppfylles allerede av kant-inntrekket (2cm hver
  kant); Regel 18 leste feilaktig dette som påkrevd bredde-mellomrom, presset maxRuns fra
  riktig 5 til 4 på rom 1110 og gjorde gap=0 utilgjengelig for EcoMat. `_normalizeEcoMat`
  setter nå `mat_required_gap_mm=0` for EcoMat; `_matProductMinGapCm` leser det nye feltet,
  faller til 0 hvis usatt (aldri en gjetning fra `min_gap_mm` igjen).
- **`290015e` — gapet kappes nå mot det som faktisk får plass.** Regel 9 håndhevet kapping kun
  i selve plasseringssteget, ikke i kapasitetsestimatet — et ukappet gap (7cm på rom 1110) ga
  et kunstig lavt kapasitetsestimat (1024cm mot riktige 1280cm) og fikk motoren til å velge en
  for liten variant selv om antallet bredder var riktig. Fiks i den delte `_matAreaGeom`-
  kjernen (gjelder enkelt- og flermatte-veien samtidig): gapCm kappes til det som faktisk går
  opp ved maxRuns bredder FØR noe nedstrøms leser det. Ny panelvarsel «Mellomrom kappet:
  ønsket Xcm → Ycm».
- **`4ab4ff3` — rom 1110 og 1105 låst som regresjonstester.** Rom 1110 hadde pendlet 5→4→5→4
  bredder over fem commits — ny `_matRegressionTest()` (kjørbar fra konsollen) låser begge rom
  mot et syntetisk katalog bygget i samme mønster som ekte Supabase-rader.
- Verifisert: rom 1110 med gap=7cm gir nå 5 bredder à 240cm = hele rullen (var 4 bredder / feil
  variant). `_matRegressionTest()` bestått på begge rom.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte hindring-forhåndsbeskjæring fjernet — 2026-08-19

En levning fra før per-bredde-klipping fantes: en grådig forhåndsbeskjæring krympet hele det
brukbare rektangelet til den største hindringsfrie SIDEN — én hindring om gangen, i stedet for
at kun den ene bredden ble kortere.

- **`f28c9d9` — presis per-bredde-klipping erstatter grov forhåndsbeskjæring.** Reprodusert i
  rom 1110 + én hindring: `alongSpan` falt fra korrekt ~262cm til 142cm. Forhåndsbeskjæringen
  fjernet — det brukbare rektangelet er nå kun romboksen minus veggmargin; sikkerhetsnettet
  (`_matRunsWithinRoom` + per-bredde `_matClippedSegments`) står urørt. Fant og fikset et
  sekundært, tidligere usynlig problem i Regel H sin nedgraderingsløkke: en hindring midt i én
  bredde skapte et shortfall løkka aldri klarte å fjerne (samme lokale klipping uansett
  rullengde), så løkka krympet i verste fall ALLE fem breddene til 0. Løkka sporer nå det BESTE
  forsøket (minst bortkastet materiale) i stedet for blindt det siste.
- Verifisert: rom 1110 uten hindring uendret (Kenneths fasit). Med hindring midt i én bredde:
  fire bredder holder full lengde, kun den rammede bredden blir kortere (ikke null, ikke hele
  rommet). Snø-veien (samme delte kjerne) fikk samme forbedring gratis.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Én mattemotor for alle — 2026-08-19

Tre parallelle mattemotorer fantes (auto innendørs, snø-auto, frihånd) — kun én fulgte det
låste regelsettet (Regel A-J, 1, 8, 9, 13, D, E, F/G). Fjerde motor (Manuell bane-liste)
flagget, ikke rørt.

- **`9ffbdd0` — STEG 0-rapport.** Bekreftet tabellen: `_packSnowMats` (snø) og
  `S.matPaths`/frihånd er separate motorer uten det låste regelsettet. Snø sin N-formel er en
  LEVENDE REGRESJON — bruker nøyaktig det gap-i-formelen-mønsteret Regel 8 nettopp fjernet
  innendørs. Kenneths svar på tre åpne spørsmål: InSnow skal legges som EcoMat (bredde-modell
  erstatter kolonne-modell, ikke lappes), ny Regel 19 (InSnow i forbandt, EcoMat i flukt).
- **`49d469d` — STEG 1: én delt geometri-kjerne.** Ny `_matAreaGeom(room, ctx)` erstatter to
  nesten identiske kopier (enkelt-matte og fler-matte). Margin/gap er nå PARAMETERE, ikke lest
  fra produktet inni kjernen — det er det som lar snø (marginCm=0) bruke samme funksjon uten
  en if(snø)-gren.
- **`cc97abd` — STEG 2: snø delegerer til `autoFillMatSerpentine`.** InSnow legges nå som
  EcoMat — ett mat-objekt, klippet mot områdets ekte polygon (ikke en boundingboks) — og får
  Regel 1/A/D/E/13 og vakten `_matRunsWithinRoom` gratis. Ny Regel 8+18: produktets PÅKREVDE
  minsteavstand (InSnow min_gap_mm→5cm) kan aldri senkes av brukeren, ulikt Regel 9 sitt
  ønskede gap. Ny Regel 19 (forbandt): annenhver InSnow-bredde forskyves en halv CC.
- **`63c1e39` — STEG 3: frihåndsvakt mot regelbrudd ved commit.** Ny
  `_matFreeRunsWithinRoom(mp)` sammenligner faktisk tegnet lengde mot samme klippefunksjon
  tegningen selv brukte, avbryter commit ved avvik.
- Verifisert: InSnow-felt med hindring gir samme forbedring som EcoMat (full lengde på
  upåvirkede bredder). Rom 1110 (EcoMat) uendret. `_matRegressionTest()` bestått gjennom alle
  fire steg.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte gap-fordeling — Regel 8+9 — 2026-08-19

Kenneths rom «1110 Lærergarderobe HC» (279×272cm): ett cm mellomrom i innstillingene kostet
en hel bredde, og dermed en hel mattestørrelse.

- **`11c9a0e` — Regel 8: mellomrommet skal aldri koste en bredde.** Rotårsak: `maxRuns` ble
  regnet som `floor((acrossSpan+gapCm)/(matWidthCm+gapCm))` — brukerens mellomrom spiste plass
  FØR antall bredder ble bestemt. Fiks: antallet regnes nå kant-i-kant,
  `floor(acrossSpan/matWidthCm)` — ingen gap-ledd. Rettet i tre identiske forekomster
  (enkelt- og flermatte-veien regnet ellers ulikt antall).
- **`936452b` — Regel 9: mellomrommet er en fordeling av slakk, ikke en reservasjon.** Ny
  `S.varmematte.gapCm=null`-tilstand + `_matResolveGapCm`/`_matDefaultGapCm`: standardverdi =
  CC − 2×kant-inntrekk (fysisk begrunnet, verifisert mot TPL-ECOMT-CA-2183). Gapclamp utvidet
  0-5cm → 0-10cm (5cm rakk ikke for 60T/100T sitt 7cm-standardgap). Fant og rettet i samme
  slag: `S.varmematte` ble lagret men ALDRI lest tilbake ved prosjektåpning (rapportert i
  786d95a, fikset her) — gap-innstillingen nullstilte seg stille ved hver reåpning.
- Verifisert: rom 1110 med `gapCm=null` gir standardgap 4cm, 5 bredder à 240cm = hele rullen —
  eksakt Kenneths fasit. gap 0/2/5/null gir alltid 5 bredder. Lagre→gjenåpne overlever nå
  (feilet før). `_matRegressionTest()` bestått.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte-kabel i eget nett — Regel I+J — 2026-08-19

Kritisk regresjon Kenneth bekreftet på nytt etter tre tidligere fikser samme uke: den røde
kabelen tegnet fra blokkens nominelle posisjon, ikke fra samme kilde som det blå nettet.

- **`5bdc0c0` — `_matCablePlan`, delt kilde for nett og kabel.** På rom «1105 Dusj» stakk
  kabelen for én klippet bredde 35cm forbi nettets egen ende — alle 11 bredders kabel lå på en
  fast, blokk-relativ posisjon uavhengig av nettets faktiske plassering. Vakten validerte kun
  nettet, ikke kabelen, og besto derfor mens tegningen var feil. Låst Regel J (Kenneths egen
  forenkling): hver bredde er uavhengig — ingen bredde er bundet til naboens ende, den fysiske
  ~1m forbindelseskabelen som rives fri i praksis telles/tegnes ikke. Ny delt `_matCablePlan(mat,
  prod)` brukt av BÅDE `drawMats` og en utvidet `_matRunsWithinRoom`, med ett FAST
  verdensbasert rutenett i stedet for en «vandrende indeks» — to nabobredder flukter
  automatisk uten sentral tilstand.
- Verifisert: bredde 10 sin kabel nå [48,200], innenfor nettets [45,205] (var [88,240], 35cm
  utenfor). 0 kabelpunkt utenfor rommets polygon på full end-to-end via `autoFillMatSerpentine`.
  Regresjon (uklippet rektangel): k-sekvens bit-for-bit identisk med den gamle algoritmen.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Etasjen er vanntett — 2026-08-19

Bakgrunnstegninger og målelinjer kunne lekke mellom etasjer. Kartlagt full bredde (ikke bare
det Kenneth selv fant) før noe ble fikset.

- **`786d95a` — STEG 0-rapport.** Bekreftet: `S.floatingDims` har ingen `floorId` og filtreres
  ikke — to EKSTRA steder (klikk-hittest, `_hitDimLine`) har samme hull, ikke bare tegningen.
  To flere hull, ikke etasje-relatert: `S.groups` mangler i lagring/gjenoppretting;
  `S.varmematte` lagres men leses aldri tilbake.
- **`a2365c4` — STEG 1-4: én plantegning per etasje.** Ny delt `_onActiveFloor(obj)` —
  roomId-objekter delegerer til eksisterende logikk, floorId-objekter (floatingDims)
  sammenlignes mot `_effectiveActiveFloorId()`; mangler objektet begge, er svaret alltid
  «nei», aldri «vis for sikkerhets skyld» (samme antakelse som ga bb627f6 sin bug).
  `S.bgLayers` (flere lag på samme etasje) fjernet helt — `_addBgToFloor` oppretter nå en NY
  etasje når etasjen allerede har en bakgrunn. Flerside-PDF-import fikk «+ Ny etasje»-
  standardvalg (tre sider gir tre etasjer). Fant og rettet i samme slag: `_activeBgLayer()`
  (ctxbar) hadde samme «vis for sikkerhets skyld»-fallback-mønster som bb627f6, bare i en
  kontroll i stedet for tegningen; `_resetProjectState` nullstilte ikke floatingDims/groups
  (et nytt prosjekt kunne arve forrige prosjekts målelinjer).
- Verifisert: floatingDims synlig og klikkbar KUN på riktig etasje. Lagre/åpne: floatingDims
  og groups overlever nå (var 0/0 før). Flerside-import ga tre distinkte nye etasjer for tre
  sider.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Gulvføler per oppvarmet rom + MAT_ACCESSORIES — 2026-08-19

Matte fikk ingen tilbehørsliste i det hele tatt, og følerrør-tellingen for kabel dekket ikke
matte-rom.

- **`6087789` — delt `_heatedRoomIds()`, ny MAT_ACCESSORIES.** STEG 0-funn: varmefolie har
  heller ingen følerrør-oppføring — samme forhåndseksisterende hull som matte, delvis dekket
  (ikke løst helt) av denne fiksen. Følerrøret (CVA10526) er det eneste artikkelnummeret
  funnet — selve følingsutstyret følger med termostatvalget, et installasjonsvalg. Ny delt
  `_heatedRoomIds()` (union av kabel+matte+folie-rom, kun innendørs) løser dobbelttelling uten
  spesial-logikk i render/lese-koden: strømmer gjennom den eksisterende generiske
  qty-mekanismen. `kabel_folerror` byttet fra kun-kabel-rom til hele den delte totalen; ny
  `mat_folerror` fyller resten når kabel-seksjonen ikke allerede dekker den.
- Verifisert: rom med kabel+matte i samme rom telles kun én gang (sum=3 for tre distinkte
  oppvarmede rom, ikke 6). Begge følerrør-avkrysningsbokser huket manuelt av → likevel kun ett
  følerrør-element (matte bidrar 0). Rent matte-prosjekt: dialogen åpnes nå (var hoppet over).

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## To visningsfeil: bakgrunn og matte-dimming — 2026-08-19

To uavhengige, men beslektede visningsfeil: alle etasjers bakgrunn tegnet oppå hverandre ved
åpning, og en matte i et ikke-valgt rom mistet både serpentin og label.

- **`bb627f6` — FEIL 1: aktiv etasje settes ved åpning.** `activeFloorId` ble aldri satt i
  `_restoreProject` — filteret i `drawBgImage` er kun sant når en etasje faktisk er valgt, så
  rett etter åpning tegnet ALT uansett etasje, helt til brukeren klikket et rom. Fiks:
  `_restoreProject` setter nå aktiv etasje til lagret verdi (ny `ui.activeFloorId` i lagringen)
  eller delens første etasje. Samlet den driftende doble betingelsen til én delt
  `_bgKeyOnActiveFloor` — null betyr nå «vis kun global», aldri «vis alle».
- **`f249db7` — FEIL 2: matte og label vises nå uansett valgt rom.** `dimOther` skjulte
  serpentin og label for enhver matte utenfor det valgte rommet og tvang fargen til default
  blå — matte var unntaket blant varmekildetypene (drawCables/drawStrips har aldri hatt dette).
  `isOtherRoom`/`dimOther` fjernet fullstendig fra `drawMats`; seleksjon er fortsatt synlig
  som sterkere strek, den fjerner bare ikke lenger innhold for naboene.
- Verifisert: to etasjer med bakgrunn — `activeFloorId` settes umiddelbart ved åpning, kun
  riktig etasjes bakgrunn vises. To rom med matte, rom 1 valgt: label tegnes for BEGGE roomId
  nå (var kun det valgte).

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte Regel H — aldri overskudd — 2026-08-18

Rom «1105 Dusj»: en bredde forankret i sømenden kunne havne utenfor romformens faktiske frie
segment, selv når et stort fritt segment fantes et annet sted i samme rad — bredden ble da
ikke tegnet i det hele tatt.

- **`b85c30a` — fallback-forankring + nedgraderingsløkke.** STEG 1: når intet segment
  inneholder det opprinnelige ankeret, velges nå det LENGSTE segmentet som faktisk finnes på
  breddeposisjonen, forankret fra samme side. STEG 2: kapasitetsanslaget er et gjett mot
  boundingboksen, ikke den innhukk-klippede formen — ny løkke (maks 5 forsøk) i
  `autoFillMatSerpentine`: legg ut, MÅL faktisk klippet lengde, går ikke valgt rull opp (>1
  kuttintervall til overs) → gå ned til neste mindre katalogvariant og legg om helt fra
  begynnelsen. STEG 3: fjernet «⚠ Overskudd — kan legges løst»-toasten helt for automatisk
  utlegg (kun manuelt utlegg beholder den).
- Verifisert: rom 1105-analog — alle 11 bredder tegnes nå, laidCm=2400=totalLengthCm eksakt,
  ingen overskudd. Nedgraderingstest konvergerte 24m→20m→16m→12m eksakt. Rent rektangulært rom:
  bit-for-bit uendret.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Motor-tilkobling: robust adresseoppløsning og kaldstart-toleranse — 2026-08-18

Lumelo-motorens (auto-import) tilkobling var skjør — en død lagret adresse blokkerte hele
import-flyten, og kaldstart på Fly ga en generisk feilmelding.

- **`e4df303` — 4-stegs adresserekkefølge + automatisk omprøving.** `_resolveEngineUrl`:
  window-override → lagret adresse (kun hvis helsesjekket OK) → localhost:8000 (kun lokalt) →
  Fly-motoren som standard overalt. `/health` pinges så tidlig som mulig ved alle
  import-triggere, cachet 15s. Ny `_engineFetchWithRetry`: feiler import-fetchen, pinges
  `/health` til den svarer (tak 20s), så prøves samme forespørsel på nytt ÉN gang, med
  «Starter motoren …»-toast. Ny statuslinje + nullstillingslenke i begge import-modalene, og
  en samlet `_engineErrorDialog` (viser prøvd adresse, feiltype, Fly/Nullstill/egen-adresse-
  knapper) erstatter de gamle `prompt()`-dialogene.
- Verifisert LIVE mot ekte Fly-motoren: et ekte kaldstart-oppvåkningsforsøk tok 21,7s
  (bekrefter 20s-taket er realistisk). Fant (ikke rørt, egen repo) en feilklasse i
  lumelo-backend: en nesten-gyldig PDF gir «Failed to fetch» uten CORS-headere ved dypere
  parse-feil — omprøvingen håndterer den trygt, men rotårsaken ligger i backend.

**Fil:** romtegner.html.

---

## PDF-bakgrunn: sidevalg og fordeling på etasjer i én operasjon — 2026-08-18

Flerside-PDF-import manglet en sidevelger og kunne kun importere én side om gangen — Kenneths
eget scenario («Sten Tærud Skole», flere etasjer i én PDF) krevde re-import per side.

- **`9227e37` — sidevelger-modal + batch-import.** STEG 0 (fallgruve, rettet først): «samme
  fil» ble avgjort på filnavn alene — to sider av samme PDF kunne arve hverandres kalibrering.
  Identitet er nå fil + sidenummer. STEG 1: ny modal med én rad per side (miniatyrbilde,
  papirformat, bokmerke-tittel når den finnes). STEG 2: én «Importer»-knapp legger ut alt
  tildelt i ett steg, hver side kalibreres separat (ingen kjede av popup-er). STEG 3:
  papirstørrelse regnes nå PER SIDE, ikke én gang for hele dokumentet. STEG 5: `bg.pageNumber`
  og papirmål lagres nå i prosjekt-JSON-en (manglet helt før, også for enkeltside-import —
  «Fast målestokk» mistet presisjon etter hver lagre/åpne-runde).
- Verifisert (mock pdf.js-dokument): 3-siders scenario — side 2→1. etasje, side 3→2. etasje i
  én operasjon, begge riktig papirstørrelse. Fallgruve-testen bekreftet feilet før fiksen,
  passerer etter. Enkeltside-PDF uendret (ingen modal).

**Fil:** romtegner.html.

---

## Matte: flere matter i samme rom — Regel F+G — 2026-08-18

Store rom (som 1102, 32,0 m²) kunne kun få én matte, selv når flere ga bedre dekning.

- **`72f9267` — STEG 1-4: `_matMultiSolve`-søk + geometri + panel.** STEG 0 avklart med
  Kenneth: bruk det ekte 16cm-kuttintervallet strengt, aksepter at 15m²-matter sjelden går opp
  eksakt (avviker bevisst fra Kenneths egne illustrasjonstall). STEG 1: uttømmende søk over
  gyldige lengder × mattesammensetninger (like/ulike, N=2-4) — Regel F pkt. 1 («færrest mulig
  matter») er en STRENG prioritet, søket stopper ved første N med gyldig løsning uansett hvor
  mye bedre en høyere N ville dekket. STEG 2: `_matPlaceMultiMats` plasserer mattene i
  sammenhengende blokker, hver klippet og vaktsjekket uavhengig — INGENTING committes før ALLE
  validerer. Geometri-oppsettet bevisst DUPLISERT fra enkelt-matte-funksjonen (ikke delt) —
  kompleksiteten der er allerede høy nok. STEG 3: nytt forslagspanel med like/ulike-alternativ,
  huskes for økta. STEG 4: materialliste og labels verifisert allerede riktige for flere
  objekter (ingen kodeendring trengtes).
- Verifisert: rom «1102»-analog (640×500cm) — «2 like matter, 24,0 av 29,8 m²» plassert
  kontiguøst, begge validert. Lite rom under terskelen: uendret enkelt-matte-vei.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte jevne bredder — Regel E — 2026-08-18

Ved automatisk utlegg skal alle bredder på en EcoMat-type matte ha SAMME lengde, ingen kort
siste bredde — marginen mot langveggene er justeringsvariabelen (samme prinsipp som
trappekabelens Regel 12).

- **`dc203fd` — ny `_matEqualWidthNL`, bekreftet Regel A/B allerede fikset.** Verifiserte
  først at Regel A (posisjon fra samme klip-kilde som lengde) og Regel B (kapasitetstak)
  allerede virket riktig fra en tidligere commit (deae659) — ingen kodeendring nødvendig der.
  Ny `_matEqualWidthNL(totalLengthCm, cutCm, maxRuns, alongSpanCm, minLenCm)`: finner
  (N,L)-paret som forbruker hele rullen eksakt. Variantvelgeren prøver opp til 3 nabovarianter
  for en gyldig (N,L); går ingen opp, faller tilbake til den gamle «N-1 like + kortere siste»-
  modellen. Ny vakt `_matRunsMatchRule` (Regel D/E) kjøres rett før commit, hopper over sjekken
  når romformen faktisk har klippet en bredde (et innhukk kan legitimt gjøre at summen ikke
  matcher uniform lengde uten at noe ligger utenfor rommet).
- Verifisert: Kenneths eget regnestykke (24m/16cm=150 enheter, N=10→L=240cm) traff eksakt. 1cm
  knappere langspenn: riktig fallback til gammel modell, ikke et sprang til en mye mindre
  variant.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Trapp-utskrift per-sone og oppløsning — 2026-08-18

Seks steg som gjør trappe-PDF-en (Regel 16-18) ryddig og lesbar: fjerner støy, viser tall per
sone i stedet for én misvisende sammendragsrad, retter flateeffekt-formelen overalt, legger
målsetting på selve utskriften, gir valg for antall like kabler, og løser en alvorlig
oppløsningsbug på lange trapper.

- **`6fa167a` — STEG 1: fjern støy, fiks dobbel bunntekst.** Fjernet redundant måltekst-
  stempel og en sammendragslinje som kun talte FØRSTE trinn-serie (direkte feil for trapper med
  blandet trinn/repos). Fjernet «Oppvarmet areal» (uinteressant for en trapp som stråler ut i
  luft på tre kanter). Fikset dobbel bunntekst — bunnteksten ble stemplet to ganger per side,
  viskerektangelet dekket ikke toppen av teksten.
- **`0605f58` — STEG 2: per-sone-blokker.** Ny `_stairSoneGeometryBlocks` grupperer berørte
  trinn i sammenhengende «trinn-serier» (ny gruppe ved endring i bredde/N/CC, eller hull i
  rekkefølgen) — leser strengetall/CC direkte fra rutingen, regner aldri på nytt.
- **`a1774a6` — STEG 3: flateeffekt fra CC overalt.** Fem andre steder viste fortsatt et
  arealbasert tall (feil av samme grunn som PDF-en) — `_stairPerStepWm2` er nå eneste kilde,
  brukt av ctx-bar, innstillingspanel og forslagsmotoren. Fant og fikset en reell krasj
  underveis («areaM2 is not defined»).
- **`899206e` — STEG 4: målsetting fra appen på utskriften.** Samme flate-utvalg og linje-/
  pil-mønster som skjermens dimensjonering, med kollisjon-avverging på lange trapper (dropper
  CC-tallet, beholder tikk-streken, når avstanden er for smal).
- **`a87f2cf` — STEG 5: valg for antall like kabler (Regel 18).** Nytt felt «Antall kabler» +
  «Like lengder»-avhuking. Går det ikke opp: spesifikk feilmelding i stedet for den generiske
  «matcher ikke dimensjonene».
- **`f13a5a1` — STEG 6: oppløsning på lange trapper.** Rotårsak: et fast 800×500-lerret ga kun
  0,458 px/cm på en 150×1468cm-trapp — skalaen ble låst av lerretets korte side. Løsning: PNG
  i stedet for JPEG, lerret dimensjonert mot en ønsket trykt oppløsning (150 dpi), rotasjon til
  liggende, og deling i bånd for ekstreme forhold.
- Verifisert: Kenneths trappe-mål (150×1468cm) gikk fra 0,458 til 2,21-2,35 px/cm per bånd
  (~5×), tydelig lesbare trinnummer og kabel-serpentin. `node --check` bestått gjennom alle
  seks steg.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Trapp: kabelstart på nesen + valgfri snuing + mm-avrunding — 2026-08-18

Regel 14-15 i spec-trapp-kabelutlegg.md: kabelen la ut fra riser-siden av trinnet i stedet for
nesen (fremkanten), sidevisningen var speilvendt om høydeaksen, og rå flyttall lekket ut på
tegningen.

- **`e58f467` — Regel 14: kabelen starter på nesen + sidevisning speilt riktig vei.** Rotårsak
  (bekreftet empirisk med pikselsøk i ekte rendering, ikke bare geometri-utledning):
  `depthStart` brukte nese-margin der den skulle brukt riser-margin — run-indeksen for trinn
  telles nå NEDOVER fra nesen mot riser-siden. Samme relabeling i sidevisningens `cumulH`-akse
  (trinn 1 havnet øverst på skjermen i stedet for nederst — canvas har y voksende nedover).
- **`aa20a3c` — STEG 2-4: valgfri snuing, skjøt-fargebug, byggbare mm-mål.** Ny
  `stair.cableStartFromTop`-innstilling reverserer hele overflate-rekkefølgen. Fikset en
  fargebug i U-svingene: strokeStyle ble satt fra sist tegnede segment (høyest x) i stedet for
  utgangssegmentet ved høyre-til-venstre-reise. Regel 15: auto-justert sidemargin snappes nå
  til nærmeste mm FØR den brukes i geometrien (ikke bare i visningen) — restavviket vises
  ærlig i stedet for å late som det er borte.
- Verifisert: K1 sin faktiske posisjon (pikselmetode) traff forventet verdi eksakt. 10-trinns
  testtrapp (spec-ens eget eksempel) fortsatt eksakt 4553cm, 4 løp per trinn, CC 9cm — uendret
  av speilingen. `fillText`-interception viser maks én desimal på alle 17 draw-kall.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte: klippet bredde posisjoneres riktig, rullen overskrider aldri kapasiteten — 2026-08-18

Oppfølging av 1cb674e på rom «1105 Dusj»: en klippet breddes LENGDE var riktig, men den kunne
tegnes fra feil ende, og variantvelgeren kunne velge en rull lengre enn rommet faktisk hadde
plass til.

- **`deae659` — Regel A (samme anker for lengde og posisjon) + Regel B (kapasitetstak).**
  Regel A: hver bredde måltes fra blokkens uniforme startpunkt, mens tegningen forankret en
  kortere bredde i sømenden — når disse to ankrene var ulike, fikk bredden riktig lengde men
  feil posisjon. Ny `mat.runStarts[]` (parallell med `runLengths[]`) og `_matRunStartCm`, delt
  kilde for tegning OG vakt. Regel B: variantvelgeren sjekket kapasitet mot uniformt langspenn
  i stedet for den faktiske klippede kapasiteten (samme følgefeil 1cb674e allerede rettet i
  utlegget selv, glemt i variantvalget) — kapasitetstaket fjernet, begge grener velger nå
  STØRSTE variant ≤ sann kapasitet.
- Verifisert: bredde 10 tegnet med korrekt worldY [13,181] (var [61,229], stakk inn i
  innhukket). Kapasitet 23,3m (ukappet, klippet) → velger 24m i stedet for 26m, 0 kabelpiksler
  utenfor noen vegg. Vakten skiller nå korrekt «riktig lengde, feil posisjon».

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Trapp-kabelskjøt — kabler deles på meter, ikke flateantall — 2026-08-18

Låst Regel 11 (Kenneth 18.08.2026): en kabel har fast fabrikklengde og kan verken kortes eller
forlenges — et utlegg der én kabel har meter til overs mens en annen er for kort er ugyldig.
Kenneths eget symptom (K1 13,8m til overs, K2 18,1m for kort) kom av at kablene ble delt etter
ANTALL FLATER, ikke meter.

- **`f54dcdb` — STEG 1+2: meter-basert fordeling + skjøt midt i et trinn.** Ny
  `_stairAllocateCables` forbruker kabel 0 i full lengde før kabel 1 starter, osv. Fant og
  fikset en beslektet, verre bug i samme runde: «Maks CC trinn» ble skrevet over med OPPNÅDD
  CC hver gang et forslag ble valgt — feltet er samtidig brukerens tak for neste forslagsrunde,
  og ble dermed low-jacket etter én anvendelse. `cableIdx` flyttet fra run-nivå til
  segment-nivå, så et skjøt kan ligge midt i en streng/opptrinn, med tydelig sort/hvit markør.
- **`e367c3e` — STEG 3-6: kabelsett + sidemargin løses eksakt sammen.** Kenneth korrigerte: CC
  skal ALDRI tettes for å forbruke overskudd (strengantallet er et heltall låst av
  ceil-formelen); sidemarginen er den kontinuerlige, presise justeringsvariabelen. Siden
  strengantallet er uavhengig av sidemarginen, er totalbehovet en LINEÆR funksjon av den —
  treffe en gitt kabellengde er derfor ren algebra, ikke søk. Ny `_stairSolveExactCableSet`
  søker over multisett av 1-3 katalogkabler, velger settet med MINST mulig marginøkning.
- **`7ecb1a0` — STEG 7: brukerstyrte soner.** Gjenbruker den eksisterende segment-listen i
  trapp-byggeren (Kenneths eksplisitte instruks) — `stair.segments[i].zone`. Hver sone løses
  uavhengig med samme Regel 11-13-mekanikk. Ny `showStairEditModal` gjenåpner byggeren for en
  allerede plassert trapp (fantes ikke fra før).
- Verifisert: 31-trinns testtrapp løste automatisk 60m+80m med kun 0,6cm marginøkning, 0cm
  avvik mot rutingens lengde. 3-sone-testtrapp: alle tre soner løst eksakt, ingen streng
  splittet på tvers av en sonegrense.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte-auto: kabel skal ALDRI legges utenfor rommet — 2026-08-18

Låst regel (Kenneth 14.08.2026): `autoFillMatSerpentine` jobbet kun på rommets omsluttende
rektangel, så bredder som traff et innhukk stakk forbi ytterveggen.

- **`1cb674e` — STEG 0-4: per-bredde-klipping mot rommets polygon.** STEG 0 (avklart med
  Kenneth): valgte per-bredde-lengder i nytt `mat.runLengths[]` fremfor å dele opp i flere
  matte-objekter (materiallisten teller allerede per S.mats-objekt — flere objekter ville
  risikert overbestilling). STEG 1: ny `_matClippedSegments` gjenbruker de samme delte
  primitivene folie bruker (`clipStripToRoom` m.fl.) til å klippe hver bredde mot rommets EKTE
  polygon. STEG 4: ny vakt `_matRunsWithinRoom` verifiserer hver streng mot polygonet FØR
  utlegget committes. Fant og rettet en reell rendering-bug underveis: skjøten mellom to baner
  («flukt») antok en fast start-/sluttindeks — med romform-klipping kan enhver bredde nå være
  kortere, og skjøten hoppet til en fast ende og tegnet en lang, feilaktig strek forbi
  ytterveggen.
- Verifisert (pikselinspeksjon mot ekte w2s): repro-rommet (567×242, innhukk 60×46) — 0
  kabelpiksler i innhukket, riktig kuttraster-snappet lengde. L-form-stress-case: 0 piksler i
  det utsparte området. Rent rektangel: `runLengths` forblir null, bit-for-bit uendret.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Matte-label som kabel — 2026-08-18

Fire steg som gir matte samme label-kvalitet og interaksjon som folie/kabel allerede har:
verdensbasert rendering, kabel-lik linje 2, og full v2-gizmo (flytt/skaler/roter).

- **`978bc8a` — STEG 1: generaliser `_drawStripLabel`.** Rektangulær matte-label hadde
  hardkodet 13px skjermpiksel-font (skalerte ikke med zoom, feil i PDF) og skjultes helt under
  zoom>0,38. `_drawStripLabel` (folies renderer, den eneste med riktig klamping/callout-
  fallback) generalisert minimalt for trygt gjenbruk. Egne lagre (`_matRectLabelBounds`/
  `Geom`) løser id-kollisjonen mellom S.mats og S.matPaths sine separate id-tellere.
- **`1ebd6c2` — STEG 2: linje 2 = W/m² flate · BTA · CC.** Ny `matWm2` i `_computeRoomStats`.
  Migrerte OGSÅ frihånds-matte til `_drawStripLabel` (STEG 1 sa «begge matte-systemene») —
  dens gamle hånd-tegnede boks («Tegnet X m · rull Y m») manglet både rom-klamping og
  callout-fallback.
- **`2f94d53` — STEG 3: v2-håndtak for rektangulær matte.** Klikk låser labelen (ingen
  lag-sykling), rundpil roterer (snapper til 0/90/180/270), X-håndtak skalerer, høyreklikk gir
  «↩ Tilbakestill». Ny `S.ui.selectedLabelMatRectId` løser id-kollisjonen. Ny minimal
  høyreklikk-meny (matte hadde ingen fra før).
- **`9753e16` — STEG 4: delt linje-2-bygger.** Ny `_matLabelInfoLine(roomId, product)` —
  fjernet ~10 dupliserte linjer hvert sted.
- Verifisert med instrumentert canvas og ekte DOM-hendelser gjennom alle fire steg: rektangulær
  og frihånds matte i samme rom viser bokstavelig identisk linje 2; kroppsdrag/roter/skaler
  bekreftet med ekte mousedown/mousemove/mouseup.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Trapp-kabelutlegg determinisme — 2026-08-17

Fem steg som gjør trappekabel-beregningen deterministisk: riktig ceil-formel, geometri før
katalog, tegning som leser motoren i stedet for å gjette, behov/dekket som to eksplisitte
sannheter, og fjerning av et U-svingtillegg som viste seg å være dobbelttelling.

- **`7268e1e` — STEG 1: riktig ceil-formel.** `floor()` i «gjerdestolpe»-formelen for antall
  strenger kunne gi faktisk CC over maks uten varsel (Kenneths eksempel: 27cm brukbar dybde,
  maks CC 10cm — floor ga CC 13,5cm, bryter maks; ceil gir riktig CC 9cm). Ny delt
  `_stairRunCount(usableDepth, maxCC)` brukt av bygger, estimator og validator samtidig — kan
  ikke lenger sprike.
- **`8d69bb2` — STEG 2: geometri bestemmer, katalog følger etterpå.** Forslagsmotoren lot
  POENGSUMMEN (dominert av valgt katalogkabels effekt) avgjøre strengantallet — en kosmetisk
  sidemargin kunne dermed flytte en fysisk utleggsbeslutning. Regnes nå én geometrisk riktig
  `runsPerStep` FØR kabelvalg. Ny egen `stair.landingMargin_cm` for repos (var feilaktig delt
  med sidemarginen).
- **`1c9d42a` — STEG 3: tegning viser rutingen fra motoren.** Tre tegnere (sidevisning, plan,
  PDF) regnet posisjon og inn-/utgangsside PÅ NYTT i stedet for å lese det motoren allerede
  hadde beregnet — 2 og 4 strenger så identiske ut i sidevisningen.
- **`e04b324` — STEG 4: behov og dekket lengde som to sannheter.** Ny
  `stair.coveredCableLength_cm` skilt fra `totalCableLength_cm` — panelet kunne før vise to
  selvmotsigende tall når kabelen var for kort.
- **`7840bce` — STEG 5: fjern U-svingtillegget.** Regel 10 (avklart av Kenneth): kabel mellom
  strengene skal ikke telles i lengdebehovet — svingen spiser omtrent like mye av den rette
  lengden som den legger til. Fjernet π×CC/2-tillegget i alle sju lengdeberegninger. Kenneths
  eksempel ga nå eksakt spec-fasiten: 4553cm (var 4977,1cm med tillegget).
- Verifisert gjennom alle fem steg mot Kenneths eget eksempel (10 trinn 120×33cm) og en sweep
  av 231 dybde/CC-kombinasjoner — 0 brudd på maks CC.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Trappebygger: ingen tapte tastetrykk, standard 1 trinn, arv fra forrige segment — 2026-08-17

- **`3e6349d` — oninput i stedet for onchange, standard 1 trinn, arv til nytt segment.** Kunne
  ikke reprodusere den beskrevne onchange/blur-racen via automatiserte museklikk, men byttet
  likevel til `oninput` for alle 6 skjemafelt — fjerner hele klassen av «tastet verdi tapt
  fordi du klikket videre uten å forlate feltet», uansett eksakt utløsermekanisme. Standard
  antall trinn er nå 1 (ny konstant), for både første og nye segmenter. Et nytt trinn-segment
  arver bredde/antall/dybde/høyde fra siste TRINN-segment i lista (et repos innimellom hoppes
  korrekt over); nytt repos arver dybde fra forrige repos. Det nylig tilføyde segmentet får
  aksentkant + «· nytt»-merke, scrolles inn, og Antall-feltet får fokus (ett-gangs).
- Verifisert med direkte funksjonskall + ekte museklikk: `oninput` committer på hver
  tastetrykk uten blur; ny trapp viser Antall 1; nytt trinn-segment arver riktig fra forrige
  trinn-segment (ikke fra et mellomliggende repos); omvendt byggeretning viser korrekt
  reversert indeksrekkefølge.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Fiks manuell folieplassering: magnet-first snap — 2026-08-14

Manuell folie-drag kunne forsvinne stille ved overlapp med en eksisterende folie i samme
retning — ingen feilmelding, bare vekk.

- **`46ca060` — felles ghost/commit-kandidat, magnet FØR kollisjonssjekk.** Rotårsak:
  dragover/drop kalte kollisjonsunngåelsen med tom exclude-liste FØR magnet-snapping, så
  ethvert delvis overlapp barberte bort hele kolonnen. Ny delt `_stripDropCandidate()`
  beregner magnetposisjon FØRST (vegg-margin eller nabofolie), kjører kollisjonsunngåelse PÅ
  den snappede posisjonen, og returnerer én sannhet brukt av BÅDE ghost (dragover) og commit
  (drop) — kan ikke lenger sprike. Kollisjonsløsning er nå tobent: dødsenter-slipp på én nabo
  prøver begge sider (korn-hjørne-tiebreak); klemt mellom flere naboer prøves kun innoverside
  per nabo (varsler «for trangt» i stedet for å teleportere). Alt-tasten hopper over magneten.
  Toast ved reell plasshunger i stedet for stille forsvinning.
- Verifisert: dødsenter-slipp på eksisterende folie snapper til motsatt side med eksakt gap;
  eksakt-passende lomme mellom to naboer (1cm begge sider); for trang lomme gir invalid+toast,
  ikke teleport. Auto-utlegget urørt (verifisert via diff).

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Veggmarkering og flyttepil — seks runder til den riktige rotårsaken — 2026-08-14

Vegger lot seg ofte ikke markere, og gizmoen for å flytte dem (som fantes fullt utbygd fra
før) var derfor uoppnåelig. Seks runder med presisjonsjakt — de fem første fjernet reelle, men
delvise bugs; den sjette fant den faktiske rotårsaken.

- **`af1366b` — klikk-terskel = faktisk veggtykkelse, ett klikk velger både rom og vegg.**
  `hitTest()` sin klikk-terskel var fast 2 skjerm-px mot veggens senterlinje, uansett hvor
  tykk veggen faktisk tegnes (opptil 50cm) — klikk hvor som helst i det synlige veggbåndet
  traff verken vegg eller rom. Ny `_wallHitThr(room, wl)` (terskel = faktisk veggtykkelse, 8px
  skjermgulv). Vegg-treff kastet tidligere bort hvis veggens rom ikke allerede var valgt
  (krevde to klikk) — velger nå begge i ett klikk.
- **`308a447` — nærmeste vegg, ikke første i array; bredere flyttepil-treff.** `hitTest()` sin
  vegg-løkke returnerte FØRSTE vegg innenfor terskel, ikke den geometrisk NÆRMESTE — i et rom
  med mange korte «jog»-vegger rammet dette systematisk. Ny `_closestWallHit`. Flyttepilens
  treffsone økt fra 3px til 12px (var strengere enn alt annet lignende i appen).
- **`bcbd329` — crosshair-cursor + strammere presisjon.** Reversert cursor til crosshair (fra
  pointer), tersklene strammet noe inn.
- **`d52b8ac` — egendefinert cursor med eksplisitt hotspot.** Kenneths foto viste cursoren
  tydelig forskjøvet fra veggens linje — OS/nettleserens innebygde crosshair-cursor har ingen
  hotspot nettsiden styrer. Ny `WALL_CURSOR` — egendefinert SVG-cursor med eksplisitt hotspot
  (10,10).
- **`fd6954d` — canvas-tegnet hover-highlight erstatter cursor som primært signal.** To runder
  med cursor-justeringer løste ikke Kenneths gjentatte, presise rapport («markering endrer seg
  litt under veggen»). Konklusjon: cursor-hotspot-rendering er strukturelt ikke verifiserbart
  fra JS. Ny `drawHoveredWallHighlight()` leser SAMME koordinater som selve veggstreken og
  hitTest — strukturelt umulig for dem å divergere.
- **`815c7ae` — den faktiske rotårsaken: canvas backing-størrelse ute av synk med CSS.**
  `resizeCanvas()` setter canvas' backing-størrelse fra `#canvas-wrap`, men kalles kun ved
  window.resize. `w2s`/`s2w` regner i backing-piksler, mens klikk-håndtererne matet inn
  CSS-piksler uskalert — enhver layout-endring (kontekst-verktøylinje, sidepanel) uten et
  resize-event ga en RETNINGSAVHENGIG skalafeil (null ved øvre/venstre kant, voksende mot
  nedre/høyre — nøyaktig Kenneths «perfekt vertikalt, glir horisontalt»). Ny delt
  `_evToCanvas(e)` brukt på alle ~26 steder som leste `e.clientX - rect.left` mot hovedlerretet.
  Ny `ResizeObserver` på `#canvas-wrap` fjerner selve rotårsaken til at backing/CSS går ute av
  synk.
- Verifisert (samme desync aktivt UNDER testen): alle 4 vegger i et rektangel treffer
  symmetrisk. 10-vegg sikksakk-testrom: 9/10 korrekt klikk-velgbare i alle seks runder (den ene
  «feilen» er korrekt hjørnepunkt-prioritet, ikke en regresjon).

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Trappedel startvalg-overlay legger seg ikke lenger over ferdig trapp — 2026-08-14

Startvalget («Slipp tegning her»/«Tegn opp rom»/«Romliste») dukket opp over en ferdig
trappetegning hver gang prosjektet ble åpnet, og blokkerte klikk.

- **`bc29dbd` — svarteliste snudd til hviteliste.** Rotårsak: `_editorIsEmpty()` avgjorde
  synlighet med en SVARTELISTE — kun 'list'-modulen var unntatt. Trapper ligger i `S.stairs`
  (via `partId`, ikke `floorId`) og oppretter aldri en aktiv etasje, så en trappedel kunne
  aldri produsere en treffende «rom på aktiv etasje», uansett hvor mye som var tegnet. Snudd
  til HVITELISTE — overlayet vises kun når aktiv del er 'indoor' eller 'snow'. I samme slag:
  overlay-tekstene sa «rom» også i snø-modulen — brukte eksisterende `roomWord()`-hjelper til
  å vise «område»/«Områdeliste» der.
- Verifisert med direkte funksjonskall: trappedel med tegnet trapp → false (var true). Indoor
  med rom på aktiv etasje → false; ny tom etasje i samme del → true igjen (overlay kommer
  riktig tilbake).

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Auto-folie hull-regresjon — REGEL A+B+C (T-rom sonegrense) — 2026-08-13

Kenneths bugrapport: auto-utlagt folie i et rom med hindring (320×198cm, 80×90
hjørnehindring) hadde et udekket hull midt i arealet, ikke mot vegg. Fire commits sporer
rotårsaken gjennom sonepakkingen og retter tre relaterte regler.

- **`6c584ae` — Funn 1: sone-utlegg overstyrte betingelsesløst.** `showAutoFillComparison`
  erstattet resultatet fra global (usonet) fylling med sone-resultatet UANSETT kvalitet så
  snart rommet dekomponerte til >1 sone — sonekanten (ikke en ekte vegg) ble behandlet som
  veggmargin, og en strimmel i én sone kunne ikke fortsette inn i naboens allerede reserverte
  areal. Fiks: erstatt kun når sone-resultatet faktisk er MINST like bra (delt
  `_statsAtLeastAsGood`, samme dekning-først + score-tiebreak som H-vs-V-valget allerede
  bruker).
- **`0add23d` — Funn 2: rom med hindring faller nå automatisk til coverage-strategi.**
  Default-strategien 'long' hoppet over hele hindringsapparatet — bekreftet med Kenneth: rom
  med hindring skal falle automatisk til 'coverage'. Eksplisitt brukervalg vinner fortsatt
  uansett romform.
- **`3ca64a0` — REGEL A: sonegrense-anker mot ekte vegg, ikke mellom soner.** Ny repro
  (T-/kryssformet rom uten hindring): `_packZoneFullLength` ankret alltid pakkingen ved lav
  koordinat uansett om kanten var en ekte vegg eller en sonegrense — når sonegrensen tilfeldig
  lå på høy koordinat, endte slakken midt i arealet. Ny `_rectEdgeIsSoneBoundary` klassifiserer
  hver sonekant, dropper veggmargin på sonegrense-kanter og pakker utover fra dem.
- **`295ce46` — REGEL B+C: maximin bredde-kombinasjon + smaleste bredde som nødløsning.** Regel
  B: ved lik dekning, foretrekk kombinasjonen der SMALESTE brukte bredde er BREDEST (120+60
  foran 140+40) — ny `_maximinWidthCombo` (DP over sonens budsjett). Regel C: familiens
  absolutt smaleste bredde er en nødløsning, ikke et førstevalg — ekskludert fra auto sitt
  full-lengde-søk, brukt kun når den gir vesentlig dekning.
- Verifisert mot repro-rommet og fire tilleggsromtyper (enkelt rektangel, hindring midt i rom,
  L-rom, U-rom, T-rom) gjennom alle fire commits — 0 regelbrudd i alle tester, ingen regresjon
  i romtyper uten hindring/sonedeling.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## InSnow frihånd: velg mattebredde 50 cm eller 100 cm — 2026-08-12

Frihånds-matteverktøyet var hardkodet til 50cm selv om katalogen alltid har hatt InSnow
300T-SKUer i begge bredder.

- **`caf5680` — breddevelger + snø-bevisst frihånd.** Ny breddevelger (chips) i UPC, kun
  synlig når familien har mer enn én bredde (EcoMat innendørs uendret). `_matFreeCatalog`
  skrevet om fra areal×200 (antok 0,5m bredde, tvetydig på tvers av bredder) til direkte snap
  på total lengde, filtrert på familie+bredde+spenning. Frihånd er nå snø-bevisst: `gapCm`
  initieres til 10cm (snø-standard) i stedet for alltid 0, langkant-margin 0 for snø (pakkes
  til kant). Tydelig toast når valgt bredde ikke får plass, i stedet for stille no-op.
- Verifisert i konsoll mot levende katalogdata: 10m tegnet + 1000mm/230V ⇒ riktig SKU (1×10m,
  10m², 3000W); EcoMat-regresjon (7 lengder) ga bit-identisk SKU+rollCm mot gammel formel.
  Ikke testet: faktisk museklikk-tegning i innlogget UI.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Fix: frihånds-matte nullstilt ved nytt/lastet prosjekt (mattelekkasje) — 2026-08-12

- **`1e6939d` — nullstill `_matFree` ved prosjektbytte.** Påbegynt frihånds-mattetegning ble
  ikke ryddet ved prosjektbytte, så en gammel matte kunne dukke opp igjen i et nytt
  prosjekt/rom — usynlig for klikk/sletting (kun `S.matPaths` hit-testes) og aldri lagret til
  Supabase.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Startskjerm: context-aware import-flyt + merget dropzone + auto/manuell-steg — 2026-07-16

UX-omlegging av tegneverktøyets startskjerm «Hvordan vil du begynne?». Fjerner dobbelt-spørring
av «hvordan», slår filtype-kortene sammen til én slipp-sone, og gjør auto-vs-manuelt utvetydig
etter raster-import. Kun flyt/UI — parser, auto-deteksjon og tegneverktøy er urørt.

- **`583c4ee` — Startskjerm-flyt.**
  - **Merget dropzone:** de fire ces-cards (Importer PDF, Importer DWG/DXF, Tegn opp rom, Hurtig
    prosjektering) → tre valg: én stiplet slipp-sone («Slipp tegning her, eller klikk — PDF, bilde
    eller DWG/DXF») + Tegn opp rom + Romliste. Klikk/slipp → felles dispatcher.
  - **Dispatcher `_startImportFile`:** DWG/DXF (vektor) → `_autoReadStart` (auto, ingen spørsmål);
    PDF/bilde (raster) → `_rasterMethodChoice` steg-2 «Fant en plantegning — hvordan lage rommene?»
    med a) «La appen finne rommene» (anbefalt) → auto-deteksjon; b) «Jeg tegner selv» →
    `_loadFileAsBackground` (uttrukket fra `handleBgFile`). Ordlyden gjør det utvetydig hvem som
    lager geometrien.
  - **Context-aware:** flagg `_startMethod`. «Fra tegning» på dashboardet → dropzone-fokusert modus
    (kun slipp-sonen + «Eller start på andre måter»-lenke), ingen native fil-dialog. Generisk
    inngang («Gulvvarme»/«+Opprett») → full startskjerm. Nullstilles i `_quickStartModule` +
    `_resetProjectState`.
  - **Toolbar-opprydding:** `_importPlanMenu` → `_emptyPickImport` (samme dispatcher); gammel
    pre-import auto/manuell-meny fjernet — ikke tilbudt på to måter.
  - Tastatur: `role=button` + tabindex + `_cesKey` (Enter/Space) + `:focus-visible`. Ingen
    drop-shadows. `_importPlanToDraw` beholdt (shape-card + fallback).
- Verifisert i preview (begge modi, steg-2, dispatch-matrise DWG→auto / raster→steg-2, dark/light)
  — ingen JS-feil. Innlogget ende-til-ende (ekte import) gjenstår hos Kenneth.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Dashboard visuell polish: kompakt full-bredde flis-rutenett — 2026-07-16

Ren visuell/layout-forbedring av to-kolonne-dashboardet (Kalkulasjon/Prosjektering). Ingen endring
i logikk, ruter eller inngangsfunksjoner. Prinsipp: se mest mulig uten å scrolle.

- **`559433c` — Kompakt flis-rutenett.**
  - **Full bredde:** boksene spenner samme bredde som stat-kort-raden (fikset at `#dash-modules`
    ikke strakk seg til full bredde → kompakt grid kollapset til innholdsbredde).
  - **Kompakte fliser:** `repeat(auto-fit, minmax(104px,1fr))` → 3 i bredden på desktop, 2 på smal
    skjerm. Kalkulasjon 1 rad, Prosjektering 2 rader (3+2). Flis = sentrert kolonnefarget ikon +
    kort etikett (~62px), undertitler droppet.
  - **Lett boks:** tynn 2px kolonnefarget toppkant + kompakt header (ikon-chip + tittel + kort
    undertekst); tunge ytre paneler fjernet. `align-items:start` → ingen tomrom i Kalkulasjon.
  - **Hover:** løft ~1,5px + kolonnefarget kant + svak tint (~100ms). `:focus-visible`. Ingen
    drop-shadows. Stat-kort strammet (padding/font) + mindre `.dash`-gap → alt høyt oppe.
  - Farge: teal #0F6E56 (kant #5DCAA5) / lilla #534AB7 (kant #AFA9EC). Fiks: «Fra tegning» brukte
    `ico:'image'` (mangler i ikon-settet, tom chip) → `map`.
- Verifisert desktop + mobil, lyst + mørkt tema. Ingen inngangsfunksjon endret (samme onclick).

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Kalkyle-matrise med bulk-varmetype på import-gjennomgang (STEG 1–5) — 2026-07-16

Utvider import-gjennomgangsskjermen (`#import-review-screen`) til en **varmetype-matrise** for
kalkyle. Matrisen bor her fordi de auto-detekterte rommene har geometri (`poly`), så folie-pakking
fungerer og de committes som ekte tegnede rom. «Fra tegning»-kortet router hit (target=draw).
Selve tegne-/pakkemotorene er urørt — kun romliste-UI, bulk, preset-oppslag og grov auto-utfylling.

- **`9cf06ab` — STEG 1–5 + DB.**
  - **Steg 1 (matrise):** hver rad (`_reviewRenderList`) får 4-veis gjensidig utelukkende
    Folie/Kabel/Matte/Ingen (`r.calcType`, `heat = calcType≠none`); fargekodet `.rv-tseg`.
  - **Steg 2 (bulk):** «Alle rom · N»-rad + `_reviewBulkType`; 'preset' = sett hvert rom etter
    romtype-regel. Enkeltoverstyring bruker samme mekanisme.
  - **Steg 3 (romtype-preset):** ny kolonne `default_mod_type` på `room_type_defaults`
    (`supabase-migration-roomtype-modtype.sql`, kjørt manuelt). `ROOM_TYPES[].defaultModType`
    (bad/vaskerom=mat, ellers foil), `_roomTypeModType`, `_savePersonalModTypeOverride` +
    admin-popup «⚙ Standarder». Forhåndsfyller varmetype per rom (scope global > org > user).
  - **Steg 4 (grov autofyll ved commit):** `_calcRoughFill` i `_drawCreateRoomsFromReview` — folie
    via `_autoFillBothDirections` (beste retning), kabel/matte via `_listAutoSuggest` (kun-label-
    anslag). Alt flagget `_calcRough=true` for re-kjøring ved «gjør om til prosjektering».
  - **Steg 5 (live-sum):** footer `#rv-sum` (`_reviewUpdateSum`) — rom med varme · sum m² · grov
    effekt (W), avrundet, live. Responsiv (footer wrap + matrise stabler på smal skjerm).
  - **Viktig funn:** `_applySalesTransition` auto-setter `delivery_status` ved `vunnet`, så
    matrisen bygger på import-detekterte geometri-rom (ikke den manuelle list-modulen).
- Verifisert render/bulk/preset/live-sum i preview. Motorkjøring (folie-pakking + kabel/matte)
  krever login/produktkatalog — innlogget ende-til-ende gjenstår hos Kenneth.

**Fil:** romtegner.html + `supabase-migration-roomtype-modtype.sql` + `docs/endringslogg.md`.

---

## Dashboard delt på intensjon: Kalkulasjon vs Prosjektering (STEG 2–5) — 2026-07-16

Bygger om dashboard-toppen fra én blandet modul-«kortrad» (varmetype + hurtigprosjektering om
hverandre) til **to intensjons-kolonner**: brukerens første valg er nå dybde, ikke varmetype.
**Kalkulasjon** (rask pris) venstre, **Prosjektering** (detaljert leggetegning) høyre; stables
vertikalt på smal skjerm. Speiler statusflyten: kalkyle = salgsfase, prosjektering = leveransefase.
Gjenbruker EKSISTERENDE inngangsfunksjoner — ingen nye flyter, ingen endring i tegne-/kalkyle-motorene.

- **`902ae40` — STEG 2–5.**
  - **Steg 2 (to kolonner):** `_renderDashModules()` bygger nå to kolonner i stedet for den flate
    `MODULE_TYPES`-raden. **Kalkulasjon** (inndata-metode): Manuelt → `addPart('list')`, Fra tegning →
    `_quickStartFromDrawing()` (åpner indoor-editor + dagens plan-import/auto-romdeteksjon),
    Snøsmelting–effektbehov → `_openSnowCalc()`. **Prosjektering** (varmetype/tegneverktøy): Innendørs
    gulvvarme, Snøsmelting trapper/grunn, Frostsikring rør + Tak og takrenner disabled («Kommer»).
    Datadrevet via `_DASH_CALC_CARDS`/`_DASH_PROJ_CARDS`.
  - **Steg 3 (fargekoding):** nye CSS-vars `--calc` (#0F6E56 teal, salg/kalkyle) / `--proj` (#534AB7
    lilla, leveranse/prosjektering) + tint-varianter. Kolonnene og leveranse-pill'en (`_deliveryCellHtml`)
    bærer modus-fargen. Salgstraktens semantiske chip-farger (vunnet=grønn osv.) er BEVISST urørt.
  - **Steg 4 (broen):** `_prosjekteringBridgeHtml(p)` viser «Gjør om til prosjektering» kun når
    `sales_status='vunnet'` OG `_type='list'` (vunnet Manuelt-kalkyle) — i stedet for de vanlige
    leveranse-kontrollene. `_convertToProsjektering(id)` bytter `project.type` list→indoor, setter
    `delivery_status='klar_for_montering'` og åpner tegneverktøyet på den eksisterende romlista.
    Kun navigasjon — INGEN geometri-konvertering (spec §7). Broen forsvinner når type er byttet.
    Viktig funn: `_applySalesTransition` auto-setter `delivery_status` ved `vunnet`, så «tomt
    delivery_status» kan ikke flagge en kalkyle — `_type='list'` brukes i stedet.
  - **Steg 5 (responsivt):** `@media(max-width:720px)` stabler kolonnene (Kalkulasjon øverst); to
    kolonner side-ved-side på desktop.
- Verifisert for parse + render + logikk i preview (to-kolonne-render, teal/lilla i lyst+mørkt tema,
  responsiv stabling på 375px, bro-trigger-matrise) — ingen JS-feil. Innlogget ende-til-ende-test av
  selve bro-klikket (mot ekte vunnet list-prosjekt) gjenstår hos Kenneth.

**Fil:** romtegner.html + `docs/endringslogg.md`. Spec: `spec-dashboard-intensjon-kalkulasjon-prosjektering.md`.

---

## To-akse prosjektstatus (salg + leveranse) + P2/P3 — 2026-07-14

Innfører to uavhengige statusakser som erstatter den blandede statusaksen i UI: **`sales_status`**
(salgstrakt: under_arbeid → tilbud_sendt → vunnet/tapt) og **`delivery_status`** (leveranse, aktiv kun
ved `vunnet`). Løser feilrettet dok-varsel (leverandør ble maset på om dokumentasjon), rydder hovedliste
+ Dokumentasjon-fanen, og skiller «regnet på» fra «faktisk fått». Rolle leses fra
`organizations.org_type` (`installer`/`supplier`) — aldri antatt. Gammel `status`-kolonne røres ikke
(bakoverkompat). Ingen RLS-endring. Migrasjon + smart backfill kjørt manuelt i Supabase.

- **`1b81e2f` — Steg 1–6 + 5b.**
  - **Steg 1 (DB):** `supabase-migration-project-status.sql` — nye kolonner `sales_status`
    (NOT NULL default under_arbeid, CHECK), `delivery_status` (CHECK), `lost_reason`,
    `status_changed_at` + delvis indeks `(org_id, sales_status) WHERE sales_status <> 'tapt'` +
    backfill. `supabase-backfill-sales-status.sql` — smart mapping fra gammel status
    (ready_quote→tilbud_sendt, completed→vunnet, archived→tapt).
  - **Steg 2 (hovedliste):** nye `SALES_STATUSES`/`DELIVERY_STATUSES`/`LOST_REASONS`; 4-verdi salgs-chip;
    «Aktive»-default skjuler tapt + ferdige leveranser; «Alle statuser» henter alt; statistikk-kort,
    kundekort og batch-status mappet til akse A.
  - **Steg 3 (dashboard-kort):** rollegated «Å gjøre nå»-kort — installatør «X må dokumenteres»
    (`delivery_status='montert_venter_dok'`), leverandør «X klar for levering»
    (`klar_for_levering`). Fjernet gammel warranty-cert-heuristikk (`_fetchDashDocGaps`/`_dashDocGapIds`).
  - **Steg 4 (Dokumentasjon-fanen):** viser kun `sales_status='vunnet'`; fanen skjult for leverandør.
  - **Steg 5 (auto-overganger):** priset PDF-eksport → `tilbud_sendt` (betinget, kun fra under_arbeid);
    `vunnet` → aktiver akse B (klar_for_montering/klar_for_levering etter rolle); garanti signert →
    `delivery_status='ferdig'`. Sentral skriver `_setProjectStatus(id, patch, cond?)` +
    `_applySalesTransition`. Alt stempler `status_changed_at`.
  - **Steg 5b (manuell leveranse):** knapper på vunne prosjekter i lista — Start montering / Ferdig
    montert (installatør) og Marker levert / Marker ferdig (leverandør), så dok-varselet faktisk kan
    trigges. `_deliveryNextAction`/`_deliveryCellHtml`/`_advanceDelivery`.
  - **Steg 6 (tapt):** hurtigvalg-overlay for valgfri `lost_reason` (pris/tid/konkurrent/kunde_utsatt/
    annet) når et prosjekt tapes; ryddes automatisk hvis prosjektet flyttes ut av tapt.
- **`d4fe350` — P2 + P3.**
  - **P2 (salgs-nudge):** nytt «Å gjøre nå»-kort «X tilbud har ventet >14 dager — følg opp?» basert på
    `sales_status='tilbud_sendt'` + `status_changed_at` (ny `_statusChangedAt` i cachen); `_isStaleTilbud`
    (14-dagers terskel); `'tilbud'`-filternøkkel i lista.
  - **P3 (pipeline-statistikk):** «Vinnrate»-kort (`vunnet/(vunnet+tapt)`) + tapt-årsak-oppsummering som
    tooltip på Tapt-kortet (utnytter `lost_reason`).
- Verifisert for parse + logikk i preview (filter-matrise, rolle-gating, auto-overganger, stale-tilbud,
  vinnrate-matte, årsaksbryting) — ingen JS-feil. Full innlogget ende-til-ende-test gjenstår hos Kenneth.

**Fil:** romtegner.html + `supabase-migration-project-status.sql` + `supabase-backfill-sales-status.sql`
+ `docs/endringslogg.md`.

---

## Label v2 for kabel + matte (låst valg + flytt/skaler/roter) — 2026-07-13

Utvider label-v2-modellen (fra folie, `f508aae`) til kabel- og matte-labels. Delt gizmo trukket ut i
`_drawLabelGizmo` + `_hitLabelHandlePts` (orientert boks + rundpil-roter + X-skaler), brukt av alle tre.
Felles prinsipp: LÅST label-valg (kun labelen markeres, ingen lag-sykling), egne markører/cursors
(boks→move, X→crosshair, rundpil→grab), grabOffset (ingen hopp), verden-basert + PDF-arvet,
«tilbakestill til auto». De tre låsene (`selectedLabelStripId`/`CableId`/`MatId`) er gjensidig utelukkende.

- **`cb85211` — Kabel-label v2 (Del A).** Ny `S.ui.selectedLabelCableId`; ny `cable.labelRotation`/
  `labelScale`; `drawCables` + `_drawCableLabelOnly` roterer/skalerer boksen og lagrer `_cableLabelGeom`
  (orientert) + akse-justert AABB. Klikk låser (før syklingen → ingen lag-sykling); body-drag beholder
  grabOffset; `drawCableLabelHandles`/`hitCableLabelHandle`/`resetCableLabel`. Seeder `labelPos` fra
  FAKTISK tegnet senter → fjerner et ~70px hopp som fantes i den gamle kabel-drag-init-en.
- **`e8cdd45` — Matte-label v2 (Del B).** Matte-labelen (matPath) hadde INGEN interaksjon før (fast
  hjørne-tekst). Bygget hele v2 fra bunnen: `_drawMatPathObj`-labelen ble sentrert 2-linjers boks
  (produktnavn + «Tegnet X m · m² · rull Y m») ved `mp.labelPos`, verden-basert font, med rotasjon
  (`mp.labelRotation`) + skala (`mp.labelScale`); `_matLabelGeom`/`_matLabelBounds`, `hitMatLabel`/
  `hitMatLabelHandle`/`drawMatLabelHandles`/`resetMatLabel`, drag + handle-drag wiret i
  mousedown/mousemove/mouseup, `S.ui.selectedLabelMatId`. Bonus-fiks: `_resetProjectState` manglet
  `nextMatPathId` i `S.counters` → frihånds-matter i NYE (u-lastede) prosjekt fikk `id=NaN` (brøt
  seleksjon); lagt til.
- Verifisert live (ekte events, dummy `_supabaseProjectId` → ingen junk-prosjekter): begge låser uten
  hopp (0px), body-drag/roter/skaler drift 0 (89°, 2×); cursors move/crosshair/grab; reset + Escape;
  folie/kabel/matte-lås gjensidig utelukkende; lag-sykling for strip/kabel/rom intakt; ingen JS-feil.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Folie-label v2 — låst valg + egne markører (flytt/skaler/roter) — 2026-07-13

Erstatter den forrige gizmo-tilnærmingen med en klarere, label-sentrert modell. Kun varmefolie;
kabel-/matte-label med samme prinsipp holdes til en senere del.

- **`f508aae` — låst label-valg + egne markører.** Rotårsak (verifisert): labelen manglet et eget
  «valgt»-state — klikk startet bare et utsatt dra uten seleksjon/håndtak, og håndtakene lånte
  `selectedStripId`, som gjorde strip-body klikkbar/syklende → forvirrende «lag-bytting».
  - **Del 1 (lås):** ny UI-state `S.ui.selectedLabelStripId`. Klikk på label låser den (KUN labelen
    markeres, `selectedStripId` urørt); gjentatte klikk holder den låst og lag-syklingen kjøres aldri
    (returnerer i label-grenen). Klikk tydelig UTENFOR labelen, Escape, eller klikk på et annet objekt
    → forlater det låste valget og går videre til normal seleksjon/sykling.
    `drawStripLabelHandles`/håndtak-hit nøkler nå på `selectedLabelStripId`.
  - **Del 2 (markører + cursors):** boks-hover → `cursor:move`; SKALER = lite KRYSS (X) i hjørnet,
    hover → `crosshair` (var firkant/`nwse-resize`); ROTER = liten rundpil over boksen, hover →
    `grab`.
  - **Del 3 (lagring/tilbakestill):** `resetStripLabel` virker på den låste labelen; Escape/utenfor-
    klikk nullstiller låsen. `labelPos`/`rotation`/`scale` er alt verden-basert + lagret + PDF-arvet;
    grabOffset (ingen hopp) beholdt.
  - Verifisert live (ekte events): klikk låser (`selStrip=null`), gjentatt klikk holder, utenfor/
    Escape/strip-klikk forlater; cursors move/crosshair/grab; body-drag offset 0 (ingen hopp), roter
    senter-drift 0 (89°), skaler senter-drift 0 (2×); reset nullstiller. Lag-sykling for strip/rom
    intakt (label ikke i kandidatstacken); kabel-/matte-label uendret.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## «Å gjøre nå»-rydding + varmekabel-label (innhold + størrelse) — 2026-07-13

- **`e4a5e11` — fjern «romtype» og «effekt & gulv» som «venter»-kriterier.** De to stegene ble lest
  feilaktig som feilmeldinger i «Å gjøre nå». Fjernet helt fra fremdriftsberegningen (ikke bare kort-
  etikettene): `_projectProgress.steps` er nå kunde → tegning → produkter → dok, prosent regnes over de
  fire, og `nextStep` faller til `produkter` etter `tegning`. `_TODO_LABELS` + `_TODO_ORDER` renset for
  `rom`/`effekt`. Et prosjekt med tegning men uten varmeelement havner nå riktig under «mangler
  prosjektering» (forsvinner ikke). Arbeidsflyt-stripen (STEG 7) mister også Rom/Effekt-chips → Kunde ›
  Tegning › Produkter › Dokumentasjon › Send til montør (default per prompt). Gamle prosjekter med
  utdatert stemplet `_prog.next='rom'/'effekt'` vises ikke som kort (defensiv `_TODO_LABELS[next]`-guard)
  og re-bucketes ved neste lagring. Verifisert live: tegnet rom uten romtype/produkt → next='produkter';
  ingen JS-feil; dashboard uten «mangler romtype/effekt»-kort.
- **`7c17d9d` — varmekabel-label: linje 2 = flate/BTA/CC + størrelse lik folie.** Gjelder alle kabeltyper,
  begge label-veier (`drawCables` + `_drawCableLabelOnly`). (1) Linje 2 viser nå «W/m² flate · W/m² BTA ·
  CC … cm» i stedet for «lengde · total W · CC» — verdiene hentes fra allerede beregnede felt i
  `_computeRoomStats` (flate = `cableLenM>0 ? cableWm2 : wm2Heated`, BTA = `wm2Total`); lengde/total-W kun
  fjernet fra label, ikke fra materialliste/spesifikasjon. Linje 1 (produktnavn) beholdt. (2) Fast 13px-
  font byttet til folies verdensbaserte `LABEL_FONT_CM*(zoom*BASE_SCALE)` med 6px skjerm-gulv + proporsjonal
  boks-metrikk → kabel-label nå like diskré/stor som folie-label. Verifisert live (auto-lagring stubbet for
  å unngå junk-prosjekter): rendret label = «InFloor 17T 170W 10m» / «139 W/m² flate · 196 W/m² BTA · CC
  12.2 cm»; per-linje-høyde identisk med folie (18.2px @ zoom 1.4); ingen regresjon i folie-/matte-label.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Fire fikser — matte-stopp · folie-label-gizmo · Toppgulv-stepper · kabel-målsett — 2026-07-13

Kø av prompt-fil-oppgaver, hver med «finn rot-årsak først». Rotårsakene ble verifisert i innlogget
app med ekte events/målinger (der mulig), ikke bare kodelesing.

- **`7a7874e` — frihånds-matte avslutter pålitelig på klikk på stopp-tegnet.** Rotårsak (verifisert):
  IKKE hit-rekkefølge (stopp sjekkes alt før ghost-commit), men for trang treffsone — markør r=9px,
  treffradius bare 12px → avslutt-klikk noen px utenfor falt gjennom til «legg neste bane». Reprodusert:
  13/20px fra senter la bane; 0/8/11px avsluttet. Fiks: markør r 9→11, treffradius 12→20px; tilgivende
  avslutning (klikk ved fri ende uten reell bane avslutter); `resizeCanvas()` ved `_matFreeStart` så
  skjerm↔verden-treffet stemmer hele økta. Ingen regresjon i utlegging/EcoMat-auto.
- **`1e2d4ad` — folie-label roter/skaler hopper ikke lenger.** Rotårsak (verifisert, avvek fra prompt-
  hypotesen): body-draget hadde alt korrekt grep-offset; hoppet lå i roter/strekk-håndtakene som satte
  `labelRotation`/`labelScale` men aldri `labelPos` → manuell render-gren ankret på foliesenter og labelen
  hoppet −175px. Fiks: seed `labelPos` fra gjeldende `_stripLabelGeom`-senter ved håndtak-grep. Polering:
  distinkte gizmo-cursors (roter=grab, strekk=nwse-resize, body=move). Verifisert: drift 0px (var −175),
  body-drag/klikk ingen regresjon.
- **`84fc50d` — Hurtig prosjektering: «Toppgulv» får ▲▼-stepper + pil opp/ned.** Toppgulv-feltet var et
  rått `<select>` uten stepper (+ gjenbrukte `li-floor-${rid}` → kolliderte med Etasje). Nå via samme
  `sel()`/`_listStepSelect`/`_listKey`-mønster som naborutene: egen nøkkel `ftype` (id `li-ftype-${rid}`,
  rydder også duplikat-id-en), ▲▼-stepper, pil opp/ned (ned=neste, opp=forrige), Tab flytter uten å endre,
  ender klamper likt. Verifisert live; ingen regresjon i de andre stepperne.
- **`5207140` — kabel-rommets målsett like tett på rommet som folie-rommet.** Rotårsak (verifisert mot
  sammenligningsbilde): rom-mål-linjene (blå, `_drawDimAnnotationsForRoom`) skyves ut for å klarere
  produkt-kjeden, men bidraget var ulikt per modul — folie 52 cm, kabel/matte 32+65 = 97 cm (≈ dobbelt så
  langt). Fiks (folie = fasit, én felles konstant): `DIM_BASE_CM=32 + DIM_CHAIN_CLEARANCE_CM=20` pr. aktiv
  produkt-kjede → folie uendret (52), kabel/matte nå også 52. Gjelder alle sider; tallverdier urørt.
  Verifisert: to rom side-ved-side, begge 52 cm.

**1:1-verifisering i innlogget app (ekte events/toggles, fler-stegs — 2026-07-13):**
- **Folie-label-gizmo (`1e2d4ad`):** reelt rom + FlexFoil-strip, valgt så gizmoen vises; drev ekte
  `mousedown`→N×`mousemove`→`mouseup` på canvas. Body-drag: grep-punktet låst under cursoren i alle
  4 steg (grep-offset holdt 0,0 → ingen hopp). Roter: senter-drift 0 gjennom 4 vinkler (30/75/120/
  200°), `labelRotation` følger draget. Strekk: `labelScale` proporsjonal (1.5×→2.2×→3.0×), senter-
  drift 0 (skalerer fra senter). «Tilbakestill til auto» nullstiller pos/rotasjon/skala → auto −90°.
  Kjernefiksen bekreftet: roter/strekk startet fra AUTO-label (uten labelPos) og driftet 0 (var −175).
- **Kabel-målsett (`5207140`):** to identiske 300×200-rom med ekte toggle-funksjoner
  (`_toggleRoomDimSnap` + `_toggleStripDimSnap`/`_toggleCableDimSnap`); begge rom-mål på 52 cm, blå
  streker like langt fra begge rom i skjermbildet. Strip+kabel-rom stabler til 72 cm (egen 20 cm-
  klaring pr. kjede). Avgrensning: testet den flaggdrevne rom-mål-offsetten, ikke med ekte kabel-
  geometri (oransje produkt-kjeder er uendret 25 cm).

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## UX-arbeidsflyt STEG 6-justering — «Tegn opp rom»-kort → alle fire tegnemetoder — 2026-07-13

Prompt-oppdatering til empty-state-kortet: den gamle teksten («Tegn rom» / «Klikk to hjørner på
lerretet») beskrev bare én av fire tegnemetoder, og klikk tvang rektangel-modus.

- **`65a85c9` — «Tegn opp rom»-kortet fører til lerret med alle fire metoder.** Tittel «Tegn rom»
  → «Tegn opp rom», undertittel «Klikk to hjørner på lerretet» → «Rektangel, polygon, L-form eller
  vegg-for-vegg». `_emptyDrawRoom()` tvinger ikke lenger rektangel (`abStartDraw('rect2')`), men
  skjuler startvalget til et tomt lerret der alle fire tegnemetodene (Rektangel/Polygon/L-form/WBW)
  ligger klare i verktøylinja — uten aktiv modus. Ny session-flagg `_emptyStateDismissed` skjuler
  startvalget uten `drawMode` og hindrer at en re-render viser det igjen; nullstilles i
  `_resetProjectState` så nytt/åpnet tomt prosjekt viser startvalget på nytt. Verifisert live: kort-
  tekst oppdatert; klikk → overlay skjult, `drawMode=null`, alle fire verktøy tilgjengelige;
  re-render viser ikke overlay igjen; gjenåpning av modul viser startvalget på nytt (ingen regresjon).

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## UX-arbeidsflyt STEG 4-fiks — token-basert søk på tvers av felt — 2026-07-13

Ende-til-ende-verifisering av hele STEG 1–7-serien i innlogget app (preview) avdekket én reell
defekt i STEG 4-søket; resten av serien fungerte som spesifisert.

- **`74243ee` — STEG 4-fiks: token-basert kryssfelt-søk.** `_filterProjectsList` gjorde
  `hay.includes(search)` — en sammenhengende delstreng-match — i stedet for det tokeniserte
  kryssfelt-søket spec-en krever. Følgen var at flerords-søk der ordene traff *ulike* felt ga
  0 treff (`leir askøy`, `park alt`). Fikset til å splitte søket på whitespace og kreve at HVERT
  token finnes et sted i den samlede feltstrengen (`tokens.every(t => hay.includes(t))`).
  Rekkefølge-uavhengig og på tvers av felt. Verifisert live mot ekte data: `leir askøy` /
  `askøy leir` → *Leirvikåsen 11*; `park alt` → *Parkveien 3*; enkelt-token + sammenhengende søk
  fortsatt OK.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## UX-arbeidsflyt — STEG 1–7 (fremdriftsmodell, dashbord + tegneskjerm) — 2026-07-10

Stegvis serie som gjør navigasjonen arbeidsflyt-orientert i stedet for funksjons-orientert. Alt
bakoverkompatibelt — dagens funksjons-nav (Inne/Ute/Trapp, Snap, Raster, Import) er urørt.
Verifisert i preview/headless med syntetiske prosjekter (innloggede flyter gjenstår for felttest).

- **`3fc6a80` — STEG 1: semantiske fargetokens.** Nye CSS-variabler i begge temaer: `--success`
  (grønn), `--danger` (rød), `--info` (blå); `--warn` (oransje) beholdt. Semantikk overalt framover:
  grønn=ferdig/ok, oransje=mangler/venter, rød=feil/avvik, blå=nøytral info. `_renderDashStats` +
  målings-/advarselvisning (`.doc-val.good/.bad`, portal-`cell()`) bruker tokens. «Pågår» gul→oransje.
- **`da7e0ca` — STEG 2: `_projectProgress` (ren funksjon, ryggraden).** 6-stegs sjekkliste (Kunde/
  Tegning/Rom/Effekt & gulv/Produkter/Dokumentasjon) med `done/todo/na` utledet fra prosjektdata +
  samlet prosent + neste steg. `_openProjectData()` gir lagret-JSON-view av åpent prosjekt. Endrer
  ikke `p._status`-enumen. Dok mates via `docStatus` (async/ekstern).
- **`9786d2b` — STEG 3: «Å gjøre nå» på dashbordet.** Handlingsliste øverst i prosjekt-fanen bygget
  på `_projectProgress`. Datastrategi «sammendrag ved lagring»: `_buildSaveData` stempler
  `project._prog`, `_fetchProjectList` plukker det ut → ingen ekstra geometri-fetch. Grupperte,
  klikkbare kort (mangler kunde/tegning/romtype/effekt/prosjektering + «må dokumenteres» via batch
  warranty-spørring); klikk filtrerer lista; tom → «Alt à jour».
- **`3217c2e` — STEG 4: ett samlet søk.** Slo sammen de to feltene (prosjekt + kunde) til ett;
  `_filterProjectsList` matcher fritt mot navn/adresse/ansvarlig/kunde/kontakt/ordrenr + lenket
  kunderad (navn/telefon/e-post). Status-/type-select beholdt.
- **`299e541` — STEG 5: adresse-autofyll + kunde-først.** `#dash-create-form` omordnet (Kunde →
  Kontakt → Navn → Adresse → Type → Ansvarlig; fokus på Kunde). Adresse-felt fikk Kartverkets
  gratis, nøkkelfrie API (`ws.geonorge.no/adresser/v1/sok`): `_addrSearch`→`_addrFetch`→dropdown,
  `_addrPick` fyller «adressetekst, postnr poststed». Feil/offline → ren fritekst (fallback).
- **`f51f213` — STEG 6: empty-state «Hvordan vil du begynne?» + PDF-drop + DWG.** `#canvas-empty-state`
  vises når aktiv etasje er tom (`_editorIsEmpty()`/`_updateEmptyState()` fra `render()`). 4 kort:
  Importer PDF + DWG/DXF (drop-soner → `_autoReadStart`; klikk → `_importPlanToDraw`), Tegn rom
  (`abStartDraw('rect2')`), Hurtig prosjektering (`addPart('list')`). Gjenbruker eksisterende
  import-/tegne-flyt. DWG-status (lumelo-backend): DXF nativt (ezdxf); native `.dwg` krever ODA
  File Converter (ikke installert) → feiler server-side, `.dxf` virker — kortet er ekte «DWG/DXF».
- **`0a182d8` + `10bc798` — STEG 7: arbeidsflyt-stripe i tegneskjermen.** Tynn `#workflow-stripe`
  (rad mellom `#topbar` og `#content`), `_renderWorkflowStripe()` fra `render()` med signatur-vakt,
  kun indoor-modul. Chips fra `_projectProgress` (STEG 1-farger) + accent «Send til montør». Klikk:
  Kunde → lettvekts info-modal; Tegning → `fitAll`/import; Rom → `selRoom`; Effekt/Produkter →
  `showUnifiedProductPanel`; Dok + Send → `showDocPanel`.

**Fil:** romtegner.html + `docs/endringslogg.md`.

---

## Folie-label — orientering + håndtak + folie-fyll + trofast PDF (Del A–E) — 2026-07-10

Oppfølger til folie-label-jobben. **Plan først** (geometri/orientering). Skjerm = PDF (samme canvas
via `_renderRoomToImage`). Verifisert headless/syntetisk; faktisk PDF-eksport gjenstår for felttest.

- **`8878657` — Del A: klikk flipper ikke lenger stående label flatt.** Rotårsak: et klikk satte
  `labelPos`, og den manuelle grenen tegnet alltid horisontal boks → stående folie flippet. Fiks:
  manuell gren respekterer lengderetning (`dir==='v'` → rotér −90°); `labelPos`+undo utsatt til reell
  drag (>4 px), så et klikk endrer ingenting.
- **`dca6551` — Del B: folie-fyll-farge + forplantning til like artikler.** Nytt `strip.fillColor`
  + prosjekt-standard `S.varmefolie.fillColor` (`drawStrips` netto-fyll via `_resolveFillColor`).
  Farge-panelet fikk «Folie-farge»-spor + omfangsvelger (`_colorScope`: Dette rommet / Denne etasjen
  / Hele prosjektet). Fargeendring forplanter til alle strips med samme `productId` innen omfang
  (`_applyColorToScope`/`_stripsInScope`); B=140 aldri berørt når B=100 endres. Undo pr batch.
- **`41f0908` + `62c0cc2` — Del C: manuelle håndtak (roter/strekk/flytt).** C1: `_drawStripLabel`
  støtter vilkårlig `strip.labelRotation` (deg) + `strip.labelScale`; lagrer orientert boks-geometri.
  C2: `drawStripLabelHandles()` tegner orientert boks + rotasjonssirkel + strekk-firkant for VALGT
  label; `hitStripLabelHandle` sjekkes før label/strip (kun valgt → ingen kollisjon). Roter =
  atan2+90° med snap 0/90/180/270 (Shift=fri); strekk = avstand-ratio → skala 0.5–4×.
  «Tilbakestill til auto» nullstiller pos+rotasjon+skala.
- **`67a2ec7` — Del D (punkt 5): trofast PDF — verdensbasert label-størrelse.** Fjernet den
  hardkodede PDF-fonten (clamp 30–40px). Ny KONSTANT verdens-fonthøyde `LABEL_FONT_CM=5.0`,
  `fontSize = LABEL_FONT_CM × (zoom×BASE_SCALE)` → uniform («like store») OG label:rom-forhold
  IDENTISK skjerm↔PDF. Boks-metrikk (lineH, padding, radius, mono-font) gjort proporsjonal med
  fonten. `labelScale` ganger fonten → strekk/rotasjon printer trofast. Verifisert: forhold identisk
  ved skjerm-skala vs PDF-lik skala (før: ~3× avvik).
- **`fa4c647` — Del E (punkt 6, valgfritt): auto-label overlapp-nudge.** Overlappende AUTO-bokser
  dyttes fra hverandre langs lengderetningen (re-klemt i rom) via `_nudgeAutoLabel`/
  `_placedAutoLabelBoxes`; manuelt plasserte labels røres aldri. «Hold roterte auto-bokser i rom»
  var alt dekket av `clampInside`.

**Fil:** romtegner.html.

---

## Folie-label — hold i rom + breddebevisst + drag + farge (Del 1–4) — 2026-07-10

Forbedret varmefolie-labelen (navn + lengde·W) på tegning + PDF. **Plan først** der geometri berøres.

- **`9089a49` — Del 1+2: hold hele labelen i rommet + breddebevisst layout.** Rotårsak: labelen ble
  tegnet INNE i `ctx.clip('evenodd')` (rom minus hindringer) → boksen ble kappet ved romkant
  («xFoil…»). Fiks: labels tegnes i eget pass ETTER strip-løkka, UTENFOR klippet; ny `_drawStripLabel`
  klemmer hele boksen innenfor rom-polygonet (`_pipScr`/`_boxFitsPoly`/`_centroidScr`). Breddebevisst:
  to-linjers → én-linjes → callout (leder-strek til folie) når folien er for smal.
- **`e21a629` — Del 3: flyttbar label (drag) med varig effekt.** `strip.labelPos` + `hitStripLabel`
  + drag-wiring (speiler kabel-labels). Manuell boks m/ leder-strek; «↩ Tilbakestill label til auto»
  i høyreklikk. Persistens gratis (strip-spread ved lagring, `S.strips = data.strips` ved last).
- **`9676fd5` — Del 4: farge pr label + prosjekt-standard.** `strip.labelColor` (bakgrunns-hex, tekst
  auto-kontrast) + prosjekt-default `S.varmefolie.labelColor`. Kuratert 8-fargers palett, «🎨 Farge»-
  chip → `#label-color-panel` (pr-label + prosjekt-standard, «A»=Auto).

**Fil:** romtegner.html.

---

## Tilbehør: manuelt tilbehør faller ikke ut av materiallisten — 2026-07-10

- **`ec8ea07` — FlexFoil tang (og andre manuelle) kom ikke med i PDF-en.** Bug: manuelt tilbehør
  (avhuket AV som standard) hadde antallsfelt = 0. Huket montøren PÅ tangen uten å skrive et tall,
  ga `readRow` qty=0 → droppet (krever qty>0) → «FlexFoil tang» kom ikke med under «Tilbehør
  varmefolie». Fiks: manuelt tilbehør starter antallsfeltet på **1** (ikke 0); `readRow` teller
  avhuket manuelt tilbehør med tomt/0 antall som minst 1 (avrundet til `roundTo`) → faller aldri ut.
  Auto-tilbehør uendret (0 = ikke med). Verifisert på ekte PDF.

**Fil:** romtegner.html.

---

## Frihånds-varmematte — felttest R2–R6 (flukt-invariant + robusthet) — 2026-07-09

Felttest-forbedringer på frihånds-matte-verktøyet (`S.matPaths`, `_matFree*`/`drawMatPaths`/
`_drawMatPathCable`). Låste kabelregler (buesving = halvsirkel cc/2, ingen Y-splitt) intakt.

- **`e4e976a` — R2 #1: kabel ≥5 cm fra vegg + hindring, ingen matte utenfor rommet.** `_matFreeCableMarginCm`
  (5 cm innendørs / 0 snø), draw-time klamp (`clipScanlineToPolygon` + hindring-bbox) i `_matFreeCandidate`,
  render-klamp av kabel-strenger.
- **`8220726` — R2 #2: sammenhengende kabel med flukt-skjøt.** Én ubrutt kabel over alle bredder:
  strengene på et GLOBALT rutenett (full lane-kant + cc/2, steg cc) → nabobredder linjerer; skann-retning
  veksler pr bredde → siste streng møter første i neste rett over (flukt-`lineTo`, ikke U-sving).
- **`9352b3d` — R2 #3: vis tegnet lengde ved siden av valgt matte** («Tegnet X m → EcoMat … (rull Y m)»).
- **`e0147a8` — R3 #1: hold hele matta i rommet.** Start flyttet til NET/2 fra vegg + perpendikulær klamp
  i `_matFreeCandidate` (move.len=0 hvis lanen ikke får plass i tverr-retning).
- **`b0df3e6` — R3 #2+#3: flukt-retning (rett side) + ortogonal skjøt.** Skann bredden fra enden nærmest
  forrige utgang (`prevExitW`); L-forbindelse følger kant (aldri diagonal luftlinje).
- **`c994aa6` — R3 #1-rettelse: retningsavhengig start.** ½ cc mot kortside (bane-enden), 5 cm mot langside
  (50 cm-kanten) via `_matFreeStartFor(room,prod,axis)`.
- **`e0bea3a` — R4: kaldskjøt ved reell start + serpentin flukter mot neste.** Første breddes serpentin ordnes
  fra bane.a (`entryRef`); strand-paritet orientert ut fra neste breddes tverr-posisjon (`rNext`).
- **`4ee0823` — R5: fjern forbindelseskabel + valgbart start-hjørne.** Skjøt-connector → `moveTo` (hver
  serpentin for seg); `S.varmefolie.startCorner` (bl/br/tl/tr) generalisert med velger i matte-panelet.
- **`c53d909` — R6: varig flukt-invariant.** Fast regel i kabel-genereringen: hver bredde STARTER mot forrige
  (`entryHi` fra `prevExitW`) og ENDER mot neste (`exitHi` fra `rNext`) → skjøtene møtes alltid flush på delt
  kant, uansett retning/start/hjørne. Paritet-fiks kutter ±1×CC (Nuse=N−1) hvis utgangssiden blir feil.
  Erstatter R4-logikken (som bare styrte exit → feil entry-side).

**Fil:** romtegner.html.

---

## EcoMat matte — Del 3: eksakt mattelengde (N−1 like + kortere siste) — 2026-07-08

Auto-utlegget legger nå ut HELE rullelengden: **N−1 like bredder** (`Lc = ceil((total/N)/raster)·raster`) +
**1 kortere siste** (`last = total − (N−1)·Lc`) → summen = nøyaktig mattelengden. Tidligere ble N like
bredder snappet NED → for lite (f.eks. 9,6 av 10 m).

- **Datamodell:** nytt nullbart felt **`last_run_length_cm`** på matte-objektet (minst-invasivt; beholder
  ubrutt kabel — ikke eget matte-objekt). `num_runs` = N.
- **drawMats:** siste bane tegnes kortere (rektangel + serpentin med færre strenger), forankret i skjøt-enden
  (up-bane → bunn, down-bane → topp) så første streng flukter; kort ende = kald sone.
- **Kalkyler:** ny `_matLaidLengthCm(mat)` = `(N−1)·length_cm + last` brukt i areal/kabel/effekt/materialliste
  (`_computeRoomStats`, `_matRatedW`, PDF- + Excel-matList, info-panel, ctxbar, overskudds-varsel).

Verifisert (300×220, EcoMat 60T 0.5×10m, raster 24): **3 × 2,64 m + 1 × 2,08 m = 10,00 m**; areal 5,0 m²;
ctxbar «10,0/10,0m»; ingen overskudds-varsel. Regresjon: matte uten `last_run_length_cm` (manuell/snø/normal)
uendret. Buesving/flukt-skjøt/ingen Y-splitt intakt.

**Fil:** romtegner.html (`autoFillMatSerpentine`, `drawMats`, `_matLaidLengthCm` + kalkyle-steder).

---

## EcoMat matte — Del 2: kaldskjøt- + ende-markør — 2026-07-08

I `drawMats` fanges kabelens **startpunkt** (første `moveTo`) + retning og **endepunkt** (`pen`). Etter
`ctx.stroke()` tegnes OVER kabelen: **kaldskjøt** = sort strek (`#111`, tykkere enn kabel, ~8 cm langs første
streng, rund cap) ved start, og **ende-markør** = liten fylt sort sirkel ved siste strengs slutt. Én av hver
per sammenhengende matte-kabel (auto/manuell/snø, delt `drawMats`).

Verifisert (instrumentert canvas): nøyaktig 1 kaldskjøt-strek + 1 ende-fyll per matte.

**Fil:** romtegner.html (`drawMats` — start/slutt-fangst + markør-tegning).

---

## EcoMat matte — Del 1: serpentin-retning (venstre→høyre) — 2026-07-08

Fikset at kabelen startet på høyre ytterste matte og at matte 2 snudde feil vei. I `drawMats()`-serpentinen:
`const r = numRuns-1-vi` → **`const r = vi`** (venstre→høyre, kabel starter nederst-venstre) og
`startHi = jj%2===0` → **`startHi = jj%2===1`** (første streng starter venstre → første sving på høyre).
Buesving (halvsirkel cc/2) og flukt-skjøt urørt — låste kabelregler intakt. Gjelder auto/manuell/snø
(delt `drawMats`); ingen duplikat i PDF (mat-serpentinen finnes kun ett sted).

Verifisert: 412×253 med EcoMat 150T (8 baner) → ren serpentin, halvsirkel-U-svinger, flukt-skjøter,
ingen Y-splitt.

**Fil:** romtegner.html (`drawMats` serpentin-blokk).

---

## Leverandør-branding — Del 5: superbruker «vis som» — 2026-07-07

Superbruker kan vise appen **som en valgt org** (elektrobedrift eller leverandør) — branding + produkt-
tilgang + meny — uten å endre innlogging. Siste del av branding-featuren; hele Del 1–5 er nå komplett.

- `_viewAsOrg` (full org-objekt) + `_effectiveOrg()` som allerede brukes av branding (header + PDF).
  **`_productVisibleToOrg` bruker nå `_effectiveOrg()`:** superadmin uten «vis som» ser alt; med «vis som»
  gjelder valgt org sine regler (leverandør → kun egne produkter; installatør → alle).
- Avatar-meny (kun superadmin): **«Vis som…»** → `_viewAsPicker` (modal med alle orgs + type-badge) →
  `_viewAsSet`; **«Avslutt vis som»** når aktiv. Oransje topp-banner «👁 Viser som: <org> — avslutt»
  (`_viewAsBanner`). `_viewAsRefresh` re-rendrer branding + produkt-chips + panel + sidebar + ctxbar.
- Vanlige brukere ser aldri «vis som». RLS uendret (superadmin ser bredt uansett; «vis som» filtrerer
  visning/branding klient-side).

Verifisert: superadmin ser alt → vis som Cenika skjuler Varmecomfort (branding+gating+banner) → vis som
installatør ser alt → avslutt gjenoppretter. Script parser OK (node-sjekk).

**Fil:** romtegner.html (`_viewAsOrg`/`_viewAsPicker`/`_viewAsSet`/`_viewAsEnd`/`_viewAsBanner`,
`_productVisibleToOrg`, avatar-meny).

---

## Leverandør-branding — Del 4: app-header (co-brand i verktøylinja) — 2026-07-07

`_applyAppBranding()` brander editor-verktøylinja (`.tb-logo`): **[org-logo] Varmeplan** når «I appen»-flagget
er på + logo finnes; ellers nøytral «Varmeplan». Bruker `_effectiveOrg()` så superbruker «vis som» (Del 5)
også brander headeren. Kalles etter `_loadOrgBranding` (login/org-bytte) og fra branding-panelets toggler.

Verifisert: nøytral → «Varmeplan»; logo + «I appen» på → `<img>` (branding-URL) + «Varmeplan»; «I appen» av
→ nøytral igjen. (Dashboardets store «Varmeplan»-tittel er ikke brandet — mulig senere utvidelse.)

**Fil:** romtegner.html (`_applyAppBranding`, `_loadOrgBranding`).

---

## Leverandør-branding — Del 3: logo i PDF (forside/alle sider) — 2026-07-07

Org-logo (co-brand) i **prosjekt-PDF** (`exportPDF`) og **garanti-PDF** (`_docBuildPDF`) iht. plasserings-
flaggene. Nøytral Varmeplan-fallback når ingen logo/flagg.

- `_pdfBranding()` (async) laster org-logoen til data-URL via `_loadLogoImage` (canvas-rasterisering, takler
  PNG/JPG/SVG), cacher `_pdfBrandCache`. `_pdfStampBranding(doc, M)` stempler etterpå: **forside** = logo
  øverst til høyre (forsiden har allerede «VARMEPLAN»-tekst → ingen dobbel), **øvrige sider** = logo + liten
  «Varmeplan» når «Alle sider» er på.
- `exportPDF`: `await _pdfBranding()` før bygging, `_pdfStampBranding` før `save`. Garanti: `await _pdfBranding()`
  før den sync `_docBuildPDF`, som stempler før `doc.output('blob')`.
- `_effectiveOrg()` innført (returnerer `_userOrg` nå; «vis som»-org i Del 5).

Verifisert: funksjoner definert; ingen logo → `_pdfBranding` = null (nøytral, ingen regresjon); stempling
kjører feilfritt på fler-siders doc med begge flagg. Ekte logo på PDF testes etter at Del 1-migrasjonen +
opplasting er gjort.

**Fil:** romtegner.html (`_pdfBranding`/`_pdfStampBranding`/`_loadLogoImage`/`_effectiveOrg`, `exportPDF`, `_docBuildPDF`).

---

## Leverandør-branding — Del 2: admin-panel (logo-opplasting + plassering) — 2026-07-07

Ny «Logo & branding»-fane i org-admin-panelet (for alle orgs — leverandør + installatør; gated owner/admin +
superadmin som før). Last opp / bytt / fjern logo (PNG/JPG/SVG, maks 2 MB) → `branding`-bucket
(`<org_id>/logo.<ext>`, upsert) + `logo_path`/`logo_updated_at` på organizations. Forhåndsvisning viser
**co-branding: org-logo ǀ «Varmeplan»** alltid sammen. Tre plasserings-toggler (Forside PDF / Alle sider PDF /
I appen) lagres direkte på org-en.

- `_orgAdmRenderBranding`, `_brandingUploadLogo`/`_brandingRemoveLogo`/`_brandingSetFlag`, `_orgLogoUrl`
  (public URL + cache-bust på `logo_updated_at`).
- `_loadOrgBranding(orgId)` henter logo-kolonnene **separat og tolerant** (try/catch) etter org-resolve, så
  org-lasting ikke brekker om branding-migrasjonen ikke er kjørt ennå.
- Kaller `_applyAppBranding()` (kommer Del 4) via `typeof`-guard.

Verifisert: panel rendrer logo-boks + «Varmeplan» + «Last opp», 3 toggler reflekterer lagret state;
alle handler-funksjoner definert. Nøytral fallback («Ingen logo ǀ Varmeplan»).

**Fil:** romtegner.html (`_orgAdmRenderBranding` + branding-helpers, nav-item, `_loadUserOrg`).

---

## Leverandør-branding — Del 1: DB + Storage (logo + plasserings-flagg) — 2026-07-07

Første del av leverandør-/org-logo-branding. Kun DB/Storage — ingen app-kode ennå (så trygt å kjøre migrasjonen
uavhengig).

- **`organizations`** (baade leverandør- OG installatør-org kan ha logo): `logo_path`, `logo_show_cover`,
  `logo_show_allpages`, `logo_show_inapp` (default true), `logo_updated_at`.
- **Storage-bucket `branding`** (public read — logoer er ikke hemmelige → direkte URL i app + PDF).
- **RLS** på `storage.objects` for branding: skriv = superadmin ELLER owner/admin i org-en som eier stien
  (`<org_id>/…`); les = public. Superadmin-sjekk via `app_metadata` (aldri `auth.users`).

Prinsipp: **«Varmeplan» vises alltid sammen med org-logoen** (co-branding); ingen logo → nøytral Varmeplan.
`_effectiveOrg()` (kommer i Del 5) skal styre branding + produkt-tilgang for superbruker «vis som».

**Fil:** supabase-migration-branding.sql

---

## Aluboard: fullført DB-migrasjon (B5+B6) — 2026-07-07

Fullført `supabase-migration-varmecomfort-aluboard.sql`: alle **17 FLXHEAT 3 mm 8 W/m-kabler** som ferdige
`insert`-rader (m/watt/EL/nominell Ω, watt_per_m 8, 230 V, aluboard_cc_mm 100, bøyeradius 36 mm, maks 90 °C),
i tillegg til de 2 platene. Lagt til `price_list`/`cost_price`-mal (B6) med `update`-eksempler — faktiske
Varmecomfort-priser fylles inn fra prislista. Idempotent (guard på `el_no`). Kun DB-fil; app-koden
(fallback-seed) hadde allerede kablene.

**Fil:** supabase-migration-varmecomfort-aluboard.sql

---

## Aluboard: prosjekt-brede integrasjoner (A1–A4) — 2026-07-07

Koblet `S.aluboard` inn i de prosjekt-brede aggregeringene (var «silo» etter Del 1–6). Sentral helper
`_aluboardComponents(ab)` / `_aluboardRoomItems(roomId)` ekspanderer en Aluboard til rette plate + vendeplate
+ valgt FLXHEAT-kabel (med antall/meter/effekt); alt gjenbruker den.

- **A1 Materialliste/Bestilling/Tilbudspris (PDF + Excel):** Aluboard-produktene (12 rette + 12 vende + kabel)
  telles nå i eksportens materialliste, ordreliste og tilbudspris-ark.
- **A2 Effekt/areal:** `_computeRoomStats` + `_roomRatedEffectW` teller Aluboard (kabelens ratede effekt +
  areal = kabel_m / 10 fra fast CC 10). Rom med Aluboard viser nå riktig W i Prosjekt-/Romoversikt (ikke 0).
- **A3 Rom-detalj i sidepanelet:** «Varme (N)» lister nå Aluboard (klikk → velg).
- **A4 Rabatt per gruppe:** `_projectUsedProductIds`/`_roomProductBreakdown`/`_roomDominantProduct` inkluderer
  Aluboard → familiene «Aluboard» + «FLXHEAT 8W/m» får rabatt-felt i tilbudspris, og vises i Romoversikten.

Verifisert (rom 360×300): ratedW 720, totalW 720, heatedM2 8,6; breakdown = kabel (720 W) + 12 rett + 12 vende;
tilbudspris-grupper «Aluboard»/«FLXHEAT 8W/m». Andre moduler uendret.

**Fil:** romtegner.html (`_aluboardComponents`/`_aluboardRoomItems`/`_aluboardRoomEffectW`, `_computeRoomStats`,
`_roomRatedEffectW`, `_roomProductBreakdown`, `_roomDominantProduct`, `_projectUsedProductIds`, PDF- + Excel-
materialliste, sidepanel-liste).

---

## Aluboard platesystem (Varmecomfort) — Del 6: interaksjon + dok-kobling — 2026-07-07

Siste del: velg/slett + kobling av Varmecomfort-målregler til dok-/garantimodulen. (Lagring + undo/redo var
allerede på plass fra Del 1.)

- **Interaksjon:** `hitAluboard` (treff = punkt i feltet — rom-fyllende, så ingen «flytt»), `selectAluboard`
  (rydder andre seleksjoner, `S.ui.selectedAluboardId`), `deleteAluboard`, wiret inn i hit-syklusen
  (`_buildCycleCandidates`/`_applyCycleSelection`). Ctxbar for valgt Aluboard: **retning Vertikal/Horisontal**
  (`_aluboardSetDirSel` re-legger + beholder valg), kabel-lengde, **Slett**. Valgt felt får accent-omriss.
- **Dok/garanti — asymmetrisk toleranse:** ny `_supResistanceBounds(sup, nominal)` støtter
  `resistance_tol_minus_pct`/`plus_pct` (Varmecomfort **−5 %/+10 %**), faller tilbake til symmetrisk
  `resistance_tolerance_pct`. `_docMeasOk` + kravtekst + lo–hi-visning bruker den nå.

Verifisert: hit→velg fester, ctxbar (Aluboard/Vertikal/Slett), retning-toggle beholder valg, slett + undo;
VC-grenser for 73 Ω = 69,35–80,3 Ω («−5 %/+10 %»), måling 80 Ω OK / 68 Ω ikke OK; Cenika = ±10 %. Andre
moduler uendret. **Aluboard-modulen (Del 1–6) er nå komplett.**

**Fil:** romtegner.html (`hitAluboard`/`selectAluboard`/`deleteAluboard`/`_aluboardSetDirSel`, ctxbar-gren,
`_supResistanceBounds`, `_docMeasOk`).

---

## Aluboard platesystem (Varmecomfort) — Del 4+5: panel + materialliste + varsler — 2026-07-07

Panel-inngang og materialliste for Aluboard, wiret inn i den delte produktvelgeren (`_upcRefreshResults`
→ ny `aluboard`-gren). Modulen nås via «Aluboard»-produkttype-chip (rolle-gated: elektrobedrift +
Varmecomfort ser den, Cenika ikke).

- `_aluboardRenderPanel(container, roomId)`: **retning Vertikal/Horisontal** (eneste montørvalg) + «Fyll
  rom automatisk». Resultater: fast CC 10, flateeffekt ≈80 W/m², kabelbehov, valgt kabel ≤ behov (m + EL),
  effekt/motstand fra katalog.
- **Del 4 (kabelvalg):** største katalog-lengde ≤ behov (aldri mer kabel enn nødvendig), siste streng
  kappes (`restM`), og **kanttilfelle < 10 m** gir overskudds-varsel (grønn OK-boks ellers).
- **Del 5 (materialliste):** rett plate (EL 5402067) + vendeplate (EL 5402066) med «del plate på to»-
  telling, FLXHEAT-kabel (valgt m + EL), aluminiumstape (≈ (rette+vende)×1,2 m), byggplast «ved behov».

Verifisert (360×300 vertikal): behov 87,9 m → 86,0 m EL 1006058 · 720 W · 73 Ω; 12 rette + 12 vende;
overskudds-varsel ved 70×70 (behov 1,15 m < 10 m); chip gated (installatør+VC ja, Cenika nei). Andre
moduler uendret.

**Fil:** romtegner.html (`_upcRefreshResults`-gren, `_aluboardRenderPanel`, `_aluboardSetDir/FillRoom`).

---

## Aluboard platesystem (Varmecomfort) — Del 3: plater fyller feltet — 2026-07-07

Plater fyller HELE feltet i begge retninger: **vendeplater** (28 cm) i de to v-endene der kabelen snur,
**rette plater** (120 cm) imellom — kuttes i lengde. Kappede plater markeres stiplet i tegningen; kabelen
tegnes oppå platene.

- `_aluboardPlates(L)` → felt-koordinat-rekter per kolonne (2 vende-bånd + rette plater vA→vB), med `cut`-flagg.
- `_aluboardPlateCount(L)` → antall til materiallista med **«del plate på to»**: kolonne-remse < ½ plate →
  `ceil(n/2)`, rad-remse < ½ plate → `ceil(n/2)`, + hjørnebit. (Materiallista vises i Del 5.)
- `drawAluboard` rendrer nå platene (vende #f4e6db, rette #e6eef1, kappet = stiplet) UNDER kabelen.

Verifisert (rom 360×300 vertikal): plate-telling **12 rette + 12 vende** (fasit); 24 fysiske plate-rekter
(6 kolonner × 2 vende + 2 rette), 9 kappede. Renderer som mockup. Andre moduler uendret.

**Fil:** romtegner.html (`_aluboardPlates`, `_aluboardPlateCount`, `drawAluboard`).

---

## Aluboard platesystem (Varmecomfort) — Del 2: auto-geometri (kabel-serpentin) — 2026-07-07

Auto-geometri for Aluboard: én sammenhengende varmekabel-serpentin i de faste sporene (CC 10), U-svinger
som halvsirkler (radius CC/2 = 5 cm) i vendeplate-sonene, retning H/V (eneste montørvalg). Alt derivert
fra state (`_aluboardCompute(room, dir)` — ingenting lagret som piksler).

- Konstanter `_ALU` (EDGE 4, PLATE_W 60, RETTE_L 120, VENDE_D 28, CC 10, RUN_EDGE 5) fra mockup-fasit.
- `_aluboardCableCatalog` (FLXHEAT sortert), `_aluboardCompute` (felt/strenger/kabelbehov/valgt kabel),
  `_aluboardCablePath` (sammenhengende polyline, siste streng kappet ved budsjett = valgt kabel).
- `_aluboardAutoFill(roomId, dir)` lager S.aluboard-oppføring (én per rom); `drawAluboard()` tegner felt-
  omriss + serpentin i «Heating elements»-laget (etter drawPlates). `_aluboardsForRoom`.
- Bugfiks: `nextAluboardId` manglet i nytt-prosjekt-counters-reset + migrasjonsguard for lastede prosjekt.

Verifisert mot fasit (rom 360×300 vertikal): 35 strenger × 236 cm → **kabelbehov 87,94 m** → valgt
**86,0 m (EL 1006058, 720 W, 73 Ω)**, siste streng **1,94 m kortere** (shortLast), path = 86,0 m.
Renderer som mockup (én ubrutt kabel, halvsirkel-U-svinger). Andre moduler uendret.

**Fil:** romtegner.html (`_ALU`, `_aluboardCompute/CablePath/AutoFill`, `drawAluboard`, render-hook).

---

## Aluboard platesystem (Varmecomfort) — Del 1: leverandør + katalog + gating — 2026-07-07

Første del av ny modul for **Aluboard platesystem** fra leverandøren **Varmecomfort** (eget datasett, IKKE
Cenika). Kun data + tilgang + state-slot — ingen geometri/UI ennå.

- **State:** `S.aluboard = []` + `nextAluboardId`-teller; med i pushUndo/undo-restore, `_buildSaveData` og
  `_restoreProject` (lagres i prosjekt-JSON, tåler gamle prosjekt uten feltet).
- **Leverandør-gating (ny dimensjon i tegneverktøyet):** `_productVisibleToOrg(prod)` — en LEVERANDØR-org
  ser kun egne produkter (`p.supplier === org.supplier_name`); elektrobedrift + superadmin ser ALLE.
  Anvendt i `_upcScopeProducts` + `_upcRenderTypeChips`. Skjuler Varmecomfort for Cenika-org.
- **Katalog (fallback-seed `_ensureVarmecomfortProducts`):** kategori «Aluboard platesystem»
  (`module_type:'aluboard'`, `available_contexts:['indoor']`), 2 plater (rett 60×120 EL 5402067,
  vende 28×60 EL 5402066) + 17 FLXHEAT 3 mm 8 W/m-kabler (meter·watt·EL·nominell Ω). Type-chip-label «Aluboard».
- **Migrasjon:** `supabase-migration-varmecomfort-aluboard.sql` — asymmetrisk resistanstoleranse på
  `suppliers` (−5 %/+10 %, lengde ±2 %), Varmecomfort-rad, Aluboard-kategori, produkt-inserts (tilpass
  kolonnenavn).

Verifisert: gating (installatør ser alle, Cenika-org ser 0 Varmecomfort, Varmecomfort-org ser kun sine,
superadmin alle); 19 produkter seedet; EL 1006058 = 86 m/720 W/73 Ω (fasit). Andre moduler uendret.

**Fil:** romtegner.html (state, `_productVisibleToOrg`, `_ensureVarmecomfortProducts`), migrasjon.

---

## Tilbudspris: rabatt per produktgruppe (+ hierarki) — 2026-07-07

Utvidet den enkle globale «Rabatt %» i PDF-eksport til et **rabatt-hierarki**: produkt > gruppe >
leverandør > global (mest spesifikk vinner). Kjøperens rabatt, så den lagres på **prosjektet**
(`S.project.pricing`), ikke som produktegenskap — forhåndsutfylt neste gang.

Eksport-dialogen lister nå **produktgruppene som er i prosjektet** (via `product_family`) med et rabatt-felt
hver (blank = standard). Skriver du f.eks. rabatt på «InFloor 17T», gjelder den ALLE InFloor 17T. `veil.pris`
(`price_list`) ligger allerede per produkt. PDF-prisarket regner nå nettopris per linje via
`_resolveDiscountPct(prod, opts)` og viser Veil.pris · Rabatt% · Pris · Sum; DG/DB/kostpris er bak «Vis
DG/DB (intern)» (skjult for kunde som før).

Nye: `_projectUsedProductIds`, `_projectProductGroups`, `_resolveDiscountPct`. Verifisert: hierarkiet
(global 10 → gruppe 30 → produkt 45; leverandør 22), dialog lister EcoMat 60T + InFloor 17T med felt, og
rabattene lagres på prosjektet.

**Fil:** romtegner.html (`_showExportDialog`, `_runExportPDF`, PDF Tilbud-seksjon).

---

## Produktkatalog (read-only, rolle-gatet) — 2026-07-07

Ny read-only produktkatalog i admin-panelene. **Rolle-gating:** superadmin ser ALLE produkter (scope
`all`, med leverandør-filter); en **leverandør-org** ser kun sine egne (scope = orgens `supplier_name`,
matchet mot `p.supplier`); **installatør-orgs har ingen inngang** (nav-item gated på `org_type='supplier'`
+ superadmin, pluss defense-in-depth i `_orgAdmRenderCatalog`).

Delt renderer `_renderProductCatalog(el, scope)`: gruppert per kategori (med kategoriens
`available_contexts`-badges), kolonner El-nr · Art.nr · Produkt · Familie · Effekt · CC · Veggmargin, med
søk + type-filter (+ leverandør-filter for superadmin). Wiret inn i superadmin-panelet (ny «Produktkatalog»-
fane ved siden av «Produktimport») og org-admin-panelet for leverandører (ny «Produktkatalog»-fane; den
gamle «Produkter»-fanen ble «Produktimport»).

Verifisert: 6 kategorier / 299 produkter i scope `all`; type-filter (mat → kun matte-kategorier);
leverandør-scope filtrerer på `p.supplier`; kontekst-badges vises (bekrefter at migrasjonen satte
Varmekabel/InFloor = {indoor,outdoor}, Varmefolie = {indoor}).

**Fil:** romtegner.html (`_renderProductCatalog`, `_admRenderCatalog`, `_orgAdmRenderCatalog`, nav + switch).

---

## Produkt-tilgjengelighet per modul-kontekst (indoor/outdoor) — 2026-07-07

Erstatter den gamle navne-hacken (`c.name.includes('utendørs')`) for hvilke produkter som vises i hvilke
moduler, med en eksplisitt, data-drevet parameter på produktkategorien (gruppen):
**`available_contexts text[]`** — delmengde av `{indoor, outdoor}`. En gruppe kan være i BEGGE (f.eks.
InFloor-kabel = `{indoor,outdoor}`), noe navne-hacken ikke kunne uttrykke.

Design-modulene mapper til kontekst i appen (`_moduleEnv`): **snø + trapp = outdoor**, resten (indoor,
list) = **indoor**. Nytt filter `_catAvailableInModule(cat, modul)` bruker `available_contexts` når satt,
ellers **back-compat** til dagens navne-logikk — så koden virker uendret FØR migrasjonen er kjørt. Byttet
i `_upcScopeProducts`, `_upcRenderTypeChips` og `_listIndoorCat`. Kategoriene lastes rått fra Supabase, så
den nye kolonnen følger automatisk med.

Migrasjon: `supabase-migration-product-contexts.sql` (idempotent) — legger til kolonnen, backfiller fra
navn (`utend…` → outdoor, ellers indoor), og setter InFloor-kabel til `{indoor,outdoor}` (juster
kategorinavn). Reglene (margin/CC) er fortsatt modul-styrt, ikke gruppe-styrt.

Verifisert: `_moduleEnv` (snow/stair→outdoor), tagget indoor-only/outdoor-only/both filtreres presist,
utaggede kategorier beholder gammel oppførsel; indoor-scope returnerer produkter som før.

**Fil:** romtegner.html (`_moduleEnv`, `_catAvailableInModule`, 3 filter-steder), supabase-migration-product-contexts.sql.

---

## Varmematte: unifisert kappbar-modell for snø-manuell (retting) — 2026-07-07

Domeneretting: **alle** varmekabelmatter (innendørs EcoMat OG snø InSnow 300T) har fast kabel + KAPPBART
nett — nettet kappes ved raster (2×cc) for å folde/vende matta. Den forrige snø-manuell-antakelsen («faste
pre-fabrikerte lengder, ingen nett-kapp») var feil.

Snø-manuell bruker nå **samme kappbar-modell som innendørs**: fritt lengde-felt per bane, snappet til
raster. `snow`-flagget styrer nå BARE installasjonsreglene — ingen veggmargin (pakkes til kanten) + gap
min 5 cm — mot 5 cm margin + 0–5 cm gap innendørs. Fjernet snø-særtilfellet for lengde i `_matManualApply`,
byttet variant-dropdownen med tall-felt, og slettet nå-overflødige `_matSnowVariants`/`_matManualSetBaneProduct`.

Verifisert: snø-bane 250/300 cm → snappet 240/288 (raster 16 cm), flush til kant (margin 0), kabel 15+18 m;
panelet bruker tall-felt (ingen dropdown). Innendørs manuell uendret (ingen regresjon).

**Fil:** romtegner.html (`_matManualApply`, `_matSnowManualStart`, `_matManualRenderPanel`, add/del-bane).

---

## Varmematte: manuell bane-liste også for snø-matter (Del 5b) — 2026-07-07

Utvidet den manuelle bane-lista til **snø-matter** (InSnow 300T). Samme motor (`_matManualApply`),
generalisert med en `snow`-modus: snø bruker **faste pre-fabrikerte lengder** (per-bane produktvalg,
ingen raster-kapp), **ingen veggmargin** (pakkes til kanten) og **gap min 5 cm** — mens innendørs beholder
kappbar rull (raster-snap), 5 cm margin, 0–5 cm gap. Hver bane er fortsatt en egen matte med egen serpentin.

UI: «Manuell (bane-liste)»-knapp i snø-panelet (`_upcRenderMatResults`) → `_matSnowManualStart`; bane-lista
rendres i `#upc-results` med **lengde-dropdown per bane** (InSnow-varianter) i stedet for fritt tall.
`_upcRefreshResults` gir bane-lista forrang så den ikke overskrives av produktlista når panelet re-rendres.

Verifisert: snø-rom med 2m stå + 6m liggende → 2 faste matter (1,0 + 3,0 m², kabel 12,5 + 37,5 = 50 m, 1200 W),
flush mot kant uten margin, riktig serpentin. Innendørs manuell uendret (ingen regresjon).

**Fil:** romtegner.html (`_matManualApply`, `_matSnowManualStart`, `_matSnowVariants`, `_matManualRenderPanel`,
`_upcRenderMatResults`, `_upcRefreshResults`).

**Merk (delt kode):** snø-matter fikk allerede Del 2 (serpentin-geometri, halvsirkel cc/2, én kabel per
matte) og Del 3a (resultat-labels) gratis, siden de deler `drawMats`/`updateObjInfo` med innendørs.

---

## Varmematte: manuell modus — bane-liste (Del 5) — 2026-07-07

La til manuell utlegg som mockupen: montøren bygger en **bane-liste** (legg bane for bane, bland Stå/Ligg
fritt, lengde snappes til raster 2×cc). **Hver bane = en egen matte** (`num_runs:1`) med egen serpentin/
kabel — gjenbruker `drawMats`/hit/select/lagring. Banene **hylle-pakkes** venstre→høyre fra rommets
margin-hjørne og brytes til ny hylle ved rombredden (fra mockupens `renderManual`).

Kjerne: `_matManualApply` (bygger mat-objektene tagget `_manualGroup`, regner om verdens-topp-venstre →
pre-rotasjons x/y for rot 0/90), `_matBaneCableM` (kabel = areal ÷ cc), `_matStdSizes` (standardstørrelser
fra katalogen). UI: «Manuell (bane-liste)»-knapp i mat-panelet → bane-liste med Stå/Ligg-toggle, lengde,
«≈ X m kabel», slett, «+ Legg til bane», og totaler (baner, dekket areal, kabellengde, effekt, foreslått
matte ≤ areal). Live re-pakking ved hver endring.

Verifisert mot mockup-matematikken: baner v192+h240 → 2 matter (0,96 m²/8 m + 1,20 m²/10 m, tot 2,16 m²/
18 m); 3-bane mikset utlegg (Stå+Ligg+Ligg) rendrer 3 separate matter med egen kabel, riktig hylle-pakking
og totaler (3,00 m² · 25 m · 180 W). Kjent begrensning: å gå inn i manuell modus på nytt starter en fersk
liste (eksisterende manuell-gruppe erstattes).

**Fil:** romtegner.html (`_matManualApply` m.fl., `showMatPlacePanel`).

---

## Varmematte: «Sentrer / Fra vegg»-toggle (Del 3b) — 2026-07-07

Auto-utlegget sentrerte alltid matten (kaldt felt likt på begge vegger). La til mockupens **«Fra vegg»**-
valg: blokka legges inntil margen på start-siden, alt kaldt felt havner på motsatt vegg. Ctxbar-chip
(Sentrer ↔ Fra vegg, kun innendørs matte — snø pakkes annerledes) via `_matToggleFromWall`, som legger
matten ut på nytt i samme rom og retning (`autoFillMatSerpentine` leser `S.varmematte.fromWall`;
`acrossCenter` = margin-flush vs sentrert). Gammel matte fjernes etter at ny er lagt (ett angre-steg
gjenoppretter originalen), og sidebaren re-rendres.

Kaldt felt rapporteres fortsatt symmetrisk (`coldS/2`) i info-panelet, som mockup-fasiten. Verifisert:
toggle-syklus Sentrer→Fra vegg→Sentrer beholder retning (rot 90) + antall baner (4), holder seg på ÉN
matte, og y-posisjon flytter (−10 → −15 → −10); matten ligger visuelt flush mot vegg i «Fra vegg».

**Fil:** romtegner.html (`autoFillMatSerpentine`, `_matToggleFromWall`, ctxbar-matteblokk).

---

## Varmematte: rom-nivå resultat-labels for valgt matte (Del 3a) — 2026-07-07

Info-panelet for en valgt matte viste villedende **én-bane**-tall (`Areal 1,20 m²`, `Effekt 72 W`) selv
når matten hadde flere baner. Endret til **rom-nivå**-resultater som mockup-fasiten: Retning
(Liggende/Stående), Antall baner (× lengde/bane), Dekket areal (total), **Kaldt felt/side**, CC,
**Kabellengde** (≈ areal ÷ cc), Klipp, og **Effekt (total)**.

Kaldt felt lagres på matten ved auto-utlegg (`_coldTotalCm = acrossSpan + 2·margin − block`, målt mot
FULL romvegg inkl. margin, deles likt ved sentrert) → 300×220 EcoMat 60T gir 10 cm/side (fasit).
Verifisert: panelet viser Dekket 4,80 m², Kaldt felt/side 10 cm, Kabellengde ≈ 40 m, Effekt 288 W.

Gjenstår (Del 3b): «Fra vegg»-toggle (veggflukt-plassering i stedet for sentrert).

**Fil:** romtegner.html (`autoFillMatSerpentine`, `updateObjInfo`).

---

## Varmematte: serpentin-geometri = LÅST mockup-fasit (Del 2) — 2026-07-07

`drawMats`-serpentinen avvek fra den låste geometrien: U-svingene var **ellipser** (`xR = min(cc/2, 2,5)`
× `cc/2`), hver bane hadde sin **egen** `beginPath` og banene ble koblet med **U-sving-arcer** i skjøten —
i strid med «halvsirkel radius cc/2», «én sammenhengende kabel» og «rett flukt-skjøt».

Skrevet om til **én sammenhengende kabel** som følger mockupen: baner tas høyre→venstre, strenger går på
tvers av 50 cm-bredden og avanserer cc langs lengden, **halvsirkel-U-svinger radius cc/2** med cc/2-inntrekk
(svingen lander på 2,5 cm-margen, aldri utenfor 50 cm), og **rett flukt-overgang** i skjøten mellom baner
(ingen sving, ingen Y-splitt).

Verifisert på 300×220 (4 baner) ved å instrumentere canvas-kallene: 1 `moveTo` (én kabel), 76 `arc` alle
med radius cc/2, 3 rette skjøt-linjer, **0 `ellipse`**. num_runs=1 (én bane) rendrer uten feil. Snø-matter
bruker samme `drawMats` — endringen er generell.

**Fil:** romtegner.html (`drawMats`).

---

## Varmematte auto: retning = best dekning (Del 1) — 2026-07-07

Del av verifisering-mot-mockup + gap-tetting for den eksisterende innendørs Varmematte-modulen
(EcoMat). **Del 1:** `autoFillMatSerpentine` valgte retning via `_suggestDirection` (PCA på romform),
ikke «prøv begge, best dekning» som mockup-fasiten. Bytta til en **mat-lokal** best-dekning-velger som
regner baner×lengde for både stående/liggende på den brukbare (margin- + hindring-innskrenkede) rekta og
velger størst dekket areal; uavgjort → stående (som mockup). Bruker-overstyrt retning vinner fortsatt.

`_suggestDirection` er **urørt** (folie/kabel bruker den) → ingen regresjon. Verifisert: 260×250 gikk fra
liggende 4 baner (4,80 m²) til stående 5 baner (6,00 m²); 300×220 forblir liggende 4; overstyring virker.

**Fil:** romtegner.html (`autoFillMatSerpentine`).

---

## Romoversikt: én rad per unik produkt-variant (fiks mikset multi-kabel) — 2026-07-07

**Bug:** Romoversikten (PDF-tabell + Excel «Per rom») antok ett dominant produkt per rom. Et rom med
FLERE ULIKE kabler (multiCableGroup, f.eks. 1× 1700W + 1× 1300W) kollapset til én rad der Antall =
antall elementer (2), W = romtotal (3000) sto ved siden av kun det dominante produktet (1700W), og den
andre kabelen forsvant. CC var også feil på avledede rader.

**Fiks:** ny `_roomProductBreakdown(room)` grupperer rommets elementer per produkt →
`[{product, kind, count, effectW}]` (effekt som i `_roomRatedEffectW`, dominant først). Begge tabellene
(`_runExportPDF` Romoversikt ~32874 + Excel «Per rom» ~38923) skriver nå **én rad per unik variant**:
Antall = antall identiske av varianten, W = variantens effekt (Σ = romtotal), CC = rommets FELLES CC på
hver rad. Etasje/Rom/Areal/W-m² kun på første variantrad (rom-nivå, unngår dobbelt-areal).

**Ingen regresjon:** enkeltkabel og N LIKE kabler → nøyaktig én rad som før (samme produkt ⇒ én gruppe).
Materiallista uendret. Verifisert (syntetiske rom): MIX 1700+1300 → to rader (1700 / 1300, Σ 3000);
SINGLE → én rad; TWOSAME (2× 1300) → én rad (Ant 2, W 2600).

**Test:** kjør Romoversikt-PDF (eller Materialliste-Excel, arket «Per rom») på et prosjekt med et rom som
har to ulike kabler → rommet får én rad per kabel-variant med riktig Antall/W og felles CC.

**Fil:** romtegner.html (`_roomProductBreakdown`, `_runExportPDF`, `_exportMaterialListXLSX`).

---

## PDF-eksport: forhåndsvisning for dokument-seksjonene — 2026-06-25

Utvider forrige (navn = preview, boks = hake) til de øvrige seksjonene: **Forside,
Prosjektoversikt, Romoversikt, Materialliste, Dokumentasjon, Signaturside**. Radene er nå `<div>`
med navn-`<span onclick=_expPreviewSection(kind)>` (klikk = forhåndsvisning) + avkrysningsboks som
kun toggler. Ny `_expPreviewSection(kind)` rendrer en HTML-representasjon fra ekte prosjektdata:
forside (navn/kunde/dato), prosjektoversikt (KPI: effekt/areal/rom/trapper), romoversikt (tabell),
materialliste (Produkt/Antall/El.nr/Art.nr), dokumentasjon (antall dok. rom), signaturside (mal).
Verifisert: alle 6 navn-klikk rendrer riktig preview uten å endre haken; boks-klikk toggler uten
preview.

**Fil:** romtegner.html (`_showExportDialog`, `_expPreviewSection`).

---

## PDF-eksport: respekter rom-utvalg + skill preview fra hake — 2026-06-25

1. **Bug:** deselekterte rom kom likevel med i PDF-en. `exportPDF` brukte
   `opts.rooms && opts.rooms.length > 0 ? … : S.rooms` → tomt utvalg falt tilbake til ALLE rom.
   Fikset til `Array.isArray(opts.rooms)` (og tilsvarende for `opts.stairs`) → et eksplisitt TOMT
   utvalg gir ingen romsider; kun `undefined` (ingen dialog) faller tilbake til alle.
2. **UX:** rom-/trapp-radene i eksport-dialogen er nå `<div>` (ikke `<label>`): **navnet** er en
   `<span onclick=_expPreviewRoom>` (klikk = kun forhåndsvisning), og **avkrysningsboksen** toggler
   kun ved klikk i boksen. Så man kan se hva hvert rom viser før man velger hva som skal med.
- Verifisert: navn-klikk rendrer preview uten å endre haken; boks-klikk toggler uten preview;
  hak av alle → 0 romsider; default-eksport uendret.

**Fil:** romtegner.html (`_showExportDialog`, `exportPDF` `_selectedRooms`/`_selectedStairs`).

---

## Innendørs multi-kabel: bevar ULIKE kabler ved re-layout — 2026-06-25

**Bug:** manuelt 1300 W + 1700 W (InFloor 10T) → den lengste kabelen la seg feil (ekstra bue),
soner ble LIK-store.

**Funn (bekreftet):** selve initial-plasseringen er allerede proporsjonal (forrige økt): 33,4 m²,
CC 11,1 cm, soner 56,7 %/43,3 %, ingen overflyt. Bug-en lå i **re-layout-stiene**:
`_cableFlipDirection`, `_reapplyCableDirection` og `_cableToggleMultiMode` re-utla gruppa via
`autoFillMultiCable(roomId, cable.productId, group.length)` = ett produkt × antall = N IDENTISKE
→ en mikset gruppe ble revertert til like soner (begge kabler = valgt produkt) → avvikende kabel
overflyter (buen i bildet).

**Fiks:** ny `_relayoutCableGroup(roomId, group, cable, dir)` som bevarer per-kabel-produktene for
MIKSEDE grupper (`_autoFillMixedCables` → proporsjonale soner, felles CC); like grupper beholder
N×like/korridor. Brukt i flip + reapply. Korridor-modus blokkeres for miksede grupper (krever like).

**Verifisert (canvas + tall):** flip [170,130]→[170,130] (56,7/43,3, retning snudd), reapply likeså,
N×like uendret (50/50), ren serpentin uten bue.

**Filer:** romtegner.html (`_relayoutCableGroup`/`_groupIsMixed`/`_groupProductIdsOrdered`,
`_cableFlipDirection`, `_reapplyCableDirection`, `_cableToggleMultiMode`).

---

## Innendørs: ULIKE kabler i samme rom (soner ∝ effekt) — 2026-06-25

Mål: tillate 2+ ulike kabler (samme familie) i ett rom, ikke bare N×like. F.eks. 3000 W med
InFloor 10T: anbefalt 2×1500, men ved lagermangel 1300+1700.

### Del A — Sone-motor for ulike kabler ✅
- `_buildNCableZones` generalisert fra ett produkt × N til en **produktliste** (ett per kabel).
  Ny `_weightedBandBounds` (generalisering av `_equalAreaBandBounds`) gir bånd med areal ∝ vekt
  (= kabellengde = effekt). Felles CC fra total lengde → samme W/m² i alle soner. Hjørne-snap
  brukes kun for LIKE soner. N×like er spesialtilfellet (like vekter) → ingen regresjon.
- Delt kjerne `_autoFillCableZonesCore` (retnings-heuristikk uendret); `_autoFillNCables` (N×like)
  + ny `_autoFillMixedCables(roomId, productIds, forcedDir)` (krever samme familie + W/m).
- Verifisert (30 m² rom, InFloor 10T): 130+170 → soner **43,3 %/56,7 %**, felles CC 10 cm, 3000 W;
  2×150 → like soner, CC 10 cm (ingen regresjon).

### Del B — Forslag: alternative ulike-kombinasjoner ✅
- Ny `_generateMixedCombos(familyProducts, desiredW, netM2, tol)`: alle gyldige 2-kabel-kombinasjoner
  fra familien som summerer til behovet (±tol), med gyldig felles CC (`netM2/Σlengde`). Rangert
  **nærmest behov først, så likest split** → eksakt-treff samles øverst med felles CC. Balansert
  eksakt-treff får `recommended:true` (★). Returneres som `mixedCombos` fra `selectMultiCables`.
- Verifisert (3000 W): 1500+1500 (★) · 1400+1600 · 1300+1700 · 1200+1800 · 1000+2000 — alle CC 10 cm,
  deretter nær-treff (2900/3100 …) under.

### Del C — UI: valgbare ulike-kabel-alternativer ✅ (manuell komponering gjenstår)
- Kabel-panelet viser nå en «Ulike kabler (samme dekning)»-seksjon med de eksakte ulike-
  kombinasjonene fra `mixedCombos` (jevnest først) som valgbare knapper. Klikk → `_placeMixedCables`
  → `_autoFillMixedCables` legger ut proporsjonale soner (K1/K2, felles CC).
- Verifisert visuelt: 130+170 i ett rom → to soner (oransje K1 1300 W / blå K2 1700 W), felles CC
  10 cm, riktige produkter/EL. N×like og enkeltkabel uendret.
### Del C.2 — Manuell komponering ✅
- «＋ Komponer ulike kabler selv…» i kabel-panelet åpner en modal (`_openMixComposer`/
  `_renderMixComposer`): kabelrader (K1/K2/…) med produkt/effekt-dropdown per rad fra familien,
  «＋ Legg til kabel», fjern per rad. Valgfritt «Årsak»-felt (f.eks. lagermangel), lagres på
  kablene (`mixReason`). «Plasser i rom» → `_placeMixedCables`.

### Del D — Validering ✅
- `_mixComposerStats`: løpende **Sum effekt** vs behov, **Felles C-C**, og **Gyldig/Ugyldig**-pill.
  Avvik flagges tydelig: sum >12 % fra behov, eller C-C utenfor produktets område. «Plasser»
  deaktiveres når ugyldig. (`_generateMixedCombos`/`_autoFillMixedCables` slipper uansett kun
  gyldige gjennom: samme familie/W/m, gyldig CC, ±tol.)
- Verifisert: 130+170 → Sum 3000 W, CC 10 cm, ✓ Gyldig; 200+200 → 4000 W, ⚠ Ugyldig (apply av);
  legg til/fjern rad; «lagermangel» lagret; apply plasserte K1 1300 W + K2 1700 W.

**Filer:** romtegner.html (`_buildNCableZones`/`_weightedBandBounds`, `_autoFillCableZonesCore`/
`_autoFillMixedCables`, `_generateMixedCombos`/`selectMultiCables`, `_placeMixedCables`,
`_openMixComposer`/`_renderMixComposer`/`_mixComposer*`, kabel-panel-render).

---

## PDF-materialliste: antall + fjern Lengde/Areal/Effekt — 2026-06-25

Materiallisten i PDF-eksporten (`exportPDF`) skal kun være en oversikt over hvilke produkter
som er medtatt. Kolonnene er endret fra Produkt·Lengde·Areal·Effekt·El.nr·Lev.art.nr til
**Produkt · Antall · El.nr · Lev.art.nr** (bruker `info.count` fra aggregeringen, som allerede
telte antall per produkt men ikke ble vist). «Total installert effekt»-linja i materialliste-
delen er fjernet (samme tall vises i sammendraget/INSTALLERT EFFEKT). Rom-/spesifikasjonsdelen
(lengde/areal/effekt per rom) er urørt. Verifisert: eksport fullfører uten feil på ekte prosjekt.

**Fil:** romtegner.html (`exportPDF` — materialliste-seksjonen).

---

## Trapp: tre fikser (fjern/legg til kabel, riktig antall strenger, side-visning) — 2026-06-25

1. **Fjern/legg til varmekabel** (`67e16b6`+`1057df0` er 2/3; denne er 1+2): ny «Fjern varmekabel»-
   knapp i trappens innstillings-panel (`_stairRemoveCable`) — tømmer kabelen (løp/produkt) men
   beholder geometrien (`stair.noCable`-flagg; `generateStairCable` returnerer tomme løp). «Legg til
   varmekabel» (`_stairAddCable`) regenererer og åpner forslag. Å velge kabel/forslag fjerner flagget.
2. **Valgt forslag → riktig antall strenger:** `_applyStairProposal` lagret bare avrundet `stepCC`;
   `generateStairCable` re-utledet `N=floor(usableDepth/cc)+1`, og opprundet CC kunne senke N med 1
   (forslag «4 strenger» ble bygd som 3). Lagrer nå `runsPerStep` og bruker den direkte for trinn
   (+ epsilon-guard). Verifisert: `runsPerStep=4` → 4 strenger (var 3).
3. **Side-visning opp-ned:** forrige buildDirection-fiks speilet side-profilen vertikalt (FY), som
   snudde trappa opp-ned. Reverterte FY i `_drawStairSide` → normal trinn-opp-profil. Byggeretning
   styrer fortsatt plan-visningen via `y_cm`. Verifisert på canvas.

**Filer:** romtegner.html (`_drawStairSide`, `generateStairCable`, `_applyStairProposal`,
`_stairRemoveCable`/`_stairAddCable`, `_renderStairSettingsPanel`, `_setStairCableProduct`).

---

## Ny modul: Snøsmelting – effektbehov — 2026-06-25

Leverandørnøytral effektbehov-kalkulator for snøsmelting; produktene kommer fra valgt leverandørs
katalog. Kilde: research-doc (ASHRAE/IEC 62395-2/HT2000) + verifisert mockup. Ingen merkenavn (DEVI/
Danfoss) i UI.

### Del A — Overflatelast (værstyrt, leverandørnøytral) ✅
- `SNOW_IEC` (værhardhet × kritikalitet → W/m²-intervall), `_snowMidLoad` (midt, rundet til 25),
  `_snowSurfaceLoad` (+100 W/m² per korreksjon: >1000 moh / vind >6 m/s / snø < −10 °C; gulv 250),
  `_snowMinAir` (α=23: «holder +Ts ned til X °C luft»).
- Verifisert: **streng/moderat → 350 W/m²**, **minAir(3, 350) → −12 °C**, floor 250, korreksjoner +100.

### Del B — Lagmodell (gulvoppbygging, R = tykkelse/λ) ✅
- `SNOW_MATERIALS` (11 materialer m/λ), `SNOW_DEFAULT_LAYERS`, `_snowLayerR`/`_snowRsum`,
  `_snowGroundModel` (kabeltemp = Ts + last×R_opp; bakketap = (T_kabel−bakke)/R_ned; installert =
  last + bakketap; responstid ∝ R_opp). Dekketykkelse/-materiale endrer kabeltemp/bakketap/respons —
  ikke overflatelasten.
- Verifisert: **R_opp = 0,050** (40 mm asfalt), **R_ned = 1,4921 ≈ 1,493** (standardlag), respons
  4cm→1×/8cm→2×. HT2000-case (q0=262): 269 (4cm)/278 (8cm) — eksakt som den verifiserte mockupen;
  ~2 % under HT2000s 273/285 (iboende i enkel R-modell vs full ASHRAE; eksakte ankre stemmer).

### Del C — UI + produkt fra leverandørens katalog ✅
- Hub-kort «Snøsmelting – effektbehov» (datadrevet i `MODULE_TYPES`, `_quickStartModule` ruter til
  `_openSnowCalc`). Modal i Varmeplan-stil (mockup-flyten): værforhold + lagbygger (over/under, R per
  lag) + produkt-chips + resultat (overflatelast, holder-ned-til-X°C, kabeltemp, bakketap, installert,
  C-C, total, responstid + advarsler).
- **`_snowCatalogProducts()`**: resolver snøkabel/matte-familier fra `HEATING_PRODUCTS` (leverandør-
  filtrert via `_filterProductsByOrg`; 230/400 V slått sammen). Ingen hardkoding/merkenavn — en annen
  leverandør viser sine egne snøprodukter automatisk. Kabel → C-C = W/m ÷ installert × 100; matte →
  sjekk W/m² ≥ installert (grønn/rød + advarsel). Ekte art./EL fra katalogen i produktkortet.
- «Lagre i prosjekt» lagrer snapshot (`S.project.snowcalc` + snowcalc-part) med valgt produkt
  (type/spenning/CVA/EL/C-C) for dokumentasjon.
- Verifisert: default InSnow 30T → 350 W/m², C-C 8,3 cm, CVA10300/EL 1005753; 400 V → CVA10700/EL
  1020483; matte 360>300 → rød + advarsel; lagring skaper prosjekt + part. Ingen DEVI/Danfoss.

### Del D — Værdata pr postnummer (auto-fyll) ✅
- **`supabase-migration-weather-postcode.sql`** (datakontrakt, kjøres manuelt): tabell
  `weather_by_postcode(postcode pk, place, municipality, design_temp_c, design_wind_ms,
  snowfall_cm_h, altitude_m, source, updated_at)`. RLS: les for innloggede, skriv kun superadmin.
  Inkluderer import-mal for 40-årsarket.
- `_snowLookupPostcode()` + `_snowDeriveFromWeather()`: postnr → auto-fyll værhardhet
  (temp ≥ −15 mild / −25…−15 streng / ≤ −25 svært) + korreksjoner (moh>1000, vind>6, temp<−10),
  overstyrbart. Tom tabell / før migrasjon → degraderer pent til «fyll inn manuelt».
- Verifisert: utledning (−28→svært+alle, −18→streng+snø, −8→mild); graceful fallback uten tabell.
- **Værdata importert:** `supabase-import-weather-postcode.sql` (generert fra Postnummerregister-
  Excel) — **5136 postnr** med dimensjonerende utetemp (Auslegungsaußentemperatur, −43,9…−7,0 °C),
  høyde over havet, poststed/kommune. Idempotent upsert, 11 batcher. Kjøres som superadmin etter
  migrasjonen. (Vind/snøfall finnes ikke i datasettet → null; korreksjon utledes fra temp/høyde.)

**Filer:** romtegner.html (`SNOW_*`/`_snow*`, `_openSnowCalc`/`_snowCalc`, `_snowCatalogProducts`,
`MODULE_TYPES`/`_MOD_ICON`), [supabase-migration-weather-postcode.sql](../supabase-migration-weather-postcode.sql).

Ny forsidekort-modul (datadrevet, samme mønster som de andre). Kilde: Cenika varmekatalog
(varmetap W/m) + verifisert mockup-flyt.

### Del A — Varmetap-tabell + beregningskjerne ✅
- `FROST_WM` (8 iso × 5 ΔT × 18 diametre), `FROST_DIAM`/`FROST_ISO`/`FROST_DT`, `_frostNearestDt`
  (runder ΔT til 20/30/40/60/80), `_frostLookupWpm(diamIdx, iso, dt)`, og `_frostSuggestCable`
  (≤10→MultiPipe 10; ≤20→IceFix 20W; >20→flagg; Ready-lengde nærmest ≥ rørlengde, ellers metervare).
- Verifisert: **fasit 2″/30mm/ΔT20 → 7 W/m**, flere oppslag, ΔT-runding (+5/−15→20), og alle
  kabelvalg-grenser (10/20). Alle rader = 18 verdier.
- ⚠️ **To celler kunne ikke verifiseres mot trykt katalog** (dimensjonerings-tabellen finnes IKKE i
  den offentlige 2024-katalog-PDF-en — bekreftet via full PDF-gjennomgang). Encodet EKSAKT som
  kildedataene, men begge bryter monotonitet (sannsynlige kopifeil) og er flagget i koden:
  ISO50/ΔT40/20″=66 og ISO100/ΔT60/1½″=8.0 — **bør bekreftes mot trykt katalog**.

### Del B — Modulkort i hub + beregnings-UI ✅
- `frost` lagt i `MODULE_TYPES` (+ `_MOD_ICON.frost='droplet'`, nytt droplet-ikon, `PROJECT_TYPE_MAP`).
  Kortet vises i hub-en; `_quickStartModule` ruter `frost` → `_openFrostModule()` (kalkulator, ikke canvas).
- `_openFrostModule()` + `_frostCalc()`: modal i Varmeplan-stil (mockup-flyten) — diameter/iso/temp/
  lengde → live ΔT + W/m + totaleffekt + fargekodet kabelforslag (MultiPipe 10 / IceFix 20W / >20-flagg).
- Verifisert live: kort i hub, default 2″/30/ΔT20/30m → 7 W/m · 210 W · MultiPipe 10 (Ready 30 m);
  1¼″/20/ΔT40 → 14,4 → IceFix. Skjermbilde matcher mockupen.

### Del C — Produktkatalog (CVA/EL fra cenika.no) ✅
- `_ensureFrostProtectionProducts()` (samme injeksjon-mønster som InSnow) legger 54 produkter i
  `HEATING_PRODUCTS` + kategori «Frostsikring rør»: MultiPipe 10 Ready (26, 2–60 m) + metervare
  CVA10220, IceFix 20W Ready (26, 2–52 m) + metervare CVA10210.
- CVA + EL **skrapet og kryssverifisert** mot cenika.no (4 subagenter + uavhengig sjekk via
  Cenikas søk-API: CVA10236→1021259, CVA10264→1010967, CVA10210→1003606 — alle matchet).
- ⚠️ **MultiPipe 10 metervare CVA10220 er utgått og har ingen publisert EL-nr** → `el_no=null`
  (flagget i koden). Alle andre 53 har EL.

### Del D — Ekte CVA/EL i forslaget + lagre på prosjekt ✅
- `_frostResolveProduct(family, lengthM)`: minste Ready-lengde ≥ rørlengde fra katalogen, ellers
  metervare. Forslaget viser nå **ekte CVA + EL** (f.eks. 2″/30/ΔT20/30m → MultiPipe 10 Ready 30 m
  → CVA10246 · EL 1021269; IceFix-tilfelle → CVA10274 · EL 1010977).
- «Lagre i prosjekt»-footer: `_frostSaveToProject()` oppretter et prosjekt (type `frost`) med en
  frost-part + `S.project.frost`-snapshot `{inputs, wpm, totalW, product:{type,CVA,EL,lengde,navn}}`
  — persistert i prosjekt-JSON, klart for dokumentasjon/garantibevis.
- Verifisert live: ekte CVA/EL i begge kabeltyper; lagring skaper prosjekt med produkt-snapshot
  (CVA10246/EL 1021269) + frost-part. Test-data ryddet.

**Filer:** romtegner.html (`FROST_WM`/`_frost*`, `_openFrostModule`/`_frostCalc`,
`_ensureFrostProtectionProducts`, `MODULE_TYPES`/`_MOD_ICON`/`PROJECT_TYPE_MAP`).

---

## Kontaktpersoner: tittel-felt, tabell på kundekort, søkbare i Kunder — 2026-06-25

Bygger på `contacts`-tabellen.

### Del A — Tittel-felt ✅
- **`supabase-migration-contact-title.sql`** (kjørt): `alter table contacts add column if not
  exists title text`. RLS uendret. Add/edit-skjemaene på kortet tar nå navn (påkrevd) + tittel,
  telefon, e-post (valgfrie); `title` skrives i `_cardCreateContact`/`_cardSaveContact`.

### Del B — Kontaktpersoner som tabell på kundekortet ✅
- `_renderCardContacts` rendrer nå en **tabell**: Navn · Tittel · Telefon · E-post · (handling).
  Inline «＋ Legg til kontaktperson» (ny rad i tabellen), rediger/fjern per rad. Telefon er
  `tel:`-lenke, e-post `mailto:`-lenke (teal). Tom tilstand: «Ingen kontaktpersoner ennå».
  Felles `_ccEditCells` for ny/rediger-rad.

### Del C — Søk i kontaktpersoner (Kunder-fanen) ✅
- `_loadAllContacts()` laster alle org-kontakter én gang (RLS-scopet) inn i `_contactsCache` —
  samme kilde som kortet; ingen rundtur per tastetrykk (mutasjoner holder cachen oppdatert).
- `_renderCustomerTable`-søket matcher nå OGSÅ kontaktenes navn/tittel/telefon/e-post (i tillegg
  til dagens kundefelt). Kunde-raden viser «Treff: <navn> – <tittel>» når treffet kom via en kontakt.
- Verifisert: kort med 3 kontakter (tittel/tlf/e-post) i tabell, rediger/fjern + tel/mailto;
  søk på kontaktnavn/tittel/telefon/e-post → riktig kunde + treff-markering; RLS kun egen org.

**Filer:** [supabase-migration-contact-title.sql](../supabase-migration-contact-title.sql),
romtegner.html (`_renderCardContacts`/`_cardContactRowHtml`/`_ccEditCells`/`_card*Contact`,
`_loadAllContacts`, `_renderCustomerTable`).

---

## Trapp: «Byggeretning» styrer nå faktisk geometri/kabel/preview — 2026-06-25

**Bug:** «Byggeretning» (Nedenfra og opp / Ovenfra og ned) ga feil resultat — `buildDirection`
ble kun brukt til å reversere segment-LISTA i modalen ([23532]), ikke i geometrien, kabelen
eller forhåndsvisningen. Reprodusert: `_generateStairSurfaces` ga identiske flater for begge
retninger; `w2s` plasserte `segs[0]` (nederste) øverst → «nedenfra og opp» bygde motsatt.

**Fiks (alt i sync med etiketten):**
- `_generateStairSurfaces`: `surfaces` beholder `segs[0]`-først rekkefølge (kabelstart = trinn 1
  = nederst), men **y_cm speiles** etter retning — «bottom» legger `segs[0]` nederst (størst
  y_cm), «top» øverst. Trinn nummereres fra `segs[0]`.
- `_drawStairSide`: vertikal speiling (`FY`) for «bottom» → profilen stiger oppover (var
  synkende); kabel + risers følger med.
- `_stairBuilderPreviewSVG`: tegner i retnings-bevisst rekkefølge så preview matcher canvas.
- Plan, side, kabel, preview og liste er nå konsistente. Kabel-/effektberegning per trinn
  uendret (sum er rekkefølge-uavhengig).

**Testet (canvas + data):** trapp 3 trinn + repos + 2 trinn. «Nedenfra og opp» → trinn 1 og
kabelstart nederst, side-profil stiger; «Ovenfra og ned» → speilvendt (trinn 1 + grønn
kabelstart øverst). Kabel-total 3951 cm i begge (ingen regresjon). Verifisert med skjermbilde.

**Merk:** eksisterende lagrede trapper oppdateres ved neste regenerering/redigering (lagret
`surfaces` brukes til da).

**Filer:** romtegner.html (`_generateStairSurfaces`, `_drawStairSide`, `_stairBuilderPreviewSVG`).

---

## Kundekort → fullt CRM-kort (kontakter + prosjekter) — 2026-06-25

Utvidet `_openCustomerCard` til et CRM-kort. Bygger på `contacts`-tabellen fra
opprett-firma/kontakt-arbeidet (allerede migrert — ingen ny migrasjon).

### Del A — Kontaktpersoner i listevisning ✅
- Erstattet det enkle `cc-contact`-feltet med en **Kontaktpersoner**-seksjon: liste over alle
  `contacts` for kunden (navn + telefon·e-post), hver rad med **rediger (✎)** og **fjern (✕)**.
  «＋ Legg til kontaktperson» → inline rad (navn påkrevd, telefon/e-post valgfritt).
- Funksjoner `_renderCardContacts`/`_cardContactRowHtml`/`_cardShowAddContact`/
  `_cardCreateContact`/`_cardStartEditContact`/`_cardSaveContact`/`_cardDeleteContact` — deler
  `contacts`-tabellen og `_contactsCache` med opprett-prosjekt-comboboxen (begge veier).
- Lazy-backfill: hvis kunden har gammel `contact_person` men ingen kontakter, migreres den inn
  som én kontakt ved åpning. `_saveCustomerCard` skriver ikke lenger `contact_person` (bevares).
- Verifisert live: la til 3 kontakter, rediger + fjern persisterer i DB; opprett-comboboxen
  (`_loadContacts`) ser samme kontakter. Test-data ryddet.

### Del B — Prosjekter i listevisning + søk/filter ✅
- Refaktor for ekte gjenbruk: heiset `_effDate` → modul-nivå `_projectEffDate`, og trakk ut
  `_filterProjectsList(projects, {search,customer,status,type})` med dashboardets eksakte
  filter-/sorteringslogikk. **Dashboardet (`_renderProjectList`) og kundekortet bruker samme
  funksjon** — ingen parallell.
- `_renderCustomerCardProjects(customerId)`: bruker dashboardets `_cachedProjects` scopet til
  `_customerId === c.id`, oppsummering («N prosjekter · M ferdige»), søk + status- + type-filter,
  og kompakt liste (navn, type-ikon, status-badge, dato) via `_cardProjectRowHtml`. Klikk åpner
  prosjektet og lukker kortet.
- Verifisert: dashboard uten regresjon (33 rader; status=ferdig → 32); kort viser «· 3 prosjekter
  · 3 ferdige», søk «Espe»→1, type indoor→3, klikk åpner.

### Del C — delt contacts-kilde ✅ (verifisert i Del A)

**Filer:** romtegner.html (`_openCustomerCard`, `_renderCardContacts` m.fl.,
`_renderCustomerCardProjects`/`_cardProjectRowHtml`, `_projectEffDate`/`_filterProjectsList`,
`_renderProjectList`).

Bygget om det inline opprett-skjemaet til et proft, luftig kort som matcher mockupen
`mockups/Varmeplan-opprett-prosjekt-redesign.html`. Kun markup + CSS; all opprett-logikk
(`_toggleCreateProject`, `_createProjectInline`, `_searchCustomers`/`_acNav`/`_searchContacts`)
og alle felt-ID-er uendret.

### Del A — Layout ✅
- Nytt `.npc-card` inni `#dash-create-form`: header (folder-plus i teal-chip + «Nytt prosjekt»
  + undertittel), `.npc-grid` 3 kolonner, etiketter over hvert felt, 46px-felt med teal
  fokus-ring (`color-mix` mot `--accent`), footer med delelinje + «✓ Opprett prosjekt» (primær)
  + «Avbryt» + tastatur-tips. Rad 1: Prosjektnavn\*·Kunde/firma·Kontaktperson; rad 2:
  Adresse·Type·Ansvarlig.
- **Fjernet den overlappende `＋`-knappen** ved Kunde (opprett-nytt-firma ligger nederst i lista).
- Kontaktfeltet ligger fast i rutenettet men er `disabled` til firma er valgt («Vises etter
  firma…») — `_onCustomerChosen` byt/disabler i stedet for å skjule (stabil 3+3).
- Toggle-knappen («＋ Opprett prosjekt») skjules mens kortet er åpent; Avbryt/Opprett viser den.
- Søk/filtre flyttet til egen linje under kortet med topp-delelinje. Dropdown (`.cust-search-results`)
  luftet opp (radius 12, skygge, avrundede rader). Bruker appens light-theme-tokens → matcher
  mockupens palett; degraderer pent i dark-theme.
- Verifisert live (light-theme, 1120px): 3×grid, 46px-felt, ＋-borte, kontakt disabled, toggle
  skjult ved åpning, combobokser virker. Skjermbilde matcher mockupen.

### Del B — Kunde-combobox ✅
Funksjonelt bygget forrige økt (`_searchCustomers` + `_inlineCreateCustomer`). Her: add-radens
ordlyd justert til mockupens «＋ Legg til «<navn>» som nytt firma». Verifisert i nytt oppsett.

### Del C — Kontaktperson ✅
`contacts`-tabell + `_searchContacts`/`_inlineCreateContact` bygget forrige økt (migrasjon
allerede kjørt). Her: feltet aktiveres etter firmavalg (Del A `_onCustomerChosen`). Aldri fast
kontakt; `contact_id` + navn-snapshot lagres på prosjektet.

**Verifisert (full tastatur-E2E i nytt oppsett):** prosjektnavn → nytt firma (Enter på add-rad)
→ kontakt aktivert → ny kontakt (Enter) → Opprett. Prosjekt lagret med riktig kontakt; toggle
gjenopprettet; RLS kun egen org. Test-data ryddet.

---

## Raskere «Opprett prosjekt» — firma + kontakt inline (2026-06-25)

Mål: velg/opprett firma og kontaktperson uten å forlate opprett-prosjekt-flyten.
Bygger på eksisterende `_searchCustomers`/`_selectCustomer`/`_acNav`/`_createProjectInline`.

### Del A — Firma: velg eller opprett inline ✅
- `_searchCustomers`: viser nå alltid en inline **«＋ Legg til «<det du skrev>»»**-rad i
  dropdownen (`data-ac` → pil/Enter via `_acNav` og museklikk funker likt). Skjules kun ved
  eksakt navnetreff.
- Ny **`_inlineCreateCustomer()`**: oppretter kunde (org-scopet, kun navn) der og da uten
  dialog/avbrudd, og velger den. Leser navnet fra søkefeltet (unngår escaping i onclick).
  `＋`-knappen → full `_showNewCustomerPopup` beholdt som «avansert».
- Verifisert live (ksk@cenika.no): tastatur Enter oppretter+velger; museklikk likeså;
  eksisterende kunde velges fortsatt; «+ Legg til» skjult ved eksakt treff. Test-rad ryddet.

### Del B — Kontaktperson: mange per firma ✅
- **Migrasjon `supabase-migration-contacts.sql`** (kjørt, verifisert 6/6/2/1): tabell
  `contacts(id, customer_id FK customers ON DELETE CASCADE, name not null, email, phone,
  created_at)`. RLS org-scopet *gjennom* customer via `user_org_ids()` + superadmin.
  `romtegner_projects.contact_id`-kolonne lagt til. Backfill: eksisterende
  `customers.contact_person` → én kontakt per kunde (idempotent). `contact_person` beholdt.
- **UI:** nytt `#dash-proj-contact`-combobox som vises **etter** valgt firma
  (`_onCustomerChosen` avslører + forhåndslaster). Ved fokus vises HELE firmaets kontaktliste
  umiddelbart (`_searchContacts(q, showAll)`); skriv for å filtrere; `_acNav` gjenbrukt
  (pil/Enter/klikk). `+ Legg til ny kontaktperson «<navn>»` → `_inlineCreateContact` (org-scopet
  via customer). Ingen fast standardkontakt — valget gjelder prosjektet.
- **Persistering:** `S.project.contact_id` + `contact_name` (snapshot) i prosjekt-JSON (lest av
  `_createProjectInline`, lagret via eksisterende save-sti — urørt). Kontaktnavn vises i
  prosjektlista (under Kunde, `_fetchProjectList._contact`) og i dokumentasjons-headeren
  (`_docFetchProjectData._contact` → `_docState.contactName`).
- Verifisert live (ksk@cenika.no): fokus viser hele lista; nytt firma + ny kontakt + prosjekt
  via **kun tastatur** på sekunder; prosjekt lagret med riktig kontakt; RLS: kun egen orgs
  kontakter synlige (6). Test-data ryddet.

**Filer:** [supabase-migration-contacts.sql](../supabase-migration-contacts.sql), romtegner.html
(`_searchContacts`/`_selectContact`/`_inlineCreateContact`/`_onCustomerChosen`/`_loadContacts`,
+ `_createProjectInline`/`_fetchProjectList`/prosjektrad/doc-prefill).

---

## EL-nummer for InSnow utendørs-kabler (20T/30T/40T) — 2026-06-24

**Mål:** Fylle inn EL-nummer (`el_no`) på alle InSnow-kabelprodukter. 85 av 104 manglet
(kun InSnow 30T 230V hadde fra før).

**Kilde + validering:** Bruker leverte Cenika-prisliste (`Bok1.xlsx`, 85 par CVA↔EL).
Kryssvalidert mot skraping av cenika.no (5 parallelle subagenter, ett produkt-oppslag per
artikkel): **100 % match, 0 avvik på 85**. Krysset mot DB: alle 85 `article_no` fantes,
ingen hadde `el_no` fra før.

**Gjort:**
- **`supabase-migration-insnow-elno.sql`** (kjørt i Supabase, verifisert 85/85/0): 85
  idempotente `update … where … and el_no is distinct from …`. DB bekreftet: 104/104
  InSnow-kabelrader har nå `el_no` (stikkprøver CVA10340=1004181, CVA10713=1020496,
  CVA10756=1042662).
- **`romtegner.html` `_ensureOutdoorCableProducts`:** rettet latent feil — `add()` tok imot
  `elNo` men lagret det aldri (`el_no: elNo` lagt til på produktobjektet), og fylte inn alle
  85 EL-numre i `add()`-kallene. Klient-fallbacken (kun aktiv hvis produktene mangler i DB)
  er nå komplett. App lastet uten feil (245 produkter).

| Serie | Artikler | EL-blokk |
|---|---|---|
| InSnow 20T 230V | CVA10340–10356 | 1004181–1004197 |
| InSnow 20T 400V | CVA10361–10377 | 1017939–1017955 |
| InSnow 30T 400V | CVA10700–10716 | 1020483–1020499 |
| InSnow 40T 230V | CVA10720–10736 | 1032638–1032654 |
| InSnow 40T 400V | CVA10740–10756 | 1042646–1042662 |

**Filer:** [supabase-migration-insnow-elno.sql](../supabase-migration-insnow-elno.sql), romtegner.html (`_ensureOutdoorCableProducts`).

---

## Medlemssynlighet: alle i egen org (RLS + embed-fiks) — 2026-06-24

**Problem:** En ikke-superadmin (ksk@cenika.no, admin i Cenika AS) så bare seg selv i
firma-panelets medlemsliste, ikke Fredrik.

**To rotårsaker (begge bekreftet):**
1. **RLS for snever.** `organization_members` SELECT = `using (user_id = auth.uid())` (kun
   egen rad) og `profiles` SELECT = kun egen profil. Superadmin så alt via `is_superadmin()`.
2. **Ødelagt PostgREST-embed.** `organization_members.user_id` har FK til `auth.users`
   (ikke `profiles`), så appens `select('... profiles(...)')` feilet med «Could not find a
   relationship … in the schema cache» → panelet viste «Ingen medlemmer» uansett RLS.

**Fiks:**
- **`supabase-migration-org-member-visibility.sql`** (kjørt i Supabase, verifisert 1/0/1/1):
  - `user_org_ids()` — SECURITY DEFINER, stable, `search_path=public` (bypasser RLS →
    ingen rekursjon/42P17 når brukt i policy PÅ `organization_members`).
  - `organization_members` SELECT → `using (org_id in (select user_org_ids()))`.
  - `profiles` SELECT → additiv policy: profiler til medlemmer i mine orgs. «Egen profil»
    + superadmin beholdt. Skrive-policyer urørt.
- **`romtegner.html` `_orgAdmRefresh`:** byttet ut den ødelagte embed-joinen med to separate
  spørringer (medlemmer + profiler) joinet i JS — samme mønster som superadmin-panelet i
  `admin.html`. Render-form `{user_id, role, profiles}` uendret.

**Verifisert live (innlogget ksk@cenika.no):** firma-panelet → **Medlemmer (2)**: Kenneth
(ksk@cenika.no, Administrator) + Fredrik (fki@cenika.no, Administrator), med navn/e-post/rolle.
RLS-spørringer isolert: `organization_members` gir begge rader, `profiles` gir begge med
e-post. Ingen tverr-org-lekkasje (policy begrenser til `user_org_ids()`). Superadmin uendret.

**Filer:** [supabase-migration-org-member-visibility.sql](../supabase-migration-org-member-visibility.sql), romtegner.html (`_orgAdmRefresh`).

---

## 🚧 PÅGÅR — 4A: Eier-styrt leverandørtilgang per bedrift (RLS) — `4f3c17a`

**Status (pause 2026-06-22):** Migrasjonen er skrevet, committet OG kjørt i Supabase av
bruker. Admin-UI (Del 3) gjenstår.

**Gjort:**
- `supabase-migration-org-supplier-access.sql` (committet `4f3c17a`) — **kjørt i Supabase**:
  tabell `organization_supplier_access` + RLS (superadmin skriver, medlemmer leser egne),
  seed av eksisterende installatør-orgs, og ny produkt-policy «Produkttilgang via
  leverandor-grant» som erstatter «installatør ser alt». Verifisert: ny policy aktiv (1),
  gammel borte (0), suppliers=1 (Cenika), **installer_orgs=0, grants_seeded=0**.
- Bruker satte **kenneth.skretteberg@gmail.com = superadmin** (app_metadata) og logget inn på nytt.

**Faktisk tilstand i DB nå (viktig kontekst):**
- `kenneth.skretteberg@gmail.com`: **superadmin, tilhører INGEN firma** (ser alt via god-mode).
- `ksk@cenika.no`: **admin i «Cenika AS»** (eneste org, type=supplier). Ser 213 Cenika-produkter.
- Ingen installatør-orgs finnes → enhver ikke-superadmin/ikke-Cenika-bruker ser **0 produkter**.
- «Delte prosjekter» mellom gmail og ksk skyldtes superadmin-innsyn, ikke samme firma.

**Gjenstår (neste økt):**
1. **Avklar med bruker:** A) gmail forblir ren superadmin uten firma, eller B) opprett
   «Varmeplan» (installatør-org), meld gmail inn, og test installatør-flyten. (B anbefalt.)
2. **Del 3 — Admin-UI (`admin.html`):** per installatør-bedrift en «Leverandør-tilgang»-liste
   (alle `suppliers`) med av/på = innvilg/trekk tilbake → `organization_supplier_access`.
   Speil mønsteret fra `toggleProductAccess` (~admin.html:700) / org-detalj-kortet (~588).
   Ny `toggleSupplierAccess(orgId, supplierId, checked)` + last-funksjon.
3. **Test med tre kontotyper:** installatør (kun innvilgede), leverandør (kun egne), superadmin (alt).

**Filer:** [supabase-migration-org-supplier-access.sql](supabase-migration-org-supplier-access.sql),
admin.html (Del 3 kommer).

---

## 📌 STATUS pr 2026-06-22 — Folie auto-utlegg (gjenoppta-notat)

**Hvor vi står:** Folie-auto-utlegget er omarbeidet til montør-stil og verifisert mot
brukers eksakte 53 m²-rom (geometri hentet via konsoll; reprodusert lokalt innlogget).

- **Automatisk-panelet:** to valg — **Horisontal / Vertikal**. Begge bruker sone-teknikken
  for ikke-rektangulære rom (rektangler beholder dagens H/V). Bruker velger retning selv.
- **Pr sone:** full-lengde, vegg-forankrede kolonner; smal strimmel (B=20) absorberer
  forskyvninger/notch (montørens triks) → resten fulle. Ingen smale folier midt i arealet.
- **Brukers rom:** Vertikal **91 %**, Horisontal **94 %**, **0 regelbrudd**. Aldri folie i
  hindring; gap-/vegg-/overlapp-brudd = 0. Regresjon: rektangel 94 %, L 91 %, U 83 %.
- **Sentrale funksjoner:** `_decomposeRoomToRects` (rutenett + maks-rektangel),
  `_packZoneFullLength` (full-lengde + absorber), `_zonedDefsForDirection` (pr retning),
  `showAutoFillComparison` (H/V bruker sone-teknikk), `_layoutRulePenalty` (scoring-straff),
  `getStripViolations` (along-akse-vakt → ingen falske ⚠).

**✅ GODKJENT av bruker (2026-06-22):** visuelt bekreftet i appen — fulle B=140-kolonner +
smale B=20-absorbere ved forskyvninger, matcher montørens manuelle utlegg (`folie_optimalt`).

Evt. senere finjustering (ikke påkrevd): absorber-logikken i `_packZoneFullLength`
(targetLen-toleranse / plassering) hvis enkelte soner i andre rom får en uønsket kort strimmel.

**Alt committet og pushet til `origin/main`** (siste: `1b696e7`).

---

## 2026-06-22 — Folie: montørens full-lengde + smal absorber-pakking — `1b696e7`

Brukers manuelle teknikk: smal strimmel der en forskyvning er, så fulle lengder etter.
Ny `_packZoneFullLength` pr sone: bredeste produkt som gir FULL lengde forankret til vegg;
der ingen bredde blir full (forskyvning), legg smaleste som absorberer, fortsett med fulle.
Verifisert på brukers rom: nedre-høyre = B=20 absorber + 2× B=140 full lengde (var 1 kort
B=100). V 91 % (var 84 %), H 94 %, 0 regelbrudd. Regresjon: rektangel 94 %, L 91 %, U 83 %.

---

## 2026-06-22 — Folie: montør-stil utlegg, bruker velger retning — `b1e9596`, `b36cbc6`

Etter brukers referanse (folie_optimalt) + ønske om å velge retning selv:
- **Én retning i hele rommet** + **uniform bredde forankret inntil vegg** pr sone (ingen
  smale folier midt i arealet; det udekkede mot vegg). `_packZoneUniform` + «lange strimler»-
  scoring (få, brede, lange kolonner).
- **Horisontal og Vertikal i Automatisk-panelet bruker nå sone-teknikken** (`_zonedDefsForDirection`)
  for ikke-rektangulære rom → bruker velger retning selv. Separat «Soner»-kort fjernet. Enkle
  rom (≤1 sone) beholder dagens H/V (ingen regresjon).
- Klamp sone-rektangler til rommets bbox (siste grid-celle stakk forbi vegg → 15 mm-brudd).
- Falske gap-⚠ fjernet tidligere (along-akse-vakt i `getStripViolations`).
- Verifisert på brukers rom: Vertikal 84 % / Horisontal 85 %, begge én retning, 0 regelbrudd,
  få brede strimler forankret til vegg.

---

## 2026-06-22 — Folie «Soner»: rutenett-dekomponering (fikser dårlig dekning) — `a2ee334`

Brukerrapport: «Soner» ga store udekkede arealer på et ekte 53 m²-rom (stua <50 %).
Reprodusert med brukers EKSAKTE romgeometri (hentet via konsoll): slabb-dekomponeringen
la soner oppå hindringer og trimmet stua til en tynn kolonne.

- Ny `_decomposeRoomToRects`: rasteriser rom-interiør MINUS hindringer/forbudte soner i
  et rutenett (~6–12 cm), og hent grådig ut største all-fyllbare rektangel (`_largestRectInGrid`,
  histogram-metode), gjenta. Hindringer = naturlige hull; 25 mm-margin håndteres ved pakking.
- Verifisert på brukers rom: stua fanges som ekte 324×333-sone; Soner-dekning 95 % (var 80 %;
  H/V 52/46 %), 0 folie i hindring, 0 overlapp. Regresjon: rektangel → fallback; L 91 %, U 90 %.

**Oppfølging — falske ⚠ + vegg-margin** (`d733cf1`, `b4ab12e`)
- `getStripViolations` sin gap-sjekk manglet along-akse-vakten → strimler ende-til-ende i ulike
  soner ble feilflagget. Lagt til vakt → ekte overlapp=0 gir 0 gap-⚠. Maks dekning: 91 % helt rent.
- `_computeRectFillDefs` klippet mot sone-rektangelet (kan stikke litt utenfor rommet i grid-
  oppløsning) → 3 vegg-brudd i stua. Nå klippes mot ROMMET (riktig 25 mm margin) + begrenses til
  sonens along-rekkevidde. Soner på brukers rom: **94 % med 0 regelbrudd** (vegg/hindring/gap/overlapp).

---

## 2026-06-22 — Folie: aldri folie i hindring + scoring-straff (Del A/B/C)

Tre gjenstående folie-punkter, reprodusert empirisk FØRST (innlogget, ekte produkter).
Commits (nyeste først): `e701dce`, `2da21be`.

**Del A — aldri folie i hindring** (`2da21be`)
- Rotårsak: `_centerStripDefs` forskyver alle strimler perp (sentrering/skyv-mot-vegg)
  men re-klipper ikke lengden → en strimmel som var hindring-fri i sin kolonne havner
  over en hindring og beholder full lengde → folie i hindring (H/V «lange strimler»).
- Fiks: `_reclipDefsAroundObstacles` re-klipper hver def mot hindringer/forbudte soner
  ved sin (forskjøvne) pos og deler/forkorter. Brukt etter sentrering i begge strategier.
  No-op uten hindringer → ingen regresjon. Verifisert: 2 hindringer → 0 folie i hindring.

**Del C — straff regelbrudd + oppstykking i scoringen** (`e701dce`)
- `_layoutRulePenalty` trekkes fra `_foilLayoutStats.score`: folie i hindring ~1× romareal
  (dominerer), <25 mm 0,15×, svært korte strimler oppstykkingsstraff. → «Soner» blir kun
  ★ når den faktisk er bedre enn H/V. Rene layouts: straff 0 (uendret rangering).

**Del B — stable folie i samme kolonne manuelt** — ingen endring (allerede løst)
- Reprodusert grundig ('v'+'h', under/over, ulik bredde, full kolonne, 2–3 stablet):
  alle plasseres korrekt. `_withFoilAvoid`+`computeClippedSegments` deler faktisk kolonnen
  rundt eksisterende folie; along-vakten i `_stripOverlapsAny` gjør stabling lovlig. Prompten
  sin antatte rotårsak stemmer ikke. (Hard-refresh hvis det fortsatt feiler — send ev. repro.)

---

## 2026-06-22 — Folie: sone-basert utlegg + hindring-varsel (verifiser-først)

Fire sammenhengende folie-problemer (sone-utlegg, hindring-eksklusjon, uavhengige
arealer). Diagnostisert empirisk i koden FØRST (innlogget, ekte produkter). Commits
(nyeste først): `bab96f6`, `07866c5`, `f80a5c8`, `a591539`, `49c5e41`.

**Verifisering (read-only) viste at 4/3/2 alt var helt/delvis løst siden prompten:**
- **Problem 4 (uavhengige arealer)** — allerede løst: `_stripOverlapsAny`/`_clampStripToRoom`
  er 2D-lokale (along-akse-vakt), og auto-folie-unngåelse trekker fra hver folie som
  rektangel. Bekreftet med repro. Ingen endring.
- **Problem 2 (auto rundt hindring)** — fungerer: `computeClippedSegments` klipper
  strimler m/ margin rundt hindringer. Bekreftet. Ingen endring.

**Problem 3 — varsle folie oppå/under hindring** (`49c5e41`)
- `getStripViolations` sjekket bare avstand-til-kant, så en strimmel som overlappet
  (delvis/helt inne i) en hindring ble aldri flagget. Ny `_rectIntersectsPoly` (rect ∩
  polygon) → overlapp ⇒ avstand 0 ⇒ brudd. Samme varselmekanisme (modal + sidepanel),
  ved drag og plassering. Ingen falsk positiv når strimmelen er klar av hindringen.

**Problem 1 — sone-basert auto-utlegg** (`a591539`)
- `_decomposeRoomToRects`: ortogonalt rom → akse-justerte rektangler. `_packRectBestDir`:
  pakk hver sone uavhengig (clipPoly), velg retning (v/h) etter best dekning.
  `autoAddStripsZoned` (auto-knappen peker hit) bruker `_withFoilAvoid` så soner aldri
  overlapper; hindringer rutes rundt. Fallback til `autoAddStrips` for enkle/ikke-ortogonale
  rom (ingen regresjon). Låste regler består.
- Verifisert: L-form → 2 soner, 0 overlapp, sone-isolert, 0 folie under hindring;
  rektangel → fallback.

**Problem 1 — koblet inn i faktisk flyt + bedre dekning + robusthet** (`f80a5c8`, `07866c5`, `bab96f6`)
- Sone-utlegget lå i en sekundær knapp som hovedflyten ikke bruker. Nå tilbyr
  `showAutoFillComparison` et tredje «★ Soner»-kort (ved siden av Horisontal/Vertikal),
  via `_zonedFoilDefs` (defs uten å plassere; sentinel-strips så soner aldri overlapper).
- Adaptiv bredde per sone (bredeste folie som får plass → smalere fyller resten) + retning
  per sone etter dekket areal → kraftig bedre dekning (U-rom: H/V 57 % → Soner 87 %).
- **Robust dekomponering:** klyng/snap koordinater + soner garantert inne i rommet (snitt
  av flere skann). Fjernet den harde ortogonalitets-bailen som gjorde at håndtegnede
  (litt skjeve) rom aldri delte seg → «Soner» dukket aldri opp. Nå trigger den på ekte
  L/T/U-rom; >12 soner → fallback. Verifisert: noisy U m/ hindring → Soner 78 %, 0 overlapp,
  0 folie under hindring, 0 strimler utenfor rommet.

---

## 2026-06-22 — WBW-flyt (vegg-for-vegg): taster + mus

Raskere og mer naturlig vegg-for-vegg-opprettelse, uten å bygge nytt. Commits
(nyeste først): `e5ea346`, `6e023fe`, `601eb29`.

**Taster** (`601eb29`)
- Piltast (↑↓←→) legger veggen direkte i den retningen (var allerede på plass);
  beholder fokus+merk på lengdefeltet etterpå → rask repetisjon for rektangler.
- Skjerm-pilene speiler nå piltastene (`wbwDirPlace` = `setDir` + `addWbwWall`).
- Enter lukker rommet; en vegg som lander på startpunktet auto-lukker.
- Status + Taster-tooltip oppdatert til ny flyt.
- Fiks (`e5ea346`): `addWbwWall`/`undoWbwWall` kalte aldri `render()`, så en vegg lagt
  med piltast dukket først opp ved musebevegelse → kaller nå `render()` umiddelbart.
  Svak stiplet forhåndsvisning av neste vegg vises så snart en lengde er skrevet
  (live mens lengden endres); blir grønn når veggen vil lukke rommet.

**Mus** (`6e023fe`)
- Enter lukker nå i BEGGE moduser. Klikk nær startpunktet (≤ 14 px) lukker rommet
  (≥3 vegger); pekeren blir «pointer» når et klikk lukker.
- Grønn stiplet lukkelinje + forstørret start-prikk vises når musa er nær start,
  så det er tydelig at neste klikk lukker.
- Behold fast-lengde-forhåndsvisning som følger musa, Shift = frihånd, og auto-lukk
  når en festet vegg lander på start. Mus-tooltip/hint oppdatert.

Verifisert (innlogget): firkant via piltaster og via pek+klikk gir begge eksakt
300×300-rom; klikk-på-start og Enter lukker i musemodus.

---

## 2026-06-22 — Kabel-tilbehør ved PDF-eksport (typeavhengig)

Utvidet den deklarative tilbehørs-funksjonen til varmekabel, og gjorde hele tilbehørs-
lista typeavhengig. Commits (nyeste først): `f4e108e`, `ff51e3b`, `c57c88c`, `3720ce4`, `f445aec`.

**Typegating + kabel-tilbehør i modal** (`f445aec`)
- `showAccessoriesModal()` viser Varmefolie-seksjon KUN ved folie og Varmekabel-seksjon
  KUN ved kabel (begge hvis begge; matte alene → ingen). Avledet fra `S.strips`/`S.cables`.
- Ny deklarativ `CABLE_ACCESSORIES` + `_computeCableContext()`:
  - Strips svart (CV087193): 4/m → rund opp til hele 100-pk, viser utregningsgrunnlag.
  - Stålnett (CVA10900): per-rom sjekkliste, `ceil(netto_m2 × 1,10 / 0,92)` pr rom + live total.
  - Følerrør: 1 per kabel-rom; art.nr/EL-nr slås opp i katalogen, flagges hvis det mangler.
- Items merkes `type:'foil'|'cable'`. Ingen regresjon i folie-tilbehør/RKK.

**PDF/Excel gruppert per type** (`3720ce4`)
- PDF «Tilbehør» får egne underseksjoner (Varmefolie / Varmekabel) med art.nr/EL/enhet/
  antall; stålnett viser valgte rom, manglende katalog-nr flagges «OBS:».
- Excel Bestilling + Materialliste skiller tilbehør per type; stålnett-rom i Rom-kolonnen.

**Modal: ingenting forhåndsavhuket + ryddet stålnett-tekst** (`f4e108e`)
- Alle avkrysninger (folie, kabel OG stålnett-rom) starter UAVHUKET. Antallet vises
  fortsatt ferdig utfylt (redigerbart); kun avhukede poster tas med i rapport/PDF.
  «Total stålnett» teller bare avhukede rom (0 når ingen er valgt).
- Fjernet hjelpelinja over stålnett-lista (spec/art.nr) + «velg rom med brennbart
  underlag» → kun «Stålnett» + romliste (navn, areal, antall nett). Beregninger uendret.

**Art.nr/EL-nr hardkodet + avhuket som standard** (`c57c88c`, `ff51e3b`)
- Tilbehør ligger ikke i `heating_products`, så katalog-oppslaget fant dem ikke.
  Hardkodet art.nr + EL-nr (hentet fra cenika.no produktsider):
  - Strips svart **CV087193** · EL **1322300**
  - Stålnett **CVA10900** · EL **1001896**
  - Følerrør **CVA10526** · EL **5400784**
- Alt kabel-tilbehør er `defaultEnabled:false` (ikke valgt som standard); antallet vises
  fortsatt i feltene, så man bare huker av det som skal tilbys. Folie-tilbehør uendret.

Verifisert mot ekte data (innlogget): auto-regler 75 m → 300 strips / 3×100pk · bad 5,8 m²
→ 7 nett · 1 føler/rom; defaults avhuket m/ synlig antall; EL-nr følger med på items;
exportPDF kjører ende-til-ende uten feil.

---

## 2026-06-22 — Gulvtype (toppgulv) + read-only prosjektpresentasjon

To sammenhengende ting: gulvtype per rom med effekt-kompatibilitet, og en read-only
«som prosjektert»-presentasjon. Commits (nyeste først): `87c0bc4`, `9487807`, `d8d89cb`,
`1cab5da`, `5e75838`.

**Del A — Gulvtype + kompatibilitet** (`5e75838`)
- Nytt valgfritt `floorType` per rom (lagres automatisk via `_buildSaveData`).
- `FLOOR_TYPES` som data: maks anbefalt flateeffekt per gulvtype (flis/mikrosement/betong
  150, vinyl/laminat/parkett 100, teppe 60, annet/ukjent = ingen sjekk) — lett redigerbar.
- Ren funksjon `floorTypeCompat(floorType, wm2)` → ok/advarsel/none + delt banner
  `_floorCompatBannerHtml`. Toppgulv-velger + live varsel i UPC-panelet og hurtig-
  prosjekteringskortet. Degraderer pent når gulvtype mangler.

**Del B steg 1 — Presentasjonsmodus** (`1cab5da`)
- «▶ Presentasjon»-knapp i topbar. Gjenbruker editor-canvas + `render()` via
  `S.ui.present` (ingen ny tegning); `body.present-mode` skjuler all redigerings-chrome.
- Topptekst (prosjektnavn, «Prosjektert av <leverandør> for <firma>», dato) + nøkkeltall
  (antall rom, oppvarmet areal, total installert effekt). Leverandøruavhengig, nøytral
  default «Varmeplan». Read-only input: kun panorering/zoom; Escape avslutter.

**Del B steg 2 — Detaljpanel** (`d8d89cb`)
- Hold over (desktop) / trykk (mobil) et rom → fremheving (cyan kontur/glød) + detaljpanel:
  produkt + artikkelnr, installert W, flateeffekt, c/c, kabellengde, spenning, nominell
  motstand (R = U²/P), og toppgulv + kompatibilitet. Treff-test via `ptInPoly`.

**Del B steg 3 — Gulvtekstur + delelenke + PDF** (`9487807`, `87c0bc4`)
- Subtil gulvtekstur per gulvtype UNDER leggemønsteret: rutenett (flis/mikrosement/betong),
  bordmønster (laminat/parkett/vinyl), prikker (teppe).
- «🔗 Del lenke» genererer/lagrer `present_token` og kopierer `?present=<token>`. Boot-sti
  åpner prosjektet read-only uten innlogging via sikker `get_present_project`-RPC (anon kan
  ikke liste andre delte prosjekter). «⬇ PDF» gjenbruker `exportPDF()`.
- Ny migrasjon `supabase-migration-presentation.sql` (kjøres manuelt): `present_token`-kolonne,
  RPC, anon-lesetilgang til katalogtabeller. Mockup i `docs/Varmeplan-prosjektpresentasjon.html`.
- **NB:** Supabase-rundturen for delelenken er implementert men ikke testet mot live DB —
  test «Del lenke» + åpne lenken i privat vindu etter at migrasjonen er kjørt.

---

## 2026-06-18 — Hurtig prosjektering: «Lagre prosjekt»-knapp (commit 2f080da)

Tydelig lagre-kontroll nederst i romlista, som komplement til autolagringen.
- Teal «Lagre prosjekt»-knapp rett under «Opprettede rom»; deaktivert når lista er tom.
  Autolagrings-indikatoren i headeren beholdt.
- `_listSaveProject` → idempotent flush (`_saveToSupabase`) + toast «Lagret – finnes i
  prosjektlista og i feltappen»; knappen viser «Lagret ✓», og «Gå til prosjektliste»
  dukker opp (uten å tvinge navigasjon).
- Navngiving for gjenfinning: ved autonavn («Prosjekt – <dato>») ber `_listSaveNameDialog`
  om prosjektnavn (+ valgfri adresse) før lagring; ellers lagres direkte. Navnet skrives
  til `romtegner_projects.name` → søkbart i feltappen.
- Datastruktur uendret — samme record (rom + produkter i `data`) som feltappen leser; kun verifisert.

---

## 2026-06-16 — Import plantegning: tegnede rom, samlet meny, kalibreringsvalg, lag-filter, folie-label

Bygde ut PDF-importen (mot den delte motoren) så den også gir **ekte tegnede rom**, og
ryddet i import-UX etter testtilbakemelding. Commits (nyeste først): `e963ae4`, `9c679de`,
`81a8fcf`, `caf0c6a`, `2218a1d`, `fdd2fcc`, `23eb071`.

**Importer plantegning → tegnede rom** (`23eb071`, `fdd2fcc`)
- Ny adapter `_drawCreateRoomsFromReview`: motor-polygon (meter, Y-opp) → cm med Y-flip →
  `createRoom(pts,'polygon',navn,floorId,keepPosition=true)` = ekte rom m/ vegger, bevart
  innbyrdes plassering. Mål (`target` 'draw'/'list') tres gjennom review-flyten.
- «Importer plantegning» i tegne-verktøylinja (ctxbar) peker nå på motor-importen.

**Samlet import-meny** (`2218a1d`)
- Én «Importer plantegning»-knapp → `_importPlanMenu`: «Les av rom automatisk» (motor) eller
  «Tegn selv over bakgrunn» (PDF/JPG som bakgrunn, også skannede).

**Auto-les med bakgrunn + kalibrering i flukt** (`caf0c6a`, `81a8fcf`)
- Auto-les laster PDF som **bakgrunn** (pdf.js), bruker kalibrerer, så plasseres rommene
  nøyaktig oppå (kanonisk frame: PDF-punkt (0,0) = verden (0,0), skala fra kalibrert bakgrunn).
  Bakgrunnen blir liggende så møblering vises mens man tegner folie.
- Kalibrerings-overlayet tilbyr nå **begge** metoder: «Klikk to punkter (kjent avstand)» og
  «Fast målestokk (1:50)» (gjaldt før kun to-punkts). Gjelder all bakgrunnsimport.
- **Lag-filter:** auto-les henter PDF-lagene og lar bruker huke av vegg-lag (default
  vegg/yttervegg/skille) → kun vegger blir rom; møbler/inventar/tekst vises kun i bakgrunnen.

**Folie-stripe-label mindre på skjerm** (`9c679de`)
- Folie-stripe-labelen skaleres ned på canvas (lettere å lese romoppsett), men beholder
  passende størrelse i PDF-utskrift.

**Liste-import (hurtig prosjektering) — to skaleringsvalg** (`e963ae4`)
- PDF-importen i hurtig prosjektering får i tillegg til «Målestokk 1:__» et valg
  «Klikk et kjent mål i tegningen» (to-punkts via bakgrunn). Etter målsetting fortsetter
  alt som før: vegg-lag → liste med romnavn + areal.

**Forbehold (uendret):** selve motoren testes mot ekte vektor-PDF fra brukerens maskin
(sandkassen min når den ikke). Bakgrunn↔rom-justering kan trenge én finjusterings-runde på
en virkelig tegning. Lag-filteret virker kun hvis PDF-en har lag som skiller vegger fra møbler.

---

## 2026-06-15 (kveld) — Infra: motor deployet til Fly, mappe-organisering, feltapp-oppsett

Ikke `romtegner.html`-endringer, men workspace/infra fra samme økt — loggført for sporbarhet.

**Lumelo-motoren live på Fly.io**
- Deployet `~/Code/lumelo-backend` (FastAPI) → `https://lumelo-backend.fly.dev` (region arn,
  scale-to-zero). La til `Dockerfile`/`fly.toml`/`.dockerignore` + CORS for arqely.com i
  `app/core/config.py` + deploy/status-notis i `lumelo-backend/CLAUDE.md`. Commit i
  lumelo-backend: `95b45a5` (repoet har ingen remote ennå — kun lokal commit).
- Verifisert `GET /health` → ok (fra mobil; mitt sandkasse-miljø når ikke eksternt nett).
  Sandkasse-merknad: Bash/preview/WebFetch er nett-begrenset her → ekstern verifisering må
  gjøres fra brukerens maskin.

**Prosjektmappe-organisering** (`~/Documents/Claude Code/`)
- Den ekte koden til Lumelo bor i `~/Code` (ikke iCloud). La inn **symlenker** under Claude
  Code-mappa: `lumelo` → `~/Code/lumelo`, `lumelo-backend` → `~/Code/lumelo-backend`
  (samlet tilgang, men deps synkes ikke til iCloud).
- `Lumelo_Spec` → omdøpt til **`Lumelo_Spec (arkiv)`** (kun gammel plan/spec; den ekte koden
  er symlenkene). `arqely-mvp` = fortsatt rotmappa til Varmeplan-web.

**Ny app: Varmeplan Feltapp (Prompt 0 + oppsett)**
- Eget prosjekt for mobil feltapp (Expo/React Native), delt Supabase. Opprettet
  `~/Code/varmeplan-app` (+ symlink i Claude Code-mappa) med `docs/` (UX-prototyper +
  `supabase-schema/` = migrasjonene) og en `CLAUDE.md` som fanger Prompt 0-planen:
  offline-først (expo-sqlite + outbox), backend-kontrakt (rom i prosjekt-JSON, integer
  product_id, klient-genererte UUID-er, RLS via org-medlemskap), måleregler fra `suppliers`,
  navigasjon + 6-stegs byggeplan. Bygges i egen Claude Code-økt (Prompt 1).

---

## 2026-06-15 — Import plantegning: gjennomgangssteg, motor live, og liste-UX

Koblet PDF-import (mot den delte Lumelo-motoren) til hurtig prosjektering via et
fokusert gjennomgangssteg, og fikk **motoren live i produksjon**. Commits (nyeste
først): `aebdd88`, `d635d91`, `c8e0802`, `51b334b`, `021f21d`.

**Gjennomgangssteg (steg 2)** — `#import-review-screen` (`021f21d` la import, `51b334b` la gjennomgang)
- `_pdfImportRun` → `_pdfOpenReview(ImportResult)` i stedet for rett i lista.
- To synkroniserte ruter mot én kilde (`_reviewState.rooms`): SVG-plan (polygoner,
  bbox→viewBox, flip Y; teal=valgt, grå=fravalgt, gul=warn; klikk=toggle) + redigerbar
  liste (navn/areal/slett/legg til). Toveis hover via rom-id.
- Areal = shoelace(polygon, m²). `review[]` plasseres i riktig rom via `where`-punkt;
  navnløse rom → «Sjekk navn». Bulk (alle/ingen/forslag) + smart standard fra
  `_pdfGuessRoomType`. Gulvoppbygging lagres (`_floorBuild`). Adapter
  `_pdfCreateListRoomsFromReview` → `_listCreateRoomObj`.

**Motor live på Fly.io** (`c8e0802`, `d635d91`)
- `_engineUrl()`: `window.LUMELO_ENGINE_URL` → `localStorage['lumelo_engine_url']` →
  vertsbasert (arqely.com → `https://lumelo-backend.fly.dev`, ellers localhost:8000).
  Feil-dialog lar deg lime inn/lagre motor-adresse.
- Motoren (`~/Code/lumelo-backend`, FastAPI) deployet til Fly (`lumelo-backend.fly.dev`,
  region arn) — bekreftet `/health` = ok. Se [[project_lumelo_engine]].

**Liste-/import-UX** (`aebdd88`)
- Fiks blank side: `_pdfOpenReview` skjulte `#app`; `_reviewReturnToApp()` viser den igjen
  ved commit/avbryt → man lander rett i hurtig prosjektering.
- Prosjektnavn ved import (felt i gjennomgang-toolbaren → `S.project.name`).
  **Bugfiks:** `_ensureDraftProject` auto-navnga ALLTID ved autolagring og overskrev
  brukerens navn — nå kun når navnet er tomt.
- Valgt rom forsvinner ikke lenger fra lista: redigert rom blir værende i tabellen,
  uthevet (teal + ● + venstrekant); kortet får «Rediger rom: \<navn\>».
- Piltaster på Type/Klasse/Produkt/Etasje-nedtrekkene stepper valget med live CC + W/m².

Alt verifisert i preview (mock-import, ingen DB-skriving). Motor-deploy-artefakter
(`Dockerfile`/`fly.toml`/`.dockerignore` + CORS for arqely.com) ligger i `lumelo-backend`.

---

## 2026-06-13 — Autonom polering av dok-/garanti-/reklamasjonsmodulen

Kjørt autonomt (uten brukervalg) mens bruker var borte. Alt verifisert i preview
(parse + render + PDF-bygging med mock-state, ingen skriving til produksjons-DB).
Commits (nyeste først): `bf64a2d` (kode), + CLAUDE.md / Edge Function / denne loggen.

**Selvgjennomgang + buggfiks** (underagent-review av all ny kode)
- `_docUpdProduct`: `nominal_ohm` settes til `null` (ikke `NaN`) når effekt tømmes.
- `_claimMutate`: kaster nå feil ved mislykket `claim_events`-innsetting (ingen stille feil).
- `_docMeasOk`: robust fallback til standard-leverandør hvis `_docState` mangler
  (hindrer krasj ved PDF-bygging uten aktiv state).

**Montørens sak-status (les-only)** — `_claimStatusView`
- Fullført rom i doc-velgeren viser «Sak: <status>» når en reklamasjon finnes, og åpner
  en les-only statusvisning med tidslinje + «neste steg» (venter på godkjenning /
  godkjent → kontakt feilsøkefirma / avvist / lukket). Henter kun egne saker.

**Rikere garantibevis-PDF** — `_docBuildPDF`
- Leverandørfarget topp (hex→rgb for robust jsPDF-rendering).
- Fotodokumentasjon bygget inn som miniatyr-rutenett (2 per rad, automatisk sideskift).

**Dokumentasjon / scaffold**
- `CLAUDE.md`: ny seksjon «Documentation, Warranty & Claims Module (implemented)» —
  tabeller, RLS-mønster (JWT-superadmin), kodekart, z-index- og e-post-konvensjoner.
  Flyttet ut av «Future».
- `supabase/functions/send-warranty-email/` (index.ts + README): Edge Function for
  kunde-/leverandørkopi (Resend). **Inaktiv** til den rulles ut + secrets settes —
  README har deploy-steg og hvordan den kobles på i `_docGenerate`/`_claimSubmit`.

**Gjenstår til bruker (krever valg/nøkler):** rull ut Edge Function (Resend-nøkkel +
verifisert domene) og koble den på; «del med huseier»-offentlig visning (krever ny
anon-RLS-policy via share_token — egen migrasjon).

---

## 2026-06-12 — NY MODUL: Dokumentasjon & garantiportal (Fase 1–3, hele Prompt 0→3)

Bygget en komplett dokumentasjons-, garanti- og reklamasjonsmodul oppå eksisterende
prosjekt/rom/produkt/innlogging. Alt verifisert i preview (UI + PDF) og ende-til-ende mot
Supabase (lagring + reklamasjonsflyt, med opprydding av testdata). Pushet til `main`.
Commits (nyeste først): `8bf26f9` (Fase 3), `1176ed0` (Fase 2), `e48b862` (Fase 1).

**Migrasjoner (kjørt i Supabase, ren ASCII, idempotente)**
- `supabase-migration-documentation.sql` — `suppliers` (leverandør som data, seed Cenika m/
  måleregler ±10 %, >10 MΩ @ 500 V), `supplier_id` FK på `heating_products` (integer, ikke uuid),
  `warranty_certificates`, `certificate_products`, `measurements`, `certificate_photos`, RLS + privat
  `documentation` storage-bucket.
- `supabase-migration-claims.sql` — `claims`, `claim_events` (tidslinje), `claim_photos`, RLS.
- **RLS-lærdom:** superadmin-policyer må lese `is_superadmin` fra `auth.jwt() -> 'app_metadata'`,
  IKKE `SELECT FROM auth.users` (authenticated mangler tilgang → 42501; separate policyer
  kortslutter ikke slik OR-uttrykk inni én policy gjør).

**Fase 1 — Dokumentasjon (`e48b862`)**
- Ny «Dokumentasjon»-fane (prosjekt-/rom-velger) + rollestyrt «Garantiportal»-fane (kun
  `org_type='supplier'`) + «Dokumentér»-snarvei i rom-høyreklikkmeny.
- Mobil `#doc-screen` 5-stegs veiviser: bekreft produkter (prefill fra tegning, nominell R=U²/P)
  → installasjon & styring → måleverdier m/ live validering (grønn/rød) → foto med faste slots
  → sjekkliste + signatur → genererer garanti-ID, lagrer bevis + PDF (jsPDF) til skyen.

**Fase 2 — Garantiportal (`1176ed0`)**
- KPI (totalt, denne måneden, med avvik, aktive firma), filtrert bevisliste (søk + status + firma +
  periode), detaljpanel med fargekodet måletabell (mot leverandørtoleranse), foto via signerte
  storage-URL-er, «Åpne PDF». RLS «Supplier orgs read their certificates» filtrerer automatisk.

**Fase 3 — Reklamasjon (`8bf26f9`)**
- Mobil `#claim-screen` «Meld feil» (kanal app + telefon → samme sak): feiltype, kundebeskrivelse,
  feilsøk (R/iso/foto), anbefalt tiltak, feilsøkefirma, kunde-e-post → sak m/ tidslinje.
- Portal under-nav Garantibevis|Reklamasjoner: statistikk (antall, samlet kostnad, vanligste årsak,
  andel dekket), saksliste, saksdetalj med tidslinje + **godkjenningssteg** (Godkjenn/Avvis —
  feilsøkefirma sendes ikke ut før godkjent) + kostnad + utfall (godkjent/delvis/avslått → lukk).
- Innganger: «⚠ Meld feil» på fullført rom i doc-velger + «Registrer telefonsak» i bevisdetalj.

**Bevisste valg / gjenstår**
- Leverandør som data (ØS Varme = «én ny rad»). Egne tabeller, ikke prosjekt-JSON (portal-søk på tvers).
- Skjermer `#doc-screen`/`#claim-screen` må ha z-index > 1001 (dashbordet `#project-list-screen` = 1001);
  portal-modal z-index 2000.
- E-post (kunde-rutinevarsel + leverandør/montør-kopi) utsatt til Supabase Edge Function — vises som
  info; alt lagres i skyen uavhengig. `share_token` finnes på beviset for senere «del med huseier»-lenke.

---

## 2026-06-10 — ØKT-OPPSUMMERING (stor økt: kabel-, folie-, matte-, soner- og plantegning-arbeid)

Detaljerte oppføringer pr. punkt under. Alt verifisert (mest numerisk in-memory pga. treg test-fane
mot slutten) og pushet til `main`. Commits (nyeste først): `83eeab3`, `438cc2d`, `3762ab9`,
`3a36364`, `e81773b`, `fd1a8eb`, `0bc8953`, `81626be`, `053b363`, `d18ce32`, `f810848`, `28422d8`,
`298d11e`, `193e8d6`, `720947a`, `fd78476` (+ tidlig: `616a110`, `6dee009`, `bc0d773`).

**Varmekabel**
- `fd78476` V6 honorerer valgt RETNING (`dirExplicit`) — slutt på «velger horisontalt, legger vertikalt».
- `720947a` L/T horisontalt → ren boustrophedon-serpentin; + 5 cm perp-margin fra indre parallelle vegger.
- `193e8d6` auto-retning foretrekker den rene (godt-fyllende) boustrophedon-retningen.
- `3a36364` «Del i N like soner» med eksplisitt horisontal/vertikal-toggle (hard honorering, felles CC).
- `83eeab3` rene multi-kabel-soner i komplekse rom (betinget vertex-snap + ingen skew i soner).
- (tidlig: retningsvelger-reapply, L-diagonal→ortogonal, rektangel-starthjørne.)

**Varmefolie**
- `f810848` «lange strimler vegg-til-vegg» som default (mot fragmentering) + bryter «Maks dekning».
- `e81773b` ALDRI folie over folie (hard invariant: footprint-subtraksjon ved fyll + retnings-uavhengig overlapp).

**SONER (utleggingssoner)**
- `28422d8` del et rom i navngitte soner via delelinjer; folie pr. sone, per-kant margin (yttervegg vs delt grense).

**Hindring**
- `298d11e` fri plassering + mykt vegg-snap (`clampHindringToRoom` omskrevet: containment + sann segment-avstand).

**Plantegning / bakgrunn**
- `d18ce32` «Fast målestokk» (1:50) alltid tilgjengelig + eksakt for PDF.
- `053b363` deselekter bakgrunn etter skalering (henger på skalerings-baren).
- `81626be` + `0bc8953` lås kalibrert underlag (klikk-felle), også eksisterende prosjekter.
- `fd1a8eb` bakgrunn lekket til andre prosjekter (async onload-race) — token-guard.

**Matte (EcoMat innendørs)**
- `3762ab9` EcoMat 60T/100T/150T-utlegg: bredder inntil hverandre + kald sone, hele matta delt i N like bredder.
- `438cc2d` innendørs: tydeligere produkt-label (unna romnavn), kabel-label alltid synlig, matter unngår hindringer (5 cm), matte-gap min 0 (folie-modell).

**Anbefalt neste steg (ikke gjort):** felles kabel/folie/matte-INVARIANT-spec + testliste alle motorer
må bestå (5 cm margin, lik CC, hjørne-start/stopp, eksplisitt retning hard, aldri overlapp, ingen
diagonal/rar form, fyll til vegg) — fanger samme rot-klasse systematisk. Venter på «si fra».

---

## 2026-06-10 — Varmekabel: rene multi-kabel-soner i komplekse rom (Gang) — betinget vertex-snap + ingen skew i soner

Symptom: Gang (~37 m²) delt i 2 like soner — sone 1 ren serpentin, sone 2 (irregulær equal-area-
halvdel) fikk «rare former» (skew-løp, skrå/ujevne U-svinger) og fylte ikke til veggene.

### Rotårsak
`_buildNCableZones` kuttet med `_equalAreaBandBounds` (lik areal → lik CC), men på et komplekst rom
ble sone 2 IRREGULÆR → `_autoFillCableImpl` sin `needSkew = !rectilinear || …` falt til
`generateCableSkew` → skrå løp / rare former.

### Fix (to prong)
1. **Betinget vertex-snap** (`_buildNCableZones`): re-innført `_snapBoundsToVertices` — snapper hvert
   indre kutt til nærmeste rom-hjørne/innhakk, MEN bruker det kun når sonene holder seg ~like store
   (areal-avvik ≤ 10 %); ellers beholdes equal-area-kuttet. Gir mest mulig REKTANGULÆRE soner uten å
   ødelegge lik CC.
2. **Ingen skew i soner** (`_noSkew`-flagg på sone-temp-rommet): `needSkew` respekterer nå
   `room._noSkew` → multi-kabel-soner bruker ren aksejustert serpentin (boustrophedon/V6, ortogonal
   kobling) i stedet for skew. «Heller jevnt udekket inntil vegg enn skrå/rotete løp» (Kenneths regel).

### Verifisert (numerisk; in-memory, ingen konsoll-feil)
- L-korridor (~35,8 m²) delt i 2, begge retninger: BEGGE soner = **boustrophedon**, `pathEls:0` (ingen
  skew), `nConn:0` (ingen diagonal kobling), lik CC 12,7 cm, ~140 m kabel hver (≈99 % dekning).
- Ingen regresjon: rektangel delt i 2 → begge boustrophedon (uendret); enkel kabel i SKRÅTT rom →
  bruker fortsatt skew (pathEls 51), siden `_noSkew` kun gjelder sone-temp-rom.

> Spec-en anbefaler sterkt en felles «kabel/folie/matte-invariant-spec» med testliste alle motorer
> må bestå (5 cm margin, lik CC, hjørne-start/stopp, eksplisitt retning hard, aldri overlapp, ingen
> diagonal/rar form, fyll til vegg). Ikke laget ennå — venter på «si fra».

---

## 2026-06-10 — Innendørs: tydeligere label + kabel alltid synlig + matte-hindring + matte-gap (4 punkter)

1. **Tydeligere produkt-label, unna romnavn:** font opp (strimmel 7–11 → 12–15 px; kabel 10 → 13;
   matte 12 → 13) og labelen FORSKYVES langs objektets lengde vekk fra rom-sentroiden (strimmel/
   kabel: ~28 % mot enden lengst fra sentroiden; matte: ~halvveis mot en ende), så den aldri ligger
   oppå romnavnet (som tegnes i sentroiden). Rammet 2-linjers-oppsett beholdt.
2. **Kabel + label ALLTID synlig:** kabel-labelen var gated på `S.ui.showStripLabels` (folie-toggel)
   → fjernet for kabel. Kabel-geometri OG label vises nå permanent uansett valgt rom/objekt (kun
   `cable.labelVisible===false` skjuler en enkelt). Valgt kabel uthives fortsatt.
3. **Matter unngår hindringer (5 cm):** `autoFillMatSerpentine` brukte før kun rom-bbox og rørte
   ALDRI `S.hindrings`. Nå inflateres hver hindring med veggmarginen (5 cm) og det brukbare
   rektangelet krympes grådig til største hindrings-frie side → ingen matte på/innen 5 cm av en
   hindring (verifisert: bunn-hindring y=300 → matte stopper y=282). Sentral hindring → matta havner
   på den største frie siden; per-løp-klipping rundt indre hindringer er en senere refinement.
4. **Matte-gap som varmefolie (min 0):** gap-panelet (`openMatGapPanel`/`setMatGap`/`stepMatGap`) er
   nå modul-bevisst — innendørs: min 0 / default 0 (matter inntil hverandre, sentrert) / max 5; snø
   (Ute/InSnow): beholder min 5 / standard 10 / max 20. Fikset `cm||10`-bug som gjorde 0→10. Motoren
   bruker bruker-gapen (default 0), sentrerer blokka → rest = kald sone likt på veggene. EcoMat-
   tvang-til-0 erstattet med denne (default 0 = samme edge-to-edge).

Verifisert: render m/strip+matte+ny label-kode 3 ms uten feil; hindring-unngåelse + gap 0/3/steg
numerisk. Items 1–2 (visuelt) bekreftet via kode + feilfri render — fin-justering av label-størrelse/
plassering kan vurderes visuelt (kunne ikke ta skjermbilde pga. treg test-fane).

---

## 2026-06-10 — EcoMat innendørs: matte-utlegg etter Kenneths modell (bredder inntil hverandre, hele matta delt i N)

Spec basert på 3 Cenika-produktblad (EcoMat 60T/100T/150T) + teknisk tegning TPL-ECOMT-CA-2183.

### Produktdata
- **Supabase hadde allerede ekte EcoMat-rader** (57 stk, laget 2026-03-11) med riktig
  cc/kutt/bredde/areal/W/art.nr/el.nr. Derfor: ikke dupliser — `_ensureEcoMatProducts()` injiserer
  hele katalogen (60T/100T/150T, 19 størrelser hver, 0,5×2m…0,5×30m, CVA10100–10158, el 1013743–
  1013799, fra produktbladene) KUN som fallback hvis ingen finnes.
- `_normalizeEcoMat()` markerer ALLE EcoMat-produkter (Supabase eller fallback) med
  `mat_equal_widths=true` (Supabase-radene mangler flagget). CC/kutt fra tegningen: 60T/100T = 120/
  240 mm, 150T = 80/160 mm; bredde 500 mm; W/m² 60/100/150.

### Matte-motor (`autoFillMatSerpentine`, gated på `mat_equal_widths`)
- **Bredder INNTIL hverandre:** `gapCm` tvinges til 0 for EcoMat → N = floor(brukbar bredde / 50 cm)
  eksakt; blokka sentreres → rest = kald sone likt på begge yttervegger (ikke jevn-fordelt gap som
  før). Seam-klaring kommer fra kant-inntrekket (2,5 cm hver side → ~5 cm kabel-til-kabel).
- **Størrelsesvalg snudd (Kenneths modell):** velg STØRSTE variant der (mat_total_length / N) ≤
  brukbar lengde; fordel HELE matta i N like bredder à (total/N), rundet NED til kutt-intervallet.
  Erstatter «minste matte ≥ behov + snap til rom». Bruker hele matta, minimer svinn, kald sone i
  lengde-enden.
- Retning respekterer delt retningsvelger; forhåndsvis-før-godta som ellers.

### Verifisert (numerisk; render 14 ms — ingen freeze)
- **Spec-eksempel 210×400, 100T:** N=4, velger 0,5×14m (700 W), 4 bredder à 336 cm (3,5m snappet
  til kutt 24cm), gap 0, **5 cm kald sone hver yttervegg**, brukt 13,4 av 14m. Matcher eksempelet.
- 260×600 100T → 0,5×28m, N=5. 210×400 150T → 0,5×14m (1050 W), N=4. 300×500 150T → 0,5×24m, N=5.
- Ikke-EcoMat-matter (InSnow utendørs) uendret (jevn-fordelt gap beholdt).
- Stats: produktets `total_effect_w` / `mat_area_m2` (ratet effekt), som InSnow.

---

## 2026-06-10 — Varmekabel: «Del i N like soner» med eksplisitt horisontal/vertikal-valg

Kenneth: del et stort rom (~37 m²) i 2–3 HELT LIKE soner → like kabler med jevn CC, og velg
eksplisitt om rommet deles horisontalt eller vertikalt. Motoren fantes (`_buildNCableZones`:
equal-area-soner + felles CC + like kabler); manglet UI + hard styring av retning.

- **UI:** delretning-toggle [Auto] [Horisontalt] [Vertikalt] i kabel-panelets manuell-/«Flere
  kabler»-seksjon (`_cableSplitToggleHtml`/`_setCableSplitDir`, modul-var `_cableSplitDir`).
  Antall = eksisterende count-input. «Forhåndsvis ›» bygger forslaget.
- **Hard honorering:** `_cableManualPreview` → `_cablePreviewPlace(...,splitDir)` →
  `autoFillMultiCable(roomId, productId, n, splitDir)` → `_autoFillNCables(forcedDir)`. forcedDir
  bygger KUN valgt retning (samme harde override som dirExplicit). Map: Horisontalt→'h'
  (horisontale delelinjer, soner stablet), Vertikalt→'v' (vertikale delelinjer, soner side om
  side). De power-drevne multi-kabel-knappene honorerer også toggelen (default `_cableSplitDir`).
  Auto (null) = motoren velger som før.
- **Beholdt:** equal-area-kutt (`_equalAreaBandBounds`), felles `sharedCC`, half-CC-sømmer → N
  identiske kabler med jevn CC også over sone-grensene.
- **Verifisert (37 m² rom, prod InFloor 10T 50m):** 3 vertikalt → 3 kabler alle 'v', soner
  [0–247][247–493][493–740], CC 24,7 cm identisk, 50 m hver; 3 horisontalt → alle 'h', samme CC;
  2 vertikalt → 2 like; Auto → motoren velger. Visuelt bekreftet (K1/K2/K3 side om side, identiske).
  Ingen regresjon på énkabel. Ingen konsoll-feil.

---

## 2026-06-10 — Varmefolie: ALDRI folie over folie (hard invariant)

Symptom: en folie (lang strimmel) la seg OVER andre folier. Krav: folie skal aldri overlappe
folie — stopp en klaring (≥ folie-gap) før eksisterende folie, uansett retning/sone/fyll-sti.

### Rotårsak
- Overlapp-vernet (`_stripOverlapsAny`) sjekket bare folier i SAMME retning (`_stripsForRoomDir`).
- `computeClippedSegments` klippet mot rom-polygon + hindringer + forbudt-soner, men ALDRI mot
  eksisterende folier → fyll/sone-fyll/lange-strimler kunne legge en folie rett oppå andre.

### Fiks
- **Footprint-subtraksjon i `computeClippedSegments`** (kjernen): ny modul-kontekst `_foilAvoidCtx`
  (`{roomId, excludeIds}`), satt via `_withFoilAvoid(roomId, exclude, fn)` rundt hver fyll-operasjon.
  Når satt, subtraheres footprinten til ALLE eksisterende folier i rommet (alle retninger/soner),
  inflatert med folie-gap, akkurat som en hindring — UNNTATT batchen som erstattes (unngår
  selv-blokkering). Opt-in → editorer/ikke-fyll-stier uendret.
- **Wiret i alle fyll-stier:** auto-fyll-sammenligning (ekskluder samme kategori), sone-fyll
  (ekskluder samme sone — peker på det EKTE rommet siden sone-fyll bruker temp-rom), manuell
  drop/preview (ekskluder ingen). «Lange strimler» går gjennom samme `computeClippedSegments`.
- **Retnings-uavhengig overlapp** i `_stripOverlapsAny`: i tillegg til samme-retning-logikken,
  ekte verdens-rektangel-nærhet (`_stripWorldRect`/`_rectsWithin`) mot folier av MOTSATT retning →
  manuell plassering/drag og sikkerhetsnett blokkerer kryssende folier.

### Verifisert (numerisk; ingen konsoll-feil)
- Eksisterende horisontal folie (y150–169); ny vertikal ved x180: uten vern ett løp y3–297 (overlapp);
  MED vern splittet y3–147 + y172–296 → stopper 3 cm (gap) før, ingen overlapp. Kryss-retning flagges.
- Sone-fyll: 0 overlapp mellom nabosoners folie (6 par sjekket).
- Ingen regresjon: rent rektangel auto-fyll uendret (2 striper/91 %); klaringen = folie-gap (holder
  SONER-skjøtens half-gap konsistent; «~5 cm ende-mot-side» er tilnærmet med gap — kan økes om ønsket).

---

## 2026-06-10 — Plantegning BUGFIX 4: bakgrunn «lekket» til andre prosjekter (async race)

Bruker: «bakgrunnstegningen jeg la inn på et prosjekt har lagt seg inn som bakgrunn på alle mine
lagrede prosjekter — ble ok igjen etter en refresh».

- **Rotårsak:** i `_restoreProject` lastes bakgrunns-bildet ASYNKRONT (`bImg.onload`). Åpner du
  prosjekt A (med bg) og så B, kan A-bildets `onload` fyre ETTER at B har nullstilt `S.bgs` →
  A-bakgrunnen skrives inn i B sitt `S.bgs`. Rent i minnet (derfor «ok etter refresh»); lekker bare
  til lagring hvis man lagrer mens den feil-bakgrunnen vises.
- **Fiks:** innlastings-generasjon `_bgRestoreGen` bumpes ved hver prosjekt-åpning; hver async
  bg-`onload` fanger generasjonen ved planlegging og skriver KUN hvis den fortsatt er gjeldende
  (`if (_myBgGen !== _bgRestoreGen) return`). Stale bilder fra et tidligere prosjekt ignoreres.
- **Verifisert:** to prosjekter åpnet etter hverandre gir konsistent `S.bgs` (ingen lekket bg),
  ingen feil.
- **Merk til bruker:** lekkasjen var i minnet → dine LAGREDE prosjekter er trygge (en refresh
  fjernet den). Hvis et prosjekt likevel viser feil bakgrunn ETTER refresh, si fra — da kan en
  feil-bakgrunn ha blitt lagret, og jeg rydder den.

---

## 2026-06-10 — Plantegning BUGFIX 3: auto-lås kalibrert underlag ved innlasting (eksisterende prosjekter)

Oppfølger: bruker fortsatt fast + «vis/skjul gjør ingenting». Reproduserte HELE den ekte flyten
interaktivt (importer → «Sett målestokk nå» → 2 klikk → 5 m → fullfør): etter kalibrering kommer
den kombinerte «BAKGRUNN Vis/opacity … | TEGN ROM Rektangel/Mål/…»-baren, klikk i tegningen holder
seg der (bg låst), og vis/skjul SKJULER tegningen korrekt. Altså: med gjeldende kode virker alt.

- **Sannsynlig årsak for «fortsatt fast»:** (a) deploy/cache-etterslep (eldre versjon i nettleseren),
  eller (b) eksisterende prosjekt med en ALLEREDE kalibrert, ULÅST bakgrunn — auto-låsen i bugfix 2
  gjelder bare NYE kalibreringer.
- **Fiks (b):** `_restoreProject` låser nå et kalibrert underlag ved innlasting
  (`if (bg.img && !bg._needsCalibration) bg.locked = true`) → eksisterende prosjekter blir også
  klikk-trygge (klikk går gjennom underlaget). Lås opp via lås-knappen for å flytte det.
- **Verifisert:** ulåst bg → klikk treffer; låst bg → klikk går gjennom (`_hitBgLayer` null).
  Full ekte kalibrerings-flyt gir «Tegn rom»-bar; vis/skjul fungerer.
- **Til bruker:** symptomene matcher å kjøre eldre kode — gjør en HARD refresh (Cmd/Ctrl+Shift+R)
  for å hente nyeste versjon.

---

## 2026-06-10 — Plantegning BUGFIX 2: lås underlaget etter kalibrering (klikk-felle)

Oppfølger: «jeg kan skalere og den går over til opprett-rom-baren, men hvis jeg klikker i tegningen
går den tilbake til plantegning-baren — kommer meg ikke ut.»

- **Rotårsak:** et kalibrert, ULÅST bakgrunns-lag er klikk-valgbart (`_hitBgLayer` treffer det).
  Etter skalering var baren riktig, men ETHVERT klikk i tegningen valgte bakgrunnen igjen →
  «Plantegning … Skaler på nytt»-baren kom tilbake, og man satt fast.
- **Fiks:** `confirmBgCalibrate` og `confirmFixedScale` setter nå `bg.locked = true` etter fullført
  kalibrering. `_hitBgLayer` hopper over låste lag → klikk går GJENNOM underlaget, så man tegner rom
  fritt. Lås opp igjen via lås-knappen (plantegning-ctxbar eller sidepanelets lag-liste) for å
  flytte/transformere underlaget. Standard CAD-oppførsel for et referanse-underlag.
- **Verifisert:** etter både fast målestokk og 2-punkts er `bg.locked=true`, `_hitBgLayer` ved et
  punkt inne i tegningen returnerer null, og klikk-kandidatlista er tom → ingen utilsiktet
  bg-seleksjon. `includeLocked`-stien finner det fortsatt for eksplisitte operasjoner.
- Merk: gjelder NYE kalibreringer. Eksisterende prosjekter med ulåst kalibrert underlag: lås det
  én gang via «Lås»-knappen i plantegning-baren, så går klikk gjennom.

---

## 2026-06-10 — Plantegning BUGFIX: «henger på skalerings-baren» etter kalibrering

Bruker: «det skjer ikke noe når jeg skalerer eller setter målestokk … nå vises kun topbar for
skaleringsvalg hele tiden» (tidligere kom rom-innsetting opp etter skalering).

- **Rotårsak:** når skalering trigges fra den VALGTE bakgrunnen (selectedBg satt — f.eks. via
  «Skaler på nytt»/«Målestokk 1:_» i plantegning-ctxbar-en), nullstilte hverken `confirmBgCalibrate`
  eller `confirmFixedScale` `S.ui.selectedBg`. Skaleringen BLE utført (widthCm endret), men
  bakgrunnen forble valgt → ctxbar-en hang igjen på «Plantegning … Skaler på nytt»-baren i stedet
  for å gå til «Tegn rom». Føltes som «det skjer ikke noe».
- **Fiks:** begge funksjonene nullstiller nå `S.ui.selectedBg = null` (i tillegg til
  selectedRoomId/selectedWallId) → ctxbar-en går korrekt til rom-innsetting etter skalering.
- **Verifisert:** både fast målestokk (1:50) og 2-punkts kalibrering trigget fra valgt bakgrunn gir
  nå `selectedBg=false` og ctxbar «Tegn rom … Rektangel/Mål/Polygon». Ingen konsoll-feil.

---

## 2026-06-10 — Plantegning: «Fast målestokk» (1:50) alltid tilgjengelig + eksakt for PDF

Bruker meldte «får ikke skalert tegning lenger» og ønsket målestokk-forhold (1:50) som tillegg.

### Funn (bug-undersøkelse)
- 2-punkts-kalibreringen (`startBgCalibrate` → klikk 2 punkter → `confirmBgCalibrate`) er IKKE brutt:
  verifisert ende-til-ende i appen (klikk 1 → punkt 1, klikk 2 → modal → skalerer; A4 100 px = 5 m
  ga riktig faktor). Logikken i både `confirmBgCalibrate` og `confirmFixedScale` er korrekt.
- Reell mangel: **«Fast målestokk» (forhold) var bare tilgjengelig på en NYIMPORTERT, ukalibrert
  tegning** (ctxbar-grenen `notCalibrated`). Når tegningen først var kalibrert og du valgte den for
  å re-skalere, fantes bare «Skaler på nytt» (2-punkts) — ikke forholds-skalering. Det forklarer at
  man «ikke får skalert» via forhold etterpå.

### Endringer
- **«Målestokk 1:_»-knapp lagt til i den valgte-plantegning-ctxbar-en** (ved siden av «Skaler på
  nytt») → forholds-skalering er nå tilgjengelig når som helst, ikke bare ved import.
- **Eksakt 1:50 for PDF:** ved PDF-import fanges den fysiske sidestørrelsen fra PDF-ens punkt-mål
  (`vp.width/RENDER_SCALE / 72 * 2.54`) og lagres som `bg.paperWidthCm/paperHeightCm`.
  `confirmFixedScale` bruker den når den finnes → 1:50 blir nøyaktig (A4-landskap 29,7×21 cm →
  1485×1050 cm). Raster-bilder (JPG/PNG) har ingen pålitelig fysisk størrelse → faller tilbake til
  150-DPI-antagelse som før.
- `_installBgImage(...,meta)` lagrer/nullstiller sidestørrelsen; rastersti uendret.

### Verifisert
- PDF (A4) 1:50 → 1485×1050 cm eksakt; raster 1:50 → 150-DPI-fallback; knappen vises i bg-ctxbar;
  2-punkts-kalibrering fungerer fortsatt. Ingen konsoll-feil.
- Merk: jeg klarte ikke å reprodusere en brutt 2-punkts-flyt — hvis «får ikke skalert» fortsatt
  skjer, trengs det konkret symptom (hvilken knapp, hva skjer).

---

## 2026-06-10 — Varmefolie: «lange strimler vegg-til-vegg» som default (mot fragmentering)

Snur folie-prioriteringen fra «maks dekning» til **få, lange, ensartede strimler vegg-til-vegg**,
med en bryter for de som vil ha maks dekning. Løser runde-2-folie-punktet (fragmentering i
uregelmessige/trappetrinn-rom) — og forbedrer samtidig folie-dekning i uregelmessige SONER.

### Rotårsak (fragmentering)
- `chooseBestProduct` byttet til SMALERE folie når en kolonne ble klippet <90 % (mot et
  trappetrinn) → patchwork av bredder.
- `_autoFillRoomOnce` lagde én strimmel pr. SEGMENT → en kolonne ble delt i hoved + kort topp-bit.
- `_scoreFoilLayout` maksimerte AREAL (straffet antall svakt) → «maks dekning» vant.

### Fiks
- **Strategi-flagg** `S.varmefolie.foilStrategy`: `'long'` (default) | `'coverage'`. Bryter i
  auto-plasserings-panelet («Lange strimler» / «Maks dekning»), `_setFoilStrategy` re-kjører.
- **`_autoFillRoomOnce(...,longMode)`**: ÉN ensartet bredde for hele rommet (ingen per-kolonne
  nedskalering), og ÉN strimmel pr. kolonne (lengste sammenhengende segment). Godtar litt udekket
  langs grunne/uregelmessige kanter.
- **`_longStripsLayout`**: prøver HVER ensartet bredde × begge sweep-ender, velger beste long-score
  → bredt for rektangel, smalere der bredt knapt får plass (L/arm-soner) → god dekning med få,
  lange strimler. Brukt av `_autoFillBothDirections` (default-stien) og `_fillSoneFoil`.
- **`_scoreFoilLayout` 'long'-profil**: maks dekket areal MINUS reell kostnad pr. strimmel (≈8 % av
  romarealet) og pr. ekstra breddetype (≈12 %) → en ekstra strimmel/kobling må «fortjene plassen»
  i dekning. Retning velges av denne scoren (lengste/færreste vinner).
- Når retning ikke er eksplisitt valgt: scoren foretrekker naturlig retningen med lengst strimler.

### Verifisert (numerisk; ingen konsoll-feil)
- Rektangel 400×300: long = 2 striper / 1 bredde / 91 % vs coverage = 3 / 2 bredder / 94 %.
- Trappetrinn-rom: long = 2 / 1 / 87 % vs coverage = 3 / 2 / 94 %.
- L-formet sone (Vindfang Sone 2): long = **57 %** (2 striper) — bedre enn coverage 43 %, og fikser
  en mellomliggende 27 %-regresjon (bredeste-uniform alene).
- «Maks dekning»-bryter gir dagens tettere/mer oppdelte layout (eksisterende motor uendret).
- Vanlig rom-folie i coverage-modus uberørt; `computeClippedSegments`/`_autoFillRoomOnce`-tillegg
  bakoverkompatible.

### Ikke gjort (informativt, ikke blokkerende)
- Eksplisitt markering «trenger tilførsel fra begge ender / skjøt» for svært lange strimler er
  ikke lagt til (antall striper i panelet = antall tilkoblinger; ingen hard produkt-maks kjent).

---

## 2026-06-10 — SONER: del et rom i navngitte utleggingssoner (Kjerne)

Ny feature: del ett rom i flere SONER med delelinjer, fyll folie pr. sone med individuell
retning og per-kant margin. Scope «Kjerne først» + rette delelinjer vegg-til-vegg (bekreftet
med bruker). Bygger på eksisterende sone-/folie-infra. Verifisert numerisk + visuelt på ekte
Bloksbergveien/Vindfang og syntetiske rom; ingen konsoll-feil; ingen regresjon på vanlig
rom-folie.

### Datamodell
- Ny `type:'sone'` i `S.zones`: `{id,roomId,type:'sone',name,points,direction,startCorner}`.
  Holdt UTENFOR alle `type==='forbidden'/'preferred'`-filtre (de matcher ikke 'sone') → kabel/
  folie-constraints uberørt (verifisert).
- Folie-strimler får `zoneId` (null for vanlig rom-folie).

### Opprettelse — «Del i soner» (rett delelinje)
- Ny modus (ctxbar-knapp på valgt rom): klikk to vegger → endepunkter snappes til rom-/
  sonegrensen → **robust polygon-split langs korde** (`_splitPolygonByChord`) deler rom-
  polygonet (eller sonen linja krysser) i to. Sonene PARTISJONERER rommet (verifisert: rektangel
  → 2× lik areal; gjentatt split → N soner uten hull/overlapp; sum sone-areal = romareal).
- Auto-navn «Sone N» (redigerbart via ctxbar). Render: indigo soner med navn + retningspil.

### Valg + ctxbar/info pr. sone
- `hitZone`/`selectZone` virker for 'sone' (hit-rekkefølge: strip→cable→zone, så strimler inni
  kan fortsatt velges). Ctxbar: navn-redigering, «+ Produkt», per-sone retning (↕/↔), slett,
  areal + effekt + dekning. Info-panel: «Utleggingssone», retning, areal, effekt, dekning.

### Folie pr. sone + PER-KANT margin (kjernen)
- «+ Produkt» på en sone ruter til `_fillSoneFoil`: fyller KUN sonen, i `zone.direction`,
  strimler tagges `zoneId`. Erstatter sonens eksisterende folie.
- **Per-kant margin** (`_zoneFillablePolygon` + `_offsetPolygonPerEdge`): hver sonekant
  klassifiseres — ligger på en romvegg (yttervegg) → veggmargin (`_effectiveMarginCm`); delt
  grense (delelinje) → halv folie-gap (`_effectiveGapCm/2`). Sone-polygonet insettes per kant,
  og fylles med margin 0 (ingen dobbel-inset). Verifisert eksakt: yttervegg inset 2,5 cm, delt
  grense 1,5 cm.
- Motor-utvidelse (bakoverkompatibelt): `computeClippedSegments(...,opts{marginCm,clipPoly})` og
  `_autoFillRoomOnce(...,marginCm)`. Vanlig rom-folie uendret (regresjonstestet: 94%/92%).

### Stats / sletting
- `_soneStats` (areal, effekt W, W/m², dekning %, strip-antall) vist i ctxbar + info-panel.
  Rom-total inkluderer sone-strimler (de har `roomId`) → sum pr. rom = sum soner.
- Slett sone fjerner også sonens folie.

### Resultat / begrensninger
- Rektangulære soner (hovedscenario): 600×400 → 4 soner à 6 m², vekslende retning, **91–92 %
  dekning**, perfekt partisjon.
- **Utsatt til runde 2:** (1) folie-dekning på UREGELMESSIGE soner (L/arm) er svak — den greedy
  `_autoFillRoomOnce` får ikke brede folier over arm-grenser (Vindfang Sone 2 ~43 %); (2) sone-
  navn kan få nummer-hull etter gjentatte splitter; (3) hindringer inne i en sone subtraheres
  ikke i sone-fyllet; (4) kabel/matte pr. sone; (5) PDF/materialliste pr. sone; (6) polyline-
  delelinjer; (7) sammenslåing/flytting av delelinjer.

---

## 2026-06-10 — Hindring: fri plassering + mykt vegg-snap (clampHindringToRoom omskrevet)

- **Symptom:** hindringer (f.eks. kjøkkenøy i Rom 6) kunne ikke plasseres fritt — de ble dratt mot
  en vegg «midt i rommet», som om det fantes forbudte soner. Reprodusert: en hindring midt i Rom 6
  (42-punkts, konkavt, langt fra alle vegger) ble flyttet **233 cm** for å snappe mot en vegg.
- **Rotårsak:** `clampHindringToRoom` (~19788) snappet flush ut fra signert avstand til veggens
  UENDELIGE LINJE og valgte veggen med STØRST avstand innenfor rekkevidde → falskt snap i
  komplekse/konkave rom. Containment og snap var sammenblandet i ett steg.
- **Fiks — to ATSKILTE steg:**
  1. **Containment (alltid):** ekte polygon-test — `ptInPoly` på hindringens hjørner + nærmeste
     punkt på rom-grensen; translerer hele hindringen minimalt inn kun når et hjørne faktisk er
     utenfor (itererer for flere brudd). Ikke per-vegg-linjeavstand.
  2. **Mykt vegg-snap (kun ≤5 cm fra segmentet):** krever tangentiell overlapp med vegg-SEGMENTET
     (hindringen ligger langs segmentet, ikke nær dens forlengede linje), velger FAKTISK NÆRMESTE
     vegg (minste avstand, ikke størst), og snapper flush kun når 0 < avstand < HINDRING_SNAP_CM
     (5 cm). Ellers fri plassering.
  - Ingen snap til andre hindringer/soner (kun `room.walls`). Grid-snap i `_dhDragging` og
    `_hwMoving`-kallerne uendret.
- **Verifisert (ekte Rom 6 + rektangel, numerisk + visuelt):** midt i rommet → 0 cm (var 233);
  3 cm fra vegg → snap flush; 8 cm fra vegg → fri; 200 cm utenfor → contained inn; rektangel
  3/8 cm → snap/fri. Skjermbilder: øy fritt mellom benkene + øy snappet flush mot vegg.

---

## 2026-06-10 — Varmekabel: auto-retning foretrekker den RENE retningen (boustrophedon-fyll)

Lett alternativ til en risikabel V6-vertikal-omskriving: i stedet for å pusse på den delte
V6-koblingsmotoren, lar vi auto-retning styre brukeren mot den rene retningen.

- **Bakgrunn:** på et utstikker-rom (L/T med horisontal arm, f.eks. Vindfang) finnes en ren
  enkelt-serpentin (boustrophedon, 0 koblinger) bare langs armen (horisontalt). Vertikalt finnes
  den ikke (stort `openLen`-hopp) → kun V6 med kobling. Eksplisitt vertikalt valg er brukerens
  rett, men AUTO bør lande på den rene retningen.
- **Fiks (cascade, boustrophedon-blokk i `_autoFillCableImpl`):** blant gyldige retninger spores nå
  `bFill` = beste som også FYLLER kabelen godt (≥90 %), og `bChosen = bFill || bBest` velges. Når
  en retning gir ren, godt-fyllende boustrophedon, vinner den framfor en underfyllende. Påvirker kun
  AUTO (uten eksplisitt valg) — `dirs` har da begge retninger; ved eksplisitt valg er `dirs` kun den
  ene, så brukerens valg overstyres aldri.
- **Verifisert (Vindfang):** AUTO → boustrophedon 'h', 0 koblinger, ren; eksplisitt 'h' → ren
  (uendret); eksplisitt 'v' → fortsatt v6 (valg respektert); rektangel AUTO → boustrophedon, ingen
  regresjon.

---

## 2026-06-10 — Varmekabel: L/T-rom horisontalt blir ren boustrophedon-serpentin + 5 cm perp-margin

Fortsettelse på Vindfang (Bloksbergveien/Hybel). To uavhengige fikser, begge verifisert på ekte
rom og målt numerisk + visuelt.

### Fiks 1 — boustrophedon `_solve`: robust CC-sveip i stedet for biseksjon
- **Symptom:** L/T-rom horisontalt ga en stygg V6-celle-layout: ett løp med tettere CC, kantete
  (ikke-buede) svinger, en Y-split der et koblings-bein lå 4,4 cm fra et løp (<5 cm), og en rar
  kantet strek før svingen. Rotårsak: V6 deler rommet i 3 bånd med polyline-**koblinger**.
- **Hvorfor V6 i det hele tatt ble valgt:** den rene motoren (boustrophedon) lager én
  sammenhengende serpentin med bue-svinger + jevn CC, men `_solve` brukte **biseksjon**, som antar
  at `_layout`-gyldighet er monoton i CC. På L/T er den **ikke-monoton** (gyldig ved 9 cm, null ved
  12 cm, gyldig ved 15 cm — celle-handoff `openLen`-sjekken). Biseksjonen spratt da til CC 39,9 cm
  → bare 15,6 m av 50 m → cascadens `fillOk`-terskel (≥90 %) falt til V6. (Dette var den samme
  «15,6 m»-underfyllingen fra tidligere økter — nå endelig forklart.)
- **Fiks:** erstattet biseksjonen med et grovt CC-sveip (0,25 cm steg) over hele området + lokal
  forfining rundt beste CC. Robust mot de ikke-monotone null-hullene; finner alltid den GYLDIGE
  layouten nærmest target-lengde.
- **Resultat (Vindfang H, InFloor 10T 500W 50 m):** boustrophedon vinner nå (var v6), CC jevn
  9,9 cm overalt, **0 koblinger** → alle U-svinger er halvsirkel-buer, ingen Y-split, ingen
  tett-løp, ingen kantet koblings-strek; 48,8 m, 87 %, min vegg-avstand 5,49 cm; start/slutt i
  hjørner. Bekreftet visuelt.
- **Begrensning:** vertikal retning på dette rommet finnes ikke som ren enkelt-serpentin (armen
  stikker ut horisontalt → stort `openLen`-hopp), så vertikal bruker fortsatt V6. Horisontal er
  den naturlige retningen for et slikt rom.

### Fiks 2 — `_generatePolygonClippedRuns`: perp-margin fra indre parallelle vegger
- **Symptom:** øverste streng i venstre arm lå 0,7 cm fra ytterveggen (brøt hard 5 cm).
- **Rotårsak:** funksjonen insettet kun løpenes ENDER (sweep-aksen). En INDRE step-vegg parallell
  med løpene (armens topp/bunn-kant, usynlig for det ytre posisjon-rutenettet) fikk ingen
  perp-margin. (Promptens `_fillCellSerpentine` var død V5-kode — ikke i live-stien.)
- **Fiks:** masker hvert løp med rom-klipp ved `pos ± margin` (rå klipp, ingen sweep-inset). Der
  rommet ikke strekker en full margin i perp på en side, ligger man <margin fra en parallell vegg
  → klipp bort. Tom-vakt for ytre ekstremer (allerede dekket av posisjon-rutenettet). Lik CC
  beholdt; litt mer udekket inntil veggen (OK).
- **Resultat:** global min vegg-avstand 0,7 → 5,03 cm (H) / 9,58 cm (V). Gjelder fortsatt V6-stier
  (vertikal/hindringer). Rektangler uendret (boustrophedon-stien urørt).

### Verifisering / ingen regresjon
- Rektangler (300×200/54 m, 250×200/29 m, 400×300/54 m): boustrophedon, jevn CC, lengde nær target.
- LOCKED-regler urørt (halvsirkel-U, lik-lengde innen serpentin, ingen Y-split, sweepMargin).

---

## 2026-06-10 — Varmekabel: V6 honorerer valgt RETNING (dirExplicit) — fikser «velger horisontalt, legger vertikalt»

Diagnostisert og fikset på ekte prosjekt **Bloksbergveien → etasje «Hybel» → rom «Vindfang»**
(T/L-rom: høy høyre-rektangel med horisontal arm til venstre, InFloor 10T 500W 50 m).

### Rotårsak
`generateCableV6` kjørte sitt interne auto-retningsvalg (`_quickTry('v')` vs `_quickTry('h')`,
~linje 9925) **ubetinget** og overstyrte den passerte retningen hver gang én retning dekket
>2 % mer. På Vindfang dekker vertikal litt mer, så et eksplisitt **horisontalt** valg ble
stille flippet tilbake til **vertikal** → «jeg velger horisontalt, men den legger vertikalt».
(Den gamle 15,6 m-underfyllingen var en annen sti — boustrophedon — som ikke lenger velges.)
`_autoFillNCables` respekterte allerede `dirExplicit`; V6 gjorde det ikke.

### Fiks
- I `generateCableV6`: ny `_dirLocked`-vakt rundt auto-retningsblokken. Retning låses (ingen
  auto-flip) når brukeren bevisst valgte den (`S.varmefolie.dirExplicit` + gyldig `h`/`v`)
  ELLER når en multi-kabel-sone tvinger orkestratorens retning (`room._forcedSpacingCm`).
  Ellers auto-velg ved best dekning som før.
- Bonus: `_forcedSpacingCm`-låsen gjør multi-kabel-soner retnings-konsistente (en sone kunne
  før stille rotere via V6s interne flip og bryte parallell-tiling).

### Verifisert (in-memory, autentisert fane, lagring nøytralisert)
- **Vindfang request 'h' → får 'h'** (v6, lik CC 8,8 cm, 50 m = produktlengde, **86 % dekning**
  vs vertikal 81 %, 2 ortogonale koblinger, start/slutt i ekte hjørner). Visuelt bekreftet:
  ren horisontal serpentin, ortogonal innhugging rundt innerhjørnet, ingen diagonal/Y-split.
- **Vindfang request 'v' → får 'v'** uendret (50 m, 81 %).
- **Multi-kabel** (rektangel, 2 soner): request 'h' → begge 'h'; request 'v' → begge 'v';
  lik CC + lik lengde i begge soner. Ingen regresjon.
- Auto-modus (dirExplicit=false): auto-flip beholdt uendret.
- LOCKED-regler urørt: halvsirkel-U, lik-lengde innen sone, ingen Y-split.

---

## 2026-06-09 — Varmekabel: retningsvelger reapply + L-diagonal + rektangel-hjørne

Tre sammenhengende kabel-forbedringer rundt retnings-/hjørnevalg. Commits: `bc0d773`,
`6dee009`, + denne (rektangel-hjørne). Verifisert in-memory i autentisert fane.

### Del A — retningsvelger re-kjører eksisterende/forhåndsvist kabel (`bc0d773`)
- Ny `_reapplyCableDirection` (nær `_cableFlipDirection`): når brukeren endrer retning/hjørne
  i pickeren, re-kjøres umiddelbart aktiv forhåndsvisning (`_cablePreviewPlace`), commitet
  enkelt-kabel (`autoFillCable`) eller multi-kabel-gruppe (`autoFillMultiCable`) i den nye
  retningen.
- Wiret inn i begge pickere (`_vfDirEvt`, `_vfPickEvt`) via en endrings-guard:
  re-kjør bare når `snap.dir`/`snap.corner` faktisk endret seg.
- `_cablePreviewMeta` utvidet med `familyName`, `categoryId`.

### Del B — fjernet vertikal L-diagonal (ortogonal kobling langs innerveggen) (`6dee009`)
- I `_v6ConnectCells` (live V6-cellekobling): når exit/entry ligger på forskjøvne sweep-nivåer
  rutes koblingen nå **ortogonalt** langs innerhjørnet i stedet for en diagonal snarvei.
  `_covers` finner cellen som spenner hele sweep-området; bias 0.7 mot dens grenseløp;
  `mk(bPerp, sweep)` bygger en 4-punkts ortogonal sti; obstacle-validert med fallback til
  rett `[exitPt, bestEntry]`. Bevart 50 m, ingen regresjon på horisontal (dx:0/dy:13),
  rektangel fortsatt boustrophedon (49,4 m).
- Samme fiks også speilet i den døde `_connectCellPathsV5` (uskadelig, ikke i live-cascade).

### Punkt (a) — rektangel-boustrophedon honorerer valgt starthjørne (denne commit)
- I `generateCableBoustrophedon` → `_layout()` (variant-utvelgelsen): når
  `S.varmefolie.dirExplicit && startCorner` er satt, **hard-filtreres** de fire traverserings-
  variantene (`perpAsc × startHigh`) til den som lander på valgt hjørne — i stedet for det
  gamle myke +0,5-tiebreaker-nudget. Tracker `bestForced` ved siden av `best`; bruker
  `bestForced` når det finnes, ellers trygg fallback til ufiltrerte beste.
- Auto-modus (ingen bevisst valg) helt uendret — motorens selvvalg beholdes.
- Bakgrunn: rektangler bruker boustrophedon, som internt selv-velger starthjørnet i
  `_layout`s 4-variant-søk. Tidligere talte picker-hjørnet bare som +0,5 og ble overdøvet av
  hjørne-landing-bonus (opptil 8/ende) → valgt hjørne ble ignorert på rektangel. Nå honoreres
  det. Samme `dirExplicit && userCorner`-mønster som V6-fiksen (`a2ee83e`).
- **Verifisert:** parser OK; alle 8 hjørne×retning-kombinasjoner gir nøyaktig valgt hjørne;
  overstyring bevist (motorens naturlige selvvalg `tl` → eksplisitt `tr` gir `tr`, `br` gir
  `br`); kabellengde stabil (~59,9 m), ingen LOCKED-regel berørt.

---

## 2026-06-08 — ØKT-OPPSUMMERING: snøsmelting fullført + matte-pakkemotor

Stor økt: fullførte utendørs snøsmelte-modulen (steg 1–8), konsoliderte produktvelgeren
(snø + innendørs deler nå én UI + én motor), og bygde en matte-pakkemotor for InSnow 300T.
Alt verifisert i preview-server `romtegner` (dev-login `?dev`) og **deployet via Vercel**.
Commits: `06b2acf`, `92d682c`, `57d74be`, `a80652b`, `81d79c4`, `48bdc93`, `6242729`,
`49f54aa`, `536947b`, `0c97e0b`, `7db1513`, `05d0efb`, `e36a335`.

### Snøsmelting-modul fullført (steg 1–8)
- **Ekte InSnow 300T-matter i DB** (`_ensureOutdoorMatProducts`): erstattet placeholder
  `CVA20001–20016` med 32 ekte faste-størrelse-matter (17× 230V `CVA106xx` + 15× 400V fra
  Cenika produktblad 05/2025), bredder 0,5/1,0 m, `mat_total_length_mm` → fast-lengde-modell.
- **`_moduleContext()`** — datadrevet modul-forskjell (wm2Default, ccMaxCm, roomWord,
  hindringTypes, hasScreed). `_roomWord`/`_roomTargetWm2`/maks-CC rutet gjennom det.
- **Effektbehov** (`SNOW_USAGE` 250/300/350 + `_snowUsageWm2` + bruksområde-velger).
- **Delt produktvelger (UPC):** snø ruter nå til `showUnifiedProductPanel` (samme som
  innendørs) via `openProduktMenu`/`showCablePlacePanel`/auto-åpning. UPC modul-bevisst
  (snø=kun utendørs InSnow, innendørs=ekskluder utendørs). Header «Bruksområde» (snø) vs
  «Romtype» (inne). Gammelt flytende snø-panel nøytralisert.
- **Multi-kabel via `_buildNCableZones`** (samme motor som innendørs; LOCKED-regler).
- **Spenningsfilter** rettet (6 steder buggy `name.startsWith` → trygt `product_family`-
  mønster); «InSnow 30T» drar ikke lenger inn 400V.
- **Bugfix:** `maxCCmm is not defined` krasjet info-panelet ved valg av snø-kabel; rettet +
  korrekt snø-maks-CC 300mm via modul-kontekst. Fjernet foreldet «Avretning»-input i snø.
- **Steg 8:** fjernet 465 linjer død gammel snø-sti (`_renderSnowSettingsPanel`,
  `showSnowProposals`, `_snow*`-forslag/preview). Beholdt `_updateSnowSettingsPanel` som shim.

### Produktvelger UX (begge moduler, delt)
- **Dokket panel** (`_dockRwp`): `#room-workflow-panel` ligger nå eksakt over venstre sidebar
  (position:fixed, følger sidebar-bredden) i stedet for oppå griddet → forhåndsvisning fri.
- **Chip/nedtrekk-hybrid:** Produkttype + Effekt-klasse + Spenning + Bruksområde som chips;
  Romtype beholdt som nedtrekk. Splittet familie-nedtrekket i klasse+spenning (`_familyKlasse`,
  `_upcState.klasse/voltage`, voltage-filter i resultatrenderne).
- **Matte-variant forhåndsviser areal:** klikk en variant → eksakt matte legges ut (byttbar),
  via `autoFillMatSerpentine(productId, {exact, keepPanel})`.

### Matte-pakkemotor (`_packSnowMats`) + 4 oppfølgingspunkter
- **Pakkemotor:** legger InSnow 300T-matter i LENGDERETNINGEN, kombinerer ende-til-ende
  per kolonne (k=floor(L/ℓ)), N kolonner på tvers med ~10cm gap + 15cm udekket kant, og
  fyller rest på tvers (rotert 90°). Hver fysiske matte = ett `S.mats`-objekt. Auto velger
  bredeste+lengste (færrest stk). Verifisert mot Cenika-fasit: Sone 1 (4,6×25, 1×20m) →
  5× 1×20m; Kenneths variant (kun 1×12m) → 8× 1×12m + 1× 0,5×8m.
- **Punkt 1 — watt-fix:** `_matRatedW` = produktets ratede effekt pr. fysisk matte (ikke
  laid geometri × num_runs). Brukt i `_computeRoomStats`, sidebar-tre, specRows, PDF-eksport,
  materialliste. Sone 1 = 30000W korrekt (var feilaktig per-løp).
- **Punkt 2 — Bruk/Avbryt:** snø-matter legges som preview (`room._matPreviewIds`); «Bruk»
  committer, «Avbryt» fjerner, bytte swapper. Speiler kabel-preview-flyten.
- **Punkt 3 — rekursiv rest:** rest fylles med flere tverr-bånd til leftover < 40cm. Sone 2
  (4,6×26,5) → 5× 1×20m + 1× 0,5×12m, full dekning.
- **Punkt 4 — fargekoding:** `MAT_COLORS` (8 farger) pr. fysisk matte i `drawMats`;
  materialliste med matchende fargeprikker. Enkeltmatte-rom uendret (`_matColor` → null).

Status: alt deployet. **Restpunkter/notater:** Sone 2-rest er forenklet (ett lengde-ish +
ett kryss-bånd, ~PDF men ikke byte-identisk Cenika-kombo); trapp-modulen + klimasone-tabell +
auto-spenning + styring/følere er utenfor scope (ikke startet).

---

## 2026-06-05 — ØKT-OPPSUMMERING: multi-kabel-motor (varmekabel)

Samlet arbeid på multi-kabel-utlegg denne økta (detaljer i oppføringene under). Commits:
`96dd460`, `825940d`, `0b06e87`, `6d006d9`, `e6906bd`, `4e51fa2`, `b08072d`, `f129876`.

- **Retning etter dekning** + picker-bias; **↻ Retning** snur hele gruppa.
- **Delt sone (hakk/døråpning) = ugyldig løsning** — auto velger den aldri, tvang nektes.
- **Full gavl-dekning** i vertikal modus (skew-kabler godtas, ikke lenger forkastet).
- **Lengde-klamp**: ingen kabel > produktlengde (trimmer sveip, aldri CC).
- **Tette half-CC-sømmer** mellom soner.
- **NØYAKTIG lik CC i alle soner** (felles CC → lik flateeffekt i hele rommet).
- **Manuelt valg «Like soner» / «Korridor»** for 2 kabler; samme motor/regler for alle 2+.

Status: alt deployet via Vercel. Restpunkt: ingen kjente. Merk testrom `__TESTGARD__` kan
ligge igjen i BIV6-prosjektet (slettes manuelt).

---

## 2026-06-05 — Multi-kabel: manuelt valg «Like soner» / «Korridor» (2+)

Brukerønske: ha BEGGE multi-kabel-layoutene med et manuelt valg. Tidligere brukte 2 kabler en
egen korridor-sti (felles startpunkt + lead-run) og 3+ en annen (like soner) — inkonsistent.

- **To moduser** via `autoFillMultiCable(roomId, productId, n, forcedDir, mode)`:
  - **`soner`** (standard) → den forente `_buildNCableZones`-motoren, håndterer nå **2+**
    (felles CC, like soner, split-ugyldig, retningskontroll, lengde-klamp, søm-pinning, skew).
  - **`korridor`** → lead-run-sti med felles startpunkt ved termostat. **Kun for 2 kabler**;
    3+ med korridor-forespørsel faller automatisk til soner.
- `S.varmekabel.multiCableMode = 'soner'` (standard, huskes pr. økt). Kablene tagges
  `multiCableMode`.
- **UI:** ny ctxbar-toggle «▦ Like soner» / «🚇 Korridor» ved siden av «↻ Retning», vises KUN
  for 2-kabel-grupper (skjult ved 3+). `_cableToggleMultiMode()` kjører gruppa på nytt i valgt
  modus. `_cableFlipDirection` bevarer nå modus.

Verifisert (Garderobe herrer): 2-soner → lik CC 19,81, ingen lead-run; 2-korridor → lik CC
19,81 + felles startpunkt + lead-run; 3-korridor → faller til soner (CC 13,21). Enkeltkabel
uendret. LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: NØYAKTIG lik CC i alle soner (lik flateeffekt)

Kenneths prioritering: lik CC i alle soner (lik W/m²) > eksakt veggmargin. CC spriket før
mellom sonene (14,2/11,7/13,2) fordi hver sone regnet sin EGEN CC, og vertex-snapping
ubalanserte arealene.

- **Én felles CC** regnes én gang i `_buildNCableZones`:
  `sharedCC = clamp(nettoTotal_m2 / (N·cable_length_m) · 100, minSp, maxSp)`, og settes som
  `tempRoom._forcedSpacingCm` på hver sone.
- **Motorene tvinges til felles CC:** `generateCableBoustrophedon._solve`, `generateCableSkew`
  og `generateCableV6` (inkl. V6 stage-7 lengde-opt hoppes over) bruker `_forcedSpacingCm` i
  stedet for å utlede CC fra delroms-arealet.
- **Like arealer:** droppet `_snapBoundsToVertices` for multi-kabel — like-areal-kuttet er nå
  styrende (lik areal → lik lengde → lik CC virker). Motorene takler uregelmessige delrom.
- **Resten absorberes i sveip-margin, aldri i CC:** `_trimCableToLength` trimmer sveip-
  utstrekningen (sving-til-vegg) ned til produktlengden; half-CC-pinning ved sømmene beholdes.

Verifisert (Garderobe herrer, vertikalt): alle tre kabler **CC 13,21 cm** (var
14,2/11,7/13,2), lengder 182,7/183/183 m (alle ≤ 183), ~128 W/m² ≈ måltall 129. Enkeltkabel
+ 2-kabel + rektangulære rom upåvirket. LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: godta skew-kabler (full gavl-dekning i vertikal modus)

Gavl-sona i vertikal modus ble underfylt (serpentin-fallback ~130 m av 183 m). Årsak:
`_buildNCableZones` sjekket kun `cable.runs.length`, men **skew-motoren lagrer banen i
`pathEls`, ikke `runs`** — så en gyldig skew-kabel ble forkastet og falt til serpentin.

- Ny `_cableHasGeom(cable)` = har `runs` ELLER `pathEls`. Brukt i alle tre stedene
  `_buildNCableZones` sjekket «har kabelen geometri» (fallback-trigger, sluttsjekk).
- Dekningsscoren bruker `cable.coverage` for skew-kabler (ingen runs å summere).
- Split-deteksjon/pin/trim hopper trygt over runs-løse skew-kabler.

Verifisert (Garderobe herrer, vertikalt): gavl-sona K1 = skew **181,6 m** (var serpentin
130 m), K2/K3 boustrophedon 182,3/183 m — alle ≤ 183 m, full gavl-dekning, fargekodet riktig.
LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: delt sone = ugyldig løsning (ikke bare straffet)

Etter brukerkrav: «hvis en sone blir delt i to, så må det bli et ugyldig løsning». Oppgraderte
split-håndteringen fra en myk score-straff til en HARD ugyldighet.

- `_buildNCableZones` måler nå split-andelen PER SONE (verste sone) og returnerer `invalid:true`
  når en sone har ≥30 % strenger brutt i ≥2 segmenter (en void/hakk deler sona fysisk).
- `_autoFillNCables` dropper alle ugyldige retninger. Finnes ingen gyldig retning → returnerer
  null (ingen fallback til en delt layout; auto-fyll kan da prøve færre/større kabler oppstrøms).
  Tvinger man en delt retning (↻ Retning), returneres null → knappen nekter med toast.

Verifisert (Garderobe herrer): auto → 'v', tvunget 'v' → 'v', tvunget 'h' → null (toppsona
deles av døråpningen). LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: retningskontroll + split-sone-straff

Bruker meldte at horisontale soner var uegnet der en døråpning/hakk fysisk DELER den øverste
sona i to (kabelen må bro over hakket), og at man ikke fikk valgt retning.

- **Split-sone-straff i `_buildNCableZones`-scoren.** Teller strenger som er brutt i ≥2
  segmenter (= en void/hakk deler sona). Auto-retningsvalget trekker fra `0.6 × split-andel`
  fra dekningsscoren → for et rom der et hakk deler det horisontale topp-båndet (mange
  splittede strenger) velger auto nå VERTIKALE soner i stedet. Verifisert på Garderobe herrer:
  'h' gir K1 med 20/31 splittede strenger (score 0,88→0,69), 'v' gir 0 splittede (0,86) → auto
  velger 'v'.
- **Tvunget retning:** `autoFillMultiCable(roomId, productId, n, forcedDir)` →
  `_autoFillNCables(..., forcedDir)` bygger kun den retningen (hopper over auto-valget).
- **`↻ Retning`-knappen** (`_cableFlipDirection`) håndterer nå multi-kabel-grupper: i stedet
  for å flippe én kabel kjøres HELE gruppa på nytt i motsatt retning (tvunget) og erstattes,
  så sonene re-orienteres samlet. Verifisert: v→h→v gir samme layout tilbake, ingen feil.

LOCKED kabelregler urørt; enkeltkabel + 2-kabel upåvirket.

---

## 2026-06-05 — Multi-kabel: lengde-klamp (≤ produktlengde) + V6-søm-pinning

Avdekket på det FAKTISKE rommet (Garderobe herrer, H7 gt5) at multi-kabel-utlegget hadde
to feil som det syntetiske testrommet ikke fanget: (1) K2/K3 krevde **186,6/186,5 m** av en
**183 m**-kabel — fysisk umulig; (2) gavl-sona (V6) sin søm-kant lå **22 cm** fra kuttet.

- **`_trimCableToLength(cable, targetCm)`** — ingen kabel kan kreve mer enn produktlengden.
  Ved overskudd (diskret strengantall bommer oppover) kortes strengene ved å trimme sweep-
  endene, fordelt PROPORSJONALT med hver strengs kapasitet (lange strenger gir mest, korte
  gavl/topp-strenger urørt → like-spenn-strenger trimmes likt, så celle-lik-lengde beholdes).
  Perp-posisjoner urørt → sømmene flytter seg ikke.
- **`_pinCableSeamToCut(...)`** — for motorer som ignorerer `_cableSeam` (V6/skew/serpentin på
  en uregelmessig yttersone): skyv ALLE strenger likt langs perp-aksen så søm-kanten havner
  halv-CC fra kuttet → én CC over sømmen. Kun yttersoner (én søm), klampet så veggsiden
  beholder ≥ margin.
- Begge kalles i `_buildNCableZones` etter at hver kabel er bygd (før push/dekningsmåling).

Verifisert: Garderobe herrer → K1 182,8 / K2 183 / K3 183 m (alle ≤ 183), sømmer 13/14 cm
(K1|K2 22→13), dekning 88 %. Rektangel → 179,4 m hver, sømmer 15/15, 96 %. Enkeltkabel +
2-kabel upåvirket (klamp/pin kjører kun i N≥3-stien). LOCKED kabelregler urørt.

---

## 2026-06-05 — Multi-kabel: tette sømmer (halv-CC delte vegger) + picker-retning

Etter Kenneths modell: 3 like soner, hver kabel legges normalt, men **veggen som deles
med nabosona er halv-CC** → full CC mellom siste streng i sone N og første streng i sone
N+1 (ingen kald stripe). Samme prinsipp som to-kabel-stien allerede bruker (`boundaryEdge`).

- **Seam-bevisst streng-plassering i `generateCableBoustrophedon`.** Nytt `room._cableSeam`
  `{min,max}` (settes kun på midlertidige delrom). En kant som deles med en nabokabel er
  IKKE vegg: ytterste streng pinnes eksakt halv-CC fra kuttet, og resten (slack) legges mot
  ekte vegg. **Kantsoner** (én søm) pinnes; **midtsona** (to sømmer) beholder liten
  veggmargin + sentrering — halv-CC-margin på begge sider der ville droppet en streng og
  blåst opp resten (løsere sømmer). Enkeltkabel uendret (`_cableSeam` udefinert → identisk
  sentrert layout).
- **`_buildNCableZones`** markerer hver delroms-kant som søm (`min: i>0`, `max: i<N-1`).
- **Retning følger picker:** `_autoFillNCables` biaser mot `S.varmefolie.direction`
  (retningsvelgeren) men prøver fortsatt begge og bytter kun ved klar deknings-gevinst
  (>2 %) — så et bevisst valg/uavgjort (rektangel) æres, mens default 'v' som ville latt en
  gavl stå udekket likevel flipper til 'h'.

Målt: GABLE-rommet K2|K3-søm **19 → 14 cm** (ideal 13), K1|K2 14 cm; RECT 15/15 (ideal
13,1) — ~1,5–2 cm over ideal (uunngåelig hårfin rest når sonebredde ≠ multiplum av CC ved
låst kabellengde). Dekning 93–96 %. LOCKED kabelregler urørt; enkeltkabel + 2-kabel uendret.

---

## 2026-06-05 — Multi-kabel: velg retning etter dekning (gavl/hakk-rom)

- **`_autoFillNCables` velger nå kjøreretning etter total dekning, ikke bare
  `_suggestDirection`.** Den gamle koden låste alltid dominansretningen. På et rom med
  skrå gavl (f.eks. Garderobe herrer, 72,5 m²) ga VERTIKALE kutt et helt udekket delrom
  (gavlen → motoren «skew» → 0 %, samlet 61 %), mens HORISONTALE topp/midt/bunn-bånd
  isolerer gavlen i ett bånd og tiler resten rent (80 % / 94 % / 97 % → samlet **93 %**).
  Refaktorert: ny `_buildNCableZones(room, productId, prod, n, dir)` bygger N like-areal
  delrom for ÉN retning og returnerer `{cables, score}` (areal-vektet dekningsgrad);
  `_autoFillNCables` kjører den for BEGGE retninger og beholder den beste (med liten
  hysterese mot dominansretningen så vi bare bytter ved klar gevinst). Beholder snapping
  til verteks, konsistent retning for alle delrom, serpentin-fallback og aldri-dropp.
  Verifisert på den eksakte Garderobe-geometrien: 61 % → 93 %, 3 kabler, alle 'h'.
  RESTPUNKT: tynne kalde sømmer mellom båndene (hvert bånd holder veggmargin mot kuttet);
  halv-CC-stramming ved sømmene gjenstår som egen oppgave. LOCKED kabelregler urørt;
  enkeltkabel + rektangulære rom uendret.

---

## 2026-06-05 — Multi-kabel: rene delrom uten udekket trekant

- **Rene delrom — snap kutt til verteks + konsistent retning + deknings-retry.**
  `_autoFillNCables` forbedret etter prompt-kabel-multi-rene-soner: (1) **Smartere
  kuttlinjer** — ny `_snapBoundsToVertices` snapper hvert like-areal-kutt til nærmeste
  rom-verteks-perp-koordinat innenfor toleranse, så hvert delrom blir mest mulig
  REKTANGULÆRT (isolerer hakk/skråvegg i ett delrom i stedet for å kutte tvers gjennom
  → fjerner den udekkede trekanten i midten). (2) **Konsistent retning** — kjøreretningen
  låses til rommets dominansretning for ALLE delrom via `S.varmefolie.direction` (forced
  dir), så `autoFillCable` ikke re-velger pr. delrom → alle strenger parallelle. (3)
  **Deknings-sjekk** — ny `_cableCoverageFrac`; hvis et delrom dekker <90 %, prøv alt-
  retning og behold den beste; serpentin-fallback hvis fortsatt tomt (aldri stille dropp).
  Verifisert: L-hakk/notch → 3 kabler, samme retning, ~96 % dekning, kutt snappet til
  notch-verteks; skråvegg-gavl → rene rektangler + isolert trapes-rest (uunngåelig pr.
  LOCKED lik-strenglengde). LOCKED kabelregler urørt; enkeltkabel + rektangulære rom
  uendret.

---

## 2026-06-04 — Varmekabel: manuelt valg i RIKTIG panel

- **`55d4a8c` — Manuell-seksjon + dekning% + preview lagt i det LIVE panelet.** Forrige
  runde la manuell-valget i `_updateCableSelection`, men panelet brukeren faktisk ser (RWP
  unified product picker) er `_upcRenderCableResults` (`#upc-results`) — derfor var det
  «borte». Nå i `_upcRenderCableResults`: «✋ Manuelt»-seksjon (type-dropdown + antall-
  stepper + Forhåndsvis) høyt (etter forslag, før «Flere kabler»), dekning% + effekt-merke
  på opsjonene, og preview-før-commit. Ny `_refreshCablePanel` oppdaterer riktig panel.

---

## 2026-06-04 — Varmekabel: synlig manuelt valg + fargekoding

- **`4f0e52f` — Manuell-seksjon flyttet opp + fargekod hver kabel.** (A) «✋ Manuelt — velg
  type + antall»-boksen flyttet OPP (rett etter «Nærmest», før den lange «Flere kabler»-
  lista) → synlig uten å scrolle. (B) Ny `INDOOR_CABLE_COLORS`-palett (6 distinkte) +
  `_cableStroke`/`_cableBaseColor`: hver kabel i en multi-gruppe får sin egen farge på
  serpentin/connections/lead-run/etikett, label K1/K2/K3… (ikke bare K1/K2). Fargelegende i
  romkortet (prikk + K# + produkt · lengde · effekt). Enkeltkabel uendret (oransje),
  LOCKED-regler urørt.

- **`85e9c8c` — Aldri dropp en kabel + fri manuell type/antall.** (1) `_autoFillNCables`
  droppet et delrom stille hvis den gode motoren ga ingen runs på en uregelmessig del
  (skrå gavl/hakk) → 3 valgt ble 2 tegnet, en del udekket. Nå: fallback til serpentin på
  sub-polygonet (`_engine='serpentine-fallback'`) → kabelen plasseres alltid; kun ekte
  slivere droppes (med `console.warn`). Verifisert: skrå-gavl → 3 kabler (2 boustrophedon +
  1 fallback), L/T → 3 boustrophedon. (2) Ny «Manuelt»-seksjon i kabel-velgeren: type-
  dropdown (alle familie-varianter) + antall-stepper (1–16) + «Forhåndsvis» → bygger
  N-delrom-layout + live preview (Bruk/Avbryt), valg huskes. Verifisert: antall=4 → 4 kabler.

- **`7f63800` — Multi-kabel deler rommet i N reelle DELROM og kjører én-kabel-motoren i
  hvert.** `_autoFillNCables` kjørte før den enkle serpentinen i et perp-BÅND av hele rom-
  polygonet → «rektangulært bånd»-problem på L/hakk (udekket). Nå klipper `_clipPolygonToSlab`
  rom-polygonet til hver like-areal slab → reelt sub-polygon, og `autoFillCable`
  (boustrophedon/V6, full dekning + hjørne-til-hjørne) kjøres på et midlertidig delrom og
  re-keyes til ekte rom. Hver kabel arver single-kabel-kvalitet; nabokabler møtes med ~én CC.
  Verifisert: L-form 74 m² → 3 delrom à likt areal, alle boustrophedon, 91% (= single-kvalitet,
  opp fra 88%). Manuell velger + forhåndsvisning (forrige økt) bruker nå denne motoren.

---

## 2026-06-04 — Varmekabel: færre/store, bedre layout, manuell velger

- **`6f8bf6f` — Punkt 3: manuelt valg + dekning% + live forhåndsvisning.** Kabel-velgeren
  (`_updateCableSelection`) lister nå forslag (1× stor + multi 3×/4×/…) med total W, W/m²,
  CC, dekning~% og effekt-merke (▼lav/●ok/▲høy). Klikk → live forhåndsvisning (ikke commit,
  som snø-modulen) + «✓ Bruk / ✕ Avbryt». Ingenting endelig før bekreftelse.
- **`10bd31c` — Punkt 2: deknings-drevet layout (like-AREAL bånd).** `_autoFillNCables`
  delte i like-BREDE bånd → dårlig tiling på uregelmessige rom. Ny `_equalAreaBandBounds`
  deler i N bånd med likt netto-areal → hver fast-lengde kabel fyller kant-til-kant.
  L-form 60 m²: 3 bånd à 20 m², 95% dekning (opp fra ~88%). Rektangel uendret.
- **`39adf4b` — Punkt 1: foretrekk færre/større kabler.** `selectMultiCables` rangerte på
  effekt-presisjon → en liten kabel slo færre store. Nå: færrest kabler innen ±12% effekt,
  største kabel. Katalogen har lange InFloor 17T (opp til 200m), så 72 m² @ 129 W/m² gir
  nå 3× 183m i stedet for 7× 79m. LOCKED kabelregler urørt.

---

## 2026-06-04 — Bakgrunn: alltid-synlig hurtigkontroll

- **`cb4a778` — Synlighets-/dimme-kontroll for bakgrunn tilbake på toppen.** Kontrollen
  lå kun i none-state-ctxbaren (kun når ingenting var valgt) → forsvant når et rom ble
  valgt. Ny `_bgCtxGroupHtml()` prepende i `updateCtxBar` for alle hvile-tilstander
  (skjult i transiente moduser + før kalibrering): Vis-toggle + dimme-slider + «…»-meny
  (målestokk/bytt/fjern), bundet til det aktive laget (synket med sidebar-lista). Fjernet
  none-state-duplikatet + død flytende `#bg-panel`-HTML. Rendering og prosjektdata urørt
  (trygg fiks — full S.bgs→bgLayers-migrering droppet pga. lav gevinst/høy risiko).

---

## 2026-06-04 — Varmekabel: ubegrenset antall kabler

- **`07032b0` — Store rom kan nå prosjekteres med så mange kabler som trengs.**
  `selectMultiCables` var hardkodet til maks 2× — nå effekt-drevet: N ≈ ønsket effekt /
  kabel-effekt, med gyldig CC. Ny `_autoFillNCables` splitter perp-aksen i N like bånd
  og legger én serpentin per bånd (indre bånd: ny `boundaryEdge='both'` → halv-CC mot
  begge nabokabler, uniform CC). Alle kabel-paneler viser «N×» og plasserer N.
  2-kabel-veien (delt start + lead-run) uendret; ny vei kun for N≥3. Tak 16 (praktisk
  ubegrenset). Verifisert ekte InSnow (64 m²): 200 W/m²→13 kabler, 300→16, 0 overlapp.

---

## 2026-06-04 — UX: seleksjons-drevet kontekst-handlingsmeny

- **`fe327c1` — Samme prinsipp overalt: klikk rad = velg/åpne, ✏️ = navn.** Utvidet
  rom-fiksen til etasje-headere (klikk → toggle, ✏️ omdøp), prosjektliste-rader på
  dashbordet (klikk → åpne prosjekt, ✏️ omdøp) og hindring-rader (fjernet villedende
  cursor:text, ✏️ lagt til). Alle eksisterende rename-handlere gjenbrukt; dobbeltklikk
  + høyreklikk «Gi nytt navn» beholdt.
- **`fefdabd` — Klikk hele rom-raden for å velge rommet.** Navne-spennet i sidebar
  hadde egen onclick som startet omdøping (med stopPropagation), så klikk på navnet
  valgte ikke rommet. Fjernet den → hele raden kaller `selRoom`. Omdøping flyttet til
  en tydelig ✏️-knapp (i tillegg til dobbeltklikk + høyreklikk «Gi nytt navn»).

- **`40f9e08` — Rydd opp i `#ctxbar` (rom-tilstand).** Rom-valgt viste ~12 knapper
  samtidig. Nå seleksjons-drevet: primær «+ Produkt» (fylt aksent) + 4 sekundære
  (+ Hindring, + Sone, Auto-soner, Mål); resten (Skillevegg, Fyll fra punkt, Sentrer,
  Folie-avstand, Tøm, Dokumentasjon, Rom-label, Målsett rom/folie/kabel, Slett rom)
  under én «⋯ Mer»-popover (`_showCtxMore`, gjenbruker `#produkt-menu` + `.ctx-item`).
  Ny `.snap-chip.primary`-stil, 44px-trykkflater beholdt, `#topbar` uendret. Alle
  onclick-handlere gjenbrukt — ingenting mistet, la til «Slett rom». None-state:
  «Rektangel» markert som primær.

---

## 2026-06-04 — Folie skråvegg-motor + onboarding/multi-org

Økt som ryddet folie-auto-fill-scoringen, bygde skråvegg-trapper, og forbedret
onboarding/brukeradministrasjon. Alle endringer verifisert på ekte FlexFoil-data i
preview-serveren (Chrome), og syntaks-sjekket før commit.

### Folie: skråvegg-dekning (ny `_slantStaircaseFill`-motor)

Bygd stegvis gjennom flere prompter. Sluttresultat: hver skråvegg får en ren
40/20cm-trapp som følger diagonalen, midtpartiet pakkes optimalt, ingen
overlapp/støv, og rette rom (rektangel/L/T) er garantert uendret.

- **`31fd9fc` — Pakk kjerne-båndet optimalt + jevne mellomrom.**
  Etter trapping dekomponeres det fullhøye kjerne-båndet (komplementet til
  slant-sonene) og pakkes med `_bestMixedWidthFit` (uttømmende søk → færrest
  strimler / beste breddekombinasjon) i stedet for grådig. Slakken fordeles jevnt
  mellom strimlene. Kun brede produkter (>40cm) i kjernen; båndet krympes forbi
  trappestrimler som strekker seg inn (ren overgang). Byttes kun når ikke verre
  (≤ antall strimler og ≥ dekning), validert mot trappene (ingen overlapp).

- **`045025a` — 40cm-trapp på BEGGE sider (slutt å beholde flatt kuttede brede strimler).**
  Ny `_stripCutRatio` (lengde / høyeste-kant-potensial). Brede strimler (>40cm)
  som diagonalen kutter < 85 % fjernes — også de som straddler sonegrensa — og
  sonen bygges om til ren trapp (regionen utvides til strimlenes fulle spenn).
  Brukervalg: ren trapp først, selv om en flat strimmel dekker marginalt mer m².

- **`0a4885d` — Fjern overlapp-advarsel, støv-strimler og glipper.**
  `_freeSweepRanges` erstatter `_subtractCoveredSweep` og håndhever leverandør
  perp-GAP (`_effectiveGapCmPair`) mot alle strimler → ingen ⚠. `_buildNarrowStaircase`
  dropper støv (< 30cm) og velger bredden som dekker mest (40cm i kroppen, fint
  20cm nær spissen, eksakt ett gap mellom trinn).

- **`6fda605` — 40/20cm-trapp på ALLE skråvegger (redesign).**
  Itererer per skråvegg-kant (slant-sone = kantens perp-span). Foretrekker ren
  full-høyde trapp der den dekker ≥ det den erstatter; ellers additiv så ingen
  sone står tom. Løste at bare én skråvegg fikk trapp.

- **`62e547f` — Skråvegg-dekning med trapp av smale FlexFoil-strimler (20/40cm).**
  Første versjon: additivt etter-pass `_slantStaircaseFill`, kun ved
  `_roomHasSlantedWall`. Hjelpere `_roomHasSlantedWall`, `_posNearSlant`,
  `_narrowEdgeFillProducts`.

### Folie: opprydding

- **`bcbb2ec` — Samle layout-scoring i én `_scoreFoilLayout` (P4).**
  Erstatter `_scoreLayout` + lokal score-closure i `_autoFillBothDirections` med
  én scorer med to dokumenterte vekt-profiler (select/zone). Aritmetikk bevist
  byte-identisk → ingen synlig endring.

### Onboarding & multi-org

- **`ff11db0` — Onboarding.** Samle pending-statuser til én komponent
  (`_AUTH_STATUS`), invitasjons-vei på login («📩 Har du en invitasjon?»),
  2-stegs registrering, org-admin rolle-endring + invitasjon på nytt.

- **`97e6d8b` — P7 multi-org.** Alle medlemskap i `_userMemberships`, aktiv-org i
  localStorage, org-bytter i avatar-meny (kun ved >1 org), plan-basert medlemstak
  (`_orgMemberLimit`).

### Kabel-motor (P1, tidligere i økten)

- **`4c86720` — Samle delt kabel-scoring i `_scoreCableCandidate`.**
- **`d1b0135` — Fjern død kabel-motor (V5/V4/length-driven).**

---

## Verifiseringsmetode

- **Syntaks:** ekstraher inline `<script>` → `node --check`.
- **Funksjonelt:** preview-server `romtegner` (port 4000) + Chrome MCP, testet på
  syntetiske rom (trapes, hus med 2 skråvegger, steep-trapes, kappet hjørne) og
  ekte FlexFoil 60W-produkter. Sjekket: dekning, overlapp (0), støv (ingen <30cm),
  no-op på rektangel/L/T.
- **LOCKED-regler** i CLAUDE.md (U-turns, sweep-margin, equal-length runs, ingen
  Y-splits) ikke berørt — dette gjelder kun folie, ikke varmekabel.
