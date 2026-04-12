{{flutter_js}}
{{flutter_build_config}}

(async function main() {
  // Register SW and wait for it to control this page BEFORE loading Flutter.
  // This ensures all Flutter fetches (canvaskit, fonts, assets) go through
  // the SW and get cached for offline use.
  if ('serviceWorker' in navigator) {
    try {
      await navigator.serviceWorker.register('/sw.js');
      if (!navigator.serviceWorker.controller) {
        await new Promise((resolve) => {
          navigator.serviceWorker.addEventListener('controllerchange', resolve, { once: true });
        });
      }
    } catch (err) {
      console.warn('SW registration failed:', err);
    }
    // Prevent browser from evicting the cache
    if (navigator.storage && navigator.storage.persist) {
      navigator.storage.persist();
    }
  }

  _flutter.loader.load({
    config: {
      canvasKitBaseUrl: "canvaskit/"
    }
  });
})();
