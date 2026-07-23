export const CARD_COLUMNS = 80;
export const DATA_COLUMNS = 72;
export const SEQUENCE_COLUMNS = 8;
export const REQUEST_SEQUENCE = 20;

const ROUTE_PATH = /^\/api\/([a-z]+)$/i;
const CARD_TEXT = /^[A-Z0-9 ]*$/;
const HOLLERITH_ROWS = ['12', '11', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

const ASCII_TO_EBCDIC = new Map([[' ', 0x40]]);
for (let digit = 0; digit <= 9; digit += 1) {
  ASCII_TO_EBCDIC.set(String(digit), 0xf0 + digit);
}
for (let index = 0; index < 9; index += 1) {
  ASCII_TO_EBCDIC.set(String.fromCharCode(65 + index), 0xc1 + index);
  ASCII_TO_EBCDIC.set(String.fromCharCode(74 + index), 0xd1 + index);
}
for (let index = 0; index < 8; index += 1) {
  ASCII_TO_EBCDIC.set(String.fromCharCode(83 + index), 0xe2 + index);
}
const EBCDIC_TO_ASCII = new Map(
  [...ASCII_TO_EBCDIC].map(([character, byte]) => [byte, character])
);

export class MainframeAbend extends Error {
  constructor(code, message, details = {}) {
    super(message);
    this.name = 'MainframeAbend';
    this.code = code;
    this.details = details;
  }
}

function abend(code, message, details) {
  throw new MainframeAbend(code, message, details);
}

function fixedText(value, field, width, { numeric = false } = {}) {
  const text = String(value ?? '').toUpperCase();
  const valid = numeric ? /^\d+$/ : CARD_TEXT;
  if (!valid.test(text)) {
    abend(
      'U0014',
      `${field} contains a character unavailable from Central Stationery.`,
      { field, value: text }
    );
  }
  if (text.length > width) {
    abend(
      'S0C1',
      `${field} exceeded PIC ${numeric ? '9' : 'X'}(${width}). The extra data has been referred to a committee.`,
      { field, width, actual: text.length }
    );
  }
  return numeric ? text.padStart(width, '0') : text.padEnd(width, ' ');
}

export function parseCobolSchema(source) {
  const program = source.match(/PROGRAM-ID\.\s*([A-Z0-9-]+)\./i);
  const fieldPattern = /^\s*05\s+([A-Z0-9-]+)\s+PIC\s+([X9])\((\d+)\)\./gim;
  const fields = [];
  let match;
  while ((match = fieldPattern.exec(source)) !== null) {
    fields.push({
      name: match[1].toUpperCase(),
      picture: match[2].toUpperCase(),
      width: Number(match[3])
    });
  }

  if (!program || fields.length === 0) {
    abend('S013', 'COBOL DATA DIVISION misplaced. Please check the filing cabinet.');
  }

  const width = fields.reduce((total, field) => total + field.width, 0);
  if (width !== DATA_COLUMNS) {
    abend(
      'S013',
      `COBOL request record is ${width} columns; procurement purchased exactly ${DATA_COLUMNS}.`
    );
  }

  return { programId: program[1].toUpperCase(), fields, width };
}

export function parseJcl(source) {
  const lines = source.split(/\r?\n/).filter(Boolean);
  const job = lines[0]?.match(/^\/\/([A-Z0-9]+)\s+JOB\b/i);
  const executions = [...source.matchAll(
    /^\/\/([A-Z0-9]+)\s+EXEC\s+PGM=([A-Z0-9-]+)/gim
  )];
  const execute = executions.at(-1);
  const sysin = /^\/\/SYSIN\s+DD\b/im.test(source);
  const punch = /^\/\/PUNCH\s+DD\b/im.test(source);

  if (!job) {
    abend('JCL0001', 'Expected //JOB card. Found agile whitespace.');
  }
  if (!execute || !sysin || !punch) {
    abend('JCL0002', 'JCL allocation failed. One slash may be on annual leave.');
  }

  return {
    jobName: job[1].toUpperCase(),
    program: execute[2].toUpperCase(),
    steps: executions.map((entry) => ({
      name: entry[1].toUpperCase(),
      program: entry[2].toUpperCase()
    })),
    cardCount: 3
  };
}

export function parseFortranRouter(source) {
  const routeBlock = source.match(/DATA\s+ROUTES\s*\/([\s\S]*?)\//i);
  const computedGoto = source.match(/GOTO\s*\(([^)]+)\)\s*,\s*IROUTE/i);
  if (!routeBlock || !computedGoto) {
    abend('F077', 'Computed GOTO missing. Structured control flow is prohibited.');
  }

  const routes = [...routeBlock[1].matchAll(/'([A-Z0-9 ]+)'/gi)]
    .map((match) => match[1].trim().toUpperCase());
  const labels = computedGoto[1].split(',').map((label) => Number(label.trim()));
  const messages = new Map();

  for (const line of source.split(/\r?\n/)) {
    const response = line.match(/^\s*(\d+)\s+WRITE\(\*,\*\)\s+'([^']+)'/i);
    if (response) messages.set(Number(response[1]), response[2]);
  }

  if (
    routes.length === 0 ||
    routes.length !== labels.length ||
    labels.some((label) => !messages.has(label))
  ) {
    abend('F078', 'FORTRAN routing labels and destinations disagree. Democracy attempted.');
  }

  return {
    routes: routes.map((route, index) => ({
      route,
      label: labels[index],
      message: messages.get(labels[index])
    }))
  };
}

