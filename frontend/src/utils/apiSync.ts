// utils/apiSync.ts — Syncs real backend data into localStorage dataStore
// Called on login when the backend is online. Falls back gracefully if offline.
import { listingsAPI, collectionsAPI, transactionsAPI, usersAPI, bidsAPI, inventoryAPI } from '../services/api';
import { saveAll } from './dataStore';
import type {
  WasteListing as DSListing,
  Collection as DSCollection,
  Transaction as DSTx,
  PlatformUser as DSUser,
} from './dataStore';

function toRole(r: string): DSUser['role'] {
  if (r === 'hotel') return 'business';
  return r as DSUser['role'];
}

/** Fetch data from the API and write it into the localStorage dataStore. */
export async function syncFromAPI(userRole: string): Promise<void> {
  try {
    // ── Listings — business users only see their own listings ────────────────
    const apiListings = userRole === 'business'
      ? await listingsAPI.mine()
      : await listingsAPI.list({ limit: 100 });
    const dsListings: DSListing[] = apiListings.map(l => ({
      id: String(l.id),
      businessId: String(l.hotel_id),
      businessName: l.hotel_name,
      hotelName: l.hotel_name,
      hotelId: String(l.hotel_id),
      wasteType: (l.waste_type || 'Mixed') as DSListing['wasteType'],
      volume: l.volume,
      unit: l.unit as 'kg' | 'liters',
      quality: (l.quality || 'B') as DSListing['quality'],
      minBid: l.min_bid,
      reservePrice: l.reserve_price || 0,
      auctionDuration: l.auction_duration || '24h',
      status: l.status as DSListing['status'],
      location: l.location || '',
      assignedRecycler: l.assigned_recycler,
      assignedDriver: l.assigned_driver,
      collectionDate: l.collection_date,
      collectionTime: l.collection_time,
      actualWeight: l.actual_weight,
      createdAt: l.created_at,
      expiresAt: l.expires_at || new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
      contactPerson: l.contact_person || '',
      specialInstructions: l.special_instructions || '',
      autoAcceptAbove: 0,
      // Map image URLs from the API response:
      // `images` is an array of { id, url, is_primary } objects (preferred).
      // `image_url` is a single primary URL (fallback).
      photos: (() => {
        if (l.images && l.images.length > 0) {
          return l.images.map((img) => img.url).filter(Boolean);
        }
        if (l.image_url) return [l.image_url];
        return [];
      })(),
      bids: [],
    }));
    saveAll('listings', dsListings);
  } catch { /* offline */ }

  try {
    // ── Collections ──────────────────────────────────────────────────────────
    const apiCols = await collectionsAPI.list({ limit: 100 });
    const dsCols: DSCollection[] = apiCols.map(c => ({
      id: String(c.id),
      listingId: c.listing_id ? String(c.listing_id) : '',
      businessName: c.hotel_name || '',
      hotelName: c.hotel_name,
      recyclerName: c.recycler_name || '',
      driverName: c.driver_name || '',
      driverId: c.driver_id ? String(c.driver_id) : '',
      wasteType: c.waste_type || '',
      volume: c.volume || 0,
      status: c.status as DSCollection['status'],
      scheduledDate: c.scheduled_date || '',
      scheduledTime: c.scheduled_time || '00:00',
      completedAt: c.completed_at,
      actualWeight: c.actual_weight,
      rating: c.rating,
      notes: c.notes || '',
      location: c.location || '',
      earnings: c.earnings || 0,
      proofPhotos: [],
      createdAt: c.created_at,
    }));
    saveAll('collections', dsCols);
  } catch { /* offline */ }

  try {
    // ── Transactions — use /mine for non-admin roles ─────────────────────────
    const apiTxs = userRole === 'admin'
      ? await transactionsAPI.list({ limit: 100 })
      : await transactionsAPI.mine({ limit: 100 });
    const dsTxs: DSTx[] = apiTxs.map(t => ({
      id: String(t.id),
      listingId: t.listing_id ? String(t.listing_id) : '',
      from: t.from_user || '',
      to: t.to_user || '',
      wasteType: t.waste_type || '',
      volume: t.volume || 0,
      amount: t.gross_amount || 0,
      fee: t.fee || 0,
      status: t.status as DSTx['status'],
      date: t.created_at,
      receipt: t.receipt,
    }));
    saveAll('transactions', dsTxs);
  } catch { /* offline */ }

  // Users endpoint is admin-only
  if (userRole === 'admin') {
    try {
      const apiUsers = await usersAPI.list({ limit: 200 });
      const dsUsers: DSUser[] = apiUsers.map(u => ({
        id: String(u.id),
        name: u.full_name,
        email: u.email,
        phone: u.phone || '',
        role: toRole(u.role),
        status: u.status as DSUser['status'],
        verified: u.is_verified,
        createdAt: u.created_at,
        location: '',
        joinDate: u.created_at,
        lastActive: new Date().toISOString(),
        avatar: '/images/default-avatar.svg',
        businessName: u.hotel_profile?.business_name,
        companyName: u.recycler_profile?.company_name,
      }));
      saveAll('users', dsUsers);
    } catch { /* offline */ }
  }


  // Recycler-specific: sync own bids and inventory
  if (userRole === 'recycler') {
    try {
      const apiBids = await bidsAPI.mine({ limit: 100 });
      saveAll('recycler_bids', apiBids);
    } catch { /* offline */ }

    try {
      const apiInv = await inventoryAPI.mine();
      saveAll('recycler_inventory', apiInv);
    } catch { /* offline */ }
  }

  window.dispatchEvent(new Event('ecotrade_data_change'));
}
