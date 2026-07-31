# Project Brief: Sống Đạo — Catholic Daily Practice App

## 1. Project Overview
**Sống Đạo** is a local-first Catholic daily action app designed to turn the liturgical calendar into concrete daily practice. Unlike traditional reference-heavy Catholic apps, Sống Đạo focuses on helping users build a consistent faith rhythm through one clear daily action, liturgical context, and private tracking.

### North Star
"A local-first Catholic daily action app that turns the liturgical calendar into concrete daily practice."

---

## 2. Core Value Proposition
- **Action-Oriented:** Answers "What should I do today to live my faith?" rather than just "What is the reading?"
- **Local-First:** Designed to work entirely offline for use in churches or travel.
- **Privacy-Centric:** Faith tracking is private and non-judgmental; no public rankings or "faith scores."
- **Cultural Context:** Deep support for the Vietnamese liturgical calendar, including lunar dates and local parish data.

---

## 3. Target Audience
- **Busy Young Catholics (18–35):** Seeking a simple, non-overwhelming way to stay connected to faith daily.
- **Parish-Connected Vietnamese Catholics:** Users who need local Mass times, feast day reminders, and lunar calendar integration.
- **Returning Catholics:** Users looking for a gentle, structured way to re-engage with their faith.

---

## 4. Key Features & Functionality

### 4.1 Today (Hôm nay) - The Command Center
- **Block Calendar Header:** Visual solar and lunar date display inspired by traditional Vietnamese paper calendars.
- **Daily Action Engine:** A curated recommendation (pray, fast, serve, reflect) based on the liturgical day.
- **Liturgical Context:** Displays the current season (e.g., Lent), color, and major feasts/solemnities.
- **Daily Word:** Gospel references and short reflection prompts.

### 4.2 Liturgical Calendar
- Visual month and week views highlighting liturgical seasons and colors.
- Quick access to upcoming feasts and Sunday obligations.

### 4.3 Private Practice Tracking (Tiến triển)
- **Faith Rhythm:** Visual tracking of completed daily actions.
- **Private Notes:** A space for personal reflections and journaling.
- **Gentle Motivation:** Focus on consistency and personal growth rather than public competition.

### 4.4 Church & Mass Finder (Nhà thờ)
- Parish directory with specific focus on Vietnamese dioceses.
- Mass and Confession schedules.
- "My Parish" feature for personalized reminders.

### 4.5 Prayer Library (Cầu nguyện)
- Collection of common and seasonal prayers.
- Dedicated tools for Confession preparation (Examination of Conscience).

---

## 5. Visual Identity & Design System
**Name:** Sacred Harmony
- **Typography:** Noto Serif for a scholarly, premium reading experience.
- **Color Palette:** Grounded in liturgical colors (Green, Purple, Red, White) set against soft, parchment-like surfaces.
- **Aesthetic:** Serene, respectful, and high-end editorial.

---

## 6. Technical Approach
- **Platform:** Flutter (iOS & Android).
- **Architecture:** Local-first using Drift (SQLite) as the source of truth.
- **Integration:** iOS WidgetKit for home screen "Daily Action" reminders.
- **Content:** Seeded with liturgical calendar data and action rules to ensure offline utility.

---

## 7. Roadmap
- **MVP:** Core "Today" flow, Daily Action Engine, Local DB, and basic Vietnamese calendar.
- **V1:** Church search, "My Parish" integration, expanded prayer library, and iOS Widgets.
- **V2:** Encrypted backups, family mode, and licensed full-text readings.