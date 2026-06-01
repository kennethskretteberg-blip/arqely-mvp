# Kabel-layout: hjørne-til-hjørne med lik strengavstand — spesifikasjon

> Optimalisering av auto-fill for varmekabel i `romtegner.html`.
> Mål (fra Kenneth): kabelen skal legge seg **jevnt ut i hele området uavhengig av
> vinkler og hindringer**, alltid **starte i ett hjørne og avsluttes i et annet**,
> og ha **lik avstand mellom strengene** overalt. Når kravene kolliderer skal
> svingene heller **trekkes litt vekk fra veggen** slik at både lik CC *og*
> hjørne-til-hjørne oppfylles samtidig.
>
> Grunnlag: gjennomgang av `autoFillCable()` + de fem kabelmotorene, `CLAUDE.md`
> sine LOCKED-regler, og standard *boustrophedon coverage path planning* (Choset &
> Pignon; Bähnemann m.fl. 2019). En kjørbar prototype som beviser invariantene
> ligger i `docs/claude/kabel-prototype.html`.

---

## 1 — Hva koden gjør i dag (verifisert i kode)

`autoFillCable()` (linje ~9243) kjører fem motorer i kaskade og scorer resultatene.
Den primære, `generateCableSerpentine()` (linje 6327), gjør i praksis dette:

1. Regner ut CC fra areal/kabellengde → **lik CC** (bra, dette beholdes).
2. Legger `N` parallelle strenger med lik CC, sentrert (≈ halv-CC margin på hver side).
3. Klipper hver streng mot rom-polygonet, krymper med `sweepMargin = margin + CC/2`,
   trekker fra hindringer og forbudte soner.
4. **Utjevner (LOCKED):** dropper strenger kortere enn 0,7 × median, og klipper
   *alle* gjenværende strenger til ett felles `[commonLo, commonHi]`-intervall.

Steg 4 er kjernen i problemet for vinklede rom. Den tvinger hele kabelen inn i ett
rektangulært bånd:

- På et **L/T-rom** blir enten den utstikkende delen liggende helt udekket (fordi
  fellesintervallet bare er overlappet), eller så slår V5/V6-celledekomposisjonen
  inn og kobler celler gjennom *midten* av rommet → **slutten havner midt i rommet,
  ikke i et hjørne**.
- Hjørne-landing finnes i dag bare som en **myk score-bonus** (linje 9324–9333:
  «reward endpoints close to corners»), prøvd over 4 hjørner × 3 spacings — det er en
  *preferanse*, ikke en *garanti*.

`CLAUDE.md` sier til og med eksplisitt: «For irregular rooms … some areas won't be
covered — this is acceptable.» Det er nettopp dette du nå vil endre.

---

## 2 — Algoritmen (boustrophedon + global CC-rute + hjørne-anker)

Standard løsning på «dekk hele et vinklet område med én sammenhengende slangebane»
er **boustrophedon-celledekomposisjon** (Choset & Pignon). Idéen, tilpasset reglene
deres:

### 2.1 Global CC-rute (lik strengavstand overalt)
Legg strengposisjonene på **én felles rute** langs perp-aksen: `u_k = u0 + k·CC`.
Alle celler henter strengene sine fra samme rute → CC er **identisk i hele rommet og
på tvers av celler**. (Dette er forskjellen fra V5/V6, som regner CC per celle og
dermed kan få ulik avstand i ulike deler.)

### 2.2 Celler = rektangulære «slabs»
Sveip en linje langs perp-aksen. Ved hver romvertex / hindringskant endrer rommets
sveip-utstrekning `(lo, hi)` seg. Maksimale intervaller der `(lo, hi)` er konstant blir
**celler** — hver celle er et rektangel. På et L-rom gir dette to celler; rundt en
hindring gir det celler over/under hindringen.

### 2.3 Utjevning *innenfor* celle (beholder LOCKED-reglene)
Innen én celle har alle strenger **samme høyde** → utjevning til `[lo+sweepMargin,
hi-sweepMargin]` gir rene **halvsirkel-svinger (r = CC/2)**, akkurat som LOCKED krever.
Forskjellen fra i dag: utjevningen skjer **per celle**, ikke globalt over hele rommet —
så den utstikkende delen mister ikke dekning.

### 2.4 Én sammenhengende bane — overgangen MÅ skje på den delte kanten
Tråkk cellene i rekkefølge og koble **siste streng i celle A → første streng i celle
B**. Dette er *ikke* en Y-split: banen forgrener seg aldri — den har nøyaktig **én start
og én slutt**.

