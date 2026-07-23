import assert from 'node:assert/strict';
import { runBasic } from '../src/basic.js';

const first = runBasic();
const second = runBasic();
assert.deepEqual(first, second);
assert.equal(first.component.title, 'REACT INSIDE BASIC');
assert.match(first.transcript.join('\n'), /READY\./);
console.log('HERESY selftest passed: identical sin produced twice.');
