import { useState } from 'react';
import api from '../services/api';
import { useNavigate } from 'react-router-dom';
import Cookies from 'js-cookie';
import { toast } from 'react-toastify';
import { User, Mail, Lock, Eye, EyeOff, Sparkles, Moon, Sun } from 'lucide-react';
import { useTheme } from '../shared/theme/ThemeProvider';

const Login = ({ setIsLoggedIn, clearLocalStorage }) => {
  const { theme, toggleTheme } = useTheme();
  const [isRegister, setIsRegister] = useState(false);
  const [form, setForm] = useState({ username: '', email: '', password: '' });
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async () => {
    if (!form.username.trim() || !form.password.trim()) {
      toast.error('Please fill in all required fields');
      return;
    }

    if (isRegister && !form.email.trim()) {
      toast.error('Please enter a valid email');
      return;
    }

    setLoading(true);
    try {
      if (isRegister) {
        await api.post('/api/auth/register', form);
        toast.success('Registered successfully! Logging you in...');
      }

      const formData = new URLSearchParams();
      formData.append('username', form.username);
      formData.append('password', form.password);

      const loginRes = await api.post('/api/auth/login', formData.toString(), {
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
      });

      Cookies.set('token', loginRes.data.access_token, { expires: 7 });
      api.defaults.headers.common.Authorization = `Bearer ${loginRes.data.access_token}`;
      clearLocalStorage();
      setIsLoggedIn(true);
      toast.success('Logged in successfully!');
      navigate('/', { replace: true });
    } catch (err) {
      toast.error('Error: ' + (err.response?.data?.detail || err.message));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={`min-h-screen flex items-center justify-center p-4 transition-colors duration-200 ${
      theme === 'dark'
        ? 'bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900'
        : 'bg-gradient-to-br from-sky-100 via-indigo-100 to-emerald-100'
    }`}>
      <button
        onClick={toggleTheme}
        className="absolute top-4 right-4 p-2 rounded-lg theme-surface theme-text theme-border border shadow-sm"
        aria-label="Toggle theme"
      >
        {theme === 'dark' ? <Sun size={18} /> : <Moon size={18} />}
      </button>
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-2xl">
            <Sparkles size={32} className="text-white" />
          </div>
          <h1 className="text-3xl font-bold text-white mb-2">Code Mentor AI</h1>
          <p className={`${theme === 'dark' ? 'text-gray-300' : 'text-slate-600'}`}>Your intelligent coding companion</p>
        </div>

        {/* Form Card */}
        <div className={`backdrop-blur-lg rounded-2xl shadow-2xl p-8 border ${
          theme === 'dark' ? 'bg-white/10 border-white/20' : 'bg-white/80 border-slate-200'
        }`}>
          <h2 className={`text-2xl font-bold mb-6 text-center ${theme === 'dark' ? 'text-white' : 'text-slate-900'}`}>
            {isRegister ? 'Create Account' : 'Welcome Back'}
          </h2>

          <div className="space-y-4">
            {/* Username */}
            <div className="relative">
              <User size={20} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input 
                placeholder="Username" 
                value={form.username} 
                onChange={e => setForm({...form, username: e.target.value})} 
                className={`w-full pl-10 pr-4 py-3 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent backdrop-blur-sm ${
                  theme === 'dark'
                    ? 'bg-white/10 border border-white/20 text-white placeholder-gray-400'
                    : 'bg-white border border-slate-300 text-slate-900 placeholder-slate-500'
                }`} 
              />
            </div>

            {/* Email (Register only) */}
            {isRegister && (
              <div className="relative">
                <Mail size={20} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                <input 
                  placeholder="Email" 
                  type="email"
                  value={form.email} 
                  onChange={e => setForm({...form, email: e.target.value})} 
                  className={`w-full pl-10 pr-4 py-3 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent backdrop-blur-sm ${
                    theme === 'dark'
                      ? 'bg-white/10 border border-white/20 text-white placeholder-gray-400'
                      : 'bg-white border border-slate-300 text-slate-900 placeholder-slate-500'
                  }`} 
                />
              </div>
            )}

            {/* Password */}
            <div className="relative">
              <Lock size={20} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input 
                type={showPassword ? 'text' : 'password'}
                placeholder="Password" 
                value={form.password} 
                onChange={e => setForm({...form, password: e.target.value})} 
                className={`w-full pl-10 pr-12 py-3 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent backdrop-blur-sm ${
                  theme === 'dark'
                    ? 'bg-white/10 border border-white/20 text-white placeholder-gray-400'
                    : 'bg-white border border-slate-300 text-slate-900 placeholder-slate-500'
                }`} 
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className={`absolute right-3 top-1/2 transform -translate-y-1/2 ${theme === 'dark' ? 'text-gray-400 hover:text-gray-300' : 'text-slate-500 hover:text-slate-700'}`}
              >
                {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
              </button>
            </div>
          </div>

          {/* Submit Button */}
          <button 
            onClick={handleSubmit}
            disabled={loading}
            className="w-full mt-6 bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700 disabled:from-gray-500 disabled:to-gray-600 py-3 rounded-lg text-white font-semibold transition-all duration-200 flex items-center justify-center shadow-lg hover:shadow-blue-500/25"
          >
            {loading ? (
              <>
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                {isRegister ? 'Creating Account...' : 'Signing In...'}
              </>
            ) : (
              isRegister ? 'Create Account' : 'Sign In'
            )}
          </button>

          {/* Toggle */}
          <button 
            onClick={() => setIsRegister(!isRegister)} 
            className={`w-full mt-4 transition-colors text-center ${theme === 'dark' ? 'text-blue-300 hover:text-blue-200' : 'text-blue-700 hover:text-blue-800'}`}
          >
            {isRegister ? 'Already have an account? Sign In' : 'Need an account? Create One'}
          </button>
        </div>

        {/* Features */}
        <div className={`mt-8 text-center ${theme === 'dark' ? 'text-gray-300' : 'text-slate-600'}`}>
          <p className="text-sm">✨ AI-powered learning • 📚 Multiple subjects • 🔧 Code debugging</p>
        </div>
      </div>
    </div>
  );
};

export default Login;