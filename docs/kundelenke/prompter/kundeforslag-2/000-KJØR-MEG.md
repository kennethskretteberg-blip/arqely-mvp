# 000 · KJØR MEG — serien «Kundeforslag 2» (053–055)

Du er Claude Code i `~/Code/arqely-mvp`. Tre prompter, **i rekkefølge**, commit etter hver.
Spec: `docs/kundelenke/spec-kundeforslag.md` + `spec-kundelenke.md` — begge leses først, og
**oppdateres** underveis (nye regler under). Bakgrunn: Kenneth testet 042–044 live 10.10.2026.
Presentasjonen og forslagskortet hos kunden **ser bra ut** — det er behandlingen hos Cenika,
stigen forbi største kabel, rom uten varme og historikken som mangler.
**Forutsetning:** 042–044 og 051 er kjørt (`e2bb6f4`).

## Hvor filene ligger

```
cp ~/Documents/Claude\ Cowork/Romtegner/Romtegner/spec/spec-kundeforslag.md ~/Code/arqely-mvp/docs/kundelenke/
cp -r ~/Documents/Claude\ Cowork/Romtegner/Romtegner/prompter/varmeplan/kundeforslag-2 ~/Code/arqely-mvp/docs/kundelenke/prompter/
```

## Rekkefølge

| # | Fil | Gjør | Avhenger av |
|---|---|---|---|
| 053 | `053-kundeforslag-gjennomgang-v2-…md` | Beslutninger lagres per rom i `applied_result`; ferdig = `applied` **uten** e-post; flyttbart vindu med rom på lerretet, Angre, inline Avslå; 💬 i romlista + rute «Kundeønske» | 044 |
| 054 | `054-kundesiden-pile-forbi-storste-kabel-…md` | Stigen fortsetter med N × like kabler; «Finn» bruker stigen; rom uten varme får «Foreslå varme» (type → serie → variant); godkjenning lærer flerkabel og nytt rom | 053 |
| 055 | `055-kundedialog-logg-…md` | `hendelser`-kolonne + `kundelenke_logg`-RPC; tidslinje per runde fra `kundelenker`; «Logg»-knapp i prosjektinfo og i vinduet; kopier som tekst | 053 |

## Nye regler i `spec-kundeforslag.md` (skriv dem inn i 053/054/055)

- **Regel 7 (endret):** Godkjenn/Avslå lagres **per rom med én gang** (`applied_result`). Når alle
  rom med forslag er behandlet, er forslaget **ferdig** (`status='applied'`) — uten at noe sendes.
  Svar til kunden er **valgfritt**.
- **11.** Gjennomgangen skjer **på lerretet**: vinduet er flyttbart og ikke-modalt; klikk på rom i
  vinduet velger og zoomer til rommet; godkjenning kjører motoren mens rommet er synlig; hvert
  rom kan angres for seg.
- **12.** Rom med ubehandlet kundeønske er **merket i romlista** (blått 💬) og viser ønsket i en
  egen rute når rommet er valgt — vinduet er en snarvei, ikke eneste vei.
- **13.** Ingen e-post sendes automatisk fra Cenika-siden; «Send svar til kunden» er en knapp.
- **14. (054)** Stigen på kundesiden fortsetter forbi største kabel med **N × like** kabler
  (N ≤ 3), bare når summen overstiger største gyldige enkeltkabel. Blandede kabler er ikke et
  klikk. «Ønsket flateeffekt» bruker samme stige.
- **15. (054)** Rom **uten** varme kan få et forslag: kunden velger type (kabel/matte) → serie →
  variant, fra samme katalog Kenneth ser. Rom som alt har varme bytter aldri type. Snørom og
  fryserom holdes utenfor. «Ikke i v1»-punktet om familiebytte **oppheves bare for tomme rom**.
- **16. (055)** Hele dialogen per prosjekt er en **logg** i appen, avledet av `kundelenker` +
  `hendelser`; kunden ser den ikke.

## Regler (samme som før)

- Linjenumre er veivisere fra `e2bb6f4`; symbolnavn er fasit. STEG 0 kjøres og rapporteres før
  koding; avvik fra prompten løses etter spec-en og noteres i rapporten.
- Én commit per prompt, endringslogg nyeste øverst, spørsmål i `SPØRSMÅL.md` i denne mappa.
  Stopp bare hvis noe ville eksponere kundedata eller skrive i prosjekter uten innlogging.
- Migrasjoner idempotente, ren ASCII i SQL-kommentarer (ikke i e-post/UI-tekst — der skal æøå inn).
- Alle regresjonsbatterier grønne etter hver prompt; hver prompt legger til sine sjekker i
  `_kundeforslagRegressionTest` / `_kundelenkeRegressionTest`.
- Avslutt med `docs/kundelenke/STATUS.md` oppdatert (seksjon «Kundeforslag 2») + «Til Kenneth»:
  hvilke migrasjoner han må kjøre i Supabase (053: `svar_sendt_at`; 055: `hendelser` + RPC).
