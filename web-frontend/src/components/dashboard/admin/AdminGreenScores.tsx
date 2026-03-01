import { useState, useEffect } from 'react';
import { Leaf, TrendingUp, Award, Edit2, X, Check } from 'lucide-react';
import { getAll, update } from '../../../utils/dataStore';
import type { PlatformUser } from '../../../utils/dataStore';

export default function AdminGreenScores() {
  const [users, setUsers] = useState<PlatformUser[]>([]);
  const [editing, setEditing] = useState<PlatformUser | null>(null);
  const [newScore, setNewScore] = useState(0);
  const [flash, setFlash] = useState(false);

  const load = () => setUsers(
    getAll<PlatformUser>('users')
      .filter(u => u.role === 'business' || u.role === 'individual' || u.role === 'recycler')
      .sort((a, b) => (b.greenScore || 0) - (a.greenScore || 0))
  );
  useEffect(() => { load(); window.addEventListener('ecotrade_data_change', load); return () => window.removeEventListener('ecotrade_data_change', load); }, []);

  const handleSave = () => {
    if (!editing) return;
    update<PlatformUser>('users', editing.id, { greenScore: Math.min(100, Math.max(0, newScore)) });
    setEditing(null); setFlash(true); setTimeout(() => setFlash(false), 2000); load();
  };

  const medalColor = (idx: number) => idx === 0 ? 'text-yellow-500' : idx === 1 ? 'text-gray-400 dark:text-gray-500' : idx === 2 ? 'text-orange-300' : 'text-gray-300';
  const scoreColor = (s: number) => s >= 80 ? 'bg-green-500' : s >= 60 ? 'bg-teal-500' : s >= 40 ? 'bg-yellow-500' : 'bg-gray-400';

  return (
    <div className="space-y-4">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <h2 className="text-xl font-bold text-gray-800 dark:text-gray-200 flex items-center gap-2"><Leaf size={20} className="text-green-600 dark:text-green-400"/>Green Score Leaderboard</h2>
        <div className="text-sm text-gray-500 dark:text-gray-400">Score 0–100 · Updated in real time</div>
      </div>

      {flash && <div className="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 text-green-700 px-4 py-2 rounded-lg text-sm flex items-center gap-2"><Check size={15}/>Score updated successfully</div>}

      <div className="grid md:grid-cols-3 gap-4 mb-2">
        {users.slice(0, 3).map((u, i) => (
          <div key={u.id} className="bg-white dark:bg-gray-800 border-2 rounded-xl p-5 text-center shadow-sm" style={{borderColor: i===0?'#eab308':i===1?'#9ca3af':'#f97316'}}>
            <Award size={28} className={`mx-auto mb-2 ${medalColor(i)}`}/>
            <div className="w-12 h-12 rounded-full bg-cyan-500 flex items-center justify-center text-white font-bold text-lg mx-auto mb-2">{u.name.charAt(0)}</div>
            <h3 className="font-semibold text-gray-800 dark:text-gray-200 text-sm">{u.name}</h3>
            <p className="text-xs text-gray-400 dark:text-gray-500 mb-2">{u.role} · {u.location}</p>
            <div className="text-2xl font-bold text-green-700">{u.greenScore || 0}</div>
            <div className="text-xs text-gray-400 dark:text-gray-500">/ 100</div>
          </div>
        ))}
      </div>

      <div className="bg-white dark:bg-gray-800 border rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 dark:bg-gray-900 border-b">
              <tr>{['Rank','User','Role','Location','Green Score','Bar',''].map(h => <th key={h} className="text-left px-4 py-3 font-medium text-gray-600 dark:text-gray-400">{h}</th>)}</tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-800">
              {users.map((u, i) => (
                <tr key={u.id} className="hover:bg-gray-50 dark:hover:bg-gray-700/50 dark:bg-gray-900">
                  <td className="px-4 py-3">
                    <span className={`font-bold text-lg ${medalColor(i)}`}>#{i+1}</span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="font-medium text-gray-800 dark:text-gray-200">{u.name}</div>
                    <div className="text-xs text-gray-400 dark:text-gray-500">{u.email}</div>
                  </td>
                  <td className="px-4 py-3"><span className="px-2 py-0.5 rounded-full text-xs bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400">{u.role}</span></td>
                  <td className="px-4 py-3 text-gray-600 dark:text-gray-400 text-xs">{u.location}</td>
                  <td className="px-4 py-3 font-bold text-gray-800 dark:text-gray-200">{u.greenScore || 0}</td>
                  <td className="px-4 py-3 w-32">
                    <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                      <div className={`h-2 rounded-full transition-all ${scoreColor(u.greenScore || 0)}`} style={{ width: `${u.greenScore || 0}%` }}/>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <button onClick={() => { setEditing(u); setNewScore(u.greenScore || 0); }} className="p-1.5 hover:bg-blue-50 dark:bg-blue-900/20 rounded text-blue-600 dark:text-blue-400"><Edit2 size={14}/></button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {editing && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white dark:bg-gray-800 rounded-2xl w-full max-w-sm shadow-xl p-6">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-bold">Edit Green Score</h3>
              <button onClick={() => setEditing(null)} className="p-2 hover:bg-gray-100 dark:bg-gray-700 rounded-lg"><X size={18}/></button>
            </div>
            <p className="text-gray-600 dark:text-gray-400 text-sm mb-4">Updating score for <strong>{editing.name}</strong></p>
            <div className="space-y-3">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Green Score (0–100)</label>
                <input type="number" min="0" max="100" value={newScore} onChange={e => setNewScore(Number(e.target.value))} className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500 bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100"/>
              </div>
              <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-3">
                <div className={`h-3 rounded-full transition-all ${scoreColor(newScore)}`} style={{ width: `${Math.min(100,Math.max(0,newScore))}%` }}/>
              </div>
            </div>
            <div className="flex gap-3 mt-5">
              <button onClick={() => setEditing(null)} className="flex-1 border rounded-lg py-2 text-sm hover:bg-gray-50 dark:hover:bg-gray-700/50 dark:bg-gray-900">Cancel</button>
              <button onClick={handleSave} className="flex-1 bg-green-600 text-white rounded-lg py-2 text-sm hover:bg-green-700 flex items-center justify-center gap-1.5"><TrendingUp size={14}/> Save</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
