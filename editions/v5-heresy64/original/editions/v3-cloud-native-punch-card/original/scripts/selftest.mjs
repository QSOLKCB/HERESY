import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import {
  CARD_COLUMNS,
  DATA_COLUMNS,
  MainframeAbend,
  containFault,
  decodeEbcdic,
  encodeEbcdic,
  executeMainframe,
  hollerithRows,
  parseAdaPolicy,
  parseCobolSchema,
  parseFortranRouter,
  parseJcl,
  verifyOverride
} from '../src/mainframe.js';

const load = (name) => readFile(new URL(`../programs/${name}`, import.meta.url), 'utf8');
const [jcl, cobol, fortran, ada] = await Promise.all([
  load('HERESY3.jcl'),
  load('mainframe.cob'),
  load('router.f'),
  load('failsafe.adb')
]);
const sources = { jcl, cobol, fortran, ada };

const request = {
  id: 1,
  method: 'POST',
  route: '/api/status',
  anxiety: 'AGILE',
  ticket: 'CHG000000001',
  payload: 'NOOP'
};

const first = executeMainframe({ request, sources });
const second = executeMainframe({ request, sources });
assert.deepEqual(first, second, 'same card and sources must produce identical output');

assert.equal(parseJcl(jcl).program, 'HERESY3');
assert.equal(parseCobolSchema(cobol).width, DATA_COLUMNS);
assert.deepEqual(
  parseFortranRouter(fortran).routes.map(({ route }) => route),
  ['STATUS', 'DEPLOY', 'AI', 'HEALTH']
);
assert.deepEqual(parseAdaPolicy(ada), {
  overrideLength: 80,
  missileAssumption: true
});

assert.equal(first.card.length, CARD_COLUMNS);
assert.equal(first.ebcdic.length, CARD_COLUMNS);
assert.equal(decodeEbcdic(encodeEbcdic(first.card)), first.card);
assert.deepEqual(first.deck.map((card) => card.slice(72)), [
  '00000010',
  '00000020',
  '00000030'
]);
assert.equal(first.record['REQ-ID'], '00001');
assert.equal(first.record['ROUTE-CODE'], 'STATUS');
assert.equal(first.response.protocol, 'REST/1959');
assert.equal(first.response.containers, 0);
assert.equal(first.response.orchestrator, 'CARD SORTER');
assert.match(first.response.body, /LEGACY OUTLIVED/);

for (const [route, expected] of [
  ['/api/deploy', /DORIS/],
  ['/api/ai', /LAMINATED FLOWCHART/],
  ['/api/health', /SCHEDULED REALITY/]
]) {
  const result = executeMainframe({
    request: { ...request, route },
    sources
  });
  assert.match(result.response.body, expected);
}

const matrix = hollerithRows(first.card);
assert.deepEqual(matrix.labels, ['12', '11', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9']);
assert.equal(matrix.rows.length, 12);
assert.ok(matrix.rows.every((row) => row.length === CARD_COLUMNS));

assert.throws(
  () => executeMainframe({
    request: { ...request, ticket: 'NO TICKET' },
    sources
  }),
  (error) => error instanceof MainframeAbend && error.code === 'U0014'
);
assert.throws(
  () => executeMainframe({
    request: { ...request, method: 'GET' },
    sources
  }),
  (error) => error instanceof MainframeAbend && error.code === 'U0405'
);
assert.throws(
  () => parseJcl(jcl.replace('//HERESY3 JOB', '/HERESY3 JOB')),
  (error) => error instanceof MainframeAbend && error.code === 'JCL0001'
);
assert.throws(
  () => executeMainframe({
    request: { ...request, payload: 'X'.repeat(30) },
    sources
  }),
  (error) => error instanceof MainframeAbend && error.code === 'S0C1'
);

const lock = containFault(new MainframeAbend('U0014', 'FORM LOST'), ada, request.id);
assert.equal(lock.challenge.length, 80);
assert.equal(verifyOverride(lock.challenge, lock), true);
assert.equal(verifyOverride(`${lock.challenge.slice(0, -1)}X`, lock), false);

console.log(
  'HERESY v3 selftest passed: one REST request survived 1959–1983 without npm assistance.'
);
