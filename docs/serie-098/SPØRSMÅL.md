# SPØRSMÅL · serie 098 · 075 · 099 · 065

Kenneth svarer når serien er ferdig. Claude Code skriver under hver prompt det som var uklart og hva
den valgte.

## 098 · Trapp, sidevisning

**Valgt:** sidevisningen følger PLANEN (samme fysiske kant), også for byggeretning `top`.

**Funn utenfor 098 (ikke rettet):** med byggeretning `top` (trinn 1 tegnes øverst i planen) ligger
neste trinn ved økende y, men kabelmotoren (`generateStairCable`, Regel 14) antar alltid at
`pos = d_cm` er forkanten. For `top`-trapper legger planen dermed starten 2 cm fra OPPTRINNET og
slutten 2 cm fra forkanten — motsatt av Regel 14 — og nese-/opptrinnsavstandene er byttet om.
Målt med syntetisk trapp (brøk fra forkanten 0,933 for start, 0,067 for slutt). Sidevisningen
viser nå det samme som planen, altså også «feil» for `top`, men konsekvent. Rettes dette i
motoren (speil pos-formelen når `buildDirection === 'top'`), følger begge visningene med.
**Spørsmål:** skal jeg rette motoren for `top`-trapper? Det endrer kabelutlegget (start/slutt-
ende) for alle eksisterende `top`-trapper, så det bør være en egen prompt.

## 075 · Høyreklikkmenyen

## 099 · Kabelmotor, cellesnitt som variant

## 065 · PWA på Windows
