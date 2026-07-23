'use strict';

var fs = require('fs');
var path = require('path');
var root = path.resolve(__dirname, '..');
var limit = 131072;
var cardBytes = 80;
var productionFiles = [
  'index.html',
  'style.css',
  'src/cobol-deck.js',
  'src/engine.js',
  'src/cobol-database.js',
  'src/app.js'
];
var total = 0;

productionFiles.forEach(function (relative) {
  var bytes = fs.statSync(path.join(root, relative)).size;
  total += bytes;
  console.log(String(bytes).padStart(7) + '  ' + relative);
});

console.log(String(total).padStart(7) + '  TOTAL');
console.log(String(limit).padStart(7) + '  128 KiB production budget');
console.log(Math.ceil(total / cardBytes) +
  ' theoretical 80-column punch cards');

if (total > limit) {
  throw new Error(
    'Production exceeds 128 KiB by ' + (total - limit) +
    ' bytes. Please dismiss a framework.'
  );
}

console.log('SIZE GATE PASSED with ' + (limit - total) + ' bytes spare.');
