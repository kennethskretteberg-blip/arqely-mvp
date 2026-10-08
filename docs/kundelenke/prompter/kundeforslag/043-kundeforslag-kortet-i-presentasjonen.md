# 043 · Kundeforslag i presentasjonen: trykk på rom → pil mellom produktene med flateeffekt/W/m²/CC i sanntid, ønsket flateeffekt, retning, OK per rom, Send forslag

**Repo:** `arqely-mvp` · **Filer:** `index.html`, `supabase-migration-kundeforslag.sql` · **Prioritet: Høy** · **Størrelse: stor**
**Spec:** `spec-kundeforslag.md` regel 1–6. Krever 041 og 042. Linjenumre fra `2147753`.

---

## Kenneths ord

> «Kunden trykker på et rom og kan pile opp/ned mellom produktene — InFloor 10T 600 W, 700 W,
> 800 W … — og se flateeffekt, W/m² og CC i sanntid. De kan også oppgi ønsket flateeffekt, så
> finner appen nærmeste valg over og under. De kan endre retning for kabel, matter og folie.»

## Hva som finnes — nesten alt

| | Finnes | Gjenbruk |
|---|---|---|
| Presentasjon uten innlogging | `?present=<token>` → `_presentLoadByToken` (:9231, 041), `_presentEnter(true)`, romklikk → `S.ui.presentRoomId` (:6736) → `_presentRoomDetailHtml(room)` (:6751) med Flateeffekt/CC/kabellengde | Forslagskortet er en utvidelse av dette kortet |
| Produktalternativer med tall | `selectCableByPower(roomId, familyProducts, targetWm2)` (:22925) → `candidates[{product, productW, cc_cm, wm2, valid, ccOverMax}]`, `below`, `above`, `closest`; `getProductFamily(productId)` (:26827); `_ccLimits`/`_ccWarnText` (016) | **Hele sanntidsvisningen** — ingen ny formel |
| Flateeffekt for kabel | W/m ÷ CC (`stats.cableWm2`-regelen, 024) — for en kandidat: `prod.watt_per_m / (cc_cm/100)` | Vis per kandidat |
| Folie/matte | Familie via `getProductFamily`; folie-varianter i `watt_per_m2`, matter i `watt_per_m2` × bredde | Pil mellom varianter = bytte `watt_per_m2`; tallene: W/m² (produktets), dekning fra `stats` |
| Kundelenke-infrastruktur | `kundelenker` + `kundelenke_get`/`kundelenke_answer` + `_kundeCreateLink` (027/034) | Ny `mode='forslag'`, egen token |
| Produktkatalog anonymt | `_loadProducts` kjøres i `_presentLoadByToken` | Kortet har katalogen |

## STEG 0

1. Åpne en presentasjonslenke (041 kjørt), klikk et rom → bekreft kortet og hvilke tall det viser
   i dag. Hvor er «lukk»/klikk utenfor?
2. `selectCableByPower(roomId, getProductFamily(pid), 100)` i konsollen på et kabelrom →
   `candidates` sortert på avvik; hent lista sortert **på effekt** (600, 700, 800 …) — det er
   pilerekkefølgen.
3. Folie- og matterom: hvordan ser familien ut (`getProductFamily` på en FlexFoil/EcoMat)? Har de
   varianter i W/m², eller bare i bredde/lengde? Rapportér — det avgjør om piling gir mening der
   (bredde/lengde-varianter skal **ikke** tilbys; kun W/m²-varianter + retning).
4. `kundelenke_get` returnerer i dag geometri+navn (027). For `forslag` må den returnere
   **presentasjonsdata** = samme som `get_present_project` (hele `data`) — er det greit sikkerhets-
   messig? Presentasjonen viser allerede alt dette anonymt, så ja, men **strip** `customer*`,
   `contact*`, `project_no`? Sjekk hva `get_present_project` leverer i dag og gjør det samme.

## Gjør

### 1. Lenke med `mode='forslag'`

- Presentasjonsmodalen (042): avkryssing «Kunden kan foreslå endringer» (standard **på**). Da
  opprettes en `kundelenker`-rad `mode='forslag'` med egen token, og lenken som kopieres er
  `?present=<present_token>&forslag=<token>`. Uten avkryssing: ren presentasjon som før.
