import { useState, useEffect, useRef, useCallback } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Cookies from 'js-cookie';
import { jwtDecode } from 'jwt-decode';
import api from './services/api';
import ToastProvider from './components/ToastProvider';
import Login from './components/Login';
import Navbar from './components/Navbar';
import ChatHistory from './components/ChatHistory';
import MessageBar from './components/MessageBar';
import ProgressDashboard from './components/ProgressDashboard';
import SubjectSelector from './components/SubjectSelector';
import CodeDebug from './components/CodeDebug';
import HistoryPanel from './components/HistoryPanel';
import QuizSystem from './components/QuizSystem';
import QuizHistory from './components/QuizHistory';
import QuizAnalytics from './components/QuizAnalytics';
import ProfileScreen from './components/ProfileScreen';
import { toast } from 'react-toastify';
import { PenSquare, Search, MessageCircle, UserPlus, MoreHorizontal, Moon, Sun, LogOut } from 'lucide-react';
import { useTheme } from './shared/theme/ThemeProvider';

// Protected Route Component for logged-in users
const ProtectedRoute = ({ children, isLoggedIn }) => {
  if (isLoggedIn) {
    return <Navigate to="/" replace />;
  }
  return children;
};

function App() {
  const normalizeSubject = (subject) => {
    const value = String(subject || '').trim().toLowerCase();
    if (!value || value === 'general' || value === 'code tutor') {
      return 'coding';
    }
    return value;
  };

  const { theme, toggleTheme } = useTheme();
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [loading, setLoading] = useState(true);
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [showSubjectModal, setShowSubjectModal] = useState(false);
  const [showProgressModal, setShowProgressModal] = useState(false);
  const [showHistoryPanel, setShowHistoryPanel] = useState(false);
  const [userProfile, setUserProfile] = useState(null);
  const [currentView, setCurrentView] = useState('chat');
  const [currentSessionId, setCurrentSessionId] = useState(null);
  const [sessionName, setSessionName] = useState('New Chat');
  const [responseLoading, setResponseLoading] = useState(false);
  const [currentSubject, setCurrentSubject] = useState('coding'); // Chat ka subject
  const [userPreferredSubject, setUserPreferredSubject] = useState('coding'); // User ka default subject (for recommendations)
  const [page, setPage] = useState(1);
  const [isInitialLoad, setIsInitialLoad] = useState(true);
  const [subjectModalContext, setSubjectModalContext] = useState('chat'); // 'chat' or 'recommendation'
  const chatContainerRef = useRef(null);

  useEffect(() => {
    const checkAuth = async () => {
      const token = Cookies.get('token');
      try {
        if (token) {
          const decoded = jwtDecode(token);
          if (decoded.exp * 1000 > Date.now()) {
            setIsLoggedIn(true);
            api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
            const userRes = await api.get('/api/auth/me');
            const userSubject = normalizeSubject(userRes.data.current_subject || 'coding');
            setUserProfile(userRes.data);
            setUserPreferredSubject(userSubject); // User ka preferred subject
            setCurrentSubject(userSubject); // Initial chat subject bhi same
            
            const userId = decoded.sub;
            const stored = JSON.parse(localStorage.getItem(`appState_${userId}`) || '{}');
            if (stored.sessionId) {
              setCurrentSessionId(stored.sessionId);
              setCurrentSubject(normalizeSubject(stored.subject || userSubject));
              // Load messages on initial mount only
              const loaded = await loadMessages(stored.sessionId, 1);
              if (!loaded) {
                startNewChat();
              } else {
                setIsInitialLoad(false);
              }
            }
          } else {
            clearLocalStorage();
            toast.warning('Session expired. Please login again.');
          }
        }
      } catch (err) {
        clearLocalStorage();
        toast.error('Auth check failed. Please login again.');
      } finally {
        setLoading(false);
      }
    };
    checkAuth();
  }, []);

  useEffect(() => {
    const fetchUserProfile = async () => {
      if (!isLoggedIn || userProfile) return;

      try {
        const userRes = await api.get('/api/auth/me');
        setUserProfile(userRes.data);
        if (userRes.data.current_subject) {
          setUserPreferredSubject(userRes.data.current_subject);
        }
      } catch {
        // No-op: auth interceptor handles invalid session
      }
    };

    fetchUserProfile();
  }, [isLoggedIn, userProfile]);

  useEffect(() => {
    // Only load messages for pagination, not on initial session load
    if (currentSessionId && !isInitialLoad && page > 1) {
      loadMessages(currentSessionId, page);
    }
  }, [page]);

  useEffect(() => {
    let scrollTimeout;
    const handleScroll = () => {
      // Throttle scroll event to prevent performance issues
      if (scrollTimeout) return;
      scrollTimeout = setTimeout(() => {
        scrollTimeout = null;
        if (chatContainerRef.current && chatContainerRef.current.scrollTop === 0 && messages.length >= 10) {
          setPage(prev => prev + 1);
        }
      }, 200); // Throttle to 200ms
    };
    
    const container = chatContainerRef.current;
    if (container) {
      container.addEventListener('scroll', handleScroll, { passive: true });
    }
    return () => {
      if (scrollTimeout) clearTimeout(scrollTimeout);
      container?.removeEventListener('scroll', handleScroll);
    };
  }, [messages.length]); // Only depend on length, not entire messages array

  const loadMessages = async (sessionId, newPage = 1) => {
    try {
      const res = await api.get(`/api/sessions/messages/${sessionId}`, { params: { page: newPage, limit: 10 } });
      
      if (res.data.length === 0 && newPage === 1) return false;
      
      const newMsgs = res.data.reverse();
      setMessages(prev => newPage > 1 ? [...newMsgs, ...prev] : newMsgs);
      
      const sessionRes = await api.get(`/api/sessions/${sessionId}`);
      const sessionName = sessionRes.data.name || 'New Chat';
      const sessionSubject = normalizeSubject(sessionRes.data.subject || currentSubject);
      
      setSessionName(sessionName);
      setCurrentSubject(sessionSubject);
      
      // Only persist on initial page load, not pagination
      if (newPage === 1) {
        persistData(sessionId, sessionSubject);
      }
      return true;
    } catch (err) {
      toast.error('Messages Load Error: ' + (err.response?.data?.detail || err.message));
      return false;
    }
  };

  const sendMessage = useCallback(async (text) => {
    if (!text) return;
    setResponseLoading(true);
    setIsInitialLoad(false); // Mark as no longer initial load after first message
    try {
      setMessages(prev => [...prev, { role: 'user', content: text }]);
      // Scroll to bottom after rendering the new user message
      requestAnimationFrame(() => {
        if (chatContainerRef.current) {
          chatContainerRef.current.scrollTop = chatContainerRef.current.scrollHeight;
        }
      });
      let sessionId = currentSessionId;
      if (!sessionId) {
        const createRes = await api.post('/api/sessions/create', { subject: normalizeSubject(currentSubject) });
        sessionId = createRes.data.session_id;
        setCurrentSessionId(sessionId);
      }
      const res = await api.post('/api/sessions/add-message', { session_id: sessionId, prompt: text });
      setMessages(prev => [...prev, { role: 'assistant', content: res.data.response }]);
      
      // Check if response indicates quota exceeded and show toast
      if (res.data.response.includes('high demand') || res.data.response.includes('quota exceeded')) {
        toast.info('API quota exceeded. You\'re getting helpful fallback responses from our knowledge base!');
      }
      
      // Ensure view stays at the bottom when assistant responds
      requestAnimationFrame(() => {
        if (chatContainerRef.current) {
          chatContainerRef.current.scrollTop = chatContainerRef.current.scrollHeight;
        }
      });
      if (sessionName === 'New Chat') {
        setSessionName(res.data.session_name || 'Chat Session');
      }
      const sessionRes = await api.get(`/api/sessions/${sessionId}`);
      setCurrentSubject(normalizeSubject(sessionRes.data.subject));
      
      // Persist the sessionId explicitly (important for new chats)
      persistData(sessionId, normalizeSubject(sessionRes.data.subject));
    } catch (err) {
      toast.error('Chat Error: ' + (err.response?.data?.detail || err.message));
      // If session was created, persist it even on error
      if (sessionId) {
        persistData(sessionId, currentSubject);
      }
    } finally {
      setResponseLoading(false);
    }
  }, [currentSubject, currentSessionId, sessionName]);

  const persistData = (sessionId = null, subject = null) => {
    const token = Cookies.get('token');
    if (token) {
      const userId = jwtDecode(token).sub;
      localStorage.setItem(`appState_${userId}`, JSON.stringify({
        sessionId: sessionId || currentSessionId,
        subject: subject || currentSubject,
      }));
    }
  };

  const clearLocalStorage = () => {
    try {
      const token = Cookies.get('token');
      if (token) {
        const userId = jwtDecode(token).sub;
        localStorage.removeItem(`appState_${userId}`);
      } else {
        localStorage.clear();
      }
    } catch (e) {
      localStorage.clear();
    }
    setMessages([]);
    setCurrentSessionId(null);
    setCurrentSubject('coding');
    setSessionName('New Chat');
    setUserProfile(null);
    setPage(1);
    setIsInitialLoad(true);
  };

  const refreshUserProfile = async () => {
    try {
      const userRes = await api.get('/api/auth/me');
      setUserProfile(userRes.data);
      const userSubject = normalizeSubject(userRes.data.current_subject || 'coding');
      setUserPreferredSubject(userSubject);
      toast.success('Profile refreshed.');
    } catch (err) {
      toast.error('Could not refresh profile: ' + (err.response?.data?.detail || err.message));
    }
  };

  const startNewChat = async () => {
    setMessages([]);
    setCurrentSessionId(null);
    setSessionName('New Chat');
    setPage(1);
    setIsInitialLoad(true);
    setCurrentSubject('coding');
    persistData(null, 'coding');
  };

  const updateCurrentSubject = (newSubject) => {
    setCurrentSubject(normalizeSubject(newSubject));
    // Pass the newSubject explicitly to avoid state update delay
    persistData(currentSessionId, newSubject);
  };

  const updateUserPreferredSubject = (newSubject) => {
    setUserPreferredSubject(newSubject);
    // Don't affect current chat subject
  };

  const handleLogout = () => {
    Cookies.remove('token');
    setIsLoggedIn(false);
    clearLocalStorage();
    toast.info('Logged out successfully!');
  };

  const handleEditMessage = useCallback(async (index, newContent) => {
    // Truncate messages after the edited message (remove old response)
    setMessages(prev => prev.slice(0, index));
    
    // Re-send the message to get a new response (GPT-like behavior)
    // sendMessage will add the message itself, so no need to add here
    await sendMessage(newContent);
  }, [sendMessage]);

  const quickPrompts = [
    'Debug my Python code and explain simply',
    'Create a short quiz from this topic',
    'Write clean version of this function',
  ];

  const handleQuickPrompt = (prompt) => {
    setInput(prompt);
  };

  if (loading) {
    return (
      <div className="h-screen theme-bg theme-text flex items-center justify-center p-4">
        <div className="theme-surface theme-border border rounded-2xl px-8 py-10 shadow-sm text-center max-w-md w-full">
          <div className="w-12 h-12 mx-auto mb-4 rounded-full border-4 border-blue-200 border-t-blue-500 animate-spin"></div>
          <p className="text-lg font-semibold">Preparing your workspace</p>
          <p className="text-sm theme-muted mt-2">Checking your session and loading chat context.</p>
        </div>
      </div>
    );
  }

  return (
    <Router>
      <Routes>
        <Route path="/login" element={
          <ProtectedRoute isLoggedIn={isLoggedIn}>
            <Login setIsLoggedIn={setIsLoggedIn} clearLocalStorage={clearLocalStorage} />
          </ProtectedRoute>
        } />
        <Route path="/" element={isLoggedIn ? (
          <div className="h-screen theme-bg theme-text flex flex-col transition-colors duration-200">
            {currentView !== 'chat' && (
              <Navbar
                setCurrentView={setCurrentView}
                setShowSubjectModal={setShowSubjectModal}
                setIsLoggedIn={setIsLoggedIn}
                setShowProgressModal={setShowProgressModal}
                setShowHistoryPanel={setShowHistoryPanel}
                startNewChat={startNewChat}
                currentView={currentView}
                userProfile={userProfile}
                setSubjectModalContext={setSubjectModalContext}
              />
            )}

            {/* Main Content */}
            <div className={`flex-1 flex min-h-0 ${currentView === 'chat' ? '' : 'flex-col px-3 lg:px-6 pb-3 lg:pb-6'}`}>
              {showHistoryPanel && (
                <HistoryPanel 
                  setCurrentSessionId={setCurrentSessionId} 
                  setShowHistoryPanel={setShowHistoryPanel} 
                  currentSessionId={currentSessionId}
                  setCurrentView={setCurrentView}
                  loadSessionMessages={async (sessionId) => {
                    setIsInitialLoad(true);
                    setPage(1);
                    setCurrentSessionId(sessionId);
                    const loaded = await loadMessages(sessionId, 1);
                    if (loaded) {
                      setIsInitialLoad(false);
                      // persistData already called in loadMessages
                    }
                    return loaded;
                  }}
                />
              )}
              
              {currentView === 'chat' && (
                <div className="w-full h-full flex min-h-0">
                  <aside className="hidden md:flex w-16 border-r theme-border theme-surface flex-col items-center py-3 gap-2">
                    <button onClick={startNewChat} className="w-10 h-10 rounded-xl theme-surface-soft theme-border border flex items-center justify-center hover:opacity-80" title="New chat">
                      <PenSquare size={18} />
                    </button>
                    <button onClick={() => setShowHistoryPanel(true)} className="w-10 h-10 rounded-xl theme-surface-soft theme-border border flex items-center justify-center hover:opacity-80" title="Search history">
                      <Search size={18} />
                    </button>
                    <button onClick={() => setShowHistoryPanel(true)} className="w-10 h-10 rounded-xl theme-surface-soft theme-border border flex items-center justify-center hover:opacity-80" title="Messages">
                      <MessageCircle size={18} />
                    </button>
                    <div className="mt-auto mb-1 w-9 h-9 rounded-full theme-surface-soft theme-border border flex items-center justify-center text-xs font-semibold">
                      {(userProfile?.username || 'U').charAt(0).toUpperCase()}
                    </div>
                  </aside>

                  <div className="flex-1 min-h-0 flex flex-col">
                    <div className="h-14 border-b theme-border flex items-center justify-between px-4 lg:px-6 theme-surface">
                      <div className="flex items-center gap-2">
                        <span className="text-lg font-semibold">Code Mentor</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <button
                          onClick={toggleTheme}
                          className="w-9 h-9 rounded-full theme-surface-soft theme-border border flex items-center justify-center hover:opacity-85"
                          title="Toggle theme"
                        >
                          {theme === 'dark' ? <Sun size={16} /> : <Moon size={16} />}
                        </button>
                        <button
                          onClick={handleLogout}
                          className="w-9 h-9 rounded-full theme-surface-soft theme-border border flex items-center justify-center hover:opacity-85 text-rose-500"
                          title="Logout"
                        >
                          <LogOut size={16} />
                        </button>
                        <button className="w-9 h-9 rounded-full theme-surface-soft theme-border border flex items-center justify-center hover:opacity-85" title="Invite">
                          <UserPlus size={16} />
                        </button>
                        <button className="w-9 h-9 rounded-full theme-surface-soft theme-border border flex items-center justify-center hover:opacity-85" title="More">
                          <MoreHorizontal size={16} />
                        </button>
                      </div>
                    </div>

                    <div className="h-12 border-b theme-border theme-surface overflow-x-auto custom-scroll">
                      <div className="h-full min-w-max px-3 lg:px-4 flex items-center gap-2">
                        <button
                          onClick={startNewChat}
                          className="px-3 py-1.5 rounded-full text-xs font-medium theme-surface-soft theme-border border hover:opacity-85"
                        >
                          New Chat
                        </button>
                        <button
                          onClick={() => setCurrentView('chat')}
                          className={`px-3 py-1.5 rounded-full text-xs font-medium ${currentView === 'chat' ? 'bg-blue-600 text-white' : 'theme-surface-soft theme-border border hover:opacity-85'}`}
                        >
                          Chat
                        </button>
                        <button
                          onClick={() => setShowHistoryPanel(true)}
                          className="px-3 py-1.5 rounded-full text-xs font-medium theme-surface-soft theme-border border hover:opacity-85"
                        >
                          Search Chat
                        </button>
                        <button
                          onClick={() => { setSubjectModalContext('chat'); setShowSubjectModal(true); }}
                          className="px-3 py-1.5 rounded-full text-xs font-medium theme-surface-soft theme-border border hover:opacity-85"
                        >
                          Subject
                        </button>
                        <button
                          onClick={() => setCurrentView('quiz')}
                          className="px-3 py-1.5 rounded-full text-xs font-medium theme-surface-soft theme-border border hover:opacity-85"
                        >
                          Quiz
                        </button>
                        <button
                          onClick={() => setCurrentView('quiz-history')}
                          className="px-3 py-1.5 rounded-full text-xs font-medium theme-surface-soft theme-border border hover:opacity-85"
                        >
                          Quiz History
                        </button>
                        <button
                          onClick={() => setCurrentView('quiz-analytics')}
                          className="px-3 py-1.5 rounded-full text-xs font-medium theme-surface-soft theme-border border hover:opacity-85"
                        >
                          Quiz Analytics
                        </button>
                        <button
                          onClick={() => setCurrentView('code')}
                          className="px-3 py-1.5 rounded-full text-xs font-medium theme-surface-soft theme-border border hover:opacity-85"
                        >
                          Code Debug
                        </button>
                        <button
                          onClick={() => setCurrentView('profile')}
                          className="px-3 py-1.5 rounded-full text-xs font-medium theme-surface-soft theme-border border hover:opacity-85"
                        >
                          Profile
                        </button>
                        <button
                          onClick={() => setShowProgressModal(true)}
                          className="px-3 py-1.5 rounded-full text-xs font-medium theme-surface-soft theme-border border hover:opacity-85"
                        >
                          Progress
                        </button>
                      </div>
                    </div>

                    <div ref={chatContainerRef} className="flex-1 overflow-y-auto custom-scroll" style={{ contain: 'layout style paint' }}>
                      <div className="max-w-4xl mx-auto w-full px-4 py-8 space-y-6">
                        {messages.length === 0 ? (
                          <div className="min-h-[46vh] flex flex-col items-center justify-center">
                            <h2 className="text-4xl font-medium tracking-tight text-center">What can I help with?</h2>
                            <div className="w-full max-w-3xl mt-8">
                              <MessageBar input={input} setInput={setInput} sendMessage={sendMessage} />
                              <div className="mt-5 flex items-center justify-center gap-2 flex-wrap">
                                {quickPrompts.map((prompt) => (
                                  <button
                                    key={prompt}
                                    onClick={() => handleQuickPrompt(prompt)}
                                    className="px-4 py-2 rounded-full theme-surface theme-border border text-sm hover:opacity-85"
                                  >
                                    {prompt}
                                  </button>
                                ))}
                              </div>
                            </div>
                          </div>
                        ) : (
                          <>
                            <ChatHistory 
                              messages={messages} 
                              onEditMessage={handleEditMessage}
                            />
                            {responseLoading && (
                              <div className="flex items-center space-x-3 px-2 py-1 theme-muted">
                                <div className="min-w-[24px] h-6 rounded-md theme-surface-soft flex items-center justify-center shrink-0 text-xs">AI</div>
                                <div className="text-sm">Thinking<span className="dots"></span></div>
                              </div>
                            )}
                          </>
                        )}
                      </div>
                    </div>

                    {messages.length > 0 && (
                      <div className="px-4 pb-4 lg:pb-6 border-t theme-border theme-surface">
                        <div className="max-w-3xl mx-auto w-full pt-3">
                          <MessageBar input={input} setInput={setInput} sendMessage={sendMessage} />
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              )}
              {currentView === 'code' && <CodeDebug />}
              {currentView === 'quiz' && <QuizSystem setCurrentView={setCurrentView} />}
              {currentView === 'quiz-history' && <QuizHistory setCurrentView={setCurrentView} />}
              {currentView === 'quiz-analytics' && <QuizAnalytics setCurrentView={setCurrentView} />}
              {currentView === 'profile' && (
                <ProfileScreen
                  userProfile={userProfile}
                  userPreferredSubject={userPreferredSubject}
                  currentSubject={currentSubject}
                  onRefreshProfile={refreshUserProfile}
                />
              )}
            </div>
            
            {showSubjectModal && (
              <SubjectSelector 
                setShowSubjectModal={setShowSubjectModal} 
                updateCurrentSubject={subjectModalContext === 'chat' ? updateCurrentSubject : updateUserPreferredSubject}
                context={subjectModalContext}
                onSubjectChange={(newSubject) => {
                  if (subjectModalContext === 'chat') {
                    // Update chat subject
                    setCurrentSubject(newSubject);
                  } else {
                    // Update recommendation subject only
                    setUserPreferredSubject(newSubject);
                  }
                }}
                onModalClose={() => {
                  // When modal is closed without selecting
                    if (subjectModalContext === 'chat' && !currentSubject) {
                    toast.info('Please select a subject to start chatting');
                  }
                }}
              />
            )}
            {showProgressModal && <ProgressDashboard setShowProgressModal={setShowProgressModal} setCurrentView={setCurrentView} userPreferredSubject={userPreferredSubject} />}
            <ToastProvider />
          </div>
        ) : <Navigate to="/login" />} />
      </Routes>
    </Router>
  );
}

export default App;
