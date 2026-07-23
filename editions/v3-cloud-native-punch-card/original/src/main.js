import './style.css';
import jcl from '../programs/HERESY3.jcl?raw';
import cobol from '../programs/mainframe.cob?raw';
import fortran from '../programs/router.f?raw';
import ada from '../programs/failsafe.adb?raw';
import {
  MainframeAbend,
  containFault,
  executeMainframe,
  hollerithRows,
  verifyOverride
} from './mainframe.js';

const sources = { jcl, cobol, fortran, ada };
const root = document.querySelector('#root');

root.innerHTML = `
  <a class="skip-link" href="#request-desk">Skip to requisition desk</a>
  <main>
    <header class="hero">
      <p class="kicker">QSOL-IMC · DIGITAL TRANSFORMATION OFFICE · BASEMENT B</p>
      <div class="hero-title">
        <h1>HERESY <span>v3.0.0</span></h1>
        <p class="stamp">CLOUD<br>NATIVE</p>
      </div>
      <p class="lede">Cloud-native microservices on an EBCDIC punched card.</p>
      <p class="sublede">Every REST request is approved by JCL, packed by COBOL,
        routed by FORTRAN and catastrophised by Ada. Entirely offline. Zero
        containers. One card. No dignity.</p>
      <ul class="status-strip" aria-label="Enterprise status">
        <li><b>1959</b><span>API YEAR</span></li>
        <li><b>80</b><span>COLUMNS / REQUEST</span></li>
        <li><b>0</b><span>CONTAINERS</span></li>
        <li><b>360 KB</b><span>HARD BUDGET</span></li>
      </ul>
    </header>

    <section class="architecture panel" aria-labelledby="architecture-title">
      <div class="section-heading">
        <p>RFC 0001 · APPROVED AFTER LUNCH</p>
        <h2 id="architecture-title">The distributed monolith, now physically sortable</h2>
      </div>
      <ol class="pipeline">
        <li><span>01</span><b>Edge-ish form</b><small>JSON denied entry</small></li>
        <li><span>02</span><b>JCL approval</b><small>Slashes establish authority</small></li>
        <li><span>03</span><b>EBCDIC card</b><small>80 columns of bandwidth</small></li>
        <li><span>04</span><b>COBOL record</b><small>Data learns discipline</small></li>
        <li><span>05</span><b>FORTRAN GOTO</b><small>Route discovery, but honest</small></li>
        <li><span>06</span><b>Ada panic</b><small>Assume missile involvement</small></li>
      </ol>
      <p class="architecture-note">Your request has been decomposed into six
        microservices. All six live in the same browser tab and refuse to
        communicate except through stationery.</p>
    </section>

    <div class="workbench">
      <section class="panel request-panel" id="request-desk" aria-labelledby="request-title">
        <div class="section-heading">
          <p>FORM REST-80 · REVISED 1964</p>
          <h2 id="request-title">Serverless requisition desk</h2>
        </div>
        <form id="request-form">
          <label>Endpoint
            <select name="route">
              <option value="/api/status">POST /api/status</option>
              <option value="/api/deploy">POST /api/deploy</option>
              <option value="/api/ai">POST /api/ai</option>
              <option value="/api/health">POST /api/health</option>
            </select>
          </label>
          <label>Developer anxiety
            <select name="anxiety">
              <option>AGILE</option>
              <option>SYNERGY</option>
              <option>CRITICAL</option>
              <option>SPRINT42</option>
            </select>
          </label>
          <label>Change ticket
            <input name="ticket" value="CHG000000001" maxlength="12"
              pattern="CHG[0-9]{9}" required>
          </label>
          <label>Business payload
            <input name="payload" value="NOOP" maxlength="29"
              pattern="[A-Za-z0-9 ]*" required>
          </label>
          <div class="button-row">
            <button class="primary" type="submit">PROCESS IN 2–4 BUSINESS DAYS</button>
            <button class="danger" id="fault-button" type="button">CAUSE CONTROLLED ABEND</button>
          </div>
        </form>
        <aside class="service-level">
          <b>SLA GUARANTEE</b>
          <p>Five nines, excluding nights, weekends, payroll, weather,
            card jams and all periods in which the system is unavailable.</p>
        </aside>
      </section>

      <section class="panel output-panel" aria-labelledby="output-title">
        <div class="section-heading terminal-heading">
          <p>OBSERVABILITY PLATFORM</p>
          <h2 id="output-title">Someone is staring at it</h2>
        </div>
        <div class="lamps" aria-label="System lamps">
          <span><i class="lamp on"></i>POWER</span>
          <span><i class="lamp on"></i>LEGACY</span>
          <span><i class="lamp"></i>ELASTIC</span>
        </div>
        <pre id="job-log" tabindex="0" aria-live="polite"></pre>
        <h3>REST response, manually retyped</h3>
        <pre id="response" tabindex="0"></pre>
      </section>
    </div>

    <section class="panel card-panel" aria-labelledby="card-title">
      <div class="section-heading">
        <p>IMMUTABLE INFRASTRUCTURE · DO NOT BEND</p>
        <h2 id="card-title">The cloud, but you can drop it</h2>
      </div>
      <figure>
        <div class="card-record">
          <span>COL 01</span><code id="card-text"></code><span>COL 80</span>
        </div>
        <div class="punch-card" id="punch-card" aria-hidden="true"></div>
        <figcaption id="card-caption"></figcaption>
      </figure>
    </section>

    <section class="panel catalogue" aria-labelledby="catalogue-title">
      <div class="section-heading">
        <p>CLOUD CENTRE OF EXCELLENCE</p>
        <h2 id="catalogue-title">Industry innovations already solved by furniture</h2>
      </div>
      <div class="comparison" role="list">
        <article role="listitem"><b>Serverless</b><p>Finance owns the server.</p></article>
        <article role="listitem"><b>Edge compute</b><p>Desk nearest the fire exit.</p></article>
        <article role="listitem"><b>Autoscaling</b><p>Doris gets another chair.</p></article>
        <article role="listitem"><b>Service mesh</b><p>Shoebox with dividers.</p></article>
        <article role="listitem"><b>Blockchain</b><p>Cards stacked in chronological order.</p></article>
        <article role="listitem"><b>Machine learning</b><p>Operator learns the machine.</p></article>
        <article role="listitem"><b>CI/CD</b><p>Card Intake / Card Disposal.</p></article>
        <article role="listitem"><b>Zero trust</b><p>Lowercase rejected on sight.</p></article>
      </div>
    </section>

    <section class="panel source-panel" aria-labelledby="source-title">
      <div class="section-heading">
        <p>SUPPLY-CHAIN TRANSPARENCY</p>
        <h2 id="source-title">Four languages, one avoidable response</h2>
      </div>
      <div class="source-grid">
        <details><summary>JCL · cloud deployment ritual</summary><pre id="jcl-source"></pre></details>
        <details><summary>COBOL · REST record theology</summary><pre id="cobol-source"></pre></details>
        <details><summary>FORTRAN · API gateway GOTO</summary><pre id="fortran-source"></pre></details>
        <details><summary>Ada · defense-grade overreaction</summary><pre id="ada-source"></pre></details>
      </div>
    </section>

    <section class="fault-panel" id="fault-panel" hidden role="dialog"
      aria-modal="true" aria-labelledby="fault-title">
      <div>
        <p class="kicker">ADA 1983 FAULT CONTAINMENT</p>
        <h2 id="fault-title" tabindex="-1">JavaScript exception reclassified as missile incident</h2>
        <p id="fault-message"></p>
        <p>The inertial guidance gyros can only be recalibrated with the exact
          80-character override stored in the sealed envelope beside the printer.</p>
        <code id="fault-challenge"></code>
        <form id="override-form">
          <label>Defense-grade override
            <input id="override-input" autocomplete="off">
          </label>
          <div class="button-row">
            <button type="button" id="insert-override">OPEN SEALED ENVELOPE</button>
            <button class="primary" type="submit">RECALIBRATE GYROS</button>
          </div>
        </form>
        <p class="legal">No missile system exists. Ada remains unconvinced.</p>
      </div>
    </section>

    <footer>
      <p><b>HERESY v3.0.0</b> · A 360 KB rebuttal to the 300 MB coffee app.</p>
      <p>“I routed the cloud-native microservice through an EBCDIC punch card
        because JSON lacked institutional trauma.”</p>
    </footer>
  </main>`;

