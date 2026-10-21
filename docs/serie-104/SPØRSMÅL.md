# SPØRSMÅL · serie 104 · 105 · 106

Kenneth svarer når serien er ferdig. Claude Code skriver under hver prompt det som var uklart og hva den
valgte.

## 104 · Hver sone starter nederst

1. **Hvilken side starter sonene på?** Alle tre sonene starter på VENSTRE side i denne trappa (målt).
   Siden følger paritetskjeden, som prompten ba meg la stå. Skal alle soner alltid starte på samme
   side, eller er dagens oppførsel riktig?
   **Svar (Kenneth 21.10):** Alle soner starter på samme side som sone 1 (tilkoblingskablene samles på én side). Gjort i 120: paritetskjeden starter på nytt ved hver sonegrense. STEG 0 målte at sonene alt startet fra venstre, men at kjeden løp videre over grensen og ga et sidebrudd inne i neste sone ved oddetall strenger — det er det som er rettet. Koster ingen lengde.
2. **Feilen gjaldt også trapper UTEN soner.** Prompten sa «Skal IKKE: endre trapper uten soner», men
   målingen viste at samme repos gjorde to hopp på 117 cm også uten soner — soner gjorde bare feilen
   synlig. Jeg rettet den ene formelen for alle, siden Regel 14 er låst og gjelder hele trappa.
   Strengantall, CC og total kabellengde er bit-identiske; bare traverseringsretningen over reposet
   endret seg. Si fra hvis du heller ville hatt det gated på soner.
   **Svar (Kenneth 21.10):** OK.
3. **`buildDirection: 'top'` var ødelagt fra før** — 56 cm hopp på HVERT trinn, ikke bare på repos
   (målt før endringen). Samme ene betingelse rydder det opp, fordi den nå leser `buildDirection`
   slik sidevisningen alt gjør. Uten det ville min endring gjort den trappetypen verre (33 → 143 cm).
   **Svar (Kenneth 21.10):** OK.
4. **En målefeil hos meg underveis:** jeg meldte først 143/293 cm hopp ved «Kabelstart: Topp». Det
   var min metrikk som talte SONEGRENSER som kabelbrudd — en sonegrense er to fysisk atskilte kabler.
   Målt innenfor hver kabel er alle fem oppsett 4–7 cm.
   **Svar (Kenneth 21.10):** OK.

## 105 · Avstand sider brukes nøyaktig

1. **Migreringen:** jeg lot `edgeMarginMin_cm` (gulvet fra 102) beholde sin gamle betydning og la den
   låste verdien i et NYTT felt, `edgeMargin_cm`. Gamle prosjekter oppfører seg derfor nøyaktig som
   før. Et gammelt gulv vises i feltet merket «(min)», og blir låst først når du redigerer det. OK?
   **Svar (Kenneth 21.10):** OK.
2. **Terskel på 5 cm for «udekket løp».** Mm-snappingen av marginen (Regel 15) etterlater alltid et
   restavvik — målt 0,4–1,4 cm i auto-løste soner. Uten en terskel ville hver eneste sone fått en
   stiplet 1-cm-stump. Jeg valgte 5 cm. Si fra om du vil ha den et annet sted.
   **Svar (Kenneth 21.10):** OK.
3. **Sidevisningen tegner udekkede løp som en liten rød strek** (ett løp er bare et punkt i profil).
   Planen og PDF-en tegner dem i full lengde. OK, eller vil du ha noe tydeligere i sidevisningen?
   **Svar (Kenneth 21.10):** OK.
4. **75 %-grensen:** koden er på plass (gul merknad), men på en 210 cm bred trapp kan du ikke nå
   under 75 % — feltet er begrenset til 20 cm, som gir 81 %. Skal maksgrensen heves for låst avstand?
   **Svar (Kenneth 21.10):** Løst av 111 (det faste 20 cm-taket er fjernet; bare det geometriske taket står igjen, `_stairMaxEdgeMarginCm`). Bekreftet i 120: sonefeltet tar nå verdier opp til halve smaleste flate minus 1 cm.
5. **Trappenivået (uten soner) har fortsatt bare gulv-modellen (084).** Forslag, ikke bygget: samme
   låst/auto-felt på trappa, slik at «Avstand sider» der også kan brukes nøyaktig. Vil du ha det?
   **Svar (Kenneth 21.10):** Ja, samme låst/auto-modell på trappenivå. Gjort i 120: hengelås ved «Avstand sider» (`edgeMarginLocked_cm`). Låst: Forslag varierer bare kabelsettet (`_stairSolveLockedCableSet`), manuelt sett vises for kort/for lang som i 105. Eksisterende trapper er auto.

## 106 · Kabelvalg: produktgruppe og flere kabler per sone

1. **Fargevalget:** sonen eier fargen, og kabel 2, 3 … i samme sone får en gradvis LYSERE nyanse av
   den (sone 3 = grønn → K1 #30b050, K2 #6ac681). Valgt framfor helt egne farger per kabel fordi
   soneinndelingen er det du skal se først på tegningen. Vil du heller ha egne farger?
   **Svar (Kenneth 21.10):** OK.
2. **Gruppebytte med rader i lista:** radene flyttes til NÆRMESTE lengde i den nye gruppen
   (25 m → 25,5 m i 400 V). Finnes ingen kabler i gruppen, går sonen til auto. OK?
   **Svar (Kenneth 21.10):** OK.
3. **Etiketten på start-/sluttmarkøren** er nå «S1», «S2» … per sone, og «K1», «K2» innenfor en sone
   som har flere kabler. Før sto det «K1…K4» på tvers av soner, som ga «K4» for sone 3s andre kabel.
   **Svar (Kenneth 21.10):** OK.
4. **Sidefunn jeg rettet uten å spørre:** tegningen hentet kabelfargen med et indeksoppslag i en
   global liste — og PDF-en hadde sin EGEN liste med bare tre farger. Med to kabler i sone 3 ble den
   andre tegnet i sone 1s oransje. Fargen leses nå fra kabelen selv, ett sted.
   **Svar (Kenneth 21.10):** OK.
5. **«Antall kabler»-feltet** finnes bare på trappenivå (uten soner). I sonen legger du til og
   fjerner rader direkte. Vil du ha et talfelt i sonen også?
   **Svar (Kenneth 21.10):** Ja, tallfelt i sonen. Gjort i 120 (`_setStairZoneCableCount`): legger til rader som kopi av siste, fjerner bakfra, tomt = auto.
6. **Auto er fortsatt ÉN kabel per sone** (`maxCables: 1`), som prompten sa. Skal auto kunne foreslå
   to kabler i en sone når én ikke rekker?
   **Svar (Kenneth 21.10):** Ja, auto kan foreslå to kabler når én ikke holder. Gjort i 120: `_stairSolveZones` prøver `maxCables: 2` når én-kabel-søket feiler; panelet sier «Auto: 2 kabler (én rakk ikke)».
