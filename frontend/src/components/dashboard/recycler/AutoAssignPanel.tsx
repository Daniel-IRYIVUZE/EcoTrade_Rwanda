/**
 * AutoAssignPanel.tsx
 *
 * Allows a recycler to preview and apply the nearest-driver auto-assignment
 * algorithm for all unassigned, geo-coded waste collections.
 *
 * Flow
 * ----
 * 1. User clicks "Preview assignments" (apply=false) → shows a table of proposed
 *    location → driver matches with geodesic distances.
 * 2. User optionally toggles "Balance workload" to apply the load-balancing mode.
 * 3. User clicks "Apply assignments" (apply=true) → persists driver assignments
 *    to the DB and triggers a data-change event so sibling components refresh.
 */
import { useState } from 'react';
import {
  Zap, MapPin, Truck, RefreshCw, CheckCircle, AlertCircle, ToggleLeft, ToggleRight,
  Navigation, Users, Loader,
} from 'lucide-react';
import { collectionsAPI } from '../../../services/api';
import type { AutoAssignResult } from '../../../services/api';

// ── Helpers ───────────────────────────────────────────────────────────────────

function formatDistance(m: number): string {
  if (m >= 1000) return `${(m / 1000).toFixed(1)} km`;
  return `${Math.round(m)} m`;
}

const WORKLOAD_COLORS = [
  'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300',
  'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-300',
  'bg-orange-100 dark:bg-orange-900/30 text-orange-700 dark:text-orange-300',
  'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-300',
];
function workloadColor(n: number) {
  return WORKLOAD_COLORS[Math.min(n - 1, WORKLOAD_COLORS.length - 1)];
}

// ── Assignment row ─────────────────────────────────────────────────────────────

