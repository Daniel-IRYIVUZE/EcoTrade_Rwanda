import { useState, useEffect, useCallback } from 'react';
import { downloadPDF } from '../../../utils/dataStore';
import { collectionsAPI as colAPI } from '../../../services/api';
import type { ChartData } from '../ChartComponent';
import { DollarSign, TrendingUp, Calendar, Clock, Download } from 'lucide-react';
import StatCard from '../StatCard';
import Widget from '../Widget';
import ChartComponent from '../ChartComponent';

const StatusBadge = ({ status }: { status: string }) => {
  const styles: Record<string, string> = {
    completed: 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-200', pending: 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-300',
  };
  return <span className={`inline-flex px-2.5 py-0.5 rounded-full text-xs font-medium ${styles[status] || 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200'}`}>{status.replace(/_/g, ' ')}</span>;
};

export default function DriverEarnings() {
  const [transactions, setTransactions] = useState<any[]>([]);
  const load = useCallback(() => colAPI.list({ status: 'completed' }).then(setTransactions).catch(() => {}), []);
  useEffect(() => { load(); }, [load]);

  const totalEarned = transactions.reduce((s: number, c: any) => s + (c.earnings || 0), 0);
  const currentMonth = new Date().toISOString().slice(0, 7);
  const monthlyEarned = transactions
    .filter((c: any) => c.scheduled_date?.startsWith(currentMonth) || c.completed_at?.startsWith(currentMonth))
    .reduce((s: number, c: any) => s + (c.earnings || 0), 0);

  // Build weekly bar chart (last 7 days)
  const earningsData: ChartData = (() => {
    const days: Record<string, number> = {};
    for (let i = 6; i >= 0; i--) {
      const d = new Date(); d.setDate(d.getDate() - i);
      days[d.toISOString().split('T')[0]] = 0;
    }
    transactions.forEach((c: any) => {
      const day = (c.completed_at || c.scheduled_date || '').split('T')[0];
      if (days[day] !== undefined) days[day] += c.earnings || 0;
    });
    const labels = Object.keys(days).map(d => new Date(d).toLocaleDateString('en-GB', { weekday: 'short' }));
    return { labels, datasets: [{ label: 'Earnings (RWF)', data: Object.values(days), backgroundColor: '#0891b2' }] };
  })();

  // Build monthly trend chart (last 6 months)
  const monthlyEarnings: ChartData = (() => {
    const months: Record<string, number> = {};
    for (let i = 5; i >= 0; i--) {
      const d = new Date(); d.setMonth(d.getMonth() - i);
      months[d.toISOString().slice(0, 7)] = 0;
    }
    transactions.forEach((c: any) => {
      const m = (c.completed_at || c.scheduled_date || '').slice(0, 7);
      if (months[m] !== undefined) months[m] += c.earnings || 0;
    });
    const labels = Object.keys(months).map(m => new Date(m + '-01').toLocaleString('default', { month: 'short', year: '2-digit' }));
    return { labels, datasets: [{ label: 'Monthly Earnings (RWF)', data: Object.values(months), borderColor: '#8b5cf6', backgroundColor: 'rgba(139,92,246,0.15)', fill: true }] };
  })();

  const payouts = transactions.slice(0, 5).map((c: any) => ({
    date: c.completed_at?.split('T')[0] ?? c.scheduled_date ?? '', amount: `RWF ${(c.earnings || 0).toLocaleString()}`, route: `#${c.id}`, method: 'Mobile Money', status: 'completed',
  }));

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">My Earnings</h1>
        <button onClick={() => {
          const tableRows = payouts.map(p => `<tr><td>${p.date}</td><td>${p.route}</td><td>${p.amount}</td><td>${p.method}</td><td>${p.status}</td></tr>`).join('');
          downloadPDF('Earnings Statement', `
            <div class="stat-grid">
              <div class="stat-card"><div class="stat-value">RWF ${(totalEarned/1000).toFixed(0)}K</div><div class="stat-label">Total Earnings</div></div>
              <div class="stat-card"><div class="stat-value">RWF ${(monthlyEarned/1000).toFixed(0)}K</div><div class="stat-label">This Month</div></div>
            </div>
            <h2>Recent Payouts</h2>
            <table><thead><tr><th>Date</th><th>Route</th><th>Amount (RWF)</th><th>Method</th><th>Status</th></tr></thead>
            <tbody>${tableRows}</tbody></table>
          `);
        }} className="flex items-center gap-2 px-4 py-2 bg-white dark:bg-gray-800 border rounded-lg text-sm hover:bg-gray-50 dark:hover:bg-gray-700/50 dark:bg-gray-900"><Download size={16} /> Download Statement</button>
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <StatCard title="Total Earnings" value={`RWF ${(totalEarned / 1000).toFixed(0)}K`} icon={<DollarSign size={22} />} color="cyan" />
        <StatCard title="This Month" value={`RWF ${(monthlyEarned / 1000).toFixed(0)}K`} icon={<TrendingUp size={22} />} color="blue" />
        <StatCard title="Completed Jobs" value={transactions.length} icon={<Calendar size={22} />} color="purple" />
        <StatCard title="Avg per Job" value={transactions.length > 0 ? `RWF ${Math.round(totalEarned / transactions.length).toLocaleString()}` : 'RWF 0'} icon={<Clock size={22} />} color="orange" />
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Widget title="Weekly Earnings" icon={<TrendingUp size={20} className="text-cyan-600" />}><ChartComponent type="bar" data={earningsData} height={260} /></Widget>
        <Widget title="Monthly Trend" icon={<TrendingUp size={20} className="text-purple-600 dark:text-purple-400" />}><ChartComponent type="area" data={monthlyEarnings} height={260} /></Widget>
      </div>
      <Widget title="Recent Payouts" icon={<DollarSign size={20} className="text-green-600 dark:text-green-400" />}>
        {payouts.length === 0 ? (
          <p className="text-center text-gray-400 dark:text-gray-500 py-8 text-sm">No completed jobs yet</p>
        ) : (
          <div className="space-y-3">
            {payouts.map((payout, i) => (
              <div key={i} className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-900 rounded-lg">
                <div><p className="text-sm font-medium">{payout.date} · {payout.route}</p><p className="text-xs text-gray-500 dark:text-gray-400">{payout.method}</p></div>
                <div className="text-right"><p className="font-semibold text-green-600 dark:text-green-400">{payout.amount}</p><StatusBadge status={payout.status} /></div>
              </div>
            ))}
          </div>
        )}
      </Widget>
    </div>
  );
}
