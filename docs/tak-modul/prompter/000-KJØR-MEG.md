# 000 · KJØR MEG — «Stedfestet tegneflate» for bakke og tak (prompt-serie 001–007)

Dette er kjøreinstruksen for en serie på sju prompter som skal kjøres **i rekkefølge, uten Kenneth
ved rattet**. Les hele denne fila før du starter 001.

## Hvor filene ligger (oppdatert 24.09, etter første kjøreforsøk)

Alt du trenger ligger **i repoet** `~/Code/arqely-mvp`:

| Hva | Sti |
|---|---|
| Denne fila + 001–007 | `docs/tak-modul/prompter/000-KJØR-MEG.md` … `007-*.md` |
| Tak-planen (kontekst, ikke fasit for serien) | `docs/tak-modul/Varmeplan-plan-tak-modul.md` (§19 og fase 3a-0 handler om kart-laget; §6 har `Provenance`/`Source` som 004 bruker) |
| Research fra 21.09 | `docs/tak-modul/research-og-arkitektur.md` — fortsatt gyldig som kildesjekk; der planen og research-notatet sier ulikt, **gjelder planen** (den er nyere og bygger på notatet) |
| Arbeidsfiler | `docs/tak-modul/STATUS.md` og `docs/tak-modul/SPØRSMÅL.md`. STATUS.md du skrev 24.09 **beholdes** — legg nye innslag øverst. SPØRSMÅL.md: kopier malen fra `prompter/SPØRSMÅL.md` hvis den ikke finnes i `docs/tak-modul/`. |
| Nytt repo | `~/Code/varmeplan-roof` finnes **ikke** ennå — det er 001 sin jobb å opprette det (`git init`, første commit). |

Promptene 001–004 gjør endringer i `varmeplan-roof`, 005–007 i `arqely-mvp`. STATUS/SPØRSMÅL
ligger alltid i `arqely-mvp/docs/tak-modul/` uansett hvilket repo prompten gjelder, og committes
der sammen med (eller rett etter) hver prompt — det er Kenneths ene oversikt.

## Hva serien bygger

«Hent fra kart» i Varmeplans snø-modul: adresse → kartutsnitt med bygningsomriss, eiendomsgrense og
terreng → brukeren tegner området rett på kartet → området har riktig målestokk uten kalibrering →
matter/kabel som før. Kart-laget bygges én gang og gjenbrukes senere av Tak-modulen (planen
`planer/Varmeplan-plan-tak-modul.md`, §19 og fase 3a-0).

Arkitektur (låst for serien):
- **Nytt repo `varmeplan-roof`** (Python 3.12, FastAPI, `uv`) = tjenesten som snakker med Kartverket.
  Ligger i `~/Code/varmeplan-roof`. Prompt 001–004.
- **`arqely-mvp/index.html`** = klient. Prompt 005–007. Tjenesten kjøres lokalt på `http://localhost:4100`
  mens 005–007 kjøres (start den selv: `cd ~/Code/varmeplan-roof && uv run uvicorn app.main:app --port 4100`).
- Kartbildet leveres som **ett georeferert PNG** per etasje og installeres som en vanlig bakgrunn
  (`S.bgs`) med kjent størrelse i cm → ingen kalibrering, ingen kartbibliotek i nettleseren.
- Lokalt verdensrom per etasje: verdens (0,0) = utsnittets **sørvestre hjørne**, x mot øst,
  y positiv nedover på skjermen (som i dag: verdens-Y øker nedover — bekreftet i kodebasen), så
  utsnittets nordkant ligger på `y = −heightCm`. Alt lagres i `bg.geo` (prompt 005).

## Regler for hele serien

1. **Én prompt = én commit** (i riktig repo), med endringslogg-innslag der repoet har en
   (`arqely-mvp/docs/endringslogg.md`; `varmeplan-roof/docs/endringslogg.md` opprettes i 001).
