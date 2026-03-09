import { useState, useEffect, useMemo } from 'react';
import { TrendingUp, BarChart3, Package, Trophy, Activity, Star, Download, Award } from 'lucide-react';
import StatCard from '../StatCard';
import Widget from '../Widget';
import ChartComponent from '../ChartComponent';
import { recyclersAPI, collectionsAPI, transactionsAPI } from '../../../services/api';
import { computeGreenScore } from './_shared';
import type { RecyclerProfile, Collection, Transaction } from '../../../services/api';
import { useAuth } from '../../../context/AuthContext';

// kg CO2 saved per kg of each waste type (mirrors backend factors)
const CO2_FACTORS: Record<string, number> = {
  UCO: 2.85, Glass: 0.26, 'Paper/Cardboard': 0.91, Plastic: 1.53,
  Metal: 1.80, Organic: 0.50, Electronic: 2.00, Textile: 3.60, Mixed: 0.80, Other: 0.50,
};

export default function RecyclerGreenImpact() {
  const { user: authUser } = useAuth();
  const [profile, setProfile] = useState<RecyclerProfile | null>(null);
  const [collections, setCollections] = useState<Collection[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);

  useEffect(() => {
    recyclersAPI.me().then(setProfile).catch(() => {});
    collectionsAPI.list({ limit: 500 }).then(setCollections).catch(() => {});
    transactionsAPI.mine({ limit: 500 }).then(setTransactions).catch(() => {});
  }, []);

  const completed = useMemo(() => collections.filter(c => c.status === 'completed'), [collections]);

  // Total kg collected from completed collections
  const totalCollectedKg = useMemo(
    () => completed.reduce((sum, c) => sum + (c.actual_volume ?? c.volume ?? 0), 0),
    [completed],
  );

  // Use DB field if non-zero, else computed
  const totalKg = (profile?.total_collected && profile.total_collected > 0)
    ? profile.total_collected
    : totalCollectedKg;

  // CO2 saved by waste type
  const co2SavedKg = useMemo(() => {
    return completed.reduce((sum, c) => {
      const factor = CO2_FACTORS[c.waste_type ?? 'Other'] ?? 0.5;
      const vol = c.actual_volume ?? c.volume ?? 0;
      return sum + factor * vol;
    }, 0);
  }, [completed]);

  // Trees equivalent: 1 tree absorbs ~21.8 kg CO2/year → trees = co2/21.8
  const treesEquivalent = Math.round(co2SavedKg / 21.8);

  const greenScore = computeGreenScore(profile?.green_score, totalCollectedKg, completed.length);

  const displayName = profile?.company_name || authUser?.name || 'Your Company';

  // Revenue trend for chart (last 6 months)
  const impactTrend = useMemo(() => {
    const now = new Date();
    const months: string[] = [];
    const co2vals: number[] = [];
    for (let i = 5; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      months.push(d.toLocaleString('default', { month: 'short' }));
      const kg = completed
        .filter(c => {
          const cd = new Date(c.completed_at || c.created_at);
          return cd.getFullYear() === d.getFullYear() && cd.getMonth() === d.getMonth();
        })
        .reduce((s, c) => {
          const factor = CO2_FACTORS[c.waste_type ?? 'Other'] ?? 0.5;
          return s + factor * (c.actual_volume ?? c.volume ?? 0);
        }, 0);
      co2vals.push(Math.round(kg));
    }
    return {
      labels: months,
      datasets: [{ data: co2vals, borderColor: '#059669', backgroundColor: 'rgba(5,150,105,0.15)', fill: true }],
    };
  }, [completed]);

  // Collections by waste type (for breakdown)
  const byType = useMemo(() => {
    const map: Record<string, { volume: number; co2: number }> = {};
    completed.forEach(c => {
      const t = c.waste_type ?? 'Other';
      const vol = c.actual_volume ?? c.volume ?? 0;
      const co2 = (CO2_FACTORS[t] ?? 0.5) * vol;
      if (!map[t]) map[t] = { volume: 0, co2: 0 };
      map[t].volume += vol;
      map[t].co2 += co2;
    });
    return map;
  }, [completed]);

  const typeColors: Record<string, string> = {
    UCO: 'bg-cyan-100 dark:bg-cyan-900/30 text-cyan-700 dark:text-cyan-400',
    Glass: 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300',
    'Paper/Cardboard': 'bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-300',
    Organic: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
    Plastic: 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-300',
    Metal: 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300',
    Electronic: 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-300',
    Textile: 'bg-pink-100 dark:bg-pink-900/30 text-pink-700 dark:text-pink-300',
    Other: 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-400',
    Mixed: 'bg-orange-100 dark:bg-orange-900/30 text-orange-700 dark:text-orange-300',
  };

  // Total revenue from completed transactions
  const totalRevenue = useMemo(
    () => transactions.filter(t => t.status === 'completed').reduce((s, t) => s + (t.net_amount ?? 0), 0),
    [transactions],
  );

  const handleDownloadCertificate = () => {
    const today = new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
    const certText = [
      '══════════════════════════════════════════════════════',
      '        ECOTRADE RWANDA — GREEN RECYCLER CERTIFICATE',
      '══════════════════════════════════════════════════════',
      '',
      'This certifies that',
      '',
      `  ${displayName}`,
      '',
      `has achieved a GREEN SCORE OF ${greenScore}/100`,
      'demonstrating exemplary environmental performance and',
      'commitment to sustainable waste recycling.',
      '',
      `  Issued on: ${today}`,
      '  Platform : EcoTrade Rwanda',
      '',
      '══════════════════════════════════════════════════════',
    ].join('\n');
    const blob = new Blob([certText], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `EcoTrade_GreenCertificate_${displayName.replace(/\s+/g, '_')}.txt`;
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Green Impact</h1>

      {greenScore >= 100 && (
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl p-5 text-white shadow-lg">
          <div className="flex items-center gap-3">
            <Award size={32} className="flex-shrink-0" />
            <div>
              <p className="font-bold text-lg">🎉 Perfect Green Score Achieved!</p>
              <p className="text-green-100 text-sm">{displayName} has reached 100/100 — download your certification.</p>
            </div>
          </div>
          <button
            onClick={handleDownloadCertificate}
            className="flex items-center gap-2 px-5 py-2.5 bg-white text-green-700 rounded-lg font-semibold text-sm hover:bg-green-50 transition-colors flex-shrink-0"
          >
            <Download size={16} /> Download Certificate
          </button>
        </div>
      )}

      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <StatCard
          title="Green Score"
          value={Math.round(greenScore)}
          icon={<Trophy size={22} />}
          color="cyan"
          progress={Math.min(Math.round(greenScore), 100)}
        />
        <StatCard
          title="Waste Recycled"
          value={totalKg >= 1000 ? `${(totalKg / 1000).toFixed(2)}t` : `${Math.round(totalKg)} kg`}
          icon={<Package size={22} />}
          color="blue"
          subtitle={`${completed.length} collections`}
        />
        <StatCard
          title="CO₂ Saved"
          value={co2SavedKg >= 1000 ? `${(co2SavedKg / 1000).toFixed(2)}t` : `${Math.round(co2SavedKg)} kg`}
          icon={<Activity size={22} />}
          color="purple"
        />
        <StatCard
          title="Trees Equivalent"
          value={treesEquivalent}
          icon={<Star size={22} />}
          color="orange"
        />
      </div>
      <Widget title="CO₂ Saved Over Time (kg)" icon={<TrendingUp size={20} className="text-green-600 dark:text-green-400" />}>
        <ChartComponent type="area" data={impactTrend} height={280} />
      </Widget>
      <Widget title="Impact Breakdown by Waste Type" icon={<BarChart3 size={20} className="text-cyan-600" />}>
        {Object.keys(byType).length === 0 ? (
          <p className="text-sm text-gray-400 dark:text-gray-500 text-center py-8">
            No completed collections yet. Complete collections to see your breakdown.
          </p>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {Object.entries(byType).map(([type, { volume, co2 }]) => (
              <div key={type} className={`p-4 rounded-lg ${typeColors[type] ?? typeColors.Other}`}>
                <p className="text-sm font-medium">{type}</p>
                <p className="text-xl font-bold mt-1">
                  {volume >= 1000 ? `${(volume / 1000).toFixed(2)} t` : `${Math.round(volume)} kg`}
                </p>
                <p className="text-xs mt-1 opacity-80">{Math.round(co2)} kg CO₂ saved</p>
              </div>
            ))}
          </div>
        )}
      </Widget>
      {totalRevenue > 0 && (
        <Widget title="Revenue Summary" icon={<TrendingUp size={20} className="text-cyan-600" />}>
          <p className="text-3xl font-bold text-cyan-600">RWF {totalRevenue.toLocaleString()}</p>
          <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">Total net revenue from completed transactions</p>
        </Widget>
      )}
    </div>
  );
}
