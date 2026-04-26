import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import {
  MdAccessTime,
  MdBarChart,
  MdCheckCircle,
  MdClose,
  MdMenuBook,
  MdQuiz,
  MdRefresh,
  MdTrendingUp,
} from 'react-icons/md';
import api from '../services/api';
import { toast } from 'react-toastify';

const COLORS = ['#2563eb', '#059669', '#d97706', '#dc2626', '#7c3aed', '#0891b2'];

const emptyStats = {
  totalSessions: 0,
  averageScore: 0,
  streakDays: 0,
  completedTopics: 0,
  totalQuizzes: 0,
  quizAverageScore: 0,
};

const ProgressDashboard = ({ setShowProgressModal, setCurrentView, userPreferredSubject }) => {
  const [recommendations, setRecommendations] = useState('');
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [sessions, setSessions] = useState([]);
  const [stats, setStats] = useState(emptyStats);
  const [loadNote, setLoadNote] = useState('');

  const runApi = async (request, fallback) => {
    try {
      const response = await request();
      return response.data;
    } catch {
      return fallback;
    }
  };

  const fetchDashboardData = useCallback(async (showToast = false) => {
    try {
      setLoadNote('');
      setRefreshing(true);

      const recommendationParams =
        userPreferredSubject && userPreferredSubject !== 'general'
          ? { subject: userPreferredSubject }
          : {};

      const [progressData, recommendData, sessionsData, quizHistoryData] = await Promise.all([
        runApi(() => api.get('/api/recommend/progress'), { progress: {} }),
        runApi(() => api.get('/api/recommend/', { params: recommendationParams }), {
          recommendations: 'Start learning to get personalized recommendations.',
        }),
        runApi(() => api.get('/api/sessions/list'), []),
        runApi(() => api.get('/api/quiz/history'), { quiz_history: [] }),
      ]);

      const safeProgress = progressData?.progress || {};
      const safeSessions = Array.isArray(sessionsData) ? sessionsData : [];
      const quizHistory = Array.isArray(quizHistoryData?.quiz_history)
        ? quizHistoryData.quiz_history
        : [];

      const progressScores = Object.values(safeProgress)
        .map(Number)
        .filter((score) => Number.isFinite(score));
      const quizScores = quizHistory
        .map((quiz) => Number(quiz.percentage ?? quiz.score ?? 0))
        .filter((score) => Number.isFinite(score));

      const subjectSet = new Set(safeSessions.map((session) => session.subject).filter(Boolean));
      Object.keys(safeProgress).forEach((subject) => subjectSet.add(subject));

      const today = new Date();
      const activeDays = new Set(
        safeSessions
          .map((session) => new Date(session.created_at))
          .filter((date) => !Number.isNaN(date.getTime()))
          .filter((date) => (today - date) / 86400000 <= 7)
          .map((date) => date.toISOString().slice(0, 10))
      );

      setSessions(safeSessions);
      setRecommendations(recommendData?.recommendations || 'No recommendations available yet.');
      setStats({
        totalSessions: safeSessions.length,
        averageScore: progressScores.length
          ? Math.round(progressScores.reduce((sum, score) => sum + score, 0) / progressScores.length)
          : 0,
        streakDays: activeDays.size,
        completedTopics: subjectSet.size,
        totalQuizzes: quizHistory.length,
        quizAverageScore: quizScores.length
          ? Math.round(quizScores.reduce((sum, score) => sum + score, 0) / quizScores.length)
          : 0,
      });

      if (!safeSessions.length && !quizHistory.length && !progressScores.length) {
        setLoadNote('No learning activity found yet. Start a chat or quiz to populate this dashboard.');
      }

      if (showToast) {
        toast.success('Dashboard refreshed');
      }
    } catch (error) {
      setLoadNote('Some dashboard data could not be loaded. Please try refreshing.');
      toast.error('Failed to load dashboard data: ' + (error.response?.data?.detail || error.message));
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, [userPreferredSubject]);

  useEffect(() => {
    setLoading(true);
    fetchDashboardData();
  }, [fetchDashboardData]);

  const subjectCounts = useMemo(() => {
    return sessions.reduce((acc, session) => {
      const subject = session.subject || 'general';
      acc[subject] = (acc[subject] || 0) + 1;
      return acc;
    }, {});
  }, [sessions]);

  const chartData = useMemo(() => {
    return Object.entries(subjectCounts).map(([subject, count], index) => ({
      subject: subject.charAt(0).toUpperCase() + subject.slice(1),
      sessions: count,
      fill: COLORS[index % COLORS.length],
    }));
  }, [subjectCounts]);

  const pieData = useMemo(() => {
    return Object.entries(subjectCounts).map(([subject, count], index) => ({
      name: subject.charAt(0).toUpperCase() + subject.slice(1),
      value: count,
      fill: COLORS[index % COLORS.length],
    }));
  }, [subjectCounts]);

  const closeDashboard = () => setShowProgressModal(false);

  const goToView = (view) => {
    setCurrentView(view);
    setShowProgressModal(false);
  };

  const statCards = [
    { label: 'Sessions', value: stats.totalSessions, icon: MdMenuBook, color: 'text-blue-500' },
    { label: 'Progress', value: `${stats.averageScore}%`, icon: MdBarChart, color: 'text-emerald-500' },
    { label: 'Active Days', value: stats.streakDays, icon: MdAccessTime, color: 'text-purple-500' },
    { label: 'Subjects', value: stats.completedTopics, icon: MdCheckCircle, color: 'text-amber-500' },
    { label: 'Quizzes', value: stats.totalQuizzes, icon: MdQuiz, color: 'text-cyan-500' },
    { label: 'Quiz Avg', value: `${stats.quizAverageScore}%`, icon: MdTrendingUp, color: 'text-rose-500' },
  ];

  return (
    <div className="fixed inset-0 z-[70] flex items-center justify-center bg-black/45 p-3 backdrop-blur-sm">
      <button
        type="button"
        className="absolute inset-0 cursor-default"
        onClick={closeDashboard}
        aria-label="Close dashboard"
      />

      <section className="relative flex max-h-[94vh] w-full max-w-6xl flex-col overflow-hidden rounded-xl theme-surface theme-text theme-border border shadow-2xl">
        <header className="flex items-center justify-between gap-3 border-b theme-border px-4 py-3 lg:px-6">
          <div className="flex min-w-0 items-center gap-3">
            <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-blue-600 text-white">
              <MdTrendingUp size={22} />
            </div>
            <div className="min-w-0">
              <h2 className="truncate text-lg font-bold lg:text-2xl">Learning Dashboard</h2>
              <p className="truncate text-xs theme-muted">
                {userPreferredSubject && userPreferredSubject !== 'general'
                  ? `Focus: ${userPreferredSubject}`
                  : 'Progress from chats, subjects, and quizzes'}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => fetchDashboardData(true)}
              disabled={refreshing}
              className="inline-flex cursor-pointer items-center gap-2 rounded-lg theme-surface-soft theme-border border px-3 py-2 text-sm font-semibold hover:opacity-85 disabled:opacity-60"
            >
              <MdRefresh className={refreshing ? 'animate-spin' : ''} size={18} />
              <span className="hidden sm:inline">Refresh</span>
            </button>
            <button
              type="button"
              onClick={closeDashboard}
              className="rounded-lg theme-surface-soft theme-border border p-2 hover:opacity-85"
              aria-label="Close dashboard"
            >
              <MdClose size={20} />
            </button>
          </div>
        </header>

        <div className="flex-1 overflow-y-auto custom-scroll p-4 lg:p-6">
          {loading ? (
            <div className="flex min-h-[420px] items-center justify-center">
              <div className="theme-surface-soft theme-border border rounded-xl px-8 py-7 text-center">
                <div className="mx-auto h-10 w-10 animate-spin rounded-full border-4 border-blue-200 border-t-blue-600"></div>
                <p className="mt-4 font-semibold">Loading dashboard...</p>
                <p className="mt-1 text-sm theme-muted">Gathering progress, sessions, and quiz activity.</p>
              </div>
            </div>
          ) : (
            <>
              {loadNote && (
                <div className="mb-4 rounded-lg border border-blue-500/30 bg-blue-500/10 px-4 py-3 text-sm text-blue-700 dark:text-blue-200">
                  {loadNote}
                </div>
              )}

              <div className="grid grid-cols-2 gap-3 lg:grid-cols-6">
                {statCards.map((card) => {
                  const Icon = card.icon;
                  return (
                    <div key={card.label} className="rounded-lg theme-surface-soft theme-border border p-3">
                      <div className="flex items-center justify-between gap-2">
                        <div className="min-w-0">
                          <p className="truncate text-xs font-medium theme-muted">{card.label}</p>
                          <p className="mt-1 text-xl font-bold">{card.value}</p>
                        </div>
                        <Icon className={`h-7 w-7 shrink-0 ${card.color}`} />
                      </div>
                    </div>
                  );
                })}
              </div>

              <div className="mt-5 grid grid-cols-1 gap-4 lg:grid-cols-2">
                <div className="rounded-lg theme-surface-soft theme-border border p-4">
                  <h3 className="mb-4 flex items-center gap-2 text-base font-semibold">
                    <MdCheckCircle className="text-emerald-500" />
                    Activity by Subject
                  </h3>
                  {chartData.length > 0 ? (
                    <div className="h-72 min-h-72">
                      <ResponsiveContainer width="100%" height="100%">
                        <BarChart data={chartData}>
                          <CartesianGrid strokeDasharray="3 3" stroke="rgba(148, 163, 184, 0.35)" />
                          <XAxis dataKey="subject" stroke="currentColor" tick={{ fontSize: 12 }} />
                          <YAxis stroke="currentColor" allowDecimals={false} tick={{ fontSize: 12 }} />
                          <Tooltip
                            formatter={(value) => [`${value} sessions`, 'Activity']}
                            contentStyle={{ borderRadius: '8px' }}
                          />
                          <Bar dataKey="sessions" radius={[6, 6, 0, 0]}>
                            {chartData.map((entry) => (
                              <Cell key={entry.subject} fill={entry.fill} />
                            ))}
                          </Bar>
                        </BarChart>
                      </ResponsiveContainer>
                    </div>
                  ) : (
                    <EmptyChart icon={MdMenuBook} title="No chat sessions yet" text="Start a chat to see subject activity here." />
                  )}
                </div>

                <div className="rounded-lg theme-surface-soft theme-border border p-4">
                  <h3 className="mb-4 flex items-center gap-2 text-base font-semibold">
                    <MdBarChart className="text-blue-500" />
                    Session Distribution
                  </h3>
                  {pieData.length > 0 ? (
                    <div className="h-72 min-h-72">
                      <ResponsiveContainer width="100%" height="100%">
                        <PieChart>
                          <Pie
                            data={pieData}
                            cx="50%"
                            cy="50%"
                            labelLine={false}
                            outerRadius="72%"
                            dataKey="value"
                            label={({ name, percent = 0 }) => `${name} ${(percent * 100).toFixed(0)}%`}
                          >
                            {pieData.map((entry) => (
                              <Cell key={entry.name} fill={entry.fill} />
                            ))}
                          </Pie>
                          <Tooltip formatter={(value) => [`${value} sessions`, 'Count']} />
                        </PieChart>
                      </ResponsiveContainer>
                    </div>
                  ) : (
                    <EmptyChart icon={MdBarChart} title="No distribution yet" text="Your session mix will appear after you chat." />
                  )}
                </div>
              </div>

              <div className="mt-5 rounded-lg theme-surface-soft theme-border border p-4">
                <div className="mb-2 flex flex-wrap items-center justify-between gap-2">
                  <h3 className="flex items-center gap-2 text-base font-semibold">
                    <MdTrendingUp className="text-blue-500" />
                    AI Recommendations
                  </h3>
                  {userPreferredSubject && userPreferredSubject !== 'general' && (
                    <span className="rounded-full bg-blue-600 px-3 py-1 text-xs font-semibold text-white">
                      Focus: {userPreferredSubject}
                    </span>
                  )}
                </div>
                <p className="whitespace-pre-line text-sm leading-6 theme-muted">{recommendations}</p>
              </div>

              <div className="mt-5 flex flex-wrap gap-3">
                <button
                  type="button"
                  onClick={() => goToView('quiz')}
                  className="inline-flex cursor-pointer items-center gap-2 rounded-lg bg-green-600 px-4 py-2 text-sm font-semibold text-white hover:bg-green-700"
                >
                  <MdQuiz size={18} />
                  Take Quiz
                </button>
                <button
                  type="button"
                  onClick={() => goToView('quiz-analytics')}
                  className="inline-flex cursor-pointer items-center gap-2 rounded-lg bg-purple-600 px-4 py-2 text-sm font-semibold text-white hover:bg-purple-700"
                >
                  <MdBarChart size={18} />
                  Quiz Analytics
                </button>
                <button
                  type="button"
                  onClick={() => goToView('chat')}
                  className="inline-flex cursor-pointer items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700"
                >
                  <MdMenuBook size={18} />
                  Continue Chat
                </button>
              </div>
            </>
          )}
        </div>
      </section>
    </div>
  );
};

const EmptyChart = ({ icon: Icon, title, text }) => (
  <div className="flex h-72 min-h-72 items-center justify-center text-center theme-muted">
    <div>
      <Icon className="mx-auto mb-3 h-12 w-12 opacity-70" />
      <p className="font-semibold">{title}</p>
      <p className="mt-1 text-sm">{text}</p>
    </div>
  </div>
);

export default ProgressDashboard;
