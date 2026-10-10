# Spec · Kundeforslag i presentasjonen — kunden ser løsningen og foreslår endringer per rom

**Status:** utkast 08.10.2026, **v2 10.10.2026** (regel 7 endret, 11–16 lagt til etter Kenneths live-test), bygger på [[spec-kundelenke]] (tabell, RPC-er, e-post, gjennomgangspanel).
**Gjelder:** `arqely-mvp/index.html` + Supabase. **Prompter:** `prompter/varmeplan/kundeforslag/042–044`, `kundeforslag-2/053–055`.

## Hva Kenneth vil (08.10)

> «Kunden skal se det samme som jeg ser når jeg trykker Presentasjon. Kunden trykker på et rom
> og kan pile opp/ned mellom produktene — InFloor 10T 600 W, 700 W, 800 W … — og i sanntid se
> flateeffekt, W/m² og CC. De kan også oppgi ønsket flateeffekt, så finner appen nærmeste valg
> over og under. De kan endre retning for kabel, matter og folie. Vi får melding om at kunden
> ønsker endring, trykker godkjenn, og layouten endrer seg. Når jeg sender en presentasjon vil jeg
> ha en fast tekst «PRESENTASJON» med lenken i, som jeg kopierer rett inn i e-posten.»

## Regler

1. **Presentasjonen er fasiten for hva kunden ser.** Kundeforslag er et lag *oppå* `?present=`:
   samme read-only visning, samme romkort (`_presentRoomDetailHtml`), pluss et forslagskort.
   Kunden endrer aldri prosjektet — forslaget lagres som svar på en kundelenke med `mode='forslag'`
   (spec-kundelenke regel 2, 7, 10 gjelder).
2. **Kunden ser produktnavn, effekt, flateeffekt, W/m² og CC — aldri priser, artikkelnummer,
   kundenavn eller andre prosjekter.** (Kenneth 08.10: produktnavn er greit.)
3. **Alternativene er de reelle produktene** i samme familie som ligger i rommet (kabel: samme
   familie, f.eks. InFloor 10T; folie/matte: samme familie, variantene i W/m² eller bredde).
   **(054)** For kabel fortsetter lista forbi største enkeltkabel med `N × like` (N ≤ 3), og
   hver rad bærer `cableCount`. En rad er identifisert av **(produkt, antall)** — 1 stk og
   2 stk 1100 W er to ulike rader med ulik CC.
   Tallene regnes med Varmeplans egne funksjoner (`selectCableByPower`-kandidatene gir W, W/m², CC
   per produkt) — aldri en egen formel på kundesiden.
4. **Ønsket flateeffekt** er en snarvei: kunden taster f.eks. 80 W/m² → kortet hopper til nærmeste
   produkt under og over, begge vist med sine tall. **(054)** Hentes fra **stigen** (regel 3),
   ikke fra `selectCableByPower.below/above` — ellers ville «Finn» hatt et annet tak enn pilene.
5. **Retning** (vannrett/loddrett) kan foreslås for kabel, matte og folie. Forhåndsvisning hos
   kunden er **ikke** et nytt utlegg (for tungt og for mye som kan gå galt uten innlogget bruker);
   kunden ser tallene og en pil for retning. Utlegget tegnes når Kenneth godkjenner.
6. **Per rom:** «OK som det er» eller «Foreslå endring» (produkt / ønsket flateeffekt / retning /
   kommentar). Et rom uten valg = ingen mening.
7. **Godkjenning hos Cenika (v2):** vindu «Kundeforslag» → per rom **Godkjenn** (kjører
   eksisterende auto-utlegg med nytt produkt/retning/antall, ett `pushUndo`) eller **Avslå** med kort
   begrunnelse. Beslutningen lagres **per rom med én gang** (`applied_result`). Når alle rom med
   forslag er behandlet er forslaget **ferdig** (`status='applied'`) — uten at noe sendes.
   «Godkjenn alle» finnes. Hvert rom kan angres for seg.
8. **E-post begge veier** via `kundelenke-mail` (`kind='forslag'`), samme regler som før.
9. **«Godkjenn hele prosjektet»** (kunden aksepterer løsningen): tas i 044 kun som *signal*
   (navn + dato lagres på svaret og vises i prosjektet) — om det skal være en formell aksept
   (låse prosjektet, PDF-stempel) avgjør Kenneth i SPØRSMÅL.md.
10. **Lenketekst:** når en presentasjons- eller kundelenke lages, får Kenneth en ferdig tekst med
    lenken som **hyperlenke** («PRESENTASJON» / «FYLL INN MÅL») og en Kopier-knapp som legger
    både formatert tekst og ren URL på utklippstavla, så det kan limes rett inn i Outlook/Gmail.

11. **Gjennomgangen skjer på lerretet.** Vinduet er flyttbart og ikke-modalt; klikk på rom i
    vinduet velger og zoomer til rommet; godkjenning kjører motoren mens rommet er synlig.
12. **Rom med ubehandlet kundeønske er merket i romlista** (blått 💬) og viser ønsket i en egen
    rute når rommet er valgt — vinduet er en snarvei, ikke eneste vei.
13. **Ingen e-post sendes automatisk fra Cenika-siden.** «Send svar til kunden» er en valgfri knapp.
14. **Stigen fortsetter forbi største kabel** med **N × like** kabler (N ≤ 3), bare når summen
    overstiger største gyldige enkeltkabel. Blandede kabler er ikke et klikk. «Ønsket flateeffekt»
    bruker samme stige.
15. **Rom uten varme kan få et forslag:** kunden velger type (kabel/matte) → serie → variant fra
    samme katalog Kenneth ser. Rom som alt har varme bytter aldri type. Snørom og fryserom utenfor.
16. **Hele dialogen per prosjekt er en logg** i appen (presentasjon/mål sendt, svar mottatt, hva
    kunden endret og skrev, hva Cenika gjorde, runde for runde), avledet av `kundelenker` +
    `hendelser`. Kunden ser den ikke.

## Datamodell (tillegg til `kundelenker`)

- `mode = 'forslag'`, `project_id`, `token` = **egen** kode (ikke `present_token`), `asked_walls` tom.
- Svar: `{ rooms: [{ roomId, ok: true|false, productId?, cableCount?, nyType?: 'kabel'|'matte',
  targetWm2?, direction?: 'h'|'v', comment? }], approveAll?: { name, at }, comment }`.
- Behandling (053): `applied_result: [{ roomId, roomName, status, grunn?, at, by, resultat? }]`,
  `svar_sendt_at`. Logg (055): `hendelser jsonb` (`kopiert`, `trukket`, `svar_sendt` …).
- `kundelenke_get` returnerer for `forslag` i tillegg: per rom dagens produkt-id og
  **alternativlista** (id, navn, W, lengde) for familien — regnet på serversiden? Nei: klienten
  har produktkatalogen (`_loadProducts` er allerede tilgjengelig anonymt for presentasjonen), så
  lista regnes i klienten med `getProductFamily` + `selectCableByPower`.

## Ikke i v1

- Live omtegning av utlegget hos kunden.
- Bytte produkt**familie** i et rom som alt har varme — det er en samtale, ikke et klikk.
  (Tomme rom: **oppheves** av regel 15 — der velger kunden type → serie → variant fritt.)
- Blandede kabler (1100 + 1300) som ett klikk. Bare N × like.
- Pris.
