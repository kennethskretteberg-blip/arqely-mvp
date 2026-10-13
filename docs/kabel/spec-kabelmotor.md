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
