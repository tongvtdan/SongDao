# Today And Widget Wireframes

Status: low-fidelity beta wireframes locked on 2026-04-27  
Linear: DAN-117

## Insight

The first screen and widget should make the answer obvious: what is today, and what one action should I do? Everything else supports that decision.

## Decision

Use a single-column Today surface with the daily action as the visual center. Use WidgetKit snapshots, not live network calls.

## Today Screen Order

```text
+------------------------------------+
|  Mon, 27 Apr                       |
|  Thứ Hai tuần II Phục Sinh [white] |
|  Màu phụng vụ: Trắng               |
+------------------------------------+

+------------------------------------+
|  Một việc nhỏ hôm nay              |
|                                    |
|  Viết một câu về Tin Mừng hôm nay  |
|                                    |
|  Đọc câu Tin Mừng được gợi ý và    |
|  viết lại một điều bạn muốn sống.  |
|                                    |
|  5 phút                            |
|                                    |
|  [Tôi đã làm việc này]             |
+------------------------------------+

+------------------------------------+
|  Bài đọc hôm nay                   |
|  Bài đọc I: Cv 14,5-18             |
|  Tin Mừng: Ga 3,1-8                |
+------------------------------------+

+------------------------------------+
|  Thánh lễ quan trọng               |
|  Chọn giáo xứ của bạn để xem lễ    |
|  Chúa nhật hoặc lễ trọng sắp tới.  |
|  [Chọn giáo xứ]                    |
+------------------------------------+

+------------------------------------+
|  Ghi chú riêng                     |
|  Bạn muốn nhớ điều gì hôm nay?     |
+------------------------------------+
```

Bottom tabs:

```text
Today | Calendar | Pray | Church | Progress
```

## Today Layout Requirements

- Liturgical context is first but compact.
- Daily action card is the largest element.
- Completion is one tap.
- Reading references show citations, not full copyrighted text.
- Important Mass appears after readings.
- Reflection note is private and visually quiet.
- Offline is normal; show stale/missing content honestly.
- Vietnamese feast names can wrap to two lines without overlap.

## Today States

### Incomplete

Primary button: `Tôi đã làm việc này`  
Secondary action: optional note affordance.

### Completed

Show gentle completion state:

```text
Đã hoàn thành hôm nay
Nhịp sống của bạn đang được xây từng ngày.
```

No score, failure copy, ranking, or public proof.

### Missing Parish

Important Mass card remains useful:

```text
Chọn giáo xứ của bạn để xem Thánh lễ quan trọng sắp tới.
```

### Stale Mass Data

```text
Lịch lễ này cần được kiểm tra lại. Hãy xác nhận với giáo xứ trước khi đi.
```

## Small iOS Widget

Goal: one glance, one action.

```text
+--------------------+
| Thứ Hai II PS [W]  |
|                    |
| Viết một câu về    |
| Tin Mừng hôm nay   |
|                    |
| 5 phút             |
+--------------------+
```

Tap target: opens Today.

Snapshot fields:

- `date`
- `weekday_label`
- `liturgical_context`
- `liturgical_color`
- `action_short_title`
- `duration_minutes`
- `deep_link`

## Medium iOS Widget

Goal: action plus one supporting context line.

```text
+------------------------------------+
| Thứ Hai tuần II Phục Sinh [white]  |
|                                    |
| Viết một câu về Tin Mừng hôm nay   |
| Đọc và ghi lại một điều muốn sống. |
|                                    |
| Bài đọc: Cv 14,5-18 / Ga 3,1-8     |
| Thánh lễ: Chưa chọn giáo xứ        |
+------------------------------------+
```

When Mass exists:

```text
Thánh lễ: CN 07:30 / Giáo xứ đã chọn
```

Snapshot fields:

- Small widget fields
- `action_prompt`
- `reading_summary`
- `completion_state`
- `mass_summary`

## Widget Visual Rules

- Warm off-white or white background.
- 8px effective corner rhythm inside WidgetKit constraints.
- Chapel green for primary accent.
- Liturgical color appears as a dot or rail, never a full saturated background.
- No decorative religious imagery in beta.
- Text must remain readable on small widgets with Vietnamese diacritics.

## Implementation Notes

- Widgets read compact JSON from App Group storage.
- Flutter owns generation of widget snapshots from the local database.
- Widget must tolerate missing snapshot by showing a calm fallback:

```text
Sống Đạo
Mở ứng dụng để chuẩn bị việc hôm nay.
```

- Widget never fetches network data directly.
- Tapping any widget opens Today through a deep link.
