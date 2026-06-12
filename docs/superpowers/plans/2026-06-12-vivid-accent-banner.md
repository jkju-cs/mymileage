# Vivid Accent Banner Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the darkened accent gradient on the mileage goal banner with vivid, full-saturation accent colors so each accent is immediately recognizable.

**Architecture:** Single computed property change in `ContentView.swift`. `heroBannerColors` currently returns deliberately darkened gradient stops (navy and blue become near-black). Replace all 7 `case` returns with vivid hex pairs. No layout, ring, text, shadow, or theme logic changes.

**Tech Stack:** SwiftUI, no new dependencies.

---

### Task 1: Update `heroBannerColors` with vivid gradient values

**Files:**
- Modify: `code/MotivationRun/ContentView.swift:436-445`

This is a pure visual change — no testable logic, no new types. The verification step is a build check followed by visual inspection of all 7 accents.

- [ ] **Step 1: Replace `heroBannerColors` in ContentView.swift**

Find the property at line ~436 (search for `heroBannerColors`). Replace the entire computed property body:

```swift
// Accent-linked vivid gradient for the hero banner
private var heroBannerColors: [Color] {
    switch themeAccent {
    case .navy:   return [Color(hex: "#6AA0FF"), Color(hex: "#3065D4")]
    case .blue:   return [Color(hex: "#2563EB"), Color(hex: "#1746B0")]
    case .green:  return [Color(hex: "#0DC450"), Color(hex: "#04B249")]
    case .orange: return [Color(hex: "#FF8A30"), Color(hex: "#FD6A00")]
    case .red:    return [Color(hex: "#F75050"), Color(hex: "#D42020")]
    case .purple: return [Color(hex: "#B266EE"), Color(hex: "#7C22C8")]
    case .yellow: return [Color(hex: "#FFD145"), Color(hex: "#FFB902")]
    }
}
```

- [ ] **Step 2: Build the project**

In Xcode: **Product → Build** (⌘B), or via CLI:

```bash
xcodebuild -project code/MotivationRun.xcodeproj \
  -scheme MotivationRun \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | grep -E "error:|BUILD"
```

Expected: `BUILD SUCCEEDED` with no errors. (The only change is hex string literals — no type or API changes.)

- [ ] **Step 3: Visual inspection on simulator**

Run the app on any iPhone simulator. Go to **Settings → Accent**, cycle through all 7 accents, and verify the dashboard banner:

| Accent | Expected banner color |
|--------|-----------------------|
| Navy | Vivid royal blue gradient |
| Blue | Cobalt blue gradient |
| Green | Bright green gradient |
| Orange | Vivid orange gradient |
| Red | Bright red gradient |
| Purple | Vivid violet gradient |
| Yellow | Bright gold gradient |

Also toggle **Settings → Theme** between Dark and Light and confirm the vivid banner reads clearly on both `#0B0D12` (dark bg) and `#E8EAED` (light bg).

- [ ] **Step 4: Commit**

```bash
git add code/MotivationRun/ContentView.swift
git commit -m "feat: use vivid accent gradient on mileage goal banner"
```
