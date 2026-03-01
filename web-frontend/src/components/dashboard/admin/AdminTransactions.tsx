import { useState, useEffect } from 'react';
import { Search, Eye, X, DollarSign, CheckCircle, AlertTriangle, RotateCcw } from 'lucide-react';
import { getAll, update, downloadCSV } from '../../../utils/dataStore';
import type { Transaction } from '../../../utils/dataStore';

const STATUS_COLORS: Record<string, string> = {
  completed: 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400',
  pending: 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-300',
  failed: 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-300',
  disputed: 'bg-orange-100 dark:bg-orange-300/30 text-orange-300 dark:text-orange-300',
  refunded: 'bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-300',
};

export default function AdminTransactions() {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selected, setSelected] = useState<Transaction | null>(null);

  const load = () => setTransactions(getAll<Transaction>('transactions'));
  useEffect(() => { load(); window.addEventListener('ecotrade_data_change', load); return () => window.removeEventListener('ecotrade_data_change', load); }, []);

  const filtered = transactions.filter(t =>
    (statusFilter === 'all' || t.status === statusFilter) &&
    ((t.from || '').toLowerCase().includes(search.toLowerCase()) ||
     (t.to || '').toLowerCase().includes(search.toLowerCase()) ||
     t.listingId.toLowerCase().includes(search.toLowerCase()))
  );

  const totalRevenue = filtered.filter(t => t.status === 'completed').reduce((s, t) => s + t.amount, 0);
  const totalFees = filtered.filter(t => t.status === 'completed').reduce((s, t) => s + t.fee, 0);

  const handleStatusChange = (t: Transaction, newStatus: Transaction['status']) => {
    update<Transaction>('transactions', t.id, { status: newStatus });
    setSelected(prev => prev?.id === t.id ? { ...prev, status: newStatus } : prev);
  };

  const handleExport = () => {
    downloadCSV('transactions', ['ID', 'Listing', 'From', 'To', 'Amount', 'Platform Fee', 'Status', 'Date'],
      filtered.map(t => [t.id, t.listingId, t.from || '', t.to || '', String(t.amount), String(t.fee), t.status, new Date(t.date).toLocaleDateString()]));
  };

  return (
    <div className="space-y-4">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <h2 className="text-xl font-bold text-gray-800 dark:text-gray-200 flex items-center gap-2"><DollarSign size={20} className="text-cyan-600"/>Transaction Records</h2>
        <button onClick={handleExport} className="px-3 py-2 border rounded-lg text-sm hover:bg-gray-50 dark:hover:bg-gray-700/50 dark:bg-gray-900">Export CSV</button>
      </div>

      <div className="grid grid-cols-3 gap-4">
        {[
          { label: 'Total Volume', value: `RWF ${totalRevenue.toLocaleString()}`, color: 'border-l-green-500' },
          { label: 'Platform Fees', value: `RWF ${totalFees.toLocaleString()}`, color: 'border-l-blue-500' },
          { label: 'Transactions', value: filtered.length, color: 'border-l-cyan-500' },
        ].map(s => (
          <div key={s.label} className={`bg-white dark:bg-gray-800 border-l-4 ${s.color} rounded-lg p-4 shadow-sm`}>
            <p className="text-xs text-gray-500 dark:text-gray-400 mb-1">{s.label}</p>
            <p className="text-lg font-bold text-gray-800 dark:text-gray-200">{s.value}</p>
          </div>
        ))}
      </div>

      <div className="flex flex-wrap gap-3 bg-white dark:bg-gray-800 border rounded-xl p-4">
        <div className="relative flex-1 min-w-48">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 dark:text-gray-500"/>
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search buyer, seller, listing..." className="w-full pl-9 pr-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500 bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100"/>
        </div>
        <select value={statusFilter} onChange={e => setStatusFilter(e.target.value)} className="border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500 bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100">
          <option value="all">All Status</option>
          {['completed','pending','failed','disputed'].map(s => <option key={s} value={s}>{s.charAt(0).toUpperCase()+s.slice(1)}</option>)}
        </select>
      </div>

      <div className="bg-white dark:bg-gray-800 border rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 dark:bg-gray-900 border-b">
              <tr>{['ID','Listing','From','To','Amount','Fee','Status','Date',''].map(h => <th key={h} className="text-left px-4 py-3 font-medium text-gray-600 dark:text-gray-400">{h}</th>)}</tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
              {filtered.length === 0 && <tr><td colSpan={9} className="text-center py-8 text-gray-400 dark:text-gray-500">No transactions found</td></tr>}
              {filtered.map(t => (
                <tr key={t.id} className="hover:bg-gray-50 dark:hover:bg-gray-700/50 dark:bg-gray-900">
                  <td className="px-4 py-3 font-mono text-xs text-gray-500 dark:text-gray-400">{t.id}</td>
                  <td className="px-4 py-3 text-xs text-gray-600 dark:text-gray-400">{t.listingId}</td>
                  <td className="px-4 py-3 text-xs text-gray-600 dark:text-gray-400">{t.from}</td>
                  <td className="px-4 py-3 text-xs text-gray-600 dark:text-gray-400">{t.to}</td>
                  <td className="px-4 py-3 font-semibold text-gray-800 dark:text-gray-200">RWF {t.amount.toLocaleString()}</td>
                  <td className="px-4 py-3 text-green-700 text-xs">+RWF {t.fee.toLocaleString()}</td>
                  <td className="px-4 py-3"><span className={`px-2 py-0.5 rounded-full text-xs font-medium ${STATUS_COLORS[t.status]}`}>{t.status}</span></td>
                  <td className="px-4 py-3 text-xs text-gray-400 dark:text-gray-500">{new Date(t.date).toLocaleDateString()}</td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1">
                      <button onClick={() => setSelected(t)} className="p-1.5 hover:bg-gray-100 dark:bg-gray-700 rounded text-gray-500 dark:text-gray-400" title="View Details"><Eye size={14}/></button>
                      {t.status === 'pending' && <button onClick={() => handleStatusChange(t, 'completed')} className="p-1.5 hover:bg-green-50 dark:bg-green-900/20 rounded text-green-600 dark:text-green-400" title="Mark Completed"><CheckCircle size={14}/></button>}
                      {(t.status === 'pending' || t.status === 'completed') && <button onClick={() => handleStatusChange(t, 'disputed')} className="p-1.5 hover:bg-orange-50 rounded text-orange-300" title="Mark Disputed"><AlertTriangle size={14}/></button>}
                      {(t.status === 'disputed' || t.status === 'completed') && <button onClick={() => handleStatusChange(t, 'refunded')} className="p-1.5 hover:bg-purple-50 dark:bg-purple-900/20 rounded text-purple-600 dark:text-purple-400" title="Refund"><RotateCcw size={14}/></button>}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {selected && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white dark:bg-gray-800 rounded-2xl w-full max-w-md shadow-xl">
            <div className="flex justify-between items-center p-5 border-b">
              <h3 className="text-lg font-bold">Transaction Details</h3>
              <button onClick={() => setSelected(null)} className="p-2 hover:bg-gray-100 dark:bg-gray-700 rounded-lg"><X size={18}/></button>
            </div>
            <div className="p-5 space-y-3 text-sm">
              {([['Transaction ID', selected.id], ['Listing ID', selected.listingId], ['From', selected.from || '—'], ['To', selected.to || '—'], ['Amount', `RWF ${selected.amount.toLocaleString()}`], ['Platform Fee', `RWF ${selected.fee.toLocaleString()}`], ['Net to Seller', `RWF ${(selected.amount - selected.fee).toLocaleString()}`], ['Waste Type', selected.wasteType], ['Status', selected.status], ['Date', new Date(selected.date).toLocaleString()]] as Array<[string, unknown]>).map(([k,v]) => (
                <div key={String(k)} className="flex justify-between">
                  <span className="text-gray-500 dark:text-gray-400">{String(k)}</span>
                  <span className="font-medium text-gray-800 dark:text-gray-200">{String(v)}</span>
                </div>
              ))}
            </div>
            <div className="p-5 border-t space-y-3">
              <div className="flex gap-2 flex-wrap">
                {selected.status !== 'completed' && <button onClick={() => handleStatusChange(selected, 'completed')} className="flex items-center gap-1.5 px-3 py-1.5 bg-green-600 text-white rounded-lg text-sm hover:bg-green-700"><CheckCircle size={14}/> Complete</button>}
                {selected.status !== 'disputed' && <button onClick={() => handleStatusChange(selected, 'disputed')} className="flex items-center gap-1.5 px-3 py-1.5 bg-orange-300 text-white rounded-lg text-sm hover:bg-orange-300"><AlertTriangle size={14}/> Dispute</button>}
                {selected.status !== 'refunded' && <button onClick={() => handleStatusChange(selected, 'refunded')} className="flex items-center gap-1.5 px-3 py-1.5 bg-purple-600 text-white rounded-lg text-sm hover:bg-purple-700"><RotateCcw size={14}/> Refund</button>}
                <button onClick={() => setSelected(null)} className="flex-1 border rounded-lg py-1.5 text-sm hover:bg-gray-50 dark:hover:bg-gray-700/50 dark:bg-gray-900">Close</button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
