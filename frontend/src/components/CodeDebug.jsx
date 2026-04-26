import { useEffect, useMemo, useState } from 'react';
import Editor from '@monaco-editor/react';
import {
  MdAutoFixHigh,
  MdBugReport,
  MdClose,
  MdContentCopy,
  MdDelete,
  MdHistory,
  MdPlayArrow,
  MdRefresh,
  MdSearch,
  MdTerminal,
} from 'react-icons/md';
import { toast } from 'react-toastify';
import api from '../services/api';
import { formatDateTime } from '../utils/timeUtils';
import MessageRenderer from './MessageRenderer';

const languages = [
  { value: 'python', label: 'Python', sample: "def add(a, b):\n    return a + b\n\nprint(add(2, '3'))" },
  { value: 'javascript', label: 'JavaScript', sample: "function total(items) {\n  return items.map(item => item.price).reduce((a, b) => a + b)\n}\n\nconsole.log(total([]))" },
  { value: 'java', label: 'Java', sample: "class Main {\n  public static void main(String[] args) {\n    String name = null;\n    System.out.println(name.length());\n  }\n}" },
  { value: 'cpp', label: 'C++', sample: "#include <iostream>\nusing namespace std;\n\nint main() {\n  int *x = nullptr;\n  cout << *x;\n}" },
  { value: 'sql', label: 'SQL', sample: "SELECT name, COUNT(*)\nFROM users\nWHERE active = true;" },
];

const modes = [
  {
    id: 'debug',
    label: 'Debug',
    icon: MdBugReport,
    instruction: 'Find bugs, runtime errors, syntax mistakes, and edge cases. Give a corrected version.',
  },
  {
    id: 'explain',
    label: 'Explain',
    icon: MdTerminal,
    instruction: 'Explain this code line by line in simple language and identify important concepts.',
  },
  {
    id: 'optimize',
    label: 'Optimize',
    icon: MdAutoFixHigh,
    instruction: 'Improve readability, performance, structure, and best practices. Show the improved code.',
  },
];

const runJavaScriptInWorker = (code) => {
  return new Promise((resolve, reject) => {
    const workerSource = `
      const format = (value) => {
        if (typeof value === 'string') return value;
        try { return JSON.stringify(value); } catch { return String(value); }
      };

      self.onmessage = (event) => {
        const logs = [];
        const console = {
          log: (...args) => logs.push(args.map(format).join(' ')),
          warn: (...args) => logs.push('Warning: ' + args.map(format).join(' ')),
          error: (...args) => logs.push('Error: ' + args.map(format).join(' ')),
        };

        try {
          const result = Function('console', '"use strict";\\n' + event.data)(console);
          if (result !== undefined) logs.push('Return: ' + format(result));
          self.postMessage({ ok: true, output: logs.join('\\n') || 'Code ran successfully with no console output.' });
        } catch (error) {
          self.postMessage({ ok: false, error: error && error.message ? error.message : String(error) });
        }
      };
    `;

    const blob = new Blob([workerSource], { type: 'application/javascript' });
    const worker = new Worker(URL.createObjectURL(blob));
    const timeout = window.setTimeout(() => {
      worker.terminate();
      reject(new Error('Execution timed out after 3 seconds'));
    }, 3000);

    worker.onmessage = (event) => {
      window.clearTimeout(timeout);
      worker.terminate();
      if (event.data.ok) {
        resolve(event.data.output);
      } else {
        reject(new Error(event.data.error));
      }
    };

    worker.onerror = (error) => {
      window.clearTimeout(timeout);
      worker.terminate();
      reject(new Error(error.message || 'Worker execution failed'));
    };

    worker.postMessage(code);
  });
};

