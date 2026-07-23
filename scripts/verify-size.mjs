import { readdir, stat } from 'node:fs/promises';
import { join } from 'node:path';

const LIMIT = 1_474_560;
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
console.log(`dist: ${bytes} / ${LIMIT} bytes`);
if (bytes > LIMIT) throw new Error(`Floppy blasphemy exceeded by ${bytes - LIMIT} bytes`);
