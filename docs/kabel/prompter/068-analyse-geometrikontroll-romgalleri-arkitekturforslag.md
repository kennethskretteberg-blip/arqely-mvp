# 068 · Kabelmotor fase 1–2: hvorfor dagens motorer bryter harde regler (målt), felles geometrikontroll, romgalleri som måleinstrument, arkitekturforslag — **STOPP etter rapport**

**Worktree `kabelmotor`.** Fil `index.html`. Linjenumre fra `1519bb0` — symbolnavn er fasit.
Spec: `docs/kabel/spec-kabelmotor.md`. **Erstatter** enkeltprompten `068-kabelmotor-orden-…md`.

---

## Kenneths ord

> «Jeg forstår ikke at kablene i bildet kan krysse hverandre, ha forskjellige CC-avstander og krysse
> vegger? Her er det brudd på minst tre harde regler.»

Rom «Bad», 5,89 m², InFloor 17T 800 W 47 m, label «CC 11,1 cm». Skrå toppvegg, smalt hakk inn fra
venstre vegg midt på, trinn nede til høyre. Synlig: brudd/åpne ender over og under hakket, løp med
ca. halv CC under hakket, U-svinger som går ut over veggen nede og ved trinnet, en rett strekning
langs veggen ved trinnet, svinger helt inntil den skrå veggen. Ingen advarsel.

**Viktig ledetråd (Kenneth, samme dag):** *samme kabel i samme rom lagt **horisontalt** legger seg
perfekt* — én sammenhengende slynge, CC 12,5 cm, 136 W/m² flate, alle svinger innenfor. Feilene
oppstår altså **bare i vertikal retning**, der hakket kutter løpene i to og motoren må dele rommet
i celler og sy dem sammen. I horisontal retning går hvert løp uavbrutt langs hakket. Det peker rett
på celleoppdelingen og overgangene mellom celler (lag B–D), ikke på CC-regningen eller produktet.

## Det vi vet fra koden

`_autoFillCableImpl` (:26638) er en kaskade: skew → boustrophedon → V6 → serpentine. Hver motor har
sin **egen** akseptregel og ingen av dem måler resultatet mot de harde kravene i spec §1:

- skew godtas ved `coverage ≥ 0,70` og `openLen < spacing × 1,5` (:26800-området) — altså er
  «hopp» opptil 1,5 × CC lov.
- V6 sveiper hver celle for seg (`_v6SweepCell(c, …, spacing, …)` :25976). Samme CC, men **hver
  celle plasserer løpene ut fra sin egen kant** → naboceller får forskjøvet fase, og der to celler
  møtes kan løp havne nær hverandre (sannsynlig kilde til «halv CC»).
- En U-sving tegnes som halvsirkel med radius CC/2 **utenfor** løpets ende. Ender løpet på
  kantmarginen, stikker svingen CC/2 forbi margen — inn i eller gjennom veggen.
- V6s `validation.warnings` brukes som poeng, ikke som avvisning.
- `_finishCableAutoFill` (:26566) måler areal- og lengdegap, ikke kryssing, klaring eller
  kontinuitet.

## STEG 0 — mål, ikke anta

1. **Rekonstruer badet.** Finn Kenneths rom (Bad ≈ 5,89 m², InFloor 17T 800W 47m) i prosjektene
   (lesende). Kopier punkter, hindringer og soner til fixture `_cableFixtures.badHakk` — bare
   geometri. Finnes det ikke: skriv i SPØRSMÅL og be Kenneth om prosjektnavnet; fortsett med en
   rekonstruksjon etter skjermbildet merket «tilnærmet».
2. Kjør **hver motor for seg** (skew, boustrophedon, V6, serpentine) på fixturen, **begge
   retninger**, og kaskaden som helhet. Hvilken motor vant **vertikalt** (feil) og hvilken
   **horisontalt** (perfekt)? Er det samme motor? Det horisontale utlegget blir **referansen** for
   badHakk: det skal bestå kontrollen, og det skal være uendret gjennom hele serien.
3. For hvert resultat: tell **kryssinger**, **åpne ender**, **minste klaring** (alle kabeldeler mot
   hverandre), **CC min/maks** mellom naboløp, **lengste strekning utenfor lovlig område**, **sving
   med radius < min_bend**, lengdeavvik.
