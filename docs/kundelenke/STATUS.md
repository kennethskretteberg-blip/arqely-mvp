# Status — Kundelenke (027–030)

**Alle fire promptene er kjørt.** Serien er komplett og i `main` per 07.10.2026.
Spec: [`spec-kundelenke.md`](spec-kundelenke.md) · Valg og avklaringer: [`prompter/SPØRSMÅL.md`](prompter/SPØRSMÅL.md)

---

## Hva som er bygget

| | Prompt | Commit | Status |
|---|---|---|---|
| Grunnmur: tabell, RPC-er, usikre vegger, kundeside for mål | 027 | `327778f` | ✅ i `main` |
| Mottak: merke, gjennomgang vegg for vegg, Bruk/Bruk alle, avvik | 028 | `0aee111` | ✅ i `main` |
| E-post begge veier, alle lenker på varmeplan.no | 029 | `4c09d7a` | ✅ i `main` |
| Tegn selv: fire metoder på PC, talltastatur på telefon | 030 | `ef636f9` | ✅ i `main` |
| Kundesiden: sidepanel, veggvalg, piltaster og gizmo | 032 | `3540512` | ✅ i `main` |
| E-postene skriver norsk med æøå + «<Org> Varmeplan» | 031 | `b16c4c5`, `5f8758b` | ✅ i `main` |
| Kundesiden: hjørner, markør som i Varmeplan, fast tabell | 033 | `d640505` | ✅ i `main` |
| Vegglengde: riktig ende flytter seg, brukervalgt fast ende | 035 | `9408319` | ✅ i `main` |

**032 erstattet en regel fra 027.** Der sto det at «geometrien tegnes ikke om på kundesiden».
Nå følger tegningen tallene mens kunden retter — men spec regel 2 står uendret: alt skjer lokalt
i kundens nettleser, og ingenting skrives før «Send inn». Det er mulig fordi `_applyWallLength`
er en ren geometrifunksjon; målt at den ikke utløser et eneste lagringskall eller undo-steg.

Svaret bærer derfor nå **både** vegglengder og `answer.points` — kundens resultat-geometri.

**033 la til at kunden kan flytte hjørner**, og da sier svaret hvem som er fasit:

| `answer.geometryMode` | Når | Hva Kenneth får i 028 |
|---|---|---|
| `'walls'` | kunden har bare tastet mål | vegg-for-vegg som før; kundens punkter vises som gul stiplet skygge i miniatyren |
| `'points'` | kunden har flyttet et hjørne | én knapp, «Bruk kundens rom», som erstatter polygonet eksakt. Avkryssing og vegg-knapper er borte — de ville gitt et annet rom enn kunden så |

Et rom med et fritt flyttet hjørne kan ikke uttrykkes som vegglengder, og da er punktene den
eneste sannheten. Rette vinkler tvinges **ikke** — det er samme oppførsel som Varmeplan har for
innloggede (målt: hjørne 0 flyttet 50 cm i X på et 400×320-rom gir vegg 0 = 449,9 og vegg 3 =
323,9 cm skrå).

**035: hvilken ende av veggen som flytter seg.** 028s vindu-regel hadde to blindsoner — den
flyttet alltid slutt-enden (fordi `points[0]` er ankerpunkt) og bevarte alltid naboveggen. Målt
på Kenneths eget rom: å sette den for lange veggen til riktig mål krympet feil nabovegg
(200 → 121) og lot den skjeve veggen stå på 407,7, med hjørnevinklene helt uendret.

Nå velges ende og metode av geometrien:

| Hjørnet i enden som flyttes | Metode | Resultat |
|---|---|---|
| Rett (90° ± 1°) | **vindu** — to punkter, vegg i±2 absorberer | rommet forblir rettvinklet (uendret fra 028) |
| Skjevt | **ett punkt** — bare endepunktet flyttes langs veggens retning | den skjeve naboen rettes opp, som ved hjørne-drag |

