# SPØRSMÅL · serie 116 · 117 · 118

## 116 · Forhåndsvalgt rom, alle mål, blå knapp

1. **Hvilken blå?** Varmeplans primærknapper bruker `--accent`, som er **turkis** (#0891b2 lyst /
   #22d3ee mørkt) — det var det «Send forslag» alt hadde når noe var valgt. Du ba om blå, så jeg valgte
   den semantiske blå-tokenen `--info` (#2563eb lyst / #3b82f6 mørkt) med hvit tekst. Vil du heller ha
   turkis (likt resten av appen), er det én linje å bytte.
2. **Tetthetsregel for målene:** et roms veggmål vises når rommets korteste side er minst 120 px på
   skjermen (`PRESENT_DIM_MIN_PX`), eller når rommet er det valgte. På 390 px med «Vestre Hals 43» var
   korteste side 128 px ved åpning, så målene vises der. Si fra om terskelen bør være høyere/lavere.
3. **Produktkjedene** (målsett folie/kabel/matte — «3.2 cm», «871.8 cm», «2.5 cm» i oransje) følger
   fortsatt dine egne brytere i prosjektet og vises for kunden som før. Skal de skjules i
   presentasjonen, slik at kunden bare ser veggmålene?
4. **Ren presentasjon på desktop** bytter fortsatt rom når musa går over et annet rom (men nuller ikke
   lenger når den forlater). Forslagslenka er klikk-styrt. 117 gir romliste, så det spiller mindre
   rolle — men si fra om du vil ha klikk-styring også i ren presentasjon.
5. Forhåndsvalget ser bare på **aktiv etasje**. Har første etasje ingen produkter og andre etasje har
   det, velges likevel første rom i første etasje.

## 117 · Venstre panel

1. **Mållenka (`?kunde=`) er ikke lagt over på det nye panelet.** Prompten sa «gjerne». Den er en
   editor med vegg-tabell, og 118 skal bruke maskineriet hennes inne i forslagslenka — jeg lot den
   stå urørt for å holde risikoen nede. Si fra om du vil ha samme skall der også.
2. **Innlogget presentasjon** (din egen «Presentasjon»-knapp) bruker også panelet. Del lenke / PDF /
   Avslutt ligger øverst i Prosjekt-seksjonen i stedet for i topplinja.
3. **Klikk i lista zoomer til rommet** (`fitRoom`), som prompten ba om. «Vis hele planen» øverst i
   romlista tar deg tilbake. Klikk i tegningen zoomer ikke (som før).
4. **Flere etasjer:** romlista grupperer per etasje, og klikk på et rom i en annen etasje bytter
   etasje. Presentasjonen hadde ingen etasjevelger fra før.
5. **Mobil-terskelen** er 760 px (prompten). Knappestørrelsene inne i kortet følger fortsatt
   `_kundeErSmal()` (< 900 px eller berøringsskjerm), så et nettbrett får PC-panel med store knapper.
6. Den svarte stripa øverst i mobil-skjermbildene er plantegningens eget PDF-bilde (målt: pikslene
   er tegnet av `drawBgImage`), ikke panelet. Topplinja dekket den før.

## 118 · Endre mål / Lås mål

1. **«Samme visning som mål-svar i dag»** hos deg: målblokka i forslagsvinduet viser listen
   («Stue: vegg 1 500 → 512 cm») og én knapp. Mållenkas eget vindu har i tillegg «Blir»-kolonnen med
   forhåndsvisning per vegg og avkryssing per vegg. Det vinduet er bundet til mållenkas cache og
   status, så jeg kopierte det ikke inn. Vil du ha hele vegg-tabellen også for forslagssvar?
2. **Innstillingen «Kunden kan rette mål»** lagres i lenkas `note`-felt som `innstilling:maal=av`
   (bare når den er AV; på = tomt). Ingen ny kolonne. Teksten kan dukke opp om `note` en gang vises
   for forslagslenker i loggen — si fra om du heller vil ha en kolonne (da er det en migrasjon).
3. **Send med bare mål rettet** (ingen «Hva synes du?»-valg) er tillatt. Svaret har da `rooms: []`
   og `maal`. Skulle kunden tvinges til å si noe om minst ett rom?
4. **Punkt-modus** (kunden flyttet et hjørne): hele rommet erstattes hos deg, som i mållenka (033).
   `_kundeBrukKundePunkter` tar ett angre-steg per rom; vegg-modus tar ett for alle.
5. **Merket «UTLEGG»** i romlista fjernes når rommets produkter ryddes for nytt utlegg
   (`_clearRoomProductCollections`) eller når du klikker på merket. Legger du ut på nytt via en vei
   som ikke rydder først, blir merket stående til du klikker det bort.
6. Første ekte veggdrag i testen (15 px) flyttet ingenting; tre påfølgende (10/15/22 px) gjorde det.
   Jeg fant ikke årsaken (snap var av i alle målte forsøk). Snap skrus nå av i målmodus uansett. Hvis
   du opplever at første drag «ikke tar», si fra — da er det noe å jakte på.
7. **Mållenka (`?kunde=`) er urørt** i oppførsel; den deler nå gaten `_kundeMaalAktiv()`.
