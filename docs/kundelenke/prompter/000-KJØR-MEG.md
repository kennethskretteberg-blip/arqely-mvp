# 000 · KJØR MEG — serien «Kundelenke» (027–030)

Du er Claude Code i `~/Code/arqely-mvp`. Denne mappa inneholder fire prompter som skal kjøres
**i rekkefølge**, én om gangen, med commit etter hver. Spec-en som er fasit ligger i
`docs/kundelenke/spec-kundelenke.md` — les den først, hele.

## Hvor filene ligger

Kenneth kopierer mappa hit før du starter:
```
mkdir -p ~/Code/arqely-mvp/docs/kundelenke/prompter
cp ~/Documents/Claude\ Cowork/Romtegner/Romtegner/spec/spec-kundelenke.md ~/Code/arqely-mvp/docs/kundelenke/
cp ~/Documents/Claude\ Cowork/Romtegner/Romtegner/prompter/varmeplan/kundelenke/*.md ~/Code/arqely-mvp/docs/kundelenke/prompter/
```
Finner du ikke filene: stopp og si fra — ikke gjett innholdet.

## Rekkefølge

| # | Fil | Gjør | Avhenger av |
|---|---|---|---|
| 027 | `027-kundelenke-grunnmur-og-maal-fra-kunde.md` | Tabell + RPC-er, merking av usikre vegger, «Be kunde om mål», kundesiden i mål-modus med innsending | — |
| 028 | `028-mottak-av-svar-og-innarbeiding.md` | Merke i prosjektlista, gjennomgangspanel «estimert → kunde», Bruk/Bruk alle med avviksvisning | 027 |
| 029 | `029-epost-begge-veier-og-varmeplan-no.md` | Edge Function (Resend): lenke til kunde, varsel til Kenneth ved svar; alle lenker på varmeplan.no | 027 |
| 030 | `030-tegn-selv-pc-og-telefon.md` | Tegn-modus: Mål / Polygon / L-form / WBW på PC, WBW med piler + talltastatur på telefon, rom inn via 028 | 027, 028 |

## Regler for hele serien

- **Linjenumre i promptene er fra `d43d1d8` og er veivisere. Symbolnavnene er fasit.** Grep før du
  antar.
- **STEG 0 i hver prompt kjøres og rapporteres før du koder.** Finner du at en antakelse i prompten
  er feil, skriv det i rapporten og velg den løsningen som stemmer med spec-en — ikke med prompten.
- **Én commit per prompt**, commit-tekst står nederst i hver. Endringslogg (`docs/endringslogg.md`,
  nyeste øverst) etter hver.
- **Spørsmål samles i `docs/kundelenke/prompter/SPØRSMÅL.md`** (fila finnes, legg til under riktig
  prompt-nummer). Ikke stopp for å spørre — velg det som er tryggest (minst endring, ingen
  dataeksponering) og noter valget der. Unntak: noe som vil eksponere kundedata eller skrive i
  prosjekter uten innlogging → **stopp**.
- Regresjonstester (`_soneRegressionTest`, `_gapRegressionTest`, `_foilRegressionTest`,
  `_cableSkewRegressionTest`, `_gbao10RegressionTest`, `_reserveCableRegressionTest` m.fl.) skal være
  grønne etter hver prompt. Hver prompt legger til sin egen.
- Migrasjonsfiler lages i repo-rota som `supabase-migration-kundelenke*.sql`, idempotente
  (`if not exists`, `create or replace`), ren ASCII i SQL-kommentarer — Kenneth kjører dem manuelt i
  SQL Editor. Skriv i rapporten **hvilke** som må kjøres.
- Edge Functions i `supabase/functions/<navn>/index.ts`, samme stil som `send-invite-email`.
- Ingen ny avhengighet, ingen ny fil i klienten — alt i `index.html`.

## Når alt er kjørt

Skriv `docs/kundelenke/STATUS.md`: hva som er gjort per prompt, hva Kenneth må gjøre (migrasjoner,
`supabase functions deploy`, secrets, Vercel-domene), og en «Til Kenneth»-liste med ting du var i
tvil om.
