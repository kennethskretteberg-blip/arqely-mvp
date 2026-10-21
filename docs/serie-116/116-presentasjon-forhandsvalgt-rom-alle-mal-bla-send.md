# 116 · Presentasjon: et rom er valgt når lenka åpner, målene på alle vegger vises, og «Send forslag» er blå

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Gren:** `main` · Linjenumre fra `ecb71c4`, men symbolnavnene er det som gjelder.

---

## Kenneths ord (21.10.2026)

> «Jeg ønsker at et rom allerede er valgt når presentasjonen åpner. Det er ikke lett å forstå at man skal trykke
> på et rom for å få opp detaljer. Jeg ønsker også at målene på alle veggene er synlig i presentasjonen. […]
> Send forslag-knappen nederst bør være BLÅ slik at den synes.»

## Hva som finnes (lest i koden)

- Presentasjon: `?present=<token>` → `_presentLoadByToken` (≈ :12001) → `_presentEnter(true)` (≈ :7966),
  `_presentRenderBar` (≈ :7922) og `_presentRenderDetail` (≈ :8810).
- Forslagslaget: `&forslag=<token>` → `_forslagStart` (≈ :8264) → `_forslagRenderBunn` (≈ :8655). Knappen
  «Send forslag» er bygd ≈ :8677.
- Mållenka (`?kunde=`, modus `'maal'`) setter `room.dimSnap = true` («kunden SKAL se målene», ≈ :9085). Det gjør
  presentasjonen trolig ikke.

## STEG 0

1. Hva er valgt når presentasjonen åpner (`S.ui.selectedRoomId`)? Hva viser `_presentRenderDetail` uten valgt
   rom?
2. Hvilke mål vises i presentasjonen i dag (`dimSnap`, `room.dims`, mållinjer)? Hva styrer det?
3. Hvilken farge har «Send forslag» i dag, og hvilken tema-token gir blått (samme blå som Varmeplans
   primærknapper)?

## Gjør

1. **Forhåndsvalgt rom:** når presentasjonen åpner, velges **første rom med produkter** (i romlistens rekkefølge).
   Finnes ingen, velges første rom. Detaljene vises med en gang, og tegningen zoomer slik at hele planen synes
   med det valgte rommet uthevet. Gjelder både ren presentasjon og forslagslenke.
   - En liten hjelpelinje i detaljene første gang: «Trykk på et annet rom i tegningen for å se det.»
2. **Mål på alle vegger:** i presentasjonen vises veggmålene for **alle** rom, med samme visning som mållenka
   (`dimSnap`). Ikke vis interne hjelpelinjer. Følg det som synes i Varmeplans egen PDF-plan.
   Tettheten må ikke bli uleselig på mobil: hvis mållinjene overlapper ved liten zoom, vis bare målene til det
   valgte rommet til man zoomer inn. Skriv valget i SPØRSMÅL.
3. **«Send forslag» blir blå** (primærfarge, hvit tekst) **når det er noe å sende**. Ellers dempet, som i dag.
   Bruk tema-token og ikke en hardkodet farge.

## Skal IKKE

- Vise flere data enn i dag (ingen priser eller interne felt).
- Endre svarformatet.
- Pushe.

## Test

1. Lag en ny presentasjon og en ny forslagslenke på en kopi. Ved åpning er et rom valgt, detaljene synes, og alle
   vegger har mål.
2. Smal skjerm (390 px): lesbart, og mållinjene klumper seg ikke.
3. «Send forslag» er blå når et valg er gjort, og dempet ellers.
4. `_kundeforslagRegressionTest` er grønn. Legg til sjekker for forhåndsvalg og mål.

## Rapport

STEG 0.1–0.3 · skjermbilder (desktop og mobil). Commit: «116: presentasjon — forhåndsvalgt rom, mål på alle vegger, blå Send forslag».
**STOPP** (se 000-KJØR-MEG).
