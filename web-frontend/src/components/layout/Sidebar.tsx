// components/layout/Sidebar.tsx
import { useState, useEffect } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import {
  Home, Users, Package, Truck, Settings, BarChart3, DollarSign,
  Calendar, Map, FileText, ShoppingCart, Recycle, LogOut, ChevronLeft,
  ChevronRight, Menu, X, Shield, ClipboardList, Trophy, MessageSquare,
  Building2, Factory, MapPin, Phone, Star, PlusCircle, Eye,
  CheckCircle, Warehouse, Route
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';

interface SidebarProps {
  userRole: 'admin' | 'business' | 'recycler' | 'driver' | 'individual';
}

const Sidebar = ({ userRole }: SidebarProps) => {
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const { logout } = useAuth();
  const { isDark } = useTheme();
  const navigate = useNavigate();

  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth >= 768) setMobileOpen(false);
    };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const roleConfigs: Record<string, { label: string; navItems: { path: string; label: string; icon: React.ReactNode }[] }> = {
    admin: {
      label: 'Admin Panel',
      navItems: [
        { path: '/dashboard/admin', label: 'Dashboard Home', icon: <BarChart3 size={20} /> },
        { path: '/dashboard/admin/users', label: 'User Management', icon: <Users size={20} /> },
        { path: '/dashboard/admin/hotels', label: 'Hotels', icon: <Building2 size={20} /> },
        { path: '/dashboard/admin/recyclers', label: 'Recyclers', icon: <Factory size={20} /> },
        { path: '/dashboard/admin/drivers', label: 'Drivers', icon: <Truck size={20} /> },
        { path: '/dashboard/admin/listings', label: 'Waste Listings', icon: <Package size={20} /> },
        { path: '/dashboard/admin/routes', label: 'Route Monitor', icon: <Map size={20} /> },
        { path: '/dashboard/admin/transactions', label: 'Transactions', icon: <DollarSign size={20} /> },
        { path: '/dashboard/admin/analytics', label: 'Analytics', icon: <BarChart3 size={20} /> },
        { path: '/dashboard/admin/settings', label: 'System Settings', icon: <Settings size={20} /> },
        { path: '/dashboard/admin/verification', label: 'Verification Queue', icon: <Shield size={20} /> },
        { path: '/dashboard/admin/audit', label: 'Audit Logs', icon: <ClipboardList size={20} /> },
        { path: '/dashboard/admin/greenscore', label: 'Green Scores', icon: <Trophy size={20} /> },
        { path: '/dashboard/admin/reports', label: 'Reports', icon: <FileText size={20} /> },
        { path: '/dashboard/admin/support', label: 'Support Tickets', icon: <MessageSquare size={20} /> },
      ]
    },
    business: {
      label: 'Hotel Dashboard',
      navItems: [
        { path: '/dashboard/business', label: 'Dashboard', icon: <BarChart3 size={20} /> },
        { path: '/dashboard/business/listings', label: 'My Waste Listings', icon: <Package size={20} /> },
        { path: '/dashboard/business/new-listing', label: 'Add New Listing', icon: <PlusCircle size={20} /> },
        { path: '/dashboard/business/revenue', label: 'Revenue', icon: <DollarSign size={20} /> },
        { path: '/dashboard/business/greenscore', label: 'Green Score', icon: <Trophy size={20} /> },
        { path: '/dashboard/business/schedule', label: 'Collection Schedule', icon: <Calendar size={20} /> },
        { path: '/dashboard/business/transactions', label: 'Transaction History', icon: <FileText size={20} /> },
        { path: '/dashboard/business/settings', label: 'Hotel Settings', icon: <Settings size={20} /> },
        { path: '/dashboard/business/reports', label: 'Reports & Certificates', icon: <Star size={20} /> },
        { path: '/dashboard/business/messages', label: 'Messages', icon: <MessageSquare size={20} /> },
        { path: '/dashboard/business/location', label: 'My Location', icon: <MapPin size={20} /> },
      ]
    },
    recycler: {
      label: 'Recycler Dashboard',
      navItems: [
        { path: '/dashboard/recycler', label: 'Dashboard', icon: <BarChart3 size={20} /> },
        { path: '/dashboard/recycler/fleet', label: 'My Fleet', icon: <Truck size={20} /> },
        { path: '/dashboard/recycler/marketplace', label: 'Available Waste', icon: <ShoppingCart size={20} /> },
        { path: '/dashboard/recycler/bids', label: 'My Bids', icon: <Eye size={20} /> },
        { path: '/dashboard/recycler/collections', label: 'Active Collections', icon: <Route size={20} /> },
        { path: '/dashboard/recycler/inventory', label: 'Inventory', icon: <Warehouse size={20} /> },
        { path: '/dashboard/recycler/revenue', label: 'Revenue', icon: <DollarSign size={20} /> },
        { path: '/dashboard/recycler/impact', label: 'Green Impact', icon: <Trophy size={20} /> },
        { path: '/dashboard/recycler/settings', label: 'Company Settings', icon: <Settings size={20} /> },
        { path: '/dashboard/recycler/reports', label: 'Reports', icon: <FileText size={20} /> },
        { path: '/dashboard/recycler/zones', label: 'Collection Zones', icon: <MapPin size={20} /> },
        { path: '/dashboard/recycler/messages', label: 'Messages', icon: <MessageSquare size={20} /> },
      ]
    },
    driver: {
      label: 'Driver Dashboard',
      navItems: [
        { path: '/dashboard/driver', label: "Today's Route", icon: <Map size={20} /> },
        { path: '/dashboard/driver/assignments', label: 'My Assignments', icon: <ClipboardList size={20} /> },
        { path: '/dashboard/driver/completed', label: 'Completed Jobs', icon: <CheckCircle size={20} /> },
        { path: '/dashboard/driver/earnings', label: 'My Earnings', icon: <DollarSign size={20} /> },
        { path: '/dashboard/driver/vehicle', label: 'My Vehicle', icon: <Truck size={20} /> },
        { path: '/dashboard/driver/settings', label: 'Settings', icon: <Settings size={20} /> },
        { path: '/dashboard/driver/support', label: 'Support', icon: <Phone size={20} /> },
      ]
    },
    individual: {
      label: 'User Dashboard',
      navItems: [
        { path: '/dashboard/individual', label: 'Overview', icon: <Home size={20} /> },
        { path: '/dashboard/individual/marketplace', label: 'Marketplace', icon: <ShoppingCart size={20} /> },
        { path: '/dashboard/individual/impact', label: 'My Impact', icon: <Recycle size={20} /> },
        { path: '/dashboard/individual/orders', label: 'Orders', icon: <Package size={20} /> },
        { path: '/dashboard/individual/financial', label: 'Financial', icon: <DollarSign size={20} /> },
        { path: '/dashboard/individual/settings', label: 'Settings', icon: <Settings size={20} /> },
      ]
    }
  };

  const config = roleConfigs[userRole] || roleConfigs.individual;

  const handleLogout = () => {
    logout();
    localStorage.removeItem('isAuthenticated');
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userRole');
    localStorage.removeItem('userName');
    window.dispatchEvent(new Event('authChange'));
    navigate('/');
  };

  return (
    <>
      <button onClick={() => setMobileOpen(true)} className="md:hidden fixed top-3 left-3 z-50 p-2 bg-gray-900 dark:bg-gray-800 text-white rounded-lg shadow-lg" aria-label="Open sidebar">
        <Menu size={20} />
      </button>
      {mobileOpen && <div className="md:hidden fixed inset-0 bg-black/50 z-40" onClick={() => setMobileOpen(false)} />}
      <aside className={`${collapsed ? 'w-20' : 'w-64'} ${isDark ? 'bg-gray-900 text-white' : 'bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-200 border-r border-gray-200'} flex flex-col transition-all duration-300 fixed md:relative inset-y-0 left-0 z-50 ${mobileOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'}`}>
        <div className="p-4 border-b border-gray-200 dark:border-gray-800 flex items-center justify-between min-h-[64px]">
          {!collapsed ? (
            <div className="flex items-center space-x-3"><img src="/images/EcoTrade1.png" alt="EcoTrade" className="h-10" /></div>
          ) : (
            <img src="/images/EcoTrade.png" alt="EcoTrade" className="h-10 mx-auto" />
          )}
          <div className="flex items-center gap-1">
            <button onClick={() => setMobileOpen(false)} className="md:hidden p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-800"><X size={20} /></button>
            <button onClick={() => setCollapsed(!collapsed)} className="hidden md:block p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-800">
              {collapsed ? <ChevronRight size={20} /> : <ChevronLeft size={20} />}
            </button>
          </div>
        </div>
        {!collapsed && <div className="px-4 py-2 border-b border-gray-200 dark:border-gray-800"><p className="text-xs text-gray-400 dark:text-gray-500 uppercase tracking-wider">{config.label}</p></div>}
        <nav className="flex-1 p-2 space-y-0.5 overflow-y-auto">
          <NavLink to="/" onClick={() => setMobileOpen(false)} className="flex items-center space-x-3 p-2.5 rounded-lg transition-colors hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-600 dark:text-gray-400 border-b border-gray-100 dark:border-gray-800 mb-1 pb-2.5">
            <Home size={18} />{!collapsed && <span className="text-sm">Home</span>}
          </NavLink>
          {config.navItems.map((item) => (
            <NavLink key={item.path} to={item.path} end={item.path === `/dashboard/${userRole}`} onClick={() => setMobileOpen(false)}
              className={({ isActive }) => `flex items-center space-x-3 p-2.5 rounded-lg transition-colors text-sm ${isActive ? 'bg-cyan-600 text-white' : `hover:bg-gray-100 dark:hover:bg-gray-800 ${isDark ? 'text-gray-300' : 'text-gray-700 dark:text-gray-300'}`}`}>
              {item.icon}{!collapsed && <span>{item.label}</span>}
            </NavLink>
          ))}
        </nav>
        <div className="p-3 border-t border-gray-200 dark:border-gray-800">
          {!collapsed && <div className="mb-3"><p className="text-xs text-gray-400 dark:text-gray-500">Logged in as</p><p className="text-sm font-medium capitalize text-gray-700 dark:text-gray-200">{userRole}</p></div>}
          <button onClick={handleLogout} className="flex items-center space-x-3 p-2.5 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/50 text-gray-600 dark:text-gray-300 hover:text-red-600 dark:hover:text-red-300 w-full transition-colors">
            <LogOut size={18} />{!collapsed && <span className="text-sm">Logout</span>}
          </button>
        </div>
      </aside>
    </>
  );
};

export default Sidebar;