Brukeren kan overstyre med «Fast»-kolonnen i tabellen eller hengelåsen på tegningen; valget
følger med i svaret som `answer.walls[].fixedEnd`, så Kenneths «Bruk» gir samme rom som kunden
så. Ankerpunktet bevares ved å translatere hele polygonet tilbake — translasjon endrer verken
lengder eller vinkler.

⚠ **Translasjonen alene ville vært en regresjon.** Med den blir forover- og bakover-vinduet
likeverdige *opp til posisjon*, men de gir ulike polygoner. `'auto'` følger derfor 028s
vinduvalg slavisk; bare et eksplisitt brukervalg bruker sitt eget vindu. Alle 10 tilfellene fra
028 er bit-for-bit identiske.

**To lag som begge rører samme vegg.** `_kundeRebuildRoom` regner alltid *original →
vegglengder → hjørne-deltaer*, i den rekkefølgen, så resultatet er likt uansett hva kunden gjorde
først. Når et tastet tall gjelder en vegg med **ett** flyttet endepunkt, justeres punktet langs
veggens retning så tallet gjelder. Er **begge** flyttet, kan tallet ikke oppfylles — og avviket
vises («Du ba om 5,00 m, men hjørnene gir 5,04 m») i stedet for å skjules.

## Oppsett — alt er på plass

Hele kjeden er operativ per 07.10.2026: migrasjoner kjørt, funksjon deployet, domene verifisert.

**1. Migrasjoner — alle tre er kjørt og verifisert:**

| Fil | Hva | Verifisert |
|---|---|---|
| `supabase-migration-kundelenke.sql` | tabell `kundelenker` + to RPC-er | ✅ begge rutiner finnes |
| `supabase-migration-kundelenke-028.sql` | `kundelenke_get` avviser `applied` | ✅ `avviser_applied = true` |
| `supabase-migration-kundelenke-mail.sql` | `last_notified_at`, `invite_sent_to/at` | ✅ 18 kolonner bekreftet |

**2. Edge Function — ✅ deployet og verifisert** (07.10.2026, prosjekt `nhzhffertfqdeslhzyxx`).

Målt mot den live funksjonen:

| Kall | Svar |
|---|---|
| `invite` med **anon-nøkkelen** | 401 «innlogging kreves» |
| `invite` uten `Authorization` | 401 |
| `answered` med ukjent token | 404 «ukjent lenke» |
| ugyldig `kind` | 400 |

Den første raden er beviset på at `verify_jwt` **ikke** hadde holdt: anon-nøkkelen er en gyldig
JWT og slapp gjennom plattformsjekken, men ble stoppet av den eksplisitte `auth.getUser`-sjekken.

Skal funksjonen deployes på nytt senere:

```bash
supabase functions deploy kundelenke-mail
```

**3. Avsenderdomene — ✅ ferdig.** `varmeplan.no` er verifisert i Resend, og både `FROM_EMAIL`
og `RESEND_API_KEY` er satt (Kenneth 07.10.2026). Tas i bruk automatisk ved deploy; ingenting
mer å gjøre.

⚠ `FROM_EMAIL` er en **prosjekt**-secret, delt av alle fem e-postfunksjonene
(`send-invite-email`, `notify-admin-registration`, `send-feedback`, `send-warranty-email`,
`kundelenke-mail`). Alle sender nå fra `noreply@varmeplan.no`; de tre første sendte tidligere
fra `arqely.no` / `invite.arqely.com`. Antakelig ønsket, men ikke isolert til kundelenken.

## Domenene — målt 07.10.2026

| URL | Svar |
|---|---|
| `varmeplan.no` | 200 direkte — **primærdomene** |
| `www.varmeplan.no` | 307 → `varmeplan.no` |
| `arqely.com` | 307 → `www.arqely.com` |
| `www.arqely.com` | 200 direkte |

Begge domenene serverer **samme Vercel-prosjekt** (identisk innhold, verifisert med sha256).
`arqely.com` redirecter altså ikke til `varmeplan.no` — de kjører parallelt. Det er uproblematisk
for kundelenkene, som treffer `varmeplan.no` uten et eneste hopp; gamle arqely-lenker fortsetter
å virke.

