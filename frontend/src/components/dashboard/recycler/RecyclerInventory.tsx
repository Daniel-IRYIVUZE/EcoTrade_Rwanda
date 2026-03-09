import { useState, useEffect, useCallback } from 'react';
import { DollarSign, Warehouse, Package, Plus, Pencil, Trash2, X, Save } from 'lucide-react';
import StatCard from '../StatCard';
import { inventoryAPI } from '../../../services/api';
import type { InventoryItem } from '../../../services/api';

const UNITS = ['kg', 'L', 'units', 'tonnes'];
const MATERIAL_TYPES = ['UCO', 'Glass', 'Paper/Cardboard', 'Plastic', 'Metal', 'Organic', 'Electronic', 'Textile', 'Mixed', 'Other'];

interface FormState {
  material_type: string;
  current_stock: number;
  capacity: number;
  unit: string;
  notes: string;
}

const EMPTY_FORM: FormState = {
  material_type: 'Plastic',
  current_stock: 0,
  capacity: 1000,
  unit: 'kg',
  notes: '',
};

export default function RecyclerInventory() {
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [showModal, setShowModal] = useState(false);
  const [editItem, setEditItem] = useState<InventoryItem | null>(null);
  const [form, setForm] = useState<FormState>(EMPTY_FORM);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [deleting, setDeleting] = useState<number | null>(null);

  const load = useCallback(async () => {
    try {
      const data = await inventoryAPI.mine();
      setInventory(data);
    } catch { /* offline */ }
  }, []);

  useEffect(() => { load(); }, [load]);

  const openAdd = () => {
    setEditItem(null);
    setForm(EMPTY_FORM);
    setError('');
    setShowModal(true);
  };

  const openEdit = (item: InventoryItem) => {
    setEditItem(item);
    setForm({
      material_type: item.material_type,
      current_stock: item.current_stock,
      capacity: item.capacity,
      unit: item.unit,
      notes: item.notes ?? '',
    });
    setError('');
    setShowModal(true);
  };

  const handleSave = async () => {
    if (!form.material_type.trim()) { setError('Material type is required.'); return; }
    setSaving(true); setError('');
    try {
      if (editItem) {
        await inventoryAPI.update(editItem.id, {
          material_type: form.material_type,
          current_stock: Number(form.current_stock),
          capacity: Number(form.capacity),
          unit: form.unit,
          notes: form.notes,
        });
      } else {
        await inventoryAPI.create({
          material_type: form.material_type,
          current_stock: Number(form.current_stock),
          capacity: Number(form.capacity),
          unit: form.unit,
          notes: form.notes,
        });
      }
      setShowModal(false);
      load();
    } catch (e: unknown) {
      setError(e instanceof Error ? e.message : 'Failed to save. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm('Delete this inventory item? This cannot be undone.')) return;
    setDeleting(id);
    try {
      await inventoryAPI.delete(id);
      setInventory(prev => prev.filter(i => i.id !== id));
    } catch {
      alert('Failed to delete item.');
    } finally {
      setDeleting(null);
    }
  };

  const avgUtilization = inventory.length === 0 ? 0 : Math.round(
    inventory.reduce((s, i) => s + (i.capacity > 0 ? (i.current_stock / i.capacity) * 100 : 0), 0) / inventory.length
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Inventory</h1>
        <button onClick={openAdd} className="flex items-center gap-2 px-4 py-2 bg-cyan-600 hover:bg-cyan-700 text-white rounded-lg text-sm font-medium">
          <Plus size={16} /> Add Item
        </button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatCard title="Total Stock" value={inventory.reduce((s, i) => s + i.current_stock, 0)} icon={<DollarSign size={22} />} color="cyan" />
        <StatCard title="Avg Utilization" value={`${avgUtilization}%`} icon={<Warehouse size={22} />} color="blue" progress={avgUtilization} />
        <StatCard title="Types Stored" value={inventory.length} icon={<Package size={22} />} color="purple" />
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-lg shadow border border-gray-200 dark:border-gray-700 overflow-hidden">
        {inventory.length === 0 ? (
          <div className="text-center py-16 text-gray-400 dark:text-gray-500">
            <Warehouse size={40} className="mx-auto mb-3 opacity-40" />
            <p className="text-sm">No inventory items yet. Click <strong>Add Item</strong> to get started.</p>
          </div>
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-gray-50 dark:bg-gray-700/50">
              <tr>
                {['Waste Type', 'Current Stock', 'Max Capacity', 'Utilization', 'Last Updated', ''].map(h => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-700">
              {inventory.map(item => {
                const util = item.capacity > 0 ? Math.round((item.current_stock / item.capacity) * 100) : 0;
                return (
                  <tr key={item.id} className="hover:bg-gray-50 dark:hover:bg-gray-700/30">
                    <td className="px-4 py-3 font-medium text-gray-900 dark:text-white">{item.material_type}</td>
                    <td className="px-4 py-3 text-gray-600 dark:text-gray-300">{item.current_stock.toLocaleString()} {item.unit}</td>
                    <td className="px-4 py-3 text-gray-600 dark:text-gray-300">{item.capacity?.toLocaleString()} {item.unit}</td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <div className="w-20 h-2 bg-gray-200 dark:bg-gray-600 rounded-full">
                          <div className={`h-full rounded-full ${util > 75 ? 'bg-red-500' : util > 50 ? 'bg-yellow-500' : 'bg-green-500'}`} style={{ width: `${Math.min(util, 100)}%` }} />
                        </div>
                        <span className="text-xs text-gray-500 dark:text-gray-400">{util}%</span>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-gray-500 dark:text-gray-400 text-xs">{item.last_updated ? new Date(item.last_updated).toLocaleDateString() : '—'}</td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <button onClick={() => openEdit(item)} className="p-1.5 rounded hover:bg-cyan-50 dark:hover:bg-cyan-900/30 text-cyan-600" title="Edit">
                          <Pencil size={14} />
                        </button>
                        <button onClick={() => handleDelete(item.id)} disabled={deleting === item.id} className="p-1.5 rounded hover:bg-red-50 dark:hover:bg-red-900/30 text-red-500" title="Delete">
                          <Trash2 size={14} />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>

      {/* Add / Edit Modal */}
      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4" onClick={e => { if (e.target === e.currentTarget) setShowModal(false); }}>
          <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl w-full max-w-md">
            <div className="flex items-center justify-between px-6 pt-5 pb-4 border-b border-gray-100 dark:border-gray-700">
              <h2 className="text-lg font-bold text-gray-900 dark:text-white">{editItem ? 'Edit Inventory Item' : 'Add Inventory Item'}</h2>
              <button onClick={() => setShowModal(false)} className="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700/50 text-gray-400"><X size={18} /></button>
            </div>
            <div className="px-6 py-5 space-y-4">
              {error && <p className="text-sm text-red-600 bg-red-50 dark:bg-red-900/20 rounded-lg px-3 py-2">{error}</p>}
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Material Type</label>
                <select value={form.material_type} onChange={e => setForm(f => ({ ...f, material_type: e.target.value }))}
                  className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none">
                  {MATERIAL_TYPES.map(t => <option key={t}>{t}</option>)}
                </select>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Current Stock</label>
                  <input type="number" min={0} value={form.current_stock} onChange={e => setForm(f => ({ ...f, current_stock: Number(e.target.value) }))}
                    className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Max Capacity</label>
                  <input type="number" min={1} value={form.capacity} onChange={e => setForm(f => ({ ...f, capacity: Number(e.target.value) }))}
                    className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none" />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Unit</label>
                <select value={form.unit} onChange={e => setForm(f => ({ ...f, unit: e.target.value }))}
                  className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none">
                  {UNITS.map(u => <option key={u}>{u}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Notes <span className="text-gray-400 font-normal">(optional)</span></label>
                <textarea rows={2} value={form.notes} onChange={e => setForm(f => ({ ...f, notes: e.target.value }))}
                  className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none resize-none" />
              </div>
            </div>
            <div className="px-6 pb-5 flex gap-3 justify-end">
              <button onClick={() => setShowModal(false)} className="px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700/50">Cancel</button>
              <button onClick={handleSave} disabled={saving} className="flex items-center gap-2 px-5 py-2 bg-cyan-600 hover:bg-cyan-700 disabled:opacity-60 text-white rounded-lg text-sm font-medium">
                {saving ? <span className="animate-spin border-2 border-white border-t-transparent rounded-full w-4 h-4" /> : <Save size={15} />}
                {saving ? 'Saving…' : editItem ? 'Save Changes' : 'Add Item'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
