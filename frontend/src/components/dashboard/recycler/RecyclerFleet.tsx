import { useState, useEffect } from 'react';
import { driversAPI, collectionsAPI, vehiclesAPI, recyclersAPI } from '../../../services/api';
import type { Collection, DriverProfile, VehicleItem, RecyclerProfile } from '../../../services/api';
import { Truck, Search, Plus, Eye, Trash2, CheckCircle, AlertTriangle, Activity, X, Save, MapPin } from 'lucide-react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import StatCard from '../StatCard';
import { StatusBadge } from './_shared';

// Fix Leaflet default icon for Vite
delete (L.Icon.Default.prototype as unknown as Record<string, unknown>)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

const KIGALI_CENTER: [number, number] = [-1.9441, 30.0619];
const VEHICLE_TYPES = ['Truck', 'Van', 'Pickup Truck', 'Lorry', 'Compact Van', 'Motorcycle'];

interface VehicleForm {
  plate_number: string;
  vehicle_type: string;
  capacity_kg: string;
  make: string;
  model: string;
  year: string;
}
const EMPTY_VF: VehicleForm = { plate_number: '', vehicle_type: 'Truck', capacity_kg: '1000', make: '', model: '', year: '' };

interface ViewDriver { driver: DriverProfile; vehicle?: VehicleItem }

