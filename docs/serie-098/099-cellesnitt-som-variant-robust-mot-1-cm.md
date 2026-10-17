# 099 · Kabelmotor: 1 cm veggflytting fjerner en celle i Rom 5 (5 → 4), og dekningen faller fra 93 til 84 %. Celleinndelingen nær terskelen skal være en **variant**, ikke et terningkast — **STOPP før push**

**Kjøres på `main`, etter 098.** Fil `index.html`. Linjenumre fra `cd72f0e`, men symbolnavnene er det som gjelder.
**Ikke push.** Stopp etter rapport. Underlag: STATUS §38 (forstyrrelsestesten) og §33–§35.

---

## Hvor vi står (din egen måling, §38)

Forstyrrelsestesten ga **34 brudd av 136**. Nesten alle har samme signatur:

| rom / produkt | brudd | signatur |
|---|---|---|
| rom5 / 700W | 20 av 40 | **celler 5 → 4** · CC 13,20 → 11,62 · dekning 93,4 → ~84 % |
| rom5 / 600W | 9 av 16 | CC 13,20 → 11,62 · 78,4 → ~71 % (og ett brudd *oppover*, 78 → 90 %) |
| rom5 / 10T | 4 av 4 | R-START tapt (118 cm) |
| rekt398 | 0 av 32 | stabil |
| badHakk | 1 av 44 | vegg 5 −2 cm gir «ingen løsning» |

Kenneths rom ligger altså på en knivsegg. En bruker som drar en vegg 1 cm, får et vesentlig dårligere
utlegg, og det er ikke akseptabelt. 091b gjorde søket komplett, men ikke robust.

## Hypotese (Cowork, må måles)

Lag B deler rommet i celler der skanlinjene skifter karakter, også der **«grensen gjør et trinn større
enn én CC»** (STATUS §1). Det er en skarp terskel. Er et trinn i Rom 5 rundt én CC (13 cm) høyt, kan
1 cm vippe det over eller under, slik at en celle oppstår eller forsvinner. Da endres hele rutenettet,
transitten og hvilke N som går.

Lærdommen fra 090 (speilet slynge) og 093 (forskjøvet ytterbane): et valg som er gunstig i noen rom og
ugunstig i andre, skal være en **variant** som scores, ikke en regel.

## STEG 0 — mål

1. For rom5 / 700W / loddrett / `tr` med én av bruddveggene ± 1 cm: vis celleinndelingen før og
   etter. Hvilken celle forsvinner, og hvilket tall krysser hvilken terskel (i mm)? Er det
   trinn-mot-CC-terskelen i lag B, eller noe annet?
2. Er det samme mekanisme bak 600W-bruddene, 10T R-START-bruddene og badHakk vegg 5?
3. Hvis du bygger **5-celle-inndelingen manuelt** på den forstyrrede geometrien (cellegrensen beholdes
   der den var): er utlegget med CC 13,20 gyldig?

## Gjør (ut fra målingen)

1. **Cellesnitt nær terskelen er en variant.** Når en grense ligger innenfor et bånd rundt terskelen
   (forslag: ± 0,25 CC, bekreft med målingen), bygges **begge** inndelingene: med og uten snittet.
   Begge går gjennom transittvarianter, ruting, kontroll, R-START, R-VEGG og R-ENDE, og poengsummen
   avgjør.
2. **Bare der den trengs:** utenfor båndet er alt som før, slik at tiden ikke eksploderer. Mål tiden.
3. **Dominans:** ingen av de 142 baselinjeradene skal bli dårligere. Lag en tabell over endrede rader.

## Etterpå (hvis tiden rekker)

- Kjør forstyrrelsestesten på nytt. Mål: rom5 700W ≤ 2 brudd av 40, og ingen R-START-brudd.
- Fullfør rom5 600W vegg 4–9 og 10T vegg 1–9 (§38 «ikke fullført»), i biter med `veggFra`/`veggTil`.
- Porten som balløner (§38): mål minnebruk og cache-størrelse mellom rader i én blokk. Er det en cache
  som vokser (transittvarianter, clipper-resultater), skal den tømmes per rad.

## Skal IKKE

- Løsne et hardt krav eller endre R-reglene.
- Flytte CC for jevnhetens skyld.
- Pushe `main`.

## Rapport — og STOPP

Med teskje:
- hvilken celle som forsvinner, og ved hvilket tall (STEG 0.1)
- om det er én mekanisme eller flere (0.2)
- om 5-celle-utlegget er gyldig på forstyrret geometri (0.3)
- hva som ble bygget
- forstyrrelsestesten før og etter
- baselinjen (endrede rader)
- tid per utlegg og for porten

Fortell også hva Kenneth skal sjekke på localhost: legg ut 700W øverst til høyre i Rom 5 på en kopi.
Dra så V6 eller V10 1 cm, slett og legg ut på nytt. Utlegget skal se likt ut.

Endringslogg. Commit: «099: kabelmotor — cellesnitt nær terskelen bygges som variant (med og uten),
robust mot 1 cm veggflytting; forstyrrelsestest før/etter». **Stopp.**