export function parseAdaPolicy(source) {
  const length = source.match(
    /OVERRIDE_LENGTH\s*:\s*constant\s+Positive\s*:=\s*(\d+)\s*;/i
  );
  const missileAssumption =
    /MISSILE_ASSUMPTION\s*:\s*constant\s+Boolean\s*:=\s*True\s*;/i.test(source);

  if (!length) {
    abend('ADA83', 'Defense-grade override length was not strongly typed.');
  }

  return {
    overrideLength: Number(length[1]),
    missileAssumption
  };
}

function requestValues(request) {
  const routeMatch = String(request.route ?? '').match(ROUTE_PATH);
  if (!routeMatch) {
    abend('U0404', 'Route absent from FORTRAN desk directory.', { route: request.route });
  }

  const method = String(request.method ?? '').toUpperCase();
  if (method !== 'POST') {
    abend('U0405', 'Only POST is stocked. GET forms are back-ordered until Q4.');
  }

  const ticket = String(request.ticket ?? '').toUpperCase();
  if (!/^CHG\d{9}$/.test(ticket)) {
    abend('U0014', 'Change ticket rejected. Jira cannot be heard over the card punch.');
  }

  return {
    'REQ-ID': fixedText(request.id, 'REQ-ID', 5, { numeric: true }),
    'HTTP-METHOD': fixedText(method, 'HTTP-METHOD', 4),
    'ROUTE-CODE': fixedText(routeMatch[1], 'ROUTE-CODE', 12),
    'DEV-ANXIETY': fixedText(request.anxiety, 'DEV-ANXIETY', 10),
    'CHANGE-TICKET': fixedText(ticket, 'CHANGE-TICKET', 12),
    PAYLOAD: fixedText(request.payload, 'PAYLOAD', 29)
  };
}

export function buildRequestCard(request, cobolSource, sequence = REQUEST_SEQUENCE) {
  const schema = parseCobolSchema(cobolSource);
  const values = requestValues(request);
  const body = schema.fields.map((field) => {
    const value = values[field.name];
    if (value === undefined) {
      abend('S013', `${field.name} exists in COBOL but not in the approved form.`);
    }
    if (value.length !== field.width) {
      abend('S013', `${field.name} escaped its fixed-width cubicle.`);
    }
    return value;
  }).join('');
  const card = body + fixedText(sequence, 'CARD-SEQUENCE', SEQUENCE_COLUMNS, {
    numeric: true
  });

  if (card.length !== CARD_COLUMNS) {
    abend('CARD80', `Card reader received ${card.length} columns and became philosophical.`);
  }
  return card;
}

