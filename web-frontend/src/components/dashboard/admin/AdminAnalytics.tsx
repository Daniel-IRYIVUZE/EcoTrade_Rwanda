import { useState, useEffect } from 'react';
import { BarChart2, TrendingUp, Leaf } from 'lucide-react';
import { getAll, downloadPDF } from '../../../utils/dataStore';
import type { WasteListing, Transaction, PlatformUser, Collection } from '../../../utils/dataStore';
import ChartComponent from '../ChartComponent';

export default function AdminAnalytics() {
  const [listings, setListings] = useState<WasteListing[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [users, setUsers] = useState<PlatformUser[]>([]);
  const [collections, setCollections] = useState<Collection[]>([]);
  const [period, setPeriod] = useState<'week' | 'month' | 'year'>('month');

  const load = () => {
    setListings(getAll<WasteListing>('listings'));
    setTransactions(getAll<Transaction>('transactions'));
    setUsers(getAll<PlatformUser>('users'));
    setCollections(getAll<Collection>('collections'));
  };
  useEffect(() => { load(); window.addEventListener('ecotrade_data_change', load); return () => window.removeEventListener('ecotrade_data_change', load); }, []);

  const wasteByType = listings.reduce((acc, l) => { acc[l.wasteType] = (acc[l.wasteType] || 0) + l.volume; return acc; }, {} as Record<string, number>);
  const usersByRole = users.reduce((acc, u) => { acc[u.role] = (acc[u.role] || 0) + 1; return acc; }, {} as Record<string,number>);
  const completedTxn = transactions.filter(t => t.status === 'completed');
  const totalRevenue = completedTxn.reduce((s, t) => s + t.amount, 0);
  const totalCO2 = collections.reduce((s, c) => s + c.volume * 0.5, 0);

  const wasteChartData = {
    labels: Object.keys(wasteByType),
    datasets: [{ label: 'Quantity (kg)', data: Object.values(wasteByType), backgroundColor: '#06b6d4' }]
  };

  const roleChartData = {
    labels: Object.keys(usersByRole),
    datasets: [{ label: 'Users', data: Object.values(usersByRole), backgroundColor: ['#06b6d4','#10b981','#f59e0b','#8b5cf6','#64748b'] }]
  };

  const txnChartData = {
    labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
    datasets: [{ label: 'Revenue (RWF)', data: [13000, 22500, 27000, 30000].slice(0, period === 'week' ? 1 : period === 'month' ? 4 : 12), backgroundColor: '#10b981' }]
  };

  const handleExportReport = () => {
    const summaryRows = [
      ['Total Users', String(users.length)],
      ['Total Listings', String(listings.length)],
      ['Completed Transactions', String(completedTxn.length)],
      ['Total Revenue (RWF)', `RWF ${totalRevenue.toLocaleString()}`],
      ['Waste Diverted (kg/L)', String(collections.reduce((s, c) => s + c.volume, 0))],
      ['CO\u2082 Saved (est. kg)', totalCO2.toFixed(1)],
      ['Active Hotels', String(users.filter(u => u.role === 'business' && u.status === 'active').length)],
      ['Active Recyclers', String(users.filter(u => u.role === 'recycler' && u.status === 'active').length)],
      ['Active Drivers', String(users.filter(u => u.role === 'driver' && u.status === 'active').length)],
    ];
    const summaryHtml = summaryRows.map(([m, v]) => `<tr><td>${m}</td><td><strong>${v}</strong></td></tr>`).join('');
    const wasteHtml = Object.entries(wasteByType).map(([k, v]) => `<tr><td>${k}</td><td>${v}</td></tr>`).join('') || '<tr><td colspan="2">No data</td></tr>';
    const roleHtml = Object.entries(usersByRole).map(([k, v]) => `<tr><td>${k}</td><td>${v}</td></tr>`).join('');
    const userRows = users.map(u => `<tr><td>${u.id}</td><td>${u.name}</td><td>${u.role}</td><td>${u.status}</td><td>${new Date(u.joinDate).toLocaleDateString()}</td></tr>`).join('');
    downloadPDF('Platform Analytics Report', `
      <div class="stat-grid">
        <div class="stat-card"><div class="stat-value">RWF ${(totalRevenue/1000).toFixed(0)}K</div><div class="stat-label">Total Revenue</div></div>
        <div class="stat-card"><div class="stat-value">${users.filter(u => u.status === 'active').length}</div><div class="stat-label">Active Users</div></div>
        <div class="stat-card"><div class="stat-value">${listings.length}</div><div class="stat-label">Total Listings</div></div>
        <div class="stat-card"><div class="stat-value">${completedTxn.length}</div><div class="stat-label">Completed Txns</div></div>
      </div>
      <h2>Platform Summary</h2>
      <table><thead><tr><th>Metric</th><th>Value</th></tr></thead><tbody>${summaryHtml}</tbody></table>
      <h2>Waste Volume by Type</h2>
      <table><thead><tr><th>Waste Type</th><th>Volume (kg/L)</th></tr></thead><tbody>${wasteHtml}</tbody></table>
      <h2>Users by Role</h2>
      <table><thead><tr><th>Role</th><th>Count</th></tr></thead><tbody>${roleHtml}</tbody></table>
      <h2>All Users</h2>
      <table><thead><tr><th>ID</th><th>Name</th><th>Role</th><th>Status</th><th>Join Date</th></tr></thead><tbody>${userRows}</tbody></table>
    `);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <h2 className="text-xl font-bold text-gray-800 flex items-center gap-2"><BarChart2 size={20} className="text-cyan-600"/>Platform Analytics</h2>
        <div className="flex gap-2">
          <select value={period} onChange={e => setPeriod(e.target.value as any)} className="border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500">
            <option value="week">This Week</option>
            <option value="month">This Month</option>
            <option value="year">This Year</option>
          </select>
          <button onClick={handleExportReport} className="px-3 py-2 bg-cyan-600 text-white rounded-lg text-sm hover:bg-cyan-700">Export PDF Report</button>
        </div>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {[
          { label: 'Total Revenue', value: `RWF ${(totalRevenue/1000).toFixed(0)}K`, icon: <TrendingUp size={18} className="text-green-500"/> },
          { label: 'Active Users', value: users.filter(u => u.status === 'active').length, icon: <BarChart2 size={18} className="text-cyan-500"/> },
          { label: 'CO₂ Saved', value: `${totalCO2.toFixed(0)} kg`, icon: <Leaf size={18} className="text-teal-500"/> },
          { label: 'Transactions', value: completedTxn.length, icon: <BarChart2 size={18} className="text-blue-500"/> },
        ].map(s => (
          <div key={s.label} className="bg-white border rounded-xl p-4 shadow-sm">
            <div className="flex items-center gap-2 mb-2">{s.icon}<span className="text-xs text-gray-500">{s.label}</span></div>
            <p className="text-xl font-bold text-gray-800">{s.value}</p>
          </div>
        ))}
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        <div className="bg-white border rounded-xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-700 mb-3">Waste by Type (kg)</h3>
          <ChartComponent type="bar" data={wasteChartData} height={240}/>
        </div>
        <div className="bg-white border rounded-xl p-4 shadow-sm">
          <h3 className="font-semibold text-gray-700 mb-3">Users by Role</h3>
          <ChartComponent type="pie" data={roleChartData as any} height={240}/>
        </div>
        <div className="bg-white border rounded-xl p-4 shadow-sm md:col-span-2">
          <h3 className="font-semibold text-gray-700 mb-3">Revenue Trend</h3>
          <ChartComponent type="line" data={txnChartData} height={200}/>
        </div>
      </div>
    </div>
  );
}
