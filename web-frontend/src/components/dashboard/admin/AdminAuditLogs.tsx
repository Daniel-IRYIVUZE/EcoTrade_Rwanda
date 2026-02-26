import { useState, useEffect } from 'react';
import { Search, Activity, Eye, X } from 'lucide-react';
import { getAll, downloadCSV } from '../../../utils/dataStore';
import type { AuditLog } from '../../../utils/dataStore';

export default function AdminAuditLogs() {
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [search, setSearch] = useState('');
  const [actionFilter, setActionFilter] = useState('all');
  const [selected, setSelected] = useState<AuditLog | null>(null);

  const load = () => setLogs(getAll<AuditLog>('auditLogs').sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()));
  useEffect(() => { load(); window.addEventListener('ecotrade_data_change', load); return () => window.removeEventListener('ecotrade_data_change', load); }, []);

  const actions = [...new Set(logs.map(l => l.action))];
  const filtered = logs.filter(l =>
    (actionFilter === 'all' || l.action === actionFilter) &&
    (l.adminUser.toLowerCase().includes(search.toLowerCase()) || l.action.toLowerCase().includes(search.toLowerCase()) || l.target.toLowerCase().includes(search.toLowerCase()))
  );

  const actionColors: Record<string, string> = { create: 'bg-green-100 text-green-700', update: 'bg-blue-100 text-blue-700', delete: 'bg-red-100 text-red-700', read: 'bg-yellow-100 text-yellow-700' };

  return (
    <div className="space-y-4">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <h2 className="text-xl font-bold text-gray-800 flex items-center gap-2"><Activity size={20} className="text-cyan-600"/>Audit Logs</h2>
        <button onClick={() => downloadCSV('audit_logs', ['ID','Admin User','Action','Target','Details','Status','Timestamp'],
          filtered.map(l => [l.id, l.adminUser, l.action, l.target, l.details, l.status, new Date(l.timestamp).toLocaleString()]))}          
          className="px-3 py-2 border rounded-lg text-sm hover:bg-gray-50">Export CSV</button>
      </div>

      <div className="flex flex-wrap gap-3 bg-white border rounded-xl p-4">
        <div className="relative flex-1 min-w-48">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"/>
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search user, action, resource..." className="w-full pl-9 pr-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500"/>
        </div>
        <select value={actionFilter} onChange={e => setActionFilter(e.target.value)} className="border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500">
          <option value="all">All Actions</option>
          {actions.map(a => <option key={a} value={a}>{a}</option>)}
        </select>
      </div>

      <div className="bg-white border rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 border-b">
              <tr>{['Timestamp','Admin User','Action','Target','Details',''].map(h => <th key={h} className="text-left px-4 py-3 font-medium text-gray-600">{h}</th>)}</tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filtered.length === 0 && <tr><td colSpan={7} className="text-center py-8 text-gray-400">No logs found</td></tr>}
              {filtered.slice(0, 100).map(l => (
                <tr key={l.id} className="hover:bg-gray-50 text-xs">
                  <td className="px-4 py-2.5 text-gray-500 whitespace-nowrap">{new Date(l.timestamp).toLocaleString()}</td>
                  <td className="px-4 py-2.5 font-medium text-gray-600">{l.adminUser}</td>
                  <td className="px-4 py-2.5"><span className={`px-2 py-0.5 rounded-full font-medium ${actionColors[l.action] || 'bg-gray-100 text-gray-600'}`}>{l.action}</span></td>
                  <td className="px-4 py-2.5 text-gray-700">{l.target}</td>
                  <td className="px-4 py-2.5 text-gray-500 max-w-xs truncate">{l.details}</td>
                  <td className="px-4 py-2.5"><button onClick={() => setSelected(l)} className="p-1 hover:bg-gray-100 rounded text-gray-500"><Eye size={13}/></button></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {filtered.length > 100 && <div className="px-4 py-2 text-xs text-gray-400 bg-gray-50 border-t">Showing 100 of {filtered.length} records</div>}
      </div>

      {selected && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-md shadow-xl">
            <div className="flex justify-between items-center p-5 border-b">
              <h3 className="text-lg font-bold">Audit Log Detail</h3>
              <button onClick={() => setSelected(null)} className="p-2 hover:bg-gray-100 rounded-lg"><X size={18}/></button>
            </div>
            <div className="p-5 space-y-3 text-sm">
              {([['ID', selected.id], ['Timestamp', new Date(selected.timestamp).toLocaleString()], ['Admin User', selected.adminUser], ['Action', selected.action], ['Target', selected.target], ['Details', selected.details], ['Status', selected.status]] as Array<[string, unknown]>).map(([k,v]) => (
                <div key={String(k)} className="flex justify-between"><span className="text-gray-500">{String(k)}</span><span className="font-medium text-gray-800">{String(v)}</span></div>
              ))}
              {selected.details && <div className="bg-gray-50 rounded p-3 font-mono text-xs overflow-auto max-h-32">{selected.details}</div>}
            </div>
            <div className="p-5 border-t"><button onClick={() => setSelected(null)} className="w-full bg-cyan-600 text-white rounded-lg py-2 text-sm hover:bg-cyan-700">Close</button></div>
          </div>
        </div>
      )}
    </div>
  );
}
