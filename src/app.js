'use strict';

(function (window, document, engine, databaseModule, cobolSource) {
  var parsed;
  var database;
  var currentScenario = null;
  var decisions = [];
  var phaseIndex = 0;
  var currentResult = null;
  var currentRecord = null;

  if (!engine || !databaseModule || !cobolSource) {
    fatal('One of the dependency-free scripts failed to arrive.');
    return;
  }

  try {
    parsed = engine.parseCobol(cobolSource);
    database = databaseModule.create({
      source: cobolSource,
      parsed: parsed
    });
    byId('record-width').textContent = database.width + ' characters';
    byId('cobol-source').textContent = cobolSource;
    bindEvents();
    renderHistory('COBOL database mounted. The ORM was turned away.');
  } catch (error) {
    fatal(error.message);
  }

  function bindEvents() {
    byId('scenario').onchange = function () {
      byId('custom-fields').hidden = this.value !== 'CUSTOM';
    };
    byId('setup-form').onsubmit = startSimulation;
    byId('back-button').onclick = previousPhase;
    byId('next-button').onclick = nextPhase;
    byId('cancel-button').onclick = resetToSetup;
    byId('new-run-button').onclick = resetToSetup;
    byId('markdown-button').onclick = function () {
      if (currentResult) {
        download(
          'heresy-v4-architecture-receipt.md',
          engine.reportMarkdown(currentResult),
          'text/markdown'
        );
      }
    };
    byId('json-button').onclick = function () {
      if (currentResult) {
        download(
          'heresy-v4-architecture-receipt.json',
          engine.reportJson(currentResult),
          'application/json'
        );
      }
    };
    byId('print-button').onclick = function () {
      window.print();
    };
    byId('database-export').onclick = function () {
      try {
        download(
          'heresy-v4-cobol-database.dat',
          database.exportText(),
          'text/plain'
        );
        ledgerMessage('Fixed records exported. They may now be faxed.');
      } catch (error) {
        ledgerMessage(error.message, true);
      }
    };
    byId('database-import').onchange = importDatabase;
    byId('database-clear').onclick = clearDatabase;
    byId('history-body').onclick = historyAction;
  }

  function startSimulation(event) {
    var custom;
    event.preventDefault();
    try {
      custom = {
        title: byId('custom-title').value,
        brief: byId('custom-brief').value,
        essentialKB: byId('essential-kb').value,
        baseDays: byId('base-days').value
      };
      currentScenario = engine.getScenario(byId('scenario').value, custom);
      decisions = [];
      engine.phases.forEach(function () {
        decisions.push(null);
      });
      phaseIndex = 0;
      currentResult = null;
      currentRecord = null;
      byId('active-brief').textContent =
        'Actual user request: ' + currentScenario.brief;
      byId('setup').hidden = true;
      byId('report').hidden = true;
      byId('simulator').hidden = false;
      renderPhase();
      focusPanel('simulator');
    } catch (error) {
      window.alert(error.message);
    }
    return false;
  }

  function renderPhase() {
    var phase = engine.phases[phaseIndex];
    var choices = byId('choices');
    var selected = decisions[phaseIndex];
    empty(choices);
    byId('progress-text').textContent =
      'Decision ' + (phaseIndex + 1) + ' of ' + engine.phases.length;
    byId('progress-bar').style.width =
      (((phaseIndex + 1) / engine.phases.length) * 100).toFixed(1) + '%';
    byId('phase-title').textContent = phase.title;
    byId('phase-prompt').textContent = phase.prompt;
    byId('back-button').disabled = phaseIndex === 0;
    byId('next-button').disabled = !selected;
    byId('next-button').textContent =
      phaseIndex === engine.phases.length - 1 ?
        'Compile consequences' : 'Ratify decision';

    phase.options.forEach(function (item) {
      var label = element('label', 'choice');
      var radio = element('input');
      var title = element('span', 'choice-title', item.label);
      var copy = element('span', 'choice-copy', item.description);
      radio.type = 'radio';
      radio.name = 'architecture-choice';
      radio.value = item.id;
      radio.checked = selected === item.id;
      if (radio.checked) {
        addClass(label, 'selected');
      }
      radio.onchange = function () {
        decisions[phaseIndex] = this.value;
        Array.prototype.forEach.call(
          choices.getElementsByClassName('choice'),
          function (choice) {
            removeClass(choice, 'selected');
          }
        );
        addClass(label, 'selected');
        byId('next-button').disabled = false;
        renderProjection();
      };
      label.appendChild(radio);
      label.appendChild(title);
      label.appendChild(copy);
      choices.appendChild(label);
    });
    renderProjection();
  }

  function renderProjection() {
    var projected = [];
    var result;
    var eventCount = 0;
    decisions.forEach(function (decision, index) {
      projected.push(decision || engine.phases[index].options[0].id);
      if (decision) {
        eventCount = index + 1;
      }
    });
    result = engine.simulate(
      currentScenario,
      projected,
      parsed,
      byId('seed').value
    );
    renderMetricList(byId('live-metrics'), result.metrics);
    renderEvents(result.events.slice(0, eventCount));
  }

  function nextPhase() {
    if (!decisions[phaseIndex]) {
      return;
    }
    if (phaseIndex < engine.phases.length - 1) {
      phaseIndex += 1;
      renderPhase();
      byId('decision-fieldset').focus();
    } else {
      finishSimulation();
    }
  }

  function previousPhase() {
    if (phaseIndex > 0) {
      phaseIndex -= 1;
      renderPhase();
    }
  }

  function finishSimulation() {
    var receipt = '';
    try {
      currentResult = engine.simulate(
        currentScenario,
        decisions,
        parsed,
        byId('seed').value
      );
      try {
        currentRecord = database.save(currentResult, new Date());
        receipt = 'PUNCHED: ' + currentRecord['RUN-ID'] + ' · ' +
          database.width + ' columns · checksum ' +
          currentRecord.CHECKSUM + ' · SQL statements avoided: all';
        renderHistory('Run ' + currentRecord['RUN-ID'] +
          ' appended to the COBOL ledger.');
      } catch (databaseError) {
        currentRecord = null;
        receipt = 'DATABASE ABEND: ' + databaseError.message +
          ' The report remains exportable.';
      }
      renderReport(currentResult, receipt);
      byId('simulator').hidden = true;
      byId('report').hidden = false;
      focusPanel('report');
    } catch (error) {
      window.alert(error.message);
    }
  }

  function renderReport(result, receipt) {
    var metrics = result.metrics;
    var metricBox = byId('report-metrics');
    var table = byId('decision-table');
    currentResult = result;
    byId('verdict-stamp').textContent = result.outcome.code;
    byId('report-title').textContent = result.outcome.title;
    byId('report-detail').textContent = result.outcome.detail;
    byId('report-brief').textContent =
      'Original requirement: ' + result.scenario.brief;
    byId('database-receipt').textContent = receipt;
    empty(metricBox);
    [
      ['Payload', engine.formatKB(metrics.sizeKB)],
      ['Dependencies', engine.formatNumber(metrics.dependencies)],
      ['Cold start', engine.formatNumber(metrics.coldMs) + ' ms'],
      ['Monthly cloud', engine.formatMoney(metrics.cloudCents)],
      ['Risk points', engine.formatNumber(metrics.risk)],
      ['Meetings', engine.formatNumber(metrics.meetings)],
      ['Ship time', engine.formatNumber(metrics.shipDays) + ' days'],
      ['User value', engine.formatNumber(metrics.value) + '/100'],
      ['Résumé points', engine.formatNumber(metrics.resume)],
      ['Bloat ratio', engine.formatRatio(metrics.bloatX100)]
    ].forEach(function (metric) {
      var card = element('div', 'metric-card');
      card.appendChild(element('span', 'metric-name', metric[0]));
      card.appendChild(element('strong', 'metric-value', metric[1]));
      metricBox.appendChild(card);
    });

    empty(table);
    result.details.forEach(function (detail) {
      var row = element('tr');
      row.appendChild(cell(detail.phase));
      row.appendChild(cell(detail.label));
      row.appendChild(cell(detail.id, true));
      table.appendChild(row);
    });
  }

  function renderMetricList(target, metrics) {
    var rows = [
      ['Payload', engine.formatKB(metrics.sizeKB)],
      ['Dependencies', engine.formatNumber(metrics.dependencies)],
      ['Cold start', engine.formatNumber(metrics.coldMs) + ' ms'],
      ['Cloud / month', engine.formatMoney(metrics.cloudCents)],
      ['Risk', engine.formatNumber(metrics.risk)],
      ['Meetings', engine.formatNumber(metrics.meetings)],
      ['Ship time', engine.formatNumber(metrics.shipDays) + ' d'],
      ['User value', engine.formatNumber(metrics.value) + '/100'],
      ['Résumé', engine.formatNumber(metrics.resume)],
      ['Bloat', engine.formatRatio(metrics.bloatX100)]
    ];
    empty(target);
    rows.forEach(function (row) {
      var wrapper = element('div');
      wrapper.appendChild(element('dt', '', row[0]));
      wrapper.appendChild(element('dd', '', row[1]));
      target.appendChild(wrapper);
    });
  }

  function renderEvents(events) {
    var list = byId('event-log');
    empty(list);
    if (!events.length) {
      list.appendChild(element(
        'li',
        '',
        'Awaiting the first irreversible architectural preference.'
      ));
      return;
    }
    events.forEach(function (event) {
      list.appendChild(element('li', '', event));
    });
  }

  function renderHistory(message) {
    var records;
    var body = byId('history-body');
    try {
      records = database.list();
      empty(body);
      byId('record-count').textContent = String(records.length);
      if (!records.length) {
        body.appendChild(emptyHistoryRow());
      } else {
        records.forEach(function (record) {
          var row = element('tr');
          var actions = element('td');
          var view = element('button', 'button', 'View');
          var remove = element('button', 'button danger', 'Delete');
          view.type = 'button';
          view.setAttribute('data-action', 'view');
          view.setAttribute('data-id', record['RUN-ID']);
          remove.type = 'button';
          remove.setAttribute('data-action', 'delete');
          remove.setAttribute('data-id', record['RUN-ID']);
          row.appendChild(cell(record['RUN-ID']));
          row.appendChild(cell(record['BRIEF-TEXT']));
          row.appendChild(cell(record['OUTCOME-CODE']));
          row.appendChild(cell(engine.formatRatio(record['BLOAT-X100'])));
          actions.appendChild(view);
          actions.appendChild(remove);
          row.appendChild(actions);
          body.appendChild(row);
        });
      }
      if (records.errors.length) {
        ledgerMessage(
          records.errors.length +
          ' corrupt record(s) quarantined. Export the ledger for surgery.',
          true
        );
      } else {
        ledgerMessage(message || 'Ledger read successfully.');
      }
    } catch (error) {
      byId('record-count').textContent = 'ABEND';
      empty(body);
      body.appendChild(emptyHistoryRow());
      ledgerMessage(error.message, true);
    }
  }

  function historyAction(event) {
    var target = event.target;
    var action = target.getAttribute('data-action');
    var id = target.getAttribute('data-id');
    var record;
    if (!action || !id) {
      return;
    }
    if (action === 'delete') {
      if (window.confirm('Delete fixed record ' + id + '?')) {
        try {
          database.remove(id);
          renderHistory('Record ' + id + ' de-punched.');
        } catch (error) {
          ledgerMessage(error.message, true);
        }
      }
      return;
    }
    record = findRecord(id);
    if (record) {
      currentRecord = record;
      currentResult = resultFromRecord(record);
      renderReport(
        currentResult,
        'RECALLED: ' + record['RUN-ID'] + ' · fixed record checksum ' +
          record.CHECKSUM + ' verified before display'
      );
      byId('setup').hidden = true;
      byId('simulator').hidden = true;
      byId('report').hidden = false;
      focusPanel('report');
    }
  }

  function findRecord(id) {
    var found = null;
    database.list().forEach(function (record) {
      if (record['RUN-ID'] === id) {
        found = record;
      }
    });
    return found;
  }

  function resultFromRecord(record) {
    var selected = record.DECISIONS.split(',');
    var scenario = {
      id: record.SCENARIO,
      title: record.SCENARIO,
      brief: record['BRIEF-TEXT'],
      essentialKB: Math.max(1, Math.round(
        record['SIZE-KB'] / (record['BLOAT-X100'] / 100)
      )),
      baseDays: 1
    };
    var details = [];
    engine.phases.forEach(function (phase, index) {
      var choice = null;
      phase.options.forEach(function (item) {
        if (item.id === selected[index]) {
          choice = item;
        }
      });
      details.push({
        phase: phase.title.replace(/^\d+\.\s*/, ''),
        id: selected[index] || 'UNKNOWN',
        label: choice ? choice.label : 'Unknown historical decision'
      });
    });
    return {
      version: '4.0.0',
      scenario: scenario,
      seed: record['SEED-VALUE'],
      decisions: selected,
      details: details,
      events: [],
      metrics: {
        sizeKB: record['SIZE-KB'],
        dependencies: record.DEPENDENCIES,
        coldMs: record['COLD-MS'],
        cloudCents: record['CLOUD-CENTS'],
        risk: record['RISK-POINTS'],
        meetings: record.MEETINGS,
        value: record['VALUE-POINTS'],
        resume: record['RESUME-POINTS'],
        shipDays: record['SHIP-DAYS'],
        bloatX100: record['BLOAT-X100']
      },
      outcome: outcomeFromCode(record['OUTCOME-CODE'])
    };
  }

  function outcomeFromCode(code) {
    var outcomes = {
      COMMITTEE: [
        'Successfully coordinated',
        'Nothing shipped, but responsibility is now evenly distributed.'
      ],
      'RISK-ACCEPTED': [
        'Incident-ready architecture',
        'The system has enough moving parts to generate its own weather.'
      ],
      PLATFORM: [
        'Accidental platform',
        'The requirement is somewhere inside a thriving infrastructure.'
      ],
      'RESUME-DRIVEN': [
        'Career-positive delivery',
        'User value was traded for an unusually searchable résumé.'
      ],
      USEFUL: [
        'Useful software incident',
        'A proportionate thing was built. Please remain calm.'
      ],
      'SHIPPED-ISH': [
        'Software-shaped outcome',
        'It works. A smaller object may be trapped inside it.'
      ]
    };
    var selected = outcomes[code] || [code, 'Historical verdict recalled.'];
    return { code: code, title: selected[0], detail: selected[1] };
  }

  function importDatabase(event) {
    var file = event.target.files[0];
    var reader;
    if (!file) {
      return;
    }
    reader = new window.FileReader();
    reader.onload = function () {
      var result;
      try {
        result = database.importText(reader.result);
        renderHistory(
          result.added + ' record(s) imported; ' +
          result.skipped + ' duplicate(s) refused.'
        );
      } catch (error) {
        ledgerMessage('Import ABEND: ' + error.message, true);
      }
      event.target.value = '';
    };
    reader.onerror = function () {
      ledgerMessage('The selected card deck could not be read.', true);
      event.target.value = '';
    };
    reader.readAsText(file);
  }

  function clearDatabase() {
    if (!window.confirm(
      'Format the entire COBOL ledger? Export it first if history matters.'
    )) {
      return;
    }
    try {
      database.clear();
      renderHistory('Ledger formatted. The beige void is ready.');
    } catch (error) {
      ledgerMessage(error.message, true);
    }
  }

  function resetToSetup() {
    byId('simulator').hidden = true;
    byId('report').hidden = true;
    byId('setup').hidden = false;
    focusPanel('setup');
  }

  function download(filename, contents, type) {
    var link = document.createElement('a');
    link.download = filename;
    link.href = 'data:' + type + ';charset=utf-8,' +
      encodeURIComponent(contents);
    link.style.display = 'none';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }

  function cell(value, code) {
    var td = element('td');
    var child;
    if (code) {
      child = element('code', '', String(value));
      td.appendChild(child);
    } else {
      td.textContent = String(value);
    }
    return td;
  }

  function emptyHistoryRow() {
    var row = element('tr');
    var td = element(
      'td',
      'empty-row',
      'NO RECORDS FOUND. THIS IS EITHER DISCIPLINE OR DATA LOSS.'
    );
    td.colSpan = 5;
    row.appendChild(td);
    return row;
  }

  function ledgerMessage(message, isError) {
    var notice = byId('ledger-status');
    notice.textContent = message;
    notice.className = isError ? 'notice error' : 'notice';
  }

  function focusPanel(id) {
    var panel = byId(id);
    panel.setAttribute('tabindex', '-1');
    panel.focus();
    if (panel.scrollIntoView) {
      panel.scrollIntoView();
    }
  }

  function fatal(message) {
    var notice = document.getElementById('ledger-status');
    if (notice) {
      notice.textContent = 'SYSTEM ABEND: ' + message;
      notice.className = 'notice error';
    } else {
      window.alert('HERESY SYSTEM ABEND: ' + message);
    }
  }

  function byId(id) {
    return document.getElementById(id);
  }

  function element(tag, className, text) {
    var node = document.createElement(tag);
    if (className) {
      node.className = className;
    }
    if (text !== undefined) {
      node.textContent = text;
    }
    return node;
  }

  function empty(node) {
    while (node.firstChild) {
      node.removeChild(node.firstChild);
    }
  }

  function addClass(node, className) {
    if ((' ' + node.className + ' ').indexOf(' ' + className + ' ') < 0) {
      node.className += (node.className ? ' ' : '') + className;
    }
  }

  function removeClass(node, className) {
    node.className = (' ' + node.className + ' ')
      .replace(' ' + className + ' ', ' ')
      .replace(/^\s+|\s+$/g, '');
  }
}(window, document, window.HERESY_ENGINE,
  window.HERESY_COBOL_DATABASE, window.HERESY_COBOL_SOURCE));
