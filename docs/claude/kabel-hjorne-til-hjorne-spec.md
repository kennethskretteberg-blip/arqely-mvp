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

Prototypen håndterer aksejusterte (rettvinklede) rom + rektangulære hindringer —
det dekker rommene i skjermbildene dine. Skrå (ikke-90°) vegger krever samme idé på et
rotert sveip-koordinatsystem; det er notert i porteringsprompten under.

---

## 5 — Ferdig Claude Code-prompt (lim inn i `arqely-mvp`)

```
Les autoFillCable() (linje ~9243) og generateCableSerpentine() (linje 6327) i
romtegner.html, og les docs/claude/kabel-hjorne-til-hjorne-spec.md +
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

4. Skrå vegger: hvis room.points har ikke-90°-kanter, kjør samme algoritme i et
   sveip-koordinatsystem rotert til dominansretningen (PCA / lengste vegg), så strengene
   følger veggen. Behold aksejustert hurtigsti for rettvinklede rom.

Test i preview-serveren romtegner på rektangel, L, T, U, rom-med-hindring og rom-med-
forbudt-sone. Vis meg skjermbilder av hver, og bekreft for hvert: lik CC, rene
halvsirkel-svinger, og at S og E sitter i hvert sitt hjørne. Ikke fjern V4/V5/V6 før
jeg har godkjent skjermbildene.
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
