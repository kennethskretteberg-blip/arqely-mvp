// import_flexfoil.mjs — Parse FlexFoil Excel and import all products to Supabase
// Run AFTER executing supabase_alter.sql in Supabase Dashboard!
//
// Usage:  node import_flexfoil.mjs
//         node import_flexfoil.mjs --dry-run   (preview only, no Supabase write)

import * as XLSX from 'xlsx';
import { readFileSync } from 'fs';

const DRY_RUN = process.argv.includes('--dry-run');

const FILE = '\\\\cen-srv01\\Brukere$\\kes\\Documents\\Romtegner\\FlexFoil\\flexfoil_artikler_04.03.2026.xlsx';
const SUPABASE_URL = 'https://nhzhffertfqdeslhzyxx.supabase.co';
const SUPABASE_KEY = 'sb_publishable_0QOhnETGSeJ4TiNCH12vtA_U3kIjSvC';

// Varmefolie category_id (from supabase_setup.sql: id=1 = Varmefolie)
const CATEGORY_ID = 1;

// ── Parse Excel ──────────────────────────────────────────────────────────────
const buf = readFileSync(FILE);
const wb  = XLSX.read(buf, { type: 'buffer' });
const ws  = wb.Sheets[wb.SheetNames[0]];
const rows = XLSX.utils.sheet_to_json(ws, { defval: '' });

console.log(`✓ Leste ${rows.length} rader fra "${wb.SheetNames[0]}"\n`);

// ── Map rows to Supabase records ──────────────────────────────────────────────
const products = rows
  .filter(r => r['Art.nr'] && r['Art.nr'].toString().trim() !== '')
  .map((r, idx) => {
    const bruttoWidthCm = parseFloat(r['Brutto bredde (cm)']) || null;
    const nettoWidthCm  = parseFloat(r['Netto bredde (cm)'])  || null;

    return {
      category_id     : CATEGORY_ID,
      article_no      : r['Art.nr']?.toString().trim()          || null,
      name            : r['Beskrivelse']?.toString().trim()     || null,
      el_no           : r['El.nr.']?.toString().trim()          || null,
      watt_per_m2     : parseFloat(r['W/m2'])                   || null,
      watt_per_lm     : parseFloat(r['Watt pr m @230V'])        || null,
      netto_width_mm  : nettoWidthCm  != null ? Math.round(nettoWidthCm  * 10) : null,
      brutto_width_mm : bruttoWidthCm != null ? Math.round(bruttoWidthCm * 10) : null,
      // width_mm stays as netto (backward compat)
      width_mm        : nettoWidthCm  != null ? Math.round(nettoWidthCm  * 10) : null,
      max_length_m    : parseFloat(r['Max lengde (m) v/10A'])   || null,
      // cut every 200 mm (standard for varmefolie)
      cut_interval_mm : 200,
      voltage         : 230,
      sort_order      : idx + 1,
      active          : true,
    };
  });

// ── Print preview table ───────────────────────────────────────────────────────
console.log('Produkter som importeres:');
console.log('─'.repeat(100));
const fmt = (v, w=14) => String(v ?? '').padEnd(w);
console.log(
  fmt('article_no') + fmt('name', 24) +
  fmt('el_no') + fmt('netto_mm',10) + fmt('brutto_mm',11) +
  fmt('W/m2',6) + fmt('W/lm',6) + fmt('max_m',7)
);
console.log('─'.repeat(100));
for (const p of products) {
  console.log(
    fmt(p.article_no) + fmt(p.name, 24) +
    fmt(p.el_no) + fmt(p.netto_width_mm, 10) + fmt(p.brutto_width_mm, 11) +
    fmt(p.watt_per_m2, 6) + fmt(p.watt_per_lm, 6) + fmt(p.max_length_m, 7)
  );
}
console.log('─'.repeat(100));
console.log(`Total: ${products.length} produkter\n`);

if (DRY_RUN) {
  console.log('🔍 Dry-run modus — ingen skriving til Supabase.');
  process.exit(0);
}

// ── Upsert to Supabase ────────────────────────────────────────────────────────
console.log('📤 Sender til Supabase (upsert på article_no)…');

const res = await fetch(
  `${SUPABASE_URL}/rest/v1/heating_products?on_conflict=article_no`,
  {
    method : 'POST',
    headers: {
      'apikey'       : SUPABASE_KEY,
      'Authorization': `Bearer ${SUPABASE_KEY}`,
      'Content-Type' : 'application/json',
      'Prefer'       : 'resolution=merge-duplicates,return=representation',
    },
    body: JSON.stringify(products),
  }
);

const body = await res.text();

if (!res.ok) {
  console.error('❌ Supabase feil:', res.status, body);
  process.exit(1);
}

const saved = JSON.parse(body);
console.log(`✅ ${saved.length} produkter lagret/oppdatert i Supabase!\n`);

console.log('Lagrede IDs:');
for (const p of saved) {
  console.log(`  id=${p.id}  ${p.article_no}  ${p.name}`);
}
