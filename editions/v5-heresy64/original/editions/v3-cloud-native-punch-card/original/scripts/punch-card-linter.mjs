import { readFile } from 'node:fs/promises';

const rules = [
  ['programs/mainframe.cob', 72],
  ['programs/router.f', 72],
  ['programs/HERESY3.jcl', 80],
  ['programs/failsafe.adb', 80]
];

const failures = [];
for (const [path, limit] of rules) {
  const source = await readFile(path, 'utf8');
  for (const [index, line] of source.split(/\r?\n/).entries()) {
    if (line.includes('\t')) {
      failures.push(`${path}:${index + 1}: tab character requires unbudgeted lateral thinking`);
    }
    if (line.length > limit) {
      failures.push(
        `${path}:${index + 1}: ${line.length} columns; ${line.length - limit} characters are hanging into the future`
      );
    }
  }
}

if (failures.length) {
  throw new Error(
    `CARD DECK REJECTED\n${failures.join('\n')}\nPrettier has been reassigned to Payroll.`
  );
}

console.log(
  'Punch-card linter passed: no thought escaped its physically allocated column.'
);