2. **STEG 0 først** i hver prompt: les koden som nevnes, bekreft antakelsene, skriv avvik i rapporten.
   Linjenumre i promptene er fra 24.09.2026 og kan ha flyttet seg — symbolnavnene er fasit.
3. **Tester grønne før commit.** Rødt → fiks. Kan det ikke fikses innenfor promptens omfang → skriv
   det i `STATUS.md`, **stopp serien** og la resten stå.
4. **Spørsmål stilles ikke — de skrives.** Alt du ellers ville spurt Kenneth om, skrives i
   `SPØRSMÅL.md` (mal ligger her) med ditt eget **midlertidige valg** og begrunnelse, og du går
   videre med det valget. Kenneth svarer på alt til slutt.
5. **Ting som krever Kenneths hender** (Fly-deploy, hemmeligheter, kjøp av data): forbered alt
   (filer, kommandoer, README), gjør det **ikke**, og legg det i `SPØRSMÅL.md` under «Kenneth må gjøre».
6. **Ingen eksterne kall i tester.** Alle tester mot Kartverket bruker lagrede svar (fixtures i
   `tests/fixtures/`), tatt opp én gang under utvikling (script `scripts/record_fixtures.py`).
   Live-kall skjer bare i STEG 0 og i manuelle røyk-tester du beskriver i rapporten.
7. **Lisens og kreditering:** alle Kartverket-data er CC BY 4.0 → «© Kartverket» skal følge
   bildet (i `bg.geo.attribution`), vises i ctxbar og på PDF. Bygningsomriss — **avgjort 24.09**:
   kun CC BY 4.0-kilder lagres som produktdata: INSPIRE-WFS hvis den svarer → omriss avledet fra
   DOM1−DTM1 (bygges i 004, `source:'DOM1'`) → ingen omriss (`null`, brukeren tegner selv).
   **OSM (ODbL) brukes ikke** — verken som fallback eller hint. Se 002 for detaljene.
   Er INSPIRE-WFS nede i STEG 0: ikke vent på den — lag en liten syntetisk GML-fixture og gå videre.
8. **Rør aldri** `referanse/kunder-*.csv`, Supabase-migrasjoner utenom det promptene ber om, eller
   lumelo-backend.
9. **Frontend uten tjeneste skal virke:** når `varmeplan-roof` ikke svarer, skal «Hent fra kart»
   si det pent og alt annet i appen være uendret.
10. Skriv `STATUS.md` etter **hver** prompt: nummer, commit-hash, hva som ble gjort, hva som ble
    avviket, tid brukt. Det er Kenneths oversikt når han kommer tilbake.

## Rekkefølge

| # | Fil | Repo | Kort |
|---|---|---|---|
| 001 | `001-varmeplan-roof-repo.md` | varmeplan-roof (nytt) | skjelett, nøkkel, tester, docs |
| 002 | `002-locate-adresse-bygning-omriss.md` | varmeplan-roof | `/roof/locate`: adresse → bygg → omriss (INSPIRE eller `null`) |
| 003 | `003-background-kartbilde.md` | varmeplan-roof | `/roof/background`: georeferert PNG |
| 004 | `004-terreng-helning-og-quick-roofmodel.md` | varmeplan-roof | `/roof/slope`, `/roof/model?level=quick`, DOM1-omriss inn i `/roof/locate` |
| 005 | `005-frontend-hent-fra-kart.md` | arqely-mvp | klient + «Hent fra kart» i snø |
| 006 | `006-frontend-omriss-eiendomsgrense-snap-helning.md` | arqely-mvp | vektorlag, snapping, helning |
| 007 | `007-pdf-attribusjon-regresjonstest-dokumentasjon.md` | arqely-mvp | PDF, tester, dokumentasjon |

Start med 001. Når 007 er ferdig: oppsummer i `STATUS.md` med en liste over alt Kenneth må svare
på eller gjøre, sortert etter hvor mye det blokkerer.
