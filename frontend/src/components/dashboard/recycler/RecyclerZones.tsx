import { useEffect, useState } from 'react';
import { MapPin, Plus, Pencil, Trash2, X, Save } from 'lucide-react';
import { MapContainer, TileLayer, Marker, Popup, Circle } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import { listingsAPI } from '../../../services/api';
import type { WasteListing } from '../../../services/api';

// Fix Leaflet's default icon bundling with Vite
delete (L.Icon.Default.prototype as unknown as Record<string, unknown>)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

const urgentIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-red.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  iconSize: [25, 41], iconAnchor: [12, 41], popupAnchor: [1, -34],
});

const KIGALI_CENTER: [number, number] = [-1.9441, 30.0619];
const LS_KEY = 'ecotrade_recycler_zones';

const PRIORITY_COLOR: Record<string, string> = {
  high: '#ef4444',
  medium: '#f59e0b',
  low: '#6b7280',
};

interface Zone {
  id: number;
  name: string;
  center: [number, number];
  radius: number;
  priority: 'high' | 'medium' | 'low';
}

const DEFAULT_ZONES: Zone[] = [
  { id: 1, name: 'Kicukiro District',   center: [-1.9837, 30.0739], radius: 5000, priority: 'high' },
  { id: 2, name: 'Gasabo District',     center: [-1.9064, 30.1060], radius: 7000, priority: 'high' },
  { id: 3, name: 'Nyarugenge District', center: [-1.9499, 30.0588], radius: 4000, priority: 'medium' },
  { id: 4, name: 'Musanze (Northern)',  center: [-1.4988, 29.6333], radius: 8000, priority: 'low' },
  { id: 5, name: 'Rubavu (Western)',    center: [-1.6767, 29.3467], radius: 6000, priority: 'low' },
];

function loadZones(): Zone[] {
  try {
    const raw = localStorage.getItem(LS_KEY);
    if (raw) return JSON.parse(raw) as Zone[];
  } catch { /* ignore */ }
  return DEFAULT_ZONES;
}

function saveZones(zones: Zone[]) {
  localStorage.setItem(LS_KEY, JSON.stringify(zones));
}

interface ZoneForm {
  name: string;
  lat: string;
  lng: string;
  radius: string;
  priority: 'high' | 'medium' | 'low';
}

const EMPTY_FORM: ZoneForm = { name: '', lat: '-1.9441', lng: '30.0619', radius: '5000', priority: 'medium' };

