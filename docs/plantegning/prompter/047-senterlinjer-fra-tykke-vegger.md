# 047 · Senterlinjer fra tykke vegger, `/import/plan`, dekning og rester

**Repo:** `lumelo-backend` · **Filer:** `app/geometry/`, `app/api/`, `tests/` · **Prioritet: Høy** · **Størrelse: stor**
**Spec:** `spec-plantegning.md`. Krever 046 (kontrakten). **Symbolnavnene er fasit.**

---

## Kenneths ord

> «Appen må skjønne at en vegg tegnet med tykkelse er ÉN vegg, ikke to streker og en flate.»

## Hvorfor romgjenkjenningen er dårlig på ekte tegninger

Vegger tegnes med **tykkelse**: fylte rektangler eller doble parallelle linjer. `polygonize` på
råstrekene gir derfor både rom-flater OG tynne «vegg-flater», og dører/åpninger gjør at rom
ikke lukker. Det er dette som ga «590 rom med alle lag, 10 merkelige med vegg-lagene» i 020.
Løsningen er ett steg FØR lukkingen: tykkelse → senterlinje.

## Hva som finnes — målt 08.10.2026

| | Finnes | Hvor |
|---|---|---|
| PDF-parsing | strek + tekst-labels (PyMuPDF) | `app/parsers/pdf_parser.py` |
| Romlukking | snap → node → `polygonize`, dropp ytterramme, navn fra label inni | `app/geometry/room_detection.py` (`detect_rooms`, `_name_for`) |
| Parametre | `close_gaps`, `max_aspect` | `app/api/import_pipeline.py:40–41` |
| Endepunkter | `/import/pdf`, `/import/pdf/layers`, `/import/dwg`, `/import/dwg/background`, `/import/dwg/capabilities`, `/import/dwg/layers`, `/export/ifc`, `/health` | `app/api/` |
| `/import/plan` | **finnes ikke** | bygges her |
| `coverage`, `leftovers` | **finnes ikke** | bygges her |
| Fixtures | `two_rooms.pdf`, `image_only.pdf`, `eksempel_2rom.ifc` | `tests/fixtures/` |

## STEG 0

1. **Testfila — syntetisk, ikke kundens.** Kenneths arkitekttegning (Okkenhaugvegen 20B) har
   adressen i tittelfeltet og skal **ikke** inn i git. Lag `tests/fixtures/plan_tykke_vegger.pdf`
   med reportlab/PyMuPDF: ett rektangulært rom og ett L-rom, vegger som **fylte rektangler** i
   tre tykkelser, to vegger som **doble linjer**, én dør-åpning på 90 cm, møbel-streker tynnere
   enn 0,5 pt, og tre rom-labels (nummer / navn / areal) pluss «1:100» i et tittelfelt.
   **Mål den ekte fila lokalt først** og bruk de målte tallene som mal — planens histogram
   (28 × 20 cm, 16 × 10 cm, 28 × 5 cm ved 1:100) er Coworks måling og skal etterprøves, ikke
   antas. Rapportér hva du faktisk målte.
2. **Hva gir `detect_rooms` på den syntetiske fila i dag?** Antall polygoner, og hvor mange av
   dem som er vegg-flater (tynne, høy aspect). Det er «før»-tallet 047 måles mot.
3. **Hvordan ser en fylt rektangel ut i parseren?** Er de allerede skilt fra strek (`fills` vs
   `lines`), eller må de hentes ut? Og har de bredde/høyde, eller fire hjørner?
4. **Tykkelse i punkter vs cm.** Ved 1:100 er 20 cm vegg = 2 mm på papiret = 5,67 pt. Bekreft med
   en måling på fila, for terskelverdiene i §1 under hviler på det.

## Gjør

### 1. `app/geometry/wall_centerlines.py` — nytt

```python
def centerlines(fills, lines, mpp) -> list[Wall]:
    """Tykkelse -> senterlinje. Wall = (a, b, thickness_cm, source)."""
```

- **Fylte rektangler** → midtlinje langs den lange aksen. Kilde `'rect'`.
- **Doble parallelle linjer**: avstand 5–40 cm (omregnet via `mpp`, ikke i punkter), vinkelavvik
  < 2°, overlapp > 60 % av korteste → én senterlinje midt mellom. Kilde `'double'`.
- **Enkle linjer** tynnere enn 0,5 pt ignoreres som vegg (dører, møbler, skravur). Kilde
  `'single'` for de som er tykke nok og ikke fant en partner.
- Slå sammen kollineære senterlinjer som møtes (ellers blir hver vegg mange korte).

**Terskelverdiene skal være navngitte konstanter med den målte begrunnelsen i kommentaren**, ikke
tall spredt i koden. De kommer til å måtte justeres mot nye tegninger.

### 2. Lukking

`detect_rooms` på senterlinjene i stedet for råstrekene, med `close_gaps` = dørbredde
(≤ 120 cm) og `max_aspect` for å droppe slisser. Dropp polygoner < 1,0 m².
**Ikke endre `detect_rooms` sin signatur** — den brukes av `/import/pdf` og `/import/dwg`, som
skal virke som før.

### 3. Dekning og rester

- `coverage`: andel av veggsegmentenes samlede lengde som endte i en senterlinje.
- `leftovers`: segmentene som ikke gjorde det — de blir røde prikker i appen (046).

### 4. `POST /import/plan`

Returnerer kontrakten i `spec-plantegning.md` i **ett** kall: `walls`, `rooms`, `labels`,
`calibration`, `coverage`, `leftovers`, `background`. I 047 er `labels` og `calibration`
tomme/`method:'none'` — de kommer i 048. `background` gjenbruker den SVG-veien
`/import/dwg/background` allerede har.

## Skal IKKE

- Endre `/import/pdf` eller `/import/dwg` sin oppførsel — de er i produksjon.
- Legge kundens arkitekttegning i repoet.
- Gjette tykkelsesterskler. De skal måles og begrunnes.

## Test

1. `pytest`: på den syntetiske fila gir `centerlines` **én** vegg per fysisk vegg — ikke to, og
   ikke en vegg-flate. Mål antall før/etter mot STEG 0.2.
2. Dør-åpningen på 90 cm lukkes; en åpning på 150 cm gjør det ikke.
3. Møbel-strekene blir ikke vegger.
4. `coverage` > 90 % på den syntetiske fila; `leftovers` inneholder møbel-strekene og ingenting
   annet.
5. `/import/plan` svarer med hele kontrakten, og `walls[].thickness_cm` stemmer med fila (± 1 cm).
6. `/import/pdf` og `/import/dwg` gir **samme** svar som før endringen (lås med en test).

## Rapport

STEG 0.1–0.4: hva du faktisk målte på den ekte fila (tykkelses-histogram, pt per cm), om
planens tall stemte, og «før»-tallet fra `detect_rooms`. Terskelverdiene og begrunnelsen.
Commit: «047: plantegning — senterlinjer fra tykke vegger og doble linjer, /import/plan, dekning og rester»
