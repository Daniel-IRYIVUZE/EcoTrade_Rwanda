// components/dashboard/business/BusinessOverview.tsx
import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { getAll } from '../../../utils/dataStore';
import type { WasteListing, Collection, Transaction, Message } from '../../../utils/dataStore';
import {
  Package, DollarSign, Trophy, Calendar,
  MessageSquare, TrendingUp, BarChart3, Clock, PlusCircle, Leaf, Zap
} from 'lucide-react';
import StatCard from '../StatCard';
import Widget from '../Widget';
import ChartComponent from '../ChartComponent';
import PageHeader from '../../ui/PageHeader';
import StatusBadge from '../../ui/StatusBadge';
import EcoImpactPanel from '../../ui/EcoImpactPanel';
import ActivityFeed, { type ActivityItem } from '../../ui/ActivityFeed';
import { hotelProfile, revenueTrend, wasteBreakdown } from './_shared';

export default function BusinessOverview() {
  const navigate = useNavigate();
  const [listings, setListings] = useState<WasteListing[]>([]);
  const [collections, setCollections] = useState<Collection[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [messages, setMessages] = useState<Message[]>([]);

  const load = useCallback(() => {
    setListings(getAll<WasteListing>('listings'));
    setCollections(getAll<Collection>('collections'));
    setTransactions(getAll<Transaction>('transactions'));
    setMessages(getAll<Message>('messages'));
  }, []);

  useEffect(() => {
    load();
    window.addEventListener('ecotrade_data_change', load);
    return () => window.removeEventListener('ecotrade_data_change', load);
  }, [load]);

  const openListings   = listings.filter(l => l.status === 'open');
  const totalRevenue   = transactions.reduce((s, t) => s + t.amount, 0);
  const unreadMsgs     = messages.filter(m => !m.read).length;
  const activeCollect  = collections.filter(c => c.status === 'scheduled' || c.status === 'en-route');
  const sparkRevenue   = [35, 40, 45, 50, 55, 60, 65, 80, 90, 85, 95, 100];

  // Build activity feed from recent listings + collections
  const activityItems: ActivityItem[] = [
    ...openListings.slice(0, 3).map(l => ({
      id: l.id,
      icon: <Package size={14}/>,
      iconBg: 'bg-cyan-100 dark:bg-cyan-900/30',
      title: `${l.wasteType} listing — ${l.volume} ${l.unit}`,
      subtitle: `${l.bids?.length || 0} bids · Min: RWF ${l.minBid?.toLocaleString()}`,
      time: new Date(l.createdAt).toLocaleDateString(),
      badge: l.status,
      badgeColor: l.status === 'open' ? 'cyan' : 'gray',
    })),
    ...activeCollect.slice(0, 2).map(c => ({
      id: c.id,
      icon: <Calendar size={14}/>,
      iconBg: 'bg-blue-100 dark:bg-blue-900/30',
      title: `${c.wasteType} collection scheduled`,
      subtitle: `${c.scheduledDate} at ${c.scheduledTime || '—'}`,
      time: c.scheduledDate,
      badge: c.status,
      badgeColor: 'blue' as const,
    })),
  ];

  return (
    <div className="space-y-6 animate-fade-up">
      <PageHeader
        title={`Welcome back, ${hotelProfile.name}!`}
        subtitle="Here's your waste management overview"
        icon={<Leaf size={20}/>}
        badge={unreadMsgs > 0 ? `${unreadMsgs} new messages` : undefined}
        badgeColor="cyan"
        actions={
          <button onClick={() => navigate('new-listing')} className="btn-primary flex items-center gap-2 text-sm">
            <PlusCircle size={15}/> New Listing
          </button>
        }
      />

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Active Listings"
          value={openListings.length}
          icon={<Package size={22}/>}
          color="cyan"
          change="+3"
          trend="up"
          sparkline={[2, 4, 3, 5, 6, 4, 7, openListings.length]}
        />
        <StatCard
          title="Total Revenue"
          value={`RWF ${(totalRevenue / 1000).toFixed(0)}K`}
          icon={<DollarSign size={22}/>}
          color="blue"
          change="+12%"
          trend="up"
          sparkline={sparkRevenue}
        />
        <StatCard
          title="Green Score"
          value={hotelProfile.greenScore}
          icon={<Trophy size={22}/>}
          color="emerald"
          progress={hotelProfile.greenScore}
          change="+5"
          trend="up"
        />
        <StatCard
          title="Upcoming Collections"
          value={activeCollect.length}
          icon={<Clock size={22}/>}
          color="orange"
          sparkline={[1, 2, 1, 3, 2, 4, activeCollect.length]}
        />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Widget title="Revenue Trend" icon={<TrendingUp size={18} className="text-cyan-600"/>}>
          <ChartComponent type="area" data={revenueTrend} height={260} />
        </Widget>
        <Widget title="Waste Type Distribution" icon={<BarChart3 size={18} className="text-purple-600 dark:text-purple-400"/>}>
          <ChartComponent type="donut" data={wasteBreakdown} height={260} />
        </Widget>
      </div>

      {/* Lists Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Widget
          title="Active Listings"
          icon={<Package size={18} className="text-cyan-600"/>}
          action={<button onClick={() => navigate('listings')} className="text-sm text-cyan-600 hover:underline">View All</button>}
        >
          <div className="space-y-2.5">
            {openListings.slice(0, 4).map(listing => {
              const bids = Array.isArray(listing.bids) ? listing.bids : [];
              const topBid = [...bids].sort((a, b) => b.amount - a.amount)[0];
              return (
                <div key={listing.id} className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-900/40 rounded-xl hover:bg-gray-100 dark:hover:bg-gray-700/40 transition-colors cursor-pointer" onClick={() => navigate('listings')}>
                  <div>
                    <p className="text-sm font-medium text-gray-900 dark:text-white">{listing.wasteType} — {listing.volume} {listing.unit}</p>
                    <p className="text-xs text-gray-400">{bids.length} bids · Top: {topBid ? `RWF ${topBid.amount.toLocaleString()}` : '—'}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-semibold text-cyan-600 dark:text-cyan-400">RWF {listing.minBid?.toLocaleString()}</p>
                    <StatusBadge status={listing.status} size="sm" dot={false} />
                  </div>
                </div>
              );
            })}
            {openListings.length === 0 && (
              <p className="text-sm text-gray-400 dark:text-gray-500 text-center py-6">No active listings yet. <button onClick={() => navigate('new-listing')} className="text-cyan-600 hover:underline">Create one →</button></p>
            )}
          </div>
        </Widget>

        <Widget
          title="Upcoming Collections"
          icon={<Calendar size={18} className="text-blue-600 dark:text-blue-400"/>}
          action={<button onClick={() => navigate('schedule')} className="text-sm text-cyan-600 hover:underline">View Schedule</button>}
        >
          <div className="space-y-2.5">
            {activeCollect.slice(0, 4).map(col => (
              <div key={col.id} className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-900/40 rounded-xl hover:bg-gray-100 dark:hover:bg-gray-700/40 transition-colors">
                <div>
                  <p className="text-sm font-medium text-gray-900 dark:text-white">{col.wasteType} — {col.volume} {col.wasteType === 'UCO' ? 'L' : 'kg'}</p>
                  <p className="text-xs text-gray-400">{col.scheduledDate} at {col.scheduledTime || '—'}</p>
                </div>
                <StatusBadge status={col.status} size="sm" dot />
              </div>
            ))}
            {activeCollect.length === 0 && (
              <p className="text-sm text-gray-400 dark:text-gray-500 text-center py-6">No upcoming collections scheduled</p>
            )}
          </div>
        </Widget>
      </div>

      {/* Recent Messages */}
      <Widget
        title="Recent Messages"
        icon={<MessageSquare size={18} className="text-emerald-600 dark:text-emerald-400"/>}
        badge={unreadMsgs > 0 ? `${unreadMsgs} new` : undefined}
        badgeColor="cyan"
        action={<button onClick={() => navigate('messages')} className="text-sm text-cyan-600 hover:underline">View All</button>}
      >
        <div className="space-y-2">
          {messages.slice(0, 3).map(msg => (
            <div key={msg.id} className={`flex items-start gap-3 p-3 rounded-xl transition-colors ${!msg.read ? 'bg-cyan-50 dark:bg-cyan-900/20 border border-cyan-100 dark:border-cyan-800' : 'hover:bg-gray-50 dark:hover:bg-gray-700/40'}`}>
              <div className={`w-2 h-2 mt-2 rounded-full flex-shrink-0 ${!msg.read ? 'bg-cyan-500' : 'bg-transparent'}`} />
              <div className="flex-1 min-w-0">
                <div className="flex justify-between items-start">
                  <p className="text-sm font-medium text-gray-900 dark:text-white">{msg.fromName}</p>
                  <span className="text-xs text-gray-400">{new Date(msg.date).toLocaleDateString()}</span>
                </div>
                <p className="text-sm text-gray-700 dark:text-gray-300 truncate">{msg.subject}</p>
                <p className="text-xs text-gray-400 truncate">{msg.body}</p>
              </div>
            </div>
          ))}
          {messages.length === 0 && <p className="text-sm text-gray-400 dark:text-gray-500 text-center py-6">No messages yet</p>}
        </div>
      </Widget>

      {/* Activity + Eco Impact */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Widget title="Recent Activity" icon={<Zap size={18} className="text-yellow-500"/>}>
          <ActivityFeed items={activityItems} emptyText="No recent activity" />
        </Widget>
        <EcoImpactPanel
          co2Saved={collections.reduce((s, c) => s + c.volume * 0.5, 0) / 1000}
          wasteDiverted={collections.reduce((s, c) => s + c.volume, 0)}
          waterSaved={collections.reduce((s, c) => s + c.volume * 3.5, 0)}
          energySaved={collections.reduce((s, c) => s + c.volume * 0.8, 0)}
        />
      </div>
    </div>
  );
}
