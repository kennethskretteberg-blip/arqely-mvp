# Trapp-serien 084–087 · kjøre-instruks for Claude Code

**Repo:** `~/Code/arqely-mvp` · **Gren: `main`** (ikke kabelmotor-worktreen).
Promptene ligger i samme mappe som denne fila (`docs/trapp/prompter/`).

> Nummer: 077–083 er brukt på grenen `kabelmotor`. Denne serien er 084–087 og gjelder bare `main`.

| # | Fil | Hva | Størrelse |
|---|---|---|---|
| 084 | `084-trapp-alltid-forslag-med-en-kabel-kantavstand-justeres.md` | Alltid et forslag med én kabel; kantavstand justeres; brukerens kant er gulv | liten–middels |
| 085 | `085-trapp-pdf-sidevisning-og-malsatt-trapp-begge-visninger.md` | Sidevisning i PDF; trappen målsatt i plan og side | middels |
| 086 | `086-trapp-raster-kan-skrus-av.md` | Raster-knappen også i trappmodulen | liten |
| 087 | `087-trapp-mallinje-blir-staende-som-innendors.md` | Mållinje (D) virker i trappmodulen og blir stående | liten–middels |

## Slik kjører du

1. **Sjekk først:** `git log --oneline -20`. Er en prompt allerede kjørt (commit som begynner med
   «084:», «085:» …), hopper du over den og skriver det i rapporten.
2. Kjør i rekkefølge **084 → 085 → 086 → 087**. Hver prompt for seg: les hele, gjør STEG 0, gjør
   endringen, test, oppdater `docs/endringslogg.md`, **én commit per prompt** med commit-teksten fra
   prompten.
3. **Ikke stopp for spørsmål.** Er noe uklart: velg det tryggeste/minste, skriv spørsmålet og hva du
   valgte i `SPØRSMÅL.md` (under riktig nummer), og fortsett.
4. **Stopp serien** bare hvis en prompt ville krevd å bryte en «Skal IKKE», eller hvis en
   eksisterende test blir rød og du ikke finner årsaken. Skriv da hvorfor i `SPØRSMÅL.md`.
5. Test bare på **dupliserte** prosjekter — samme database som varmeplan.no.
6. **Ikke push.** Kenneth pusher selv når han har sett resultatet.

## Til slutt

Én samlet rapport, med teskje (Kenneth er ikke utvikler):
- per prompt: hva som ble gjort, STEG 0-funn, commit-hash
- hva Kenneth skal klikke for å se hver endring (trapp-delen på en duplisert kopi)
- skjermbilde av forslagspanelet (084), PDF-siden med sidevisning (085), verktøylinja i trapp (086/087)
- hva som står igjen i `SPØRSMÅL.md`
