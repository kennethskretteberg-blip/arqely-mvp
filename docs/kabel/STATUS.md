# Kabelmotor 068–071 — status, merge-sjekkliste og hva som ikke er løst

Gren `kabelmotor`. Fire commits på toppen av `1519bb0`. `main` er urørt.
Galleriet: `docs/kabel/galleri.html` · Arkitektur: `docs/kabel/arkitektur.md` ·
Spørsmål: `docs/kabel/prompter/SPØRSMÅL.md`

---

## 1. Hva som er bygget, på én side

**Geometrikontrollen `_cableGeometryCheck(cable, room)` (068)** er fasiten. Den leser kabelens
senterlinje slik rendereren faktisk tegner den, og måler den mot de harde kravene i spec §1:
ligger kabelen i lovlig område, krysser den seg selv, kommer to deler nærmere hverandre enn
produktets minsteavstand, er noen sving trangere enn bøyeradien, stemmer lengden med produktet
(±1 %), er CC innenfor intervallet, og er banen sammenhengende. Myke mål (CC-variasjon,
kantsymmetri, hopp, dekning) måles også, men avviser ikke.

**Motoren `generateCableGeo(roomId, productId)` (069)** bygger utlegget lagvis:

| Lag | Hva den gjør |
|---|---|
| **A** Normalisering | Lovlig område = rom − kantavstand − hindringer − forbudte soner, med ekte polygon-offset (clipper-lib@6.4.2). |
| **B** Celler | Rommet deles i celler der skanlinjene skifter karakter: enten fordi de splittes/slås sammen (et hakk sett på tvers), eller fordi grensen gjør et **trinn** større enn én CC. |
| **C** Global avstand | **Ett** løpsrutenett for hele rommet: `pos_i = x0 + i × CC`, der `x0` velges én gang mot hele det lovlige området. Cellene sier bare hvilke løp de inneholder. Dette er rettelsen av «ulik CC». |
| **D** Rute | Cellene kobles til **én** bane. To celler kan bare kobles når løpene deres ligger ved siden av hverandre på rutenettet og begge snur i samme ende. Finnes ingen slik kjede → «ingen løsning». |
| **E** Svinger | Halvsirkler med radius CC/2, lagt på et nivå begge løp når. Løpene slutter CC/2 inne i lovlig område, så svingen får plass. |
| **F** Lengde | Søk over CC (bisekssjon) og symmetrisk inntrukne vendepunkter, mot produktets lengde ±1 %. Lengden **måles**, den tilordnes aldri. |
| **G** Start/slutt | Brukerens starthjørne brukes når det er lovlig; ellers nærmeste lovlige. |
| **H** Optimalisering | Harde krav er **filter** — et ulovlig utlegg kan aldri vinne på poeng. Myke mål er poeng. |

**I kaskaden (070):** ny motor og dagens kaskade kjøres begge, begge måles, og en dominans-test
avgjør. Ny motor tar bare over når den ikke er dårligere på noe mål. Bryter et utlegg likevel et
hardt krav, legges det ut **merket** — rød stiplet romkontur, røde ringer på bruddene, ⚠ i
labelen, defektliste og forslag i panelet, egen linje på PDF-romsiden.

---

## 2. Galleriet, rom for rom

28 rader = 14 fixture-rom × 2 retninger. «Før» = kaskaden slik den var ved `1519bb0`.

| | består | bryter et hardt krav | merket for brukeren |
|---|---|---|---|
| **Før (068)** | 5 | 23 | **0 — alle stille** |
| **Etter (070)** | **20** | 8 | **8 — alle merket** |

