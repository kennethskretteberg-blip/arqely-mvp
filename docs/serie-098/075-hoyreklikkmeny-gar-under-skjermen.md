# 075 · Høyreklikkmenyen på rom går under skjermkanten — mål den ekte høyden og hold den innenfor skjermen, og gjør romtype-lista kompakt

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Prioritet: Høy** · **Størrelse: liten**
**Kjøres på `main`** (ikke i kabelmotor-worktreen). Linjenumre fra `cd72f0e` — symbolnavn er fasit.

---

## Kenneths ord

> «Menyen som kommer opp ved høyreklikk fra rom er så stor at den går under skjermen, ingen mulighet å
> se hva som står nederst.»

Skjermbildet: høyreklikk på et rom midt/nede på lerretet → menyen starter rundt midten av skjermen og
slutter langt under nederste kant. Synlig er «Sett inn produkt» og romtypene Bad … Oppholdsrom; resten
(Fryserom, Annet, Gi nytt navn, varmetype, Bytt produkt, Fjern produkter, Skjul labels, **Slett rom**)
kan ikke nås.

## Hva som skjer — målt i koden

- `showCtxAt(x, y)` (:53612) plasserer menyen med en **fast antakelse** om høyden:
  `top = min(y, innerHeight − 230)`. Menyen har ingen `max-height` eller rulling (`#ctx-menu` :854).
- Rom-menyen (`canvasRoomCtxMenu` :59919) har ca. 20 rader: Angre, Sett inn produkt, **ti romtyper**
  (`ROOM_TYPES`, én rad hver), Gi nytt navn, varmetype-radene (`_varmetypeCtxItems`), Bytt produkt,
  Fjern produkter, Skjul labels, Slett rom — godt over 230 px.
- `showCtxAt` brukes av 15 menyer; alle har samme svakhet, rom-menyen er bare den lengste.

## Gjør

### 1. `showCtxAt` måler i stedet for å gjette (gjelder alle 15 menyer)

- Vis menyen usynlig (`visibility:hidden; display:block`), les `offsetWidth/offsetHeight`, plasser, og
  gjør den synlig.
- Vertikalt: får den plass under musepekeren → der. Ellers **over** pekeren hvis det er plass der.
  Ellers klem til `[8, innerHeight − høyde − 8]`.
- Horisontalt: samme, mot høyre/venstre kant (erstatter fast `innerWidth − 180`).
- CSS: `#ctx-menu { max-height: calc(100vh - 16px); overflow-y: auto; }` — er menyen høyere enn skjermen
  (liten laptop), kan den rulles i stedet for å forsvinne.
- Gjelder også `openProduktMenuFrom` og andre egne popup-menyer som plasseres med faste tall — let etter
  `innerHeight-` med et hardkodet tall i nærheten av menyplassering og bruk samme hjelpefunksjon.

### 2. Kompakt romtype-valg i rom-menyen

Ti romtyper som én rad hver er det som gjør menyen så lang. Bytt til et **rutenett med to kolonner**
under «Velg romtype» (ikon + navn, samme klikk som i dag `setRoomType(...)`), med gjeldende romtype
uthevet (`sel`). Det halverer høyden på den delen. Rekkefølgen beholdes.

## Skal IKKE

- Fjerne eller flytte valg ut av menyen.
- Endre hva valgene gjør.

## Test

1. Høyreklikk på et rom helt nederst på lerretet (laptop-skjerm, 13–14") → hele menyen synlig, åpnet
   **over** pekeren, «Slett rom» kan klikkes.
2. Høyreklikk øverst → åpner under pekeren som før.
3. Høyreklikk helt til høyre → menyen går ikke ut av høyre kant.
4. Nettleservindu gjort lavt (ca. 500 px) → menyen rulles, ingenting er utenfor skjermen.
5. Romtype i to kolonner, gjeldende uthevet, klikk setter romtypen som før.
6. Vegg-, hjørne-, folie-, hindring- og mål-menyene (de andre `showCtxAt`-brukerne) åpner fortsatt riktig.

## Skal heller IKKE

- Pushe `main`. Kenneth pusher selv.

## Rapport

Endringslogg. Commit: «075: høyreklikkmenyer måler egen høyde og holdes innenfor skjermen (over pekeren
ved behov, rulling som siste utvei); romtyper i to kolonner».
