# Vivid Accent Banner — Design Spec

**Date:** 2026-06-12  
**Status:** Approved  

## Problem

The mileage goal banner on the Dashboard tab uses accent-derived *dark* gradient colors (`heroBannerColors`). These were chosen so white text would remain readable, but the side effect is that the accent color is imperceptible — especially for navy and blue, which produce near-black banners that barely distinguish from the app's dark card background (`#161A22`).

## Goal

Make the accent color immediately obvious on the banner without changing the banner's layout, ring design, or text treatment.

## Decision

**Option C: Vivid accent gradient, white text.**  
Replace the darkened gradient stops in `heroBannerColors` with the actual vivid accent hues. Everything else stays the same.

Alternatives considered:
- **Option A (neutral banner + accent ring):** Accent ring on dark neutral background — accent is clear, but the banner loses its distinctive per-theme color identity.
- **Option B (accent banner + accent ring):** Adds accent ring stroke on top of the existing accent bg — creates a same-hue-on-same-hue problem for some accents.
- **Option C (vivid banner):** Chosen — most vivid, works on both light and dark app themes, minimal code change.

User explicitly accepted that yellow and orange accents will have low WCAG contrast between white text and the bright banner background.

## Scope

Single computed property change: `heroBannerColors` in `ContentView.swift` (~line 436).

No changes to:
- `GoalProgressRing` (white ring stays)
- Banner layout, padding, or shadow
- Text colors (all white, unchanged)
- Light/dark theme logic (same gradient applied in both themes)

## New Color Values

`heroBannerColors` — gradient direction: `topLeading → bottomTrailing`

| Accent | Top (start) | Bottom (end) | Notes |
|--------|-------------|--------------|-------|
| `.navy` | `#6AA0FF` | `#3065D4` | Was `#1A2E5E → #0A1F4A` (near-black). Uses dark-variant hue at vivid saturation. |
| `.blue` | `#2563EB` | `#1746B0` | Was `#0D3A96 → #071E6E` (dark navy). Now true cobalt. |
| `.green` | `#0DC450` | `#04B249` | Was `#00ab45 → #006c28` (dark forest). Now uses the accent base color. |
| `.orange` | `#FF8A30` | `#FD6A00` | Was `#da5b00 → #c04d00` (dark burnt orange). Now vivid orange. |
| `.red` | `#F75050` | `#D42020` | Was `#cb1414 → #a91b1b` (dark crimson). Now vivid red. |
| `.purple` | `#B266EE` | `#7C22C8` | Was `#4A1580 → #30095A` (near-black). Now vivid violet. |
| `.yellow` | `#FFD145` | `#FFB902` | Was `#fad501 → #ce9403` (muddy gold). Now bright gold using the accent base. |

## Implementation

**File:** `code/MotivationRun/ContentView.swift`  
**Property:** `heroBannerColors` (computed, returns `[Color]`)  
**Change:** Replace the 7 `case` return values with the new hex pairs above.

No other files need changing. The shadow (`themeAccent.color.opacity(0.30)`) already uses the vivid accent color and requires no update.

## Light Theme Behavior

The vivid gradient block pops cleanly against the `#E8EAED` light app background — actually stronger contrast than the current dark gradient on a light background. No theme-conditional logic needed.