4. Pek på **linjen/funksjonen** der hver feil oppstår (fase per celle? svingplassering? overgang
   mellom celler? klipping mot skrå vegg?).
5. **Dataformat:** list hvilke felt på kabelobjektet som leses av `_computeRoomStats`, labelen,
   materialliste, PDF, flerkabel-soner (`_autoFillNCables`), fryserom-reserve (`_offsetCableClone`),
   manuell redigering og lagring — for både `runs`-form og `pathEls`-form. Dette blir kontrakten
   den nye motoren må levere.

## Gjør

### 1. `_cableGeometryCheck(cable, room)` — ren lesing, alle formater

Returnerer `{ ok, hard: [...], soft: [...], metrics }`. Hver defekt: `{ kind, at:{x,y}, value, msg }`.

**Harde (spec §1):** `utenfor` (> 1 cm utenfor lovlig område), `kryssing` (kabelen krysser seg
selv), `naerforing` (to kabeldeler < `min_spacing_mm`, også sving mot løp), `boy` (radius <
`min_bend_radius_mm`), `lengde` (avvik > 1 %), `cc` (global CC utenfor tillatt intervall),
`brudd` (gap > 1 cm mellom elementer, eller mer enn to frie ender).

**Myke:** `cc_variasjon` (naboløp < 0,8 × CC eller > 1,25 × CC over > 50 cm), `kant_asymmetri`,
`hopp` (rett overgang > 1 × CC som ikke er sving/løp), `dekning`.

**`metrics`:** lagt lengde, produktlengde, CC min/median/maks, minste klaring, minste radius, antall
kryssinger, antall åpne ender, dekning %.

Lovlig område beregnes med et pinnet polygonbibliotek fra CDN (spec §0.6) — legg det inn her, siden
kontrollen trenger offset. Rapportér valg og versjon.

### 2. Romgalleri

`_cableGalleryRun()` kjører kaskaden **og** hver motor for seg på alle fixture-rom × begge retninger
× relevante produkter, og gir én tabell: rom · motor · ok/feil · harde defekter · metrics.
Fixtures (spec §6): rektangel, L, U, én hindring, flere hindringer, smal passasje, utsparing,
asymmetriske vegger, kabel for lang, kabel for kort, bøyeradius umulig, umulig starthjørne,
**badHakk**. Skrå vegg (`skraa`) tas med for å måle skew, men er utenfor ny motor (spec §0.5).

`docs/kabel/galleri.html`: generert av en hjelpefunksjon (`_cableGalleryExportHtml()`), som tegner
hvert utlegg (SVG) med røde markeringer på harde defekter og tallene under. Ingen byggesteg.

**Galleriet er måleinstrumentet** for resten av serien. Kjør det nå og legg tabellen i rapporten som
«før».

### 3. Ingen endring i oppførsel ennå

Kontrollen og galleriet **leser** bare. Kaskaden endres ikke i 068 (det skjer i 070). Unntak: logg
`[cable-check]` i konsollen når `S.ui.debugCableEngine` er på.

### 4. Arkitekturforslag (`docs/kabel/arkitektur.md`)

Basert på målingene: hvordan lag A–H (spec §4) bygges, hva fra V6 som kan gjenbrukes
(`_v6BuildHeatableArea`, `_v6AnalyzeTopology`, `_v6DecomposeCells`?) og hva som må nytt, særlig
**global fase (lag C)** og **svinger innenfor lovlig område (lag E)**. Hvilket dataformat motoren
leverer (fra STEG 0.5). Hvilke romklasser den skal ta i 070. Anslag på størrelse. Risikoer.

## Skal IKKE

- Endre noen motor eller kaskaden.
- Senke terskler for å få færre feil.
- Bygge den nye motoren (det er 069).

## Rapport — og STOPP

Til Kenneth, kort og med teskje: hvilken motor laget badet, hvorfor reglene ble brutt (én setning per
regel), galleritabellen «før», og arkitekturforslaget i tre–fem punkter. Commit:
«068: kabelmotor — geometrikontroll for harde krav, romgalleri med badHakk, analyse og
arkitekturforslag». **Stopp. 069 kjøres først når Kenneth har lest og sagt ja.**
