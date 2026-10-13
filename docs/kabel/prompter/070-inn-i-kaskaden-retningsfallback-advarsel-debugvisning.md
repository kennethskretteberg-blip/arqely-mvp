# 070 · Kabelmotor fase 4–5: inn i kaskaden — ny motor tar over der den vinner, kontrollen avviser ugyldige utlegg, annen retning prøves automatisk, ⚠-visning og debug-visning

**Worktree `kabelmotor`.** Spec §0.2, §5, §7. Linjenumre fra `1519bb0` (sjekk etter 068/069).

---

## Mål

Etter 070 kan appen **aldri** vise et utlegg som bryter et hardt krav uten at det står tydelig
merket. Ny motor brukes der galleriet viser at den er bedre; dagens motorer ellers.

## STEG 0

1. Galleritabellen fra 069: for hvilke romklasser er ny motor bedre (flere gyldige, eller samme
   gyldighet + bedre myke mål)? Det er listen over hvor den tar over.
2. Hvordan settes retning i dag: `S.varmefolie.direction` (+ `dirExplicit`) — hvordan skiller koden
   «brukeren valgte vertikal» fra «auto valgte vertikal»?

## Gjør

### 1. Kaskaden med kontroll

I `_autoFillCableImpl` (:26638):
- For akseparallelle rom i romklassene fra STEG 0.1: **ny motor først**. Ellers dagens rekkefølge.
- **Hver** kandidat fra **hver** motor kjøres gjennom `_cableGeometryCheck`. Hardt brudd = avvist,
  neste kandidat/motor. Skews `openLen < spacing × 1,5`-terskel erstattes av kontrollen.
- Myke defekter = poeng som i dag.

### 2. Annen retning automatisk

Kenneths observasjon: badet legger seg perfekt horisontalt, men feil vertikalt.
- **Auto-retning** (ikke eksplisitt valgt): prøv begge retninger; velg den gyldige med best poeng.
- **Eksplisitt valgt retning** som ikke gir gyldig utlegg, mens den andre gjør det: legg ut den
  gyldige og vis «Vertikal gir ikke et gyldig utlegg i dette rommet (hakket deler løpene) — lagt
  horisontalt. [Prøv vertikal likevel]». «Prøv vertikal likevel» legger ut beste vertikale merket ⚠.
- Gjelder også flerkabel-soner (`_autoFillNCables`) per sone.

### 3. Ingen gyldig løsning → ⚠, aldri stille

- Legg ut beste kandidat med `cable._geomDefects` (harde defekter med posisjon).
- Lerret: rød stiplet romkontur, røde prikker/segmenter der defektene er.
- Sidepanel/ctxbar: «⚠ Utlegget bryter regler: kabelen krysser seg selv 1 gang · 3 åpne ender ·
  sving utenfor veggen (2). Prøv annen retning · Del i 2 kabler · Vis feil». «Del i 2 kabler»
  bruker ny motors forslag (069) eller eksisterende flerkabel-vei.
- Label: «⚠» foran CC. PDF-romside: linje «Utlegget er ikke kontrollert — se app». Ikke blokker
  lagring/eksport.
- Ny motors «ingen løsning»-svar vises med årsak og forslag (spec §5) i samme panel.

### 4. Debug-visning (spec §7)

Bryter i debug-overlayet (Cmd/Ctrl+Shift+D finnes) — «Kabelgeometri»: cellegrenser, senterlinjer,
start/slutt, CC-mål, kantmarginer, bøyeradier, røde problemsegmenter, lagt lengde mot produktlengde.
Av som standard; påvirker ikke vanlig bruk eller PDF.

### 5. Regresjon (fase 5)

- Galleriet: dagens kaskade («før» fra 068) mot ny kaskade (etter 070). **Ingen rom dårligere.**
- Rektangelrom uten hindringer: identisk utlegg som før (sammenlign `runs`).
- Alle eksisterende batterier grønne; nytt `_cableGeometryRegressionTest` som kjører galleriet og
  feiler ved harde brudd i et rom som tidligere var gyldig.

## Skal IKKE

- Fjerne gamle motorer.
- Blokkere eksport/lagring.
- Endre retning stille når brukeren eksplisitt har valgt — alltid med melding.

## Test

1. badHakk vertikalt (eksplisitt) → enten gyldig vertikalt fra ny motor, eller horisontalt med
   meldingen og «Prøv vertikal likevel» → ⚠ med prikker.
2. badHakk auto → gyldig, uten ⚠.
3. Kenneths ekte bad (duplisert kopi) → samme som 1–2.
4. Et rom ingen motor klarer → ⚠, «Del i 2 kabler» gir to gyldige.
5. Debug-visningen av/på; PDF uendret når av.
6. Galleri før/etter i rapporten.

## Rapport

Galleritabell før/etter, hvilke romklasser ny motor tok over, skjermbilder av ⚠-visning og debug.
Endringslogg. Commit: «070: kabelmotor — geometrikontroll i kaskaden, ny motor der den vinner,
automatisk annen retning, ⚠ for ugyldige utlegg, debug-visning».
