// ============================================================================
// 031 punkt 4b: avsendernavnet skal være «<Org> Varmeplan», ikke «Cenika AS».
//
// `_orgShort` / `_avsenderNavn` bor i en Deno Edge Function, så de kan ikke nås fra
// regresjonsbatteriet i index.html. Dette skriptet leser funksjonene UT av .ts-fila,
// stripper typene og kjører dem — altså testes den ekte koden, ikke en kopi.
//
// Kjør:  node scripts/test-avsendernavn.mjs
// ============================================================================
import { readFileSync } from 'fs';
const src = readFileSync(new URL('../supabase/functions/kundelenke-mail/index.ts', import.meta.url), 'utf8');
// Hent ut de tre bitene og kjør dem som JS (typene strippes).
const bit = s => { const i = src.indexOf(s); if (i < 0) throw new Error('fant ikke ' + s); return i; };
const kode = src.slice(bit('const ORG_FORMER'), bit('// Bevisst konservativ'))
  .replace(/:\s*unknown/g, '').replace(/:\s*string/g, '')
  .replace(/export\s+/g, '');
const f = new Function(kode + '\nreturn { _orgShort, _avsenderNavn };')();

const saker = [
  ['Cenika AS',              'Cenika Varmeplan'],
  ['Cenika',                 'Cenika Varmeplan'],
  ['Bravida ASA',            'Bravida Varmeplan'],
  ['Lillesand ANS',          'Lillesand Varmeplan'],
  ['Bodø DA',                'Bodø Varmeplan'],
  ['Elektro Sandefjord SA',  'Elektro Sandefjord Varmeplan'],
  ['Hansen ENK',             'Hansen Varmeplan'],
  ['Cenika A.S.',            'Cenika Varmeplan'],
  ['Cenika as',              'Cenika Varmeplan'],
  ['Cenika AS.',             'Cenika Varmeplan'],
  ['Cenika  AS',             'Cenika Varmeplan'],   // dobbelt mellomrom
  ['Cenika, AS',             'Cenika Varmeplan'],
  // Skal IKKE klippes — bokstavene er del av et ord
  ['Vikinganes',             'Vikinganes Varmeplan'],
  ['Mesta',                  'Mesta Varmeplan'],
  ['Elektrikeren Bergenhus', 'Elektrikeren Bergenhus Varmeplan'],
  ['Nordsjø Elektro',        'Nordsjø Elektro Varmeplan'],
  // Kantsaker
  ['',                       'Varmeplan'],
  ['   ',                    'Varmeplan'],
  [null,                     'Varmeplan'],
  [undefined,                'Varmeplan'],
  ['AS',                     'Varmeplan'],          // bare selskapsform → tomt
  ['Varmeplan AS',           'Varmeplan'],          // ingen dobbel
  ['Varmeplan Norge AS',     'Varmeplan Norge'],
];
let feil = 0;
for (const [inn, forventet] of saker) {
  const fikk = f._avsenderNavn(inn);
  const ok = fikk === forventet;
  if (!ok) feil++;
  console.log((ok ? '✓' : '✗') + '  ' + String(JSON.stringify(inn)).padEnd(28) + '→ ' +
    JSON.stringify(fikk) + (ok ? '' : '   FORVENTET ' + JSON.stringify(forventet)));
}
console.log(feil ? `\n${feil} av ${saker.length} FEILET` : `\nAlle ${saker.length} bestått`);
process.exit(feil ? 1 : 0);