function controlCard(text, sequence) {
  return fixedText(text, 'CONTROL-CARD', DATA_COLUMNS) +
    fixedText(sequence, 'CARD-SEQUENCE', SEQUENCE_COLUMNS, { numeric: true });
}

export function buildDeck(requestCard) {
  return [
    controlCard('END OF DECK CLOUD MIGRATION COMPLETE', 30),
    requestCard,
    controlCard('HERESY3 JOB DECK DO NOT FOLD SPINDLE OR MODERNISE', 10)
  ];
}

function sequenceOf(card) {
  if (card.length !== CARD_COLUMNS) {
    abend('CARD80', `Physical media violation: ${card.length} columns.`);
  }
  const sequence = card.slice(DATA_COLUMNS);
  if (!/^\d{8}$/.test(sequence)) {
    abend('CARD73', 'Columns 73 through 80 have unionised.');
  }
  return Number(sequence);
}

export function sortDeck(cards) {
  return [...cards].sort((left, right) => sequenceOf(left) - sequenceOf(right));
}

export function encodeEbcdic(text) {
  return Uint8Array.from([...text], (character) => {
    const byte = ASCII_TO_EBCDIC.get(character);
    if (byte === undefined) {
      abend('EBC037', `EBCDIC code page 037 refuses character ${JSON.stringify(character)}.`);
    }
    return byte;
  });
}

export function decodeEbcdic(bytes) {
  return [...bytes].map((byte) => {
    const character = EBCDIC_TO_ASCII.get(byte);
    if (character === undefined) {
      abend('EBC037', `Unallocated EBCDIC byte 0x${byte.toString(16).padStart(2, '0')}.`);
    }
    return character;
  }).join('');
}

export function unpackCobolRecord(body, cobolSource) {
  const schema = parseCobolSchema(cobolSource);
  if (body.length !== schema.width) {
    abend('S013', 'COBOL record boundary crossed without completing Form 27B/6.');
  }

  let offset = 0;
  const record = {};
  for (const field of schema.fields) {
    const value = body.slice(offset, offset + field.width);
    record[field.name] = field.picture === '9' ? value : value.trimEnd();
    offset += field.width;
  }
  return record;
}

function punchesFor(character) {
  if (character === ' ') return [];
  if (/^\d$/.test(character)) return [character];
  const code = character.charCodeAt(0);
  if (code >= 65 && code <= 73) return ['12', String(code - 64)];
  if (code >= 74 && code <= 82) return ['11', String(code - 73)];
  if (code >= 83 && code <= 90) return ['0', String(code - 81)];
  abend('CARD29', `No Hollerith punch combination approved for ${character}.`);
}

export function hollerithRows(card) {
  if (card.length !== CARD_COLUMNS) {
    abend('CARD80', 'Cannot visualise a card that would jam the reader.');
  }
  const punches = [...card].map((character) => punchesFor(character));
  return {
    labels: HOLLERITH_ROWS,
    rows: HOLLERITH_ROWS.map((row) =>
      punches.map((column) => column.includes(row))
    )
  };
}

function recoveryPhrase(requestId, length) {
  const id = String(requestId || 0).padStart(5, '0').slice(-5);
  const confession =
    `I ACCEPT THAT THE MAINFRAME WAS NOT THE BOTTLENECK REQUEST ${id} AUTHORISE `;
  return confession.repeat(Math.ceil(length / confession.length)).slice(0, length);
}

