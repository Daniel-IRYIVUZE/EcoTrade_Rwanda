import { useState, useEffect } from 'react';
import { downloadCSV, downloadPDF } from '../../../utils/dataStore';
import { collectionsAPI, transactionsAPI, recyclersAPI } from '../../../services/api';
import type { Collection, Transaction, RecyclerProfile } from '../../../services/api';
import { Download } from 'lucide-react';
import DataTable from '../DataTable';

export default function RecyclerReports() {
  const [generating, setGenerating] = useState<number | null>(null);
  const [collections, setCollections] = useState<Collection[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [recyclerProfile, setRecyclerProfile] = useState<RecyclerProfile | null>(null);
  const now = new Date();
  const month = now.toLocaleString('default', { month: 'long', year: 'numeric' });

  useEffect(() => {
    collectionsAPI.list({ limit: 500 }).then(setCollections).catch(() => {});
    transactionsAPI.mine({ limit: 500 }).then(setTransactions).catch(() => {});
    recyclersAPI.me().then(setRecyclerProfile).catch(() => {});
  }, []);

  const companyName = recyclerProfile?.company_name || 'EcoTrade Recycler';

  const generateReport = (type: string, id: number) => {
    setGenerating(id);
    setTimeout(() => {
      if (type === 'Collections') {
        downloadCSV(`collections_${month.replace(/ /g, '_')}`, ['ID', 'Hotel', 'Driver', 'Type', 'Volume', 'Status', 'Date', 'Earnings'],
          collections.map(c => [String(c.id), c.hotel_name || 'N/A', c.driver_name || 'N/A', c.waste_type || '', String(c.volume), c.status, c.scheduled_date || '', String(c.earnings || 0)]));
      } else if (type === 'Revenue') {
        downloadCSV(`revenue_${month.replace(/ /g, '_')}`, ['ID', 'Date', 'Hotel', 'Description', 'Gross Amount', 'Platform Fee', 'Net Amount', 'Status'],
          transactions.map(t => [String(t.id), t.created_at ? new Date(t.created_at).toLocaleDateString() : '', t.hotel_name || '', t.description || '', String(t.gross_amount ?? 0), String(t.platform_fee ?? 0), String(t.net_amount ?? 0), t.status]));
      } else {
        const totalVol = collections.reduce((s, c) => s + (c.volume || 0), 0);
        downloadPDF(`${type} Report — ${companyName}`,
          `${type.toUpperCase()} REPORT\n${companyName} — ${month}\n\nTotal Collections: ${collections.length}\nTotal Volume: ${totalVol.toLocaleString()} units\nEarnings: RWF ${transactions.reduce((s, t) => s + (t.gross_amount ?? 0), 0).toLocaleString()}\n\nEcoTrade Rwanda | Kigali, Rwanda`);
      }
      setGenerating(null);
    }, 600);
  };

  const reports = [
    { id: 1, name: `Monthly Collection Report — ${month}`, type: 'Collections', date: now.toLocaleDateString() },
    { id: 2, name: `Revenue Summary — ${month}`, type: 'Revenue', date: now.toLocaleDateString() },
    { id: 3, name: `Fleet Performance Report — ${month}`, type: 'Fleet', date: now.toLocaleDateString() },
    { id: 4, name: `Environmental Impact Certificate — ${month}`, type: 'Impact', date: now.toLocaleDateString() },
  ];

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Reports</h1>
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow border border-gray-200 dark:border-gray-700 p-4">
        <DataTable
          columns={[
            { key: 'name', label: 'Report', render: (v: string) => <span className="font-medium">{v}</span> },
            { key: 'type', label: 'Type', render: (v: string) => <span className="bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded text-xs">{v}</span> },
            { key: 'date', label: 'Date' },
            { key: 'id', label: 'Download', render: (v: number, r: typeof reports[0]) => (
              <button onClick={() => generateReport(r.type, v)} disabled={generating === v} className="flex items-center gap-1 text-xs px-3 py-1.5 bg-cyan-50 dark:bg-cyan-900/20 text-cyan-700 dark:text-cyan-400 rounded hover:bg-cyan-100 font-medium disabled:opacity-50">
                {generating === v ? 'Generating...' : <><Download size={14} /> {r.type === 'Impact' || r.type === 'Fleet' ? 'PDF' : 'CSV'}</>}
              </button>
            )},
          ]}
          data={reports}
        />
      </div>
    </div>
  );
}