- Migrasjon `supabase-migration-kundeforslag.sql`: ingen nye kolonner nødvendig hvis `mode`
  er `text` (sjekk constraint); `kundelenke_answer` må godta svar-formen fra spec. Oppdater
  evt. `kundelenke_get` til å levere presentasjonsdata for `forslag` (STEG 0.4).
- Boot: `?present=…&forslag=…` → presentasjon som i dag + `S.ui.kundeMode = 'forslag'` + hent
  lenkestatus med `kundelenke_get(forslag)` (status/utløp/alt sendt).

### 2. Forslagskortet (utvidelse av `_presentRoomDetailHtml`)

Når `kundeMode === 'forslag'` og rommet har et produkt:

```
Stue · 16,0 m²
Nå:  InFloor 10T 800 W · 80 m          Flateeffekt 50 W/m² · 50 W/m² · CC 20 cm
Alternativ:  [▲]  InFloor 10T 900 W · 90 m   →  56 W/m² · 56 W/m² · CC 17,8 cm   [▼]
Ønsket flateeffekt: [ 80 ] W/m²  → nærmeste under: 700 W (…)  over: 800 W (…)   [Velg]
Retning: (•) som nå  ( ) vannrett  ( ) loddrett
Kommentar: [                    ]
[ OK som det er ]            [ Foreslå denne endringen ]
```
- **Pilene** går gjennom familiens kandidater sortert på effekt (STEG 0.2); hvert trinn viser
  W, lengde, **flateeffekt** (W/m ÷ CC), **W/m²** (W/netto), **CC** — fra `selectCableByPower`-
  kandidaten. Kandidater utenfor gyldig CC (`valid:false`) vises grå med «for tett/for langt»
  og kan ikke velges; ⚠ over anbefalt maks (016) vises som liten tekst.
- **Ønsket flateeffekt**: tast tall → `selectCableByPower(roomId, family, wm2)` → `below`/`above`
  med tallene sine, «Velg» setter alternativet.
- **Folie/matte** (STEG 0.3): pil kun mellom W/m²-varianter; tallene er W/m² og dekning.
  Finnes ingen varianter → bare retning + kommentar.
- **Retning**: tre radioknapper; ingen omtegning (spec regel 5) — en liten pil i kortet viser valgt.
- **OK som det er** → rommet får grønn hake i presentasjonen og `ok:true` i forslaget.
  **Foreslå** → gul «Forslag»-brikke på rommet.
- Nederst i presentasjons-baren: «**N rom OK · M forslag** · [Send forslag]» + navn/kommentar.
  Send → `kundelenke_answer(token, { rooms:[…], comment })` → takk-melding. Kan sendes igjen til
  Cenika har behandlet (siste gjelder).

### 3. Telefon

Kortet som bunnark (samme mønster som 032/033), piler ≥ 44 px, feltet for ønsket flateeffekt
med `inputmode="decimal"`.

## Skal IKKE

- Tegne utlegg på nytt hos kunden.
- Vise pris, art.nr, kundenavn. (Produktnavn og W er ok — Kenneth 08.10.)
- La kunden bytte produktfamilie.
- Skrive i `romtegner_projects`.

## Test

1. Kabelrom (InFloor 10T 800 W): ▲ → 900 W med riktige tall (sammenlign med Varmeplans eget
   forslagspanel for samme rom — tallene skal være identiske); ▼ ▼ → 700 W; 600 W med CC over
   maks → grå. Tast 80 W/m² → under/over stemmer med `selectCableByPower(…,80)`.
2. Folierom: piler kun hvis W/m²-varianter finnes; matte likedan.
3. Retning loddrett + kommentar → Foreslå → gul brikke; annet rom OK → grønn hake; Send →
   `answer.rooms` har begge, status `answered`.
4. Presentasjonslenke uten `forslag=` → ingen forslagskort, alt som 041.
5. Telefon: bunnark, piler treffbare, send virker.
6. Ny `_kundeforslagRegressionTest()`: kandidatliste sortert på effekt, ugyldige grå, ønsket
   flateeffekt gir riktig under/over, svar-payload validert.

## Rapport

STEG 0.1–0.4 (spesielt folie/matte-variantene og hva `get_present_project` leverer), hvilke
felter som ble strippet. Endringslogg. Commit: «043: kundeforslag — forslagskort i presentasjonen med produkt-piling (flateeffekt/W/m²/CC), ønsket flateeffekt, retning, OK per rom, Send forslag».
