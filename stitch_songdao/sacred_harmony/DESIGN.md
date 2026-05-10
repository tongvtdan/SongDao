---
name: Sacred Harmony
colors:
  surface: '#fcf9f3'
  surface-dim: '#dcdad4'
  surface-bright: '#fcf9f3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3ed'
  surface-container: '#f0eee8'
  surface-container-high: '#ebe8e2'
  surface-container-highest: '#e5e2dc'
  on-surface: '#1c1c18'
  on-surface-variant: '#414941'
  inverse-surface: '#31312d'
  inverse-on-surface: '#f3f0ea'
  outline: '#727970'
  outline-variant: '#c1c9be'
  surface-tint: '#3a6843'
  primary: '#204e2b'
  on-primary: '#ffffff'
  primary-container: '#386641'
  on-primary-container: '#afe2b3'
  inverse-primary: '#a0d3a5'
  secondary: '#6e5097'
  on-secondary: '#ffffff'
  secondary-container: '#d1affe'
  on-secondary-container: '#5c3e84'
  tertiary: '#841d24'
  on-tertiary: '#ffffff'
  tertiary-container: '#a43539'
  on-tertiary-container: '#ffc8c6'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#bcefc0'
  primary-fixed-dim: '#a0d3a5'
  on-primary-fixed: '#00210a'
  on-primary-fixed-variant: '#22502d'
  secondary-fixed: '#eddcff'
  secondary-fixed-dim: '#d8b9ff'
  on-secondary-fixed: '#28054f'
  on-secondary-fixed-variant: '#55387d'
  tertiary-fixed: '#ffdad8'
  tertiary-fixed-dim: '#ffb3b0'
  on-tertiary-fixed: '#410007'
  on-tertiary-fixed-variant: '#861f25'
  background: '#fcf9f3'
  on-background: '#1c1c18'
  surface-variant: '#e5e2dc'
typography:
  display-lg:
    fontFamily: Noto Serif
    fontSize: 40px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Noto Serif
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.3'
  headline-md:
    fontFamily: Noto Serif
    fontSize: 24px
    fontWeight: '500'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 48px
  xl: 64px
  container-max: 1200px
  gutter: 24px
---

## Brand & Style

This design system is built upon the principles of **Serene Minimalism**. It seeks to create a digital sanctuary that honors tradition while embracing contemporary clarity. The brand personality is meditative, respectful, and timeless, catering to users seeking spiritual reflection without the distractions of modern high-intensity interfaces.

The visual style utilizes heavy whitespace and a warm, paper-like foundation to evoke the feeling of a well-kept liturgical book. By balancing the weight of classical serif typography with the functional precision of modern sans-serif, the system achieves a "slightly traditional yet contemporary" aesthetic. Every interaction is designed to be intentional, slowing down the user's pace to foster a sense of peace and focus.

## Colors

The palette is rooted in the liturgical calendar, where color serves as a functional signifier of the current season. The background departs from "digital white" in favor of a warm cream (#F9F6F0), reducing eye strain during long periods of reading and reflection.

- **Ordinary Time (Primary):** A deep, grounded Green (#386641) used for standard navigation and steady growth.
- **Lent & Advent (Secondary):** A contemplative Violet (#6A4C93) for periods of preparation and penance.
- **Feasts & Martyrs (Tertiary):** A respectful, muted Red (#BC4749) for celebration and sacrifice.
- **Easter & Christmas:** Represented by the background itself and gold accents (Yellow-Ochre) to signify light and purity.

Text is rendered in a soft charcoal rather than pure black to maintain the gentle contrast required for a serene experience.

## Typography

Typography in this design system is treated as a medium for scripture and prayer. **Noto Serif** is used for all headings to provide an authoritative, literary feel reminiscent of traditional hymnals and missals. It conveys elegance and history.

For the primary reading experience and functional UI elements, **Inter** provides high legibility and a neutral, systematic counterweight to the serif headers. This pairing ensures that while the document feels "sacred," the interface remains modern and accessible. Large line heights (1.6x) are mandated for body text to ensure a comfortable, unhurried reading cadence.

## Layout & Spacing

The layout philosophy follows a **Fixed Grid** model for desktop and a **Fluid Margin** model for mobile devices. The core of the system is the "Sacred Center"—a layout principle where the most important content is centered with generous horizontal margins to minimize distraction.

We utilize an 8px rhythmic grid. Spacing is intentionally generous (the "Breathe" principle); elements are never crowded. Vertical rhythm is prioritized to guide the user downward through a spiritual narrative or daily reading. Content spans 12 columns on desktop, typically constrained to a 6-8 column central reading well.

## Elevation & Depth

Visual hierarchy is conveyed through **Ambient Shadows** and **Tonal Layers**. Rather than using high-contrast borders, the design system uses extremely soft, diffused shadows (0% spread, high blur) to lift cards off the warm background.

Depth is used to signify "containers of wisdom." The background is the lowest level (Level 0). Cards containing daily readings or prayers sit at Level 1. Modals or primary action buttons sit at Level 2. This subtle stacking creates a tactile feel, as if layers of paper are being placed atop one another, rather than a digital window.

## Shapes

The shape language is defined by **Rounded** corners (Level 2). This choice softens the interface, making the experience feel approachable and gentle. Sharp 0px corners are avoided to move away from "institutional" or "legal" aesthetics, while full pills are reserved only for specific tags or chips to maintain the formal structure of the cards.

- Standard UI elements (Buttons, Inputs): 0.5rem (8px).
- Large Containers (Cards, Content Areas): 1rem (16px).

## Components

### Cards
Cards are the primary structural unit. They must feature a subtle shadow and a background color that is slightly "brighter" white than the cream page background to create a "lifted" effect. They should avoid heavy borders.

### Buttons
The primary action button uses a solid fill based on the current liturgical season's color. There should only be one primary action per screen. Secondary actions must be "ghost" buttons with only a serif label or a subtle underline.

### Liturgical Chips
Small, pill-shaped tags used to denote the day of the week or the specific liturgical feast. These use low-saturation versions of the seasonal colors to avoid overwhelming the text.

### Iconography
Icons should be thin-stroke (Linear) and meaningful. Avoid overly playful or "bubbly" icons; opt for geometric and representational symbols that align with religious iconography.

### Lists
Lists of prayers or readings should be separated by thin, low-opacity lines (1px) in a slightly darker tone than the cream background, ensuring clear separation without visual noise.