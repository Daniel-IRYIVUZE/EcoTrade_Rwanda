// utils/dataManagement.ts
// Comprehensive data management with proper local storage syncing

import { 
  getAll, create, update, remove
} from './dataStore';
import type { 
  WasteListing, Collection, PlatformUser, Transaction, Message 
} from './dataStore';

export class DataManager {
  // Listings
  static getListings(filters?: { status?: string; businessId?: string }) {
    let listings = getAll<WasteListing>('listings');
    if (filters?.status) listings = listings.filter(l => l.status === filters.status);
    if (filters?.businessId) listings = listings.filter(l => l.businessId === filters.businessId || l.hotelId === filters.businessId);
    return listings;
  }

  static createListing(listing: WasteListing) {
    // Normalize data before storing
    listing.businessId = listing.businessId || listing.hotelId || 'unknown';
    listing.businessName = listing.businessName || listing.hotelName || 'Unknown';
    return create('listings', listing);
  }

  static updateListing(id: string, updates: Partial<WasteListing>) {
    return update('listings', id, updates);
  }

  static deleteListing(id: string) {
    return remove('listings', id);
  }

  // Collections
  static getCollections(filters?: { status?: string; driverId?: string; recyclerName?: string }) {
    let collections = getAll<Collection>('collections');
    if (filters?.status) collections = collections.filter(c => c.status === filters.status);
    if (filters?.driverId) collections = collections.filter(c => c.driverId === filters.driverId);
    if (filters?.recyclerName) collections = collections.filter(c => c.recyclerName === filters.recyclerName);
    return collections;
  }

  static createCollection(collection: Collection) {
    collection.businessName = collection.businessName || collection.hotelName || 'Unknown';
    return create('collections', collection);
  }

  static updateCollection(id: string, updates: Partial<Collection>) {
    return update('collections', id, updates);
  }

  // Users
  static getUsers(role?: string) {
    let users = getAll<PlatformUser>('users');
    if (role) users = users.filter(u => u.role === role);
    return users;
  }

  static getUser(id: string) {
    const users = getAll<PlatformUser>('users');
    return users.find(u => u.id === id);
  }

  // Transactions
  static getTransactions(filters?: { userId?: string; status?: string }) {
    let transactions = getAll<Transaction>('transactions');
    if (filters?.userId) {
      transactions = transactions.filter(t => t.from === filters.userId || t.to === filters.userId);
    }
    if (filters?.status) transactions = transactions.filter(t => t.status === filters.status);
    return transactions;
  }

  // Messages
  static getMessages(userId: string) {
    const messages = getAll<Message>('messages');
    return messages.filter(m => m.from === userId || m.to === userId);
  }

  // Statistics
  static getStatistics() {
    const listings = getAll<WasteListing>('listings');
    const collections = getAll<Collection>('collections');
    const transactions = getAll<Transaction>('transactions');
    const users = getAll<PlatformUser>('users');

    return {
      totalListings: listings.length,
      activeListings: listings.filter(l => l.status === 'open').length,
      totalVolume: listings.reduce((sum, l) => sum + l.volume, 0),
      totalCollections: collections.length,
      completedCollections: collections.filter(c => c.status === 'completed').length,
      totalRevenue: transactions.filter(t => t.status === 'completed').reduce((sum, t) => sum + t.amount, 0),
      totalUsers: users.length,
      activeUsers: users.filter(u => u.status === 'active').length,
    };
  }

  // Dashboard metrics by role
  static getBusinessMetrics(businessId: string) {
    const listings = this.getListings({ businessId });
    const collections = getAll<Collection>('collections').filter(c => 
      c.businessName === businessId || listings.some(l => l.id === c.listingId)
    );
    const transactions = getAll<Transaction>('transactions').filter(t => t.from === businessId);

    return {
      monthlyWaste: listings.reduce((sum, l) => sum + l.volume, 0),
      activeListings: listings.filter(l => l.status === 'open').length,
      revenue: transactions.filter(t => t.status === 'completed').reduce((sum, t) => sum + t.amount - t.fee, 0),
      collections: collections.length,
      averageQuality: listings.length ? 
        (listings.filter(l => l.quality === 'A').length / listings.length * 100).toFixed(0) : '0',
    };
  }

  static getRecyclerMetrics(recyclerName: string) {
    const collections = getAll<Collection>('collections').filter(c => c.recyclerName === recyclerName);
    const transactions = getAll<Transaction>('transactions').filter(t => t.to === recyclerName);

    return {
      totalCollections: collections.length,
      completedCollections: collections.filter(c => c.status === 'completed').length,
      revenue: transactions.filter(t => t.status === 'completed').reduce((sum, t) => sum + t.amount - t.fee, 0),
      totalVolume: collections.reduce((sum, c) => sum + c.volume, 0),
      averageRating: collections.filter(c => c.rating).length ?
        (collections.filter(c => c.rating).reduce((sum, c) => sum + (c.rating || 0), 0) / 
         collections.filter(c => c.rating).length).toFixed(1) : '0',
    };
  }

  static getDriverMetrics(driverId: string) {
    const routes = getAll<any>('driverRoutes').filter(r => r.driverId === driverId);
    const collections = getAll<Collection>('collections').filter(c => c.driverId === driverId);

    return {
      completedRoutes: routes.filter(r => r.status === 'completed').length,
      totalDistance: routes.reduce((sum, r) => sum + r.totalDistance, 0),
      earnings: collections.filter(c => c.status === 'completed').reduce((sum, c) => sum + c.earnings, 0),
      totalCollections: collections.length,
      averageRating: collections.filter(c => c.rating).length ?
        (collections.filter(c => c.rating).reduce((sum, c) => sum + (c.rating || 0), 0) / 
         collections.filter(c => c.rating).length).toFixed(1) : '0',
    };
  }
}

// Make DataManager globally available
export { DataManager as default };
