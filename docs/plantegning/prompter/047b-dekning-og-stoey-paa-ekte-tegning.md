# 047b · Dekning og røde prikker som betyr noe på en ekte tegning

**Repo:** `lumelo-backend` · **Prioritet: Høy** · **Størrelse: liten**
**Grunnlag:** målingene i 048 mot Kenneths ekte A2-tegning. Krever 047 + 048.

---

## Hva målingen viste

Kenneth la ved `Forprosjekt golvplan 23.09.26.pdf` (A2, 1:100, 11 174 segmenter). 047 ble
bygget mot en syntetisk fixtur, og holdt ikke:

| | Syntetisk | Ekte |
|---|---|---|
| dekning | 95,3 % | **13,2 %** |
| rester («røde prikker» i 046) | 3 | **10 489** |
| `single`-vegger (tykkelse 0) | 0 | **116** |

**6795 av 10 489 rester er kortere enn 10 cm** — skravur, tekstkonturer, symboler.

## Rotårsaken — to feil i samme definisjon

`coverage` og `leftovers` er begge definert mot **alle** strek på siden:

```python
kand_idx = {i for i, _ in kandidater}
leftovers = [s for i, s in enumerate(segments) if i not in kand_idx and not _on_rect_edge(...)]
coverage = brukt / (brukt + rest)
```

1. **Nevneren er feil.** `total_length` måler «hvor mye av tegningen er vegg» — på en
   arkitekttegning er det ~13 % av natur. Den gule advarselen i 046 ville fyrt alltid.
2. **`leftovers` er snudd.** Den inneholder nøyaktig det motsatte av det den burde: alt som
   ALDRI var en vegg-kandidat. De 10 489 røde prikkene i appen ville vært skravur, ikke steder
   motoren ga opp. Den ene informasjonen brukeren trenger — «her fant jeg en lang strek jeg
   ikke klarte å pare» — finnes ikke.

## Gjør

### 1. Snu `leftovers`

`leftovers` skal være **kandidater som ikke ble vegg** — altså segmenter som var lange nok og
tykke nok til å kunne vært en vegg, men som motoren ikke klarte å pare. Ikke-kandidater
(kort/tynn støy) ignoreres helt: verken vegg eller rest.

### 2. `coverage` mot kandidatene

`pct = vegglengde / (vegglengde + restlengde)` med den nye rest-definisjonen. Da betyr tallet
«av det som så ut som vegg, hvor mye ble vegg» — som er det 046 viser.

### 3. `single` av som standard

Parameter `allow_single: bool = False`. En uparet linje er ikke bevis på en vegg på en ekte
tegning — 116 av dem var målsettingsmerker, de fleste 50 cm. De blir rester i stedet, altså
synlige som røde prikker der brukeren kan tegne veggen selv.

## Skal IKKE

- Endre terskelverdiene (`MIN_WALL_CM` osv.) — de er ikke problemet her.
- Filtrere på lag. Lag-velgeren finnes allerede og er brukerens valg.
- Røre `/import/pdf` eller `/import/dwg`.

## Test

1. Syntetisk fixtur: dekning fortsatt > 90 %, og restene er fortsatt de tre støy-strekene
   (de er under minstelengden, så de skal nå forsvinne helt — rest = 0).
2. Ekte tegning (`local/`, manuelt): dekning skal bli et tall som faktisk sier noe, og
   antall rester skal falle fra 10 489 til noe en bruker kan se på.
3. `allow_single=True` gir fortsatt den gamle oppførselen (låst med test).
4. Hele `pytest` grønn.

## Rapport

Før/etter-tall på begge filene. Commit: «047b: plantegning — dekning og rester måles mot vegg-kandidater, ikke mot hver strek på siden; single av som standard»
