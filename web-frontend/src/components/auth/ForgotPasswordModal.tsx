// components/auth/ForgotPasswordModal.tsx
import { useState } from 'react';
import { X, Mail, ArrowRight, CheckCircle } from 'lucide-react';

interface ForgotPasswordModalProps {
  onClose: () => void;
  onSubmit: (email: string) => void;
}

const ForgotPasswordModal = ({ onClose, onSubmit }: ForgotPasswordModalProps) => {
  const [email, setEmail] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) {
      setError('Please enter your email address');
      return;
    }
    if (!email.includes('@')) {
      setError('Please enter a valid email address');
      return;
    }
    setSubmitted(true);
    onSubmit(email);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
      <div className="bg-white rounded-2xl max-w-md w-full">
        {/* Header */}
        <div className="p-4 border-b border-gray-200 flex justify-between items-center">
          <h2 className="text-xl font-bold text-gray-900">Reset Password</h2>
          <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-lg">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6">
          {!submitted ? (
            <form onSubmit={handleSubmit}>
              <p className="text-sm text-gray-600 mb-6">
                Enter your email address and we'll send you a link to reset your password.
              </p>

              <div className="mb-6">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Email Address
                </label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => {
                      setEmail(e.target.value);
                      setError('');
                    }}
                    className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500 outline-none"
                    placeholder="umuntu@ecotrade.rw"
                  />
                </div>
                {error && (
                  <p className="text-xs text-red-500 mt-2">{error}</p>
                )}
              </div>

              <button
                type="submit"
                className="w-full bg-gradient-to-r from-cyan-600 to-teal-600 text-white py-3 rounded-xl font-semibold hover:shadow-lg transition-all flex items-center justify-center"
              >
                Send Reset Link
                <ArrowRight className="w-4 h-4 ml-2" />
              </button>
            </form>
          ) : (
            <div className="text-center">
              <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <CheckCircle className="w-8 h-8 text-green-600" />
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-2">Check Your Email</h3>
              <p className="text-sm text-gray-600 mb-6">
                We've sent a password reset link to <strong>{email}</strong>
              </p>
              <p className="text-xs text-gray-500">
                Didn't receive the email? Check your spam folder or{' '}
                <button 
                  onClick={() => setSubmitted(false)}
                  className="text-cyan-600 font-semibold"
                >
                  try again
                </button>
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ForgotPasswordModal;