const CodeDebug = () => {
  const [codeInput, setCodeInput] = useState('');
  const [language, setLanguage] = useState('python');
  const [analysisMode, setAnalysisMode] = useState('debug');
  const [debugResponse, setDebugResponse] = useState('');
  const [debugResponseRoman, setDebugResponseRoman] = useState('');
  const [runOutput, setRunOutput] = useState('');
  const [showRoman, setShowRoman] = useState(false);
  const [responseLoading, setResponseLoading] = useState(false);
  const [runLoading, setRunLoading] = useState(false);
  const [historyLoading, setHistoryLoading] = useState(false);
  const [codeSessions, setCodeSessions] = useState([]);
  const [selectedSession, setSelectedSession] = useState(null);
  const [showHistory, setShowHistory] = useState(false);
  const [historySearch, setHistorySearch] = useState('');

  useEffect(() => {
    loadCodeSessions();
  }, []);

  const selectedLanguage = languages.find((item) => item.value === language) || languages[0];
  const selectedMode = modes.find((mode) => mode.id === analysisMode) || modes[0];

  const filteredSessions = useMemo(() => {
    const query = historySearch.trim().toLowerCase();
    if (!query) return codeSessions;

    return codeSessions.filter((session) => {
      return [session.name, session.language, session.created_at]
        .some((value) => String(value || '').toLowerCase().includes(query));
    });
  }, [codeSessions, historySearch]);

  const loadCodeSessions = async () => {
    try {
      setHistoryLoading(true);
      const response = await api.get('/api/code/sessions');
      setCodeSessions(Array.isArray(response.data) ? response.data : []);
    } catch (error) {
      console.error('Failed to load code sessions:', error);
      toast.error('Could not load code history');
    } finally {
      setHistoryLoading(false);
    }
  };

  const handleDebug = async () => {
    if (!codeInput.trim()) {
      toast.warning('Please enter some code first');
      return;
    }

    setResponseLoading(true);
    setDebugResponse('');
    setDebugResponseRoman('');

    try {
      const response = await api.post('/api/code/debug', {
        language,
        mode: analysisMode,
        instruction: selectedMode.instruction,
        code: codeInput,
      });

      setDebugResponse(response.data.response || 'No analysis returned.');
      setDebugResponseRoman(response.data.response_roman || '');
      setSelectedSession({
        id: response.data.session_id,
        name: response.data.session_name,
        language,
      });
      toast.success(`Code analyzed: ${response.data.session_name || 'new session'}`);
      loadCodeSessions();
    } catch (error) {
      const detail = error.response?.data?.detail || error.message;
      toast.error('Debug failed: ' + detail);
      setDebugResponse(`Analysis failed: ${detail}`);
    } finally {
      setResponseLoading(false);
    }
  };

  const clearCodeUI = () => {
    setCodeInput('');
    setDebugResponse('');
    setDebugResponseRoman('');
    setRunOutput('');
    setShowRoman(false);
    setSelectedSession(null);
  };

  const loadSample = () => {
    setCodeInput(selectedLanguage.sample);
    setDebugResponse('');
    setDebugResponseRoman('');
    setRunOutput('');
    setSelectedSession(null);
  };

  const handleRunCode = async () => {
    if (!codeInput.trim()) {
      toast.warning('Please enter some code first');
      return;
    }

    setRunLoading(true);
    setRunOutput('');

    try {
      if (language !== 'javascript') {
        setRunOutput(
          `Run is currently available in the browser for JavaScript only.\n\nSelected language: ${selectedLanguage.label}\nUse Debug/Explain/Optimize for AI analysis, or add a backend runner endpoint for ${selectedLanguage.label}.`
        );
        toast.info('Run currently supports JavaScript in the browser');
        return;
      }

      const output = await runJavaScriptInWorker(codeInput);
      setRunOutput(output || 'Code ran successfully with no console output.');
      toast.success('JavaScript code ran');
    } catch (error) {
      setRunOutput(`Runtime error:\n${error.message}`);
      toast.error('Run failed: ' + error.message);
    } finally {
      setRunLoading(false);
    }
  };

  const copyText = async (text, label) => {
    if (!text) {
      toast.info(`Nothing to copy from ${label}`);
      return;
    }

    try {
      await navigator.clipboard.writeText(text);
      toast.success(`${label} copied`);
    } catch {
      toast.error('Copy failed');
    }
  };

  const loadSession = async (sessionId) => {
    try {
      const response = await api.get(`/api/code/sessions/${sessionId}`);
      const session = response.data;
      const listSession = codeSessions.find((item) => item.id === sessionId);

      setCodeInput(session.code_input || session.code || '');
      setLanguage(session.language || listSession?.language || language);
      setDebugResponse(session.response || '');
      setDebugResponseRoman(session.response_roman || '');
      setSelectedSession({
        ...listSession,
        ...session,
        id: session.id || sessionId,
        name: session.name || listSession?.name || 'Code session',
        language: session.language || listSession?.language || language,
      });
      setShowHistory(false);
      toast.success(`Loaded: ${session.name || listSession?.name || 'Code session'}`);
    } catch (error) {
      toast.error('Failed to load session: ' + (error.response?.data?.detail || error.message));
    }
  };

  const deleteSession = async (sessionId) => {
    try {
      await api.delete(`/api/code/sessions/${sessionId}`);
      toast.success('Session deleted');
      setCodeSessions((prev) => prev.filter((session) => session.id !== sessionId));

      if (selectedSession?.id === sessionId) {
        clearCodeUI();
      }
    } catch (error) {
      toast.error('Failed to delete session: ' + (error.response?.data?.detail || error.message));
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'Unknown date';
    return formatDateTime(dateString);
  };

  const currentResponse = showRoman ? debugResponseRoman : debugResponse;

  return (
    <div className="h-full min-h-0 flex flex-col theme-surface theme-text rounded-lg theme-border border overflow-y-auto lg:overflow-hidden custom-scroll">
      <header className="flex-shrink-0 border-b theme-border theme-surface px-4 py-3">
        <div className="flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
          <div className="min-w-0">
            <div className="flex items-center gap-2">
              <MdTerminal className="text-blue-500" size={22} />
              <h1 className="text-lg font-semibold">Code Debugger</h1>
            </div>
            <p className="text-xs theme-muted mt-1">Debug, explain, and improve code with AI assistance.</p>
          </div>

          <div className="flex flex-wrap items-center gap-2">
            <button
              type="button"
              onClick={() => setShowHistory((current) => !current)}
              className="inline-flex items-center gap-2 rounded-lg theme-surface-soft theme-border border px-3 py-2 text-sm font-medium hover:opacity-85"
            >
              <MdHistory size={17} />
              {showHistory ? 'Hide History' : 'History'}
            </button>
            <button
              type="button"
              onClick={loadCodeSessions}
              className="inline-flex items-center gap-2 rounded-lg theme-surface-soft theme-border border px-3 py-2 text-sm font-medium hover:opacity-85"
            >
              <MdRefresh className={historyLoading ? 'animate-spin' : ''} size={17} />
              Refresh
            </button>
            <button
              type="button"
              onClick={clearCodeUI}
              className="rounded-lg theme-surface-soft theme-border border px-3 py-2 text-sm font-medium hover:opacity-85"
            >
              Clear
            </button>
          </div>
        </div>
      </header>

      {showHistory && (
        <div className="fixed inset-0 z-50 bg-black/45 backdrop-blur-sm lg:hidden">
          <div className="h-full theme-surface theme-text flex flex-col">
            <HistoryPanel
              sessions={filteredSessions}
              selectedSession={selectedSession}
              historySearch={historySearch}
              setHistorySearch={setHistorySearch}
              historyLoading={historyLoading}
              loadSession={loadSession}
              deleteSession={deleteSession}
              formatDate={formatDate}
              onClose={() => setShowHistory(false)}
            />
          </div>
        </div>
      )}

      <div className="flex flex-1 min-h-0 overflow-y-auto lg:overflow-hidden custom-scroll">
        {showHistory && (
          <aside className="hidden lg:flex w-80 shrink-0 theme-surface-soft theme-border border-r min-h-0">
            <HistoryPanel
              sessions={filteredSessions}
              selectedSession={selectedSession}
              historySearch={historySearch}
              setHistorySearch={setHistorySearch}
              historyLoading={historyLoading}
              loadSession={loadSession}
              deleteSession={deleteSession}
              formatDate={formatDate}
            />
          </aside>
        )}

        <main className="flex-1 grid grid-cols-1 lg:grid-cols-2 min-h-0 overflow-visible lg:overflow-hidden">
          <section className="min-h-[620px] lg:min-h-0 flex flex-col theme-border border-r p-3 lg:p-4">
            <div className="mb-3 flex flex-col gap-3">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                <label className="text-xs font-semibold theme-muted">
                  Language
                  <select
                    value={language}
                    onChange={(event) => setLanguage(event.target.value)}
                    className="mt-1 w-full rounded-lg theme-surface-soft theme-border border px-3 py-2 theme-text outline-none"
                  >
                    {languages.map((item) => (
                      <option key={item.value} value={item.value}>{item.label}</option>
                    ))}
                  </select>
                </label>

                <div>
                  <p className="text-xs font-semibold theme-muted mb-1">Mode</p>
                  <div className="grid grid-cols-3 gap-1 rounded-lg theme-surface-soft theme-border border p-1">
                    {modes.map((mode) => {
                      const Icon = mode.icon;
                      const isActive = analysisMode === mode.id;
                      return (
                        <button
                          type="button"
                          key={mode.id}
                          onClick={() => setAnalysisMode(mode.id)}
                          className={`inline-flex items-center justify-center gap-1 rounded-md px-2 py-2 text-xs font-semibold ${
                            isActive ? 'bg-blue-600 text-white' : 'hover:opacity-80'
                          }`}
                          title={mode.instruction}
                        >
                          <Icon size={15} />
                          {mode.label}
                        </button>
                      );
                    })}
                  </div>
                </div>
              </div>

              {selectedSession && (
                <div className="rounded-lg border border-blue-500/30 bg-blue-500/10 px-3 py-2 text-sm text-blue-700 dark:text-blue-200">
                  Loaded: {selectedSession.name}
                </div>
              )}
            </div>

            <div className="flex-1 min-h-[320px] overflow-hidden rounded-lg theme-border border">
              <Editor
                height="100%"
                language={language === 'cpp' ? 'cpp' : language}
                value={codeInput}
                onChange={(value) => setCodeInput(value || '')}
                theme="vs-dark"
                options={{
                  minimap: { enabled: false },
                  fontSize: 14,
                  lineNumbers: 'on',
                  wordWrap: 'on',
                  automaticLayout: true,
                  scrollBeyondLastLine: false,
                  padding: { top: 14, bottom: 14 },
                }}
              />
            </div>

            <div className="mt-3 grid grid-cols-2 lg:grid-cols-5 gap-2">
              <button
                type="button"
                onClick={handleDebug}
                disabled={responseLoading || !codeInput.trim()}
                className="col-span-2 inline-flex items-center justify-center gap-2 rounded-lg bg-blue-600 px-4 py-3 text-sm font-semibold text-white hover:bg-blue-700 disabled:opacity-50"
              >
                {responseLoading ? (
                  <span className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
                ) : (
                  <MdPlayArrow size={18} />
                )}
                {responseLoading ? 'Analyzing...' : `${selectedMode.label} Code`}
              </button>
              <button
                type="button"
                onClick={handleRunCode}
                disabled={runLoading || !codeInput.trim()}
                className="inline-flex items-center justify-center gap-2 rounded-lg bg-emerald-600 px-3 py-3 text-sm font-semibold text-white hover:bg-emerald-700 disabled:opacity-50"
              >
                {runLoading ? (
                  <span className="h-4 w-4 animate-spin rounded-full border-2 border-white border-t-transparent" />
                ) : (
                  <MdPlayArrow size={18} />
                )}
                Run
              </button>
              <button
                type="button"
                onClick={loadSample}
                className="rounded-lg theme-surface-soft theme-border border px-3 py-3 text-sm font-semibold hover:opacity-85"
              >
                Sample
              </button>
              <button
                type="button"
                onClick={() => copyText(codeInput, 'Code')}
                className="inline-flex items-center justify-center gap-2 rounded-lg theme-surface-soft theme-border border px-3 py-3 text-sm font-semibold hover:opacity-85"
              >
                <MdContentCopy size={16} />
                Copy
              </button>
            </div>
          </section>

          <section className="min-h-[520px] lg:min-h-0 flex flex-col p-3 lg:p-4">
            <div className="mb-3 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <h3 className="text-base font-semibold">Analysis & Explanation</h3>
                <p className="text-xs theme-muted">Review fixes, causes, and improved code.</p>
              </div>
              <div className="flex items-center gap-2">
                <button
                  type="button"
                  onClick={() => setShowRoman(false)}
                  className={`rounded-lg px-3 py-2 text-xs font-semibold ${!showRoman ? 'bg-blue-600 text-white' : 'theme-surface-soft theme-border border'}`}
                >
                  English
                </button>
                <button
                  type="button"
                  onClick={() => setShowRoman(true)}
                  disabled={!debugResponseRoman}
                  className={`rounded-lg px-3 py-2 text-xs font-semibold ${showRoman ? 'bg-blue-600 text-white' : 'theme-surface-soft theme-border border'} disabled:opacity-50`}
                >
                  Roman Urdu
                </button>
                <button
                  type="button"
                  onClick={() => copyText(currentResponse, 'Analysis')}
                  className="rounded-lg theme-surface-soft theme-border border p-2 hover:opacity-85"
                  title="Copy analysis"
                >
                  <MdContentCopy size={16} />
                </button>
              </div>
            </div>

            <div className="flex-1 min-h-[320px] overflow-y-auto custom-scroll rounded-lg theme-surface-soft theme-border border p-4">
              {runOutput && (
                <div className="mb-4 rounded-lg border border-emerald-500/30 bg-emerald-500/10 p-3">
                  <div className="mb-2 flex items-center justify-between gap-2">
                    <p className="text-sm font-semibold text-emerald-700 dark:text-emerald-200">Run Output</p>
                    <button
                      type="button"
                      onClick={() => copyText(runOutput, 'Run output')}
                      className="rounded-md p-1 hover:opacity-80"
                      title="Copy run output"
                    >
                      <MdContentCopy size={15} />
                    </button>
                  </div>
                  <pre className="whitespace-pre-wrap break-words text-sm theme-text">{runOutput}</pre>
                </div>
              )}

              {responseLoading ? (
                <div className="flex h-full items-center justify-center text-center theme-muted">
                  <div>
                    <div className="mx-auto h-10 w-10 animate-spin rounded-full border-4 border-blue-200 border-t-blue-600" />
                    <p className="mt-4 font-semibold">Analyzing your code</p>
                    <p className="mt-1 text-sm">The response will appear here.</p>
                  </div>
                </div>
              ) : currentResponse ? (
                <div className="theme-text">
                  <MessageRenderer content={currentResponse} />
                </div>
              ) : (
                <div className="flex h-full items-center justify-center text-center theme-muted">
                  <div>
                    <MdSearch className="mx-auto mb-3 h-12 w-12 opacity-70" />
                    <p className="text-lg font-semibold">Ready to analyze</p>
                    <p className="mt-1 text-sm">Paste code, choose a mode, and run the debugger.</p>
                  </div>
                </div>
              )}
            </div>
          </section>
        </main>
      </div>
    </div>
  );
};

const HistoryPanel = ({
  sessions,
  selectedSession,
  historySearch,
  setHistorySearch,
  historyLoading,
  loadSession,
  deleteSession,
  formatDate,
  onClose,
}) => (
  <div className="flex h-full w-full flex-col min-h-0">
    <div className="border-b theme-border p-3">
      <div className="flex items-center justify-between gap-2">
        <div>
          <h3 className="font-semibold">Code Sessions</h3>
          <p className="text-xs theme-muted">{sessions.length} shown</p>
        </div>
        {onClose && (
          <button
            type="button"
            onClick={onClose}
            className="rounded-lg theme-surface-soft theme-border border p-2"
            aria-label="Close history"
          >
            <MdClose size={18} />
          </button>
        )}
      </div>

      <label className="mt-3 flex items-center gap-2 rounded-lg theme-surface theme-border border px-3 py-2">
        <MdSearch size={16} className="theme-muted" />
        <input
          value={historySearch}
          onChange={(event) => setHistorySearch(event.target.value)}
          placeholder="Search code sessions"
          className="w-full bg-transparent text-sm outline-none"
        />
      </label>
    </div>

    <div className="flex-1 min-h-0 overflow-y-auto custom-scroll p-3 space-y-2">
      {historyLoading ? (
        <div className="py-8 text-center theme-muted">Loading history...</div>
      ) : sessions.length === 0 ? (
        <div className="py-8 text-center theme-muted">
          <MdHistory className="mx-auto mb-3 h-10 w-10 opacity-70" />
          <p className="font-semibold">No sessions found</p>
          <p className="text-sm">Run a code analysis to create one.</p>
        </div>
      ) : (
        sessions.map((session) => (
          <div
            role="button"
            tabIndex={0}
            key={session.id}
            onClick={() => loadSession(session.id)}
            onKeyDown={(event) => {
              if (event.key === 'Enter' || event.key === ' ') {
                event.preventDefault();
                loadSession(session.id);
              }
            }}
            className={`group w-full rounded-lg border p-3 text-left transition ${
              selectedSession?.id === session.id
                ? 'border-blue-500 bg-blue-600 text-white'
                : 'theme-surface theme-border hover:opacity-90'
            }`}
          >
            <div className="flex items-start justify-between gap-2">
              <div className="min-w-0">
                <p className="truncate text-sm font-semibold">{session.name || 'Code session'}</p>
                <p className={`mt-1 text-xs ${selectedSession?.id === session.id ? 'text-blue-100' : 'theme-muted'}`}>
                  {session.language || 'code'} - {formatDate(session.created_at)}
                </p>
              </div>
              <button
                type="button"
                onClick={(event) => {
                  event.stopPropagation();
                  deleteSession(session.id);
                }}
                onKeyDown={(event) => {
                  if (event.key === 'Enter' || event.key === ' ') {
                    event.preventDefault();
                    event.stopPropagation();
                    deleteSession(session.id);
                  }
                }}
                className="rounded-lg p-2 text-rose-500 opacity-100 hover:bg-rose-500 hover:text-white lg:opacity-0 lg:group-hover:opacity-100"
                title="Delete session"
              >
                <MdDelete size={17} />
              </button>
            </div>
          </div>
        ))
      )}
    </div>
  </div>
);

export default CodeDebug;
