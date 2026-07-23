'use strict';

var assert = require('assert');
var fs = require('fs');
var path = require('path');
var root = path.resolve(__dirname, '..');
var source = require(path.join(root, 'src', 'cobol-deck.js'));
var engine = require(path.join(root, 'src', 'engine.js'));
var databaseModule = require(path.join(root, 'src', 'cobol-database.js'));
var parsed = engine.parseCobol(source);
var leanDecisions = [
  'HTML',
  'NOSERVER',
  'COBOLFILE',
  'COPYFILES',
  'LOGROTATE',
  'CODEVIEW',
  'NOAI'
];
var maximalDecisions = [
  'ELECTRON',
  'MICROSERVICES',
  'EVENTSOURCE',
  'KUBERNETES',
  'OBSSTACK',
  'SAFE',
  'SWARM'
];
var lean;
var maximal;
var custom;
var adapter;
var database;
var first;
var second;
var customRecord;
var customInputs;
var exported;
var imported;
var importResult;
var corrupt;
var legacyFields;
var legacyAdapter;
var legacyDatabase;
var legacySaved;
var compatibleDatabase;
var compatibleRows;
var malformedAdapter;
var malformedDatabase;
var malformedRows;
var validRows;
var productionFiles;

assert.strictEqual(
  parsed.record.length,
  22,
  'COBOL RUN-RECORD field count changed'
);
assert.strictEqual(parsed.recordWidth, 379, 'fixed record width changed');
assert.strictEqual(
  parsed.record[parsed.record.length - 1].name,
  'CHECKSUM',
  'checksum is no longer the final COBOL field'
);
assert.strictEqual(
  Object.keys(parsed.rules).length,
  28,
  'the simulator must have 28 COBOL rules'
);
assert.deepStrictEqual(
  engine.allRuleIds().sort(),
  Object.keys(parsed.rules).sort(),
  'interface choices and COBOL rules disagree'
);

lean = engine.simulate(
  engine.getScenario('COFFEE'),
  leanDecisions,
  parsed,
  1985
);
maximal = engine.simulate(
  engine.getScenario('COFFEE'),
  maximalDecisions,
  parsed,
  1985
);
custom = engine.simulate(
  engine.getScenario('CUSTOM', {
    title: 'Exact custom inputs',
    brief: 'Preserve the scenario without reverse-engineering rounded bloat.',
    essentialKB: 999,
    baseDays: 37
  }),
  leanDecisions,
  parsed,
  1985
);
assert.strictEqual(custom.metrics.sizeKB, 1024);
assert.strictEqual(custom.metrics.bloatX100, 103);

assert.deepStrictEqual(
  lean,
  engine.simulate(
    engine.getScenario('COFFEE'),
    leanDecisions,
    parsed,
    1985
  ),
  'same input and seed must reproduce the same simulation'
);
assert.strictEqual(lean.outcome.code, 'USEFUL');
assert(maximal.metrics.sizeKB > lean.metrics.sizeKB * 1000);
assert(maximal.metrics.dependencies > lean.metrics.dependencies);
assert(maximal.metrics.cloudCents > lean.metrics.cloudCents);
assert(maximal.metrics.risk > lean.metrics.risk);
assert(maximal.metrics.meetings > lean.metrics.meetings);
assert(maximal.metrics.resume > lean.metrics.resume);
assert(maximal.metrics.bloatX100 > lean.metrics.bloatX100);
assert.strictEqual(lean.decisions[2], 'COBOLFILE');
assert(
  engine.reportMarkdown(lean).indexOf('COBOLFILE') >= 0,
  'exported receipt must identify the COBOL decision'
);
assert(
  engine.reportMarkdown(lean).indexOf('Useful software incident') >= 0
);

adapter = databaseModule.memoryAdapter();
database = databaseModule.create({ parsed: parsed, adapter: adapter });
first = database.save(lean, new Date('2026-07-24T00:00:00.000Z'));
second = database.save(maximal, new Date('2026-07-24T00:00:00.000Z'));
customRecord = database.save(
  custom,
  new Date('2026-07-24T00:00:00.000Z')
);
customInputs = database.scenarioInputs(customRecord);

