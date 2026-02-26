import { CheckCircle, Clock, Truck } from 'lucide-react';
import { useState } from 'react';
import { motion } from 'framer-motion';

const RecyclerPurchasesSection = () => {
  const [purchases] = useState([
    { id: 1, date: '2026-02-19', seller: 'Park Inn by Radisson', material: 'UCO', quantity: '100L', amount: 13000, status: 'completed', driver: 'Emmanuel Mugisha' },
    { id: 2, date: '2026-02-23', seller: 'Mille Collines Hotel', material: 'UCO', quantity: '150L', amount: 22500, status: 'completed', driver: 'Jean Pierre Habimana' },
    { id: 3, date: '2026-02-25', seller: 'Serena Hotel Kigali', material: 'Glass', quantity: '150kg', amount: 11500, status: 'in-transit', driver: 'Jean Pierre Habimana' },
  ]);

  const getStatusIcon = (status: string) => {
    switch(status) {
      case 'completed': return <CheckCircle size={16} className="text-cyan-600" />;
      case 'in-transit': return <Truck size={16} className="text-blue-600" />;
      case 'scheduled': return <Clock size={16} className="text-amber-600" />;
      default: return null;
    }
  };

  const getStatusBadge = (status: string) => {
    switch(status) {
      case 'completed': return 'bg-cyan-100 text-cyan-700';
      case 'in-transit': return 'bg-blue-100 text-blue-700';
      case 'scheduled': return 'bg-amber-100 text-amber-700';
      default: return 'bg-gray-100 text-gray-700';
    }
  };

  return (
    <section className="bg-white rounded-xl border border-gray-200 overflow-hidden">
      <div className="p-6 border-b border-gray-200">
        <h2 className="text-xl font-bold text-gray-900">Recent Purchases</h2>
      </div>
      
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-gray-50 border-b border-gray-200">
            <tr>
              <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Date</th>
              <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Seller</th>
              <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Material</th>
              <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Quantity</th>
              <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Amount</th>
              <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Status</th>
              <th className="px-6 py-3 text-left text-sm font-medium text-gray-700">Driver</th>
            </tr>
          </thead>
          <tbody>
            {purchases.map((purchase) => (
              <motion.tr key={purchase.id} className="border-b border-gray-200 hover:bg-gray-50">
                <td className="px-6 py-4 text-sm text-gray-600">{purchase.date}</td>
                <td className="px-6 py-4 text-sm font-medium text-gray-900">{purchase.seller}</td>
                <td className="px-6 py-4 text-sm text-gray-600">{purchase.material}</td>
                <td className="px-6 py-4 text-sm text-gray-600">{purchase.quantity}</td>
                <td className="px-6 py-4 text-sm font-medium text-gray-900">Rwf {purchase.amount.toLocaleString()}</td>
                <td className="px-6 py-4 text-sm">
                  <div className="flex items-center gap-2">
                    {getStatusIcon(purchase.status)}
                    <span className={`px-3 py-1 rounded-full text-xs font-medium ${getStatusBadge(purchase.status)}`}>
                      {purchase.status}
                    </span>
                  </div>
                </td>
                <td className="px-6 py-4 text-sm text-gray-600">{purchase.driver}</td>
              </motion.tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
};

export default RecyclerPurchasesSection;
