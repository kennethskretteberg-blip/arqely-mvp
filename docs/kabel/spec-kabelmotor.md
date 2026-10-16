# Spec · Geometrisk utleggsmotor for varmekabel

**Status:** 13.10.2026. Kenneths oppdragstekst («Varmeplan – ny geometrisk utleggsmotor for
varmekabel»), med Coworks justeringer som Kenneth har godtatt (§0). Prompter:
`prompter/varmeplan/kabelmotor/068–071`. Bygges i en **git worktree** på grenen `kabelmotor`.

---

## 0. Justeringer (gjelder foran resten av dokumentet)

1. **Målestokken først.** Geometrikontrollen (`_cableGeometryCheck`) og romgalleriet bygges før ny
   motor (068). De er fasiten alle motorer — gamle og nye — måles mot.
2. **Ny motor ved siden av, ikke i stedet for.** Den kobles inn i kaskaden bak en bryter og tar over
   bare for romklasser der galleriet viser at den er bedre (070). De fire eksisterende motorene
   (skew, boustrophedon, V6, serpentine) fjernes ikke i denne serien.
3. **Samme dataformat ut.** Motoren leverer kabelobjekter i formatet resten av appen leser i dag
   (`runs`-form og/eller `pathEls`-form — 068 kartlegger hvilke felt romstatistikk, label,
   materialliste, PDF, flerkabel-soner, fryserom-reserve og manuell redigering faktisk bruker).
   Ingen nedstrøms ombygging.
4. **Lengdetoleranse:** lagt senterlinjelengde = produktets lengde **±1 %** (47 m → ±0,47 m).
   *(Standardvalg — Kenneth bekrefter i SPØRSMÅL.)* Kaldkabel/tilledning regnes ikke med.
5. **Omfang første runde:** rom med **akseparallelle** vegger — med hakk, utsparinger, veggstubber,
   trinn og hindringer. Rom med skrå/roterte vegger beholder dagens skew-motor, men **må bestå
   geometrikontrollen**; gjør de ikke det, merkes de ugyldige (⚠). Vilkårlige vinkler er en senere runde.
6. **Polygonbibliotek:** robust offset/klipping via ett pinnet CDN-bibliotek (f.eks. Clipper2 eller
   clipper-lib), lastet som de andre (`<script src=…@versjon>`). Ingen byggesteg, ingen package.json.
7. **«Del i to kabler» er et godt svar.** Finnes ingen lovlig sammenhengende vei med én kabel, er en
   begrunnet anbefaling om 2 kabler (eller annen kabellengde) et **bestått** utfall i galleriet.
8. **Stopp etter 068** — Kenneth ser analysen og arkitekturforslaget før 069 bygger.

## 1. Hovedkrav (harde — brytes aldri)

1. **Inne:** all kabel ligger i lovlig område = rom − kantavstand − hindringer − forbudte soner.
2. **Ingen kryssing eller ulovlig nærføring:** kabelen krysser aldri seg selv; ingen to deler av
   kabelen nærmere enn produktets `min_spacing_mm`.
3. **Bøyeradius:** ingen sving under `min_bend_radius_mm`.
4. **Lengde:** lagt lengde = produktlengde ± toleranse (§0.4).
5. **CC-intervall:** én global CC innenfor rommets/produktets tillatte intervall (romtype, `_ccLimits`).
6. **Sammenhengende:** én kurve fra start til slutt, uten brudd.

## 2. Myke mål (forbedres bare innenfor de harde kravene)

1. Minimal CC-variasjon. 2. Symmetrisk kantavstand. 3. Start/slutt nær ønsket hjørne.
4. Best dekning. 5. Færrest overganger. 6. Ryddig utlegg.

## 3. Begreper som ikke må blandes

- **CC** = avstand mellom parallelle rette løp.
- **Minste klaring** = minste avstand mellom to vilkårlige deler av kabelen (også sving mot løp,
  overgang mot løp).
- **Kantavstand** = kabel til vegg/hindring.
- **Dekning** = andel av netto areal som ligger innenfor ½ CC fra kabel.
CC kan bare kalles «eksakt» når det er målt mellom parallelle segmenter; klaring måles separat.

## 4. Arkitektur (lag A–H, fra oppdraget)

A. **Normalisering** — ytterpolygon, hull, hindringer, ikke-oppvarmet; validering; lovlig område ved
   offset (§0.6); konkave hjørner, smale passasjer, små restområder.
B. **Celleoppdeling** — Boustrophedon Cellular Decomposition; kritiske hjørner; celler som kan fylles
   med parallelle løp; koblingsmuligheter bevart; 0° og 90° (§0.5); unngå unødig fragmentering.
   *Merk: V6 (`_v6DecomposeCells`) gjør allerede noe av dette — gjenbruk der det holder mål.*
C. **Global avstand** — én CC og ett felles koordinatsystem for løpene i hele rommet; antall løp og
   faseforskyvning slik at kantavstanden blir symmetrisk: for bredde W med N løp,
   `margin = (W − (N − 1) × CC) / 2`, generalisert. **Celler får aldri egen CC eller egen fase.**