**Den kritiske detaljen (paritets-styrt overgang):** kabelen må **forlate celle A
gjennom kanten den DELER med celle B**, ikke gjennom motsatt vegg. Hvis ikke får man
det «jukset» du så på skjermbildet: kabelen gikk helt opp til toppen av den høye delen
og måtte deretter hoppe rett ned (stiplet linje) til den lave delen — et hopp tvers over
oppvarmet gulv.

For et L-rom deler de to delene **den nedre kanten**. Da må siste streng i den høye
delen *avsluttes nederst*, slik at overgangen til den lave delen blir en **helt vanlig
halvsirkel-sving nederst** — akkurat slik «strengene normalt svinger mellom de to
romgeometriene». Hvilken ende en celle avsluttes i bestemmes av paritet (antall strenger
+ hvilken ende den startet i). Motoren prøver derfor alle fire starthjørner og velger
den varianten der **alle** celleoverganger lander på en delt kant (null hopp over gulv).
For 2-celle-rom (L, trinn, forskjøvne rom) gir dette **alltid** en ren løsning — verifisert
i prototypen (`openLen = 0`, 41 svinger, 0 koblinger).

> **Forgrenede rom (T, kryss, hull rundt hindring):** her finnes en celle med en arm
> som stikker forbi den delte kanten (f.eks. T-benets fot). Da kan ÉN kort kobling som
> **følger en innervegg** være uunngåelig — det er prisen for LOCKED-regelen om like
> svinger. Motoren minimerer disse og legger dem inntil vegg (aldri tvers over åpent
> gulv), og auto-retningsvelgeren prøver begge retninger for å unngå dem helt når mulig.

(Datamodellen har allerede et `connections`-felt fra V5/V6.) LOCKED-regelen om «ingen
forlengelseslinjer mellom strenger av ulik høyde» gjelder *innen* et bånd — den brytes
ikke av en bevisst celle-til-celle-kobling på den delte kanten.

### 2.5 Hjørne-anker (garantert, ikke scoret)
To frie ender finnes: enden av første streng og enden av siste streng.
- **Perp-aksen:** med sentrert CC-rute ligger første og siste streng ≈ halv-CC fra
  veggen — det nærmeste lovlige punktet til hjørnet. Det *er* hjørnet i praksis
  (kabelen kan ikke ligge på veggen).
- **Sveip-aksen:** velg **starthjørne + traverseringsrekkefølge + strengparitet** slik
  at start-enden og slutt-enden lander i hvert sitt romhjørne. Dette er en
  *konstruksjon*, ikke en score — jf. Bähnemann m.fl. (2019), som viser at
  celle-koblingen kan løses med **fast start- og sluttnode**.

### 2.6 «Trekk svingene fra veggen» (din regel ved konflikt)
Hvis sluttstrengens naturlige ende ikke treffer hjørnet eksakt (typisk når rom-lengden
ikke er et helt multiplum slik at U-svingene ellers ville stå ulikt fra veggen),
**juster sveip-inset symmetrisk** (`commonLo += d`, `commonHi -= d`) for det aktuelle
båndet. CC mellom strengene røres aldri — bare hvor langt strengene strekker seg mot
sveip-veggen. Slik får du *både* lik CC *og* eksakt hjørne-landing.

### 2.7 Skråvegger og hindringer (generell motor — `engine2`)
De rettvinklede reglene over generaliserer til vilkårlige polygoner med to grep:

**(a) Rotert sveiperamme for skråvegger.** Roter all geometri slik at strengene blir
parallelle med en valgt vegg (kandidat-vinkler = hver veggretning + 0°/90°; velg den med
best dekning). Kjør samme scanline-serpentin i den roterte rammen, og roter resultatet
tilbake. Da **følger strengene skråveggen** med lik CC, og U-svingene trapper seg pent
langs skråningen. Strenglengden får variere naturlig langs skråveggen — det er *ikke* en
Y-split (banen forgrener seg aldri), bare en streng som er litt kortere enn naboen.

