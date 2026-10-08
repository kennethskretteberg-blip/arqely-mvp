# Spec · Kundeforslag i presentasjonen — kunden ser løsningen og foreslår endringer per rom

**Status:** utkast 08.10.2026, bygger på [[spec-kundelenke]] (tabell, RPC-er, e-post, gjennomgangspanel).
**Gjelder:** `arqely-mvp/index.html` + Supabase. **Prompter:** `prompter/varmeplan/kundeforslag/042–044`.

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
   Tallene regnes med Varmeplans egne funksjoner (`selectCableByPower`-kandidatene gir W, W/m², CC
   per produkt) — aldri en egen formel på kundesiden.
4. **Ønsket flateeffekt** er en snarvei: kunden taster f.eks. 80 W/m² → kortet hopper til nærmeste
   produkt under og over (`below`/`above` fra `selectCableByPower`), begge vist med sine tall.
5. **Retning** (vannrett/loddrett) kan foreslås for kabel, matte og folie. Forhåndsvisning hos
   kunden er **ikke** et nytt utlegg (for tungt og for mye som kan gå galt uten innlogget bruker);
   kunden ser tallene og en pil for retning. Utlegget tegnes når Kenneth godkjenner.
6. **Per rom:** «OK som det er» eller «Foreslå endring» (produkt / ønsket flateeffekt / retning /
   kommentar). Et rom uten valg = ingen mening.
7. **Godkjenning hos Cenika:** panel «Kundeforslag» (samme ramme som 028) → per rom
   **Godkjenn** (kjører eksisterende auto-utlegg med nytt produkt/retning, ett `pushUndo`) eller
   **Avslå** med kort begrunnelse som kunden får på e-post. «Godkjenn alle» finnes.
8. **E-post begge veier** via `kundelenke-mail` (`kind='forslag'`), samme regler som før.
9. **«Godkjenn hele prosjektet»** (kunden aksepterer løsningen): tas i 044 kun som *signal*
   (navn + dato lagres på svaret og vises i prosjektet) — om det skal være en formell aksept
   (låse prosjektet, PDF-stempel) avgjør Kenneth i SPØRSMÅL.md.
10. **Lenketekst:** når en presentasjons- eller kundelenke lages, får Kenneth en ferdig tekst med
    lenken som **hyperlenke** («PRESENTASJON» / «FYLL INN MÅL») og en Kopier-knapp som legger
    både formatert tekst og ren URL på utklippstavla, så det kan limes rett inn i Outlook/Gmail.

## Datamodell (tillegg til `kundelenker`)

- `mode = 'forslag'`, `project_id`, `token` = **egen** kode (ikke `present_token`), `asked_walls` tom.
- Svar: `{ rooms: [{ roomId, ok: true|false, productId?, targetWm2?, direction?: 'h'|'v',
  comment? }], approveAll?: { name, at }, comment }`.
- `kundelenke_get` returnerer for `forslag` i tillegg: per rom dagens produkt-id og
  **alternativlista** (id, navn, W, lengde) for familien — regnet på serversiden? Nei: klienten
  har produktkatalogen (`_loadProducts` er allerede tilgjengelig anonymt for presentasjonen), så
  lista regnes i klienten med `getProductFamily` + `selectCableByPower`.

## Ikke i v1

- Live omtegning av utlegget hos kunden.
- Bytte produkt**familie** (f.eks. fra folie til kabel) — det er en samtale, ikke et klikk.
- Pris.
