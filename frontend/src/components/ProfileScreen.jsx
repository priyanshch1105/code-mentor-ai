import { MdPerson, MdMail, MdSchool, MdPalette, MdRefresh } from 'react-icons/md';
import { useTheme } from '../shared/theme/ThemeProvider';

const ProfileScreen = ({ userProfile, userPreferredSubject, currentSubject, onRefreshProfile }) => {
  const { theme, toggleTheme } = useTheme();

  const username = userProfile?.username || 'Unknown User';
  const email = userProfile?.email || 'No email available';

  return (
    <div className="flex-1 theme-bg theme-text p-6 lg:p-10">
      <div className="max-w-3xl mx-auto space-y-6">
        <div className="theme-surface theme-border border rounded-2xl p-6 shadow-sm">
          <div className="flex items-center justify-between gap-4 flex-wrap">
            <div>
              <p className="theme-muted text-sm">Profile</p>
              <h2 className="text-2xl font-bold">{username}</h2>
            </div>
            <button
              onClick={onRefreshProfile}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-blue-600 text-white hover:bg-blue-700"
            >
              <MdRefresh size={18} />
              Refresh
            </button>
          </div>

          <div className="mt-6 grid gap-4 sm:grid-cols-2">
            <div className="theme-surface-soft rounded-xl p-4">
              <p className="theme-muted text-xs uppercase tracking-wide">Username</p>
              <p className="mt-2 inline-flex items-center gap-2 font-semibold">
                <MdPerson size={18} />
                {username}
              </p>
            </div>

            <div className="theme-surface-soft rounded-xl p-4">
              <p className="theme-muted text-xs uppercase tracking-wide">Email</p>
              <p className="mt-2 inline-flex items-center gap-2 font-semibold break-all">
                <MdMail size={18} />
                {email}
              </p>
            </div>

            <div className="theme-surface-soft rounded-xl p-4">
              <p className="theme-muted text-xs uppercase tracking-wide">Preferred Subject</p>
              <p className="mt-2 inline-flex items-center gap-2 font-semibold capitalize">
                <MdSchool size={18} />
                {userPreferredSubject || 'general'}
              </p>
            </div>

            <div className="theme-surface-soft rounded-xl p-4">
              <p className="theme-muted text-xs uppercase tracking-wide">Current Chat Subject</p>
              <p className="mt-2 inline-flex items-center gap-2 font-semibold capitalize">
                <MdSchool size={18} />
                {currentSubject || 'general'}
              </p>
            </div>
          </div>
        </div>

        <div className="theme-surface theme-border border rounded-2xl p-6 shadow-sm">
          <p className="theme-muted text-sm">Appearance</p>
          <div className="mt-4 flex items-center justify-between gap-3 flex-wrap">
            <div>
              <h3 className="font-semibold">Theme</h3>
              <p className="theme-muted text-sm">Current mode: {theme === 'dark' ? 'Dark' : 'Light'}</p>
            </div>
            <button
              onClick={toggleTheme}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-indigo-600 text-white hover:bg-indigo-700"
            >
              <MdPalette size={18} />
              Toggle Theme
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProfileScreen;
