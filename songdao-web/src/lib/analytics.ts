"use client";

export type AnalyticsEventName =
  | "app_opened"
  | "action_completed"
  | "note_saved"
  | "pwa_install_prompt_shown"
  | "pwa_install_prompt_accepted"
  | "export_used"
  | "import_used";

interface AnalyticsPayload {
  event: AnalyticsEventName;
  app: "songdao-web";
  version: "0.1.0";
  occurredAt: string;
}

export function trackEvent(event: AnalyticsEventName): void {
  const endpoint = process.env.NEXT_PUBLIC_SONGDAO_ANALYTICS_URL;
  if (!endpoint || typeof navigator === "undefined") return;

  const payload: AnalyticsPayload = {
    event,
    app: "songdao-web",
    version: "0.1.0",
    occurredAt: new Date().toISOString(),
  };
  const body = JSON.stringify(payload);

  if (navigator.sendBeacon) {
    navigator.sendBeacon(endpoint, new Blob([body], { type: "application/json" }));
    return;
  }

  fetch(endpoint, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body,
    keepalive: true,
  }).catch(() => undefined);
}
