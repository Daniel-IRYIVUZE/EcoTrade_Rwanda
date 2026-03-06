// components/dashboard/admin/AdminRouteMonitor.tsx
import { useState, useEffect } from 'react';
import { Map, Truck, Building2, Recycle, AlertTriangle, RefreshCw } from 'lucide-react';
import { getAll } from '../../../utils/dataStore';
import type { Collection, PlatformUser } from '../../../utils/dataStore';

const STATUS_COLOR: Record<string, string> = {
  'en-route':  'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300',
  scheduled:   'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-300',
  completed:   'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
  cancelled:   'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-300',
};

const KIGALI_SECTORS = ['Nyarugenge', 'Gasabo', 'Kicukiro', 'Kimironko', 'Remera', 'Gikondo'];

export default function AdminRouteMonitor() {
  const [collections, setCollections] = useState<Collection[]>([]);
  const [users, setUsers] = useState<PlatformUser[]>([]);
  const [selectedRoute, setSelectedRoute] = useState<Collection | null>(null);
  const [layerFilter, setLayerFilter] = useState<'all' | 'hotels' | 'recyclers' | 'routes'>('all');
  const [lastRefresh, setLastRefresh] = useState(new Date());

  const load = () => {
    setCollections(getAll<Collection>('collections'));
    setUsers(getAll<PlatformUser>('users'));
    setLastRefresh(new Date());
  };

  useEffect(() => {
    load();
    window.addEventListener('ecotrade_data_change', load);
    const interval = setInterval(load, 30000);
    return () => {
      window.removeEventListener('ecotrade_data_change', load);
      clearInterval(interval);
    };
  }, []);

  const hotels = users.filter(u => u.role === 'business');
  const recyclers = users.filter(u => u.role === 'recycler');
  const drivers = users.filter(u => u.role === 'driver');
  const activeRoutes = collections.filter(c => c.status === 'en-route');
  const scheduledRoutes = collections.filter(c => c.status === 'scheduled');

  // Fake pins for the map visual (since we don't have real GPS in localStorage)
  const mapPins = [
    { type: 'hotel', name: 'Mille Collines', sector: 'Nyarugenge', x: 28, y: 45 },
    { type: 'hotel', name: 'Marriott', sector: 'Gasabo', x: 58, y: 35 },
    { type: 'hotel', name: 'Serena', sector: 'Nyarugenge', x: 35, y: 55 },
    { type: 'hotel', name: 'Radisson Blu', sector: 'Kicukiro', x: 50, y: 65 },
    { type: 'recycler', name: 'GreenEnergy', sector: 'Gasabo', x: 65, y: 40 },
    { type: 'recycler', name: 'EcoFuel Ltd', sector: 'Kicukiro', x: 55, y: 70 },
    { type: 'driver', name: 'Jean Pierre', sector: 'Nyarugenge', x: 32, y: 50, active: true },
    { type: 'driver', name: 'Alice M.', sector: 'Gasabo', x: 60, y: 45, active: true },
  ];

  const visiblePins = mapPins.filter(p => {
    if (layerFilter === 'all') return true;
    if (layerFilter === 'hotels') return p.type === 'hotel';
    if (layerFilter === 'recyclers') return p.type === 'recycler';
    if (layerFilter === 'routes') return p.type === 'driver';
    return true;
  });

  const pinColor = (type: string, active?: boolean) => {
    if (type === 'hotel') return 'bg-green-500';
    if (type === 'recycler') return 'bg-blue-500';
    if (type === 'driver') return active ? 'bg-yellow-400 animate-pulse' : 'bg-gray-400';
    return 'bg-gray-400';
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <h2 className="text-xl font-bold text-gray-800 dark:text-gray-200 flex items-center gap-2">
          <Map size={20} className="text-cyan-600" />
          Route Monitor — Live Map
        </h2>
        <div className="flex items-center gap-3">
          <span className="text-xs text-gray-500 dark:text-gray-400">
            Last updated: {lastRefresh.toLocaleTimeString()}
          </span>
          <button
            onClick={load}
            className="flex items-center gap-2 px-3 py-1.5 bg-cyan-600 hover:bg-cyan-700 text-white rounded-lg text-sm transition-colors"
          >
            <RefreshCw size={14} />
            Refresh
          </button>
        </div>
      </div>

      {/* KPI Row */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {[
          { label: 'Active Routes', value: activeRoutes.length, icon: <Truck size={18} />, color: 'text-blue-600 bg-blue-50 dark:bg-blue-900/20' },
          { label: 'Scheduled', value: scheduledRoutes.length, icon: <Map size={18} />, color: 'text-yellow-700 bg-yellow-50 dark:bg-yellow-900/20' },
          { label: 'Hotels Online', value: hotels.filter(h => h.status === 'active').length, icon: <Building2 size={18} />, color: 'text-green-600 bg-green-50 dark:bg-green-900/20' },
          { label: 'Recyclers Active', value: recyclers.length, icon: <Recycle size={18} />, color: 'text-cyan-600 bg-cyan-50 dark:bg-cyan-900/20' },
        ].map(({ label, value, icon, color }) => (
          <div key={label} className={`${color} rounded-xl p-4 flex items-center gap-3`}>
            <div>{icon}</div>
            <div>
              <p className="text-2xl font-bold text-gray-900 dark:text-white">{value}</p>
              <p className="text-xs text-gray-500 dark:text-gray-400">{label}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Map Panel */}
        <div className="lg:col-span-2 bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden">
          {/* Layer Toggles */}
          <div className="p-4 border-b border-gray-200 dark:border-gray-700 flex flex-wrap items-center gap-2">
            <span className="text-sm font-medium text-gray-700 dark:text-gray-300 mr-2">Layers:</span>
            {([
              { key: 'all', label: 'All', color: 'bg-gray-600' },
              { key: 'hotels', label: '🏨 Hotels', color: 'bg-green-500' },
              { key: 'recyclers', label: '♻️ Recyclers', color: 'bg-blue-500' },
              { key: 'routes', label: '🚛 Drivers', color: 'bg-yellow-400' },
            ] as const).map(({ key, label, color }) => (
              <button
                key={key}
                onClick={() => setLayerFilter(key)}
                className={`px-3 py-1 rounded-full text-xs font-medium border transition-colors ${
                  layerFilter === key
                    ? `${color} text-white border-transparent`
                    : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 border-gray-200 dark:border-gray-600 hover:bg-gray-200 dark:hover:bg-gray-600'
                }`}
              >
                {label}
              </button>
            ))}
          </div>

          {/* Visual Map Placeholder */}
          <div className="relative bg-cyan-50 dark:bg-gray-900" style={{ height: 380 }}>
            {/* Grid lines to simulate map */}
            <svg className="absolute inset-0 w-full h-full opacity-10" xmlns="http://www.w3.org/2000/svg">
              <defs>
                <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
                  <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#0891b2" strokeWidth="0.5"/>
                </pattern>
              </defs>
              <rect width="100%" height="100%" fill="url(#grid)" />
            </svg>

            {/* Kigali Sector Labels */}
            {KIGALI_SECTORS.map((sector, i) => (
              <span
                key={sector}
                className="absolute text-xs text-cyan-700 dark:text-cyan-400 font-medium opacity-40 select-none"
                style={{ left: `${(i * 17) % 80 + 5}%`, top: `${(i * 13) % 75 + 5}%` }}
              >
                {sector}
              </span>
            ))}

            {/* Route lines */}
            {activeRoutes.slice(0, 3).map((_, i) => (
              <svg key={i} className="absolute inset-0 w-full h-full pointer-events-none">
                <line
                  x1={`${30 + i * 10}%`} y1={`${45 + i * 5}%`}
                  x2={`${60 + i * 5}%`} y2={`${40 + i * 8}%`}
                  stroke="#0891b2" strokeWidth="2" strokeDasharray="6 3" opacity="0.6"
                />
              </svg>
            ))}

            {/* Map Pins */}
            {visiblePins.map((pin, i) => (
              <div
                key={i}
                className="absolute transform -translate-x-1/2 -translate-y-1/2 cursor-pointer group"
                style={{ left: `${pin.x}%`, top: `${pin.y}%` }}
              >
                <div className={`w-4 h-4 rounded-full border-2 border-white shadow-md ${pinColor(pin.type, (pin as any).active)}`} />
                <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-1 px-2 py-1 bg-gray-900 text-white text-xs rounded-md whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity z-10 pointer-events-none">
                  {pin.name} · {pin.sector}
                </div>
              </div>
            ))}

            {/* Legend */}
            <div className="absolute bottom-3 left-3 bg-white/90 dark:bg-gray-800/90 rounded-lg p-3 text-xs space-y-1 shadow">
              <div className="flex items-center gap-2"><span className="w-3 h-3 rounded-full bg-green-500 inline-block" /> Hotels</div>
              <div className="flex items-center gap-2"><span className="w-3 h-3 rounded-full bg-blue-500 inline-block" /> Recyclers</div>
              <div className="flex items-center gap-2"><span className="w-3 h-3 rounded-full bg-yellow-400 animate-pulse inline-block" /> Active Drivers</div>
              <div className="flex items-center gap-2"><span className="w-6 border-t-2 border-dashed border-cyan-600 inline-block" /> Active Route</div>
            </div>

            {/* Kigali badge */}
            <div className="absolute top-3 right-3 bg-white/90 dark:bg-gray-800/90 rounded-lg px-3 py-2 text-xs font-semibold text-gray-700 dark:text-gray-300 shadow">
              Kigali, Rwanda · -1.9441, 30.0619
            </div>
          </div>
        </div>

        {/* Alerts + Route Details Panel */}
        <div className="space-y-4">
          {/* Alerts */}
          <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
            <h3 className="font-semibold text-gray-800 dark:text-gray-200 flex items-center gap-2 mb-3">
              <AlertTriangle size={16} className="text-amber-500" />
              Alerts
            </h3>
            {activeRoutes.length === 0 && scheduledRoutes.length === 0 ? (
              <p className="text-sm text-gray-400 dark:text-gray-500 text-center py-4">No active alerts</p>
            ) : (
              <div className="space-y-2">
                {activeRoutes.length > 0 && (
                  <div className="p-2 rounded-lg bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300 text-sm">
                    {activeRoutes.length} route{activeRoutes.length > 1 ? 's' : ''} currently en-route
                  </div>
                )}
                {scheduledRoutes.length > 0 && (
                  <div className="p-2 rounded-lg bg-yellow-50 dark:bg-yellow-900/20 text-yellow-700 dark:text-yellow-300 text-sm">
                    {scheduledRoutes.length} pickup{scheduledRoutes.length > 1 ? 's' : ''} scheduled today
                  </div>
                )}
              </div>
            )}
          </div>

          {/* Active Routes List */}
          <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4">
            <h3 className="font-semibold text-gray-800 dark:text-gray-200 mb-3 flex items-center gap-2">
              <Truck size={16} className="text-cyan-600" />
              Active Collections
            </h3>
            <div className="space-y-2 max-h-64 overflow-y-auto">
              {collections.slice(0, 8).map(col => (
                <button
                  key={col.id}
                  onClick={() => setSelectedRoute(selectedRoute?.id === col.id ? null : col)}
                  className={`w-full text-left p-3 rounded-lg text-sm transition-colors border ${
                    selectedRoute?.id === col.id
                      ? 'border-cyan-500 bg-cyan-50 dark:bg-cyan-900/20'
                      : 'border-gray-100 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700/50'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <p className="font-medium text-gray-800 dark:text-gray-200 truncate">
                      {col.businessName || col.hotelName || 'Hotel'}
                    </p>
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ml-2 flex-shrink-0 ${STATUS_COLOR[col.status] || STATUS_COLOR.scheduled}`}>
                      {col.status}
                    </span>
                  </div>
                  <p className="text-xs text-gray-500 dark:text-gray-400 mt-0.5">
                    {col.wasteType} · {col.volume}kg · Driver: {col.driverName}
                  </p>
                </button>
              ))}
              {collections.length === 0 && (
                <p className="text-sm text-gray-400 dark:text-gray-500 text-center py-4">No collections found</p>
              )}
            </div>
          </div>

          {/* Route Detail */}
          {selectedRoute && (
            <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-cyan-300 dark:border-cyan-700 p-4">
              <h3 className="font-semibold text-gray-800 dark:text-gray-200 mb-3">Route Details</h3>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between"><span className="text-gray-500 dark:text-gray-400">Hotel</span><span className="font-medium">{selectedRoute.businessName || selectedRoute.hotelName}</span></div>
                <div className="flex justify-between"><span className="text-gray-500 dark:text-gray-400">Driver</span><span className="font-medium">{selectedRoute.driverName}</span></div>
                <div className="flex justify-between"><span className="text-gray-500 dark:text-gray-400">Recycler</span><span className="font-medium">{selectedRoute.recyclerName}</span></div>
                <div className="flex justify-between"><span className="text-gray-500 dark:text-gray-400">Waste</span><span className="font-medium">{selectedRoute.wasteType} · {selectedRoute.volume}kg</span></div>
                <div className="flex justify-between"><span className="text-gray-500 dark:text-gray-400">Date</span><span className="font-medium">{selectedRoute.scheduledDate}</span></div>
                <div className="flex justify-between"><span className="text-gray-500 dark:text-gray-400">Status</span>
                  <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${STATUS_COLOR[selectedRoute.status] || STATUS_COLOR.scheduled}`}>
                    {selectedRoute.status}
                  </span>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Drivers Table */}
      <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-5">
        <h3 className="font-semibold text-gray-800 dark:text-gray-200 mb-4 flex items-center gap-2">
          <Truck size={16} className="text-cyan-600" />
          Driver Fleet Status
        </h3>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-200 dark:border-gray-700">
                {['Driver', 'Status', 'Sector', 'Phone', 'Joined'].map(h => (
                  <th key={h} className="text-left text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider py-2 pr-4">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-700">
              {drivers.length === 0 ? (
                <tr><td colSpan={5} className="py-6 text-center text-gray-400 dark:text-gray-500">No drivers registered</td></tr>
              ) : drivers.map(d => (
                <tr key={d.id} className="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                  <td className="py-3 pr-4 font-medium text-gray-900 dark:text-white">{d.name}</td>
                  <td className="py-3 pr-4">
                    <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${
                      d.status === 'active' ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400' : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400'
                    }`}>
                      {d.status}
                    </span>
                  </td>
                  <td className="py-3 pr-4 text-gray-600 dark:text-gray-300">{d.location || 'Kigali'}</td>
                  <td className="py-3 pr-4 text-gray-600 dark:text-gray-300">{d.phone || '—'}</td>
                  <td className="py-3 pr-4 text-gray-500 dark:text-gray-400">{new Date(d.joinDate).toLocaleDateString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
