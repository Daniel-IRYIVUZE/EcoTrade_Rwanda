import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import { replayQueue } from './utils/offlineQueue.ts'
import { API_BASE_URL } from './services/api.ts'
import { syncFromAPI } from './utils/apiSync.ts'

// Register service worker for offline-first PWA support.
// Skip registration in development — an active SW caches Vite's module
// bundles and serves them on every reload, which breaks HMR, the WebSocket
// connection, and causes duplicate-React "Invalid hook call" errors because
// the SW serves a stale bundle that contains a second React instance.
if (import.meta.env.PROD && 'serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').catch(err => {
      console.warn('Service worker registration failed:', err);
    });

    // Handle SW-triggered sync messages (e.g. when tab was in background)
    navigator.serviceWorker.addEventListener('message', async (event) => {
      if (event.data?.type === 'SYNC_QUEUE' && navigator.onLine) {
        const storedUser = localStorage.getItem('ecotrade_user');
        if (!storedUser) return;
        try {
          const { synced } = await replayQueue(API_BASE_URL);
          if (synced > 0) {
            const u = JSON.parse(storedUser);
            syncFromAPI(u.role).catch(() => {});
          }
        } catch { /* ignore */ }
      }
    });
  });
} else if (!import.meta.env.PROD && 'serviceWorker' in navigator) {
  // In development, unregister any previously installed SW so it cannot
  // intercept Vite's module requests.
  navigator.serviceWorker.getRegistrations().then(registrations => {
    for (const reg of registrations) reg.unregister();
  });
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
