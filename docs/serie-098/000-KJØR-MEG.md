# Serie 098 · 075 · 099 · 065 — kjøre-instruks for Claude Code

**Repo:** `~/Code/arqely-mvp` · **Gren: `main`** (på `cd72f0e` eller nyere).
Promptene ligger i samme mappe som denne fila (`docs/serie-098/`).

| rekkefølge | fil | hva | størrelse |
|---|---|---|---|
| 1 | `098-trapp-sidevisning-start-slutt-speilet-per-trinn.md` | Trapp, sidevisning: start og slutt speilet innenfor trinnet. Overskriften følger tegningen i PDF | liten |
| 2 | `075-hoyreklikkmeny-gar-under-skjermen.md` | Høyreklikkmenyen måler høyden sin og holdes innenfor skjermen. Romtyper i to kolonner | liten |
| 3 | `099-cellesnitt-som-variant-robust-mot-1-cm.md` | Kabelmotor: cellesnitt nær terskelen bygges som variant (Rom 5 tåler 1 cm veggflytting) | middels |
| 4 | `065-varmeplan-som-installerbar-app-pwa-windows.md` | Varmeplan som installerbar app på Windows (PWA) | liten–middels |

## Slik kjører du

1. **Sjekk først:** `git log --oneline -20`. Har en prompt allerede en commit som begynner med
   nummeret («098:», «075:» …), hopper du over den og skriver det i rapporten.
2. Kjør i rekkefølgen over. Hver prompt for seg: les hele, gjør STEG 0, gjør endringen, test og
   oppdater `docs/endringslogg.md` (og `docs/kabel/STATUS.md` for 099). **Én commit per prompt**,
   med commit-teksten fra prompten.
3. **«STOPP» i en prompt betyr her:** commit, skriv rapporten for den prompten i
   `docs/serie-098/RAPPORT.md`, og gå videre til neste. Ikke push.
4. **Ikke stopp for spørsmål.** Er noe uklart, velg det tryggeste og minste, skriv spørsmålet og hva
   du valgte i `SPØRSMÅL.md` under riktig nummer, og fortsett.
5. **Stopp hele serien** bare hvis en prompt ville krevd å bryte en «Skal IKKE», eller hvis
   `_cableGeoSuite()` (i biter med `only` + `flett`) eller et regresjonsbatteri blir rødt og du ikke
   finner årsaken. Skriv da hvorfor i `SPØRSMÅL.md`.
6. Test bare på **dupliserte** prosjekter. Det er samme database som varmeplan.no.
7. **Ikke push.** `main` går rett ut til varmeplan.no. Kenneth pusher selv når han har sett
   resultatet på localhost.
8. **Mål før du forklarer** (STATUS §4): er en hypotese ikke målt, skal den merkes som hypotese.

## Til slutt

Én samlet rapport i `docs/serie-098/RAPPORT.md`, med teskje (Kenneth er ikke utvikler):
- per prompt: hva som ble gjort, STEG 0-funn og commit-hash
- hva Kenneth skal klikke for å se hver endring på localhost, og hva han skal sjekke før push
- 099: forstyrrelsestesten før og etter (brudd av totalt), og tiden for `_cableGeoSuite()`
- 065: hvordan Kenneth installerer appen på Windows-PC-en
- hva som står igjen i `SPØRSMÅL.md`
