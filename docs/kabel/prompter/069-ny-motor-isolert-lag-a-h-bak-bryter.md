# 069 · Kabelmotor fase 3: ny utleggsmotor (lag A–H) bygget isolert fra UI, bak bryter, målt mot galleriet

**Worktree `kabelmotor`.** Kjøres **etter** at Kenneth har godkjent 068s arkitekturforslag.
Spec: `docs/kabel/spec-kabelmotor.md` §1–§5. Arkitektur: `docs/kabel/arkitektur.md` (fra 068) —
**den går foran denne prompten** der de er uenige.

---

## Mål

En motor `generateCableGeo(roomId, productId, opts)` som for akseparallelle rom (spec §0.5) gir et
utlegg som består **alle harde krav** i `_cableGeometryCheck` — eller returnerer et strukturert
«ingen løsning» (spec §5). Den kobles **ikke** inn i kaskaden her; den kjøres bare fra galleriet og
fra konsollen. Bryter: `S.ui.cableGeoEngine` (av som standard).

## STEG 0

1. Les `docs/kabel/arkitektur.md` og 068-rapporten. Hva skal gjenbrukes fra V6, og hva er nytt?
2. Bekreft kontrakten fra 068 STEG 0.5: hvilket kabelformat motoren leverer, og hvilke felt som må
   være satt for at romstatistikk, label, materialliste, PDF, flerkabel og fryserom-reserve virker.
3. Kjør galleriet («før»-tabellen fra 068) så du har utgangspunktet.

## Gjør — lag for lag, hvert med egne enhetstester

| Lag | Leverer | Test (fra galleriet + egne) |
|---|---|---|
| **A** Normalisering | lovlig område = rom − kantavstand − hindringer − forbudte soner (polygonbiblioteket fra 068); hull og smale passasjer håndtert | areal av lovlig område mot håndregnet for rektangel, L, U, utsparing |
| **B** Celler | BCD for 0° og 90°; kritiske punkter; naboskap mellom celler | badHakk vertikalt: hakket gir riktig antall celler; horisontalt: én celle (eller som referansen) |
| **C** Global avstand | **én** CC og **én** fase for hele rommet; N løp og fase slik at `margin = (W − (N−1)·CC)/2` blir symmetrisk, generalisert | ingen celle har egen fase; CC-variasjon = 0 mellom parallelle løp |
| **D** Rute | graf over celler, lovlige overganger; én sammenhengende bane; flere rekkefølger og start/slutt prøvd | kontinuitet, 0 kryssinger, 0 snarveier |
| **E** Svinger | sirkelbuer r = CC/2, **trukket inn** så hele svingen ligger i lovlig område; alternativ sving når `min_bend > CC/2` | `boy` og `utenfor` = 0 |
| **F** Lengde | senterlinjelengde = Σ rette + buer + overganger; numerisk søk (CC i intervall, N, fase, retning, inntrukne vendepunkter, rekkefølge) mot produktlengde ±1 % | lengdeavvik ≤ 1 % eller begrunnet «ingen løsning» |
| **G** Start/slutt | hjørnekandidater med samme margin; `S.varmefolie.startCorner` respektert når lovlig | umulig starthjørne → nærmeste lovlige + forklaring |
| **H** Optimalisering | harde krav som filter, myke mål som poeng (spec §2) | beste kandidat er alltid lovlig |

**Ingen løsning** → `{ ok:false, reason, conflicts:[…], achievedLen, targetLen, cc, minClearance,
uncovered:[polygoner], suggestions:[{ kind:'2 kabler'|'annen lengde'|'annen CC', … }] }`. For «2
kabler»: prøv å dele lovlig område i to celle-grupper og løs hver — rapportér om det gir to gyldige.

## Galleriet etter 069

Kjør `_cableGalleryRun()` med ny motor som egen kolonne. Tabell: rom × retning × (dagens kaskade /
ny motor), med ok/feil og metrics. **badHakk vertikalt** skal gi gyldig utlegg eller begrunnet
«2 kabler»; **badHakk horisontalt** skal være minst like godt som referansen (CC 12,5, én slynge).

## Skal IKKE

- Koble motoren inn i `_autoFillCableImpl` (det er 070).
- Endre de fire eksisterende motorene.
- Støtte skrå/roterte rom (spec §0.5) — returner `{ ok:false, reason:'ikke akseparallelt' }`.
- Bruke ukontrollerte Bézier-svinger.

## Rapport

Galleritabellen før/etter med ny motor som egen kolonne, hvilke rom den ikke løser og hvorfor,
ytelse (ms per rom; et vanlig rom skal være godt under 500 ms). Endringslogg. Commit:
«069: kabelmotor — generateCableGeo (normalisering, BCD, global fase, rute, svinger innenfor, lengdesøk, start/slutt) isolert bak bryter».
