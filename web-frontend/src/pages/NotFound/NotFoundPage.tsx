import { Link } from 'react-router-dom';
import { Home, ArrowLeft, Search } from 'lucide-react';

const NotFoundPage = () => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 flex items-center justify-center px-4">
      <div className="max-w-lg w-full text-center">
        {/* 404 Visual */}
        <div className="mb-8">
          <h1 className="text-8xl sm:text-9xl font-black text-transparent bg-clip-text bg-gradient-to-r from-cyan-600 to-teal-600">
            404
          </h1>
          <div className="w-24 h-1 bg-gradient-to-r from-cyan-600 to-teal-600 mx-auto rounded-full mt-4"></div>
        </div>

        {/* Message */}
        <h2 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-4">
          Page Not Found
        </h2>
        <p className="text-gray-600 mb-8 max-w-md mx-auto">
          The page you're looking for doesn't exist or has been moved. 
          Let's get you back to the EcoTrade marketplace.
        </p>

        {/* Actions */}
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <Link
            to="/"
            className="flex items-center gap-2 bg-cyan-600 text-white px-6 py-3 rounded-xl font-medium hover:bg-cyan-700 transition-all shadow-lg hover:shadow-xl w-full sm:w-auto justify-center"
          >
            <Home size={18} />
            Go Home
          </Link>
          <button
            onClick={() => window.history.back()}
            className="flex items-center gap-2 border border-gray-300 text-gray-700 px-6 py-3 rounded-xl font-medium hover:bg-gray-50 transition-all w-full sm:w-auto justify-center"
          >
            <ArrowLeft size={18} />
            Go Back
          </button>
          <Link
            to="/marketplace"
            className="flex items-center gap-2 border border-cyan-200 text-cyan-700 px-6 py-3 rounded-xl font-medium hover:bg-cyan-50 transition-all w-full sm:w-auto justify-center"
          >
            <Search size={18} />
            Marketplace
          </Link>
        </div>

        {/* Decorative Elements */}
        <div className="mt-12 flex items-center justify-center gap-8 text-gray-400 text-sm">
          <Link to="/about" className="hover:text-cyan-600 transition-colors">About</Link>
          <span>•</span>
          <Link to="/services" className="hover:text-cyan-600 transition-colors">Services</Link>
          <span>•</span>
          <Link to="/contact" className="hover:text-cyan-600 transition-colors">Contact</Link>
        </div>
      </div>
    </div>
  );
};

export default NotFoundPage;
