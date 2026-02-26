// components/services/ServiceTabs.tsx
import { Building2, Factory, Truck } from 'lucide-react';

interface ServiceTabsProps {
  activeTab: 'hotels' | 'recyclers' | 'drivers';
  setActiveTab: (tab: 'hotels' | 'recyclers' | 'drivers') => void;
}

const ServiceTabs = ({ activeTab, setActiveTab }: ServiceTabsProps) => {
  const tabs = [
    {
      id: 'hotels',
      label: 'Hotels & Restaurants',
      icon: Building2,
      color: 'from-cyan-500 to-teal-500',
      count: 156
    },
    {
      id: 'recyclers',
      label: 'Recyclers',
      icon: Factory,
      color: 'from-blue-500 to-indigo-500',
      count: 23
    },
    {
      id: 'drivers',
      label: 'Drivers',
      icon: Truck,
      color: 'from-orange-500 to-red-500',
      count: 47
    }
  ];

  return (
    <div className="bg-white rounded-2xl shadow-xl p-2">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-2">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id as 'hotels' | 'recyclers' | 'drivers')}
            className={`relative p-6 rounded-xl transition-all duration-300 group ${
              activeTab === tab.id
                ? `bg-gradient-to-r ${tab.color} text-white shadow-lg transform scale-105`
                : 'hover:bg-gray-50 text-gray-700'
            }`}
          >
            <div className="flex items-center space-x-4">
              <div className={`p-3 rounded-xl ${
                activeTab === tab.id
                  ? 'bg-white/20'
                  : `bg-gradient-to-r ${tab.color} bg-opacity-10`
              }`}>
                <tab.icon className={`w-6 h-6 ${
                  activeTab === tab.id ? 'text-white' : 'text-gray-600'
                }`} />
              </div>
              <div className="text-left">
                <p className="font-semibold">{tab.label}</p>
                <p className={`text-sm ${
                  activeTab === tab.id ? 'text-white/80' : 'text-gray-500'
                }`}>
                  {tab.count} active
                </p>
              </div>
            </div>

            {/* Active Indicator */}
            {activeTab === tab.id && (
              <div className="absolute -bottom-2 left-1/2 transform -translate-x-1/2">
                <div className="w-2 h-2 bg-white rounded-full"></div>
              </div>
            )}
          </button>
        ))}
      </div>
    </div>
  );
};

export default ServiceTabs;