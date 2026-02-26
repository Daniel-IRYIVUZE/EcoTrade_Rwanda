import { useState, useEffect } from 'react';
import { Plus, Search, Edit2, Trash2, Eye, X, Check, User } from 'lucide-react';
import { getAll, create, update, remove, generateId, downloadPDF } from '../../../utils/dataStore';
import type { PlatformUser } from '../../../utils/dataStore';

const ROLES = ['business', 'recycler', 'driver', 'individual', 'admin'] as const;
const STATUSES = ['active', 'pending', 'suspended'] as const;

const emptyUser = (): Omit<PlatformUser, 'id'> => ({
  name: '', email: '', phone: '', role: 'business', status: 'pending',
  location: '', joinDate: new Date().toISOString(), lastActive: new Date().toISOString(),
  avatar: '', verified: false, greenScore: 0, monthlyWaste: 0, totalRevenue: 0
});

export default function AdminUserManagement() {
  const [users, setUsers] = useState<PlatformUser[]>([]);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');
  const [modal, setModal] = useState<'add' | 'edit' | 'view' | 'delete' | null>(null);
  const [selected, setSelected] = useState<PlatformUser | null>(null);
  const [form, setForm] = useState(emptyUser());
  const [saved, setSaved] = useState(false);

  const load = () => setUsers(getAll<PlatformUser>('users'));

  useEffect(() => {
    load();
    window.addEventListener('ecotrade_data_change', load);
    return () => window.removeEventListener('ecotrade_data_change', load);
  }, []);

  const filtered = users.filter(u =>
    (roleFilter === 'all' || u.role === roleFilter) &&
    (statusFilter === 'all' || u.status === statusFilter) &&
    (u.name.toLowerCase().includes(search.toLowerCase()) || u.email.toLowerCase().includes(search.toLowerCase()))
  );

  const openAdd = () => { setForm(emptyUser()); setSelected(null); setModal('add'); };
  const openEdit = (u: PlatformUser) => { setSelected(u); setForm({ ...u }); setModal('edit'); };
  const openView = (u: PlatformUser) => { setSelected(u); setModal('view'); };
  const openDelete = (u: PlatformUser) => { setSelected(u); setModal('delete'); };

  const handleSave = () => {
    if (!form.name || !form.email) return;
    if (modal === 'add') {
      create<PlatformUser>('users', { ...form, id: generateId('U'), joinDate: new Date().toISOString(), lastActive: new Date().toISOString() });
    } else if (modal === 'edit' && selected) {
      update<PlatformUser>('users', selected.id, form);
    }
    setSaved(true); setTimeout(() => setSaved(false), 2000);
    setModal(null); load();
  };

  const handleDelete = () => {
    if (selected) { remove('users', selected.id); setModal(null); load(); }
  };

  const handleStatusToggle = (u: PlatformUser) => {
    const next = u.status === 'active' ? 'suspended' : 'active';
    update<PlatformUser>('users', u.id, { status: next, verified: next === 'active' });
    load();
  };

  const handleExport = () => {
    const tableRows = filtered.map(u =>
      `<tr><td>${u.id}</td><td>${u.name}</td><td>${u.email}</td><td>${u.role}</td><td>${u.phone}</td><td>${u.location}</td><td>${u.status}</td><td>${new Date(u.joinDate).toLocaleDateString()}</td></tr>`
    ).join('');
    downloadPDF('User Management Report', `
      <div class="stat-grid">
        <div class="stat-card"><div class="stat-value">${filtered.length}</div><div class="stat-label">Total Records</div></div>
        <div class="stat-card"><div class="stat-value">${filtered.filter(u => u.status === 'active').length}</div><div class="stat-label">Active</div></div>
        <div class="stat-card"><div class="stat-value">${filtered.filter(u => u.status === 'pending').length}</div><div class="stat-label">Pending</div></div>
        <div class="stat-card"><div class="stat-value">${filtered.filter(u => u.status === 'suspended').length}</div><div class="stat-label">Suspended</div></div>
      </div>
      <h2>User List (${filtered.length} records)</h2>
      <table><thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Role</th><th>Phone</th><th>Location</th><th>Status</th><th>Join Date</th></tr></thead>
      <tbody>${tableRows || '<tr><td colspan="8">No users found.</td></tr>'}</tbody></table>
    `);
  };

  const roleColors: Record<string, string> = {
    admin: 'bg-purple-100 text-purple-700', business: 'bg-cyan-100 text-cyan-700',
    recycler: 'bg-green-100 text-green-700', driver: 'bg-orange-100 text-orange-700', individual: 'bg-gray-100 text-gray-700'
  };

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <h2 className="text-xl font-bold text-gray-800 flex items-center gap-2"><User size={20} className="text-cyan-600"/>User Management</h2>
        <div className="flex gap-2">
          <button onClick={handleExport} className="px-3 py-2 border rounded-lg text-sm hover:bg-gray-50">Export PDF</button>
          <button onClick={openAdd} className="flex items-center gap-2 bg-cyan-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-cyan-700">
            <Plus size={16}/> Add User
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3 bg-white border rounded-xl p-4">
        <div className="relative flex-1 min-w-48">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400"/>
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search name, email..." className="w-full pl-9 pr-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500"/>
        </div>
        <select value={roleFilter} onChange={e => setRoleFilter(e.target.value)} className="border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500">
          <option value="all">All Roles</option>
          {ROLES.map(r => <option key={r} value={r}>{r.charAt(0).toUpperCase()+r.slice(1)}</option>)}
        </select>
        <select value={statusFilter} onChange={e => setStatusFilter(e.target.value)} className="border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500">
          <option value="all">All Status</option>
          {STATUSES.map(s => <option key={s} value={s}>{s.charAt(0).toUpperCase()+s.slice(1)}</option>)}
        </select>
      </div>

      {saved && <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-2 rounded-lg text-sm flex items-center gap-2"><Check size={16}/>Saved successfully</div>}

      {/* Table */}
      <div className="bg-white border rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 border-b">
              <tr>{['ID','Name','Role','Contact','Location','Status','Last Active','Actions'].map(h => <th key={h} className="text-left px-4 py-3 font-medium text-gray-600">{h}</th>)}</tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filtered.length === 0 && <tr><td colSpan={8} className="text-center py-8 text-gray-400">No users found</td></tr>}
              {filtered.map(u => (
                <tr key={u.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-4 py-3 font-mono text-xs text-gray-500">{u.id}</td>
                  <td className="px-4 py-3">
                    <div className="font-medium text-gray-800">{u.name}</div>
                    <div className="text-xs text-gray-400">{u.email}</div>
                  </td>
                  <td className="px-4 py-3"><span className={`px-2 py-0.5 rounded-full text-xs font-medium ${roleColors[u.role]}`}>{u.role}</span></td>
                  <td className="px-4 py-3">
                    <div className="text-gray-700">{u.phone}</div>
                  </td>
                  <td className="px-4 py-3 text-gray-600 text-xs">{u.location}</td>
                  <td className="px-4 py-3">
                    <button onClick={() => handleStatusToggle(u)} className={`px-2 py-0.5 rounded-full text-xs font-medium cursor-pointer ${u.status === 'active' ? 'bg-green-100 text-green-700' : u.status === 'pending' ? 'bg-yellow-100 text-yellow-700' : 'bg-red-100 text-red-700'}`}>
                      {u.status}
                    </button>
                  </td>
                  <td className="px-4 py-3 text-xs text-gray-400">{new Date(u.lastActive).toLocaleDateString()}</td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1">
                      <button onClick={() => openView(u)} className="p-1.5 rounded hover:bg-gray-100 text-gray-500"><Eye size={14}/></button>
                      <button onClick={() => openEdit(u)} className="p-1.5 rounded hover:bg-blue-50 text-blue-600"><Edit2 size={14}/></button>
                      <button onClick={() => openDelete(u)} className="p-1.5 rounded hover:bg-red-50 text-red-500"><Trash2 size={14}/></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add / Edit Modal */}
      {(modal === 'add' || modal === 'edit') && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg shadow-xl">
            <div className="flex items-center justify-between p-5 border-b">
              <h3 className="text-lg font-bold">{modal === 'add' ? 'Add New User' : 'Edit User'}</h3>
              <button onClick={() => setModal(null)} className="p-2 hover:bg-gray-100 rounded-lg"><X size={18}/></button>
            </div>
            <div className="p-5 space-y-4 max-h-[70vh] overflow-y-auto">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Full Name *</label>
                  <input value={form.name} onChange={e => setForm({...form, name: e.target.value})} className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500" placeholder="Name"/>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Email *</label>
                  <input value={form.email} onChange={e => setForm({...form, email: e.target.value})} className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500" placeholder="umuntu@ecotrade.rw"/>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
                  <input value={form.phone} onChange={e => setForm({...form, phone: e.target.value})} className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500" placeholder="+250 788 ..."/>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Role</label>
                  <select value={form.role} onChange={e => setForm({...form, role: e.target.value as any})} className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500">
                    {ROLES.map(r => <option key={r} value={r}>{r.charAt(0).toUpperCase()+r.slice(1)}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
                  <select value={form.status} onChange={e => setForm({...form, status: e.target.value as any})} className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500">
                    {STATUSES.map(s => <option key={s} value={s}>{s.charAt(0).toUpperCase()+s.slice(1)}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Location</label>
                  <input value={form.location} onChange={e => setForm({...form, location: e.target.value})} className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-cyan-500" placeholder="Sector, Kigali"/>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <input type="checkbox" id="verified" checked={form.verified} onChange={e => setForm({...form, verified: e.target.checked})} className="w-4 h-4"/>
                <label htmlFor="verified" className="text-sm text-gray-700">Mark as Verified</label>
              </div>
            </div>
            <div className="flex gap-3 p-5 border-t">
              <button onClick={() => setModal(null)} className="flex-1 border rounded-lg py-2 text-sm hover:bg-gray-50">Cancel</button>
              <button onClick={handleSave} className="flex-1 bg-cyan-600 text-white rounded-lg py-2 text-sm hover:bg-cyan-700">Save User</button>
            </div>
          </div>
        </div>
      )}

      {/* View Modal */}
      {modal === 'view' && selected && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg shadow-xl">
            <div className="flex items-center justify-between p-5 border-b">
              <h3 className="text-lg font-bold">User Profile</h3>
              <button onClick={() => setModal(null)} className="p-2 hover:bg-gray-100 rounded-lg"><X size={18}/></button>
            </div>
            <div className="p-5 space-y-4">
              <div className="flex items-center gap-4">
                <div className="w-16 h-16 rounded-full bg-gradient-to-br from-cyan-400 to-teal-600 flex items-center justify-center text-white font-bold text-xl">{selected.name.charAt(0)}</div>
                <div>
                  <h4 className="font-bold text-lg text-gray-800">{selected.name}</h4>
                  <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${roleColors[selected.role]}`}>{selected.role}</span>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3 text-sm">
                {[['Email', selected.email], ['Phone', selected.phone], ['Location', selected.location], ['Status', selected.status], ['Join Date', new Date(selected.joinDate).toLocaleDateString()], ['Last Active', new Date(selected.lastActive).toLocaleDateString()], ['Verified', selected.verified ? 'Yes ✓' : 'No ✗']].map(([k, v]) => (
                  <div key={k}><span className="text-gray-500">{k}:</span> <span className="font-medium text-gray-800">{v}</span></div>
                ))}
              </div>
              {selected.greenScore !== undefined && <div className="bg-green-50 rounded-lg p-3"><p className="text-sm font-medium text-green-700">Green Score: {selected.greenScore}/100</p></div>}
            </div>
            <div className="flex gap-3 p-5 border-t">
              <button onClick={() => { openEdit(selected); }} className="flex-1 border rounded-lg py-2 text-sm hover:bg-gray-50">Edit</button>
              <button onClick={() => { setModal(null); }} className="flex-1 bg-cyan-600 text-white rounded-lg py-2 text-sm hover:bg-cyan-700">Close</button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirm */}
      {modal === 'delete' && selected && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-sm shadow-xl p-6 text-center">
            <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-3"><Trash2 size={20} className="text-red-500"/></div>
            <h3 className="text-lg font-bold text-gray-800 mb-2">Delete User?</h3>
            <p className="text-gray-500 text-sm mb-5">This will permanently delete <strong>{selected.name}</strong>. This action cannot be undone.</p>
            <div className="flex gap-3">
              <button onClick={() => setModal(null)} className="flex-1 border rounded-lg py-2 text-sm hover:bg-gray-50">Cancel</button>
              <button onClick={handleDelete} className="flex-1 bg-red-500 text-white rounded-lg py-2 text-sm hover:bg-red-600">Delete</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
