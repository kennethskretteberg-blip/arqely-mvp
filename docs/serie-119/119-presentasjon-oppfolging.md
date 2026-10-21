# 119 · Presentasjon, oppfølging av serie-116: skjul produktmål for kunden, klikk-styring også i ren presentasjon, forhåndsvalg på tvers av etasjer, vegg-tabell per vegg for mål i forslagssvar, og UTLEGG-merket ryddes av seg selv

**Repo:** `arqely-mvp` · **Fil:** `index.html` · **Gren:** `main`. Svar skrives i `docs/serie-116/SPØRSMÅL.md`.

---

## Kenneths svar (21.10.2026)

| | Svar |
|---|---|
| 116/1 | **Blå** (`--info`) beholdes |
| 116/2 | OK: 120 px |
| 116/3 | **Skjul produktmålene** (målsatt folie/kabel/matte) for kunden. Kunden ser bare veggmål |
| 116/4 | **Klikk-styring** også i ren presentasjon. Hover bytter ikke rom lenger |
| 116/5 | **Forhåndsvalget ser på alle etasjer** og bytter etasje om nødvendig |
| 117/1 | Mållenka får panelet **senere**. Ikke nå. Legg i SPØRSMÅL at det står igjen |
| 117/2–6 | OK |
| 118/1 | **Ja: vegg-tabell per vegg** også for mål i forslagssvar |
| 118/2 | OK: innstillingen i `note` |
| 118/3 | OK: lov å sende bare mål |
| 118/4 | OK |
| 118/5 | **UTLEGG-merket fjernes automatisk** når rommet får nytt utlegg, uansett hvilken vei |
| 118/6 | Følg med, ingen endring |

## STEG 0

1. **116/3:** hvilke brytere styrer produktmålene (`3.2 cm`, `871.8 cm` …) i presentasjonen, og hvor tegnes de?
2. **116/4:** `_presentHover` og hvor ren presentasjon velger rom.
3. **116/5:** forhåndsvalg-funksjonen fra 116, og hvordan presentasjonen bytter etasje (117/4 la til bytte ved
   klikk i romlista).
4. **118/1:** mållenkas gjennomgangsvindu med «Blir»-kolonne og avkryssing per vegg. Hva binder det til
   mållenkas `_kundeLinkCache`/status? Hva må bli et argument?
5. **118/5:** alle veier som legger nytt utlegg i et rom. Finnes én felles kanal (f.eks. `renderSidebar`, slik 109
   brukte, eller cache-invalidering per rom) der «rommet har fått produkter siden merket ble satt» kan
   oppdages?

## Gjør

1. **Produktmål skjules for kunden** i presentasjon og forslagslenke, uansett Kenneths egne brytere. Kenneths egen
   visning og PDF er uendret.
2. **Klikk-styring:** hover bytter ikke rom i noen kundevisning. Klikk i tegning eller romliste velger rom.
3. **Forhåndsvalg:** første rom med produkter **i alle etasjer** (etasjerekkefølge, så romrekkefølge). Etasjen
   byttes til den rommet ligger i.
4. **Vegg-tabell per vegg** i forslagsgjennomgangen: samme vindu og visning som mållenkas gjennomgang (Vegg · Var
   · Kunden sier · Blir · ☑), med svaret som argument og «ikke lukk lenka» som i 118. «Arbeid inn» bruker bare
   avkryssede vegger. Punkt-modus (hjørne flyttet) viser rommet samlet med én avkryssing, slik mållenka gjør.
   **Gjenbruk, ikke kopier.**
5. **UTLEGG-merket:** fjernes automatisk når rommet får et nytt utlegg etter at merket ble satt (lagre et
   tidsstempel eller en produkt-signatur på merket, og sjekk det i felles kanal fra STEG 0.5). Klikk på merket
   fjerner det fortsatt manuelt.

## Skal IKKE

- Endre svarformat eller RPC-er.
- Endre mållenka (`?kunde=`).
- Pushe.

## Test

1. Kundevisning: ingen produktmål. Kenneths visning: produktmål som før.
2. Ren presentasjon: hover bytter ikke, klikk gjør det.
3. Prosjekt der første etasje er uten produkter: forhåndsvalget havner i andre etasje.
4. Forslagssvar med tre endrede vegger: kryss av to og arbeid inn. Bare de to endres.
5. Innarbeid mål og legg ut ny kabel, matte og frihånds-matte i tre rom. Merket forsvinner i alle tre.
6. `_kundeforslagRegressionTest`, `_kundelenkeRegressionTest` grønne, og nye sjekker for punkt 1–5.

## Rapport

STEG 0 · skjermbilder · svar skrevet inn. Commit: «119: presentasjon — produktmål skjult for kunden, klikk-styring, forhåndsvalg over etasjer, vegg-tabell per vegg i forslagssvar, UTLEGG-merket ryddes ved nytt utlegg».
**STOPP**.