D. **Rute** — graf (celler = noder, lovlige overganger = kanter); én sammenhengende bane; ingen
   kryssing, overlapp eller snarveier; flere cellerekkefølger og start/slutt-kombinasjoner vurderes.
E. **Svinger** — sirkelbuer; ideell U-sving har radius CC/2; er `min_bend_radius > CC/2`, brukes en
   validert alternativ sving (f.eks. «nøkkelhull») eller CC økes; hver sving kontrolleres mot
   lovlig område. Ingen ukontrollerte Bézier-kurver.
F. **Lengde** — rette segmenter + buer + overganger = senterlinjelengde; numerisk søk over CC, antall
   løp, fase, retning, symmetrisk inntrukne vendepunkter og cellerekkefølge. Aldri tilfeldig
   justering av enkeltsegmenter.
G. **Start/slutt** — lovlige hjørnekandidater med samme kantmargin som vendepunktene; brukerens
   startvalg (`S.varmefolie.startCorner`) respekteres når det er lovlig; aldri tvang som bryter §1.
H. **Optimalisering** — harde krav (§1) som filter, myke mål (§2) som poeng.

## 5. Feilhåndtering

Ingen løsning → strukturert svar: årsak, kolliderende begrensninger, oppnådd og målsatt lengde,
beregnet CC, minste klaring, udekkede områder, forslag (annen kabellengde, lovlig CC, 2 kabler).
**Aldri et tilsynelatende gyldig utlegg ved feil.**

## 6. Test

Romgalleri (068) med minst: rektangel · L · U · én hindring · flere hindringer · smal passasje ·
utsparing · asymmetriske vegger · kabel for lang · kabel for kort · bøyeradius umulig · umulig
starthjørne · **Kenneths bad (5,89 m², hakk fra venstre, skrå toppvegg, trinn; InFloor 17T 800 W
47 m)** rekonstruert fra prosjektets koordinater — ikke fra piksler i skjermbildet.
Hver test måler: lengdeavvik, CC-variasjon, kantavstand, minste klaring, bøyeradius, antall
kryssinger, kontinuitet, dekning.

## 7. Debug-visning

Av/på uten å påvirke vanlig bruk: cellegrenser, senterlinjer, start/slutt, CC-mål, kantmarginer,
bøyeradier, røde problemsegmenter, lagt lengde mot produktlengde.

## 8. Merge-kriterier (alle må være oppfylt)

1. Kenneths bad får gyldig utlegg — eller en begrunnet «del i 2 kabler» som selv er gyldig.
2. Ingen rom i galleriet er dårligere enn med dagens motor (samme eller bedre på hvert mål).
3. Alle eksisterende regresjonsbatterier grønne.
4. Kenneth har sett `docs/kabel/galleri.html` og forhåndsvisningen av grenen, og sagt «merge».

## §0.9 · R-START (LÅST REGEL, 083)

Kabelens start (tilkoblingsenden) ligger **≤ 40 cm** fra det hjørnet retningsvelgeren peker på.
«Hjørnet» er rommets eget hjørnepunkt nærmest velgerens hjørne av rommets ytre ramme — ikke
rammens hjørne, som i et L-rom kan ligge utenfor rommet (`_cableCornerPoint`).

Rekkefølgen når mål står mot hverandre:

1. Harde krav (§1: inne, ingen kryssing/nærføring, bøy, lengde ±1 %, CC-intervall, sammenhengende)
2. **Valgt retning** — byttes aldri (088b)
3. **R-START** — start i valgt hjørne
4. Jevn CC (ingen hull > 1,25 × CC, 074b)
5. Dekning
6. Fasit-CC og øvrige myke mål

⚠ **088b endret punkt 2 og 3.** 083 lot R-START rangere foran retningen, og da byttet motoren
til vannrett når loddrett ikke kunne starte i hjørnet. Kenneth meldte det to ganger som at
«retningsvelgeren virker ikke» — med rette. Hans egne ord var at starten må vinne over
**dekning**; han sa aldri over **retning**. Når hjørnet ikke kan nås i valgt retning, legges
utlegget likevel i valgt retning, og panelet sier avstanden og tilbyr den andre retningen med
tall. Aldri et stille bytte.

Et utlegg som starter i hjørnet slår alltid et som ikke gjør det — uansett dekning og CC. Regelen
gjelder på **kaskadenivå**, for alle motorer, ikke bare i geo-poengsummen
(`_cableFilterByCorner`, `_cableHitsCorner`).

Når hjørnet ikke går i valgt retning, men går i den andre: den andre legges ut, velgeren står
fortsatt på brukerens valg, og panelet sier det i én linje med en vei tilbake. Går det i ingen
retning: beste i valgt retning, merket ⚠ med avstand og grunn. Aldri et stille avvik.

## §0.10 · R-VEGG (LÅST REGEL, 089)

