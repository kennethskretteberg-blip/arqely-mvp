# 000 · KJØR MEG — serien «Plantegning» (046–050)

Du er Claude Code. Fem prompter, **i rekkefølge**, commit etter hver.
Spec: `docs/plantegning/spec-plantegning.md` (leses først).
To repoer: `~/Code/arqely-mvp` og `~/Code/lumelo-backend`.

## Rekkefølge — og hvorfor den ikke følger planens nummerering

| # | Repo | Gjør | Avhenger av |
|---|---|---|---|
| 046 | arqely | Vegg-sjekk-flaten mot **syntetisk** motor-utdata; definerer kontrakten; ruter alle tre import-inngangene | — |
| 047 | lumelo | Senterlinjer fra tykke vegger, `/import/plan`, dekning/rester | 046 (kontrakten) |
| 048 | lumelo | Labels → nummer/navn/areal, skala, arealsjekk | 047 |
| 049 | arqely | Rom fra planvegger: utvid gjennomgangsskjermen, romtype, «Bekreft alle», «Ikke navngitt» | 046 + 048 |
| 050 | begge | DWG gjennom samme flyt, regresjon, STATUS | 047–049 |

**Flaten før motoren, med vilje.** 020 bygde automatisk romgjenkjenning først og ga 590 «rom» —
Kenneth kalte det «rot». Det som skiller denne serien er vegg-sjekken, altså er den den bærende
delen. Bygges motoren først, finnes det ingen flate å se feilen i, og 047 blir umulig å vurdere.

## Regler

- **STEG 0 kjøres og rapporteres før koding.** Promptens «hva som skjer» er en HYPOTESE som skal
  etterprøves. Den har tatt feil før (020, 021b, 025, 027, 028, 035, 041) — 041 er det ferskeste
  eksempelet: «presentasjonslenken virker ikke» viste seg å være at RPC-en returnerte en liste.
- Linjenumre er veivisere fra `0491101`; **symbolnavn er fasit**.
- Én commit per prompt. Endringslogg nyeste øverst (`docs/endringslogg.md` i arqely,
  `CHANGELOG.md` i lumelo hvis den finnes — ellers rapport i commit-meldingen).
- Spørsmål i `SPØRSMÅL.md` i denne mappa, med valget du tok i mellomtiden.
- Alle regresjonsbatterier grønne etter hver prompt. arqely: ny `_planRegressionTest`.
  lumelo: `pytest`.
- **Ingen kundedata i repoet.** Testfila er syntetisk (se 047 STEG 0.1).
- Avslutt serien med `docs/plantegning/STATUS.md` + «Til Kenneth».

## Stopp hvis

- Noe ville skrive i et prosjekt uten brukerens bekreftelse.
- En arkitekttegning med adresse er på vei inn i git.