for (const [id, source] of [
  ['jcl-source', jcl],
  ['cobol-source', cobol],
  ['fortran-source', fortran],
  ['ada-source', ada]
]) {
  document.querySelector(`#${id}`).textContent = source;
}

const form = document.querySelector('#request-form');
const log = document.querySelector('#job-log');
const response = document.querySelector('#response');
const faultPanel = document.querySelector('#fault-panel');
const faultMessage = document.querySelector('#fault-message');
const faultChallenge = document.querySelector('#fault-challenge');
const overrideForm = document.querySelector('#override-form');
const overrideInput = document.querySelector('#override-input');
let requestId = 1;
let currentLock = null;
let lastFocus = null;

function requestFromForm(overrides = {}) {
  const data = new FormData(form);
  return {
    id: requestId,
    method: 'POST',
    route: data.get('route'),
    anxiety: data.get('anxiety'),
    ticket: data.get('ticket'),
    payload: data.get('payload'),
    ...overrides
  };
}

function renderCard(card, ebcdic) {
  const display = document.querySelector('#punch-card');
  const matrix = hollerithRows(card);
  const fragment = document.createDocumentFragment();
  display.replaceChildren();

  for (let row = 0; row < matrix.labels.length; row += 1) {
    const line = document.createElement('div');
    line.className = 'punch-row';
    const label = document.createElement('b');
    label.textContent = matrix.labels[row];
    line.append(label);
    for (let column = 0; column < card.length; column += 1) {
      const hole = document.createElement('i');
      if (matrix.rows[row][column]) hole.className = 'punched';
      line.append(hole);
    }
    fragment.append(line);
  }
  display.append(fragment);
  document.querySelector('#card-text').textContent = card;
  document.querySelector('#card-caption').textContent =
    `80 physical columns · ${ebcdic.length} EBCDIC bytes · ` +
    `sequence ${card.slice(72)} · bandwidth approved by Accounting`;
}

