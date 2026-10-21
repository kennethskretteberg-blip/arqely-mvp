# Serie 119 · 120 · 121: oppfølging (presentasjon, trappesoner, kabelmotor-testene). Kjøre-instruks for Claude Code

**Repo:** `~/Code/arqely-mvp` · **Gren: `main`** (på `8eee272` eller nyere). Kopier mappen til `docs/serie-119/` først.

Alle tre er **Kenneths svar** på åpne SPØRSMÅL. Skriv «**Svar (Kenneth 21.10):** …» under hvert spørsmål i fila det
står i (stiene står i hver prompt), og gjør det svaret krever.

| rekkefølge | fil | hva | størrelse |
|---|---|---|---|
| 1 | `119-presentasjon-oppfolging.md` | Skjul produktmål for kunden, klikk-styring, forhåndsvalg på tvers av etasjer, vegg-tabell per vegg, UTLEGG-merket ryddes selv | middels |
| 2 | `120-trapp-svar-serie-104.md` | Alle soner starter på samme side, tallfelt «Antall kabler» i sonen, auto kan foreslå 2 kabler i en sone | middels |
| 3 | `121-kabelmotor-rett-roede-sjekker-og-fail-open.md` | 077 fail-open rettes i motoren, 7 utdaterte påstander oppdateres, rask variant av batteriet | middels |

## Slik kjører du

1. `git log --oneline -15`: er en prompt alt committet, hopper du over den.
2. Én prompt om gangen: STEG 0, endring, test og endringslogg. **Én commit per prompt.**
3. **«STOPP»** betyr: commit, skriv rapporten i `docs/serie-119/RAPPORT.md`, og gå videre. Ikke push.
4. Ikke stopp for spørsmål. Velg det tryggeste og minste, skriv det i `SPØRSMÅL.md`, og fortsett.
5. **Stopp hele serien** hvis en «Skal IKKE» må brytes, eller hvis et batteri blir rødt uten kjent årsak.
6. **121 rører kabelmotoren.** `_cableGeoSuite()` skal være grønn, og **ingen** av de 142 radene skal bli dårligere.
   Endret rad = stopp og skriv.
7. Bare dupliserte prosjekter. Ikke push. Mål før du forklarer.

## Til slutt

`docs/serie-119/RAPPORT.md` med teskje: per prompt hva som ble gjort, STEG 0, commit, hva Kenneth skal klikke,
batterier og det som står igjen i `SPØRSMÅL.md`.
