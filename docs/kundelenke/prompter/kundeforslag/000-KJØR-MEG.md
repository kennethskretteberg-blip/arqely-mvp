# 000 · KJØR MEG — serien «Kundeforslag» (042–044)

Du er Claude Code i `~/Code/arqely-mvp`. Tre prompter, **i rekkefølge**, commit etter hver.
Spec: `docs/kundelenke/spec-kundeforslag.md` (bygger på `spec-kundelenke.md` — begge leses først).
**Forutsetning:** 041 (presentasjonslenken) er kjørt — serien bygger på `?present=`.

## Hvor filene ligger

```
mkdir -p ~/Code/arqely-mvp/docs/kundelenke/prompter/kundeforslag
cp ~/Documents/Claude\ Cowork/Romtegner/Romtegner/spec/spec-kundeforslag.md ~/Code/arqely-mvp/docs/kundelenke/
cp ~/Documents/Claude\ Cowork/Romtegner/Romtegner/prompter/varmeplan/kundeforslag/*.md ~/Code/arqely-mvp/docs/kundelenke/prompter/kundeforslag/
```

## Rekkefølge

| # | Fil | Gjør | Avhenger av |
|---|---|---|---|
| 042 | `042-lenketekst-med-kopierknapp.md` | «PRESENTASJON»/«FYLL INN MÅL» som hyperlenke + Kopier (formatert + ren URL) | 041 |
| 043 | `043-kundeforslag-kortet-i-presentasjonen.md` | Mode `forslag`: romkort med produkt-piling, ønsket flateeffekt, retning, OK per rom, Send forslag | 042 |
| 044 | `044-kundeforslag-godkjenn-hos-cenika-og-epost.md` | Panel «Kundeforslag» med Godkjenn/Avslå per rom → auto-utlegg, e-post begge veier, «Godkjenn hele prosjektet» som signal | 043 |

## Regler (samme som kundelenke-serien)

- Linjenumre er veivisere fra `2147753`; symbolnavn er fasit. STEG 0 kjøres og rapporteres før
  koding; avvik fra prompten løses etter spec-en og noteres i rapporten.
- Én commit per prompt, endringslogg nyeste øverst, spørsmål i `SPØRSMÅL.md` i denne mappa.
  Stopp bare hvis noe ville eksponere kundedata eller skrive i prosjekter uten innlogging.
- Migrasjoner idempotente, ren ASCII i SQL-kommentarer (ikke i e-post/UI-tekst — der skal æøå inn).
- Alle regresjonsbatterier grønne etter hver prompt; hver prompt legger til sine sjekker i
  `_kundelenkeRegressionTest` eller en ny `_kundeforslagRegressionTest`.
- Avslutt med `docs/kundelenke/STATUS.md` oppdatert (seksjon «Kundeforslag») + «Til Kenneth».
