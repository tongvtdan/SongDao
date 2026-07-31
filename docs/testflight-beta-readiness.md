# Sống Đạo TestFlight Beta Readiness

Status: ready for internal TestFlight after signing and device QA.

## App Store Connect Metadata

Use this as the first TestFlight/App Store Connect pass. Keep claims narrow until beta retention is proven.

| Field | Value |
|---|---|
| App name | Sống Đạo |
| Subtitle | Một việc nhỏ để sống đức tin hôm nay |
| Category | Lifestyle |
| Bundle ID | `com.dantino.songdao` |
| Version | `0.1.0` |
| Build | `2` |
| Privacy policy URL | `https://songdao.dantino.com/privacy` |
| Support URL | `https://songdao.dantino.com/support` |

Vietnamese beta description:

> Sống Đạo giúp bạn sống đức tin mỗi ngày qua một việc nhỏ rõ ràng, bối cảnh phụng vụ hôm nay, lời nhắc nhẹ, widget màn hình chính, và lịch sử thực hành riêng tư lưu trên thiết bị.
>
> Bản beta tập trung vào vòng lặp cốt lõi: mở Today, nhận một việc sống đạo, hoàn thành nhẹ nhàng, ghi chú riêng nếu muốn, và quay lại qua widget hoặc thông báo.

English reviewer note:

> Sống Đạo is an iOS-first, local-first Catholic daily practice beta for Vietnamese users. The app does not require an account, payment, location, analytics, or server access. Reading content is citation-only; no copyrighted full Bible or lectionary text is included. Please test Today, completion, private note, Settings reminder permission, Church parish selection, and the Today widget.

## Privacy Nutrition Answers

- Account data: not collected.
- Contact info: not collected.
- Location: not collected in the current beta flow; future nearby church search must be opt-in.
- User content: practice notes remain on device and are not transmitted.
- Usage data: not collected unless a future opt-in analytics control is added.
- Diagnostics: Apple/TestFlight crash and feedback behavior only.
- Tracking: no.

In-app privacy promise:

> Lịch sử thực hành của bạn được lưu trên thiết bị này, trừ khi bạn chọn sao lưu.

## Device QA Checklist

- Cold launch imports bundled content packs and opens Today without a fallback action.
- Today works for `2026-05-16` and later with calendar context, reading references, action, and reflection when available.
- Completing the daily action persists after force quit and relaunch.
- Reflection note persists after force quit and relaunch.
- Church tab can select a parish and keeps it selected after relaunch.
- Settings can enable and disable daily reminders; denied notification permission shows the existing guidance.
- Notification payload opens Today.
- Widget renders real Vietnamese snapshot in small and medium sizes after opening the app.
- Widget falls back calmly if App Group provisioning is missing.
- Offline launch still shows Today, completion history, notes, and cached parish data.

## Signing Checklist

- Register App Group `group.com.dantino.songdao` in Apple Developer.
- Enable App Groups for `com.dantino.songdao` and `com.dantino.songdao.TodayWidget`.
- Confirm Runner uses `Runner/Runner.entitlements`.
- Confirm TodayWidget uses `TodayWidget/TodayWidget.entitlements`.
- Regenerate provisioning profiles after enabling App Groups.

## Launch Decision

Ship internal TestFlight first. Move to external TestFlight only after widget/device QA passes on a real iPhone or simulator with App Group provisioning.