export default function RecyclerFleet() {
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [drivers, setDrivers] = useState<DriverProfile[]>([]);
  const [vehicles, setVehicles] = useState<VehicleItem[]>([]);
  const [collections, setCollections] = useState<Collection[]>([]);
  const [recycler, setRecycler] = useState<RecyclerProfile | null>(null);
  const [showAddVehicle, setShowAddVehicle] = useState(false);
  const [vehicleForm, setVehicleForm] = useState<VehicleForm>(EMPTY_VF);
  const [vehicleSaving, setVehicleSaving] = useState(false);
  const [vehicleError, setVehicleError] = useState('');
  const [viewDriver, setViewDriver] = useState<ViewDriver | null>(null);
  const [deletingVehicle, setDeletingVehicle] = useState<number | null>(null);

  const load = () => {
    Promise.all([
      driversAPI.list({ limit: 100 }).catch(() => [] as DriverProfile[]),
      vehiclesAPI.list().catch(() => [] as VehicleItem[]),
      collectionsAPI.list({ limit: 200 }).catch(() => [] as Collection[]),
      recyclersAPI.me().catch(() => null as RecyclerProfile | null),
    ]).then(([ds, vs, cs, rec]) => {
      setDrivers(ds);
      setVehicles(vs);
      setCollections(cs);
      setRecycler(rec);
    });
  };

  useEffect(() => { load(); }, []);

  // Only show drivers belonging to this recycler
  const myDrivers = recycler ? drivers.filter(d => d.recycler_id === recycler.id) : drivers;

  const fleetData = myDrivers.map(driver => {
    const vehicle = vehicles.find(v => v.id === driver.vehicle_id);
    const driverCollections = collections.filter(c => (c as unknown as { driver_id?: number }).driver_id === driver.id);
    const completedTrips = driverCollections.filter(c => c.status === 'completed').length;
    const activeRoute = driverCollections.find(c => c.status === 'en_route');
    return {
      id: driver.id,
      driver,
      vehicle,
      driverName: driver.name || `Driver #${driver.id}`,
      vehicleLabel: vehicle ? `${vehicle.vehicle_type} — ${vehicle.plate_number}` : (driver.vehicle_type || 'No vehicle'),
      plate: vehicle?.plate_number || driver.plate_number || '—',
      capacity: vehicle ? `${vehicle.capacity_kg.toLocaleString()} kg` : '—',
      trips: completedTrips || driver.total_trips || 0,
      rating: driver.rating || 4.8,
      onRoute: !!activeRoute,
      status: driver.status === 'available' ? 'active' : (driver.status === 'off_duty' ? 'maintenance' : driver.status === 'on_route' ? 'active' : 'inactive'),
    };
  });

  const filtered = fleetData.filter(f => {
    const matchSearch = f.driverName.toLowerCase().includes(search.toLowerCase()) || f.plate.toLowerCase().includes(search.toLowerCase());
    const matchStatus = statusFilter === 'all' || f.status === statusFilter;
    return matchSearch && matchStatus;
  });

  const liveDrivers = myDrivers.filter(d => d.current_lat && d.current_lng);

  const handleAddVehicle = async () => {
    if (!vehicleForm.plate_number.trim()) { setVehicleError('Plate number is required.'); return; }
    const cap = parseFloat(vehicleForm.capacity_kg);
    if (isNaN(cap) || cap <= 0) { setVehicleError('Capacity must be a positive number.'); return; }
    setVehicleSaving(true); setVehicleError('');
    try {
      await vehiclesAPI.create({
        plate_number: vehicleForm.plate_number.trim().toUpperCase(),
        vehicle_type: vehicleForm.vehicle_type,
        capacity_kg: cap,
        make: vehicleForm.make || undefined,
        model: vehicleForm.model || undefined,
        year: vehicleForm.year ? parseInt(vehicleForm.year) : undefined,
      });
      setShowAddVehicle(false);
      setVehicleForm(EMPTY_VF);
      load();
    } catch (e: unknown) {
      setVehicleError(e instanceof Error ? e.message : 'Failed to add vehicle.');
    } finally {
      setVehicleSaving(false);
    }
  };

  const handleDeleteVehicle = async (vehicleId: number) => {
    if (!confirm('Remove this vehicle from your fleet? This cannot be undone.')) return;
    setDeletingVehicle(vehicleId);
    try {
      await vehiclesAPI.delete(vehicleId);
      load();
    } catch { alert('Failed to delete vehicle.'); }
    finally { setDeletingVehicle(null); }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">My Fleet</h1>
        <button onClick={() => { setShowAddVehicle(true); setVehicleForm(EMPTY_VF); setVehicleError(''); }}
          className="flex items-center gap-2 px-4 py-2 bg-cyan-600 text-white rounded-lg text-sm hover:bg-cyan-700">
          <Plus size={16} /> Add Vehicle
        </button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <StatCard title="Fleet Vehicles" value={vehicles.length} icon={<Truck size={22} />} color="cyan" />
        <StatCard title="Active Drivers" value={fleetData.filter(f => f.status === 'active').length} icon={<CheckCircle size={22} />} color="blue" />
        <StatCard title="On Route" value={fleetData.filter(f => f.onRoute).length} icon={<Activity size={22} />} color="purple" />
        <StatCard title="Maintenance" value={fleetData.filter(f => f.status === 'maintenance').length} icon={<AlertTriangle size={22} />} color="yellow" />
      </div>

      {/* Live Map */}
      <div className="bg-white dark:bg-gray-800 rounded-2xl shadow border border-gray-200 dark:border-gray-700 overflow-hidden">
        <div className="p-4 border-b border-gray-100 dark:border-gray-700 flex items-center gap-2">
          <MapPin size={16} className="text-cyan-600" />
          <span className="text-sm font-semibold text-gray-900 dark:text-white">Live Fleet Map</span>
          <span className="ml-auto text-xs text-gray-500 dark:text-gray-400">{liveDrivers.length} driver{liveDrivers.length !== 1 ? 's' : ''} with live location</span>
        </div>
        <div style={{ height: 320 }}>
          {typeof window !== 'undefined' && (
            <MapContainer center={KIGALI_CENTER} zoom={12} style={{ height: '100%', width: '100%' }} scrollWheelZoom={false}>
              <TileLayer
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              {liveDrivers.map(d => (
                <Marker key={d.id} position={[d.current_lat!, d.current_lng!]}>
                  <Popup>
                    <strong>{d.name || `Driver #${d.id}`}</strong><br />
                    {d.vehicle_type || 'Vehicle'} · {d.plate_number || 'N/A'}<br />
                    Status: {d.status}
                  </Popup>
                </Marker>
              ))}
            </MapContainer>
          )}
        </div>
        {liveDrivers.length === 0 && (
          <div className="px-4 pb-3 text-xs text-gray-400 dark:text-gray-500 text-center">
            No drivers have shared their live location yet.
          </div>
        )}
      </div>

      {/* Fleet Vehicles table */}
      <div className="bg-white dark:bg-gray-800 rounded-2xl shadow border border-gray-200 dark:border-gray-700 p-4">
        <h2 className="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-3 flex items-center gap-2">
          <Truck size={15} className="text-cyan-600" /> Registered Vehicles
        </h2>
        {vehicles.length === 0 ? (
          <p className="text-sm text-gray-400 dark:text-gray-500 text-center py-6">No vehicles registered yet. Click <strong>Add Vehicle</strong> to start building your fleet.</p>
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-gray-50 dark:bg-gray-700/50">
              <tr>
                {['Plate', 'Type', 'Make / Model', 'Capacity', 'Status', ''].map(h => (
                  <th key={h} className="px-3 py-2 text-left text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-700">
              {vehicles.map(v => (
                <tr key={v.id} className="hover:bg-gray-50 dark:hover:bg-gray-700/30">
                  <td className="px-3 py-2 font-mono font-medium text-gray-900 dark:text-white">{v.plate_number}</td>
                  <td className="px-3 py-2 text-gray-700 dark:text-gray-300">{v.vehicle_type}</td>
                  <td className="px-3 py-2 text-gray-500 dark:text-gray-400">{[v.make, v.model, v.year].filter(Boolean).join(' ') || '—'}</td>
                  <td className="px-3 py-2 text-gray-600 dark:text-gray-300">{v.capacity_kg.toLocaleString()} kg</td>
                  <td className="px-3 py-2">
                    <span className={`capitalize text-xs px-2 py-0.5 rounded font-medium ${v.status === 'active' ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400' : v.status === 'maintenance' ? 'bg-yellow-100 text-yellow-700' : 'bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300'}`}>{v.status}</span>
                  </td>
                  <td className="px-3 py-2">
                    <button onClick={() => handleDeleteVehicle(v.id)} disabled={deletingVehicle === v.id}
                      className="p-1.5 rounded hover:bg-red-50 dark:hover:bg-red-900/30 text-red-400 hover:text-red-600" title="Remove">
                      <Trash2 size={14} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Drivers table */}
      <div className="bg-white dark:bg-gray-800 rounded-2xl shadow border border-gray-200 dark:border-gray-700 p-4">
        <h2 className="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-3">Driver Assignments</h2>
        <div className="flex flex-col md:flex-row gap-3 mb-4">
          <div className="relative flex-1">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search drivers or plates…"
              className="w-full pl-10 pr-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-cyan-500 outline-none" />
          </div>
          <select value={statusFilter} onChange={e => setStatusFilter(e.target.value)}
            className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-sm bg-white dark:bg-gray-700 text-gray-900 dark:text-white">
            <option value="all">All Status</option>
            <option value="active">Active</option>
            <option value="maintenance">Maintenance</option>
            <option value="inactive">Inactive</option>
          </select>
        </div>
        {filtered.length === 0 ? (
          <p className="text-sm text-gray-400 dark:text-gray-500 text-center py-6">No drivers found{myDrivers.length === 0 ? '. Add drivers from the Drivers page.' : '.'}</p>
        ) : (
          <table className="w-full text-sm">
            <thead className="bg-gray-50 dark:bg-gray-700/50">
              <tr>
                {['Driver', 'Vehicle', 'Capacity', 'Trips', 'Rating', 'Route', 'Availability', ''].map(h => (
                  <th key={h} className="px-3 py-2 text-left text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-700">
              {filtered.map(f => (
                <tr key={f.id} className="hover:bg-gray-50 dark:hover:bg-gray-700/30">
                  <td className="px-3 py-2 font-medium text-gray-900 dark:text-white">{f.driverName}</td>
                  <td className="px-3 py-2">
                    <p className="text-sm text-gray-700 dark:text-gray-300">{f.vehicle?.vehicle_type || f.driver.vehicle_type || '—'}</p>
                    <p className="text-xs text-gray-400 dark:text-gray-500">{f.plate}</p>
                  </td>
                  <td className="px-3 py-2 text-gray-600 dark:text-gray-300">{f.capacity}</td>
                  <td className="px-3 py-2 text-gray-600 dark:text-gray-300">{f.trips}</td>
                  <td className="px-3 py-2 text-yellow-600 font-semibold">⭐ {f.rating.toFixed(1)}</td>
                  <td className="px-3 py-2">
                    {f.onRoute ? <span className="text-blue-600 dark:text-blue-400 font-medium text-xs">On Route</span> : <span className="text-gray-400 text-xs">Idle</span>}
                  </td>
                  <td className="px-3 py-2"><StatusBadge status={f.status} /></td>
                  <td className="px-3 py-2">
                    <button onClick={() => setViewDriver({ driver: f.driver, vehicle: f.vehicle })}
                      className="p-1.5 text-cyan-600 hover:bg-cyan-50 dark:hover:bg-cyan-900/20 rounded" title="View details">
                      <Eye size={15} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Add Vehicle Modal */}
      {showAddVehicle && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4" onClick={e => { if (e.target === e.currentTarget) setShowAddVehicle(false); }}>
          <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl w-full max-w-md">
            <div className="flex items-center justify-between px-6 pt-5 pb-4 border-b border-gray-100 dark:border-gray-700">
              <h2 className="text-lg font-bold text-gray-900 dark:text-white">Add Vehicle to Fleet</h2>
              <button onClick={() => setShowAddVehicle(false)} className="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700/50 text-gray-400"><X size={18} /></button>
            </div>
            <div className="px-6 py-5 space-y-4">
              {vehicleError && <p className="text-sm text-red-600 bg-red-50 dark:bg-red-900/20 rounded-lg px-3 py-2">{vehicleError}</p>}
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Plate Number <span className="text-red-500">*</span></label>
                <input value={vehicleForm.plate_number} onChange={e => setVehicleForm(f => ({ ...f, plate_number: e.target.value }))} placeholder="e.g. RAB 123A"
                  className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Vehicle Type</label>
                  <select value={vehicleForm.vehicle_type} onChange={e => setVehicleForm(f => ({ ...f, vehicle_type: e.target.value }))}
                    className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none">
                    {VEHICLE_TYPES.map(t => <option key={t}>{t}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Capacity (kg) <span className="text-red-500">*</span></label>
                  <input type="number" min={1} value={vehicleForm.capacity_kg} onChange={e => setVehicleForm(f => ({ ...f, capacity_kg: e.target.value }))}
                    className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none" />
                </div>
              </div>
              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Make</label>
                  <input value={vehicleForm.make} onChange={e => setVehicleForm(f => ({ ...f, make: e.target.value }))} placeholder="Toyota"
                    className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Model</label>
                  <input value={vehicleForm.model} onChange={e => setVehicleForm(f => ({ ...f, model: e.target.value }))} placeholder="Hilux"
                    className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Year</label>
                  <input type="number" value={vehicleForm.year} onChange={e => setVehicleForm(f => ({ ...f, year: e.target.value }))} placeholder="2022"
                    className="w-full px-3 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white text-sm focus:ring-2 focus:ring-cyan-500 outline-none" />
                </div>
              </div>
            </div>
            <div className="px-6 pb-5 flex gap-3 justify-end">
              <button onClick={() => setShowAddVehicle(false)} className="px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700/50">Cancel</button>
              <button onClick={handleAddVehicle} disabled={vehicleSaving} className="flex items-center gap-2 px-5 py-2 bg-cyan-600 hover:bg-cyan-700 disabled:opacity-60 text-white rounded-lg text-sm font-medium">
                {vehicleSaving ? <span className="animate-spin border-2 border-white border-t-transparent rounded-full w-4 h-4" /> : <Save size={15} />}
                {vehicleSaving ? 'Saving…' : 'Add Vehicle'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* View Driver Modal */}
      {viewDriver && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4" onClick={e => { if (e.target === e.currentTarget) setViewDriver(null); }}>
          <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl w-full max-w-sm">
            <div className="flex items-center justify-between px-6 pt-5 pb-4 border-b border-gray-100 dark:border-gray-700">
              <h2 className="text-lg font-bold text-gray-900 dark:text-white">Driver Details</h2>
              <button onClick={() => setViewDriver(null)} className="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700/50 text-gray-400"><X size={18} /></button>
            </div>
            <div className="px-6 py-5 space-y-3 text-sm">
              <div className="flex items-center gap-4 pb-3 border-b border-gray-100 dark:border-gray-700">
                <div className="w-14 h-14 bg-gradient-to-br from-cyan-500 to-teal-600 rounded-full flex items-center justify-center text-white font-bold text-xl">
                  {(viewDriver.driver.name || 'D')[0].toUpperCase()}
                </div>
                <div>
                  <p className="font-semibold text-gray-900 dark:text-white text-base">{viewDriver.driver.name || `Driver #${viewDriver.driver.id}`}</p>
                  <p className="text-xs text-gray-400">⭐ {viewDriver.driver.rating.toFixed(1)} · {viewDriver.driver.total_trips} trips</p>
                </div>
              </div>
              {[
                ['Status', viewDriver.driver.status],
                ['Phone', viewDriver.driver.phone || '—'],
                ['License', viewDriver.driver.license_number || '—'],
                ['Vehicle Type', viewDriver.vehicle?.vehicle_type || viewDriver.driver.vehicle_type || '—'],
                ['Plate', viewDriver.vehicle?.plate_number || viewDriver.driver.plate_number || '—'],
                ['Capacity', viewDriver.vehicle ? `${viewDriver.vehicle.capacity_kg.toLocaleString()} kg` : '—'],
                ['Verified', viewDriver.driver.is_verified ? '✅ Yes' : '❌ No'],
              ].map(([label, val]) => (
                <div key={label} className="flex justify-between text-sm">
                  <span className="text-gray-500 dark:text-gray-400">{label}</span>
                  <span className="font-medium text-gray-900 dark:text-white capitalize">{val}</span>
                </div>
              ))}
            </div>
            <div className="px-6 pb-5">
              <button onClick={() => setViewDriver(null)} className="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700/50">Close</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
