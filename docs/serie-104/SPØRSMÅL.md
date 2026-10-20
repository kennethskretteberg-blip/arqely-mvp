# SPØRSMÅL · serie 104 · 105 · 106

Kenneth svarer når serien er ferdig. Claude Code skriver under hver prompt det som var uklart og hva den
valgte.

## 104 · Hver sone starter nederst

1. **Hvilken side starter sonene på?** Alle tre sonene starter på VENSTRE side i denne trappa (målt).
   Siden følger paritetskjeden, som prompten ba meg la stå. Skal alle soner alltid starte på samme
   side, eller er dagens oppførsel riktig?
2. **Feilen gjaldt også trapper UTEN soner.** Prompten sa «Skal IKKE: endre trapper uten soner», men
   målingen viste at samme repos gjorde to hopp på 117 cm også uten soner — soner gjorde bare feilen
   synlig. Jeg rettet den ene formelen for alle, siden Regel 14 er låst og gjelder hele trappa.
   Strengantall, CC og total kabellengde er bit-identiske; bare traverseringsretningen over reposet
   endret seg. Si fra hvis du heller ville hatt det gated på soner.
3. **`buildDirection: 'top'` var ødelagt fra før** — 56 cm hopp på HVERT trinn, ikke bare på repos
   (målt før endringen). Samme ene betingelse rydder det opp, fordi den nå leser `buildDirection`
   slik sidevisningen alt gjør. Uten det ville min endring gjort den trappetypen verre (33 → 143 cm).
4. **En målefeil hos meg underveis:** jeg meldte først 143/293 cm hopp ved «Kabelstart: Topp». Det
   var min metrikk som talte SONEGRENSER som kabelbrudd — en sonegrense er to fysisk atskilte kabler.
   Målt innenfor hver kabel er alle fem oppsett 4–7 cm.

## 105 · Avstand sider brukes nøyaktig

1. **Migreringen:** jeg lot `edgeMarginMin_cm` (gulvet fra 102) beholde sin gamle betydning og la den
   låste verdien i et NYTT felt, `edgeMargin_cm`. Gamle prosjekter oppfører seg derfor nøyaktig som
   før. Et gammelt gulv vises i feltet merket «(min)», og blir låst først når du redigerer det. OK?
2. **Terskel på 5 cm for «udekket løp».** Mm-snappingen av marginen (Regel 15) etterlater alltid et
   restavvik — målt 0,4–1,4 cm i auto-løste soner. Uten en terskel ville hver eneste sone fått en
   stiplet 1-cm-stump. Jeg valgte 5 cm. Si fra om du vil ha den et annet sted.
3. **Sidevisningen tegner udekkede løp som en liten rød strek** (ett løp er bare et punkt i profil).
   Planen og PDF-en tegner dem i full lengde. OK, eller vil du ha noe tydeligere i sidevisningen?
4. **75 %-grensen:** koden er på plass (gul merknad), men på en 210 cm bred trapp kan du ikke nå
   under 75 % — feltet er begrenset til 20 cm, som gir 81 %. Skal maksgrensen heves for låst avstand?
5. **Trappenivået (uten soner) har fortsatt bare gulv-modellen (084).** Forslag, ikke bygget: samme
   låst/auto-felt på trappa, slik at «Avstand sider» der også kan brukes nøyaktig. Vil du ha det?

## 106 · Kabelvalg: produktgruppe og flere kabler per sone
