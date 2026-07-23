import React, { useMemo, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { PROGRAM, runBasic } from './basic.js';
import './style.css';

function InnerReact({ spec, count, onIncrement }) {
  return (
    <article className="inner" aria-labelledby="inner-title">
      <p className="eyebrow">{spec.eyebrow}</p>
      <h2 id="inner-title">{spec.title}</h2>
      <p>{spec.body}</p>
      <button type="button" onClick={onIncrement}>{spec.button}: {count}</button>
    </article>
  );
}

function App() {
  const result = useMemo(() => runBasic(), []);
  const [count, setCount] = useState(0);
  const [booted, setBooted] = useState(true);

  return (
    <main>
      <header>
        <p className="kicker">QSOL-IMC · DEPARTMENT OF RECURSIVE THEOLOGY</p>
        <h1>HERESY <span>v2.0.0</span></h1>
        <p className="lede">React inside Commodore BASIC inside React.</p>
        <div className="status" role="list" aria-label="System status">
          <span role="listitem">REACT: CONTAINED</span>
          <span role="listitem">BASIC: READY</span>
          <span role="listitem">SANITY: FAILED</span>
        </div>
      </header>

      <section className="diagram" aria-labelledby="diagram-title">
        <h2 id="diagram-title">Architecture of an avoidable button</h2>
        <ol>
          <li>Outer React host</li><li>Bounded BASIC V2 interpreter</li><li>DATA byte payload</li><li>Inner React component</li><li>Number becomes larger</li>
        </ol>
      </section>

      <section className="terminal" aria-label="Commodore BASIC terminal">
        <div className="terminal-bar"><strong>**** COMMODORE 64 BASIC V2 ****</strong><button type="button" onClick={() => setBooted(v => !v)}>{booted ? 'HALT' : 'RUN'}</button></div>
        {booted ? <pre>{result.transcript.join('\n')}\n\n{PROGRAM}\n\nCOMPONENT EMITTED. GOD FORGIVE US.</pre> : <pre>BREAK IN 10\nREADY.</pre>}
      </section>

      {booted && <InnerReact spec={result.component} count={count} onIncrement={() => setCount(value => value + 1)} />}

      <footer>
        <p>One virtual DOM was apparently insufficient.</p>
        <p><strong>Modern problems require 1982 middleware.</strong></p>
      </footer>
    </main>
  );
}

createRoot(document.getElementById('root')).render(<React.StrictMode><App /></React.StrictMode>);