function showFault(error, request) {
  lastFocus = document.activeElement;
  currentLock = containFault(error, ada, request.id);
  faultMessage.textContent = `${currentLock.code}: ${currentLock.message} ` +
    `State: ${currentLock.state}.`;
  faultChallenge.textContent = currentLock.challenge;
  overrideInput.value = '';
  overrideInput.maxLength = currentLock.overrideLength;
  faultPanel.hidden = false;
  document.body.classList.add('locked');
  document.querySelector('#fault-title').focus?.();
}

function runRequest(request) {
  try {
    const result = executeMainframe({ request, sources });
    log.textContent = result.trace.join('\n');
    response.textContent = JSON.stringify(result.response, null, 2);
    renderCard(result.card, result.ebcdic);
    faultPanel.hidden = true;
    document.body.classList.remove('locked');
    requestId += 1;
    form.elements.ticket.value = `CHG${String(requestId).padStart(9, '0')}`;
  } catch (error) {
    showFault(
      error instanceof Error ? error : new MainframeAbend('JS9999', String(error)),
      request
    );
  }
}

form.addEventListener('submit', (event) => {
  event.preventDefault();
  runRequest(requestFromForm());
});

document.querySelector('#fault-button').addEventListener('click', () => {
  runRequest(requestFromForm({ ticket: 'NO TICKET' }));
});

document.querySelector('#insert-override').addEventListener('click', () => {
  if (currentLock) {
    overrideInput.value = currentLock.challenge;
    overrideInput.setCustomValidity('');
  }
});

overrideInput.addEventListener('input', () => overrideInput.setCustomValidity(''));

overrideForm.addEventListener('submit', (event) => {
  event.preventDefault();
  if (!currentLock || !verifyOverride(overrideInput.value, currentLock)) {
    overrideInput.setCustomValidity('Override rejected: sealed envelope mismatch.');
    overrideInput.reportValidity();
    return;
  }
  overrideInput.setCustomValidity('');
  faultPanel.hidden = true;
  document.body.classList.remove('locked');
  log.textContent += '\nADA1983 OVERRIDE ACCEPTED GYROS RECALIBRATED CARD READER APOLOGETIC';
  currentLock = null;
  lastFocus?.focus();
  lastFocus = null;
});

runRequest(requestFromForm());
