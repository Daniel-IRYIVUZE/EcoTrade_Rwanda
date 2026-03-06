// components/home/LiveImpactTicker.tsx
import { useEffect, useState } from 'react';
import { Activity, Droplet, Package, Truck } from 'lucide-react';
import { getAll } from '../../utils/dataStore';
import type { WasteListing, Collection } from '../../utils/dataStore';

interface ActivityItem {
  type: 'hotel' | 'recycler' | 'driver';
  name: string;
  action: string;
  waste: string;
  time: string;
}


const LiveImpactTicker = () => {
  const [activities, setActivities] = useState<ActivityItem[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);

  useEffect(() => {
    const loadActivities = () => {
      const listings = getAll<WasteListing>('listings');
      const collections = getAll<Collection>('collections');

      const newActivities: ActivityItem[] = [];

      // Recent listings
      listings.slice(-2).forEach(l => {
        const age = Date.now() - new Date(l.createdAt).getTime();
        const timeAgo = age < 3600000 ? `${Math.floor(age/60000)}m ago` : `${Math.floor(age/3600000)}h ago`;
        newActivities.push({
          type: 'hotel',
          name: l.businessName || 'Unknown Hotel',
          action: 'listed',
          waste: `${l.volume} ${l.unit} ${l.wasteType}`,
          time: timeAgo,
        });
      });

      // Recent bids
      listings.forEach(l => {
        const bids = Array.isArray(l.bids) ? l.bids : [];
        if (bids.length > 0) {
          const lastBid = bids[bids.length - 1];
          const age = Date.now() - new Date(lastBid.createdAt).getTime();
          const timeAgo = age < 3600000 ? `${Math.floor(age/60000)}m ago` : `${Math.floor(age/3600000)}h ago`;
          newActivities.push({
            type: 'recycler',
            name: lastBid.recyclerName,
            action: 'bid on',
            waste: `${l.volume} ${l.unit} ${l.wasteType}`,
            time: timeAgo,
          });
        }
      });

      // Recent collections
      collections.slice(-2).forEach(c => {
        const age = Date.now() - new Date(c.scheduledDate).getTime();
        const timeAgo = age < 3600000 ? `${Math.floor(age/60000)}m ago` : `${Math.floor(age/3600000)}h ago`;
        newActivities.push({
          type: 'driver',
          name: c.driverName,
          action: `collected ${c.volume} kg`,
          waste: `from ${c.businessName}`,
          time: timeAgo,
        });
      });

      // Use seed activities if no real data
      if (newActivities.length === 0) {
        newActivities.push(
          { type: 'hotel', name: 'Mille Collines', action: 'listed', waste: '200kg UCO', time: 'just now' },
          { type: 'recycler', name: 'GreenEnergy', action: 'bid on', waste: '150kg Glass', time: '2 min ago' },
          { type: 'driver', name: 'Jean Pierre', action: 'completed collection', waste: '200L UCO', time: '5 min ago' }
        );
      }

      setActivities(newActivities.slice(0, 6));
    };

    loadActivities();
    window.addEventListener('ecotrade_data_change', loadActivities);
    return () => window.removeEventListener('ecotrade_data_change', loadActivities);
  }, []);

  useEffect(() => {
    if (activities.length === 0) return;
    const interval = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % activities.length);
    }, 3000);
    return () => clearInterval(interval);
  }, [activities]);

  const currentActivity = activities[currentIndex];

  if (!currentActivity) {
    return null;
  }

  return (
    <section className="bg-cyan-600 py-6 text-white">
      <div className="max-w-11/12 mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between flex-wrap gap-4">
          <div className="flex items-center space-x-4">
            <Activity className="w-6 h-6 animate-pulse" />
            <span className="font-semibold text-lg">Live Activity:</span>
          </div>

          <div className="flex-1 min-w-[300px]">
            <div className="bg-gray-800/10 dark:bg-gray-800/10 backdrop-blur-sm rounded-lg px-6 py-3">
              <div className="flex items-center space-x-4 animate-fade-in">
                {currentActivity.type === 'hotel' && <Package className="w-5 h-5 flex-shrink-0" />}
                {currentActivity.type === 'recycler' && <Droplet className="w-5 h-5 flex-shrink-0" />}
                {currentActivity.type === 'driver' && <Truck className="w-5 h-5 flex-shrink-0" />}
                <span className="font-medium">
                  <span className="font-bold">{currentActivity.name}</span>{' '}
                  {currentActivity.action}{' '}
                  <span className="text-cyan-200">{currentActivity.waste}</span>
                </span>
                <span className="text-cyan-200 text-sm ml-auto">{currentActivity.time}</span>
              </div>
            </div>
          </div>

          <div className="flex space-x-2">
            <span className="w-2 h-2 bg-white rounded-full animate-pulse"></span>
            <span className="w-2 h-2 bg-white/50 rounded-full"></span>
            <span className="w-2 h-2 bg-white/50 rounded-full"></span>
          </div>
        </div>
      </div>
    </section>
  );
};

export default LiveImpactTicker;