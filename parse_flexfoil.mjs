// parse_flexfoil.mjs — Read FlexFoil Excel and import to Supabase
import * as XLSX from 'xlsx';
import { readFileSync } from 'fs';

const FILE = '\\\\cen-srv01\\Brukere$\\kes\\Documents\\Romtegner\\FlexFoil\\flexfoil_artikler_04.03.2026.xlsx';

const SUPABASE_URL = 'https://nhzhffertfqdeslhzyxx.supabase.co';
const SUPABASE_KEY = 'sb_publishable_0QOhnETGSeJ4TiNCH12vtA_U3kIjSvC';

// Column name aliases (Norwegian/English) → canonical field
const COL_MAP = {
  article_no      : ['artikkelnummer','artikkel_nr','art.nr','artnr','article_no','art nr','artnummer'],
  name            : ['artikkelnavn','navn','name','produktnavn'],
  el_no           : ['elnummer','el_nr','el.nr','elnr','el nr','elnr.'],
  watt_per_m2     : ['watt_m2','w/m2','watt/m2','watt pr m2','watt pr kvm','watt_per_m2','w_m2','w/m²','watt/m²'],
  watt_per_lm     : ['watt_lm','w/lm','watt/lm','watt pr lm','watt pr løpemeter','watt_per_lm','w_lm'],
  netto_width_mm  : ['nettobredde_mm','nettobredde','netto_bredde','netto bredde','netto_mm','netto','netto bredde (mm)'],
  brutto_width_mm : ['bruttobredde_mm','bruttobredde','brutto_bredde','brutto bredde','brutto_mm','brutto','brutto bredde (mm)'],
  cut_interval_mm : ['kutt_intervall_mm','kutt_intervall','kuttintervall','cut_interval_mm','kuttes hver'],
  max_length_m    : ['maks_lengde','maks lengde','max_length_m','maks lengde (m)'],
  watt_per_m2_2   : ['effekt','effekt w/m2'],  // extra alias
};

function normalizeKey(s) {
  return s.toString().trim().toLowerCase()
    .replace(/\s+/g,' ')
    .replace(/[_\-]/g,' ');
}

function mapHeaders(headers) {
  const result = {};
  for (const h of headers) {
    const norm = normalizeKey(h);
    for (const [field, aliases] of Object.entries(COL_MAP)) {
      const realField = field === 'watt_per_m2_2' ? 'watt_per_m2' : field;
      if (aliases.some(a => normalizeKey(a) === norm)) {
        result[h] = realField;
        break;
      }
    }
    if (!result[h]) {
      // Try partial match
      const norm2 = norm.replace(/[^a-zæøå0-9]/g,'');
      for (const [field, aliases] of Object.entries(COL_MAP)) {
        const realField = field === 'watt_per_m2_2' ? 'watt_per_m2' : field;
        if (aliases.some(a => normalizeKey(a).replace(/[^a-zæøå0-9]/g,'') === norm2)) {
          result[h] = realField;
          break;
        }
      }
    }
  }
  return result;
}

// Read Excel
const buf = readFileSync(FILE);
const wb = XLSX.read(buf, { type: 'buffer' });

console.log('Sheets:', wb.SheetNames);

for (const sheetName of wb.SheetNames) {
  const ws = wb.Sheets[sheetName];
  const rows = XLSX.utils.sheet_to_json(ws, { defval: '' });

  if (rows.length === 0) {
    console.log(`\nSheet "${sheetName}": empty`);
    continue;
  }

  console.log(`\n=== Sheet: "${sheetName}" (${rows.length} rows) ===`);
  const headers = Object.keys(rows[0]);
  console.log('Headers:', headers);

  const headerMap = mapHeaders(headers);
  console.log('Header mapping:', headerMap);

  // Show first 3 rows
  console.log('\nFirst 3 rows:');
  rows.slice(0, 3).forEach((row, i) => {
    console.log(`Row ${i+1}:`, JSON.stringify(row, null, 2));
  });
}