**Bueretning (LOCKED — `_uTurnIsHigh`/`wallDir`):** hver bue skal alltid **vende utover**,
vekk fra strengkroppene. Bestem retningen lokalt fra strengen som ender i svingen: gikk
strengen oppover (`y1 > y0`) er svingen i topp-enden → bue oppover; ellers nederst → bue
nedover. Dette tilsvarer `wallDir = connectHigh ? +1 : -1` i `_drawCableUTurns` (linje
11591). Bruk ALDRI «vekk fra rom-sentrum»-heuristikk — den bommer ved hindringer og
innvendige svinger. I rotert ramme er normalen ganske enkelt (0, ±1), rotert til verden.
Verifisert på trapes, parallellogram, kappet hjørne og triangel: lik CC, ~95–96 %
dekning, hjørne-til-hjørne, null gulv-hopp.

**(b) Boustrophedon-celler rundt hindringer.** En hindring (hull) splitter strengene som
passerer den i to baner (over/under). Standard boustrophedon: ved hindringens kant endrer
banetallet seg (1→2 eller 2→1) — det er et **kritisk punkt** som starter nye celler.
Koble baner mellom nabostrenger **kun når koblingen er 1:1** (én bane treffer nøyaktig én
bane); ved split/merge lages ny celle. Da blir hver celle enkel-banet og sveipes rent.
Cellene (venstre, over, under, høyre) bindes til **én** bane via en grådig vandring over
celle-naboskapsgrafen, med **veggnære koblinger** rundt hindringen — aldri tvers over
åpent gulv.

> **Ærlige begrensninger** (verifisert i prototypen):
> - **Fritstående hindring midt i rom:** kabelen ruter pent rundt, men *slutten havner
>   ved hindringen*, ikke i et fjernt hjørne — det er geometrisk uunngåelig for et hull
>   (du dekker fire soner og må ende ved den siste). Hindring **mot vegg** (søyle, trapp)
>   blir derimot et hakk = ren enkelt-celle, hjørne-til-hjørne.
> - **Triangel:** spissen gir svært korte strenger som faller bort; start/slutt kan ligge
>   ~20 cm fra selve spissen. Akseptabelt — en spiss kan ikke varmes helt ut uansett.

Prototype for dette: `docs/claude/kabel-prototype-skra.html` (trapes, parallellogram,
kappet hjørne, triangel, hindring midt/mot vegg; Auto- eller manuell sveipevinkel).

---

## 3 — Hva endres, hva beholdes

| Beholdes (LOCKED) | Endres |
|---|---|
| CC regnes fra areal/lengde | Utjevning flyttes fra **globalt** til **per celle** |
| Halvsirkel-sving r = CC/2 | Hjørne-landing blir **konstruksjon**, ikke score-bonus |
| `sweepMargin = margin + CC/2` | Sveip-inset kan trekkes symmetrisk for hjørne-treff |
| Lik strenglengde *innen celle* | Global CC-rute deles av alle celler |
| Én start, én slutt, ingen Y-split | Fem-motor-kaskaden erstattes av én forutsigbar motor |

Dette er samtidig **P1** i `forbedringsplan-arqely.md` (konsolider kabel-motoren):
én primær motor, én scoringsfunksjon, mindre død kode.

---

## 4 — Prototype (bevis)

`docs/claude/kabel-prototype.html` — frittstående, åpne i nettleser. Velg romform
(rektangel, L, T, U, «to rom med hakk», rektangel m/ hindring), retning, starthjørne og
CC. Tre invarianter sjekkes live og er verifisert headless i Node for alle formene i
begge retninger:

- **Lik CC** — alle nabostrenger har nøyaktig CC mellom seg.
- **Like strenger pr. celle** — rene halvsirkel-svinger (r = CC/2).
- **Start + slutt i hjørne** — begge frie ender innenfor `margin + CC` av et romhjørne.
- **Ingen hopp over gulv** — celleoverganger skjer på delt kant som en vanlig sving
  (`openLen ≈ 0`); for forgrenede rom vises en veggnær kobling med lengde i cm.

Den **første** prototypen (`kabel-prototype.html`) dekker rettvinklede rom + rektangulære
hindringer (skjermbildene dine). Den **generelle** prototypen
(`kabel-prototype-skra.html`) utvider til **skråvegger og vilkårlige hindringer** via en
rotert sveiperamme + boustrophedon-celler (se §2.7) — verifisert på trapes, parallellogram,
kappet hjørne, triangel og hindring midt/mot vegg.

---

## 5 — Ferdig Claude Code-prompt (lim inn i `arqely-mvp`)

> **NB:** Linjenumrene under er omtrentlige og kan ha forskjøvet seg — **søk på
> funksjonsnavn** (`grep`), ikke på tall.