## Sikkerhetsmodellen

- Tabellens RLS åpnes **aldri** for anon. Verifisert: en anonym `select` på `kundelenker` gir
  0 rader, mens begge `security definer`-funksjonene er kallbare.
- `kundelenke_get` velger felt **eksplisitt** fra prosjektets JSON — aldri `data` rått. Kunden
  ser geometri og navn, ingenting annet.
- `kundelenke-mail` slår opp alt innhold selv med service role. Fra klienten kommer bare token,
  og for invitasjon mottaker + melding.
- `kind='invite'` verifiserer brukeren med `auth.getUser(jwt)` + medlemskap i lenkens org.
  **Merk:** Supabase sin `verify_jwt` er *ikke* det samme som innlogget bruker — anon-nøkkelen er
  en gyldig JWT og ligger åpent i klienten.
- `kind='answered'` er anonym, men krever `status='answered'`, svar under 10 min gammelt, og
  maks ett varsel per lenke per 10 min. Mottakeren er alltid lenkens egen `notify_email`.

## Verktøy fra den innloggede editoren som lakk inn på kundesiden

Målt i nettleseren 07.10.2026 (032), ikke antatt — `present-mode` skjuler ingen av dem:

| Element | Hva kunden fikk se |
|---|---|
| `#wip` | «VEGG · ID · Lengde · Vinkel · Rom» + en **«✕ Avslutt»**-knapp som ville tatt kunden ut av siden |
| Rommets transform-gizmo | Håndtak for å flytte og rotere **hele** rommet |
| Minikartet | Navigasjonshjelpemiddel som hører sammen med sidebaren |
| Hjørne-gizmoen (033) | Lå *inne i* `drawTransformGizmo`, som 032 stengte — kunden fikk aldri hjørne-pilene. Trukket ut som egen `drawVertexGizmo()`, kalt fra begge |

Stengt med en ny `body.kunde-maal`-klasse. Lærdommen: kundesiden er presentasjon **pluss**
redigering, så den kan ikke bare arve `present-mode`-lista — hver nye ting som vises ved et
valg må sjekkes eksplisitt.

**039 fant en femte, av en annen type:** 030 la inn en gate i `_presentRenderBar()` —
`const _kunde = !!(S.ui && S.ui.kundeMode)` — som skulle skjule «⬇ PDF» og de tre KPI-ene
(Rom / Oppvarmet / Installert effekt) på en kundelenke. Gaten fyrte aldri: `S.ui.kundeMode`
ble satt på linja **under** `_presentEnter(true)`, altså etter at baren allerede var tegnet.
Målt i live HTML 08.10.2026. Her var det ikke gaten som manglet, men **rekkefølgen** — en
riktig skrevet regel kan stå død fordi den leses før flagget finnes.

## Tre åpne e-postutløsere — funnet og tettet

Målt mot de deployede funksjonene 07.10.2026, ikke lest ut av koden. Alle tre er nå rettet og
redeployet; verifisert at ingen av dem sender på et uautentisert kall.

| Funksjon | Før | Etter |
|---|---|---|
| `send-invite-email` | nådde vår kode uten `Authorization`; mottaker **og** lenke-URL fra klientens body | 401 uten innlogget bruker; tar kun `token`, slår opp alt selv |
| `notify-admin-registration` | **sendte e-post på tomt POST-kall** (200) | 400 uten `user_id`, 404 på ukjent, krever konto under 15 min gammel |
| `send-feedback` | **sendte e-post på tomt POST-kall** (200) | 401 uten innlogging; identitet fra JWT, ikke fra body |

`send-invite-email` var en ferdig phishing-kanal på vårt eget verifiserte domene, med
`org_name`/`invited_by` interpolert uescapet inn i HTML-en. De to andre kunne hvem som helst
bruke til å fylle `ADMIN_EMAIL` og tømme Resend-kvoten, slik at ekte invitasjoner stoppet.

