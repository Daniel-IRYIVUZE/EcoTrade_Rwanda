// components/home/KeyFeatures.tsx
import { 
  Map, 
  WifiOff, 
  Zap, 
  Award, 
  TrendingUp, 
  Shield,
  Globe,
  Smartphone,
  BarChart
} from 'lucide-react';

const features = [
  {
    icon: Map,
    title: 'Geospatial Optimization',
    description: 'PostGIS-powered clustering for 40% shorter collection routes',
    color: 'text-blue-600',
    bgColor: 'bg-blue-50'
  },
  {
    icon: WifiOff,
    title: 'Offline-First Mobile',
    description: 'Full functionality without internet, syncs when connected',
    color: 'text-cyan-600',
    bgColor: 'bg-cyan-50'
  },
  {
    icon: Zap,
    title: 'Instant Payments',
    description: 'Mobile money transfer on collection confirmation',
    color: 'text-yellow-600',
    bgColor: 'bg-yellow-50'
  },
  {
    icon: Award,
    title: 'Green Certification',
    description: 'Verifiable sustainability metrics and digital certificates',
    color: 'text-purple-600',
    bgColor: 'bg-purple-50'
  },
  {
    icon: TrendingUp,
    title: 'Real-time Tracking',
    description: 'Live updates on collections, bids, and revenue',
    color: 'text-red-600',
    bgColor: 'bg-red-50'
  },
  {
    icon: BarChart,
    title: 'Analytics Dashboard',
    description: 'Comprehensive insights into your waste impact',
    color: 'text-indigo-600',
    bgColor: 'bg-indigo-50'
  },
  {
    icon: Globe,
    title: 'B2B Marketplace',
    description: 'Direct connection between hotels and recyclers',
    color: 'text-cyan-600',
    bgColor: 'bg-cyan-50'
  },
  {
    icon: Shield,
    title: 'Verified Quality',
    description: 'Photo proof and quality verification for all collections',
    color: 'text-cyan-600',
    bgColor: 'bg-cyan-50'
  },
  {
    icon: Smartphone,
    title: 'Multi-Platform',
    description: 'Web dashboard and mobile apps for all users',
    color: 'text-orange-600',
    bgColor: 'bg-orange-50'
  }
];

const KeyFeatures = () => {
  return (
    <section className="py-20 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Powerful <span className="text-cyan-600">Features</span>
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Everything you need to transform waste management into revenue generation
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <div
              key={index}
              className="group p-8 rounded-2xl border border-gray-100 hover:border-cyan-200 hover:shadow-xl transition-all duration-300"
            >
              <div className={`inline-flex items-center justify-center w-16 h-16 ${feature.bgColor} rounded-xl mb-6 group-hover:scale-110 transition-transform duration-300`}>
                <feature.icon className={`w-8 h-8 ${feature.color}`} />
              </div>
              
              <h3 className="text-xl font-bold text-gray-900 mb-3">{feature.title}</h3>
              <p className="text-gray-600 leading-relaxed">{feature.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default KeyFeatures;