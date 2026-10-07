# 028 · Mottak: merke i prosjektlista, gjennomgang «estimert → kunde» vegg for vegg, Bruk / Bruk alle med avvik som går opp

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Høy** · **Størrelse: middels–stor**
**Spec:** regel 2, 4, 10. Krever 027. Linjenumre fra `d43d1d8`.

---

## Poenget

Kunden har sendt inn tall. Nå skal Kenneth se dem ved siden av sine egne, velge hva som brukes,
og få tegningen rettet — uten at rommet blir skjevt i stillhet. Spec regel 4: **målene må gå
opp**, og avvik skal vises, ikke skjules.

## STEG 0

1. Finnes det alt en funksjon som setter en veggs lengde i et rom (klikk på målelinje, redigering
   av `dims`, WBW-redigering)? Grep etter steder som flytter `room.points` ut fra en tastet lengde.
   Finnes den → gjenbruk. Finnes den ikke → §2 beskriver den.
2. Hva skjer med hindringer, soner, striper/kabler/matter i rommet når `room.points` endres i dag
   (f.eks. ved vegg-drag)? Finn mekanismen (re-clip? slettes? ligger igjen?) og bruk samme.
3. Hvordan lastes prosjektlista (`_loadProjectList` e.l.) — kan den hente `kundelenker` med
   `status='answered'` for orgen i samme runde?

## Gjør

### 1. Merke og panel

- Prosjektlista: prosjekter med `kundelenker.status='answered'` får merke «✉ Svar fra kunde».
  Prosjektinfo-blokken i sidebaren: «Svar fra kunde (06.11, Ola Montør) — **Gå gjennom**».
- Gjennomgangspanel (modal eller sidepanel): tabell per rom → per vegg:
  `Vegg | Estimert | Kunde | Avvik | [Bruk]`, usikre vegger først, uendrede vegger grå nederst.
  Kundens kommentar øverst. Knapper **Bruk alle**, **Bruk valgte**, **Avvis** (status `revoked`
  med merknad), **Lukk** (beholder `answered`).
- Når Kenneth trykker Bruk → rommene markeres i tegningen samtidig (highlight), så han ser hva som
  skjer.

### 2. Innarbeiding — `_applyWallLength(room, wallIdx, newCm)` (hvis STEG 0.1 ikke fant en)

- Vegg `i` = `points[i] → points[i+1]`. Retning `u` = enhetsvektor langs veggen. `delta = newCm −
  dagens lengde`. Flytt `points[i+1 … n−1]` (alle etterfølgende, **ikke** `points[0]`) med `u·delta`.
  Det er «forleng veggen og skyv resten av rommet etter» — i et rektangel/L-form gir det et rom
  som fortsatt er rettvinklet; den lukkende veggen (`points[n−1] → points[0]`) absorberer
  endringen.
- Spesialtilfelle rektangel med både vegg `i` og motstående vegg `i+2` endret: bruk gjennomsnitt
  hvis de avviker ≤ 2 cm; ellers behold begge i lista som avvik (se §3).
- Etter hver anvendt vegg: `room.area` på nytt (`compArea`), `dims` på nytt, hindringer/soner/
  utlegg etter STEG 0.2-mekanismen. `pushUndo()` **én gang** per «Bruk»-klikk, uansett antall vegger.
- Rekkefølge ved «Bruk alle»: vegger med størst |delta| først, deretter resten; så én
  kontrollrunde (§3).

### 3. Avvik som ikke går opp

**Før** Bruk: panelet viser `_roomAxisBalance` (027 §2b) regnet med kundens tall — «✓ går opp»
eller «⚠ 3,10 m mangler loddrett på høyre side» med veggene det gjelder uthevet, så Kenneth ser
hvor det skurrer før han trykker. Kundens eget `axisBalance` fra svaret vises ved siden av.

Etter innarbeiding måles alle vegger som kunden ga tall på. Vegger der |resultat − kunde| > 1 cm
listes: «Vegg 4: kunde 4,10 m → ble 3,95 m (rommet går ikke opp — sjekk vegg 2 og 4)». Rommet
får gul «⚠ Mål går ikke opp» i sidebar til Kenneth fjerner den (klikk) eller retter. Ingen
automatisk «fordeling» av feilen — spec regel 4.

### 4. Status og opprydding

- Alle vegger brukt/avvist → `kundelenker.status='applied'`, `room.uncertainWalls` tømmes for de
  veggene som fikk mål. Prosjektet merkes `_projectDirty` og lagres som vanlig.
- Flere svar på samme lenke (kunden sendte to ganger): nyeste `answer` gjelder (027 skriver over).

## Skal IKKE

- Endre rom kunden ikke ga tall på.
- Flytte `points[0]` (rommets ankerpunkt — da flytter rommet seg i forhold til nabo-rom/underlag).
- Rotere eller skalere rommet.

## Test

1. Rektangel 3,20 × 4,00 estimert; kunde: 3,45 (vegg 0) og 4,10 (vegg 1) → Bruk alle → rommet er
   3,45 × 4,10, rettvinklet, areal riktig, `points[0]` urørt, Ctrl+Z gir 3,20 × 4,00 tilbake i ett steg.
2. L-form med 6 vegger, kunde endrer 3 → resultatet er fortsatt rettvinklet; de 3 andre veggene
   får sine følge-endringer vist i panelet før Bruk (forhåndsvisning av «blir»-kolonnen).
3. Rektangel der kunde gir vegg 0 = 3,45 og vegg 2 = 3,60 → ⚠-rad, ingen stille gjennomsnitt når
   avvik > 2 cm.
4. Rom med folie-utlegg → etter Bruk oppfører utlegget seg som ved vegg-drag i dag (STEG 0.2).
5. Status `applied`, kundelenken gir «ikke gyldig» ved nytt besøk; «?»-markeringer borte.
6. Ny sjekk i `_kundelenkeRegressionTest`: syntetisk rektangel + svar → riktige lengder,
   `points[0]` uendret, areal = 3,45 × 4,10 ± 0,01 m².

## Rapport

STEG 0.1 (fantes en vegg-lengde-funksjon?), 0.2-mekanismen, hvordan «blir»-forhåndsvisningen
ble løst. Endringslogg. Commit: «028: kundesvar — gjennomgang vegg for vegg, Bruk/Bruk alle, avvik som ikke går opp vises».
