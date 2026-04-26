import { useState } from 'react';
import {
  MdAdd,
  MdBarChart,
  MdCode,
  MdDarkMode,
  MdHistory,
  MdLightMode,
  MdLogout,
  MdMenuBook,
  MdMessage,
  MdMoreHoriz,
  MdPerson,
  MdPersonAdd,
  MdQuiz,
  MdSearch,
} from 'react-icons/md';
import Cookies from 'js-cookie';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import { useTheme } from '../shared/theme/ThemeProvider';

const Navbar = ({
  setCurrentView,
  setShowSubjectModal,
  setIsLoggedIn,
  setShowProgressModal,
  setShowHistoryPanel,
  startNewChat,
  currentView,
  setSubjectModalContext,
  userProfile,
}) => {
  const navigate = useNavigate();
  const { theme, toggleTheme } = useTheme();
  const [activeNavItem, setActiveNavItem] = useState(currentView);
  const handleLogout = () => {
    Cookies.remove('token');
    setIsLoggedIn(false);
    toast.info('Logged out successfully!');
    navigate('/login');
  };

  const handleNavClick = (item) => {
    setActiveNavItem(item.id);
    item.action();
  };

  const navItems = [
    { id: 'chat', icon: MdMessage, label: 'Chat', action: () => setCurrentView('chat') },
    { id: 'history', icon: MdSearch, label: 'Search Chat', action: () => setShowHistoryPanel(true) },
    { id: 'subject', icon: MdMenuBook, label: 'Subject', action: () => { setSubjectModalContext('chat'); setShowSubjectModal(true); } },
    { id: 'quiz-history', icon: MdHistory, label: 'Quiz History', action: () => setCurrentView('quiz-history') },
    { id: 'quiz-analytics', icon: MdBarChart, label: 'Quiz Analytics', action: () => setCurrentView('quiz-analytics') },
    { id: 'code', icon: MdCode, label: 'Code Debug', action: () => setCurrentView('code') },
    { id: 'profile', icon: MdPerson, label: 'Profile', action: () => setCurrentView('profile') },
    { id: 'progress', icon: MdBarChart, label: 'Progress', action: () => setShowProgressModal(true) },
  ];

  return (
    <nav className="sticky top-0 z-40 theme-surface/95 theme-border border-b backdrop-blur-xl shadow-sm">
      <div className="h-14 border-b theme-border flex items-center justify-between px-4 lg:px-6 theme-surface">
        <div className="flex items-center gap-2 min-w-0">
          <span className="text-lg font-semibold truncate">Code Mentor</span>
          {userProfile?.username && (
            <span className="hidden sm:inline text-xs theme-muted truncate">
              @{userProfile.username.toLowerCase().replace(/\s+/g, '_')}
            </span>
          )}
        </div>

        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={toggleTheme}
            className="w-9 h-9 rounded-full theme-surface-soft theme-border border flex items-center justify-center hover:opacity-85"
            title="Toggle theme"
            aria-label={`Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`}
          >
            {theme === 'dark' ? <MdLightMode size={16} /> : <MdDarkMode size={16} />}
          </button>
          <button
            type="button"
            onClick={handleLogout}
            className="w-9 h-9 rounded-full theme-surface-soft theme-border border flex items-center justify-center hover:opacity-85 text-rose-500"
            title="Logout"
            aria-label="Log out"
          >
            <MdLogout size={16} />
          </button>
          <button
            type="button"
            className="w-9 h-9 rounded-full theme-surface-soft theme-border border flex items-center justify-center hover:opacity-85"
            title="Invite"
            aria-label="Invite"
          >
            <MdPersonAdd size={16} />
          </button>
          <button
            type="button"
            className="w-9 h-9 rounded-full theme-surface-soft theme-border border flex items-center justify-center hover:opacity-85"
            title="More"
            aria-label="More"
          >
            <MdMoreHoriz size={16} />
          </button>
        </div>
      </div>

      <div className="h-12 border-b theme-border theme-surface overflow-x-auto custom-scroll">
        <div className="h-full min-w-max px-3 lg:px-4 flex items-center gap-2">
          <button
            type="button"
            onClick={startNewChat}
            className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium theme-surface-soft theme-border border hover:opacity-85"
          >
            <MdAdd size={15} />
            New Chat
          </button>

          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = currentView === item.id || activeNavItem === item.id;
            return (
              <button
                type="button"
                key={item.id}
                onClick={() => handleNavClick(item)}
                aria-label={item.label}
                className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium transition-all duration-200 ${
                  isActive
                    ? 'bg-blue-600 text-white'
                    : 'theme-surface-soft theme-border border hover:opacity-85'
                }`}
              >
                <Icon size={15} className="pointer-events-none" />
                <span className="pointer-events-none">{item.label}</span>
              </button>
            );
          })}
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
