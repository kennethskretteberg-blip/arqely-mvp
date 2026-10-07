# SPØRSMÅL — serien Kundelenke (027–030)

Claude Code: legg spørsmål under riktig prompt mens du kjører. Skriv hva du **valgte** i mellomtiden,
så Kenneth kan si «ok» eller «endre». Kenneth svarer til slutt.

## Avklart av Kenneth før start (07.10.2026)

- Kunden kan endre mål på **alle** vegger, ikke bare de merkede. Merkede vises først.
- Tegn-modus: **Mål, Polygon, L-form og WBW.** WBW på telefon = pilknapper + talltastatur på skjermen.
- Lenker bruker **varmeplan.no**, ikke arqely.
- Reservekabel (025) er ikke del av denne serien.

## 027

- **Balansesjekken på et FERDIG rom er alltid stille.** Prompten ba om `_roomAxisBalance` tre
  steder, inkludert ctxbar-en for en valgt målelinje. Men et tegnet rom er per definisjon lukket,
  og en lukket form summerer alltid til null — sjekken ville aldri sagt noe der.
  **Valgt:** linja vises i WBW (mens man tegner, åpen kjede) og på kundesiden (kundens tall), ikke
  på et ferdig rom. 028-panelet får den når det bygges. Minst endring, ingen funksjonstap.
- **`wallIdx` = punktindeks.** STEG 0.2 målte at `compWalls(pts)` bygger `walls[i]` av
  `points[i] → points[(i+1)%n]`, og at den kalles på nytt ved hver geometriendring (10 kallsteder).
  Indeksen er stabil og overlever lagring. **Valgt:** `{roomId, wallIdx}` i svaret, ingen egen vegg-id.
- **Ingen ctxbar-gren fantes for målelinjer** — `S.ui.selectedAnnot` hadde bare dra-håndtak.
  **Valgt:** ny ctxbar-gren med «⚠ Usikkert mål»-chip, framfor å bygge en ny høyreklikkmeny.
- **Kundesiden gjenbruker IKKE `_restoreProject`.** Den ville dratt inn produkter, utlegg og
  kundeopplysninger fra prosjektfila. **Valgt:** minimalt `S` bygget fra RPC-svaret — eneste måten
  spec regel 1 faktisk holder.
- **«Send på e-post» står deaktivert** med tooltip til 029 er kjørt, som prompten ba om.

## 028

- **Promptens §2-regel ble målt og forkastet.** «Flytt `points[i+1 … n−1]`» gjør et rektangel
  skjevt (lukkeveggen havner på −98,9°). **Valgt:** vindu-regelen — flytt nøyaktig to punkter
  langs veggens egen retning, så kant `i+2` absorberer. Verifisert for alle vegger i rektangel
  og L-form. Dette er en informert kursendring, ikke en misforståelse av prompten.
- **Den lukkende veggen kan settes som alle andre.** Promptens §2 antydet at den «absorberer
  endringen» og dermed ikke kunne settes selv. Med vindu-regelen speilvendt (bakover-vindu
  `{i, i−1}`) kan den det. **Valgt:** alle vegger er likeverdige, som spec regel 3 sier.
- **Balansesjekken ble delt i to.** «Går kundens tall opp som en lukket romform?» gir bare
  mening når kunden har oppgitt *alle* veggene — ved et delvis sett bærer de andre fortsatt
  tegningens gamle tall, og kjeden lukker naturligvis ikke uten at noe er galt. **Valgt:**
  balanselinja vises kun ved fullt sett; for delvise sett vises i stedet «n av m mål kan ikke
  oppfylles samtidig», som er det spørsmålet som faktisk gjelder da.
- **Rekkefølgen «Bruk alle»:** største `|delta|` først, som prompten ba om. Med vindu-regelen
  er det også det som gir minst etterslep, siden den største endringen forplanter seg mest.
- **Kontrollrunden markerer rommet, den retter ikke.** Spec regel 4: ingen automatisk fordeling
  av differansen. `room.maalAvvik` lagres i prosjektet og vises som gul ⚠ til Kenneth klikker
  den vekk.
- **Avvis-knappen setter `revoked` med merknad i `note`**, ikke en ny statusverdi — tabellen har
  ikke en `rejected`-status, og `revoked` er det spec regel 10 lister.
