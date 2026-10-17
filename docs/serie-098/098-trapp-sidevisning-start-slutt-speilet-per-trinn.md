# 098 · Trapp, sidevisning: grønn start og rød slutt ligger i feil ende av trinnet. Start skal ligge ytterst til venstre (forkanten av trinn 1), slutt ytterst til høyre (bakkanten av øverste trinn), som i planvisningen

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Normal** · **Størrelse: liten**
**Kjøres på `main`, etter 096 og 097.** Linjenumre fra `9934b3d`/`cd72f0e`, men symbolnavnene er det som
gjelder. **Ikke push** før Kenneth har sett PDF-en.

---

## Kenneths ord og PDF (Test Cenika, P0341 rev. 2, side 3–4)

> «Grønt og rødt merke som indikerer start og stopp på kabelen ligger feil plassert på sidevisning
> av trappen. Grønn start bør ligge helt til venstre. Rød stopp bør ligge helt til høyre. Da vil de
> harmonere med start/stopp på alle andre visninger.»

Trapp 1, 10 trinn à 30 cm, opptrinn 17 cm, InSnow 30T 2360W 78,7m. I sidevisningen stiger trappen
mot høyre. Opptrinnet til neste trinn står i **høyre** ende av hvert trinn, og forkanten (nesen) er
i **venstre** ende.
- **Grønn** ligger i **høyre** ende av trinn 1, altså inntil opptrinnet. Den skal ligge i venstre
  ende (forkanten, lengst ned og lengst ut).
- **Rød** ligger i **venstre** ende av trinn 10. Den skal ligge i høyre ende (bakkanten, lengst
  inn).

## Hva som skjer (lest i koden, bekreft i STEG 0)

`_stairDrawSideToCanvas` (≈ :69310) plasserer både løpsmerkene og start- og sluttprikken på
`x = coords[si].xStart + run.pos_cm` (≈ :69391 og :69426). Kommentaren ved Regel 14 (≈ :38054)
sier at `pos_cm ≈ 0` er **opptrinnssiden** («siste løp på fromSurf ligger nær RISER-siden»). Men i
sidevisningen står opptrinnet i **høyre** ende (`dropX = sc.xStart + sc.depth`, ≈ :69408). Da må
posisjonen speiles innenfor trinnet:

```
x = xStart + depth − pos_cm        // ikke xStart + pos_cm
```

Hele løpsrekka i sidevisningen er altså speilet innenfor hvert trinn. Det synes bare på prikkene,
fordi løpene ellers ligger jevnt.

## STEG 0

1. Bekreft hvor `pos_cm = 0` ligger på en trinnflate: ved opptrinnet mot neste trinn eller ved
   forkanten. Bekreft også om det avhenger av `buildDirection` (`bottom`/`top`) eller av hvilken vei
   planen er tegnet.
2. Sjekk skjermens `_drawStairSide` (:39049). Har den samme speiling?
3. Har trappens **repos** samme regel? Sjekk med en trapp med repos.

## Gjør

1. Én hjelper, `_stairSideX(sc, pos_cm)`, med riktig speiling. Den brukes for løpsmerkene **og**
   start- og sluttprikkene i både `_stairDrawSideToCanvas` (PDF) og `_drawStairSide` (skjerm).
2. **Test:** for trapper med og uten repos, og begge `buildDirection`, skal start- og sluttprikkens
   plassering i sidevisningen være **samme fysiske kant** som i planvisningen (samme trinn, samme løp,
   forkant eller bakkant). Testen sammenligner brøken «avstand fra forkanten / trinndybde» mellom de
   to visningene.

### Sidefunn i samme PDF: overskriften står alene

Side 3 har bare «Start kabel · Slutt kabel» og «Sidevisning». Selve tegningen kommer først på side 4.
Overskriften og tegnforklaringen skal følge tegningen: sjekk plassen til **hele** blokken
(overskrift + bilde) før den skrives, og skift side før overskriften, ikke etter den.

## Skal IKKE

- Endre kabelutlegget i trappen eller planvisningen.
- Endre opptrinnskjeden («11 × 17»). Det spørsmålet står åpent i SPØRSMÅL fra 085.

## Test

1. Test Cenika / Trapp 1 (duplisert kopi), PDF: grønn ytterst til venstre på trinn 1, rød ytterst
   til høyre på trinn 10. «Sidevisning» står på samme side som tegningen.
2. Samme på skjermen (sidevisning eller «begge»).
3. Trapp med repos og trapp med `buildDirection: top`: prikkene stemmer med planen.
4. Flere kabler: hver kabels prikker stemmer.

## Rapport

STEG 0.1–0.3. PDF-side før og etter. Endringslogg. Commit: «098: trapp — sidevisningen speiler
løpsposisjonen riktig per trinn (start ved forkanten nederst, slutt ved bakkanten øverst, som i
planen); overskriften følger tegningen på samme side».
