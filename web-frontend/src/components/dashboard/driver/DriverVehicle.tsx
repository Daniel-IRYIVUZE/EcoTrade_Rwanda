import { Truck, Battery, Fuel, Activity, AlertTriangle } from 'lucide-react';
import { driverProfile } from './_shared';

const ProgressBar = ({ value, color }: { value: number; color: string }) => (
  <div className="w-full bg-gray-200 rounded-full h-2.5">
    <div className={`h-2.5 rounded-full ${color}`} style={{ width: `${value}%` }} />
  </div>
);

export default function DriverVehicle() {
  const v = { ...driverProfile, licensePlate: driverProfile.plate };

  const maintenance = [
    { item: 'Oil Change', due: '2024-08-15', status: 'OK', daysLeft: 40 },
    { item: 'Tire Rotation', due: '2024-07-30', status: 'Due Soon', daysLeft: 25 },
    { item: 'Brake Inspection', due: '2024-09-01', status: 'OK', daysLeft: 57 },
    { item: 'Air Filter', due: '2024-07-25', status: 'Action Required', daysLeft: 20 },
  ];
  const statusColor: Record<string, string> = {
    'OK': 'text-green-600 bg-green-50', 'Due Soon': 'text-yellow-600 bg-yellow-50', 'Action Required': 'text-red-600 bg-red-50',
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">My Vehicle</h1>
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="flex items-center gap-3 mb-6">
            <div className="p-3 bg-cyan-50 rounded-xl"><Truck size={24} className="text-cyan-600" /></div>
            <div><h2 className="text-lg font-semibold text-gray-900">{v.vehicle}</h2><p className="text-sm text-gray-500">License Plate: {v.licensePlate}</p></div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            {[
              ['Fuel Efficiency', '11.2 km/L'],
              ['Total Distance', '45,800 km'],
              ['Avg Load', '2.4 tonnes'],
              ['Last Service', '2024-06-01'],
              ['Next Service', '2024-08-15'],
              ['Insurance Exp.', '2025-01-31'],
            ].map(([k, val]) => (
              <div key={k} className="bg-gray-50 rounded-lg p-3">
                <p className="text-xs text-gray-500 uppercase tracking-wide mb-1">{k}</p>
                <p className="font-semibold text-gray-900">{val}</p>
              </div>
            ))}
          </div>
        </div>
        <div className="space-y-4">
          {[
            { label: 'Fuel Level', value: 72, icon: <Fuel size={18} />, color: 'bg-amber-400' },
            { label: 'Battery', value: 88, icon: <Battery size={18} />, color: 'bg-green-500' },
            { label: 'Tire Condition', value: 65, icon: <Activity size={18} />, color: 'bg-blue-500' },
          ].map(item => (
            <div key={item.label} className="bg-white rounded-xl shadow-sm p-5 border border-gray-100">
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center gap-2 text-gray-700">{item.icon}<span className="text-sm font-medium">{item.label}</span></div>
                <span className="text-lg font-bold text-gray-900">{item.value}%</span>
              </div>
              <ProgressBar value={item.value} color={item.color} />
            </div>
          ))}
        </div>
      </div>
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <div className="flex items-center gap-2 mb-4"><AlertTriangle size={20} className="text-amber-500" /><h2 className="text-lg font-semibold text-gray-900">Maintenance Schedule</h2></div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm text-left">
            <thead><tr className="border-b border-gray-100 text-gray-500 text-xs uppercase">{['Item','Due Date','Status','Days Left'].map(h => <th key={h} className="pb-3 pr-4">{h}</th>)}</tr></thead>
            <tbody>{maintenance.map(m => (
              <tr key={m.item} className="border-b border-gray-50 hover:bg-gray-50">
                <td className="py-3 pr-4 font-medium">{m.item}</td>
                <td className="py-3 pr-4 text-gray-600">{m.due}</td>
                <td className="py-3 pr-4"><span className={`px-2 py-0.5 rounded-full text-xs font-medium ${statusColor[m.status]}`}>{m.status}</span></td>
                <td className="py-3 text-gray-600">{m.daysLeft}d</td>
              </tr>
            ))}</tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
