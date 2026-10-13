# 000 · KJØR MEG — serien «Kabelmotor» (068–071), i en git worktree

Du er Claude Code. Serien bygger en geometrisk kontroll og en ny utleggsmotor for varmekabel.
**Alt arbeid skjer i en worktree på grenen `kabelmotor`** — `main` og varmeplan.no røres ikke før
Kenneth sier «merge». Les `spec-kabelmotor.md` først; §0 og §8 der går foran alt annet.

## Oppsett (første gang)

```
cd ~/Code/arqely-mvp
git fetch && git status            # main skal være ren
git worktree add ../arqely-mvp-kabelmotor -b kabelmotor
cd ../arqely-mvp-kabelmotor
mkdir -p docs/kabel/prompter
cp ~/Documents/Claude\ Cowork/Romtegner/Romtegner/prompter/varmeplan/kabelmotor/*.md docs/kabel/prompter/
mv docs/kabel/prompter/spec-kabelmotor.md docs/kabel/
```
Lokal test i worktreen: `PORT=4100 node serve-varmeplan.js` hvis 4000 er i bruk av hovedkopien
(legg inn `process.env.PORT || 4000` i `serve-varmeplan.js` hvis den ikke leser variabelen —
liten, egen commit).

## ⚠ Samme database

Worktreen bruker **samme Supabase** som produksjon. Autosave skriver tilbake til prosjektet som er
åpent. Derfor:
- Test på **faste testrom** (fixtures i koden) eller på en **duplisert kopi** av et prosjekt
  (`_duplicateProject`), aldri på et levende kundeprosjekt.
- Kenneths bad hentes som **geometri** (punkter, hindringer, soner) inn i en fixture — prosjektet
  selv åpnes bare lesende. Ingen kundedata (navn/adresse) i fixturen.
- Ingen migrasjoner i denne serien. Trengs en, stopp og spør.

## Rekkefølge

| # | Fil | Gjør | Stopp? |
|---|---|---|---|
| 068 | `068-…md` | Fase 1–2: hvorfor dagens motorer feiler (målt), `_cableGeometryCheck`, romgalleri som måleinstrument, kartlegging av dataformatet, arkitekturforslag | **JA — stopp og rapportér til Kenneth** |
| 069 | `069-…md` | Fase 3: ny motor (lag A–H) isolert fra UI, bak bryter, mot galleriet | nei |
| 070 | `070-…md` | Fase 4–5: inn i kaskaden, konkurrerer per rom, ⚠-visning og debug-visning | nei |
| 071 | `071-…md` | Fase 6: dokumentasjon, merge-sjekkliste, forhåndsvisning | **JA — Kenneth sier «merge»** |

## Regler

- Linjenumre er veivisere fra `1519bb0`; symbolnavn er fasit. STEG 0 rapporteres før koding.
- Én commit per prompt (flere er greit når det er naturlig), endringslogg nyeste øverst, spørsmål i
  `SPØRSMÅL.md` i `docs/kabel/prompter/`.
- **Ikke juster tersklene i geometrikontrollen for å få galleriet grønt.** Et rom som feiler, feiler
  — skriv hvorfor.
- Alle eksisterende regresjonsbatterier grønne etter hver prompt. En gammel test som forventer et
  utlegg kontrollen avviser: rapportér, ikke endre testen stille.
- **Ikke merge til `main` og ikke push `main`.** Push av grenen `kabelmotor` (for forhåndsvisning)
  gjøres først i 071, og bare hvis Kenneth sier ja.
- Hvis `main` får nye commits underveis: `git rebase main` i worktreen før 071, og kjør galleriet
  på nytt etter rebase.
