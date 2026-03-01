// components/auth/LoginForm.tsx
import { useState } from 'react';
import { Eye, EyeOff, Mail, Lock, ArrowRight } from 'lucide-react';

interface LoginFormProps {
  onToggleMode: () => void;
  onForgotPassword: () => void;
  onLogin: (email: string, password: string) => void;
  demoCredentials: Array<{ role: string; email: string; password: string }>;
}

const LoginForm = ({ onToggleMode, onForgotPassword, onLogin, demoCredentials }: LoginFormProps) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      // Pass credentials to parent (LoginPage handles AuthContext login + 2FA)
      await onLogin(email, password);
    } catch {
      setError('Invalid email or password. Please try again or use demo credentials below.');
    } finally {
      setIsLoading(false);
    }
  };



  return (
    <div className="bg-white dark:bg-gray-900 rounded-2xl shadow-xl p-8">
      {/* Header */}
      <div className="text-center mb-8">
        <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">Welcome Back</h2>
        <p className="text-gray-600 dark:text-gray-400">Sign in to your EcoTrade account</p>
      </div>

      {/* Error Message */}
      {error && (
        <div className="mb-6 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl">
          <p className="text-sm text-red-600 dark:text-red-400">{error}</p>
        </div>
      )}



      {/* Login Form */}
      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Email Field */}
        <div>
          <label htmlFor="email" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Email Address
          </label>
          <div className="relative">
            <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400 dark:text-gray-500" />
            <input
              type="email"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full pl-10 pr-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500 outline-none transition-all bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 placeholder-gray-400 dark:placeholder-gray-500"
              placeholder="username@ecotrade.rw"
              required
            />
          </div>
        </div>

        {/* Password Field */}
        <div>
          <label htmlFor="password" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Password
          </label>
          <div className="relative">
            <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400 dark:text-gray-500" />
            <input
              type={showPassword ? 'text' : 'password'}
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full pl-10 pr-12 py-3 border border-gray-300 dark:border-gray-600 rounded-xl focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500 outline-none transition-all bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100"
              placeholder="••••••••"
              required
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute right-3 top-1/2 transform -translate-y-1/2"
            >
              {showPassword ? (
                <EyeOff className="w-5 h-5 text-gray-400 dark:text-gray-500" />
              ) : (
                <Eye className="w-5 h-5 text-gray-400 dark:text-gray-500" />
              )}
            </button>
          </div>
        </div>

        {/* Remember Me & Forgot Password */}
        <div className="flex items-center justify-between">
          <label className="flex items-center">
            <input
              type="checkbox"
              checked={rememberMe}
              onChange={(e) => setRememberMe(e.target.checked)}
              className="w-4 h-4 text-cyan-600 rounded border-gray-300 dark:border-gray-600 focus:ring-cyan-500"
            />
            <span className="ml-2 text-sm text-gray-600 dark:text-gray-400">Remember me</span>
          </label>
          <button
            type="button"
            onClick={onForgotPassword}
            className="text-sm text-cyan-600 hover:text-cyan-700 dark:text-cyan-400 font-medium"
          >
            Forgot password?
          </button>
        </div>

        {/* Login Button */}
        <button
          type="submit"
          disabled={isLoading}
          className="w-full bg-cyan-600 text-white py-3 rounded-xl font-semibold hover:shadow-lg transform hover:-translate-y-0.5 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:transform-none flex items-center justify-center"
        >
          {isLoading ? (
            <>
              <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
              Signing in...
            </>
          ) : (
            <>
              Sign In
              <ArrowRight className="ml-2 w-5 h-5" />
            </>
          )}
        </button>
      </form>

      {/* Google Login */}
      <div className="mt-8">
        <button
          className="w-full flex items-center justify-center px-4 py-3 border-2 border-gray-200 dark:border-gray-700 rounded-xl hover:border-gray-300 dark:hover:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-800 transition-all duration-300"
        >
          <svg className="w-5 h-5 mr-2" viewBox="0 0 24 24">
            <path fill="#EA4335" d="M23.745 12.27c0-.79-.078-1.54-.228-2.26H12v4.26h6.47c-.29 1.48-1.14 2.84-2.42 3.74v3h3.92c2.3-2.1 3.63-5.2 3.63-8.74z"/>
            <path fill="#34A853" d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.92-3c-1.08.72-2.46 1.13-4.01 1.13-3.02 0-5.57-2.03-6.48-4.78H2.18v3.09C3.99 21.1 7.7 24 12 24z"/>
            <path fill="#4285F4" d="M5.52 15.44c-.25-.72-.38-1.49-.38-2.44s.13-1.72.35-2.44V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.49-.27z"/>
            <path fill="#FBBC05" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.92 2.3 15.25 1 12 1 7.7 1 3.99 3.9 2.18 7.93l3.34 2.6c.91-2.75 3.46-4.78 6.48-4.78z"/>
          </svg>
          <span className="text-sm font-medium text-gray-700 dark:text-gray-300">Continue with Google</span>
        </button>
      </div>

      {/* Quick Fill Demo Buttons */}
      <div className="mt-6">
        <p className="text-xs text-gray-500 dark:text-gray-400 mb-3 text-center">Quick fill demo accounts:</p>
        <div className="flex flex-wrap gap-2 justify-center">
          {demoCredentials.map((cred, index) => (
            <button
              key={index}
              onClick={() => {
                setEmail(cred.email);
                setPassword(cred.password);
              }}
              className="px-3 py-1 bg-gray-100 dark:bg-gray-800 rounded-full text-xs hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors dark:text-gray-300"
            >
              {cred.role}
            </button>
          ))}
        </div>
      </div>

      {/* Sign Up Link */}
      <p className="mt-8 text-center text-sm text-gray-600 dark:text-gray-400">
        Don't have an account?{' '}
        <button
          onClick={onToggleMode}
          className="text-cyan-600 hover:text-cyan-700 dark:text-cyan-400 font-semibold"
        >
          Sign up
        </button>
      </p>
    </div>
  );
};

export default LoginForm;