```
Les autoFillCable() og generateCableSerpentine() i romtegner.html (FINN dem ved å søke
på navn, ikke linjenummer), og les docs/claude/kabel-hjorne-til-hjorne-spec.md +
docs/claude/kabel-prototype.html (kjørbar referanse-motor med verifiserte invarianter).

Mål: gjøre kabel-auto-fill forutsigbar og hjørne-til-hjørne, uten å bryte LOCKED-reglene
i CLAUDE.md (halvsirkel r=CC/2, sweepMargin = margin+CC/2, lik strenglengde, ingen
Y-split).

Jobb stegvis og IKKE slett noe før det er bevist trygt:

1. Legg en debug-teller i autoFillCable som logger hvilken motor som faktisk leverer
   resultatet for (a) rektangel, (b) L-rom, (c) rom med hindring, (d) rom med forbudt
   sone. Rapporter til meg FØR du rører motorene.

2. Implementer en ny primærmotor generateCableBoustrophedon(roomId, productId, dir,
   startCorner) etter spec-en, som porterer prototypen i kabel-prototype.html:
   - Global CC-rute (u_k = u0 + k·CC) delt av alle celler → lik CC overalt.
   - Slab-celler ved romvertekser/hindringskanter; utjevning PER CELLE (ikke globalt)
     slik at utstikkende deler beholder dekning.
   - Én sammenhengende bane med PARITETS-STYRT overgang: kabelen må forlate hver celle
     gjennom kanten den DELER med neste celle, slik at overgangen blir en vanlig
     halvsirkel-sving — ALDRI et hopp tvers over gulvet (det var feilen i forrige
     forsøk). Prøv alle fire starthjørner og velg varianten med null gulv-hopp
     (openLen ≈ 0). Forgrenede rom (T/kryss/hull): tillat ÉN kort veggnær kobling.
   - Hjørne-anker som KONSTRUKSJON: velg starthjørne/rekkefølge/paritet slik at begge
     frie ender lander i hvert sitt romhjørne. Hvis sluttenden ikke treffer eksakt,
     trekk sveip-inset symmetrisk (commonLo += d, commonHi -= d) — rør ALDRI CC.
   - Behold halvsirkel-svinger r=CC/2 og sweepMargin = margin+CC/2 uendret.

3. La generateCableBoustrophedon være første motor i autoFillCable. Behold V6/V5/V4 som
   fallback inntil steg 1-loggingen + visuell test bekrefter at den nye motoren dekker
   alle tilfeller minst like bra. Trekk den dupliserte scoringen (linje 9311, 9364,
   9419, 9474, 9530) ut til én _scoreCableCandidate(res, ctx).

4. Skråvegger + vilkårlige hindringer (port fra kabel-prototype-skra.html, se §2.7):
   - Skråvegger: roter geometrien så strengene blir parallelle med valgt vegg (kandidat-
     vinkler = hver veggretning + 0/90°, velg best dekning), kjør scanline-serpentinen i
     rotert ramme, roter tilbake. Strenglengden får variere langs skråveggen (ikke
     Y-split). Behold aksejustert hurtigsti for rettvinklede rom.
   - Hindringer: bygg boustrophedon-celler ved å koble baner mellom nabostrenger KUN ved
     1:1-treff (split/merge ved hindringskant = ny celle). Bind cellene til én bane via
     grådig vandring over naboskapsgrafen med veggnære koblinger rundt hindringen.
   - Aksepter de ærlige grensene i §2.7 (fritstående hindring → slutt ved hindring;
     triangelspiss → ~20 cm fra spissen).

Test i preview-serveren romtegner på rektangel, L, T, U, trapes, kappet-hjørne-rom,
rom-med-hindring (midt og mot vegg) og rom-med-forbudt-sone. Vis meg skjermbilder av
hver, og bekreft: lik CC, rene svinger som følger veggen, og at S og E sitter i hjørner
(unntatt fritstående hindring). Ikke fjern V4/V5/V6 før jeg har godkjent skjermbildene.
```

---

## 5b — Ferdig Claude Code-prompt: SKRÅVEGGER + HINDRINGER (frittstående)

Bruk denne hvis du bare vil ta skråvegg-/hindring-delen. Den porterer den verifiserte
referansemotoren i `docs/claude/kabel-prototype-skra.html` (engine2) inn i romtegner.html.

> **NB om linjenumre:** alle linjehenvisninger i dette dokumentet kan ha forskjøvet seg
> (filen vokser). **Finn funksjonene ved å søke på NAVN** (`grep`), ikke på tall.

