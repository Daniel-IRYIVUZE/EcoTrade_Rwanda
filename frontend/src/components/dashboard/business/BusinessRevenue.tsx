// components/dashboard/business/BusinessRevenue.tsx
import { useState, useEffect } from 'react';
import { getAll } from '../../../utils/dataStore';
import type { Transaction, PlatformUser } from '../../../utils/dataStore';
import { DollarSign, TrendingUp, BarChart3, Clock } from 'lucide-react';
import StatCard from '../StatCard';
import Widget from '../Widget';
import ChartComponent from '../ChartComponent';
import { revenueTrend } from './_shared';

export default function BusinessRevenue() {
  const [transactions, setTransactions] = useState<Transaction[]>([]);

  useEffect(() => {
    const load = () => {
      const users = getAll<PlatformUser>('users');
      const hotel = users.find(u => u.role === 'business');
      const hotelName = hotel?.name || 'Mille Collines Business';
      
      const allTransactions = getAll<Transaction>('transactions');
      // Filter transactions where this business is the seller (from field)
      const businessTransactions = allTransactions.filter(t => t.from === hotelName);
      setTransactions(businessTransactions);
    };
    load();
    window.addEventListener('ecotrade_data_change', load);
    return () => window.removeEventListener('ecotrade_data_change', load);
  }, []);

  const totalRevenue = transactions.filter(t => t.status === 'completed').reduce((s, t) => s + t.amount, 0);
  const currentMonth = new Date().toISOString().slice(0, 7);
  const thisMonth = transactions.filter(t => t.status === 'completed' && t.date?.startsWith(currentMonth)).reduce((s, t) => s + t.amount, 0);
  const avgPerListing = transactions.length > 0 ? Math.round(totalRevenue / transactions.length) : 0;
  const pendingPayouts = transactions.filter(t => t.status === 'pending').reduce((s, t) => s + t.amount, 0);

  const wasteTypeRevenue: Record<string, number> = {};
  transactions.forEach(t => {
    wasteTypeRevenue[t.wasteType] = (wasteTypeRevenue[t.wasteType] || 0) + t.amount;
  });

  const revenueByType = {
    labels: Object.keys(wasteTypeRevenue).length > 0 ? Object.keys(wasteTypeRevenue) : ['UCO', 'Glass', 'Paper/Cardboard', 'Organic Waste'],
    datasets: [{
      data: Object.keys(wasteTypeRevenue).length > 0 ? Object.values(wasteTypeRevenue) : [0, 0, 0, 0],
      backgroundColor: '#0891b2'
    }]
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Revenue</h1>
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <StatCard title="Total Revenue" value={`RWF ${(totalRevenue / 1000).toFixed(0)}K`} icon={<DollarSign size={22} />} color="cyan" change={totalRevenue > 0 ? '+18%' : '0%'} />
        <StatCard title="This Month" value={`RWF ${(thisMonth / 1000).toFixed(0)}K`} icon={<TrendingUp size={22} />} color="blue" change={thisMonth > 0 ? '+12%' : '0%'} />
        <StatCard title="Avg per Listing" value={`RWF ${(avgPerListing / 1000).toFixed(0)}K`} icon={<BarChart3 size={22} />} color="purple" />
        <StatCard title="Pending Payouts" value={`RWF ${(pendingPayouts / 1000).toFixed(0)}K`} icon={<Clock size={22} />} color="yellow" />
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Widget title="Monthly Revenue" icon={<TrendingUp size={20} className="text-cyan-600" />}><ChartComponent type="line" data={revenueTrend} height={280} /></Widget>
        <Widget title="Revenue by Waste Type" icon={<BarChart3 size={20} className="text-purple-600 dark:text-purple-400" />}><ChartComponent type="bar" data={revenueByType} height={280} /></Widget>
      </div>
    </div>
  );
}