- **Prosjektlista fikk et eget lite spørsmål**, ikke en join. `_fetchProjectList` er en
  fallback-stige av tolv kolonnesett; en join måtte vært duplisert tolv ganger og kunne veltet
  hele lista på et eldre skjema.
- **027 etterlot `_kundeStatusHtml()` som død kode** — definert, aldri kalt, så kundelenkens
  status fantes ikke i grensesnittet. Rettet her, på statiske sidebar-rader (aldri innerHTML-
  ombygging av `#sb-proj-info`).
- **Ny migrasjon:** `supabase-migration-kundelenke-028.sql`. 027 lot `kundelenke_get` slippe
  gjennom `applied`-lenker — kunden kunne åpnet lenken igjen etter innarbeiding og trodd han
  fortsatt kunne rette mål. Nå avviser begge RPC-ene samme statusliste.

## 029

- **❓ TIL KENNETH — Resend-domenet.** `send-invite-email` sender i dag fra `noreply@arqely.no`,
  og det virker. `send-warranty-email` har `noreply@varmeplan.no` som standard, men den er
  dokumentert som ikke aktiv — altså uprøvd. **Valgt:** `kundelenke-mail` bruker samme standard
  som den som faktisk sender i dag (`noreply@arqely.no`), slik at e-post virker fra første
  deploy. Skal avsender bli `noreply@varmeplan.no`, må du verifisere domenet i Resend (DNS) og
  deretter sette `FROM_EMAIL`-secreten — ingen kodeendring. Lenkene **i** e-posten peker
  uansett på `varmeplan.no`; det er uavhengig av avsenderadressen.
- **❓ TIL KENNETH — Vercel-domenet (prompten §3).** Jeg kan ikke lese Vercel-prosjektets
  domeneoppsett herfra. Bekreft at `varmeplan.no` er primærdomene og at `arqely.com` redirecter
  dit — ellers havner kundelenkene på en side som kanskje sies opp. `vercel.json` har bare
  `/romtegner.html → /`-redirecten; domene-redirect settes normalt på prosjektnivå i Vercel, så
  jeg har ikke lagt noe inn i fila. Skriv her hva som faktisk gjelder.
- **`verify_jwt` er ikke innlogging.** Supabase godtar anon-nøkkelen som en gyldig JWT, og den
  ligger åpent i klienten. **Valgt:** `kind='invite'` verifiserer brukeren eksplisitt med
  `auth.getUser(jwt)` + medlemskapssjekk mot lenkens `org_id`, i stedet for å stole på
  plattformens JWT-sjekk.
- **Funksjonen slår opp alt innhold selv.** Fra klienten kommer bare token, og for `invite`
  mottaker + melding. **Valgt** framfor `send-invite-email`-mønsteret, der både mottaker og
  lenke-URL kommer fra klientens body — den kan sende en vilkårlig lenke til hvem som helst med
  Varmeplan som avsender. Den eksisterende funksjonen er ikke rørt i denne omgang, men svakheten
  er verdt en egen oppgave.
- **`kind='answered'` måtte kunne kalles anonymt** (kunden er ikke innlogget). **Valgt:** tre
  lag i stedet for autentisering — `status='answered'`, svar under 10 min gammelt, og maks ett
  varsel per lenke per 10 min. Mottakeren er alltid lenkens egen `notify_email`. Det eneste en
  angriper kan utløse er én e-post til Kenneth selv, rett etter at en kunde faktisk har svart.
- **Svarvarselet sendes uten `await`.** E-post er et tillegg; kundens bekreftelse skal aldri
  avhenge av at en SMTP-tjeneste svarer.
- **Boot-stien `?project=&kundesvar=` ligger etter innlogging**, ikke blant de anonyme grenene
  i `initSupabase()` — å åpne et skyprosjekt krever en sesjon.
- **En 027-test besto av feil grunn.** `location.origin`-sjekken matchet en *kommentar* om
  `location.origin`, ikke kode, og ville vært grønn selv om bruken ble satt tilbake. Rettet med
  `_kildeUtenKommentarer` + et sveip over hele skriptet i stedet for en liste med funksjonsnavn.

## 030

-

## Til senere (ikke i v1 — fra spec)

- Åpen «tegn selv»-side uten prosjekt (f.eks. fra cenika.no). Trenger misbruksvern (rate limit,
  CAPTCHA eller e-postbekreftelse) før den lages.
- Elektriker med egen Varmeplan-konto deler prosjekt mellom organisasjoner.
- Bilder fra kunden i svaret.
