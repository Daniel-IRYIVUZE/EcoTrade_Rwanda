// components/dashboard/driver/DriverTodaysRoute.tsx
import { useState, useEffect, useCallback } from 'react';
import { getAll, update as dsUpdate } from '../../../utils/dataStore';
import type { Collection } from '../../../utils/dataStore';
import {
  Map, CheckCircle, DollarSign, Phone, Clock, Navigation,
  Package, MapPin, Star, ChevronRight
} from 'lucide-react';
import StatCard from '../StatCard';
import PageHeader from '../../ui/PageHeader';
import StatusBadge from '../../ui/StatusBadge';
import { driverProfile, todaysStops } from './_shared';

export default function DriverTodaysRoute() {
  const [collections, setCollections] = useState<Collection[]>([]);
  const [flash, setFlash] = useState<string | null>(null);

  const load = useCallback(() => {
    const today = new Date().toISOString().split('T')[0];
    const all = getAll<Collection>('collections');
    const todayItems = all.filter(c => c.scheduledDate.startsWith(today) && c.driverName === driverProfile.name);
    setCollections(todayItems.length > 0 ? todayItems : all.filter(c => c.status === 'scheduled' || c.status === 'en-route').slice(0, 5));
  }, []);

  useEffect(() => {
    load();
    window.addEventListener('ecotrade_data_change', load);
    return () => window.removeEventListener('ecotrade_data_change', load);
  }, [load]);

  const stops = collections.length > 0 ? collections.map((c, idx) => ({
    id: c.id, hotel: c.hotelName, address: c.location || 'Kigali', type: c.wasteType,
    quantity: `${c.volume} ${c.wasteType === 'UCO' ? 'L' : 'kg'}`,
    time: c.scheduledTime || `0${9 + idx}:00 AM`, status: c.status, contact: '',
    notes: c.notes || '', _dsId: c.id,
  })) : todaysStops;

  const completedStops = stops.filter(s => s.status === 'completed' || s.status === 'collected' || s.status === 'verified').length;
  const totalStops = stops.length;
  const progressPct = totalStops > 0 ? Math.round((completedStops / totalStops) * 100) : 0;

  const handleMarkCollected = (dsId: string | undefined, _stopId: number | string) => {
    if (dsId) {
      dsUpdate<Collection>('collections', String(dsId), { status: 'collected', completedAt: new Date().toISOString() });
    }
    setFlash(`Stop marked as collected!`);
    setTimeout(() => setFlash(null), 2500);
  };

  const handleNavigate = (address: string) => {
    window.open(`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(address + ', Kigali, Rwanda')}`, '_blank');
  };

  const handleReportIssue = (stopId: number | string) => {
    setFlash(`Issue reported for stop #${stopId}. Dispatch has been notified.`);
    setTimeout(() => setFlash(null), 3000);
  };

  return (
    <div className="space-y-6 animate-fade-up">
      {flash && (
        <div className="flex items-center gap-2 bg-emerald-50 dark:bg-emerald-900/20 border border-emerald-200 dark:border-emerald-800 text-emerald-700 dark:text-emerald-400 px-4 py-2.5 rounded-xl text-sm animate-slide-down">
          <CheckCircle size={15}/> {flash}
        </div>
      )}

      <PageHeader
        title="Today's Route"
        subtitle={`Route KG-01 · ${new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}`}
        icon={<Navigation size={20}/>}
        badge={`${completedStops}/${totalStops} stops`}
        badgeColor={progressPct === 100 ? 'emerald' : 'cyan'}
        actions={
          <div className="flex gap-2">
            <button className="btn-secondary flex items-center gap-1.5 text-sm" onClick={() => {
              const activeStop = stops.find(s => s.status === 'en-route' || s.status === 'in_progress' || s.status === 'scheduled');
              if (activeStop) handleNavigate(activeStop.address);
            }}><Navigation size={14}/> Navigate</button>
            <button className="btn-primary flex items-center gap-1.5 text-sm" onClick={() => { window.open('tel:+250788000000'); }}><Phone size={14}/> Dispatch</button>
          </div>
        }
      />

      {/* Driver Profile Card */}
      <div className="bg-white dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700 p-5 flex items-center gap-4">
        <div className="w-14 h-14 rounded-2xl bg-cyan-500 flex items-center justify-center text-white text-2xl font-bold flex-shrink-0">
          {driverProfile.name.charAt(0)}
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-base font-bold text-gray-900 dark:text-white">{driverProfile.name}</p>
          <p className="text-sm text-gray-400">{driverProfile.vehicle} · {driverProfile.plate}</p>
        </div>
        <div className="text-right flex-shrink-0">
          <div className="flex items-center gap-1 justify-end text-yellow-500">
            <Star size={14} className="fill-yellow-500"/> <span className="text-sm font-bold">{driverProfile.rating}</span>
          </div>
          <p className="text-xs text-gray-400">{driverProfile.totalTrips} total trips</p>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <StatCard title="Stops Done"      value={`${completedStops}/${totalStops}`} icon={<CheckCircle size={20}/>} color="cyan"   progress={progressPct} />
        <StatCard title="Current Stop"    value={`${Math.min(completedStops + 1, totalStops)} of ${totalStops}`}   icon={<MapPin size={20}/>}     color="blue" />
        <StatCard title="Total Weight"    value="1,530 kg"                            icon={<Package size={20}/>}    color="purple" />
        <StatCard title="Est. Earnings"   value="RWF 45K"                             icon={<DollarSign size={20}/>} color="orange" />
      </div>

      {/* Progress Bar */}
      <div className="bg-white dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700 p-5">
        <div className="flex items-center justify-between mb-3">
          <p className="text-sm font-semibold text-gray-900 dark:text-white">Route Progress</p>
          <span className="text-sm font-bold text-cyan-600 dark:text-cyan-400">{progressPct}%</span>
        </div>
        <div className="w-full h-3 bg-gray-100 dark:bg-gray-700 rounded-full overflow-hidden">
          <div
            className="h-full bg-cyan-500 rounded-full transition-all duration-700"
            style={{ width: `${progressPct}%` }}
          />
        </div>
        <div className="flex justify-between mt-2 text-xs text-gray-400">
          <span>{completedStops} completed</span>
          <span>{totalStops - completedStops} remaining</span>
        </div>
      </div>

      {/* Route Map Placeholder */}
      <div className="bg-white dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700 overflow-hidden">
        <div className="px-5 py-4 border-b border-gray-200 dark:border-gray-700 flex items-center gap-2">
          <Map size={16} className="text-cyan-600"/>
          <h3 className="text-sm font-semibold text-gray-900 dark:text-white">Live Route Map</h3>
          <span className="ml-auto text-xs text-gray-400">Kigali, Rwanda</span>
        </div>
        <div className="bg-cyan-50 dark:bg-cyan-900/10 h-48 flex items-center justify-center relative">
          {/* Stylized map placeholder with stop markers */}
          <div className="absolute inset-0 flex items-center justify-center gap-12">
            {stops.slice(0, 4).map((stop, i) => (
              <div key={stop.id} className="flex flex-col items-center gap-1">
                <div className={`w-8 h-8 rounded-full border-2 flex items-center justify-center text-xs font-bold ${(stop.status === 'completed' || stop.status === 'collected') ? 'bg-emerald-500 border-emerald-600 text-white' : stop.status === 'en-route' || stop.status === 'in_progress' ? 'bg-cyan-600 border-cyan-700 text-white animate-pulse' : 'bg-white border-gray-300 text-gray-600'}`}>
                  {i + 1}
                </div>
                <span className="text-xs text-gray-500 dark:text-gray-400 truncate max-w-16 text-center">{stop.hotel?.split(' ')[0]}</span>
              </div>
            ))}
          </div>
          <div className="text-center text-gray-400 dark:text-gray-500 mt-20">
            <p className="text-xs">Interactive map with Leaflet.js</p>
          </div>
        </div>
      </div>

      {/* Stop Schedule */}
      <div className="bg-white dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700">
        <div className="px-5 py-4 border-b border-gray-200 dark:border-gray-700 flex items-center gap-2">
          <MapPin size={16} className="text-cyan-600"/>
          <h3 className="text-sm font-semibold text-gray-900 dark:text-white">Stop Schedule</h3>
          <span className="ml-auto text-xs bg-cyan-100 dark:bg-cyan-900/30 text-cyan-700 dark:text-cyan-300 px-2 py-0.5 rounded-full">{totalStops} stops</span>
        </div>
        <div className="divide-y divide-gray-100 dark:divide-gray-800">
          {stops.map((stop, idx) => {
            const isDone = stop.status === 'completed' || stop.status === 'collected' || stop.status === 'verified';
            const isActive = stop.status === 'en-route' || stop.status === 'in_progress';
            return (
              <div key={stop.id} className={`px-5 py-4 transition-colors ${isActive ? 'bg-cyan-50 dark:bg-cyan-900/15 border-l-4 border-cyan-500' : 'hover:bg-gray-50 dark:hover:bg-gray-700/30'}`}>
                <div className="flex items-start gap-4">
                  {/* Step indicator */}
                  <div className="flex flex-col items-center flex-shrink-0">
                    <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold ${isDone ? 'bg-emerald-500 text-white' : isActive ? 'bg-cyan-600 text-white' : 'bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-400'}`}>
                      {isDone ? <CheckCircle size={16}/> : idx + 1}
                    </div>
                    {idx < stops.length - 1 && (
                      <div className={`w-0.5 h-6 mt-1 ${isDone ? 'bg-emerald-400' : 'bg-gray-200 dark:bg-gray-700'}`} />
                    )}
                  </div>

                  {/* Stop details */}
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-2">
                      <div>
                        <p className="font-semibold text-gray-900 dark:text-white">{stop.hotel}</p>
                        <p className="text-sm text-gray-400">{stop.address}</p>
                      </div>
                      <StatusBadge status={stop.status} size="sm" dot />
                    </div>
                    <div className="mt-2 flex flex-wrap gap-3 text-xs text-gray-500 dark:text-gray-400">
                      <span className="flex items-center gap-1"><Clock size={11}/> {stop.time}</span>
                      <span className="flex items-center gap-1"><Package size={11}/> {stop.type} — {stop.quantity}</span>
                      {stop.contact && <span className="flex items-center gap-1"><Phone size={11}/> {stop.contact}</span>}
                    </div>
                    {stop.notes && <p className="mt-1 text-xs text-gray-400 italic">📝 {stop.notes}</p>}

                    {(isActive || stop.status === 'scheduled') && (
                      <div className="mt-3 flex flex-wrap gap-2">
                        <button
                          onClick={() => handleMarkCollected((stop as any)._dsId, stop.id)}
                          className="flex items-center gap-1.5 px-3 py-1.5 text-xs bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 font-medium transition-colors"
                        >
                          <CheckCircle size={12}/> Mark Collected
                        </button>
                        <button
                          onClick={() => handleNavigate(stop.address)}
                          className="flex items-center gap-1.5 px-3 py-1.5 text-xs btn-secondary rounded-lg font-medium">
                          <Navigation size={12}/> Navigate
                        </button>
                        <button
                          onClick={() => handleReportIssue(stop.id)}
                          className="flex items-center gap-1.5 px-3 py-1.5 text-xs btn-secondary rounded-lg font-medium">
                          Report Issue
                        </button>
                      </div>
                    )}
                    {isDone && (
                      <div className="mt-2 flex items-center gap-1 text-xs text-emerald-600 dark:text-emerald-400">
                        <CheckCircle size={12}/> Collection verified
                      </div>
                    )}
                  </div>

                  {/* Arrow */}
                  <ChevronRight size={16} className="text-gray-300 dark:text-gray-600 flex-shrink-0 mt-1" />
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
