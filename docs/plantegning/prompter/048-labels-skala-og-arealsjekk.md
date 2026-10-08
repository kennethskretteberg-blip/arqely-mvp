# 048 · Labels → nummer/navn/areal, skala fra tittelfeltet, arealsjekk per rom

**Repo:** `lumelo-backend` · **Filer:** `app/geometry/`, `app/parsers/`, `tests/` · **Prioritet: Høy** · **Størrelse: middels**
**Spec:** `spec-plantegning.md`. Krever 047. **Symbolnavnene er fasit.**

---

## Kenneths ord

> «Står det «102 Kjk./stue 25,7 m²» på tegningen, skal rommet hete det. Og da vet vi også om
> vi traff — vårt areal mot deres.»

## Hva som finnes — målt 08.10.2026

| | Finnes | Hvor |
|---|---|---|
| Tekst-labels fra PDF | ja, med posisjon | `app/parsers/pdf_parser.py` |
| Navn fra label inni polygon | `_name_for(poly, labels)` | `app/geometry/room_detection.py:73` |
| Måleverdi-filter (`3.45`, `1.90 m`) | ja, i dagens navnelogikk | samme fil |
| `scale_from_labels` | **finnes ikke** | bygges her |
| `stated_area_m2` på rom | **finnes ikke** | bygges her |

## ⚠ Skala fra arealer er dimensjonalt feil — og sirkulær

Planens utkast sa «median av `stated_area / polygon_area` → `meters_per_point`». To feil:

1. **Dimensjon.** `stated_area` er m², `polygon_area` er punkter². Forholdet er m²/pt², så
   `meters_per_point = sqrt(stated_area / polygon_area)`. Uten kvadratroten er skalaen feil med
   en faktor som vokser med rommets størrelse.
2. **Sirkularitet.** Den hviler på at polygonet er riktig — som er nøyaktig det som er usikkert
   før veggene er sjekket. Et rom som ikke lukket seg riktig gir en skala som er helt gal, og
   den feilen forplanter seg til ALLE mål.

**Derfor: tittelfeltet er primærkilden, arealene er kryss-sjekk.** Ikke omvendt.

## STEG 0

1. **Hvordan ser en rom-label ut i råteksten?** På den syntetiske fila (047) og på den ekte
   lokalt: er «102», «Kjk./stue» og «25.7 m²» tre separate tekstlinjer, eller én? Hva er
   linjeavstanden i punkter? Rapportér — grupperingen i §1 hviler på det.
2. **Finnes «1:100» som tekst, og hvor?** Er den i et tittelfelt nederst til høyre, og i hvilket
   format («1:100», «1 : 100», «M 1:100»)? Hvor mange treff gir et søk på hele siden?
3. **Hva filtrerer dagens navnelogikk bort i dag?** Les `_name_for` og list reglene, så 048
   utvider dem i stedet for å lage et parallelt filter.

## Gjør

### 1. Labels → rom-label

Grupper tekstlinjer vertikalt (innenfor den målte linjeavstanden × 1,8) til én `RoomLabel`:
`{ id, number, name, stated_area_m2, at }`. Nummer = en ren tallgruppe på egen linje
(`102`, `A515`); areal = tall + `m²`; navn = resten. Måleverdier filtreres som i dag — bruk
`_name_for` sine eksisterende regler, ikke nye.

### 2. Skala

```python
def scale_from_title(texts) -> tuple[float, str] | None   # «1:100» -> mpp, '1:100'
def scale_from_areas(rooms) -> float | None               # sqrt(median(stated/poly))
def resolve_calibration(texts, rooms) -> Calibration
```

`resolve_calibration`:
- Tittelfelt funnet → `method='title'`, `confidence=0.9`. Arealene regnes likevel ut og legges i
  `area_ratio_mpp` som kryss-sjekk.
- Avviker de to med mer enn **3 %** → `confidence=0.5` og `method='title'` (tittelen vinner),
  så appen kan si «sjekk målestokken».
- Ingen tittel → `method='areas'`, `confidence=0.6`.
- Verken tittel eller arealer → `method='none'`, `confidence=0`, og appen ber om målestrek.

### 3. Arealsjekk per rom

`rooms[].stated_area_m2` og `rooms[].area_ok` = `abs(poly - stated) / stated <= 0.05`.
Avvik over 5 % er den beste gratis kvalitetskontrollen vi har — den skal **returneres**, ikke
rettes opp automatisk.

## Skal IKKE

- Skalere geometrien etter arealene. Skalaen er ÉN verdi for hele siden; et enkelt rom som ikke
  stemmer er et varsel, ikke en korreksjon.
- Lage et parallelt navnefilter ved siden av `_name_for`.
- Røre `/import/pdf` / `/import/dwg`.

## Test

1. Tre-linjers label blir ett rom med `number='102'`, `name='Kjk./stue'`,
   `stated_area_m2=25.7`.
2. «3.45» og «1.90 m» blir ikke romnavn (lås dagens regler med en test).
3. `scale_from_title('1:100')` gir samme `mpp` som en kjent strek på fila (± 1 %).
4. **Kvadratroten:** et rom på 25,7 m² som er 2 000 pt² gir `mpp = sqrt(25.7/2000) = 0.1134`,
   ikke `0.01285`. Egen test på nettopp dette, med tallene i.
5. Tittel og arealer som avviker 10 % → `confidence=0.5`, `method='title'`.
6. Rom der polygonet ble 31,2 m² mot oppgitt 25,7 → `area_ok=False`.

## Rapport

STEG 0.1–0.3 (label-formen og linjeavstanden du målte, hvor «1:100» sto, dagens filterregler),
og hvilken `method` den ekte fila endte på. Commit: «048: plantegning — rom-labels med nummer/navn/areal, skala fra tittelfeltet med arealene som kryss-sjekk, arealsjekk per rom»