export default function RecyclerZones() {
  const [zones, setZones] = useState<Zone[]>(loadZones);
  const [listings, setListings] = useState<WasteListing[]>([]);
  const [showModal, setShowModal] = useState(false);
  const [editZone, setEditZone] = useState<Zone | null>(null);
  const [form, setForm] = useState<ZoneForm>(EMPTY_FORM);
  const [formError, setFormError] = useState('');

  useEffect(() => {
    listingsAPI.list({ status: 'open', limit: 200 }).then(setListings).catch(() => {});
  }, []);

  const persistZones = (updated: Zone[]) => {
    setZones(updated);
    saveZones(updated);
  };

  const openAdd = () => {
    setEditZone(null);
    setForm(EMPTY_FORM);
    setFormError('');
    setShowModal(true);
  };

  const openEdit = (z: Zone) => {
    setEditZone(z);
    setForm({ name: z.name, lat: String(z.center[0]), lng: String(z.center[1]), radius: String(z.radius), priority: z.priority });
    setFormError('');
    setShowModal(true);
  };

  const handleSave = () => {
    const lat = parseFloat(form.lat);
    const lng = parseFloat(form.lng);
    const radius = parseFloat(form.radius);
    if (!form.name.trim()) { setFormError('Zone name is required.'); return; }
    if (isNaN(lat) || lat < -90 || lat > 90) { setFormError('Invalid latitude (must be -90 to 90).'); return; }
    if (isNaN(lng) || lng < -180 || lng > 180) { setFormError('Invalid longitude (must be -180 to 180).'); return; }
    if (isNaN(radius) || radius <= 0) { setFormError('Radius must be a positive number (meters).'); return; }

    if (editZone) {
      persistZones(zones.map(z => z.id === editZone.id
        ? { ...z, name: form.name.trim(), center: [lat, lng], radius, priority: form.priority }
        : z));
    } else {
      const newId = zones.length === 0 ? 1 : Math.max(...zones.map(z => z.id)) + 1;
      persistZones([...zones, { id: newId, name: form.name.trim(), center: [lat, lng], radius, priority: form.priority }]);
    }
    setShowModal(false);
  };

  const handleDelete = (id: number) => {
    if (!confirm('Remove this collection zone?')) return;
    persistZones(zones.filter(z => z.id !== id));
  };

  const mappableListings = listings.filter(l => l.latitude && l.longitude);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Collection Zones</h1>
        <button onClick={openAdd} className="flex items-center gap-2 px-4 py-2 bg-cyan-600 hover:bg-cyan-700 text-white rounded-lg text-sm font-medium">
          <Plus size={16} /> Add Zone
        </button>
      </div>

      {/* Map */}
      <div className="bg-white dark:bg-gray-800 rounded-2xl shadow border border-gray-200 dark:border-gray-700 overflow-hidden">
        <div className="p-4 border-b border-gray-100 dark:border-gray-700 flex items-center gap-2">
          <MapPin size={16} className="text-cyan-600" />
          <span className="text-sm font-semibold text-gray-900 dark:text-white">Live Coverage Map — Kigali & Surrounding Areas</span>
          <span className="ml-auto text-xs text-gray-500 dark:text-gray-400">{mappableListings.length} pinned listings</span>
        </div>
        <div style={{ height: 420 }}>
          <MapContainer center={KIGALI_CENTER} zoom={11} style={{ height: '100%', width: '100%' }} scrollWheelZoom={false}>
            <TileLayer
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />
            {zones.map(z => (
              <Circle key={z.id} center={z.center} radius={z.radius}
                pathOptions={{ color: PRIORITY_COLOR[z.priority], fillColor: PRIORITY_COLOR[z.priority], fillOpacity: 0.08, weight: 2 }}>
                <Popup>{z.name} — {z.priority} priority</Popup>
              </Circle>
            ))}
            {mappableListings.map(l => (
              <Marker key={l.id} position={[l.latitude!, l.longitude!]} icon={l.is_urgent ? urgentIcon : new L.Icon.Default()}>
                <Popup>
                  <strong>{l.hotel_name}</strong><br />
                  {l.waste_type} · {l.volume} {l.unit}<br />
                  Min bid: RWF {l.min_bid.toLocaleString()}
                  {l.is_urgent && <><br /><span className="text-red-600 font-semibold">⚠ Urgent</span></>}
                </Popup>
              </Marker>
            ))}
          </MapContainer>
        </div>
      </div>

      {/* Zone table */}
      <div className="bg-white dark:bg-gray-800 rounded-2xl shadow border border-gray-200 dark:border-gray-700 overflow-hidden">
        {zones.length === 0 ? (
          <div className="text-center py-12 text-gray-400 dark:text-gray-500">
            <MapPin size={36} className="mx-auto mb-3 opacity-40" />
            <p className="text-sm">No zones yet. Click <strong>Add Zone</strong> to define a coverage area.</p>
          </div>
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-gray-50 dark:bg-gray-700/50">
              <tr>
                {['Zone Name', 'Center (lat, lng)', 'Radius (m)', 'Priority', 'Open Listings', ''].map(h => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-700">
              {zones.map(z => {
                const activeListings = listings.filter(l => l.status === 'open' && l.address?.toLowerCase().includes(z.name.split(' ')[0].toLowerCase())).length;
                return (
                  <tr key={z.id} className="hover:bg-gray-50 dark:hover:bg-gray-700/30">
                    <td className="px-4 py-3 font-medium text-gray-900 dark:text-white">{z.name}</td>
                    <td className="px-4 py-3 text-gray-500 dark:text-gray-400 font-mono text-xs">{z.center[0].toFixed(4)}, {z.center[1].toFixed(4)}</td>
                    <td className="px-4 py-3 text-gray-600 dark:text-gray-300">{z.radius.toLocaleString()}</td>
                    <td className="px-4 py-3">
                      <span className={`capitalize px-2 py-0.5 rounded text-xs font-medium ${z.priority === 'high' ? 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400' : z.priority === 'medium' ? 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400' : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300'}`}>{z.priority}</span>
                    </td>
                    <td className="px-4 py-3 text-gray-600 dark:text-gray-300">{activeListings}</td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <button onClick={() => openEdit(z)} className="p-1.5 rounded hover:bg-cyan-50 dark:hover:bg-cyan-900/30 text-cyan-600" title="Edit"><Pencil size={14} /></button>
                        <button onClick={() => handleDelete(z.id)} className="p-1.5 rounded hover:bg-red-50 dark:hover:bg-red-900/30 text-red-500" title="Delete"><Trash2 size={14} /></button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>

      {/* Add / Edit Zone Modal */}
      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4" onClick={e => { if (e.target === e.currentTarget) setShowModal(false); }}>
          <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl w-full max-w-md">
            <div className="flex items-center justify-between px-6 pt-5 pb-4 border-b border-gray-100 dark:border-gray-700">
              <h2 className="text-lg font-bold text-gray-900 dark:text-white">{editZone ? 'Edit Zone' : 'New Zone'}</h2>
              <button onClick={() => setShowModal(false)} className="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700/50 text-gray-400"><X size={18} /></button>
            </div>
            <div className="px-6 py-5 space-y-4">
              {formError && <p className="text-sm text-red-600 bg-red-50 dark:bg-red-900/20 rounded-lg px-3 py-2">{formError}</p>}
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Zone Name</label>
                <input value={form.name} onChange={e => setForm(f => ({ ...f, name: e.target.value }))} placeholder="e.g. Kicukiro District"
                  className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Latitude</label>
                  <input type="number" step="0.0001" value={form.lat} onChange={e => setForm(f => ({ ...f, lat: e.target.value }))}
                    className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Longitude</label>
                  <input type="number" step="0.0001" value={form.lng} onChange={e => setForm(f => ({ ...f, lng: e.target.value }))}
                    className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none" />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Radius (meters)</label>
                <input type="number" min={100} value={form.radius} onChange={e => setForm(f => ({ ...f, radius: e.target.value }))}
                  className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none" />
                <p className="text-xs text-gray-400 dark:text-gray-500 mt-1">1000 m = 1 km. Kigali district ≈ 4000–7000 m.</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Priority</label>
                <select value={form.priority} onChange={e => setForm(f => ({ ...f, priority: e.target.value as Zone['priority'] }))}
                  className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none">
                  <option value="high">High</option>
                  <option value="medium">Medium</option>
                  <option value="low">Low</option>
                </select>
              </div>
            </div>
            <div className="px-6 pb-5 flex gap-3 justify-end">
              <button onClick={() => setShowModal(false)} className="px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700/50">Cancel</button>
              <button onClick={handleSave} className="flex items-center gap-2 px-5 py-2 bg-cyan-600 hover:bg-cyan-700 text-white rounded-lg text-sm font-medium">
                <Save size={15} /> {editZone ? 'Save Changes' : 'Add Zone'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