| Rom | Retn | Før | Etter | Motor etter |
|---|---|---|---|---|
| Rektangel 400×300 | v | feil: lengde | **ok** | geo |
| Rektangel 400×300 | h | ok | ok (uendret) | boustrophedon |
| L-rom | v | feil: utenfor | **ok** | geo |
| L-rom | h | feil: utenfor+nærføring+bøy+lengde | **ok** | geo |
| U-rom | v | feil: utenfor+lengde | **ok** | geo |
| U-rom | h | feil: utenfor+nærføring+lengde+brudd | **ok** (h→v, annonsert) | geo |
| Én hindring | v | feil: utenfor+nærføring+lengde+brudd | ⚠ samme | v6 |
| Én hindring | h | feil: utenfor+kryssing+nærføring+lengde+brudd | ⚠ samme | v6 |
| Flere hindringer | v | feil: utenfor+nærføring+lengde+brudd | ⚠ samme | v6 |
| Flere hindringer | h | feil: utenfor+kryssing+nærføring+lengde+brudd | ⚠ samme | v6 |
| Smal passasje | v | feil: seks brudd | **ok** | geo |
| Smal passasje | h | feil: fem brudd | **ok** (h→v, annonsert) | geo |
| Utsparing | v | feil: utenfor+nærføring+lengde+brudd | **ok** (v→h, annonsert) | geo |
| Utsparing | h | feil: lengde | **ok** | geo |
| Asymmetriske vegger | v | feil: fem brudd | **ok** (v→h, annonsert) | geo |
| Asymmetriske vegger | h | ok (dekning 81,1 %) | **ok (dekning 93,9 %)** | geo |
| Kabel for lang | v/h | feil: bøy+lengde | ⚠ samme | v6 |
| Kabel for kort | v/h | feil: lengde (+147 %) | **ok** | geo |
| Bøyeradius umulig | v/h | feil: bøy+lengde | ⚠ samme | v6 |
| Umulig starthjørne | v | ok (dekning 96,3 %) | **ok (97,4 %)** | geo |
| Umulig starthjørne | h | feil: lengde | **ok** | geo |
| Skrå (18°) | v/h | ok | ok (uendret) | skew |
| **Kenneths bad** | **v** | feil: seks brudd | **ok** (v→h, annonsert) | geo |
| **Kenneths bad** | **h** | feil: utenfor+lengde | **ok** | geo |

**15 bedre, 5 uendret, 0 dårligere.** Ingen rom der begge var gyldige tapte dekning.

---

## 3. Hva motoren IKKE løser — og hva brukeren får se

### a) Hindring midt i rommet (`enHindring`, `flereHindringer`)
Cellene ligger som `0 < {1,2} < 3` langs tverraksen: to endekolonner og to celler stablet i
midten. En bane innom alle fire må ut i en endekolonne og tilbake igjen, og tilbaketuren har
ingen lovlig korridor — den ville ligget nærmere løpene enn produktets minsteavstand.
**Dette er en geometrisk kjensgjerning, ikke en mangel i koden.**
**Brukeren får:** dagens V6-utlegg, merket ⚠ med defektlista, pluss et prøvd «2 kabler»-forslag
med målte lengder (`enHindring` loddrett: 39,2 m + 39,2 m) og riktig produkt i hver sone.
**Vei videre:** en validert transittkorridor (reservert plass langs en vegg, slik `leadRun` gjør
for flerkabel-soner). Koster dekning — se spørsmål 5.

### b) Kabel for lang for rommet (`kabelForLang`)
Et 3 m² rom med 96 m kabel: CC klemmes til produktets minimum 5 cm, og bøyeradien 3,2 cm krever
CC ≥ 6,4. Ingen lovlig CC finnes.
**Brukeren får:** ⚠ og forslag om et kortere produkt i samme familie.

### c) Bøyeradius umulig (`boyUmulig`)
Samme mekanisme: 10 m² med 200 m kabel gir CC 5,0 cm, og en U-sving med radius 2,5 cm er
trangere enn produktets 3,2 cm.
**Brukeren får:** ⚠ og forslaget om et produkt med mindre bøyeradius eller kortere lengde.

### d) Skrå og roterte rom (`skraa`)
Utenfor denne runden (spec §0.5). Rom med en vegg mer enn 5° fra aksen svarer «ikke
akseparallelt» og overlates til skew-motoren, som består galleriet for dem.
**Brukeren får:** samme utlegg som før.

### e) Flerkabel-soner
`_buildNCableZones` tvinger felles CC i alle soner (lik W/m² over sømmen). Ny motor søker sin
egen CC og kjenner ikke bindingen. Soner kjører derfor uendret på dagens kaskade.

### f) ⚠ Utlegg som allerede er lagret
Kontrollen kjører ved **auto-utlegg**, ikke ved åpning av et prosjekt. Et prosjekt lagret før
denne serien beholder utlegget sitt umerket til kabelen legges på nytt. Det er et bevisst valg —
å merke alle gamle prosjekter ved åpning er en stor endring — men det er også et **hull mot
målet «aldri et ulovlig utlegg uten merking»**, og bør avgjøres før merge.

---

## 4. Legge til et nytt testrom i galleriet

