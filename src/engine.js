'use strict';

(function (root, factory) {
  var api = factory();
  if (typeof module === 'object' && module.exports) {
    module.exports = api;
  } else {
    root.HERESY_ENGINE = api;
  }
}(this, function () {
  var metricFields = [
    'SIZE-KB',
    'DEPENDENCIES',
    'COLD-MS',
    'CLOUD-CENTS',
    'RISK-POINTS',
    'MEETINGS',
    'VALUE-POINTS',
    'RESUME-POINTS',
    'SHIP-DAYS'
  ];

  var scenarios = {
    COFFEE: {
      id: 'COFFEE',
      title: 'Office coffee status',
      brief: 'Show whether the office coffee machine is working.',
      essentialKB: 4,
      baseDays: 1
    },
    TODO: {
      id: 'TODO',
      title: 'Personal task list',
      brief: 'Keep a small task list for one person on one computer.',
      essentialKB: 12,
      baseDays: 2
    },
    WEATHER: {
      id: 'WEATHER',
      title: 'Weather notice board',
      brief: 'Display one already-supplied weather reading to staff.',
      essentialKB: 6,
      baseDays: 1
    },
    CALCULATOR: {
      id: 'CALCULATOR',
      title: 'Invoice calculator',
      brief: 'Multiply quantity by price and print the total.',
      essentialKB: 8,
      baseDays: 2
    },
    BROCHURE: {
      id: 'BROCHURE',
      title: 'Opening-hours page',
      brief: 'Publish a phone number and opening hours for a shop.',
      essentialKB: 3,
      baseDays: 1
    },
    APPROVAL: {
      id: 'APPROVAL',
      title: 'Leave approval',
      brief: 'Let ten employees submit leave requests to one manager.',
      essentialKB: 32,
      baseDays: 5
    }
  };

  var phases = [
    {
      id: 'interface',
      title: '1. Interface procurement',
      prompt: 'How shall the user receive these few characters?',
      options: [
        option('HTML', 'HTML + forms', 'The browser already has widgets.',
          'A document was delivered. Nobody announced a migration.'),
        option('REACT', 'React application', 'State now has a career path.',
          'A component rendered the phone number after hydration.'),
        option('NEXTJS', 'Next.js platform', 'The static text needs an edge.',
          'The opening hours acquired a server/client trust boundary.'),
        option('ELECTRON', 'Electron desktop', 'Bundle a browser per user.',
          'The four-kilobyte requirement now travels with Chromium.')
      ]
    },
    {
      id: 'services',
      title: '2. Service-boundary ceremony',
      prompt: 'How many network boundaries prove that this is serious?',
      options: [
        option('NOSERVER', 'No server', 'The requirement is local.',
          'The architecture review ended before catering arrived.'),
        option('CGI', 'One CGI program', 'A process receives a request.',
          'The web server called a program and nobody formed a guild.'),
        option('MONOLITH', 'Modular monolith', 'One deployable, several files.',
          'The modules remained in the same building.'),
        option('MICROSERVICES', 'Microservice estate',
          'Seven services and a discovery workshop.',
          'Coffee status became eventually consistent.')
      ]
    },
    {
      id: 'data',
      title: '3. Persistence acquisition',
      prompt: 'Where should several tiny records become enterprise data?',
      options: [
        option('COBOLFILE', 'COBOL fixed records',
          'One copybook, one file, no ORM.',
          'The database is beige, finite and capable of being emailed.'),
        option('SQLITE', 'SQLite', 'A sensible embedded database.',
          'One file gained transactions without gaining a sales team.'),
        option('POSTGRES', 'Managed PostgreSQL',
          'Excellent database; perhaps more database than asked for.',
          'A phone number obtained backups in three availability zones.'),
        option('EVENTSOURCE', 'Event-sourced platform',
          'Never update; only reconsider forever.',
          'The coffee machine now has immutable biographical detail.')
      ]
    },
    {
      id: 'deployment',
      title: '4. Deployment department',
      prompt: 'How shall the finished bytes travel eight metres?',
      options: [
        option('COPYFILES', 'Copy the files', 'An underrated distribution.',
          'The release completed before the pipeline YAML compiled.'),
        option('FTPSERVER', 'FTP to one server', 'Transfer, then go home.',
          'A progress bar supplied all required observability.'),
        option('SERVERLESS', 'Serverless edge mesh',
          'Pay nothing until somebody reads the opening hours.',
          'Static text experienced a cold start at the edge.'),
        option('KUBERNETES', 'Kubernetes',
          'The answer to a question nobody was brave enough to repeat.',
          'The phone number is healthy on eleven pods.')
      ]
    },
    {
      id: 'observability',
      title: '5. Observability colonisation',
      prompt: 'How shall we know the phone number continues to exist?',
      options: [
        option('TEXTLOG', 'Text log', 'Append what happened.',
          'An operator read a sentence and understood it.'),
        option('LOGROTATE', 'Rotated text logs', 'Text, but tidied.',
          'Yesterday was compressed. Today remained legible.'),
        option('TELEMETRY', 'Telemetry pipeline',
          'Spans for every multiplication.',
          'The invoice total emitted fourteen correlated signals.'),
        option('OBSSTACK', 'Full observability stack',
          'Dashboards watching dashboards.',
          'The monitoring system now costs more than the shop.')
      ]
    },
    {
      id: 'process',
      title: '6. Process improvement',
      prompt: 'How much governance should precede displaying the answer?',
      options: [
        option('SHIPIT', 'Ship it', 'Fast, with consequences.',
          'A user saw working software while risk filled out a form.'),
        option('CODEVIEW', 'Review and test', 'One colleague checks it.',
          'A defect was found without a quarterly planning increment.'),
        option('AGILE', 'Industrial Agile', 'Twelve meetings remove silos.',
          'The sprint produced a refined ticket about producing a ticket.'),
        option('SAFE', 'Scaled framework', 'Coordinate everyone with everyone.',
          'The release train departed carrying no release.')
      ]
    },
    {
      id: 'ai',
      title: '7. Artificial headcount',
      prompt: 'Who should write the four lines?',
      options: [
        option('NOAI', 'A person', 'Read, think, type, test.',
          'The developer briefly encountered the requirement.'),
        option('COPILOT', 'Code completion', 'A useful power tool.',
          'Three lines were suggested and one was inspected.'),
        option('AGENT', 'Autonomous agent', 'Delegate implementation.',
          'The agent added a config system to avoid choosing a value.'),
        option('SWARM', 'Multi-agent swarm', 'Parallelise the four lines.',
          'Six agents agreed to create a seventh coordination agent.')
      ]
    }
  ];

  function option(id, label, description, event) {
    return {
      id: id,
      label: label,
      description: description,
      event: event
    };
  }

  function parseCobol(source) {
    var lines;
    var record = [];
    var rules = {};
    var currentRule = null;
    var inRecord = false;
    var index;
    var line;
    var match;
    var field;

    if (typeof source !== 'string' || source.indexOf('RUN-RECORD') < 0) {
      throw new Error('COBOL source does not contain RUN-RECORD.');
    }

    lines = source.replace(/\r\n/g, '\n').split('\n');
    for (index = 0; index < lines.length; index += 1) {
      line = lines[index];
      if (/^\s*01\s+RUN-RECORD\./.test(line)) {
        inRecord = true;
        currentRule = null;
        continue;
      }
      match = line.match(/^\s*01\s+RULE-([A-Z0-9-]+)\./);
      if (match) {
        inRecord = false;
        currentRule = { name: match[1], values: {} };
        rules[match[1]] = currentRule.values;
        continue;
      }
      if (/^\s*PROCEDURE DIVISION\./.test(line)) {
        currentRule = null;
      }

      if (inRecord) {
        match = line.match(
          /^\s*05\s+([A-Z0-9-]+)\s+PIC\s+([X9])\((\d+)\)\./
        );
        if (match) {
          field = {
            name: match[1],
            type: match[2],
            width: parseInt(match[3], 10)
          };
          record.push(field);
        }
      } else if (currentRule) {
        match = line.match(
          /^\s*05\s+([A-Z0-9-]+)\s+PIC\s+\S+\s+VALUE\s+(.+)\./
        );
        if (match) {
          if (/^'.*'$/.test(match[2])) {
            currentRule.values[match[1]] = match[2].slice(1, -1);
          } else {
            currentRule.values[match[1]] = parseInt(match[2], 10);
          }
        }
      }
    }

    validateCobol(record, rules);
    return {
      record: record,
      recordWidth: record.reduce(function (total, item) {
        return total + item.width;
      }, 0),
      rules: rules
    };
  }

  function validateCobol(record, rules) {
    var names = Object.keys(rules);
    if (record.length !== 18) {
      throw new Error('RUN-RECORD must contain exactly 18 fields.');
    }
    if (record[record.length - 1].name !== 'CHECKSUM') {
      throw new Error('RUN-RECORD must end with CHECKSUM.');
    }
    if (names.length !== 28) {
      throw new Error('COBOL deck must contain exactly 28 rules.');
    }
    names.forEach(function (name) {
      if (rules[name]['RULE-ID'] !== name) {
        throw new Error('COBOL rule identity mismatch: ' + name);
      }
      metricFields.forEach(function (metric) {
        if (typeof rules[name][metric] !== 'number') {
          throw new Error('COBOL rule ' + name + ' lacks ' + metric + '.');
        }
      });
    });
  }

  function getScenario(id, custom) {
    var cleanBrief;
    var cleanTitle;
    var essential;
    if (id !== 'CUSTOM') {
      if (!scenarios[id]) {
        throw new Error('Unknown scenario: ' + id);
      }
      return copy(scenarios[id]);
    }
    custom = custom || {};
    cleanBrief = cleanText(custom.brief || '', 96);
    cleanTitle = cleanText(custom.title || 'Custom production brief', 48);
    essential = clamp(parseInt(custom.essentialKB, 10) || 8, 1, 999999);
    if (!cleanBrief) {
      throw new Error('A custom brief is required.');
    }
    return {
      id: 'CUSTOM',
      title: cleanTitle,
      brief: cleanBrief,
      essentialKB: essential,
      baseDays: clamp(parseInt(custom.baseDays, 10) || 2, 1, 999)
    };
  }

  function simulate(scenarioInput, decisions, cobol, seed) {
    var scenario = typeof scenarioInput === 'string' ?
      getScenario(scenarioInput) : copy(scenarioInput);
    var numericSeed = normaliseSeed(seed);
    var totals = {
      sizeKB: scenario.essentialKB,
      dependencies: 0,
      coldMs: 0,
      cloudCents: 0,
      risk: 0,
      meetings: 0,
      value: 0,
      resume: 0,
      shipDays: scenario.baseDays
    };
    var details = [];
    var events = [];

    if (!cobol || !cobol.rules) {
      throw new Error('A parsed COBOL rule deck is required.');
    }
    if (!decisions || decisions.length !== phases.length) {
      throw new Error('Exactly seven architecture decisions are required.');
    }

    phases.forEach(function (phase, phaseIndex) {
      var choiceId = decisions[phaseIndex];
      var selected = findOption(phase, choiceId);
      var rule = cobol.rules[choiceId];
      var eventSuffix;
      if (!selected || !rule) {
        throw new Error('Invalid decision for ' + phase.id + ': ' + choiceId);
      }
      addRule(totals, rule);
      eventSuffix = eventVariant(numericSeed, choiceId, phaseIndex);
      details.push({
        phase: phase.title.replace(/^\d+\.\s*/, ''),
        id: choiceId,
        label: selected.label,
        description: selected.description,
        rule: copy(rule)
      });
      events.push(selected.event + ' ' + eventSuffix);
    });

    totals.sizeKB = Math.max(1, totals.sizeKB);
    totals.dependencies = Math.max(0, totals.dependencies);
    totals.coldMs = Math.max(0, totals.coldMs);
    totals.cloudCents = Math.max(0, totals.cloudCents);
    totals.risk = Math.max(0, totals.risk);
    totals.meetings = Math.max(0, totals.meetings);
    totals.value = clamp(totals.value, 0, 100);
    totals.resume = Math.max(0, totals.resume);
    totals.shipDays = Math.max(1, totals.shipDays);
    totals.bloatX100 = Math.round(
      (totals.sizeKB / scenario.essentialKB) * 100
    );

    return {
      version: '4.0.0',
      scenario: scenario,
      seed: numericSeed,
      decisions: decisions.slice(),
      details: details,
      events: events,
      metrics: totals,
      outcome: classify(totals)
    };
  }

  function addRule(total, rule) {
    total.sizeKB += rule['SIZE-KB'];
    total.dependencies += rule.DEPENDENCIES;
    total.coldMs += rule['COLD-MS'];
    total.cloudCents += rule['CLOUD-CENTS'];
    total.risk += rule['RISK-POINTS'];
    total.meetings += rule.MEETINGS;
    total.value += rule['VALUE-POINTS'];
    total.resume += rule['RESUME-POINTS'];
    total.shipDays += rule['SHIP-DAYS'];
  }

  function classify(metrics) {
    if (metrics.shipDays >= 90 && metrics.meetings >= 35) {
      return outcome(
        'COMMITTEE',
        'Successfully coordinated',
        'Nothing shipped, but responsibility is now evenly distributed.'
      );
    }
    if (metrics.risk >= 120) {
      return outcome(
        'RISK-ACCEPTED',
        'Incident-ready architecture',
        'The system has enough moving parts to generate its own weather.'
      );
    }
    if (metrics.bloatX100 >= 100000) {
      return outcome(
        'PLATFORM',
        'Accidental platform',
        'The requirement is somewhere inside a thriving infrastructure.'
      );
    }
    if (metrics.resume > metrics.value * 3) {
      return outcome(
        'RESUME-DRIVEN',
        'Career-positive delivery',
        'User value was traded for an unusually searchable résumé.'
      );
    }
    if (metrics.value >= 70 && metrics.bloatX100 <= 2500) {
      return outcome(
        'USEFUL',
        'Useful software incident',
        'A proportionate thing was built. Please remain calm.'
      );
    }
    return outcome(
      'SHIPPED-ISH',
      'Software-shaped outcome',
      'It works. A smaller object may be trapped inside it.'
    );
  }

  function outcome(code, title, detail) {
    return { code: code, title: title, detail: detail };
  }

  function findOption(phase, id) {
    var found = null;
    phase.options.forEach(function (item) {
      if (item.id === id) {
        found = item;
      }
    });
    return found;
  }

  function eventVariant(seed, id, index) {
    var variants = [
      'A steering group has been spared.',
      'Procurement has requested a diagram.',
      'The user remains cautiously visible.',
      'One architect has updated their biography.',
      'Finance has begun making a face.'
    ];
    return variants[hashNumber(seed + ':' + id + ':' + index) %
      variants.length];
  }

  function reportMarkdown(result) {
    var m = result.metrics;
    var lines = [
      '# HERESY v4 architecture receipt',
      '',
      '**Brief:** ' + result.scenario.brief,
      '',
      '**Verdict:** ' + result.outcome.title,
      '',
      result.outcome.detail,
      '',
      '| Measure | Result |',
      '| --- | ---: |',
      '| Payload | ' + formatKB(m.sizeKB) + ' |',
      '| Dependencies | ' + formatNumber(m.dependencies) + ' |',
      '| Cold start | ' + formatNumber(m.coldMs) + ' ms |',
      '| Monthly cloud | ' + formatMoney(m.cloudCents) + ' |',
      '| Risk points | ' + formatNumber(m.risk) + ' |',
      '| Meetings | ' + formatNumber(m.meetings) + ' |',
      '| Ship time | ' + formatNumber(m.shipDays) + ' days |',
      '| User value | ' + formatNumber(m.value) + '/100 |',
      '| Résumé points | ' + formatNumber(m.resume) + ' |',
      '| Bloat ratio | ' + formatRatio(m.bloatX100) + ' |',
      '',
      '## Decisions',
      '',
      '| Department | Decision | COBOL rule |',
      '| --- | --- | --- |'
    ];
    result.details.forEach(function (detail) {
      lines.push(
        '| ' + detail.phase + ' | ' + detail.label + ' | `' +
        detail.id + '` |'
      );
    });
    lines.push(
      '',
      'Seed: `' + result.seed + '`',
      '',
      '_Calculated from the committed COBOL DATA DIVISION. ' +
      'No cloud architect was queried._',
      ''
    );
    return lines.join('\n');
  }

  function cleanText(value, maximum) {
    return String(value)
      .replace(/[\u0000-\u001f\u007f]/g, ' ')
      .replace(/\s+/g, ' ')
      .trim()
      .slice(0, maximum);
  }

  function normaliseSeed(value) {
    var numeric = parseInt(value, 10);
    if (!isFinite(numeric)) {
      numeric = 1985;
    }
    numeric = Math.abs(Math.floor(numeric)) % 10000000000;
    return numeric;
  }

  function hashNumber(value) {
    var hash = 2166136261;
    var index;
    for (index = 0; index < value.length; index += 1) {
      hash ^= value.charCodeAt(index);
      hash += (hash << 1) + (hash << 4) + (hash << 7) +
        (hash << 8) + (hash << 24);
    }
    return hash >>> 0;
  }

  function formatNumber(value) {
    return String(Math.round(value)).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  }

  function formatKB(value) {
    if (value >= 1024 * 1024) {
      return (value / (1024 * 1024)).toFixed(1) + ' GiB';
    }
    if (value >= 1024) {
      return (value / 1024).toFixed(1) + ' MiB';
    }
    return formatNumber(value) + ' KiB';
  }

  function formatMoney(cents) {
    return '$' + (cents / 100).toFixed(2);
  }

  function formatRatio(x100) {
    var ratio = x100 / 100;
    if (ratio >= 1000) {
      return formatNumber(Math.round(ratio)) + '×';
    }
    return ratio.toFixed(ratio < 10 ? 1 : 0) + '×';
  }

  function clamp(value, minimum, maximum) {
    return Math.max(minimum, Math.min(maximum, value));
  }

  function copy(value) {
    var clone = {};
    Object.keys(value).forEach(function (key) {
      clone[key] = value[key];
    });
    return clone;
  }

  function allRuleIds() {
    var ids = [];
    phases.forEach(function (phase) {
      phase.options.forEach(function (item) {
        ids.push(item.id);
      });
    });
    return ids;
  }

  return {
    metricFields: metricFields,
    scenarios: scenarios,
    phases: phases,
    parseCobol: parseCobol,
    getScenario: getScenario,
    simulate: simulate,
    reportMarkdown: reportMarkdown,
    reportJson: function (result) {
      return JSON.stringify(result, null, 2) + '\n';
    },
    allRuleIds: allRuleIds,
    formatNumber: formatNumber,
    formatKB: formatKB,
    formatMoney: formatMoney,
    formatRatio: formatRatio,
    hashNumber: hashNumber
  };
}));
