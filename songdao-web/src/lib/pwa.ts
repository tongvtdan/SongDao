"use client";

export async function registerServiceWorker(): Promise<void> {
  if (!("serviceWorker" in navigator)) return;

  try {
    await navigator.serviceWorker.register("/sw.js");
  } catch {
    // PWA support is additive; never block the daily practice flow.
  }
}
