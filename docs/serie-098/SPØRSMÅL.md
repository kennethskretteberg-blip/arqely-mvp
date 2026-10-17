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

**Valgt:** promptens hypotese (cellesnitt nær terskelen) ble målt og avkreftet (STATUS §40), så
«cellesnitt som variant» er IKKE bygget. Bygget er det målingen pekte på: stigetrinn innenfor
lengdetoleransen som varianter (R-START først, så poeng), og 093-forskyvningen med rekkevidde 0,2 × CC.

**Spørsmål 1 — rom5 / 600W:** referansen gir 78,4 % (CC 13,2, hull 0). Flyttes en vegg 1–2 cm,
finner motoren 88–92,6 % (CC 15,29, hull 0, gyldig) på de fleste geometriene — men IKKE på
referansen, fordi 099 bare kjører når `tries` ikke traff hullfritt. «099 alltid på» henter 92,6 %
også der, men koster fire baselinjerader (lRom h, badHakk41 h tl, rom5 h) 4–6 prosentpoeng, fordi
poengsummen da bytter bort dekning. Vil du (a) ha gaten som nå (600W-referansen blir 78,4 %), eller
(b) at jeg lager en egen regel «aldri bytt bort dekning» for alltid-på? (b) er en egen prompt.

**Spørsmål 2 — hjørnerunden:** den går fem grove CC-trinn og mister trinn som ligger ett hakk unna
(enHindring `br`: 10,54 / 90,7 % finnes, runden fant 9,07 / 77,4 %). N-stigen nærmeste-først (som
enderunden) brakk sju rader fordi budsjettet (40) brukes opp på nære trinn. Skal jeg bruke en egen
prompt på en hjørnerunde med både grovsveip og nære trinn innenfor et høyere budsjett?

**Spørsmål 3 — 10T i Rom 5 treffer aldri hjørnet** (start 118 cm, også på referansen). §38 leste det
som «R-START tapt». Det er en R-START-sak for 10T 400W/40 m i dette rommet, ikke en robusthetssak.
Skal den undersøkes?

**Merknad:** `_geoCells` teller nå celler med minst to baner (sliveren på 12,6 cm telte som «celle»),
og «R-START tapt» i forstyrrelsestesten krever at referansen traff hjørnet. Begge er endringer i
MÅLINGEN, ikke i motoren — si fra hvis du vil ha de gamle definisjonene tilbake.

## 065 · PWA på Windows

**Valgt:** `display: standalone` uten `window-controls-overlay` (kan ikke måles uten Windows; se
endringsloggen). PNG-ene er laget med den lokale Chromium-en i stedet for `npx @resvg/resvg-js-cli`
— samme resultat, ingen nedlasting av verktøy.

**Spørsmål 1:** Skal `admin.html` også kunne installeres (eget manifest), eller holder ikonet?
Jeg lot admin være en vanlig side.

**Spørsmål 2:** Har en installatør først logget inn på varmeplan.no i Edge, ligger service workeren
på hele origin-et — også når samme person åpner en `?present=`-lenke i samme nettleser. Den gjør
bare «nettverk først» på navigasjon, så siden virker som før, men «Service Workers tom for den
økten» gjelder bare en kunde som aldri har logget inn. Er det greit, eller skal `?present=` aktivt
avregistrere?

**Merknad:** Lighthouse og selve installasjonen i Edge på Windows er ikke kjørt her — det er
sjekkpunkt 1–3 og 6 i prompten, som Kenneth må gjøre på PC-en.
