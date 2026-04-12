'use strict';

const CACHE_NAME = 'gutcheck-v2';

// All files needed to boot the app offline.
// canvaskit/chromium/ variant is used on Chrome/Edge (most users).
const PRECACHE = [
  '/',
  '/index.html',
  '/flutter_bootstrap.js',
  '/flutter.js',
  '/main.dart.js',
  '/manifest.json',
  '/favicon.svg',
  '/version.json',
  '/assets/AssetManifest.bin',
  '/assets/AssetManifest.bin.json',
  '/assets/FontManifest.json',
  '/assets/fonts/MaterialIcons-Regular.otf',
  '/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
  '/assets/shaders/ink_sparkle.frag',
  '/assets/shaders/stretch_effect.frag',
  '/assets/assets/seed/ingredients.json',
  '/canvaskit/canvaskit.js',
  '/canvaskit/canvaskit.wasm',
  '/canvaskit/chromium/canvaskit.js',
  '/canvaskit/chromium/canvaskit.wasm',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) =>
      Promise.allSettled(
        PRECACHE.map((url) =>
          fetch(url).then((res) => {
            if (res.ok) return cache.put(url, res);
          }).catch(() => {})
        )
      )
    )
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  // Delete old cache versions
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  event.respondWith(
    caches.open(CACHE_NAME).then((cache) =>
      cache.match(request).then((cached) => {
        if (cached) {
          // Serve from cache immediately (offline-first).
          // Revalidate in background only if network is available.
          fetch(request).then((res) => {
            if (res.ok) cache.put(request, res);
          }).catch(() => {});
          return cached;
        }
        // Not in cache — fetch from network, cache for next time
        return fetch(request).then((res) => {
          if (res.ok) cache.put(request, res.clone());
          return res;
        });
      })
    )
  );
});