**Presentasjonslenken viste «Del lenke» og «Avslutt» til alle**, fordi `_presentEnter()`
nullstilte `presentPublic` rett etter at den var satt. Rettet i 030.

## Norsk i e-postene

ASCII-regelen i `prompter/000-KJØR-MEG.md` gjelder **SQL-kommentarer**, ikke e-posttekst. Den ble
feilaktig dratt over på kundeteksten i 029 («Apne», «maalene»); rettet i 031. Alle fem funksjoner
har nå `<meta charset="utf-8">` og `charset=utf-8` mot Resend, og
`scripts/sjekk-norsk-i-epost.sh` fanger det hvis det sniker seg inn igjen.

## Flyten, ende til ende

```
Kenneth merker usikre vegger  ──►  «Be kunde om mål»  ──►  Mål eller Tegn
                                          │
                                          ├─ kopier lenke, eller send på e-post
                                          ▼
                       kunden åpner varmeplan.no/?kunde=<token>
                       (ingen innlogging, kun geometri og romnavn)
                                          │
                 mål: velger vegg ELLER    │  tegn: tegner rom med fire metoder
                 hjørne, i lista eller på  │  — talltastatur + piler på telefon
                 tegningen; retter med     │
                 tall, piltast eller gizmo │
                 — tegningen følger med    │
                 (032/033)                 │
                                          ▼
                                     «Send inn»
                                          │
                          e-post til Kenneth  +  status = answered
                                          ▼
                 prosjektlista: «✉ Svar fra kunde»  ──►  Gå gjennom
                                          │
                 Estimert | Kunde | Avvik | Blir   og/eller   Nye rom fra kunde
                                          ▼
                             Bruk / Bruk alle  (ett Ctrl+Z angrer alt)
                                          │
                        avvik som ikke går opp vises, de skjules aldri
                                          ▼
                                   status = applied
                             (lenken blir ugyldig)
```

## Kundeforslag (042–044) — ferdig 08.10.2026

Kunden ser presentasjonen, trykker på et rom og sier «OK som det er» eller foreslår annet
produkt / ønsket flateeffekt / retning. Kenneth godkjenner per rom, og utlegget endrer seg.

| Prompt | Hva | Commit |
|---|---|---|
| 042 | «PRESENTASJON» / «FYLL INN MÅL» som ferdig hyperlenke med Kopier (formatert + ren URL) | `6420667` |
| 043 | Forslagskort i presentasjonen: produkt-piling, ønsket flateeffekt, retning, OK per rom, Send | `1e9bcac` |
| 044 | Panel med Godkjenn/Avslå per rom → auto-utlegg, e-post begge veier, «Godkjent av kunde» | denne |

**041 kom etterpå, og var en FEILRETTING — ikke infrastruktur.** Infrastrukturen var på plass
(`?present=`, `present_token`, `get_present_project`), men lenken virket ikke:
`get_present_project` er `returns table`, som supabase-js leverer som en LISTE, mens
`_presentLoadByToken` leste `data.data` rett på den. Et gyldig token ga «fant ikke prosjekt» →
dashbordet for innloggede, innloggingsskjerm for kunder. **Det rammet også forslagslenka**, som
går gjennom samme funksjon. Rettet 08.10.2026 (`Array.isArray(data) ? data[0] : data`), og
`supabase-migration-presentation-v2.sql` gjør funksjonen lik `kundelenke_get` for den som vil
rydde. Lærdommen: at infrastrukturen FINNES er ikke det samme som at den VIRKER — jeg slo fast
det første og antok det andre.

### Hvordan det henger sammen

Lenka er `?present=<present_token>&forslag=<token>`. Prosjektet hentes som før via
`get_present_project`; `kundelenke_get` brukes **bare** til lenkestatus. Forslagslenka viser
derfor ikke ett felt mer enn en vanlig presentasjonslenke. Den gjenbrukes per prosjekt (90 dager)
— uten gjenbruk ville hver deling laget en ny rad, og 044 ikke visst hvilken som gjelder.

