# Visma Global — «Kopier til Visma»-formatet

Dokumenterer utklippstavle-formatet som `romtegner.html` bruker for «Kopier til Visma»
(`_vismaPasteBuild`/`_vismaPasteText`, se `dokumenter/`-mappen mangler ellers dokumentasjon på
dette — dette er den eneste kilden). Limes inn i et **allerede åpent tilbud** i Visma Global
(Ctrl+V i varelinjene) — kundenummer/-kobling trengs ikke, brukeren har allerede opprettet
tilbudet på riktig kunde.

## Kolonner

Tabulatorseparert, én rad per linje. Overskriftsraden er Vismas egne interne felt-ID-er, ikke
lesbare navn:

| Felt-ID | Betydning |
|---|---|
| `2269` | Artikkelnr |
| `2281` | Antall |

**Kun disse to.** `2270` (Artikkelnavn) og `2274` (Rab %) er kjente felt-ID-er (se `VISMA_FIELD` i
`romtegner.html`) men er IKKE med i utklippet — testet ut 01.09.2026, se under.

## ⚠ Fritekstlinjer virker IKKE — testet, ikke prøv igjen

Kenneth testet å lime inn en rad med tomt artikkelnummer (tenkt som en overskriftsrad, f.eks.
«VARMEFOLIE») på en varelinje i Visma Global. **Det fungerer ikke.** Nøyaktig feilmodus (avvist
rad, hele limingen avbrutt, eller noe tredje) er ikke dokumentert i detalj — konklusjonen er at
det ikke skal brukes, ikke hvorfor. Ikke bruk tid på å teste dette på nytt.

**Erstatning:** tomme rader (se under) gir den visuelle grupperingen en overskrift ellers ville
gitt.

## Tomme rader som gruppering

En «tom rad» er **én tabulator** (`"\t"`) — altså to tomme felt, ikke en helt tom streng. Det er
slik Excel kopierer en tom rad når to kolonner er markert, og holder kolonnetallet konstant på
hver rad (en rad uten tabulator har ett felt der resten har to).

Rekkefølge og plassering av tomme rader:

```
2269	2281          ← overskriftsrad
	                  ← én tom rad
<materialgruppe 1 sine linjer>
	                  ← én tom rad
<materialgruppe 2 sine linjer>
…                     ← én tom rad mellom hver ikke-tomme materialgruppe
	                  ← to tomme rader FØR tilbehør (kun når det finnes minst én materiallinje over)
	
<tilbehørslinjer>
```

- Materialgruppene følger `MATERIAL_GROUPS` (`romtegner.html`) — samme kanoniske rekkefølge som
  PDF-materiallista og XLSX Materialliste-arket.
- En gruppe uten linjer (alt i den hadde antall 0, eller gruppen ikke er i bruk) gir **ingen** tom
  rad — tomrommet oppstår kun mellom grupper som faktisk har innhold.
- Har prosjektet ingen tilbehør, slutter utklippet etter siste materiallinje — ingen
  etterfølgende tomme rader.
- Har prosjektet KUN tilbehør (ingen materiallinjer i det hele tatt) — uvanlig, men mulig: én tom
  rad etter overskriften, ikke to (det er ikke noe materialgruppe-innhold å skille tilbehøret fra).

## Rabatt

Fjernet 01.09.2026 samtidig med artikkelnavn-kolonnen (samme endring — begge var nice-to-have,
ingen av dem er del av det Visma faktisk trenger for å opprette varelinjene). `_resolveDiscountPct`
brukes fortsatt av PDF-eksporten; ikke av Visma-pasten.

## Forhåndsvisning ≠ utklipp

Dialogen i appen viser artikkelnr + **produktnavn** + antall (tre kolonner), til kontroll før
liming. Det som faktisk havner på utklippstavla er kun artikkelnr + antall (to kolonner) — navnet
er der KUN for at Kenneth skal kunne se hva han limer inn, ikke fordi Visma bruker det.

## Kildekode

`romtegner.html`: `VISMA_FIELD`, `_vismaPasteBuild()`, `_vismaPasteText()`, `_vismaPasteRender()`
(rundt linje 48850–49050 i denne økten — søk på `KOPIER TIL VISMA` for gjeldende plassering, filen
endrer størrelse ofte).
