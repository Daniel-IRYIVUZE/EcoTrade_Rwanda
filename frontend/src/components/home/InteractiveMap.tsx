// components/home/InteractiveMap.tsx — Real Leaflet map showing Kigali HORECA activity
import { useEffect, useRef, useState } from 'react';
import { Maximize2, ArrowRight, MapPin } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import 'leaflet/dist/leaflet.css';
import { listingsAPI, recyclersAPI, type WasteListing, type RecyclerProfile } from '../../services/api';

const InteractiveMap = () => {
  const mapRef = useRef<HTMLDivElement>(null);
  const leafletMapRef = useRef<any>(null);
  const navigate = useNavigate();

  const [listings, setListings] = useState<WasteListing[]>([]);
  const [recyclers, setRecyclers] = useState<RecyclerProfile[]>([]);

  useEffect(() => {
    listingsAPI.list({ limit: 30 }).then(setListings).catch(() => {});
    recyclersAPI.list({ limit: 20 }).then(setRecyclers).catch(() => {});
  }, []);

  useEffect(() => {
    const container = mapRef.current;
    if (!container) return; // Guard: only proceed if ref is attached

    // Re-init map when data changes (first load or data arrives)
    if (leafletMapRef.current) {
      leafletMapRef.current.remove();
      leafletMapRef.current = null;
    }

    let map: any;

    const initMap = async () => {
      try {
        const L = await import('leaflet');

        // Kigali center
        map = L.map(container, {
          center: [-1.9441, 30.0619],
          zoom: 13,
          zoomControl: false,
          attributionControl: false,
        });

        leafletMapRef.current = map;

        // OpenStreetMap tiles
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          attribution: '© OpenStreetMap contributors',
          maxZoom: 19,
        }).addTo(map);

        L.control.attribution({ prefix: false, position: 'bottomright' })
          .addAttribution('© <a href="https://osm.org/copyright">OSM</a>')
          .addTo(map);

        L.control.zoom({ position: 'topright' }).addTo(map);

        // ── Helper: colored circle marker ──────────────────────────────────
        const circleIcon = (color: string, size = 14) =>
          L.divIcon({
            className: '',
            html: `<div style="
              width:${size}px;height:${size}px;
              background:${color};border-radius:50%;
              border:2px solid white;
              box-shadow:0 2px 6px rgba(0,0,0,0.35);
            "></div>`,
            iconSize: [size, size],
            iconAnchor: [size / 2, size / 2],
            popupAnchor: [0, -(size / 2 + 4)],
          });

        // ── Listing markers (waste generators) ────────────────────────────
        listings.forEach(l => {
          const lat = l.latitude;
          const lng = l.longitude;
          if (!lat || !lng) return;
          const wasteInfo = `${l.volume} ${l.unit} ${l.waste_type} available`;
          L.marker([lat, lng], { icon: circleIcon('#0891b2', 16) })
            .addTo(map)
            .bindPopup(`
              <div style="font-family:sans-serif;min-width:160px">
                <strong style="color:#0891b2">${l.hotel_name}</strong><br/>
                <span style="font-size:12px;color:#555">${wasteInfo}</span>
              </div>
            `);
        });

        // ── Recycler markers ───────────────────────────────────────────────
        recyclers.forEach(r => {
          const lat = r.latitude;
          const lng = r.longitude;
          if (!lat || !lng) return;
          const types = Array.isArray(r.waste_types_handled)
            ? r.waste_types_handled.join(', ')
            : (r.waste_types_handled ?? 'All types');
          L.marker([lat, lng], { icon: circleIcon('#2563eb', 18) })
            .addTo(map)
            .bindPopup(`
              <div style="font-family:sans-serif;min-width:160px">
                <strong style="color:#2563eb">${r.company_name}</strong><br/>
                <span style="font-size:12px;color:#555">Accepting: ${types}</span>
              </div>
            `);
        });

      } catch (err) {
        console.error('Leaflet failed to load:', err);
      }
    };

    initMap();

    return () => {
      if (leafletMapRef.current) {
        leafletMapRef.current.remove();
        leafletMapRef.current = null;
      }
    };
  }, [listings, recyclers]);

  const activeListings = listings.filter(l => l.status === 'open').length;
  const recyclerCount = recyclers.length;

  return (
    <section className="py-20 bg-gray-50 dark:bg-gray-900 transition-colors duration-300">
      {/* Pulse ring animation for driver markers */}
      <style>{`
        @keyframes pulse-ring {
          0%   { transform: scale(1);   opacity: 0.5; }
          100% { transform: scale(2.4); opacity: 0;   }
        }
      `}</style>

      <div className="max-w-11/12 mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="flex flex-col lg:flex-row items-center justify-between mb-12">
          <div>
            <h2 className="text-4xl font-bold text-gray-900 dark:text-white mb-4">
              Live <span className="text-cyan-600">Marketplace Map</span>
            </h2>
            <p className="text-xl text-gray-600 dark:text-gray-400 max-w-2xl">
              Real-time waste listings and collection activity across Kigali
            </p>
          </div>
          <button
            onClick={() => navigate('/marketplace')}
            className="mt-4 lg:mt-0 bg-cyan-600 text-white px-6 py-3 rounded-xl font-semibold hover:bg-cyan-700 transition-colors flex items-center"
          >
            <Maximize2 className="w-5 h-5 mr-2" />
            View Full Map
          </button>
        </div>

        {/* Map Container */}
        <div className="relative bg-white dark:bg-gray-800 rounded-2xl shadow-xl overflow-hidden border border-gray-200 dark:border-gray-700">
          <div ref={mapRef} className="h-[500px] w-full z-0" />

          {/* Legend overlay */}
          <div className="absolute bottom-10 left-4 bg-white/95 dark:bg-gray-800/95 backdrop-blur-sm rounded-xl p-4 shadow-lg z-[400]">
            <h4 className="font-semibold text-gray-900 dark:text-white mb-3 text-sm">Map Legend</h4>
            <div className="space-y-2">
              <div className="flex items-center gap-2">
                <div className="w-3 h-3 rounded-full bg-cyan-600 ring-2 ring-white shadow-sm" />
                <span className="text-xs text-gray-700 dark:text-gray-300">Hotels (waste generators)</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-3 h-3 rounded-full bg-blue-600 ring-2 ring-white shadow-sm" />
                <span className="text-xs text-gray-700 dark:text-gray-300">Recycling facilities</span>
              </div>
            </div>
          </div>

          {/* Location badge */}
          <div className="absolute top-4 left-4 bg-white/95 dark:bg-gray-800/95 backdrop-blur-sm rounded-lg px-4 py-2 shadow-lg z-[400]">
            <p className="text-sm font-medium text-gray-900 dark:text-white flex items-center gap-1"><MapPin size={13} className="text-cyan-500"/> Kigali, Rwanda</p>
            <p className="text-xs text-gray-500 dark:text-gray-400">Nyarugenge · Gasabo · Kicukiro</p>
          </div>
        </div>

        {/* Footer Stats */}
        <div className="mt-4 bg-white dark:bg-gray-800 rounded-xl px-6 py-4 border border-gray-200 dark:border-gray-700">
          <div className="flex flex-wrap items-center justify-between gap-3 text-sm text-gray-600 dark:text-gray-400">
            <div className="flex flex-wrap items-center gap-4">
              <span className="flex items-center gap-1.5">
                <span className="w-2.5 h-2.5 bg-cyan-500 rounded-full" />
                {activeListings} Active Listings
              </span>
              <span className="flex items-center gap-1.5">
                <span className="w-2.5 h-2.5 bg-blue-500 rounded-full" />
                {recyclerCount} Recyclers Online
              </span>
            </div>
            <span className="text-cyan-600 font-medium text-xs">● Updated live</span>
          </div>
        </div>

        {/* CTA */}
        <div className="text-center mt-8">
          <button
            onClick={() => navigate('/marketplace')}
            className="text-cyan-600 font-semibold hover:text-cyan-700 dark:text-cyan-400 inline-flex items-center group"
          >
            Explore full marketplace
            <ArrowRight className="ml-2 w-4 h-4 group-hover:translate-x-1 transition-transform" />
          </button>
        </div>
      </div>
    </section>
  );
};

export default InteractiveMap;
