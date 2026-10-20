# 104 · Trapp: hver sone legges nedenfra og opp, som sone 1. I dag starter sone 2 (repos) i motsatt ende, så kabelendene fra sone 1 og sone 2 møtes ett trinn fra hverandre

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Gren:** `main` · Linjenumre fra `2cbc31f`, men symbolnavnene er det som gjelder.
**Spec:** Regel 14 (kabelen legges nedenfra og opp), «Soner», Regel 21.

---

## Kenneths ord (20.10.2026)

> «Trappen er bygd nedenfra og opp. Da starter kabel nederst i sone 1. Men i sone 2, så starter repos i
> motsatt retning slik at kabelendene på sone 1 og sone 2 møtes og ligger et trinn fra hverandre.»

**Forventet:** hver sone er sin egen kabel og legges **nedenfra og opp innenfor sonen**, akkurat som
sone 1. Grønn start ligger nederst i sonen og rød slutt øverst. «Kabelstart: Topp» snur alle sonene likt.

## Hva som er lest i koden (bekreft i STEG 0)

- `generateStairCable` (≈ :43470) bygger **én** kjede over hele trappa i `surfOrder` (bunn → topp). Sidene
  veksler med `prevExitRight` (≈ :43554), som **fortsetter over sonegrensen**.
- Sone-grenen (≈ :43575) deler kjeden i biter per sone med `_stairAllocateCables(zonePieces, [capacity])`.
- Start- og sluttmarkørene (≈ :39405) går gjennom `stair.runs` i emisjonsrekkefølge og tar første og siste
  segment per `cableIdx`.
- **Hypotese (ikke målt):** enten emitteres repos-løpene i omvendt rekkefølge i sone-grenen, eller så
  gjetter markørkoden feil retning for en sone som starter på et repos. Mål hvilken det er.

## STEG 0

1. Duplisert trapp: trinn / repos / trinn, tre soner, bygd nedenfra. For **hver sone**: på hvilken flate og
   hvilken side (venstre/høyre) ligger start og slutt? Svar både i ruting (`stair.runs`) og i markører
   (plan, sidevisning og PDF). Lag en tabell.
2. Er feilen i rutingen eller bare i markørene? Gjelder den bare repos, eller også en sone som starter på et
   trinn?
3. Hva skjer med «Kabelstart: Topp»? Hva skjer med en trapp bygd ovenfra (`buildDirection: 'top'`)?

## Gjør

1. **Regel 14 per sone:** hver sones kabel starter på sonens **nederste** flate (eller øverste med
   «Kabelstart: Topp») og går oppover gjennom sonen. Rett der STEG 0 viste at feilen sitter, og bare der.
2. **Venstre eller høyre side:** behold det kjeden gir naturlig i dag, med mindre STEG 0 viser at det er
   en del av feilen. Skriv i tabellen hvilken side hver sone starter på. Kenneth avgjør i SPØRSMÅL om alle
   soner skal starte på samme side.
3. Plan, sidevisning (`_stairSideX`), PDF og målsetting skal vise samme start og slutt per sone. Gjenbruk
   samme kilde, og ikke beregn retningen på nytt per visning.
4. **Trapper uten soner er uendret** (også `cableStartFromTop`).

## Skal IKKE

- Endre strengantall, CC eller marginer.
- Endre trapper uten soner.
- Pushe.

## Test

1. Trappa fra STEG 0: start ligger nederst i alle tre sonene, både i plan, sidevisning og PDF. Lag en
   tabell før og etter.
2. «Kabelstart: Topp»: alle sonene starter øverst.
3. En trapp med to trinn-soner (uten repos): uendret hvis den allerede var riktig.
4. Utvid `_stairZoneRegressionTest102` med en sjekk per sone: startflate = sonens nederste flate.
5. Kjør alle trapp-batteriene.

## Rapport

STEG 0-tabellen · årsak (ruting eller markør) · før og etter · skjermbilder av plan og sidevisning.
Commit: «104: trapp — hver sone legges nedenfra og opp (Regel 14 per sone); start/slutt likt i plan, sidevisning og PDF».
**STOPP** (se 000-KJØR-MEG: commit, rapport, videre).
