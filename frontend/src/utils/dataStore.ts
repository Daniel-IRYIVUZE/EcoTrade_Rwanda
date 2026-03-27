
export interface WasteListing {
  id: string;
  businessId: string;
  businessName: string;
  hotelName?: string; // Alias for businessName (from API)
  hotelId?: string; // Alias for businessId (from API)
  wasteType: 'UCO' | 'Glass' | 'Paper/Cardboard' | 'Mixed';
  volume: number;
  unit: 'kg' | 'liters';
  quality: 'A' | 'B' | 'C';
  photos: string[];
  minBid: number;
  reservePrice: number;
  auctionDuration: string;
  autoAcceptAbove: number;
  specialInstructions: string;
  contactPerson: string;
  status: 'open' | 'assigned' | 'collected' | 'completed' | 'cancelled' | 'expired' | 'draft';
  createdAt: string;
  expiresAt: string;
  bids: Bid[];
  assignedRecycler?: string;
  assignedDriver?: string;
  collectionDate?: string;
  collectionTime?: string;
  actualWeight?: number;
  proofPhotos?: string[];
  location: string;
}

export interface Bid {
  id: string;
  listingId: string;
  recyclerId: string;
  recyclerName: string;
  amount: number;
  note: string;
  collectionPreference: string;
  status: 'active' | 'won' | 'lost' | 'withdrawn';
  createdAt: string;
}

export interface PlatformUser {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: 'admin' | 'business' | 'recycler' | 'driver' | 'individual';
  status: 'active' | 'pending' | 'suspended';
  location: string;
  joinDate: string;
  lastActive: string;
  avatar: string;
  verified: boolean;
  greenScore?: number;
  monthlyWaste?: number;
  totalRevenue?: number;
  vehicleType?: string;
  vehiclePlate?: string;
  rating?: number;
  completedRoutes?: number;
  processingCapacity?: number;
  licenseNumber?: string;
  wasteTypes?: string[];
}

export interface Transaction {
  id: string;
  date: string;
  from: string;
  to: string;
  wasteType: string;
  volume: number;
  amount: number;
  fee: number;
  status: 'pending' | 'completed' | 'disputed' | 'refunded';
  listingId: string;
  receipt?: string;
}

export interface Collection {
  id: string;
  listingId: string;
  businessName: string;
  hotelName?: string; // Alias for businessName (from API)
  recyclerName: string;
  driverName: string;
  driverId: string;
  wasteType: string;
  volume: number;
  status: 'scheduled' | 'en-route' | 'collected' | 'verified' | 'completed' | 'missed';
  scheduledDate: string;
  scheduledTime: string;
  completedAt?: string;
  proofPhotos: string[];
  actualWeight?: number;
  rating?: number;
  notes: string;
  location: string;
  earnings: number;
  createdAt?: string;
}

export interface SupportTicket {
  id: string;
  userId: string;
  userName: string;
  subject: string;
  message: string;
  status: 'open' | 'in-progress' | 'resolved' | 'closed';
  priority: 'low' | 'medium' | 'high' | 'urgent';
  createdAt: string;
  updatedAt: string;
  responses: { from: string; message: string; date: string }[];
}

export interface AuditLog {
  id: string;
  timestamp: string;
  adminUser: string;
  action: 'create' | 'read' | 'update' | 'delete';
  target: string;
  details: string;
  status: 'success' | 'failure';
}

export interface DriverRoute {
  id: string;
  driverId: string;
  date: string;
  stops: RouteStop[];
  status: 'pending' | 'in-progress' | 'completed';
  totalDistance: number;
  estimatedEarnings: number;
  actualEarnings?: number;
  startTime: string;
  endTime?: string;
}

export interface RouteStop {
  id: string;
  businessName: string;
  location: string;
  wasteType: string;
  volume: number;
  eta: string;
  status: 'pending' | 'arrived' | 'collecting' | 'completed' | 'skipped';
  contactPerson: string;
  contactPhone: string;
  specialInstructions: string;
  actualWeight?: number;
  photos: string[];
  completedAt?: string;
}

export interface RecyclingEvent {
  id: string;
  userId: string;
  userName: string;
  date: string;
  wasteType: 'Plastic' | 'Paper/Cardboard' | 'Glass' | 'Organic Waste' | 'Metal' | 'E-Waste' | 'Mixed';
  weight: number;
  location: string;
  points: number;
  notes: string;
  verified: boolean;
}

export interface Message {
  id: string;
  from: string;
  fromName: string;
  to: string;
  toName: string;
  subject: string;
  body: string;
  date: string;
  read: boolean;
  replies: { from: string; fromName: string; body: string; date: string }[];
}

// --- Storage helpers ---
const STORE_KEY = 'ecotrade_store';

function getStore(): Record<string, any> {
  try {
    const raw = localStorage.getItem(STORE_KEY);
    return raw ? JSON.parse(raw) : {};
  } catch { return {}; }
}

function setStore(store: Record<string, any>) {
  localStorage.setItem(STORE_KEY, JSON.stringify(store));
  window.dispatchEvent(new Event('ecotrade_data_change'));
}

