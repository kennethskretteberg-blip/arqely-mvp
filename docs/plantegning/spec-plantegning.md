# Spec · Plantegning → vegger → rom, automatisk

**Status:** godkjent av Kenneth 08.10.2026. Planen han skrev, med fire endringer fra
etterprøvingen av koden (se «Hva etterprøvingen endret»). **Prompter:** `prompter/046–050`.
**Bygger på:** `spec-kundelenke.md`-seriens arbeidsmåte (STEG 0 måles før koding).

## Hva Kenneth vil

> «Slipp plantegningen inn, la appen finne veggene og rommene, men la meg se og rette veggene
> før de blir rom. Rom med navn på tegningen skal få navnet. Rom uten navn skal ikke rote til
> lista.»

## Prinsippet

**Tegningen er fasiten, motoren foreslår, brukeren bekrefter.** Ingenting blir rom før brukeren
har sett veggene.

## Flyten

```
1  Slipp PDF/DWG på etasjen
2  «Finn vegger og rom automatisk»  (eller «jeg tegner selv» som i dag)
3  Motoren jobber 2–10 s → tegningen som underlag, motorens vegger OPPÅ i rav
4  VEGG-SJEKK: flytt / slett / tegn vegg, snap til tegningen, dekning i %
5  «Lag rom» → senterlinjene lukkes til polygoner
6  Gjennomgang: navn fra tegningen, romtype gjettet, arealsjekk ✓/⚠, «Bekreft alle»
7  Rom uten navn samles i «Ikke navngitt (N)» — sammenleggbar, hentbar senere
```

## Hva etterprøvingen endret (08.10.2026)

Alle symbolene planen navngav ble målt. De som skal bygges finnes ikke; de som skal gjenbrukes
finnes. Fire ting ble rettet, og ett funn kom i tillegg:

**1. Rekkefølgen er snudd: vegg-sjekken bygges FØRST.** 020 bygde automatisk romgjenkjenning og
ga 590 «rom»; Kenneth kalte det «rot». Forskjellen nå er vegg-sjekken — altså er den den
bærende delen, ikke senterlinjene. Bygges motoren først, leverer den samme rot som 020 og det
finnes ingen flate å se feilen i. **046 er derfor arqely-flaten mot syntetisk motor-utdata**, og
den definerer kontrakten `/import/plan` skal oppfylle.

**2. Det er tre import-innganger, ikke én.** 021b-funnet: `_emptyPickImport` dekker både
verktøylinjens «Importer plantegning» og tom-tilstandens slipp-sone, og `_importPlanMenu` går
samme vei. I 021 ble bare én av tre rettet. 046 må rute alle gjennom den nye flyten.

**3. Dialogen anbefaler i dag den svakeste veien for PDF.** Målt i `_rasterMethodChoice`: for PDF
har «La appen finne rommene» **Anbefalt**-merket; bare for DXF/DWG er underlag-veien anbefalt.
Merket flyttes i 049 — ikke før flyten virker ende til ende.

**4. Skala fra arealer er dimensjonalt feil og sirkulær.** `stated_area / polygon_area` gir
m² per punkt², så `meters_per_point` krever kvadratrot. Og den hviler på at polygonet er riktig,
som er nøyaktig det som er usikkert før veggene er sjekket. **Tittelfeltet («1:100») er
primærkilden, arealene er kryss-sjekk.**

**5. Funn: gjennomgangsskjermen finnes allerede.** `#import-review-screen` + `_reviewRenderList`
har per rom redigerbart navn, redigerbart areal, advarsler (`r.review`, med `severity`), slett,
varmetype-velger, bulk-rad og live-sum. Planens «rom-kort» er altså stort sett bygget. **049
utvider den skjermen** — den bygger ikke en ny.

## Datakontrakt — `POST /import/plan`

```
{
  walls:       [{ a:[x,y], b:[x,y], thickness_cm, source:'rect'|'double'|'single' }],
  rooms:       [{ polygon:[[x,y],…], label_id|null, stated_area_m2|null }],
  labels:      [{ id, number|null, name|null, stated_area_m2|null, at:[x,y] }],
  calibration: { meters_per_point, method:'title'|'areas'|'none', confidence:0..1,
                 title_scale:'1:100'|null, area_ratio_mpp|null },
  coverage:    { used_length, total_length, pct },
  leftovers:   [{ a:[x,y], b:[x,y] }],
  background:  { svg|png, width, height, extent }
}
```

Koordinater i PDF-punkter; `meters_per_point` gjør dem til meter. Samme kontrakt for DWG (050).

## Regler

1. Ingenting blir rom før brukeren har trykket «Lag rom».
2. Motorens vegger er et eget lag (`S.planWalls` per etasje), lagret i prosjektet, aldri
   blandet med `room.walls`.
3. Rom uten navn skal finnes, men ikke forstyrre: grå kontur, egen sammenleggbar gruppe.
4. «Ikke navngitt» betyr *motoren fant ikke navnet* — ikke *rommet skal ikke varmes*. Rom med
   kjent navn og ingen varme navngis og får romtype «ingen varme».
5. Arealsjekken (oppgitt areal mot polygonets areal) er den beste gratis kvalitetskontrollen vi
   har. Den skal vises, ikke skjules.

## Ikke i v1

- Dører og vinduer som objekter.
- Flere etasjer i én PDF (én side = én etasje, som i dag).
- Møbler, skravur, målsetting som noe annet enn støy.
