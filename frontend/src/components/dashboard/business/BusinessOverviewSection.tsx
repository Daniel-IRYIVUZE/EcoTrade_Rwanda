import { Package, DollarSign, Leaf, CheckCircle, AlertCircle } from 'lucide-react';
import { useState, useEffect } from 'react';
import { listingsAPI, collectionsAPI, transactionsAPI } from '../../../services/api';

const BusinessOverviewSection = () => {
  const [stats, setStats] = useState({
    totalListings: 0,
    activeListings: 0,
    totalRevenue: 0,
    pendingPickups: 0,
    wasteReduction: 0,
  });

  useEffect(() => {
    Promise.all([
      listingsAPI.mine().catch(() => []),
      collectionsAPI.list({ limit: 200 } as Parameters<typeof collectionsAPI.list>[0]).catch(() => []),
      transactionsAPI.mine({ limit: 200 } as Parameters<typeof transactionsAPI.mine>[0]).catch(() => []),
    ]).then(([listings, collections, transactions]) => {
      const activeListings = listings.filter((l: { status: string }) => l.status === 'open').length;
      const pendingPickups = collections.filter((c: { status: string }) =>
        c.status === 'scheduled' || c.status === 'en_route'
      ).length;
      const totalRevenue = transactions.reduce((s: number, t: { net_amount?: number }) => s + (t.net_amount || 0), 0);
      const wasteReduction = listings
        .filter((l: { status: string }) => l.status === 'collected' || l.status === 'completed')
        .reduce((s: number, l: { volume?: number }) => s + (l.volume || 0), 0);
      setStats({
        totalListings: listings.length,
        activeListings,
        totalRevenue,
        pendingPickups,
        wasteReduction,
      });
    });
  }, []);

  return (
    <section className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4 sm:gap-6">
      <div className="bg-white dark:bg-gray-800 p-4 sm:p-6 rounded-xl border border-gray-200 dark:border-gray-700 hover:shadow-lg transition-shadow">
        <div className="flex items-center justify-between mb-2">
          <span className="text-gray-600 dark:text-gray-400 text-sm font-medium">Total Listings</span>
          <Package size={20} className="text-cyan-600" />
        </div>
        <div className="text-2xl sm:text-3xl font-bold text-gray-900 dark:text-white">{stats.totalListings}</div>
        <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">All time listings</p>
      </div>

      <div className="bg-white dark:bg-gray-800 p-4 sm:p-6 rounded-xl border border-gray-200 dark:border-gray-700 hover:shadow-lg transition-shadow">
        <div className="flex items-center justify-between mb-2">
          <span className="text-gray-600 dark:text-gray-400 text-sm font-medium">Active Now</span>
          <CheckCircle size={20} className="text-cyan-600" />
        </div>
        <div className="text-2xl sm:text-3xl font-bold text-gray-900 dark:text-white">{stats.activeListings}</div>
        <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">Available for pickup</p>
      </div>

      <div className="bg-white dark:bg-gray-800 p-4 sm:p-6 rounded-xl border border-gray-200 dark:border-gray-700 hover:shadow-lg transition-shadow">
        <div className="flex items-center justify-between mb-2">
          <span className="text-gray-600 dark:text-gray-400 text-sm font-medium">Total Revenue</span>
          <DollarSign size={20} className="text-cyan-600" />
        </div>
        <div className="text-2xl sm:text-3xl font-bold text-gray-900 dark:text-white">
          Rwf {stats.totalRevenue >= 1_000_000
            ? `${(stats.totalRevenue / 1_000_000).toFixed(1)}M`
            : `${(stats.totalRevenue / 1000).toFixed(0)}K`}
        </div>
        <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">Lifetime earnings</p>
      </div>

      <div className="bg-white dark:bg-gray-800 p-4 sm:p-6 rounded-xl border border-gray-200 dark:border-gray-700 hover:shadow-lg transition-shadow">
        <div className="flex items-center justify-between mb-2">
          <span className="text-gray-600 dark:text-gray-400 text-sm font-medium">Pending Pickups</span>
          <AlertCircle size={20} className="text-amber-600 dark:text-amber-400" />
        </div>
        <div className="text-2xl sm:text-3xl font-bold text-gray-900 dark:text-white">{stats.pendingPickups}</div>
        <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">Waiting for pickup</p>
      </div>

      <div className="bg-white dark:bg-gray-800 p-4 sm:p-6 rounded-xl border border-gray-200 dark:border-gray-700 hover:shadow-lg transition-shadow">
        <div className="flex items-center justify-between mb-2">
          <span className="text-gray-600 dark:text-gray-400 text-sm font-medium">Waste Reduced</span>
          <Leaf size={20} className="text-cyan-600" />
        </div>
        <div className="text-2xl sm:text-3xl font-bold text-gray-900 dark:text-white">{stats.wasteReduction.toFixed(0)}kg</div>
        <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">Diverted from landfill</p>
      </div>
    </section>
  );
};

export default BusinessOverviewSection;