function getCollection<T>(key: string): T[] {
  return getStore()[key] || [];
}

function setCollection<T>(key: string, data: T[]) {
  const store = getStore();
  store[key] = data;
  setStore(store);
}

// --- Generic CRUD ---
export function getAll<T>(collection: string): T[] {
  return getCollection<T>(collection);
}

export function getById<T extends { id: string }>(collection: string, id: string): T | undefined {
  return getCollection<T>(collection).find(item => item.id === id);
}

export function create<T extends { id: string }>(collection: string, item: T): T {
  const items = getCollection<T>(collection);
  items.push(item);
  setCollection(collection, items);
  addAuditLog('create', collection, `Created ${collection} item: ${item.id}`);
  return item;
}

export function update<T extends { id: string }>(collection: string, id: string, updates: Partial<T>): T | undefined {
  const items = getCollection<T>(collection);
  const index = items.findIndex(item => item.id === id);
  if (index === -1) return undefined;
  items[index] = { ...items[index], ...updates };
  setCollection(collection, items);
  addAuditLog('update', collection, `Updated ${collection} item: ${id}`);
  return items[index];
}

export function remove<T extends { id: string }>(collection: string, id: string): boolean {
  const items = getCollection<T>(collection);
  const filtered = items.filter(item => item.id !== id);
  if (filtered.length === items.length) return false;
  setCollection(collection, filtered);
  addAuditLog('delete', collection, `Deleted ${collection} item: ${id}`);
  return true;
}

// --- Audit log helper ---
function addAuditLog(action: AuditLog['action'], target: string, details: string) {
  const logs = getCollection<AuditLog>('auditLogs');
  logs.unshift({
    id: `AL-${Date.now()}`,
    timestamp: new Date().toISOString(),
    adminUser: localStorage.getItem('userName') || 'System',
    action,
    target,
    details,
    status: 'success'
  });
  // Keep only last 500 entries
  if (logs.length > 500) logs.length = 500;
  const store = getStore();
  store['auditLogs'] = logs;
  localStorage.setItem(STORE_KEY, JSON.stringify(store));
}

// --- Report generation ---
export function generateCSV(headers: string[], rows: string[][]): string {
  const csvContent = [headers.join(','), ...rows.map(row => row.map(cell => `"${String(cell).replace(/"/g, '""')}"`).join(','))].join('\n');
  return csvContent;
}

export function downloadCSV(filename: string, headers: string[], rows: string[][]) {
  const csv = generateCSV(headers, rows);
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = `${filename}_${new Date().toISOString().split('T')[0]}.csv`;
  link.click();
  URL.revokeObjectURL(link.href);
}

export function downloadPDF(title: string, content: string) {
  // Generate printable HTML report and trigger print dialog
  const printWindow = window.open('', '_blank');
  if (!printWindow) return;
  printWindow.document.write(`
    <!DOCTYPE html>
    <html><head><title>${title}</title>
    <style>
      body { font-family: 'Segoe UI', Arial, sans-serif; padding: 40px; color: #1a1a1a; }
      h1 { color: #0891b2; border-bottom: 3px solid #0891b2; padding-bottom: 10px; }
      h2 { color: #333; margin-top: 30px; }
      table { width: 100%; border-collapse: collapse; margin: 15px 0; }
      th { background: #0891b2; color: white; padding: 10px; text-align: left; }
      td { padding: 8px 10px; border-bottom: 1px solid #ddd; }
      tr:nth-child(even) { background: #f8f8f8; }
      .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
      .logo { font-size: 24px; font-weight: bold; color: #0891b2; }
      .date { color: #666; }
      .footer { margin-top: 40px; padding-top: 20px; border-top: 1px solid #ddd; color: #888; font-size: 12px; text-align: center; }
      .stat-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; margin: 20px 0; }
      .stat-card { background: #f0fdfa; padding: 15px; border-radius: 8px; text-align: center; }
      .stat-value { font-size: 24px; font-weight: bold; color: #0891b2; }
      .stat-label { font-size: 12px; color: #666; margin-top: 5px; }
      @media print { body { padding: 20px; } }
    </style></head><body>
    <div class="header">
      <div class="logo">EcoTrade Rwanda</div>
      <div class="date">Generated: ${new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' })}</div>
    </div>
    <h1>${title}</h1>
    ${content}
    <div class="footer">
      <p>EcoTrade Rwanda — Digital B2B Marketplace for Reverse Logistics</p>
      <p>Kigali, Rwanda | contact@ecotrade.rw | +250 780 162 164</p>
    </div>
    </body></html>
  `);
  printWindow.document.close();
  setTimeout(() => printWindow.print(), 500);
}

// --- ID generator ---
export function generateId(prefix: string = 'ET'): string {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`;
}

// seedDataIfEmpty — removed: all data now comes from the backend API via syncFromAPI().

// --- Bulk save helper (used by apiSync) ---
export function saveAll(collection: string, items: any[]) {
  const store = getStore();
  store[collection] = items;
  setStore(store);
}
