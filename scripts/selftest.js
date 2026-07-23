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
var adapter;
var database;
var first;
var second;
var exported;
var imported;
var importResult;
var corrupt;
var productionFiles;

assert.strictEqual(
  parsed.record.length,
  18,
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

assert.strictEqual(first['RUN-ID'].length, 16);
assert.notStrictEqual(first['RUN-ID'], second['RUN-ID']);
assert.strictEqual(first['CREATED-UTC'], '2026-07-24T00:00:00Z');
assert.strictEqual(first.DECISIONS, leanDecisions.join(','));
assert.strictEqual(first.CHECKSUM.length, 8);
assert.strictEqual(database.list().length, 2);
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
    'HERESY COBOL DATABASE V1 WIDTH 379 CHECKSUM FNV1A\n'
  ) === 0
);
assert.strictEqual(exported.split('\n')[1].length, 379);

imported = databaseModule.create({
  parsed: parsed,
  adapter: databaseModule.memoryAdapter()
});
importResult = imported.importText(exported);
assert.deepStrictEqual(importResult, { added: 2, skipped: 0 });
assert.deepStrictEqual(
  imported.importText(exported),
  { added: 0, skipped: 2 },
  'duplicate COBOL records must be refused'
);
assert.strictEqual(imported.list().length, 2);
assert.strictEqual(imported.remove(first['RUN-ID']), true);
assert.strictEqual(imported.remove(first['RUN-ID']), false);
assert.strictEqual(imported.list().length, 1);
imported.clear();
assert.strictEqual(imported.list().length, 0);

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
