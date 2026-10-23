# 126 — Visma-eksport (GBAO10): «Ferdig» og «Eksporter på nytt» etter eksport

Kjørt 23.10.2026 på `main` fra `829be8a`. Ikke pushet. Skjermbilder i `skjermbilder/` (headless Chrome,
fikstur med ett folieprodukt, kunde 38156, nedlastingsveien).

## STEG 0 — målt før endring

### 0.1 Knappene etter eksport, og et nytt trykk
Målt i nettleseren (`00-foer-endring-etter-eksport.png`): etter «✓ Lastet ned» sto knappene uendret —
«Eksporter» (blå) og «Avbryt». Et nytt trykk på «Eksporter»:
- **Nedlasting:** laster ned samme fil en gang til, uten spørsmål. Tidsstempelet er frosset ved
  åpning (`_gbao10Stamp`), så filnavnet er identisk; nettleseren legger på « (1)».
- **Mappe:** `_gbao10WriteToFolder` spør aldri om overskriving — fins fila, skrives `…_2.txt`,
  `…_3.txt` (kollisjonsvernet fra 012) med en info-toast. Grenen «Avbrutt.» i `_gbao10Export`
  (`if (!wrote)`) er derfor **død kode** i dag; `_gbao10WriteToFolder` returnerer alltid `true`.
  Beholdt og koblet til tilstanden likevel, i tilfelle en framtidig overskrivingsdialog.
- **Esc** lukket ikke dialogen (målt: overlayet sto). Den globale tastehåndtereren kjenner ikke
  `cust-overlay`-dialoger.

### 0.2 Andre eksportdialoger med samme mønster
| Dialog | Knapper | Etter handlingen |
|---|---|---|
| PDF (`export-dialog`) | «Avbryt» + «Generer PDF» | `_runExportPDF` **skjuler dialogen** før PDF-en lages — ingen knapp står igjen. OK. |
| XLSX | ingen egen dialog | bare tilbehørsdialogen («Avbryt» + «Generer rapport →»), som lukkes ved bekreftelse. OK. |
| Kopier til Visma (`visma-paste-overlay`) | «Lukk» + «Kopier N linjer» | lukkes ved vellykket kopiering; ved clipboard-feil står den åpen med tekstfelt og «Lukk» — riktig ord. OK. |
| Tilbehør (`modal-accessories`) | «Avbryt» + «Generer rapport →» | lukkes ved bekreftelse. OK. |
| **GBAO10** (`gbao10-export-overlay`) | «Eksporter» + «Avbryt» | **sto igjen uendret** — den eneste med problemet. Rettet her. |

## Gjort

- `_gbao10SetDone(done)` — **én** funksjon skriver knappetekst og stil: før = «Eksporter» (blå,
  `dash-create-btn`) + «Avbryt» (`npc-btn-ghost`); etter = «Eksporter på nytt» (sekundær) +
  «Ferdig» (blå). `_gbao10RenderDialog` kaller den etter hver gjenoppbygging, så tilstanden
  overlever type-bytte/merking/EL-valg innenfor samme åpning. Ny åpning nullstiller.
- `_gbao10Export`: begge suksessveiene (mappe og nedlasting) → `_gbao10SetDone(true)`. Alle feilveier
  (ingen tilgang, unntak, avslått) → `_gbao10SetDone(false)`, også etter en tidligere suksess.
  «Eksporter på nytt» gjør nøyaktig det samme som «Eksporter» (samme funksjon).
- **Esc** lukker i begge tilstander: `_gbao10OnKey` registreres i fangstfasen ved åpning
  (`_gbao10OpenOverlay`) og fjernes i `_gbao10Close`. Alle fem lukkeveiene (×, Avbryt/Ferdig, klikk
  utenfor, Rediger kunde, Rediger prosjekt) går nå gjennom `_gbao10Close` — ingen direkte `.remove()`.
- Filinnhold, filnavn og mappevalg er urørt.

## Test

| Nr | Krav | Resultat |
|---|---|---|
| 1 | Mappe: «Eksporter på nytt» + «Ferdig»; Ferdig lukker | ✓ via test D (tilgangsnekt-veien) + samme `_gbao10SetDone(true)` som nedlasting |
| 2 | Nedlasting: samme | ✓ (`02-etter-eksport.png`, Ferdig lukker målt) |
| 3 | Avslå overskriving: knappene uendret, «Avbrutt.» | grenen finnes og setter tilbake, men kan ikke utløses i dag (se 0.1) — testet med tilgangsnekt i stedet |
| 4 | Esc lukker før og etter | ✓ (målt begge, før endring lukket Esc ikke) |
| 5 | `_gbao10RegressionTest` grønn med ny sjekk på knappetekst | ✓ 21/21, hvorav 11 nye i del D |

Del D er async (nedlasting fanges ved å stubbe `HTMLAnchorElement.prototype.click`, mappe-veien
ved å stubbe `_gbao10EnsureWritePermission` til «nei»). Kjør `await _gbao10RegressionTest().async`
for alle sjekkene; det synkrone returobjektet dekker A–C og de synkrone D-sjekkene.
`_accessoryFoilQtyRegressionTest` (125) fortsatt grønn (38/38).

## Endrede symboler
Nye `_gbao10Done`, `_gbao10SetDone`, `_gbao10OnKey`, `_gbao10Close`, `_gbao10OpenOverlay` ·
`_showGbao10ExportDialog` (bruker `_gbao10OpenOverlay`) · `_gbao10RenderDialog` (knapp-id-er, lukking) ·
`_gbao10EditCustomer` · `_gbao10Export` · `_gbao10RegressionTest` (del D).