assert.strictEqual(first['RUN-ID'].length, 16);
assert.notStrictEqual(first['RUN-ID'], second['RUN-ID']);
assert.strictEqual(first['CREATED-UTC'], '2026-07-24T00:00:00Z');
assert.strictEqual(first.DECISIONS, leanDecisions.join(','));
assert.strictEqual(first['RECORD-VERSION'], '2');
assert.strictEqual(customRecord['ESSENTIAL-KB'], '000000999');
assert.strictEqual(customRecord['BASE-DAYS'], '000037');
assert.deepStrictEqual(customInputs, {
  exact: true,
  recordVersion: 2,
  essentialKB: 999,
  baseDays: 37
});
assert.deepStrictEqual(
  database.restoreScenario(customRecord),
  {
    id: 'CUSTOM',
    title: 'CUSTOM',
    brief: 'Preserve the scenario without reverse-engineering rounded bloat.',
    essentialKB: 999,
    baseDays: 37,
    inputsExact: true,
    recordVersion: 2
  },
  'recall must restore exact custom inputs for JSON export'
);
assert.strictEqual(first.CHECKSUM.length, 8);
assert.strictEqual(database.list().length, 3);
assert.strictEqual(
  adapter.get().split('\n')[0].length,
  parsed.recordWidth,
  'virtual disk must contain fixed records, not JSON'
);
assert.strictEqual(
  adapter.get().indexOf('{'),
  -1,
  'the COBOL database quietly became JSON'
);

exported = database.exportText();
assert(
  exported.indexOf(
    'HERESY COBOL DATABASE V2 WIDTH 379 CHECKSUM FNV1A\n'
  ) === 0
);
assert.strictEqual(exported.split('\n')[1].length, 379);

imported = databaseModule.create({
  parsed: parsed,
  adapter: databaseModule.memoryAdapter()
});
importResult = imported.importText(exported);
assert.deepStrictEqual(importResult, { added: 3, skipped: 0 });
assert.deepStrictEqual(
  imported.importText(exported),
  { added: 0, skipped: 3 },
  'duplicate COBOL records must be refused'
);
assert.strictEqual(imported.list().length, 3);
assert.strictEqual(imported.remove(first['RUN-ID']), true);
assert.strictEqual(imported.remove(first['RUN-ID']), false);
assert.strictEqual(imported.list().length, 2);
imported.clear();
assert.strictEqual(imported.list().length, 0);

legacyFields = [];
parsed.record.forEach(function (field) {
  if (field.name === 'DECISIONS') {
    legacyFields.push({ name: 'DECISIONS', type: 'X', width: 128 });
  } else if ([
    'RECORD-VERSION',
    'ESSENTIAL-KB',
    'BASE-DAYS',
    'RESERVED'
  ].indexOf(field.name) < 0) {
    legacyFields.push(field);
  }
});
legacyAdapter = databaseModule.memoryAdapter();
legacyDatabase = databaseModule.create({
  parsed: {
    record: legacyFields,
    recordWidth: 379,
    rules: parsed.rules
  },
  adapter: legacyAdapter
});
legacySaved = legacyDatabase.save(
  custom,
  new Date('2026-07-24T01:00:00.000Z')
);
assert.strictEqual(legacySaved.DECISIONS, leanDecisions.join(','));
compatibleDatabase = databaseModule.create({
  parsed: parsed,
  adapter: legacyAdapter
});
compatibleRows = compatibleDatabase.list();
assert.strictEqual(compatibleRows.length, 1);
assert.strictEqual(compatibleRows.errors.length, 0);
assert.strictEqual(
  compatibleRows[0].DECISIONS,
  leanDecisions.join(',')
);
assert.deepStrictEqual(
  compatibleDatabase.scenarioInputs(compatibleRows[0]),
  {
    exact: false,
    recordVersion: 1,
    essentialKB: null,
    baseDays: null
  },
  'legacy custom inputs must be unknown, never reverse-engineered'
);
assert.deepStrictEqual(
  compatibleDatabase.restoreScenario(compatibleRows[0]),
  {
    id: 'CUSTOM',
    title: 'CUSTOM',
    brief: 'Preserve the scenario without reverse-engineering rounded bloat.',
    essentialKB: null,
    baseDays: null,
    inputsExact: false,
    recordVersion: 1
  },
  'legacy custom recall must expose unavailable inputs honestly'
);
assert.deepStrictEqual(
  databaseModule.create({
    parsed: parsed,
    adapter: databaseModule.memoryAdapter()
  }).importText(
    'HERESY COBOL DATABASE V1 WIDTH 379 CHECKSUM FNV1A\n' +
    legacyAdapter.get() + '\n'
  ),
  { added: 1, skipped: 0 },
  'version 1 exports must remain importable'
);

