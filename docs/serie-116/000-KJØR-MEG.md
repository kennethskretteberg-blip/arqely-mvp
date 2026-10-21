# Serie 116 · 117 · 118: kundepresentasjonen. Kjøre-instruks for Claude Code

**Repo:** `~/Code/arqely-mvp` · **Gren: `main`** (på `ecb71c4` (115) eller nyere).
Kopier denne mappen til `docs/serie-116/` før du starter.

**Mål for serien:** Kenneth skal kunne tegne rom, legge ut løsning og sende **én** lenke. Kunden ser løsningen,
kan rette målene og sier hva hen synes, i ett svar. I dag går det to runder: først en lenke for mål, så en
presentasjon.

| rekkefølge | fil | hva | størrelse |
|---|---|---|---|
| 1 | `116-presentasjon-forhandsvalgt-rom-alle-mal-bla-send.md` | Et rom er valgt når presentasjonen åpner. Mål på alle vegger. «Send forslag» er blå | liten |
| 2 | `117-presentasjon-venstre-panel.md` | Alt samlet i et venstre panel som i Varmeplan (skuff nederst på mobil) | middels |
| 3 | `118-presentasjon-endre-mal-las-mal.md` | «Endre mål» → vegger og hjørner flyttes → «Lås mål». Målene følger med i svaret og kan innarbeides hos Kenneth | middels–stor |

## Slik kjører du

1. **Sjekk først:** `git log --oneline -15`. Har en prompt allerede en commit som begynner med nummeret,
   hopper du over den.
2. Kjør i rekkefølge, én prompt om gangen:
   - les hele prompten
   - gjør STEG 0
   - gjør endringen
   - test
   - oppdater `docs/endringslogg.md`

   **Én commit per prompt.**
3. **«STOPP»** betyr: commit, skriv rapporten i `docs/serie-116/RAPPORT.md`, og gå videre. Ikke push.
4. **Ikke stopp for spørsmål.** Velg det tryggeste og minste, skriv det i `SPØRSMÅL.md`, og fortsett.
5. **Stopp hele serien** bare hvis en prompt ville krevd å bryte en «Skal IKKE», eller hvis
   `_kundeforslagRegressionTest` eller et annet kundelenke-batteri blir rødt uten at du finner årsaken.
6. **Sikkerhet (gjelder hele serien):**
   - Kunden skriver **aldri** i prosjektet, bare via `kundelenke_answer` (security definer).
   - Ingen nye RPC-er og ingen migrasjon, med mindre STEG 0 viser at det er umulig uten. Da skal du stoppe og
     skrive det.
   - Presentasjonslenka skal ikke vise et eneste felt mer enn i dag.
7. Test på **dupliserte** prosjekter og egne testlenker. Det er samme database som varmeplan.no. Test også i
   **smal skjerm (390 px)**, fordi kunder åpner lenka på mobil.
8. **Ikke push.** `main` går rett ut til varmeplan.no.
9. **Mål før du forklarer** (STATUS §4).

## Til slutt

Én samlet rapport i `docs/serie-116/RAPPORT.md`, med teskje:
- per prompt: hva som ble gjort, STEG 0-funn, commit og skjermbilder (desktop og mobil)
- hvordan Kenneth lager en testlenke og ser endringen
- batterier som ble kjørt
- hva som står igjen i `SPØRSMÅL.md`
