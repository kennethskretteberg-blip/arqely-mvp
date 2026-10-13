# 071 · Kabelmotor fase 6: dokumentasjon, merge-sjekkliste og forhåndsvisning — **STOPP: Kenneth sier «merge»**

**Worktree `kabelmotor`.** Spec §8.

---

## Gjør

1. **Rebase:** `git fetch && git rebase main` i worktreen (main kan ha fått commits). Løs konflikter,
   kjør **alle** regresjonsbatterier og galleriet på nytt.
2. **Dokumentasjon** `docs/kabel/STATUS.md`:
   - Hva motoren gjør (lag A–H) på én side, med teskje.
   - Galleritabellen før (068) / etter (070), rom for rom.
   - **Hva motoren ikke løser** (spec §6 punkt 6 i oppdraget) — hver romtype med årsak og hva appen
     viser brukeren da.
   - Hvordan legge til et nytt testrom i galleriet.
3. **Merge-sjekkliste** (spec §8) — fyll ut med bevis:
   - [ ] badHakk: gyldig utlegg (retning, CC, lengdeavvik) eller gyldig «2 kabler»
   - [ ] badHakk horisontalt: minst like godt som Kenneths referanse (CC 12,5, én slynge)
   - [ ] ingen galleri-rom dårligere enn før (tabell)
   - [ ] alle regresjonsbatterier grønne (antall batterier/sjekker)
   - [ ] ingen endring i lagret dataformat (eksisterende prosjekter åpnes og vises likt — test tre
     ekte prosjekter **lesende**)
   - [ ] `docs/kabel/galleri.html` oppdatert
4. **Forhåndsvisning:** spør Kenneth i rapporten om grenen skal pushes for Vercel-forhåndsvisning.
   Hvis ja: `git push -u origin kabelmotor`, og gi ham forhåndsvisnings-adressen fra Vercel. Minn om at
   forhåndsvisningen bruker **samme database** — test på dupliserte prosjekter.

## Når Kenneth sier «merge»

```
cd ~/Code/arqely-mvp
git checkout main && git pull
git merge --no-ff kabelmotor -m "Kabelmotor 068–071: geometrikontroll, ny motor for akseparallelle rom, ⚠ for ugyldige utlegg"
# kjør regresjon én gang til på main
git push
git worktree remove ../arqely-mvp-kabelmotor
```
(Kjør ikke dette uten et eksplisitt «merge» fra Kenneth.)

## Rapport — og STOPP

Utfylt sjekkliste, lenke til galleri og STATUS, og spørsmålet om forhåndsvisning. Endringslogg.
Commit: «071: kabelmotor — dokumentasjon, merge-sjekkliste».
