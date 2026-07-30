'use strict';

var fs = require('fs');
var path = require('path');

var root = path.resolve(__dirname, '..');
var sourcePath = path.join(root, 'programs', 'modern-developer.cob');
var deckPath = path.join(root, 'src', 'cobol-deck.js');
var source = fs.readFileSync(sourcePath, 'utf8').replace(/\r\n/g, '\n');
var lines = source.replace(/\n$/, '').split('\n');
var body = lines.map(function (line) {
  return '    ' + JSON.stringify(line);
}).join(',\n');
var generated = [
  "'use strict';",
  '',
  '// Generated from programs/modern-developer.cob.',
  '// The browser executes this committed COBOL deck without fetch or build.',
  '(function (root, factory) {',
  '  var source = factory();',
  "  if (typeof module === 'object' && module.exports) {",
  '    module.exports = source;',
  '  } else {',
  '    root.HERESY_COBOL_SOURCE = source;',
  '  }',
  "}(this, function () {",
  '  return [',
  body,
  "  ].join('\\n') + '\\n';",
  '}));',
  ''
].join('\n');

if (process.argv.indexOf('--check') !== -1) {
  var current = fs.existsSync(deckPath) ? fs.readFileSync(deckPath, 'utf8') : '';
  if (current !== generated) {
    throw new Error(
      'COBOL deck is stale. Run: node scripts/punch-cobol.js'
    );
  }
  console.log('COBOL deck matches the fixed-column source exactly.');
} else {
  fs.writeFileSync(deckPath, generated);
  console.log('Punched ' + lines.length + ' COBOL cards into src/cobol-deck.js.');
}
