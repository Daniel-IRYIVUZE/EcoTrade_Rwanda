// components/about/ValuesSection.tsx
import { 
  Shield, 
  Lightbulb, 
  Users, 
  TrendingUp,
  Handshake,
  Leaf
} from 'lucide-react';

interface AboutReadMorePayload {
  title: string;
  description: string;
  details?: string[];
}

interface ValuesSectionProps {
  onReadMore?: (payload: AboutReadMorePayload) => void;
}

const values = [
  {
    icon: Leaf,
    title: 'Sustainability First',
    description: 'Every decision prioritizes environmental impact and long-term ecological health.',
    color: 'from-cyan-500 to-cyan-500'
  },
  {
    icon: Shield,
    title: 'Transparency',
    description: 'Open pricing, verified transactions, and clear impact reporting for all stakeholders.',
    color: 'from-blue-500 to-indigo-500'
  },
  {
    icon: Lightbulb,
    title: 'Innovation',
    description: 'Leveraging cutting-edge technology to solve waste management challenges.',
    color: 'from-yellow-500 to-orange-500'
  },
  {
    icon: Users,
    title: 'Community Empowerment',
    description: 'Creating economic opportunities for local businesses and informal collectors.',
    color: 'from-purple-500 to-pink-500'
  },
  {
    icon: Handshake,
    title: 'Partnership',
    description: 'Building strong relationships across the entire waste value chain.',
    color: 'from-red-500 to-rose-500'
  },
  {
    icon: TrendingUp,
    title: 'Economic Viability',
    description: 'Making recycling profitable for all participants in the ecosystem.',
    color: 'from-cyan-500 to-teal-500'
  }
];

const ValuesSection = ({ onReadMore }: ValuesSectionProps) => {
  return (
    <section className="py-20 bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <span className="text-cyan-600 font-semibold text-sm uppercase tracking-wider">
            What We Stand For
          </span>
          <h2 className="text-4xl font-bold text-gray-900 mt-2 mb-6">
            Our Core <span className="text-cyan-600">Values</span>
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            These principles guide our decisions, partnerships, and vision for a circular economy
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {values.map((value, index) => (
            <div
              key={index}
              className="group bg-white rounded-2xl p-8 shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2 relative overflow-hidden"
            >
              {/* Background Gradient */}
              <div className={`absolute inset-0 bg-gradient-to-br ${value.color} opacity-0 group-hover:opacity-5 transition-opacity duration-300`}></div>
              
              <div className={`inline-flex items-center justify-center w-16 h-16 rounded-xl bg-gradient-to-br ${value.color} text-white mb-6 group-hover:scale-110 transition-transform`}>
                <value.icon className="w-8 h-8" />
              </div>
              
              <h3 className="text-xl font-bold text-gray-900 mb-3">{value.title}</h3>
              <p className="text-gray-600 leading-relaxed">{value.description}</p>

              <button
                type="button"
                onClick={() =>
                  onReadMore?.({
                    title: value.title,
                    description: value.description,
                    details: ['How we operationalize this value across product, partnerships, and community.']
                  })
                }
                className="mt-4 inline-flex items-center text-cyan-600 text-sm font-semibold hover:text-cyan-700"
              >
                Read more
              </button>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default ValuesSection;