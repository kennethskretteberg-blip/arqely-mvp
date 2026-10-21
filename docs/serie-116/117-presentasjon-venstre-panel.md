# 117 · Presentasjon: alt samlet i ett venstre panel, som i Varmeplan (romliste, detaljer, «Hva synes du?», Send). Skuff nederst på mobil

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Gren:** `main` · **Kjøres etter 116.**

---

## Kenneths ord (21.10.2026)

> «Kanskje alt skulle stått i en venstre bar slik som vi har i Varmeplan-appen? Da er alt samlet.»

## Hva som finnes (lest i koden)

- Presentasjonen har i dag en **topplinje** (`_presentRenderBar`), et **detaljkort** (`_presentRenderDetail`) og en
  **bunnlinje** for forslag (`_forslagRenderBunn`, «Hva synes du?» ≈ :8408/:8582). Det er tre steder å se.
- Mållenka har alt et **sidepanel** (032: «KUNDESIDEN — SIDEPANEL, VEGGVALG OG LEVENDE TEGNING» ≈ :10249) og
  `_kundeRenderBar` (≈ :9177).

## STEG 0

1. Skjermbilder av presentasjon og forslagslenke i dag (desktop og 390 px). List hvert element og hvor det står.
2. Kan sidepanelet fra 032 gjenbrukes som skjelett? Hva må deles, og hva er spesielt for mål?

## Gjør

**Ett venstre panel** (desktop, ca. 320 px, fast) med, ovenfra og ned:
1. **Prosjekt**: navn og avsender (`orgName`). Det som står i topplinja i dag, minus det som skal bort.
2. **Romliste**: alle rom med navn, areal og produkt. Det valgte rommet er uthevet. Klikk velger rommet og zoomer
   til det, akkurat som klikk i tegningen.
3. **Valgt rom**: dagens detaljkort (produkt, effekt, flateeffekt, mål).
4. **Hva synes du?** for valgt rom: dagens valg (OK, annet produkt, kommentar).
5. **Nederst, alltid synlig:** status («2 av 4 rom vurdert») og den blå **Send forslag** (116).
6. **Plass for «Endre mål»** (bygges i 118): en tom seksjon er nok.

Tegningen fyller resten. Topplinje og bunnlinje forsvinner eller blir minimale, med bare det som ikke passer i
panelet (f.eks. videohjelp).

**Mobil (< 760 px):** panelet blir en **skuff nederst** som kan dras opp. Lukket viser den valgt rom +
Send-knappen, og åpen viser den hele panelet. Tegningen får resten av skjermen.

**Én komponent** for presentasjon og forslagslenke (og gjerne mållenka). Lag ikke tre paneler. Ren presentasjon
(uten `&forslag=`) viser 1–3 og ingen Send.

## Skal IKKE

- Endre hva kunden får se av data, eller endre svarformatet.
- Endre Varmeplans eget sidepanel for innloggede brukere.
- Pushe.

## Test

1. Presentasjon og forslagslenke på desktop og 390 px: alt er samlet, ingenting er borte, og Send virker.
2. Klikk i romlista og i tegningen velger samme rom.
3. Et forslag kan sendes fra start til slutt fra panelet, og svaret kommer fram hos Kenneth som før.
4. `_kundeforslagRegressionTest` og batteriene for mållenka er grønne.

## Rapport

STEG 0 · skjermbilder før og etter (desktop og mobil, skuff lukket og åpen). Commit: «117: presentasjon — ett venstre panel (romliste, valgt rom, Hva synes du, Send); skuff på mobil».
**STOPP** (se 000-KJØR-MEG).
