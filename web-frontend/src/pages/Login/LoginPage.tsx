// pages/Login/LoginPage.tsx
import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Home } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import LoginForm from '../../components/auth/LoginForm';
import TwoFactorModal from '../../components/auth/TwoFactorModal';
import ForgotPasswordModal from '../../components/auth/ForgotPasswordModal';
import TermsPrivacyModal from '../../components/auth/TermsPrivacyModal';
import SignupWizard from '../../components/auth/SignupWizard';

const LoginPage = () => {
  const navigate = useNavigate();
  const { login, verify2FA } = useAuth();
  const [showTwoFactor, setShowTwoFactor] = useState(false);
  const [showForgotPassword, setShowForgotPassword] = useState(false);
  const [showTermsModal, setShowTermsModal] = useState(false);
  const [showSignup, setShowSignup] = useState(false);
  const [userEmail, setUserEmail] = useState('');
  const [pendingRole, setPendingRole] = useState('');

  // Demo credentials for all 5 roles
  const demoCredentials = [
    { role: 'Admin', email: 'admin@ecotrade.rw', password: 'admin123' },
    { role: 'Hotel', email: 'hotel@millecollines.rw', password: 'hotel123' },
    { role: 'Recycler', email: 'recycler@greenenergy.rw', password: 'recycler123' },
    { role: 'Driver', email: 'driver@ecotrade.rw', password: 'driver123' },
    { role: 'Individual', email: 'individual@ecotrade.rw', password: 'user123' }
  ];

  // Role to dashboard path mapping
  const getRoleDashboardPath = (role: string) => {
    const roleMap: Record<string, string> = {
      admin: '/dashboard/admin',
      business: '/dashboard/business',
      recycler: '/dashboard/recycler',
      driver: '/dashboard/driver',
      individual: '/dashboard/individual',
    };
    return roleMap[role] || '/dashboard';
  };

  const handleLogin = async (email: string, password: string) => {
    // Call AuthContext login - validates against DEMO_USERS and sets user state
    await login(email, password);
    
    // Determine role from DEMO_USERS match
    const roleMap: Record<string, string> = {
      'admin@ecotrade.rw': 'admin',
      'hotel@millecollines.rw': 'business',
      'recycler@greenenergy.rw': 'recycler',
      'driver@ecotrade.rw': 'driver',
      'individual@ecotrade.rw': 'individual',
    };
    const role = roleMap[email] || 'individual';
    
    setUserEmail(email);
    setPendingRole(role);
    // Show 2FA modal
    setShowTwoFactor(true);
  };

  const handle2FAVerify = async (code: string) => {
    const isValid = await verify2FA(code);
    if (isValid) {
      setShowTwoFactor(false);
      // Navigate to the correct role-based dashboard
      navigate(getRoleDashboardPath(pendingRole));
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      {/* Header with Home Button */}
      <header className="fixed top-0 left-0 right-0 z-40 bg-white/90 backdrop-blur-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <img src="/images/EcoTrade.png" alt="EcoTrade Rwanda" className="h-12 object-contain" />
            <Link 
              to="/" 
              className="flex items-center gap-2 px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <Home size={20} />
              <span className="text-sm font-medium">Home</span>
            </Link>
          </div>
        </div>
      </header>
      
      <main className="pt-20 sm:pt-24 pb-8 sm:pb-12">
        <div className="max-w-7xl mx-auto px-3 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-8 sm:gap-12 items-start">
            {/* Left Column - Hero Content */}
            <div className="hidden lg:block">
              <div className="sticky top-24">
                <h1 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-4 sm:mb-6">
                  Welcome to{' '}
                  <span className="text-transparent bg-clip-text bg-gradient-to-r from-cyan-600 to-teal-600">
                    EcoTrade
                  </span>
                </h1>
                
                <p className="text-base sm:text-lg text-gray-600 mb-6 sm:mb-8">
                  Join Kigali's premier circular economy marketplace. Connect with hotels, 
                  recyclers, and drivers to transform waste management.
                </p>

                {/* Demo Credentials Card */}
                <div className="bg-white rounded-2xl shadow-xl p-4 sm:p-6 mb-6 sm:mb-8 border border-gray-200">
                  <h3 className="font-semibold text-gray-900 mb-3 sm:mb-4 text-sm sm:text-base">Demo Credentials</h3>
                  <div className="space-y-2 sm:space-y-3">
                    {demoCredentials.map((cred, index) => (
                      <div key={index} className="flex items-center justify-between p-2 sm:p-3 bg-gray-50 rounded-xl">
                        <div>
                          <span className="text-xs font-semibold px-2 py-1 rounded-full bg-cyan-100 text-cyan-700">
                            {cred.role}
                          </span>
                        </div>
                        <div className="text-xs sm:text-sm flex gap-2">
                          <span className="text-gray-600 truncate">{cred.email}</span>
                          <span className="mx-1 text-gray-300 hidden sm:inline">|</span>
                          <span className="font-mono text-gray-800">{cred.password}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                  <p className="text-xs text-gray-500 mt-3 sm:mt-4">
                    Use these credentials to test different roles. OTP code: <span className="font-mono font-bold text-cyan-700">123456</span>
                  </p>
                </div>

                {/* Features List */}
                <div className="space-y-3 sm:space-y-4">
                  <div className="flex items-center">
                    <div className="w-6 h-6 sm:w-8 sm:h-8 bg-cyan-100 rounded-full flex items-center justify-center mr-2 sm:mr-3 flex-shrink-0">
                      ✓
                    </div>
                    <span className="text-sm sm:text-base text-gray-700">Secure authentication with OTP</span>
                  </div>
                  <div className="flex items-center">
                    <div className="w-6 h-6 sm:w-8 sm:h-8 bg-cyan-100 rounded-full flex items-center justify-center mr-2 sm:mr-3 flex-shrink-0">
                      ✓
                    </div>
                    <span className="text-sm sm:text-base text-gray-700">Role-based access control</span>
                  </div>
                  <div className="flex items-center">
                    <div className="w-6 h-6 sm:w-8 sm:h-8 bg-cyan-100 rounded-full flex items-center justify-center mr-2 sm:mr-3 flex-shrink-0">
                      ✓
                    </div>
                    <span className="text-sm sm:text-base text-gray-700">Multi-step registration wizard</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Right Column - Auth Forms */}
            <div className="w-full max-w-md mx-auto lg:mx-0">
              {!showSignup ? (
                <LoginForm 
                  onToggleMode={() => setShowTermsModal(true)}
                  onForgotPassword={() => setShowForgotPassword(true)}
                  onLogin={handleLogin}
                  demoCredentials={demoCredentials}
                />
              ) : (
                <SignupWizard 
                  onToggleMode={() => setShowSignup(false)}
                  onComplete={() => navigate('/dashboard')}
                />
              )}
            </div>
          </div>
        </div>
      </main>

      {/* Modals */}
      <TermsPrivacyModal
        isOpen={showTermsModal}
        onAccept={() => {
          setShowTermsModal(false);
          setShowSignup(true);
        }}
        onDecline={() => {
          setShowTermsModal(false);
          window.location.href = '/';
        }}
      />

      {showTwoFactor && (
        <TwoFactorModal 
          email={userEmail}
          onClose={() => setShowTwoFactor(false)}
          onVerify={handle2FAVerify}
        />
      )}

      {showForgotPassword && (
        <ForgotPasswordModal 
          onClose={() => setShowForgotPassword(false)}
          onSubmit={(email) => {
            console.log('Password reset for:', email);
            setShowForgotPassword(false);
          }}
        />
      )}
    </div>
  );
};

export default LoginPage;