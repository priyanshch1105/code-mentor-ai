import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  MdAccessTime,
  MdBarChart,
  MdCalculate,
  MdCalendarToday,
  MdClose,
  MdCode,
  MdEdit,
  MdMenuBook,
  MdMessage,
  MdRefresh,
  MdScience,
  MdSearch,
  MdSort,
} from 'react-icons/md';
import { toast } from 'react-toastify';
import api from '../services/api';
import { formatRelativeTime, formatTime } from '../utils/timeUtils';

const HistoryPanel = ({
  setCurrentSessionId,
  setShowHistoryPanel,
  currentSessionId,
  setCurrentView,
  loadSessionMessages,
}) => {
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [loadingSession, setLoadingSession] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedSubject, setSelectedSubject] = useState('all');
  const [sortOrder, setSortOrder] = useState('newest');

  const formatDate = (dateString) => formatRelativeTime(dateString);

  const fetchSessions = useCallback(async (showToast = false) => {
    try {
      setLoading(true);
      setError(null);
      const res = await api.get('/api/sessions/list');
      const data = Array.isArray(res.data) ? res.data : [];
      setSessions(data);
      if (showToast) {
        toast.success('History refreshed');
      }
    } catch (err) {
      setError('Failed to load history');
      toast.error('History Fetch Error: ' + (err.response?.data?.detail || err.message));
      setSessions([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchSessions();
  }, [fetchSessions]);

  const subjects = useMemo(() => {
    const uniqueSubjects = [...new Set(sessions.map((session) => session.subject).filter(Boolean))];
    return ['all', ...uniqueSubjects];
  }, [sessions]);

  const filteredSessions = useMemo(() => {
    const query = searchTerm.trim().toLowerCase();

    return sessions
      .filter((session) => {
        const matchesSearch = !query || [
          session.name,
          session.subject,
          formatDate(session.created_at),
          formatTime(session.created_at),
        ].some((value) => String(value || '').toLowerCase().includes(query));
        const matchesSubject = selectedSubject === 'all' || session.subject === selectedSubject;

        return matchesSearch && matchesSubject;
      })
      .sort((a, b) => {
        const first = new Date(a.created_at).getTime();
        const second = new Date(b.created_at).getTime();
        return sortOrder === 'newest' ? second - first : first - second;
      });
  }, [sessions, searchTerm, selectedSubject, sortOrder]);

  const loadSession = async (id) => {
    try {
      setLoadingSession(id);
      setCurrentSessionId(id);
      setCurrentView('chat');

      if (loadSessionMessages) {
        const loaded = await loadSessionMessages(id);
        if (loaded) {
          setShowHistoryPanel(false);
          toast.success('Session loaded');
        } else {
          toast.error('No messages found in this session');
        }
      } else {
        setShowHistoryPanel(false);
        toast.success('Session loaded');
      }
    } catch (err) {
      toast.error('Failed to load session: ' + (err.message || 'Unknown error'));
    } finally {
      setLoadingSession(null);
    }
  };

  const handleSessionKeyDown = (event, id) => {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      if (!loadingSession) {
        loadSession(id);
      }
    }
  };

  const getSubjectIcon = (subject) => {
    switch (subject) {
      case 'coding': return <MdCode className="text-green-400" />;
      case 'math': return <MdCalculate className="text-blue-400" />;
      case 'ielts': return <MdEdit className="text-purple-400" />;
      case 'physics': return <MdScience className="text-orange-400" />;
      default: return <MdMenuBook className="text-gray-400" />;
    }
  };

  const getSubjectColor = (subject) => {
    switch (subject) {
      case 'coding': return 'from-green-500 to-green-600';
      case 'math': return 'from-blue-500 to-blue-600';
      case 'ielts': return 'from-purple-500 to-purple-600';
      case 'physics': return 'from-orange-500 to-orange-600';
      default: return 'from-gray-500 to-gray-600';
    }
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/45 backdrop-blur-sm lg:bg-black/20">
      <div
        className="absolute inset-0"
        onClick={() => setShowHistoryPanel(false)}
        aria-hidden="true"
      />

      <aside className="absolute right-0 top-0 h-full w-full max-w-md theme-surface theme-text theme-border border-l shadow-2xl">
        <div className="flex h-full flex-col p-4 lg:p-5">
          <div className="flex items-center justify-between gap-3">
            <div className="flex items-center min-w-0">
              <MdMessage className="w-6 h-6 text-blue-500 mr-3 shrink-0" />
              <div className="min-w-0">
                <h3 className="text-xl font-bold truncate">Chat History</h3>
                <p className="text-xs theme-muted">
                  {filteredSessions.length} of {sessions.length} sessions
                </p>
              </div>
            </div>

            <div className="flex items-center gap-2 shrink-0">
              <button
                type="button"
                onClick={() => fetchSessions(true)}
                className="p-2 rounded-lg theme-surface-soft theme-border border hover:opacity-85"
                aria-label="Refresh chat history"
                title="Refresh"
              >
                <MdRefresh size={20} className={loading ? 'animate-spin' : ''} />
              </button>
              <button
                type="button"
                onClick={() => setShowHistoryPanel(false)}
                className="p-2 rounded-lg theme-surface-soft theme-border border hover:opacity-85"
                aria-label="Close chat history"
                title="Close"
              >
                <MdClose size={20} />
              </button>
            </div>
          </div>

          <div className="mt-5 grid grid-cols-2 gap-2">
            <div className="rounded-lg theme-surface-soft theme-border border p-3">
              <div className="flex items-center justify-between">
                <div>
                  <p className="theme-muted text-xs font-medium">Total Sessions</p>
                  <p className="text-2xl font-bold">{sessions.length}</p>
                </div>
                <MdMenuBook className="w-7 h-7 text-blue-500" />
              </div>
            </div>
            <div className="rounded-lg theme-surface-soft theme-border border p-3">
              <div className="flex items-center justify-between">
                <div>
                  <p className="theme-muted text-xs font-medium">Subjects</p>
                  <p className="text-2xl font-bold">{Math.max(subjects.length - 1, 0)}</p>
                </div>
                <MdBarChart className="w-7 h-7 text-purple-500" />
              </div>
            </div>
          </div>

          <div className="mt-4 space-y-3">
            <label className="flex items-center gap-2 rounded-lg theme-surface-soft theme-border border px-3 py-2">
              <MdSearch size={18} className="theme-muted shrink-0" />
              <input
                value={searchTerm}
                onChange={(event) => setSearchTerm(event.target.value)}
                placeholder="Search sessions"
                className="w-full bg-transparent text-sm outline-none placeholder:opacity-70"
              />
            </label>

            <div className="flex items-center gap-2 overflow-x-auto custom-scroll pb-1">
              {subjects.map((subject) => (
                <button
                  type="button"
                  key={subject}
                  onClick={() => setSelectedSubject(subject)}
                  className={`inline-flex cursor-pointer items-center gap-1.5 whitespace-nowrap rounded-lg px-3 py-1.5 text-xs font-semibold transition ${
                    selectedSubject === subject
                      ? 'bg-blue-600 text-white'
                      : 'theme-surface-soft theme-border border hover:opacity-85'
                  }`}
                >
                  {subject === 'all' ? <MdMenuBook size={14} /> : getSubjectIcon(subject)}
                  {subject === 'all' ? 'All' : subject}
                </button>
              ))}
            </div>

            <button
              type="button"
              onClick={() => setSortOrder((current) => current === 'newest' ? 'oldest' : 'newest')}
              className="inline-flex cursor-pointer items-center gap-2 rounded-lg theme-surface-soft theme-border border px-3 py-2 text-xs font-semibold hover:opacity-85"
            >
              <MdSort size={16} />
              {sortOrder === 'newest' ? 'Newest first' : 'Oldest first'}
            </button>
          </div>

          <div className="mt-4 flex-1 space-y-3 overflow-y-auto pr-1 custom-scroll">
            {loading && (
              <div className="flex items-center justify-center py-10">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
                <span className="ml-3 theme-muted">Loading sessions...</span>
              </div>
            )}

            {error && (
              <div className="p-4 bg-red-600/10 border border-red-500/30 rounded-lg">
                <p className="text-red-400 text-sm">{error}</p>
                <button
                  type="button"
                  onClick={() => fetchSessions(true)}
                  className="mt-3 rounded-lg bg-red-500 px-3 py-1.5 text-xs font-semibold text-white"
                >
                  Try again
                </button>
              </div>
            )}

            {!loading && !error && sessions.length === 0 ? (
              <div className="text-center py-8">
                <MdMessage className="mx-auto h-12 w-12 theme-muted" />
                <p className="theme-muted text-lg mt-4 mb-2">No sessions yet</p>
                <p className="theme-muted text-sm">Start chatting to create your first session.</p>
              </div>
            ) : !loading && !error && filteredSessions.length === 0 ? (
              <div className="text-center py-8">
                <MdSearch className="mx-auto h-12 w-12 theme-muted" />
                <p className="theme-muted text-lg mt-4 mb-2">No matching sessions</p>
                <button
                  type="button"
                  onClick={() => {
                    setSearchTerm('');
                    setSelectedSubject('all');
                  }}
                  className="rounded-lg bg-blue-600 px-3 py-1.5 text-xs font-semibold text-white"
                >
                  Clear filters
                </button>
              </div>
            ) : (
              filteredSessions.map((session) => (
                <div
                  key={session.id}
                  role="button"
                  tabIndex={0}
                  onClick={() => !loadingSession && loadSession(session.id)}
                  onKeyDown={(event) => handleSessionKeyDown(event, session.id)}
                  className={`cursor-pointer p-3 lg:p-4 rounded-lg border transition-all duration-200 hover:shadow-lg focus:outline-none focus:ring-2 focus:ring-blue-400 ${
                    loadingSession === session.id
                      ? 'theme-surface-soft theme-border opacity-70 cursor-wait'
                      : session.id === currentSessionId
                        ? 'bg-blue-600 border-blue-400 text-white shadow-lg'
                        : 'theme-surface-soft theme-border hover:opacity-90'
                  }`}
                >
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex items-center flex-1 min-w-0">
                      <div className="mr-3 flex-shrink-0">
                        {getSubjectIcon(session.subject)}
                      </div>
                      <div className="flex-1 min-w-0">
                        <h4 className="font-semibold text-sm lg:text-base truncate" title={session.name || 'Untitled'}>
                          {session.name || 'Untitled Session'}
                        </h4>
                        <div className={`flex items-center text-xs mt-1 ${session.id === currentSessionId ? 'text-blue-100' : 'theme-muted'}`}>
                          <MdCalendarToday size={12} className="mr-1 flex-shrink-0" />
                          <span className="truncate">{formatDate(session.created_at)}</span>
                        </div>
                      </div>
                    </div>
                    <div className={`px-2 py-1 rounded-full text-xs font-medium bg-gradient-to-r ${getSubjectColor(session.subject)} text-white flex-shrink-0 ml-2`}>
                      {session.subject || 'general'}
                    </div>
                  </div>

                  <div className="flex items-center justify-between text-xs">
                    <div className={`flex items-center ${session.id === currentSessionId ? 'text-blue-100' : 'theme-muted'}`}>
                      <MdAccessTime size={12} className="mr-1" />
                      {formatTime(session.created_at)}
                    </div>
                    {loadingSession === session.id ? (
                      <div className="flex items-center theme-muted">
                        <div className="animate-spin rounded-full h-3 w-3 border-b-2 border-blue-400 mr-1"></div>
                        Loading...
                      </div>
                    ) : session.id === currentSessionId ? (
                      <div className="flex items-center text-blue-100">
                        <div className="w-2 h-2 bg-blue-100 rounded-full mr-1"></div>
                        Active
                      </div>
                    ) : (
                      <span className="theme-muted">Open</span>
                    )}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </aside>
    </div>
  );
};

export default HistoryPanel;
