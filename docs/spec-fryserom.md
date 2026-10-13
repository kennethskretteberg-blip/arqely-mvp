# Spec: Fryserom og kjølerom

Gjelder romtypen `fryserom` («Fryserom/kjølerom»). Reglene er **ikke** valgt av oss — de kommer fra
en bindende leverandørgodkjenning og to produsentveiledninger.

---

## Kilder

| | Dokument | Rolle |
|---|---|---|
| **BL-001** | Thermopads, 22.03.2026 (e-post, mappe 22 → «01 - Bekreftede løsninger.md») | **Bindende for Cenika.** CVA-veiledningene sier ingenting om fryserom, så denne godkjenningen er det som gjelder. |
| DEVI | VGLUB102 s. 8–10 | Produsentramme |
| Nexans | Varmehåndboka 2020–21, del 2 s. 20 | Produsentramme |

## BL-001 i korthet

- **Produkt:** InFloor 10T (10 W/m) er godkjent for frostsikring av fryseromsgulv.
- **Utlegg:** c/c **40 cm** → ca. **25 W/m²** (10 × 100 / 40).
- **Reserve:** hovedkabel + reservekabel med **2,5–5 cm** mellomrom, styrt av **to termostater med
  alarm**. Godkjent i prinsippet; forbehold om at systemdesignet valideres.
- **Plassering:** minst **50 mm** ned i sand/grus under isolasjonen er lov; Thermopads **anbefaler
  innstøping i betong**.
- **Ansvar:** design, effekt og montasje ligger hos den som prosjekterer anlegget.

## Rammene, og hva vi bruker

| | DEVI VGLUB102 s. 8–10 | Nexans del 2 s. 20 | **Vi bruker** |
|---|---|---|---|
| Effekt | 15–30 W/m², minst 15 | 10–15 W/m² | **15–30**, standard **25** |
| c/c | maks **50 cm**, anbefalt 33 | 50–70 cm | **30–50 cm**, standard **40** |
| Reserve | **påkrevd**, parallell, 2,5–5 cm | anbefalt | **påkrevd**, 2,5–5 cm |
| Styring | termostat per kabel: hoved +5 °C, reserve +3 °C med alarm | føler i kabeldybde, midt mellom strenger, i rør | **appen sier ingenting** om termostater (Kenneth 13.10.2026); kun Nexans' følerplassering |
| Kurs | egen kurs, eget vern og jordfeilvern per kabel | — | som DEVI |
| Kontroll | P = Δt × U × 1,3 (U = λ / tykkelse) | — | **ikke medtatt i appen** (Kenneth 13.10.2026) — står her som referanse |

### Hvorfor Nexans' c/c 50–70 ikke brukes

Nexans tillater opptil 70 cm. **DEVI setter maks 50**, og BL-001 — den bindende godkjenningen —
legger seg på 40. Vi følger den strengeste: **aldri over 50 cm**. Fra Nexans bruker vi kun
følerplasseringen (i rør, i kabeldybde, midt mellom to strenger).

Nexans' effektområde (10–15 W/m²) er tilsvarende forlatt til fordel for DEVIs 15–30: 10 W/m² er
dessuten fysisk uoppnåelig med en 10 W/m kabel innenfor 50 cm c/c (se under).

---

## Slik er det bygget

| Regel | Hvor |
|---|---|
| Standard 25 W/m², område 15–30, c/c 30–50 | `ROOM_TYPES.fryserom` + `room_type_defaults` (global) |
| Fysisk gulv (ingen kabel kan gi mindre) | `_cableWm2Floor` — 10 W/m ved maks 50 cm = **20 W/m²**, så det effektive området er 20–30 |
| c/c 40 som standard | **Lagres ikke.** CC utledes av målet og kabellengden i `_autoFillCableImpl`; 25 W/m² gir 40 cm av seg selv. Én kilde: rommets `targetWm2`. |
| Reserveavstand 5 cm | `RESERVE_OFFSET_CM`, klemt til `min(…, cc/2)` |
| Reserve påkrevd | `reserveCable` på romtypen; avvik varsles, blokkeres ikke |
| Avvik (reserve av, feil produkt, knapp effekt) | `_fryseromAvvik` — én kilde for skjerm og PDF |
| Montasjetekst | `_fryseromMontasjeLinjer` — én liste, skjerm og PDF |

---

## Avklart 13.10.2026 (Kenneth)

- **Varmetapskontrollen** (P = Δt × U × 1,3): **ikke medtatt.** Ble bygget og fjernet igjen.
  Formelen står i tabellen over som referanse for den som prosjekterer — appen regner den ikke.
- **Termostater:** appen skal **ikke nevne noe om termostater**. DEVIs krav (hoved +5 °C,
  reserve +3 °C med alarm) er derfor ute av montasjeteksten, og ingen termostater eller
  alarmmodul legges i materiallista.
- **Ekstra strenger langs yttervegger** (c/c 5–7,5 cm) og **varme ved søylefot**: appen gjør
  **ingen av delene** — verken forslag eller omtale.

Det appen sier om montasje er dermed kabelavstand, kurs/vern, dybde og følerplassering — se
`_fryseromMontasjeLinjer`.
