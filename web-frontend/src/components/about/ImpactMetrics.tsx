// components/about/ImpactMetrics.tsx
import { useEffect, useState } from 'react';
import { Recycle, TreePine, Droplets, Factory, Users, TrendingUp, Target, Globe2, Handshake } from 'lucide-react';

interface AboutReadMorePayload {
  title: string;
  description: string;
  details?: string[];
}

interface ImpactMetricsProps {
  onReadMore?: (payload: AboutReadMorePayload) => void;
}

const metrics = [
  {
    icon: Recycle,
    label: 'Waste Diverted',
    value: 1500,
    suffix: ' kg',
    color: 'from-cyan-500 to-teal-500'
  },
  {
    icon: TreePine,
    label: 'CO₂ Emissions Saved',
    value: 750,
    suffix: ' kg',
    color: 'from-cyan-500 to-cyan-500'
  },
  {
    icon: Droplets,
    label: 'Water Saved',
    value: 3500,
    suffix: ' L',
    color: 'from-blue-500 to-cyan-500'
  },
  {
    icon: Factory,
    label: 'Partner Recyclers',
    value: 2,
    suffix: '',
    color: 'from-purple-500 to-indigo-500'
  },
  {
    icon: Users,
    label: 'Hotels Engaged',
    value: 5,
    suffix: '',
    color: 'from-orange-500 to-red-500'
  },
  {
    icon: TrendingUp,
    label: 'Revenue Generated',
    value: 650000,
    suffix: ' RWF',
    format: (val: number) => (val / 1000).toFixed(0) + 'K',
    color: 'from-yellow-500 to-orange-500'
  }
];

const ImpactMetrics = ({ onReadMore }: ImpactMetricsProps) => {
  const [counts, setCounts] = useState(metrics.map(() => 0));

  const handleReadMore = () => {
    onReadMore?.({
      title: 'Impact Reporting',
      description:
        'We track diversion, emissions, and revenue outcomes so partners can see tangible results.',
      details: metrics.map((metric) => `${metric.label}: ${metric.value.toLocaleString()}${metric.suffix}`)
    });
  };

  useEffect(() => {
    const intervals = metrics.map((metric, index) => {
      return setInterval(() => {
        setCounts(prev => {
          const newCounts = [...prev];
          const target = metric.value;
          if (newCounts[index] < target) {
            newCounts[index] = Math.min(
              newCounts[index] + Math.ceil(target / 50), 
              target
            );
          }
          return newCounts;
        });
      }, 30);
    });

    return () => intervals.forEach(clearInterval);
  }, []);

  return (
    <section className="py-20 bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Our <span className="text-cyan-600">Impact</span> So Far
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Measurable results in our journey toward a circular economy
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {metrics.map((metric, index) => (
            <div
              key={index}
              className="bg-white rounded-xl p-6 shadow-lg hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1"
            >
              <div className="flex items-start justify-between mb-4">
                <div className={`p-3 rounded-lg bg-gradient-to-r ${metric.color} bg-opacity-10`}>
                  <metric.icon className={`w-6 h-6 text-${metric.color.split('-')[1]}-600`} />
                </div>
                <span className="text-sm text-gray-400">Since 2025</span>
              </div>
              
              <div className="text-3xl font-bold text-gray-900 mb-1">
                {metric.format 
                  ? metric.format(counts[index])
                  : counts[index].toLocaleString()}
                {metric.suffix}
              </div>
              
              <div className="text-sm text-gray-600">{metric.label}</div>

              {/* Progress Bar */}
              <div className="mt-4 h-1 bg-gray-100 rounded-full overflow-hidden">
                <div
                  className={`h-full bg-gradient-to-r ${metric.color} rounded-full transition-all duration-1000`}
                  style={{ width: `${(counts[index] / metric.value) * 100}%` }}
                ></div>
              </div>
            </div>
          ))}
        </div>

        {/* Comparison to Global Goals */}
        <div className="mt-12 bg-white rounded-xl p-8 border border-gray-100">
          <h3 className="text-xl font-bold text-gray-900 mb-4">
            Aligned with UN Sustainable Development Goals
          </h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="text-center">
              <Target className="w-8 h-8 mx-auto mb-2 text-cyan-600" />
              <p className="text-sm font-medium">SDG 12: Responsible Consumption</p>
            </div>
            <div className="text-center">
              <Globe2 className="w-8 h-8 mx-auto mb-2 text-blue-600" />
              <p className="text-sm font-medium">SDG 13: Climate Action</p>
            </div>
            <div className="text-center">
              <Droplets className="w-8 h-8 mx-auto mb-2 text-cyan-600" />
              <p className="text-sm font-medium">SDG 6: Clean Water</p>
            </div>
            <div className="text-center">
              <Handshake className="w-8 h-8 mx-auto mb-2 text-teal-600" />
              <p className="text-sm font-medium">SDG 17: Partnerships</p>
            </div>
          </div>
        </div>

        <div className="mt-8 text-center">
          <button
            type="button"
            onClick={handleReadMore}
            className="inline-flex items-center justify-center px-6 py-3 rounded-xl bg-cyan-600 text-white font-semibold hover:bg-cyan-700 transition-colors"
          >
            Read the impact report
          </button>
        </div>
      </div>
    </section>
  );
};

export default ImpactMetrics;