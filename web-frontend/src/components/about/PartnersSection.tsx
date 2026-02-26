// components/about/PartnersSection.tsx
import { ExternalLink } from 'lucide-react';

interface AboutReadMorePayload {
  title: string;
  description: string;
  details?: string[];
}

interface PartnersSectionProps {
  onReadMore?: (payload: AboutReadMorePayload) => void;
}

const partners = [
  {
    name: 'REMA',
    logo: 'https://via.placeholder.com/200x100?text=REMA',
    description: 'Rwanda Environment Management Authority',
    type: 'Government Partner'
  },
  {
    name: 'GGGI',
    logo: 'https://via.placeholder.com/200x100?text=GGGI',
    description: 'Global Green Growth Institute',
    type: 'Technical Partner'
  },
  {
    name: 'COPED',
    logo: 'https://via.placeholder.com/200x100?text=COPED',
    description: 'Waste Management Services',
    type: 'Industry Partner'
  },
  {
    name: 'ALU',
    logo: 'https://via.placeholder.com/200x100?text=ALU',
    description: 'African Leadership University',
    type: 'Academic Partner'
  },
  {
    name: 'Bank of Kigali',
    logo: 'https://via.placeholder.com/200x100?text=BK',
    description: 'Financial Services Partner',
    type: 'Banking Partner'
  },
  {
    name: 'Rwanda Green Fund',
    logo: 'https://via.placeholder.com/200x100?text=FONERWA',
    description: 'Climate Finance',
    type: 'Funding Partner'
  }
];

const PartnersSection = ({ onReadMore }: PartnersSectionProps) => {
  const handlePartnerReadMore = (partner: (typeof partners)[number]) => {
    onReadMore?.({
      title: partner.name,
      description: partner.description,
      details: [`Partner type: ${partner.type}`]
    });
  };

  return (
    <section className="py-20 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <span className="text-cyan-600 font-semibold text-sm uppercase tracking-wider">
            Our Network
          </span>
          <h2 className="text-4xl font-bold text-gray-900 mt-2 mb-6">
            Trusted <span className="text-cyan-600">Partners</span>
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Collaborating with leading organizations to drive circular economy in Rwanda
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {partners.map((partner, index) => (
            <div
              key={index}
              className="group bg-gray-50 rounded-2xl p-6 hover:shadow-xl transition-all duration-300 border border-gray-100 hover:border-cyan-200"
            >
              <div className="flex items-start justify-between mb-4">
                <div className="w-24 h-16 bg-white rounded-lg flex items-center justify-center p-2">
                  <img
                    src={partner.logo}
                    alt={partner.name}
                    className="max-w-full max-h-full object-contain"
                  />
                </div>
                <span className="text-xs bg-cyan-100 text-cyan-700 px-2 py-1 rounded-full">
                  {partner.type}
                </span>
              </div>
              
              <h3 className="text-lg font-bold text-gray-900 mb-2">{partner.name}</h3>
              <p className="text-sm text-gray-600 mb-4">{partner.description}</p>
              
              <button
                type="button"
                onClick={() => handlePartnerReadMore(partner)}
                className="inline-flex items-center text-cyan-600 text-sm font-semibold hover:text-cyan-700 group"
              >
                Learn more
                <ExternalLink className="w-3 h-3 ml-1 group-hover:translate-x-1 transition-transform" />
              </button>
            </div>
          ))}
        </div>

        {/* Become a Partner CTA */}
        <div className="mt-16 text-center">
          <div className="bg-gradient-to-r from-cyan-600 to-teal-600 rounded-2xl p-8 text-white">
            <h3 className="text-2xl font-bold mb-4">Interested in Partnering?</h3>
            <p className="text-cyan-100 mb-6 max-w-2xl mx-auto">
              Join our network of organizations committed to building a circular economy in Rwanda
            </p>
            <button
              type="button"
              onClick={() =>
                onReadMore?.({
                  title: 'Partner with EcoTrade',
                  description:
                    'Join our network to expand circular economy impact across Rwanda.',
                  details: ['Access verified recycler networks.', 'Co-design pilot programs.', 'Share impact metrics.']
                })
              }
              className="bg-white text-cyan-600 px-8 py-3 rounded-xl font-semibold hover:shadow-xl transform hover:-translate-y-1 transition-all duration-300"
            >
              Become a Partner
            </button>
          </div>
        </div>
      </div>
    </section>
  );
};

export default PartnersSection;