function AssignmentRow({ result, index }: { result: AutoAssignResult; index: number }) {
  const drv = result.assigned_driver;
  const loc = result.location;

  return (
    <tr className="border-b border-gray-100 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700/30 transition-colors">
      {/* # */}
      <td className="py-3 pl-4 pr-2 text-xs text-gray-400 dark:text-gray-500 tabular-nums">
        {index + 1}
      </td>

      {/* Waste location */}
      <td className="py-3 px-3">
        <div className="flex items-start gap-2">
          <MapPin size={14} className="text-emerald-500 mt-0.5 shrink-0" />
          <div>
            <p className="text-sm font-medium text-gray-900 dark:text-white leading-tight">
              {loc.label}
            </p>
            <p className="text-xs text-gray-400 dark:text-gray-500 font-mono mt-0.5">
              {loc.lat.toFixed(5)}, {loc.lng.toFixed(5)}
            </p>
            {loc.waste_type && (
              <span className="mt-1 inline-block text-[10px] px-1.5 py-0.5 rounded bg-cyan-50 dark:bg-cyan-900/30 text-cyan-700 dark:text-cyan-300 font-medium">
                {loc.waste_type} {loc.volume != null ? `· ${loc.volume} kg` : ''}
              </span>
            )}
          </div>
        </div>
      </td>

      {/* Collector */}
      <td className="py-3 px-3">
        <div className="flex items-start gap-2">
          <Truck size={14} className="text-blue-500 mt-0.5 shrink-0" />
          <div>
            <p className="text-sm font-medium text-gray-900 dark:text-white leading-tight">
              {drv.name}
            </p>
            {drv.vehicle_type && (
              <p className="text-xs text-gray-500 dark:text-gray-400">
                {drv.vehicle_type}
                {drv.plate_number ? ` · ${drv.plate_number}` : ''}
              </p>
            )}
            <p className="text-xs text-gray-400 dark:text-gray-500 font-mono mt-0.5">
              {drv.lat.toFixed(5)}, {drv.lng.toFixed(5)}
            </p>
          </div>
        </div>
      </td>

      {/* Distance */}
      <td className="py-3 px-3 text-center">
        <span className="inline-flex items-center gap-1 text-sm font-semibold text-gray-700 dark:text-gray-200">
          <Navigation size={12} className="text-indigo-400" />
          {formatDistance(result.distance_m)}
        </span>
      </td>

      {/* Workload */}
      <td className="py-3 pr-4 text-center">
        <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${workloadColor(result.workload)}`}>
          {result.workload} {result.workload === 1 ? 'stop' : 'stops'}
        </span>
      </td>
    </tr>
  );
}

// ── Summary bar ────────────────────────────────────────────────────────────────

function SummaryBar({ results }: { results: AutoAssignResult[] }) {
  const totalLocations = results.length;
  const uniqueCollectors = new Set(results.map(r => r.assigned_driver.id)).size;
  const avgDist =
    results.length > 0
      ? results.reduce((s, r) => s + r.distance_m, 0) / results.length
      : 0;
  const maxWorkload = results.reduce((m, r) => Math.max(m, r.workload), 0);

  return (
    <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-4">
      {[
        { label: 'Locations', value: totalLocations, icon: <MapPin size={14} /> },
        { label: 'Collectors', value: uniqueCollectors, icon: <Users size={14} /> },
        { label: 'Avg distance', value: formatDistance(avgDist), icon: <Navigation size={14} /> },
        { label: 'Max workload', value: `${maxWorkload} stops`, icon: <Truck size={14} /> },
      ].map(({ label, value, icon }) => (
        <div
          key={label}
          className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl p-3 flex items-center gap-2"
        >
          <span className="text-cyan-500">{icon}</span>
          <div>
            <p className="text-[10px] text-gray-400 dark:text-gray-500 uppercase tracking-wide">
              {label}
            </p>
            <p className="text-sm font-bold text-gray-900 dark:text-white">{value}</p>
          </div>
        </div>
      ))}
    </div>
  );
}

// ── Main panel ─────────────────────────────────────────────────────────────────

type PanelState = 'idle' | 'loading' | 'previewed' | 'applied' | 'error';

export default function AutoAssignPanel({ onApplied }: { onApplied?: () => void }) {
  const [state, setState] = useState<PanelState>('idle');
  const [isLoading, setIsLoading] = useState(false);
  const [results, setResults] = useState<AutoAssignResult[]>([]);
  const [errorMsg, setErrorMsg] = useState('');
  const [balanceLoad, setBalanceLoad] = useState(false);

  async function preview() {
    setState('loading');
    setIsLoading(true);
    setErrorMsg('');
    try {
      const data = await collectionsAPI.autoAssign(balanceLoad, false);
      setResults(data);
      setState('previewed');
    } catch (err: unknown) {
      setErrorMsg(err instanceof Error ? err.message : 'Failed to compute assignments.');
      setState('error');
    } finally {
      setIsLoading(false);
    }
  }

  async function applyAssignments() {
    setIsLoading(true);
    setState('loading');
    try {
      const data = await collectionsAPI.autoAssign(balanceLoad, true);
      setResults(data);
      setState('applied');
      window.dispatchEvent(new Event('ecotrade_data_change'));
      onApplied?.();
    } catch (err: unknown) {
      setErrorMsg(err instanceof Error ? err.message : 'Failed to apply assignments.');
      setState('error');
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div className="bg-white dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700 shadow-sm overflow-hidden">
      {/* ── Header ── */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 px-5 py-4 border-b border-gray-100 dark:border-gray-700">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-gradient-to-br from-cyan-500 to-teal-600 rounded-xl text-white">
            <Zap size={18} />
          </div>
          <div>
            <h3 className="text-base font-bold text-gray-900 dark:text-white">
              Auto-Assign Drivers
            </h3>
            <p className="text-xs text-gray-400 dark:text-gray-500">
              Geodesic nearest-collector matching · Haversine formula
            </p>
          </div>
        </div>

        {/* Load-balance toggle */}
        <button
          onClick={() => setBalanceLoad(v => !v)}
          className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-300 hover:text-cyan-600 dark:hover:text-cyan-400 transition-colors"
        >
          {balanceLoad
            ? <ToggleRight size={20} className="text-cyan-500" />
            : <ToggleLeft size={20} className="text-gray-400" />}
          Balance workload
        </button>
      </div>

      {/* ── Body ── */}
      <div className="p-5">
        {/* Algorithm description */}
        {state === 'idle' && (
          <div className="rounded-xl bg-cyan-50 dark:bg-cyan-900/20 border border-cyan-100 dark:border-cyan-800 p-4 mb-4 text-sm text-cyan-800 dark:text-cyan-200 space-y-1">
            <p className="font-semibold">How it works</p>
            <ul className="list-disc list-inside space-y-0.5 text-xs">
              <li>Calculates the Haversine (geodesic) distance between each waste location and every available driver.</li>
              <li>Assigns the nearest driver to each unassigned, scheduled collection.</li>
              <li>One driver can handle multiple locations (workload shown per driver).</li>
              {balanceLoad && (
                <li className="font-medium text-cyan-700 dark:text-cyan-300">
                  Balance mode active: adds a 500 m penalty per extra stop to spread load evenly.
                </li>
              )}
            </ul>
          </div>
        )}

        {/* Error */}
        {state === 'error' && (
          <div className="flex items-center gap-3 rounded-xl bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 px-4 py-3 mb-4">
            <AlertCircle size={18} className="text-red-500 shrink-0" />
            <p className="text-sm text-red-700 dark:text-red-300">{errorMsg}</p>
          </div>
        )}

        {/* Applied success banner */}
        {state === 'applied' && (
          <div className="flex items-center gap-3 rounded-xl bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 px-4 py-3 mb-4">
            <CheckCircle size={18} className="text-green-500 shrink-0" />
            <p className="text-sm text-green-700 dark:text-green-300 font-medium">
              {results.length} assignment{results.length !== 1 ? 's' : ''} applied successfully.
            </p>
          </div>
        )}

        {/* Results */}
        {(state === 'previewed' || state === 'applied') && results.length > 0 && (
          <>
            <SummaryBar results={results} />
            <div className="overflow-x-auto rounded-xl border border-gray-200 dark:border-gray-700">
              <table className="w-full text-left">
                <thead className="bg-gray-50 dark:bg-gray-700/50 text-xs text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  <tr>
                    <th className="py-2.5 pl-4 pr-2 w-8">#</th>
                    <th className="py-2.5 px-3">Waste Location</th>
                    <th className="py-2.5 px-3">Assigned Collector</th>
                    <th className="py-2.5 px-3 text-center">Distance</th>
                    <th className="py-2.5 pr-4 text-center">Workload</th>
                  </tr>
                </thead>
                <tbody>
                  {results.map((r, i) => (
                    <AssignmentRow key={r.collection_id} result={r} index={i} />
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}

        {/* Empty state after preview */}
        {(state === 'previewed' || state === 'applied') && results.length === 0 && (
          <div className="text-center py-10 text-gray-400 dark:text-gray-500">
            <CheckCircle size={36} className="mx-auto mb-2 text-green-400" />
            <p className="font-medium">All collections are already assigned.</p>
            <p className="text-xs mt-1">No unassigned, geo-coded collections found.</p>
          </div>
        )}

        {/* ── Action buttons ── */}
        <div className="flex flex-wrap gap-3 mt-5">
          <button
            onClick={preview}
            disabled={isLoading}
            className="flex items-center gap-2 px-4 py-2.5 rounded-xl border border-gray-300 dark:border-gray-600 text-sm font-medium text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {isLoading
              ? <Loader size={15} className="animate-spin" />
              : <RefreshCw size={15} />}
            {state === 'previewed' || state === 'applied'
              ? 'Re-compute preview'
              : 'Preview assignments'}
          </button>

          {state === 'previewed' && results.length > 0 && (
            <button
              onClick={applyAssignments}
              disabled={isLoading}
              className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-cyan-600 to-teal-600 text-white text-sm font-medium hover:from-cyan-700 hover:to-teal-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-sm"
            >
              <Zap size={15} />
              Apply {results.length} assignment{results.length !== 1 ? 's' : ''}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
