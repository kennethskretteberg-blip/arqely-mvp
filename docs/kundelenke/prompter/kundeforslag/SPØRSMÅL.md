# SPØRSMÅL — serien Kundeforslag (042–044)

Claude Code: legg spørsmål under riktig prompt mens du kjører, med valget du tok i mellomtiden.
Kenneth svarer til slutt.

## Avklart av Kenneth før start (08.10.2026)

- Kunden ser **produktnavn** og piler mellom produktene i samme familie (InFloor 10T 600/700/800 W …)
  med flateeffekt, W/m² og CC i sanntid.
- Kunden kan oppgi **ønsket flateeffekt** og få nærmeste alternativ under og over.
- Kunden kan foreslå **retning** for kabel, matte og folie.
- Lenketekst «PRESENTASJON» med Kopier-knapp.

## Til Kenneth (ubesvart)

- **Godkjenn hele prosjektet — formelt eller signal?** 044 lagrer navn + dato og viser «Godkjent
  av kunde». Skal det i tillegg låse prosjektet for endring, stemples på PDF-forsiden, eller
  utløse noe mot Visma? Hvis ja: egen sak.
- **Hvem skal kunne foreslå?** Alle med presentasjonslenken (som nå), eller skal det kreve navn
  før Send? 043 krever navn ved Send forslag — bekreft.

## 042

- **041 finnes ikke som nummerert prompt.** Serien oppgir «krever 041», men det finnes ingen
  promptfil, commit eller endringsloggpost. Verifisert at det ikke blokkerer: presentasjonslenka
  (`?present=`, `present_token`, `get_present_project`, `_presentLoadByToken`) er på plass fra
  `supabase-migration-presentation.sql`, og hvert symbol 042/043 navngir ligger på nøyaktig det
  linjenummeret promptene oppgir for `2147753`. **Valget jeg tok:** kjørte 042 som normalt.
  Si fra hvis 041 var ment å gjøre noe mer enn det som allerede står i koden.
- **URL-radens knapp heter «Kopier adresse», ikke «Kopier».** Spec-en sier bare «legg til rad
  FYLL INN MÅL · [Kopier] over dagens URL-rad», men da ville to knapper ved siden av hverandre
  hatt samme navn og ulik virkning. Si fra hvis du vil ha «Kopier» på begge.
- **Innliming i Gmail/Outlook er ikke testet av meg** — Claudes nettleserrute nekter
  `clipboard-write` (målt `denied`). Nyttelasten er verifisert mot en stubbet utklippstavle.
  Test gjerne én gang i Outlook og én i Gmail, og si fra hvis lenketeksten ikke blir klikkbar.

## 043

- **Skal kunden kunne foreslå en annen KABELTYPE (17T ↔ 10T)?** Jeg snevret pilelista til samme
  `watt_per_m`, altså samme T-serie, fordi spec-en holder «bytte produktfamilie» utenfor v1 og
  ditt eget eksempel er en serie innenfor én type. Men `getProductFamily` blander dem (44
  produkter), og 10T gir faktisk et bedre utlegg i testrommet: 800 W på 17T ga CC 34 cm, som er
  **over** anbefalt maks, mens 800 W på 10T gir CC 20 cm. Si fra hvis kunden skal få se begge.
- **«Flateeffekt» og «W/m²» er samme tall for kabel.** W/m ÷ CC = productW / nettoM² — algebraisk
  identisk. Spec-en ber om begge, men kortet viste da «50 W/m² · 50 W/m²». Jeg viser det én gang
  som «Flateeffekt». Si fra hvis du vil ha begge likevel.
- **Navn er påkrevd ved Send forslag** (som spec-en antydet). Bekreftet i koden.
- **Forslagslenka varer 90 dager** og gjenbrukes per prosjekt. Målforespørselen er 30. Si fra
  hvis presentasjonen skal ha en annen levetid.
- **Presentasjonslenka gir i dag ut HELE prosjekt-JSON-en anonymt** (`get_present_project`
  returnerer `data` ubeskåret, og `_restoreProject` laster alt) — kundenavn, kontaktperson og
  prosjektnummer ligger i nyttelasten selv om de ikke vises. 043 utvider ikke dette, men det bør
  bli en egen sak: strippe `customer*`/`contact*`/`project_no` i RPC-en.

## 044

-
