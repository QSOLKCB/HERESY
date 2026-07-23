import { readdir, stat } from 'node:fs/promises';
import { join } from 'node:path';

const LIMIT = 368_640;

async function total(path) {
  let bytes = 0;
  for (const name of await readdir(path)) {
    const item = join(path, name);
    const info = await stat(item);
    bytes += info.isDirectory() ? await total(item) : info.size;
  }
  return bytes;
}

const bytes = await total('dist');
const cards = Math.ceil(bytes / 80);
const percentage = ((bytes / LIMIT) * 100).toFixed(2);

console.log(`dist: ${bytes} / ${LIMIT} bytes (${percentage}% of one 360 KB floppy)`);
console.log(`Equivalent paperwork: ${cards} tightly packed 80-column records.`);

if (bytes > LIMIT) {
  throw new Error(
    `High-density decadence detected: v3 exceeded its 360 KB budget by ${bytes - LIMIT} bytes.`
  );
}
