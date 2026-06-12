# HelpView Accordion Redesign

**Date:** 2026-06-12  
**Status:** Approved

## Problem

The current `HelpView` renders a single multi-line string (`t(.helpContent)`) as a plain `Text` view with uniform font size and line spacing. There is no visual hierarchy between sections, no icons, and no way to navigate to a specific topic. All content is equally prominent, making it hard to scan.

## Solution

Replace the flat text block with a **4-section accordion** (expand/collapse per section). All sections start collapsed. Users tap a section header to reveal its content.

---

## Architecture

### Component

A new `HelpView` body replaces the existing `ScrollView { Text(...) }` with a `ScrollView { VStack { AccordionSection(...) × 4 } }`.

`HelpView` remains a `struct View` sheet presented from the Settings toolbar `?` button. No changes to call sites.

### AccordionSection

A private helper view inside `HelpView`:

```swift
private struct AccordionSection<Content: View>: View {
    let icon: String          // SF Symbol name
    let iconColor: Color
    let title: String
    @Binding var isExpanded: Bool
    @ViewBuilder var content: () -> Content
}
```

- Header: `HStack` — icon box (28×28 rounded rect with tinted background) + title + chevron (`chevron.down`)
- Tap header → toggle `isExpanded` with `withAnimation(.easeInOut(duration: 0.22))`
- Chevron rotates 180° when expanded (`rotationEffect`)
- Body: shown/hidden with `if isExpanded` inside the animation block

Four `@State` booleans in `HelpView` track expansion independently — multiple sections can be open simultaneously.

---

## Sections & Content

### 1. 시작하기
- **Icon:** `play.circle.fill` — `#4ade80` on `#16a34a` tinted bg
- **Items:** numbered steps (yellow circle + step number)
  | # | 제목 | 설명 |
  |---|------|------|
  | 1 | 목표 설정 | 설정 탭에서 거리·칼로리·시간 중 목표 유형을 선택하고, 이번 달 목표값을 입력하세요. |
  | 2 | Apple Health 동기화 | 권한을 허용하면 러닝 데이터를 자동으로 불러옵니다. |
  | 3 | 대시보드 확인 | 일별 바 차트와 월간 요약으로 진행 상황을 한눈에 확인할 수 있습니다. |

### 2. 기본 기능
- **Icon:** `star.fill` — `#60a5fa` on `#2563eb` tinted bg
- **Items:** icon box (22×22 tinted rounded rect) + 제목 + 설명
  | SF Symbol | 제목 | 설명 |
  |-----------|------|------|
  | `flag.checkered` (yellow) | 마일리지 목표 | 이번 달 목표와 남은 일수를 대시보드에서 바로 확인할 수 있습니다. |
  | `arrow.2.circlepath` (green) | 러닝 빈도 | 매일·격일·3일마다 중에서 선택하면 회당 필요한 목표량을 자동으로 계산해드립니다. |
  | `ruler` (blue) | 거리 단위 | km와 마일 사이를 자유롭게 전환할 수 있고, 목표값도 자동으로 변환됩니다. |

### 3. 위젯 & 알림
- **Icon:** `bell.and.waves.left.and.right.fill` — `#a78bfa` on `#7c3aed` tinted bg
- **Items:** same icon-box style as 기본 기능
  | SF Symbol | 제목 | 설명 |
  |-----------|------|------|
  | `square.grid.2x2.fill` (purple) | 홈 화면 위젯 | 4가지 레이아웃 중 원하는 스타일을 선택하고, Pro 버전에서는 배경 사진도 설정할 수 있습니다. |
  | `bell.fill` (orange) | 목표 리마인더 | 월말 7일·3일·1일 전에 목표 달성 현황을 알림으로 알려드립니다. |

### 4. 도움말
- **Icon:** `lightbulb.fill` — `#fbbf24` on `#ca8a04` tinted bg
- **Items:** yellow dot bullet + plain sentence
  - 정기적으로 동기화해 최신 데이터를 유지하세요.
  - 위젯은 1시간마다 자동으로 갱신됩니다.
  - 설정 탭에서 테마 색상과 언어를 변경할 수 있습니다.

---

## Item Row Styles

### Step Row (시작하기 only)
```
[yellow circle "1"] [title bold 10pt]
                    [desc 9pt gray, line-height 1.45]
```
Rows separated by 1pt divider (`Divider()`). No divider after last row.

### Feature Row (기본 기능, 위젯&알림)
```
[22×22 tinted icon box]  [title bold 10pt  ]
                          [desc 9pt gray    ]
```
Same divider pattern.

### Tip Row (도움말)
```
[5pt yellow dot]  [sentence 9.5pt light gray]
```
No dividers — plain `VStack(spacing: 6)`.

---

## Visual Tokens

| Token | Value |
|-------|-------|
| Section card bg | `cCard` (passed as param to `HelpView`) |
| Section corner radius | 12pt |
| Icon box size | 28×28pt (header), 22×22pt (item) |
| Icon box corner radius | 7pt (header), 6pt (item) |
| Icon tint bg opacity | 0.13 |
| Header title font | `.pretendard(.semibold, size: 15)` |
| Item title font | `.pretendard(.semibold, size: 13)` |
| Item desc font | `.pretendard(.regular, size: 12)` |
| Item desc color | `cSub` (passed as param to `HelpView`) |
| Chevron symbol | `chevron.down` |
| Animation duration | 0.22s easeInOut |

---

## Localization

`helpContent` string key is **removed** from `LocalizedStrings.swift`. New granular keys are added:

```
helpSectionStart, helpSectionFeatures, helpSectionWidget, helpSectionTips
helpStep1Title, helpStep1Desc
helpStep2Title, helpStep2Desc
helpStep3Title, helpStep3Desc
helpFeatGoalTitle, helpFeatGoalDesc
helpFeatFreqTitle, helpFeatFreqDesc
helpFeatUnitTitle, helpFeatUnitDesc
helpWidgetTitle, helpWidgetDesc
helpNotifTitle, helpNotifDesc
helpTip1, helpTip2, helpTip3
```

All 6 languages (EN, KO, DE, FR, ZH, ES) must be updated.

---

## Out of Scope

- No changes to when/how `HelpView` is presented (toolbar `?` button, Settings sheet)
- No persistence of expanded state between sessions
- No search or filter within help content
- `preferredColorScheme(nil)` on the sheet stays as-is