Ingen tom stripe mellom en vegg og nærmeste løp er bredere enn **margin + 1 CC**. Én ubrukt bane
ved veggen er lov (074b); to er det ikke. Måles **per løp**, ikke per bånd: finnes det et annet løp
mellom dette og veggen som overlapper det i sveiperetningen, er avstanden ikke en tom stripe
(`_cableWallStripe`, `metrics.wallStripeCm`). Straffen i `_geoScore` er gradert fra «kant + 1 CC»
til «kant + 2 CC», vekt 18 — over lengdeleddet, under hull-straffen (25). Se STATUS §34.

## §0.11 · R-ENDE (LÅST REGEL, 094, presisert i 095)

**Kabelens frie ende skal ikke ligge i en restcelle.** En restcelle er en celle med **én bane som
er lavere enn 2 × CC** — altså for lav til en vanlig sving (radius CC/2) i begge ender. En fri ende
som fyller sin **egen** celle helt ut, også en grunn nisje, er **ikke** et brudd. Lengden tilpasses
fortsatt jevnt i alle svinger (`extraSweep`), aldri ved å kappe endeløpet.

Kenneths ord 16.10.2026: «her er siste løp kortere enn løpene ved siden. Det skal det ikke være.
Siste løp må forlenges, og heller øke avstand fra alle løpene mot vegger.» Og presiseringen samme
dag: «En ende som fyller en 78 cm dyp nisje helt ut, er riktig utlegg. Nisjen er 78 cm, og kabelen
går så langt den kan.»

⚠ **094-utgaven var for bred.** Den målte bare «kortere enn naboen» og meldte derfor brudd på seks
rader der endecellen er en ekte nisje: badHakk (78,1 cm mot 2 × 11,21 = 22,4) og badHakk41 (85,9 mot
2 × 13,45 = 26,9). Rom 5 er en restcelle (12,6 < 2 × 13,2 = 26,4), og reparasjonen der står.

Målt som `metrics.endeKortCm` (`_cableEndeKort`): er endeløpet ≥ 2 × CC, er svaret 0 og det finnes
ingen påstand. Ellers finnes nærmeste nabo-løp som overlapper i sveiperetningen, og det måles hvor
langt naboens sving på samme side rekker forbi enden. ⚠ Overlappskravet skaleres etter løpets
**egen** lengde (`min(CC, len × 0,6)`) — et løp på 12,6 cm kan aldri overlappe en nabo med en hel CC.

**Porten er den samme i rutingen.** `_geoRouteOrders` lager rekkefølger som utelater en kort
én-banes celle, og den porten må bruke samme 2 × CC-terskel. Uten den vant dropp-varianten på
**lengdeleddet** i badHakk41 (40,74 m mot 41,37 mot et mål på 41,00) og endret et utlegg i et rom
uten restcelle — dekning 82,9 → 81,5 og veggstripe 5,1 → 16,9.

**Rekkefølge:** R-ENDE ligger **over R-VEGG** (Kenneth sa rett ut hva som skal gi etter når de to er
i strid) og **under** harde krav, valgt retning, R-START og jevn CC. Vekt 22 i `_geoScore`.
R-ENDE kjøpes **aldri** med dårligere dekning (Kenneths beslutning 095: 5–7 prosentpoeng er for
dyrt). Enderunden godtar bare en kandidat som er like god på alt annet.

**Årsaken, målt:** endeløpet er full høyde i sin **egen** rutenettcelle; det kortes ikke inn noe
sted. `_geoRouteOrders` krever en Hamilton-sti, så hver celle må besøkes, og en restcelle som ikke
kan ta en U-sving i begge ender må derfor bli stiens **ende**. Fiksen er ekstra rekkefølger som
utelater den — lagt bakerst som varianter, aldri som erstatning (093).

## §0.12 · Testnivåene (095)

* **`_cableGeoSuite()` — PORTEN.** Bare geo-motoren, alle fixtures × 2 retninger × 4 hjørner (136
  rader), hver rad mot `docs/kabel/baseline.json`. Kjøres før hver commit i kabelmotoren.
  Baselinjen oppdateres BARE med `_cableGeoSuite({ oppdaterBaseline: true })`, aldri automatisk;
  `flett: true` + `only` lar den bygges i biter.
  Dominans — en rad feiler hvis den mister gyldighet, får flere hull, taper R-START (var ≤ 40 cm),
  bryter R-VEGG (var innenfor), får større `endeKort` eller mister mer enn 1 prosentpoeng dekning.
  N og CC **rapporteres**, de feiler ikke: CC velges av lengdesøket, og et annet trinn er ikke i seg
  selv dårligere.
* **`_cableForstyrrelsesTest()`** — flytter hver vegg ± 1 og ± 2 cm, én om gangen. Krav: dekning
  ≤ 3 prosentpoeng, CC ≤ 0,8 cm, samme form (celler, transitt, starthjørne), start ≤ 40 cm.
  Brudd **måles og rapporteres**; de rettes ikke av testen.
* **`_cableGeometryRegressionTest()`** — det store batteriet med alle sju motorene. **Ikke en port.**
  Manuell kjøring; V6-loggingen ligger bak `window._cableQuietV6`.