```
Les docs/claude/kabel-prototype-skra.html (kjørbar referansemotor "engine2",
funksjonene generateCable2, _generateRotated, _serpCell, _buildPath) og
docs/claude/kabel-hjorne-til-hjorne-spec.md §2.7. Les også CLAUDE.md sine LOCKED
kabelregler og _drawCableUTurns/_uTurnIsHigh. VIKTIG: finn alle funksjoner ved å SØKE
på funksjonsnavn (grep), ikke på linjenumre — tallene i spec-en kan ha forskjøvet seg.

Mål: la kabel-auto-fill håndtere SKRÅVEGGER (ikke-90°) og HINDRINGER like rent som
rettvinklede rom — lik CC, svinger som vender utover, hjørne-til-hjørne, uten hopp over
åpent gulv. IKKE bryt LOCKED-reglene (halvsirkel r=CC/2, sweepMargin=margin+CC/2, ingen
Y-split, lik strenglengde innen en celle).

Jobb stegvis, ikke slett gammelt før nytt er bevist i preview:

0. IKKE REGRESSER rettvinklede rom. Behold den aksejusterte hurtigstien (0/90°) som
   allerede gir rene L-/T-rom hjørne-til-hjørne. Den roterte ramma under skal kun være
   et tillegg for ikke-90°-vegger; for rene rektangulære rom skal resultatet være
   identisk med i dag. Verifiser L og T på nytt etter endringen.

1. SKRÅVEGG via rotert sveiperamme. Lag _cableSweepAngles(room) som returnerer
   kandidatvinkler = hver veggretning (mod 180°) + 0/90°. For hver: roter room.points
   (og hindringer) så strengene blir vertikale, kjør den eksisterende scanline-
   serpentinen (clipScanlineToPolygon finnes allerede), roter resultatet tilbake. Velg
   vinkelen med best dekning. Strenglengden får variere langs skråveggen — det er IKKE
   en Y-split. (Når dominansvinkelen er 0/90° faller dette automatisk tilbake til
   hurtigstien fra steg 0.)

2. HINDRINGER via boustrophedon-celler. Når en hindring splitter en streng i to baner
   (over/under), koble baner mellom nabostrenger KUN ved 1:1-treff; ved split/merge
   (hindringskant) starter ny celle. Hver celle blir da enkel-banet og sveipes rent.
   Bind cellene (venstre/over/under/høyre) til ÉN sammenhengende bane via en grådig
   vandring over celle-naboskapsgrafen, med VEGGNÆRE koblinger rundt hindringen — aldri
   tvers over åpent gulv. Hindring mot vegg skal bli et rent hakk (én celle).

3. BUERETNING (LOCKED). Hver U-sving skal vende UTOVER, bestemt lokalt: gikk strengen
   oppover (y1>y0) → bue i topp-enden (opp); ellers → bue ned. Dette er samme regel som
   wallDir = connectHigh ? +1 : -1 i _drawCableUTurns. I rotert ramme er bulge-normalen
   (0, ±1) rotert til verden. Bruk ALDRI «vekk fra rom-sentrum».

4. HJØRNE-ANKER. Søk over starthjørne/retning og velg banen med null gulv-hopp og begge
   ender nær romhjørner. Aksepter de ærlige grensene i §2.7: fritstående hindring midt i
   rom → slutten havner ved hindringen (geometrisk uunngåelig); triangelspiss → start/
   slutt ~20 cm fra spissen.

Test i preview-serveren romtegner på: trapes, parallellogram, rom med kappet hjørne,
triangel, rom med hindring midt i, og rom med hindring mot vegg. Vis skjermbilder og
bekreft for hver: lik CC, alle buer vender utover, og ruting rundt hindring uten gulv-
hopp. Behold dagens motorer som fallback til jeg har godkjent skjermbildene.
```

---

## Kilder

- Choset & Pignon, *Coverage Path Planning: The Boustrophedon Cellular Decomposition* —
  https://link.springer.com/chapter/10.1007/978-1-4471-1273-0_32
- Bähnemann m.fl. (2019), *Revisiting Boustrophedon Coverage Path Planning as a
  Generalized Traveling Salesman Problem* (fast start/slutt-node) —
  https://arxiv.org/pdf/1907.09224
- CMU Robotics Institute, oversikt boustrophedon-dekning —
  https://publications.ri.cmu.edu/coverage-path-planning-the-boustrophedon-decomposition