export function containFault(error, adaSource, requestId) {
  const policy = parseAdaPolicy(adaSource);
  return {
    code: error instanceof MainframeAbend ? error.code : 'JS9999',
    message: error.message || 'Unknown exception achieved stakeholder alignment.',
    state: policy.missileAssumption
      ? 'INERTIAL GUIDANCE REVIEW'
      : 'ORDINARY ENTERPRISE PANIC',
    overrideLength: policy.overrideLength,
    challenge: recoveryPhrase(requestId, policy.overrideLength)
  };
}

export function verifyOverride(value, lock) {
  return String(value).length === lock.overrideLength &&
    String(value) === lock.challenge;
}

const ENTERPRISE_TRUTHS = [
  'OBSERVABILITY MEANS BRENDA IS WATCHING THE GREEN LIGHT',
  'AUTOSCALING MEANS DORIS HAS BEEN PAGED',
  'THE SERVICE MESH IS A SHOEBOX WITH DIVIDERS',
  'EVENTUAL CONSISTENCY IS EXPECTED AFTER THE Q4 AUDIT',
  'SERVERLESS MEANS FINANCE OWNS THE SERVER',
  'AI ASSISTANCE WAS REPLACED BY A LAMINATED FLOWCHART'
];

export function executeMainframe({ request, sources }) {
  const jcl = parseJcl(sources.jcl);
  const schema = parseCobolSchema(sources.cobol);
  const router = parseFortranRouter(sources.fortran);
  parseAdaPolicy(sources.ada);

  if (jcl.program !== schema.programId) {
    abend(
      'S806',
      `JCL requested ${jcl.program}; COBOL payroll only recognises ${schema.programId}.`
    );
  }

  const requestCard = buildRequestCard(request, sources.cobol);
  const encoded = encodeEbcdic(requestCard);
  const decoded = decodeEbcdic(encoded);
  if (decoded !== requestCard) {
    abend('EBC037', 'Round-trip failed. The punched card remembers a different past.');
  }

  const deck = sortDeck(buildDeck(decoded));
  const input = deck.find((card) => sequenceOf(card) === REQUEST_SEQUENCE);
  const record = unpackCobolRecord(input.slice(0, DATA_COLUMNS), sources.cobol);
  const destination = router.routes.find((entry) => entry.route === record['ROUTE-CODE']);
  if (!destination) {
    abend('S0C7', `${record['ROUTE-CODE']} fell between FORTRAN labels.`);
  }

  const id = Number(record['REQ-ID']);
  const path = `/api/${destination.route.toLowerCase()}`;
  const truth = ENTERPRISE_TRUTHS[id % ENTERPRISE_TRUTHS.length];
  const traceId = `EBC-${record['REQ-ID']}-${input.slice(DATA_COLUMNS)}`;

  return {
    card: input,
    deck,
    ebcdic: encoded,
    record,
    response: {
      status: 200,
      route: path,
      body: destination.message,
      protocol: 'REST/1959',
      region: 'DESK NEAR FIRE EXIT',
      coldStartMs: 0,
      warmStartYears: 67,
      containers: 0,
      orchestrator: 'CARD SORTER',
      observability: 'BRENDA',
      billingModel: 'CAPEX WITH ASBESTOS',
      traceId,
      enterpriseTruth: truth
    },
    trace: [
      `$HASP100 ${jcl.jobName} ON READER1 ${jcl.cardCount} CARDS`,
      'SORT0001 DECK ARRIVED IN AGILE ORDER 30 20 10',
      'SORT0002 COLUMNS 73 TO 80 RESTORED MANAGEMENT HIERARCHY',
      `EBC0037 ${encoded.length} BYTES ENCODED FOR THE FUTURE OF 1964`,
      `COBOL01 ${schema.programId} ACCEPTED FIXED RECORD ${record['REQ-ID']}`,
      `FORT077 COMPUTED GOTO SELECTED LABEL ${destination.label}`,
      'ADA1983 NO MISSILES AFFECTED BUT PROCEDURE INSISTS WE MENTION THEM',
      `$HASP395 ${jcl.jobName} ENDED CC 0000 SANITY NOT EVALUATED`
    ]
  };
}
