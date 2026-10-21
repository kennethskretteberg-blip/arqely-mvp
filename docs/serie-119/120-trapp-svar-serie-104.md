# 120 · Trapp, svar på SPØRSMÅL fra serie-104: alle soner starter på samme side som sone 1, tallfelt «Antall kabler» i sonen, og auto kan foreslå to kabler i en sone når én ikke holder

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Gren:** `main`. Svar skrives i `docs/serie-104/SPØRSMÅL.md`.
**Spec:** `Claude Cowork/Romtegner/Romtegner/spec/spec-trapp-kabelutlegg.md`, Regel 14, 19, 21 og 22.

---

## Kenneths svar (21.10.2026)

| | Svar |
|---|---|
| 104/1 | **Alle soner starter på samme side som sone 1** (tilkoblingskablene samles på én side av trappa) |
| 104/2–4 | OK |
| 105/1–3 | OK |
| 105/4 | Løst av 111 (fast 20 cm-tak fjernet). Bekreft og skriv det |
| 105/5 | **Ja: samme låst/auto-modell på trappenivå.** Se punkt 4 |
| 106/1–4 | OK |
| 106/5 | **Ja: tallfelt «Antall kabler» i sonen** |
| 106/6 | **Ja: auto kan foreslå to kabler i en sone, men bare når ingen enkeltkabel holder 75 %-grensen** |

## STEG 0

1. **104/1:** hvilken side starter hver sone på i dag (paritetskjeden)? Hva koster det å tvinge samme side som
   sone 1: en ekstra overgang eller et halvt løp? Mål det på trappa fra 104 (4 trinn / repos / 6 trinn) og på én
   med to trinn-soner.
2. **105/5:** «Avstand sider» på trappenivå er gulvet for Forslag (084), mens sonen har låst/auto (105). Hva betyr
   «låst» for Forslag? Forslag skal da løse med **fast** margin og bare variere kabelsettet, ikke marginen.
3. **106/6:** hvor i `_stairSolveZones` velges auto med `maxCables:1`, og hva returnerer
   `_stairSolveExactCableSet` når ingen enkeltkabel holder 75 %?

## Gjør

1. **Samme startside:** hver sones kabel starter på **samme side (venstre/høyre) som sone 1** og nederst i sonen
   (Regel 14 per sone, 104). Gjelder plan, sidevisning og PDF (én kilde, `_stairCableEndpoints`). Spec: ny linje
   under Regel 21.
2. **«Antall kabler» i sonen:** tallfelt over kabellista i sonepanelet. Det virker som på trappenivå (legger til
   rader med kopi av siste, eller fjerner bakfra). Tomt = auto.
3. **Auto med to kabler i en sone:** når auto for en sone ikke finner én kabel innenfor 75 %-grensen (Regel 19),
   prøver auto **to** kabler (samme produktgruppe, `maxCables: 2`) før sonen får feil. Panelet sier «Auto: 2 kabler
   (én rakk ikke)». Regel 21 i spec: «Auto gir én kabel per sone, eller to når én ikke holder 75 %.»
4. **Låst/auto på trappenivå** (trapp uten soner og «Hele trappa»):
   - **Tomt felt** = dagens oppførsel. Gulvet er brukerens minimum, og Forslag/manuelt løser marginen
     (084/Regel 12).
   - **Tall med hengelås** = låst. Marginen brukes nøyaktig, Forslag varierer bare kabelsettet, og for
     kort/for lang vises som i 105 (stiplet rødt).
   - Eksisterende trapper skal oppføre seg som før (migrering som i 105: gammelt `edgeMarginMin_cm` = gulv). Spec:
     Regel 22 gjelder også trappenivå.

## Skal IKKE

- Endre strengantall, CC eller ruting utover startsiden.
- Endre trapper uten soner utover punkt 4.
- Pushe.

## Test

1. Trapp med 3 soner: alle starter på samme side som sone 1, nederst i sonen. Tabell før og etter med ekstra
   lengde.
2. Sone med «Antall kabler» = 2: to rader, og begge legges ut.
3. Sone der ingen enkeltkabel holder 75 %: auto gir 2 kabler, med meldingen i panelet.
4. Trapp uten soner: tomt felt = som før, låst 6 cm = 6 cm og for kort/lang vises. Forslag med låst margin
   varierer bare kabelsettet.
5. Alle trapp-batterier grønne, og nye sjekker for 1–4. `_pdfExportSmokeTest` grønn.

## Rapport

STEG 0 (særlig kostnaden ved samme side) · svar skrevet inn · spec-linjene. Commit: «120: trapp — alle soner starter på samme side som sone 1, Antall kabler i sonen, auto 2 kabler når 1 ikke holder 75 %, låst/auto også på trappenivå».
**STOPP**.