Én oppføring i `_cableFixtures` i `index.html`:

```js
mittRom: {
  name: 'Beskrivende navn',            // vises som overskrift i galleriet
  klasse: 'rettvinklet uregelmessig',  // fri tekst, grupperer i rapporten
  productId: 31,                       // et ekte produkt fra katalogen
  points: [{x:0,y:0},{x:400,y:0},{x:400,y:300},{x:0,y:300}],   // innvendig polygon, cm
  hindrings: [[{x:150,y:110},/* … */]],                        // valgfritt
  zones: [{ type:'forbidden', points:[/* … */] }],             // valgfritt
  note: 'Hvorfor dette rommet er med'                          // valgfritt
}
```

Deretter, i konsollen med dev-serveren i gang:

```
await _cableGalleryExport()
```

Den kjører alle rom × begge retninger × kaskaden + fem motorer, skriver
`docs/kabel/galleri.html` og legger tabellen i konsollen. For ett rom:
`await _cableGalleryExport({ only: ['mittRom'] })`.

---

## 5. Merge-sjekkliste (spec §8)

- [x] **badHakk får gyldig utlegg.** Vannrett: **47,00 m, avvik 0,00 %, CC 11,22 cm**,
      0 kryssinger, 0 knekker, 0 cm utenfor lovlig område, minste klaring 11,22 cm, 1 sammenhengende
      bane. Loddrett (eksplisitt valgt): ingen gyldig én-kabel-løsning finnes — appen legger
      vannrett og sier fra, med «Prøv vertikal likevel». På auto: gyldig, uten ⚠.
- [x] **badHakk vannrett er minst like godt som referansen.** Kenneths referanse (skew) var én
      slynge med CC 12,5 — men lå **0,83 cm fra veggen der produktet krever 5 cm**, over 213 cm av
      lengden, og traff lengden med −2,03 %. Ny motor: 0 cm utenfor, lengde 0,00 %.
      **Unntak som må godkjennes:** dekningen er 88,3 % mot referansens 96,5 %. Det er prisen for
      at alle løp i en celle er like lange (den låste regelen). Se spørsmål 2.
- [x] **Ingen galleri-rom dårligere enn før.** 15 bedre, 5 uendret, 0 dårligere (tabell i §2).
      Målt automatisk av `_cableGeometryRegressionTest`, som feiler hvis et rom som var gyldig
      blir ugyldig, eller taper dekning.
- [x] **Alle regresjonsbatterier grønne: 22 batterier.** Herunder nytt
      `_cableGeometryRegressionTest` (24 påstander) og `_prosjektlaasRegressionTest` (62 påstander).
      Én gammel påstand er endret, med begrunnelsen i koden ved testen — se endringsloggen for 070.
- [x] **Ingen endring i lagret dataformat.** Tre ekte prosjekter åpnet **lesende** med begge
      lagrede former: «Vidsynveien 175» (1 kabel, `runs`/boustrophedon), «Vålerengahjemmet»
      (4 kabler, `runs`, 15 rom) og «Kiwi Søvik» (16 kabler, `pathEls`/skew). Alle rom gir
      romstatistikk og tegnet romside uten feil; ingen kabel endret form eller ble merket.
- [x] **`docs/kabel/galleri.html` oppdatert** — 168 rader (14 rom × 2 retninger × kaskaden +
      5 motorer), generert etter 070.
- [ ] **Kenneth har sett galleriet og forhåndsvisningen, og sagt «merge».**

---

## 6. Åpne beslutninger før merge

1. **Lengdetoleransen ±1 %** (spørsmål 1). Motoren treffer den i alle rom den løser, flere på
   0,00 %, så den bremser ikke lenger — men den avgjør fortsatt når ⚠ vises.
2. **Dekning mot kantavstand i badet** (spørsmål 2): 88,3 % og lovlig, mot 96,5 % og 0,83 cm fra
   veggen. Dette er det eneste målet der ny motor er dårligere enn dagens.
3. **Nye utlegg kan ikke dras** (spørsmål 3) — `pathEls`-formen er auto-utfylling-bare.
4. **Rettvinklede overganger** regnes som hardt bøyebrudd (spørsmål 4).
5. **Transittkorridor** for hindringsrom (spørsmål 5) — eller er «2 kabler» riktig svar der?
6. **Skal lagrede utlegg kontrolleres ved åpning** (§3f)? I dag: nei.
