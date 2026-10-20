# Serie 104 · 105 · 106: trappesoner, del 2. Kjøre-instruks for Claude Code

**Repo:** `~/Code/arqely-mvp` · **Gren: `main`** (på `2cbc31f` (103) eller nyere).
Promptene ligger i samme mappe som denne fila. Kopier mappen til `docs/serie-104/` før du starter.
**Spec:** `Claude Cowork/Romtegner/Romtegner/spec/spec-trapp-kabelutlegg.md`, Regel 14, 20, 21 og 22.

| rekkefølge | fil | hva | størrelse |
|---|---|---|---|
| 1 | `104-trapp-hver-sone-starter-nederst.md` | Hver sone legges nedenfra og opp, som sone 1. Sone 2 starter i dag i motsatt ende | liten–middels |
| 2 | `105-trapp-avstand-sider-i-sone-brukes-noyaktig.md` | Avstand sider i en sone brukes nøyaktig når den er tastet. For kort eller for lang kabel vises i tegning, panel og PDF | middels |
| 3 | `106-trapp-kabelvalg-produktgruppe-og-flere-kabler-per-sone.md` | Først produktgruppe, så kabel («InSnow 30T 3000W 100m»). Flere kabler i én sone. «Tilbake til auto» | middels |

## Slik kjører du

1. **Sjekk først:** `git log --oneline -15`. Har en prompt allerede en commit som begynner med nummeret,
   hopper du over den og skriver det i rapporten.
2. Kjør i rekkefølgen over, én prompt om gangen:
   - les hele prompten
   - gjør STEG 0
   - gjør endringen
   - test
   - oppdater `docs/endringslogg.md`

   **Én commit per prompt**, med commit-teksten fra prompten.
3. **«STOPP» i en prompt betyr her:** commit, skriv rapporten for prompten i `docs/serie-104/RAPPORT.md`, og
   gå videre til neste. Ikke push.
4. **Ikke stopp for spørsmål.** Er noe uklart, velger du det tryggeste og minste. Skriv spørsmålet og hva du
   valgte i `SPØRSMÅL.md` under riktig nummer, og fortsett.
5. **Stopp hele serien** bare hvis en prompt ville krevd å bryte en «Skal IKKE», eller hvis et trapp-batteri
   (`_stairRegressionTest`, `_stairSideRegressionTest`, `_stairManualSetRegressionTest`,
   `_stairZoneRegressionTest102`) blir rødt og du ikke finner årsaken. Skriv da hvorfor i `SPØRSMÅL.md`.
6. **Trapper uten soner skal være uendret** gjennom hele serien, med unntak av det 106 sier om produktgruppe i
   kabellista.
7. Test bare på **dupliserte** prosjekter. Det er samme database som varmeplan.no.
8. **Ikke push.** `main` går rett ut til varmeplan.no. Kenneth pusher selv.
9. **Mål før du forklarer** (STATUS §4). En hypotese som ikke er målt, merkes som hypotese.
10. **Ikke rør kabelmotoren for rom** (`generateCableGeo` og lagene rundt). `_cableGeoSuite()` skal være grønn
    og uendret til slutt.

## Til slutt

Én samlet rapport i `docs/serie-104/RAPPORT.md`, med teskje (Kenneth er ikke utvikler):
- per prompt: hva som ble gjort, STEG 0-funn og commit-hash
- hva Kenneth skal klikke for å se hver endring, med skjermbilder i `docs/trapp/skjermbilder/`
- hvilke batterier som ble kjørt, og resultatet
- hva som står igjen i `SPØRSMÅL.md`