validRows = adapter.get().split('\n');
malformedAdapter = databaseModule.memoryAdapter(
  validRows[0] + '\n\n' + validRows[1]
);
malformedDatabase = databaseModule.create({
  parsed: parsed,
  adapter: malformedAdapter
});
malformedRows = malformedDatabase.list();
assert.strictEqual(malformedRows.length, 2);
assert.strictEqual(malformedRows.errors.length, 1);
assert.match(malformedRows.errors[0], /record width is 0/);
malformedDatabase.save(
  lean,
  new Date('2026-07-24T02:00:00.000Z')
);
assert(
  malformedAdapter.get().indexOf('\n\n') >= 0,
  'saving must not silently erase a blank malformed record'
);
malformedRows = malformedDatabase.list();
assert.strictEqual(malformedRows.length, 3);
assert.strictEqual(malformedRows.errors.length, 1);
assert(
  malformedDatabase.exportText().indexOf('\n\n') >= 0,
  'export must preserve a quarantined blank record for inspection'
);

corrupt = exported.split('\n');
corrupt[1] = corrupt[1].slice(0, 20) +
  (corrupt[1].charAt(20) === 'X' ? 'Y' : 'X') +
  corrupt[1].slice(21);
assert.throws(function () {
  databaseModule.create({
    parsed: parsed,
    adapter: databaseModule.memoryAdapter()
  }).importText(corrupt.join('\n'));
}, /checksum mismatch/);

assert.throws(function () {
  database.pack({
    'RUN-ID': 'THIS-RUN-ID-IS-DELIBERATELY-TOO-LONG'
  });
}, /overflows PIC X/);

source.split('\n').forEach(function (line, index) {
  assert(
    line.length <= 72,
    'COBOL card ' + (index + 1) + ' exceeds column 72'
  );
});
assert.strictEqual(
  fs.readFileSync(
    path.join(root, 'programs', 'modern-developer.cob'),
    'utf8'
  ).replace(/\r\n/g, '\n'),
  source,
  'punched browser deck differs from COBOL source'
);

productionFiles = [
  'index.html',
  'style.css',
  'src/cobol-deck.js',
  'src/engine.js',
  'src/cobol-database.js',
  'src/app.js'
];
productionFiles.forEach(function (relative) {
  var contents = fs.readFileSync(path.join(root, relative), 'utf8');
  assert(
    !/https?:\/\//i.test(contents),
    relative + ' contains a network URL'
  );
  assert(
    !/\b(eval|Function)\s*\(/.test(contents),
    relative + ' contains dynamic code execution'
  );
});
assert(
  fs.readFileSync(path.join(root, 'index.html'), 'utf8')
    .indexOf('type="module"') < 0,
  'classic scripts were replaced by a module loader'
);
assert(
  !fs.existsSync(path.join(root, 'package.json')),
  'a package manager has entered production'
);

console.log('SELFTEST PASSED');
console.log('28 COBOL rules materially govern seven architecture decisions.');
console.log('379-column fixed records save, verify, export and import.');
console.log('Lean path: ' + engine.formatKB(lean.metrics.sizeKB) +
  ', ' + engine.formatRatio(lean.metrics.bloatX100) + ' bloat.');
console.log('Modern path: ' + engine.formatKB(maximal.metrics.sizeKB) +
  ', ' + engine.formatRatio(maximal.metrics.bloatX100) + ' bloat.');
