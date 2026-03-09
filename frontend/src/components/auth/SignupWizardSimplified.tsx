// components/auth/SignupWizardSimplified.tsx
import { useState } from 'react';
import {
  Building2, Factory, Truck, ArrowRight, ArrowLeft, Check
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

interface SignupWizardProps {
  onToggleMode: () => void;
  onComplete: () => void;
}

const SignupWizard = ({ onToggleMode, onComplete }: SignupWizardProps) => {
  const [step, setStep] = useState(1);
  const [userType, setUserType] = useState<'business' | 'recycler' | 'driver' | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    phone: '',
    password: '',
    confirmPassword: '',
    latitude: '',
    longitude: '',
  });
  const [passwordStrength, setPasswordStrength] = useState(0);
  const { login } = useAuth();

  const userTypes = [
    { id: 'business', label: 'Hotel/Restaurant (HORECA)', icon: Building2, color: 'amber' },
    { id: 'recycler', label: 'Recycling Company', icon: Factory, color: 'cyan' },
    { id: 'driver', label: 'Driver/Collector', icon: Truck, color: 'blue' },
  ];

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    if (name === 'password') {
      let s = 0;
      if (value.length >= 8) s += 25;
      if (/[a-z]/.test(value)) s += 25;
      if (/[A-Z]/.test(value)) s += 25;
      if (/[0-9]/.test(value)) s += 25;
      setPasswordStrength(s);
    }
  };

  const handleUserTypeSelect = (type: 'business' | 'recycler' | 'driver') => {
    setUserType(type);
    setStep(2);
  };

  const handleRegister = async () => {
    if (!userType) return;
    setSubmitting(true);
    setSubmitError('');
    try {
      // Create user in local storage (backend will sync)
      const newUser = {
        id: `user_${Date.now()}`,
        name: formData.fullName,
        email: formData.email,
        phone: formData.phone,
        role: userType,
        verified: false,
        avatar: '/images/default-avatar.svg',
        twoFactorEnabled: false,
      };

      // Store user temporarily for verification
      localStorage.setItem('ecotrade_pending_user', JSON.stringify(newUser));
      localStorage.setItem('ecotrade_pending_password', formData.password);
      localStorage.setItem('ecotrade_location', JSON.stringify({
        latitude: formData.latitude,
        longitude: formData.longitude,
      }));

      // Auto-login the new user
      await login(formData.email, formData.password);
      setStep(4);
    } catch (err) {
      setSubmitError((err as Error).message || 'Registration failed. Please try again.');
    } finally {
      setSubmitting(false);
    }
  };

  const canProceedStep2 = () => {
    if (!formData.email || !formData.password || formData.password !== formData.confirmPassword) return false;
    if (formData.password.length < 6) return false;
    if (!formData.fullName) return false;
    return true;
  };

  const canProceedStep3 = () => {
    return formData.latitude && formData.longitude;
  };

  const renderStepIndicator = () => {
    const steps = [
      { num: 1, label: 'Account Type' },
      { num: 2, label: 'Basic Info' },
      { num: 3, label: 'Location' },
      { num: 4, label: 'Confirmation' },
    ];

    return (
      <div className="mb-8">
        <div className="flex items-center justify-between">
          {steps.map((s, idx) => (
            <div key={s.num} className="flex items-center flex-1">
              <div className={`flex items-center justify-center w-10 h-10 rounded-full font-semibold text-sm ${
                step >= s.num ? 'bg-cyan-600 text-white' : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-400'
              }`}>
                {step > s.num ? <Check className="w-5 h-5" /> : s.num}
              </div>
              {idx < steps.length - 1 && (
                <div className={`flex-1 h-1 mx-2 rounded-full ${step > s.num ? 'bg-cyan-600' : 'bg-gray-200 dark:bg-gray-700'}`} />
              )}
            </div>
          ))}
        </div>
        <div className="flex justify-between mt-2 text-xs text-gray-600 dark:text-gray-400">
          {steps.map(s => (
            <span key={s.num} className="text-center flex-1">{s.label}</span>
          ))}
        </div>
      </div>
    );
  };

  const renderStep = () => {
    switch (step) {
      case 1:
        return (
          <div className="space-y-4">
            <div className="text-center mb-6">
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">Create Your Account</h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">Select your account type to get started</p>
            </div>
            <div className="grid grid-cols-1 gap-3">
              {userTypes.map(({ id, label, icon: Icon, color }) => {
                const colorMap: Record<string, string> = {
                  amber: 'hover:border-amber-500 hover:bg-amber-50 dark:hover:bg-amber-900/10',
                  cyan: 'hover:border-cyan-500 hover:bg-cyan-50 dark:hover:bg-cyan-900/10',
                  blue: 'hover:border-blue-500 hover:bg-blue-50 dark:hover:bg-blue-900/10',
                };
                return (
                  <button
                    key={id}
                    onClick={() => handleUserTypeSelect(id as 'business' | 'recycler' | 'driver')}
                    className={`p-4 border-2 border-gray-200 dark:border-gray-700 rounded-xl transition-all text-left ${colorMap[color]}`}
                  >
                    <div className="flex items-center gap-3">
                      <Icon className="w-6 h-6" />
                      <div>
                        <p className="font-semibold text-gray-900 dark:text-white">{label}</p>
                        <p className="text-xs text-gray-500 dark:text-gray-400">Complete the setup in your dashboard later</p>
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>
        );

      case 2:
        return (
          <div className="space-y-4">
            <div className="text-center mb-6">
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-1">Basic Information</h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">We'll ask for more details later</p>
            </div>

            {submitError && (
              <div className="p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl text-sm text-red-700 dark:text-red-400">
                {submitError}
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Full Name *</label>
              <input
                type="text"
                name="fullName"
                value={formData.fullName}
                onChange={handleInputChange}
                placeholder="Your full name"
                className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl focus:ring-2 focus:ring-cyan-500 outline-none bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Email Address *</label>
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleInputChange}
                placeholder="your@email.com"
                className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl focus:ring-2 focus:ring-cyan-500 outline-none bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Phone Number</label>
              <input
                type="tel"
                name="phone"
                value={formData.phone}
                onChange={handleInputChange}
                placeholder="+250 780 000 000"
                className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl focus:ring-2 focus:ring-cyan-500 outline-none bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Password *</label>
              <input
                type="password"
                name="password"
                value={formData.password}
                onChange={handleInputChange}
                placeholder="••••••••"
                className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl focus:ring-2 focus:ring-cyan-500 outline-none bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100"
              />
              {formData.password && (
                <div className="mt-2">
                  <div className="h-1 bg-gray-200 rounded-full overflow-hidden">
                    <div className={`h-full transition-all ${
                      passwordStrength <= 25 ? 'bg-red-500' : 
                      passwordStrength <= 50 ? 'bg-yellow-500' : 
                      passwordStrength <= 75 ? 'bg-blue-500' : 
                      'bg-green-500'
                    }`} style={{ width: `${passwordStrength}%` }} />
                  </div>
                  <p className="text-xs text-gray-500 mt-1">
                    {passwordStrength <= 25 ? 'Weak' : 
                     passwordStrength <= 50 ? 'Fair' : 
                     passwordStrength <= 75 ? 'Good' : 
                     'Strong'} password
                  </p>
                </div>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Confirm Password *</label>
              <input
                type="password"
                name="confirmPassword"
                value={formData.confirmPassword}
                onChange={handleInputChange}
                placeholder="••••••••"
                className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl focus:ring-2 focus:ring-cyan-500 outline-none bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100"
              />
              {formData.confirmPassword && formData.password !== formData.confirmPassword && (
                <p className="text-xs text-red-500 mt-1">Passwords do not match</p>
              )}
            </div>
          </div>
        );

      case 3:
        return (
          <div className="space-y-4">
            <div className="text-center mb-6">
              <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-1">Your Location</h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">Used to match you with nearby opportunities</p>
            </div>

            <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-xl p-3 text-xs text-blue-700 dark:text-blue-300">
              <strong>Example:</strong> Kigali center: -1.9441, 30.0619
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Latitude *</label>
              <input
                type="text"
                name="latitude"
                value={formData.latitude}
                onChange={handleInputChange}
                placeholder="e.g. -1.9441"
                className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl focus:ring-2 focus:ring-cyan-500 outline-none bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Longitude *</label>
              <input
                type="text"
                name="longitude"
                value={formData.longitude}
                onChange={handleInputChange}
                placeholder="e.g. 30.0619"
                className="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-xl focus:ring-2 focus:ring-cyan-500 outline-none bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100"
              />
            </div>
          </div>
        );

      case 4:
        return (
          <div className="space-y-4 text-center">
            <div className="w-20 h-20 bg-green-100 dark:bg-green-900/30 rounded-full flex items-center justify-center mx-auto">
              <Check className="w-10 h-10 text-green-600 dark:text-green-400" />
            </div>
            <h3 className="text-2xl font-bold text-gray-900 dark:text-white">Account Created!</h3>
            <p className="text-gray-600 dark:text-gray-400">
              Welcome to EcoTrade! You're now logged in. Let's complete your profile setup to get started.
            </p>
            <div className="bg-blue-50 dark:bg-blue-900/20 rounded-xl p-4 text-left border border-blue-200 dark:border-blue-800">
              <h4 className="font-semibold text-blue-800 dark:text-blue-200 mb-3">Next Steps:</h4>
              <ul className="space-y-2 text-sm text-blue-700 dark:text-blue-300">
                <li className="flex items-center gap-2">
                  <Check className="w-4 h-4 shrink-0" />
                  Complete your profile in Dashboard Settings
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-4 h-4 shrink-0" />
                  Upload required documents for verification
                </li>
                <li className="flex items-center gap-2">
                  <Check className="w-4 h-4 shrink-0" />
                  Start using the platform once approved!
                </li>
              </ul>
            </div>
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="bg-white dark:bg-gray-900 rounded-2xl shadow-xl border border-gray-100 dark:border-gray-800 p-6 sm:p-8">
      {renderStepIndicator()}
      {renderStep()}

      {/* Action ButKilograms */}
      <div className="mt-8 flex flex-col sm:flex-row justify-between gap-3">
        {step > 1 && step < 4 && (
          <button
            onClick={() => setStep(step - 1)}
            disabled={submitting}
            className="w-full sm:w-auto px-6 py-3 border border-gray-300 dark:border-gray-600 rounded-xl font-semibold hover:bg-gray-50 dark:hover:bg-gray-800 dark:text-gray-300 transition-colors flex items-center justify-center disabled:opacity-50"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back
          </button>
        )}

        {step === 2 && (
          <button
            onClick={() => setStep(3)}
            disabled={!canProceedStep2()}
            className="w-full sm:flex-1 px-6 py-3 bg-cyan-600 text-white rounded-xl font-semibold hover:bg-cyan-700 transition-all flex items-center justify-center disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Continue
            <ArrowRight className="w-4 h-4 ml-2" />
          </button>
        )}

        {step === 3 && (
          <button
            onClick={handleRegister}
            disabled={!canProceedStep3() || submitting}
            className="w-full sm:flex-1 px-6 py-3 bg-cyan-600 text-white rounded-xl font-semibold hover:bg-cyan-700 transition-all flex items-center justify-center disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {submitting ? 'Creating Account...' : 'Create Account'}
            {!submitting && <ArrowRight className="w-4 h-4 ml-2" />}
          </button>
        )}

        {step === 4 && (
          <button
            onClick={onComplete}
            className="w-full px-6 py-3 bg-cyan-600 text-white rounded-xl font-semibold hover:bg-cyan-700 transition-all"
          >
            Go to Dashboard
          </button>
        )}
      </div>

      {step === 1 && (
        <p className="mt-8 text-center text-sm text-gray-600 dark:text-gray-400">
          Already have an account?{' '}
          <button onClick={onToggleMode} className="text-cyan-600 hover:text-cyan-700 dark:text-cyan-400 font-semibold">
            Sign in
          </button>
        </p>
      )}
    </div>
  );
};

export default SignupWizard;