Svaret lagres med `kundelenke_answer` (formagnostisk fra 027), og kunden skriver aldri i
prosjektet. `mode='forslag'` krevde én skjemaendring: CHECK-constrainten sto `in ('maal','tegn')`.

### Pilefunksjonen — familiene oppfører seg ulikt

| Familie | Antall | Varierer i | Piling |
|---|---|---|---|
| InFloor 17T (kabel) | 25 | lengde ved fast 17 W/m → effekt | over effekt |
| EcoMat (matte) | 57 | 60/100/150 W/m² **og** lengde | over W/m² (3 valg) |
| FlexFoil (folie) | 8 | kun bredde, alle 60 W/m² | ingen piler |

`getProductFamily('InFloor 17T 800W 47m')` gir **44** produkter som **blander 17T og 10T**
(kategori 2 har begge, så felles navneprefiks blir «InFloor»). Kundens pileliste snevres inn på
`watt_per_m` — kabeltypen ER watt_per_m. `getProductFamily` er urørt.

### Fire ting som ble funnet, ikke bestilt

1. **Romkortet viste `Artikkelnr` til alle med en offentlig lenke.** Spec regel 2 forbyr det.
   Nå gatet på `presentPublic`; innlogget presentasjon beholder det.
2. **Kortet var hover-drevet** — det forsvant når musa forlot rommet. I forslagsmodus velges
   rommet med klikk, og kortet har fått et ✕.
3. **`_kundeRefreshStatus` tok første levende lenke uansett `mode`.** En åpen forslagslenke
   (90 dager) kunne dermed skygge for et besvart mål-svar, som 028/037-panelet lever av.
   Modusene har nå hver sin cache, og prosjektlista kan vise begge merkene samtidig.
4. **Godkjenningen tok `rad.productId` på tro.** Et forslag kan bli ugyldig mellom innsending og
   godkjenning. Vakten leser samme kandidat kunden så — men bare produktreglene: målt at
   3400W/200m i 16 m² (CC 8 cm, 213 W/m²) er *lovlig*, siden minSp er 5 cm.

### Godkjenningen

`_forslagGodkjennRom` kaller motorene, endrer dem ikke. Retningen settes via den **delte**
globalen `S.varmefolie.direction` (+ `dirExplicit`) — den ene inngangen for kabel, matte og folie
— og settes tilbake etterpå; `S.ui.selectedRoomId` likedan, fordi `autoFillMatSerpentine` leser
den. Ryddingen er scopet til produkttypen (`_clearRoomProductCollections(roomId, ['cables'])`),
så hindringer og soner står. «Godkjenn alle» er ETT angre-steg. Feiler motoren settes rommet
tilbake med `_restoreRoomProductSnapshot` og raden får ⚠.

### Til Kenneth

Tre ting å kjøre, i denne rekkefølgen:

1. **Supabase SQL Editor:** `supabase-migration-kundeforslag.sql` (mode-constraint,
   approve_all_*, applied_*). Uten den feiler «Del lenke» med 23514 og forslagsavkryssingen
   vises ikke.
2. **Terminal:** `supabase functions deploy kundelenke-mail` — to nye `kind`
   (`forslag_answered`, `forslag_svar`). 039s `KUNDE_VIDEO_ID` følger med samme deploy.
3. Test i Outlook og Gmail at «PRESENTASJON» blir en klikkbar lenke — Claudes nettleserrute
   nekter `clipboard-write`, så den biten er ikke testet av meg.

Fire spørsmål venter i `prompter/kundeforslag/SPØRSMÅL.md`, viktigst: skal kunden kunne foreslå
en annen kabeltype (17T ↔ 10T), og skal «Godkjenn hele prosjektet» være formelt eller bare et
signal.

## Ikke i v1 (fra spec)

- Åpen «tegn selv»-side uten prosjekt, f.eks. fra cenika.no. Krever misbruksvern.
- Elektriker med egen Varmeplan-konto som deler prosjekt mellom organisasjoner.
- Bilder/vedlegg fra kunden i svaret.
