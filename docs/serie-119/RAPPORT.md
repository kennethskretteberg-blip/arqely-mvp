# Rapport · serie 119 · 120 · 121 — oppfølging (presentasjon, trappesoner, kabelmotor-testene)

Kjørt 21.10.2026 på `main`, fra `8eee272`. **Ikke pushet.** Én commit per prompt.
Ingen av promptene var kjørt fra før (sjekket med `git log --oneline -15`).

| # | commit | hva |
|---|---|---|
| 119 | `b547ea7` | Produktmål skjult for kunden, klikk-styring, forhåndsvalg over etasjer, vegg-tabell per vegg i forslagssvar, UTLEGG-merket ryddes selv |

---

## 119 — presentasjon, oppfølging

Svarene er skrevet inn under hvert spørsmål i `docs/serie-116/SPØRSMÅL.md` («Svar (Kenneth 21.10): …», 17 stk).

### STEG 0 (målt på forslagslenka til «Vestre Hals 43», bare lest — lagring stubbet)

| | funn |
|---|---|
| 0.1 produktmål | Tegnes i `drawAllDimAnnotations` på rommets egne brytere `stripDimSnap`/`cableDimSnap`/`matDimSnap` (lagret i prosjektet). Rommet hadde `stripDimSnap: true` → hele foliekjeden («3.2 cm», «871.8 cm», «2.5 cm» + sidekjeden) sto i kundens lenke. PDF-en slår bryterne på selv i `_pdfMode` og var alt utenfor. |
| 0.2 hover | `_presentHover` (mousemove) byttet rom ved hover i ren presentasjon; bare forslagslenka var klikk-styrt (`_forslagAktiv()`). Klikk-veien fantes i `_canvasMouseUp` (tap uten drag). |
| 0.3 forhåndsvalg | `_presentForhaandsvalgtRom` så bare på `_roomOnActiveFloor`. Etasjebyttet fra 117/4 lå som fire linjer inne i `_presentPanelVelgRom`. `_presentEnter` kalte `fitAll()` FØR forhåndsvalget. |
| 0.4 vegg-tabellen | `_kundeRevRender(groups)` var bundet til `_kundeLinkCache` (navn, dato, kommentar, `answer.points`, `axisBalance`) og til mållenkas knapper (`_kundeApplyRoom/All`, `_kundeBrukKundePunkter`, `_kundeRejectAnswer`, `_kundeNyeRomHtml`). Avkryssingen (`_kundeRevState.picked`) og `_kundeApplyWalls(groups, onlyPicked)` fantes allerede. Det som måtte bli argument: svaret (`k`) og knappenes mål. |
| 0.5 felles kanal | Alle plasseringsveier ender i `renderSidebar()` (det 109 brukte). `_clearRoomProductCollections` fjernet merket, men manuell plassering og frihånds-matte rydder ikke først. |

### Gjort

1. **Produktmål skjult** — `_presentProduktMaalSkjult()`: presentasjon/forslagslenke uten `_pdfMode` og uten annen kundemodus. `drawAllDimAnnotations` tegner veggmålene og hopper så over de tre kjedene. Rommets brytere røres ikke; editor, PDF og mållenka er uendret.
2. **Klikk-styring** — `_presentHover` setter bare markøren, i alle kundevisninger.
3. **Forhåndsvalg over etasjer** — `_presentRomIEtasjerekkefolge()` (etasjerekkefølge, så romrekkefølge) og `_presentByttTilRommetsEtasje(roomId)` (delt med romlista). `_presentEnter`: forhåndsvalg → etasjebytte → `fitAll`.
4. **Vegg-tabell per vegg** — `_kundeRevRender(groups, ctx)`; `ctx = { forslag, k }` i `_kundeRevState.ctx`, så avkryssing og re-tegning finner samme svar. «Arbeid inn målene» åpner vinduet. Knappene går til `_forslagRevBrukAlle/Rom/Punkter` → den eksisterende innarbeidingen → `_forslagMaalEtterInnarbeiding` (merke + protokollrad). Uten ctx er mållenkas vindu bit-identisk.
5. **UTLEGG-merket** — settes med `utleggMerkeSig = _roomProduktSignatur(roomId)` (id-ene i alle `ROOM_PRODUCT_KEYS`); `_utleggMerkeRydd()` i `renderSidebar` fjerner det når signaturen avviker. Klikk fjerner fortsatt.

### Hva Kenneth skal klikke

1. Åpne forslagslenka til Vestre Hals 43 i et privat vindu: den oransje foliekjeden er borte, veggmålene står. I Varmeplan (editor) står kjeden som før.
2. Åpne en ren presentasjonslenke med flere rom (f.eks. «Varmematter 60W»): før musa over et annet rom — valget står. Klikk — rommet byttes.
3. I et prosjekt med to etasjer der første etasje er tom: ▶ Presentasjon åpner på andre etasje med det første rommet som har produkter.
4. Et forslagssvar med rettede mål: «Arbeid inn målene» åpner vegg-tabellen (Vegg · Estimert · Kunde · Avvik · Blir · ☑). Kryss bort en vegg, «Arbeid inn valgte mål». Rommet får UTLEGG-merket; «Vis målene» åpner tabellen igjen.
5. Legg ut på nytt i rommet (hvilken som helst vei, også manuell folie): merket forsvinner av seg selv.

### Målt etter

- Forslagslenka: kjeden borte ([skjermbilde](skjermbilder/119-etter-forslag-desktop.png), [før](skjermbilder/119-foer-desktop.png)).
- Ren presentasjon «Varmematter 60W» (5 rom): hover over rom 4 → valgt rom fortsatt 2, markør `pointer` ([hover](skjermbilder/119-etter-ren-presentasjon-hover.png)); klikk → 4 ([klikk](skjermbilder/119-etter-ren-presentasjon-klikk.png)).
- Kenneths side (Vestre Hals lest med stubbet lagring og dummy prosjekt-id): [målblokk](skjermbilder/119-kenneth-maalblokk.png) → [vegg-tabell](skjermbilder/119-kenneth-veggtabell.png) → [vegg 3 krysset bort](skjermbilder/119-kenneth-veggtabell-to-valgt.png) → «Arbeid inn valgte mål»: vegg 1/2 = 454/204 (kundens tall). Vegg 3 fulgte geometrien (215 → 203, slik «Blir»-kolonnen viste) — ikke kundens 205. [UTLEGG-merket](skjermbilder/119-kenneth-innarbeidet-utlegg.png); én ny folie + `renderSidebar` → merket borte.
- Et funn utenfor prompten: test L i `_kundeforslagRegressionTest` var rød på HEAD når batteriet kjøres i editoren (seksjon C etterlot en fast `#_fors-bunn`; grønn i en levende lenke). Rettet i testen (L kaller `_forslagRenderBunn()` selv).

### Batterier

| batteri | resultat |
|---|---|
| `_kundeforslagRegressionTest()` | 189/189 (33 nye: M/119 + seksjon N) |
| `_kundelenkeRegressionTest()` | 328/328 |

