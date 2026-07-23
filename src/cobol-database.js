'use strict';

(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('./engine.js'));
  } else {
    root.HERESY_COBOL_DATABASE = factory(root.HERESY_ENGINE);
  }
}(this, function (engine) {
  var defaultKey = 'HERESY_V4_COBOL_RUN_RECORDS';
  var headerPrefix = 'HERESY COBOL DATABASE V2 WIDTH ';
  var legacyHeaderPrefix = 'HERESY COBOL DATABASE V1 WIDTH ';

  function create(options) {
    var parsed;
    var schema;
    var adapter;
    options = options || {};
    parsed = options.parsed || engine.parseCobol(options.source);
    schema = parsed.record;
    adapter = options.adapter || localStorageAdapter(
      options.key || defaultKey
    );

    return {
      width: parsed.recordWidth,
      schema: schema.slice(),
      save: save,
      list: list,
      remove: remove,
      clear: clear,
      exportText: exportText,
      importText: importText,
      scenarioInputs: scenarioInputs,
      restoreScenario: restoreScenario,
      pack: function (values) {
        return pack(schema, values);
      },
      unpack: function (record) {
        return unpack(schema, record);
      }
    };

    function save(result, when) {
      var rows = readRows(adapter);
      var created = normalDate(when || new Date());
      var values = resultValues(result, created.text);
      var suffix = 0;
      var id;
      var record;
      do {
        id = makeId(created, suffix);
        suffix += 1;
      } while (hasId(schema, rows, id) && suffix < 100);
      if (hasId(schema, rows, id)) {
        throw new Error('COBOL RUN-ID counter exhausted for this millisecond.');
      }
      values['RUN-ID'] = id;
      record = pack(schema, values);
      rows.push(record);
      writeRows(adapter, rows);
      return unpack(schema, record);
    }

    function list() {
      var rows = readRows(adapter);
      var output = [];
      var errors = [];
      rows.forEach(function (row, index) {
        try {
          output.push(unpack(schema, row));
        } catch (error) {
          errors.push('Record ' + (index + 1) + ': ' + error.message);
        }
      });
      output.errors = errors;
      return output.reverse();
    }

    function remove(id) {
      var rows = readRows(adapter);
      var kept = [];
      var removed = false;
      rows.forEach(function (row) {
        var value;
        try {
          value = unpack(schema, row);
          if (value['RUN-ID'] === id) {
            removed = true;
          } else {
            kept.push(row);
          }
        } catch (error) {
          kept.push(row);
        }
      });
      if (removed) {
        writeRows(adapter, kept);
      }
      return removed;
    }

    function clear() {
      adapter.set('');
    }

    function exportText() {
      var rows = readRows(adapter);
      var header = headerPrefix + parsed.recordWidth + ' CHECKSUM FNV1A';
      return header + '\n' + (rows.length ? rows.join('\n') + '\n' : '');
    }

    function importText(text) {
      var clean = String(text).replace(/\r\n/g, '\n');
      var lines = clean.split('\n');
      var suppliedHeader = lines.shift();
      var expected = headerPrefix + parsed.recordWidth + ' CHECKSUM FNV1A';
      var legacyExpected = legacyHeaderPrefix + parsed.recordWidth +
        ' CHECKSUM FNV1A';
      var rows = readRows(adapter);
      var ids = {};
      var added = 0;
      var skipped = 0;
      var values;
      if (suppliedHeader !== expected && suppliedHeader !== legacyExpected) {
        throw new Error('Not this COBOL database format or record width.');
      }
      rows.forEach(function (row) {
        try {
          ids[unpack(schema, row)['RUN-ID']] = true;
        } catch (ignore) {
          return;
        }
      });
      lines.forEach(function (line, index) {
        if (!line && index === lines.length - 1) {
          return;
        }
        if (!line) {
          throw new Error('Blank record at imported line ' + (index + 2) + '.');
        }
        values = unpack(schema, line);
        if (ids[values['RUN-ID']]) {
          skipped += 1;
        } else {
          ids[values['RUN-ID']] = true;
          rows.push(line);
          added += 1;
        }
      });
      writeRows(adapter, rows);
      return { added: added, skipped: skipped };
    }
  }

  function resultValues(result, created) {
    var metrics = result.metrics;
    return {
      'RUN-ID': '',
      'CREATED-UTC': created,
      SCENARIO: result.scenario.id,
      'SEED-VALUE': result.seed,
      'SIZE-KB': metrics.sizeKB,
      DEPENDENCIES: metrics.dependencies,
      'COLD-MS': metrics.coldMs,
      'CLOUD-CENTS': metrics.cloudCents,
      'RISK-POINTS': metrics.risk,
      MEETINGS: metrics.meetings,
      'VALUE-POINTS': metrics.value,
      'RESUME-POINTS': metrics.resume,
      'SHIP-DAYS': metrics.shipDays,
      'BLOAT-X100': metrics.bloatX100,
      'OUTCOME-CODE': result.outcome.code,
      DECISIONS: result.decisions.join(','),
      'RECORD-VERSION': '2',
      'ESSENTIAL-KB': fixedDigits(
        result.scenario.essentialKB,
        9,
        'ESSENTIAL-KB'
      ),
      'BASE-DAYS': fixedDigits(
        result.scenario.baseDays,
        6,
        'BASE-DAYS'
      ),
      RESERVED: '',
      'BRIEF-TEXT': result.scenario.brief,
      CHECKSUM: ''
    };
  }

  function scenarioInputs(record) {
    var essential;
    var baseDays;
    if (!record || !record['RECORD-VERSION']) {
      return {
        exact: false,
        recordVersion: 1,
        essentialKB: null,
        baseDays: null
      };
    }
    if (record['RECORD-VERSION'] !== '2') {
      throw new Error(
        'Unsupported COBOL RECORD-VERSION ' +
        record['RECORD-VERSION'] + '.'
      );
    }
    if (!/^\d{9}$/.test(record['ESSENTIAL-KB']) ||
        !/^\d{6}$/.test(record['BASE-DAYS'])) {
      throw new Error('Version 2 scenario inputs are not fixed digits.');
    }
    essential = parseInt(record['ESSENTIAL-KB'], 10);
    baseDays = parseInt(record['BASE-DAYS'], 10);
    if (essential < 1 || baseDays < 1) {
      throw new Error('Version 2 scenario inputs must be positive.');
    }
    return {
      exact: true,
      recordVersion: 2,
      essentialKB: essential,
      baseDays: baseDays
    };
  }

  function restoreScenario(record) {
    var savedInputs = scenarioInputs(record);
    var defined = engine.scenarios[record.SCENARIO] || null;
    return {
      id: record.SCENARIO,
      title: defined ? defined.title : record.SCENARIO,
      brief: record['BRIEF-TEXT'],
      essentialKB: savedInputs.exact ?
        savedInputs.essentialKB :
        (defined ? defined.essentialKB : null),
      baseDays: savedInputs.exact ?
        savedInputs.baseDays :
        (defined ? defined.baseDays : null),
      inputsExact: savedInputs.exact || Boolean(defined),
      recordVersion: savedInputs.recordVersion
    };
  }

  function pack(schema, values) {
    var checksumField = schema[schema.length - 1];
    var prefix = '';
    var index;
    if (!checksumField || checksumField.name !== 'CHECKSUM' ||
        checksumField.width !== 8) {
      throw new Error('COBOL schema lacks an eight-character CHECKSUM.');
    }
    for (index = 0; index < schema.length - 1; index += 1) {
      prefix += encodeField(schema[index], values[schema[index].name]);
    }
    return prefix + fnv1a(prefix);
  }

  function unpack(schema, record) {
    var width = schema.reduce(function (sum, item) {
      return sum + item.width;
    }, 0);
    var expected;
    var offset = 0;
    var values = {};
    var checksumField = schema[schema.length - 1];
    if (typeof record !== 'string' || record.length !== width) {
      throw new Error(
        'record width is ' + (record ? record.length : 0) +
        '; expected ' + width
      );
    }
    expected = fnv1a(record.slice(0, -checksumField.width));
    if (record.slice(-checksumField.width) !== expected) {
      throw new Error('FNV1A checksum mismatch; card deck may be haunted.');
    }
    schema.forEach(function (field) {
      var raw = record.slice(offset, offset + field.width);
      offset += field.width;
      if (field.type === '9') {
        if (!/^\d+$/.test(raw)) {
          throw new Error(field.name + ' contains non-numeric punchings.');
        }
        values[field.name] = parseInt(raw, 10);
      } else {
        values[field.name] = raw.replace(/\s+$/, '');
      }
    });
    if (Object.prototype.hasOwnProperty.call(
      values,
      'RECORD-VERSION'
    )) {
      scenarioInputs(values);
    }
    return values;
  }

  function fixedDigits(value, width, name) {
    var number = Number(value);
    var text;
    if (!isFinite(number) || number < 1 || Math.floor(number) !== number) {
      throw new Error(name + ' must be a positive integer.');
    }
    text = String(number);
    if (text.length > width) {
      throw new Error(name + ' exceeds its fixed record width.');
    }
    return repeat('0', width - text.length) + text;
  }

  function encodeField(field, value) {
    var text;
    if (field.type === '9') {
      if (typeof value !== 'number' || !isFinite(value) ||
          value < 0 || Math.floor(value) !== value) {
        throw new Error(field.name + ' must be a non-negative integer.');
      }
      text = String(value);
      if (text.length > field.width) {
        throw new Error(field.name + ' overflows PIC 9(' + field.width + ').');
      }
      return repeat('0', field.width - text.length) + text;
    }
    text = ascii(value);
    if (text.length > field.width) {
      throw new Error(field.name + ' overflows PIC X(' + field.width + ').');
    }
    return text + repeat(' ', field.width - text.length);
  }

  function ascii(value) {
    return String(value === undefined || value === null ? '' : value)
      .replace(/[\r\n\t]/g, ' ')
      .replace(/[^\x20-\x7e]/g, '?');
  }

  function fnv1a(text) {
    var hash = 2166136261;
    var index;
    for (index = 0; index < text.length; index += 1) {
      hash ^= text.charCodeAt(index);
      hash += (hash << 1) + (hash << 4) + (hash << 7) +
        (hash << 8) + (hash << 24);
    }
    return ('00000000' + (hash >>> 0).toString(16).toUpperCase()).slice(-8);
  }

  function hasId(schema, rows, id) {
    var found = false;
    rows.forEach(function (row) {
      try {
        if (unpack(schema, row)['RUN-ID'] === id) {
          found = true;
        }
      } catch (ignore) {
        return;
      }
    });
    return found;
  }

  function makeId(created, suffix) {
    var milliseconds = String(created.date.getTime());
    return 'R' + repeat('0', 13 - milliseconds.length) +
      milliseconds + ('0' + suffix).slice(-2);
  }

  function normalDate(value) {
    var date = value instanceof Date ? value : new Date(value);
    var iso;
    if (!isFinite(date.getTime())) {
      throw new Error('Invalid database timestamp.');
    }
    iso = date.toISOString();
    return {
      date: date,
      text: iso.slice(0, 19) + 'Z'
    };
  }

  function readRows(adapter) {
    var raw = adapter.get();
    if (!raw) {
      return [];
    }
    return String(raw).split('\n');
  }

  function writeRows(adapter, rows) {
    adapter.set(rows.join('\n'));
  }

  function localStorageAdapter(key) {
    return {
      get: function () {
        try {
          return window.localStorage.getItem(key) || '';
        } catch (error) {
          throw new Error('Virtual disk unavailable: ' + error.message);
        }
      },
      set: function (value) {
        try {
          if (value) {
            window.localStorage.setItem(key, value);
          } else {
            window.localStorage.removeItem(key);
          }
        } catch (error) {
          throw new Error('Virtual disk write failed: ' + error.message);
        }
      }
    };
  }

  function memoryAdapter(initial) {
    var contents = initial || '';
    return {
      get: function () {
        return contents;
      },
      set: function (value) {
        contents = String(value);
      }
    };
  }

  function repeat(character, count) {
    return new Array(count + 1).join(character);
  }

  return {
    create: create,
    memoryAdapter: memoryAdapter,
    fnv1a: fnv1a,
    headerPrefix: headerPrefix,
    legacyHeaderPrefix: legacyHeaderPrefix
  };
}));
