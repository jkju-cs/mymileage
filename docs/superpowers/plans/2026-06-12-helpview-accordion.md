# HelpView Accordion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `HelpView`'s plain text block with a 4-section accordion using SF Symbol icons, numbered step rows, and feature rows with title + description on separate lines.

**Architecture:** `AccordionSection<Content: View>` is a private generic struct in `ContentView.swift` that handles expand/collapse animation. `HelpView` holds four `@State Bool` values (one per section) and uses private helper functions (`helpStepRow`, `helpFeatureRow`, `helpTipRow`) to build each row. `helpContent` LK key is removed and replaced with 23 granular keys covering 6 languages.

**Tech Stack:** SwiftUI, `.pretendard` font extension (existing), `Color(hex:)` extension (existing), `LocalizedStrings.swift` dictionary-based localization.

---

## File Map

| File | Change |
|------|--------|
| `code/MotivationRun/LocalizedStrings.swift` | Remove `case helpContent`; add 23 new `LK` cases; update all 6 language dictionaries |
| `code/MotivationRun/ContentView.swift` | Replace `HelpView` body; add `AccordionSection` private struct after `HelpView` |

---

### Task 1: Add new LK enum cases

**Files:**
- Modify: `code/MotivationRun/LocalizedStrings.swift:86-87`

- [ ] **Step 1: Replace `helpContent` case with 23 granular cases**

Find and replace in `LocalizedStrings.swift`. The current block at line 86-87:
```swift
    case helpTitle
    case helpContent
```
Replace with:
```swift
    case helpTitle
    // Help — section headers
    case helpSectionStart
    case helpSectionFeatures
    case helpSectionWidget
    case helpSectionTips
    // Help — getting started steps
    case helpStep1Title
    case helpStep1Desc
    case helpStep2Title
    case helpStep2Desc
    case helpStep3Title
    case helpStep3Desc
    // Help — core features
    case helpFeatGoalTitle
    case helpFeatGoalDesc
    case helpFeatFreqTitle
    case helpFeatFreqDesc
    case helpFeatUnitTitle
    case helpFeatUnitDesc
    // Help — widget & notifications
    case helpWidgetTitle
    case helpWidgetDesc
    case helpNotifTitle
    case helpNotifDesc
    // Help — tips
    case helpTip1
    case helpTip2
    case helpTip3
```

- [ ] **Step 2: Verify the enum compiles (no build needed yet — check for duplicates)**

Search the file for any remaining `helpContent` references in the enum:
```bash
grep -n "case helpContent" code/MotivationRun/LocalizedStrings.swift
```
Expected: no output (zero matches).

---

### Task 2: Update English dictionary

**Files:**
- Modify: `code/MotivationRun/LocalizedStrings.swift` (English section, around line 298)

- [ ] **Step 1: Remove the English `helpContent` entry**

Find and delete this block (lines 298–317):
```swift
            .helpContent: """
MyMileage helps you hit your monthly running goal.

Getting Started
1. Open the Settings tab and tap "Set Goal" to choose your goal type (distance, calories, or duration) and set a monthly target.
2. Tap "Sync Apple Health" to grant permission and import your running data.
3. The Dashboard shows a daily bar chart and monthly summary for your progress.

Key Features
• Mileage Goal — The current month displays your goal and remaining days at a glance.
• Run Frequency — Choose daily, every 2 days, or every 3 days. The app calculates how much you need per session.
• Distance Unit — Switch between km and miles in Settings. Your goal converts automatically.
• Widget — Add the widget to your Home Screen. Choose from 4 layouts (Minimal, Compact, Balanced, Complete) and set a custom background photo.
• Notifications — Get reminders 7, 3, or 1 day before month-end if you haven't reached your goal yet.

Tips
• Sync regularly to keep your data up to date.
• The widget refreshes automatically every hour.
• Use the Settings tab to customize theme colors, language, and more.
""",
```

- [ ] **Step 2: Add English granular entries in its place**

Insert these entries right before the `],` that closes the English dictionary (after the last entry before `],`):
```swift
            .helpSectionStart:      "Getting Started",
            .helpSectionFeatures:   "Core Features",
            .helpSectionWidget:     "Widget & Notifications",
            .helpSectionTips:       "Tips",
            .helpStep1Title:        "Set Your Goal",
            .helpStep1Desc:         "In the Settings tab, choose your goal type — distance, calories, or duration — then enter your monthly target.",
            .helpStep2Title:        "Sync Apple Health",
            .helpStep2Desc:         "Grant permission and your running data will be imported automatically.",
            .helpStep3Title:        "Check Your Dashboard",
            .helpStep3Desc:         "View daily bar charts and your monthly summary to track progress at a glance.",
            .helpFeatGoalTitle:     "Mileage Goal",
            .helpFeatGoalDesc:      "Your monthly target and remaining days are shown on the dashboard at a glance.",
            .helpFeatFreqTitle:     "Run Frequency",
            .helpFeatFreqDesc:      "Choose daily, every 2 days, or every 3 days — the required amount per session is calculated automatically.",
            .helpFeatUnitTitle:     "Distance Unit",
            .helpFeatUnitDesc:      "Switch freely between km and miles — your goal value converts automatically.",
            .helpWidgetTitle:       "Home Screen Widget",
            .helpWidgetDesc:        "Choose from 4 layouts — Minimal, Compact, Balanced, or Complete. Set a custom background photo with Pro.",
            .helpNotifTitle:        "Goal Reminders",
            .helpNotifDesc:         "Receive notifications 7, 3, and 1 day before month-end if your goal hasn't been reached yet.",
            .helpTip1:              "Sync regularly to keep your data up to date.",
            .helpTip2:              "The widget refreshes automatically every hour.",
            .helpTip3:              "Customize your theme colors and language in the Settings tab.",
```

- [ ] **Step 3: Verify no remaining English `helpContent` key**

```bash
grep -n "\.helpContent" code/MotivationRun/LocalizedStrings.swift | head -10
```
Expected: lines from KO, DE, FR, ZH, ES only — no English line.

- [ ] **Step 4: Commit**

```bash
git add code/MotivationRun/LocalizedStrings.swift
git commit -m "feat: add granular help LK cases, update EN strings"
```

---

### Task 3: Update Korean dictionary

**Files:**
- Modify: `code/MotivationRun/LocalizedStrings.swift` (Korean section, around line 441)

- [ ] **Step 1: Remove the Korean `helpContent` entry**

Find and delete:
```swift
            .helpContent: """
MyMileage는 이번 달 러닝 목표를 달성할 수 있도록 도와주는 앱입니다.

시작하기
1. 설정 탭에서 '목표 설정'을 탭해 목표 유형(거리·칼로리·시간)과 월간 목표값을 입력하세요.
2. 'Apple Health 동기화'를 탭해 권한을 허용하고 러닝 데이터를 불러오세요.
3. 대시보드에서 일별 바 차트와 월간 요약으로 진행 상황을 확인하세요.

주요 기능
• 마일리지 목표 — 현재 월에는 이번 달 목표와 남은 일수가 한눈에 표시됩니다.
• 러닝 빈도 — 매일·격일·3일마다 중 선택하면 회당 필요량이 자동 계산됩니다.
• 거리 단위 — 설정에서 km와 마일을 전환할 수 있고, 목표값은 자동 변환됩니다.
• 위젯 — 홈 화면에 위젯을 추가하세요. 4가지 레이아웃(미니멀, 컴팩트, 밸런스, 컴플리트) 중 선택하고, 배경 사진도 설정할 수 있습니다.
• 알림 — 월말 7일·3일·1일 전에 목표 미달성 리마인더를 받을 수 있습니다.

도움말
• 정기적으로 동기화해 데이터를 최신 상태로 유지하세요.
• 위젯은 1시간마다 자동으로 갱신됩니다.
• 설정 탭에서 테마 색상, 언어 등을 변경할 수 있습니다.
""",
```

- [ ] **Step 2: Add Korean granular entries in its place**

```swift
            .helpSectionStart:      "시작하기",
            .helpSectionFeatures:   "기본 기능",
            .helpSectionWidget:     "위젯 & 알림",
            .helpSectionTips:       "도움말",
            .helpStep1Title:        "목표 설정",
            .helpStep1Desc:         "설정 탭에서 거리·칼로리·시간 중 목표 유형을 선택하고, 이번 달 목표값을 입력하세요.",
            .helpStep2Title:        "Apple Health 동기화",
            .helpStep2Desc:         "권한을 허용하면 러닝 데이터를 자동으로 불러옵니다.",
            .helpStep3Title:        "대시보드 확인",
            .helpStep3Desc:         "일별 바 차트와 월간 요약으로 진행 상황을 한눈에 확인할 수 있습니다.",
            .helpFeatGoalTitle:     "마일리지 목표",
            .helpFeatGoalDesc:      "이번 달 목표와 남은 일수를 대시보드에서 바로 확인할 수 있습니다.",
            .helpFeatFreqTitle:     "러닝 빈도",
            .helpFeatFreqDesc:      "매일·격일·3일마다 중에서 선택하면 회당 필요한 목표량을 자동으로 계산해드립니다.",
            .helpFeatUnitTitle:     "거리 단위",
            .helpFeatUnitDesc:      "km와 마일 사이를 자유롭게 전환할 수 있고, 목표값도 자동으로 변환됩니다.",
            .helpWidgetTitle:       "홈 화면 위젯",
            .helpWidgetDesc:        "4가지 레이아웃 중 원하는 스타일을 선택하고, Pro 버전에서는 배경 사진도 설정할 수 있습니다.",
            .helpNotifTitle:        "목표 리마인더",
            .helpNotifDesc:         "월말 7일·3일·1일 전에 목표 달성 현황을 알림으로 알려드립니다.",
            .helpTip1:              "정기적으로 동기화해 최신 데이터를 유지하세요.",
            .helpTip2:              "위젯은 1시간마다 자동으로 갱신됩니다.",
            .helpTip3:              "설정 탭에서 테마 색상과 언어를 변경할 수 있습니다.",
```

- [ ] **Step 3: Commit**

```bash
git add code/MotivationRun/LocalizedStrings.swift
git commit -m "feat: update KO help strings for accordion"
```

---

### Task 4: Update German dictionary

**Files:**
- Modify: `code/MotivationRun/LocalizedStrings.swift` (German section, around line 584)

- [ ] **Step 1: Remove the German `helpContent` entry**

Find and delete:
```swift
            .helpContent: """
MyMileage hilft dir, dein monatliches Laufziel zu erreichen.

Erste Schritte
1. Öffne den Tab „Einstellungen" und tippe auf „Ziel setzen", um Zieltyp (Distanz, Kalorien oder Dauer) und monatlichen Zielwert festzulegen.
2. Tippe auf „Apple Health synchronisieren", um die Berechtigung zu erteilen und Laufdaten zu importieren.
3. Das Dashboard zeigt ein tägliches Balkendiagramm und eine Monatszusammenfassung.

Hauptfunktionen
• Laufziel — Im aktuellen Monat werden dein Ziel und die verbleibenden Tage auf einen Blick angezeigt.
• Lauffrequenz — Wähle täglich, alle 2 Tage oder alle 3 Tage. Das benötigte Pensum pro Einheit wird automatisch berechnet.
• Entfernungseinheit — Wechsle zwischen km und Meilen in den Einstellungen. Das Ziel wird automatisch umgerechnet.
• Widget — Füge das Widget zum Startbildschirm hinzu. Wähle aus 4 Layouts (Minimal, Kompakt, Ausgewogen, Komplett) und lege ein eigenes Hintergrundfoto fest.
• Benachrichtigungen — Erinnerungen 7, 3 oder 1 Tag vor Monatsende, wenn das Ziel noch nicht erreicht ist.

Tipps
• Synchronisiere regelmäßig, um deinen Fortschritt aktuell zu halten.
• Das Widget aktualisiert sich stündlich automatisch.
• Im Tab „Einstellungen" kannst du Farben, Sprache und mehr ändern.
""",
```

- [ ] **Step 2: Add German granular entries**

```swift
            .helpSectionStart:      "Erste Schritte",
            .helpSectionFeatures:   "Kernfunktionen",
            .helpSectionWidget:     "Widget & Benachrichtigungen",
            .helpSectionTips:       "Tipps",
            .helpStep1Title:        "Ziel setzen",
            .helpStep1Desc:         "Wähle im Einstellungen-Tab einen Zieltyp — Distanz, Kalorien oder Dauer — und gib dein Monatsziel ein.",
            .helpStep2Title:        "Apple Health synchronisieren",
            .helpStep2Desc:         "Erteile die Berechtigung und deine Laufdaten werden automatisch importiert.",
            .helpStep3Title:        "Dashboard ansehen",
            .helpStep3Desc:         "Sieh dir tägliche Balkendiagramme und deine Monatsübersicht an, um den Fortschritt auf einen Blick zu verfolgen.",
            .helpFeatGoalTitle:     "Laufziel",
            .helpFeatGoalDesc:      "Dein Monatsziel und die verbleibenden Tage sind auf dem Dashboard sofort sichtbar.",
            .helpFeatFreqTitle:     "Lauffrequenz",
            .helpFeatFreqDesc:      "Wähle täglich, alle 2 Tage oder alle 3 Tage — die erforderliche Menge pro Einheit wird automatisch berechnet.",
            .helpFeatUnitTitle:     "Entfernungseinheit",
            .helpFeatUnitDesc:      "Wechsle frei zwischen km und Meilen — dein Zielwert wird automatisch umgerechnet.",
            .helpWidgetTitle:       "Startbildschirm-Widget",
            .helpWidgetDesc:        "Wähle aus 4 Layouts — Minimal, Kompakt, Ausgewogen oder Komplett. Mit Pro kannst du ein benutzerdefiniertes Hintergrundbild festlegen.",
            .helpNotifTitle:        "Ziel-Erinnerungen",
            .helpNotifDesc:         "Erhalte Benachrichtigungen 7, 3 und 1 Tag vor Monatsende, wenn das Ziel noch nicht erreicht wurde.",
            .helpTip1:              "Synchronisiere regelmäßig, um deine Daten aktuell zu halten.",
            .helpTip2:              "Das Widget wird stündlich automatisch aktualisiert.",
            .helpTip3:              "Passe Themenfarben und Sprache im Einstellungen-Tab an.",
```

- [ ] **Step 3: Commit**

```bash
git add code/MotivationRun/LocalizedStrings.swift
git commit -m "feat: update DE help strings for accordion"
```

---

### Task 5: Update French dictionary

**Files:**
- Modify: `code/MotivationRun/LocalizedStrings.swift` (French section, around line 727)

- [ ] **Step 1: Remove the French `helpContent` entry**

Find and delete:
```swift
            .helpContent: """
MyMileage vous aide à atteindre votre objectif mensuel de course.

Pour commencer
1. Ouvrez l'onglet Réglages et appuyez sur « Définir l'objectif » pour choisir le type (distance, calories ou durée) et la cible mensuelle.
2. Appuyez sur « Sync Apple Health » pour accorder la permission et importer vos données de course.
3. Le tableau de bord affiche un graphique à barres quotidien et un résumé mensuel.

Fonctionnalités principales
• Objectif kilométrique — Le mois en cours affiche votre objectif et les jours restants en un coup d'œil.
• Fréquence de course — Choisissez quotidien, tous les 2 jours ou tous les 3 jours. L'app calcule automatiquement la quantité requise par session.
• Unité de distance — Passez entre km et miles dans les réglages. L'objectif se convertit automatiquement.
• Widget — Ajoutez le widget à l'écran d'accueil. Choisissez parmi 4 dispositions (Minimal, Compact, Équilibré, Complet) et définissez une photo de fond personnalisée.
• Notifications — Rappels 7, 3 ou 1 jour avant la fin du mois si l'objectif n'est pas atteint.

Conseils
• Synchronisez régulièrement pour maintenir votre progression à jour.
• Le widget se met à jour automatiquement toutes les heures.
• Utilisez l'onglet Réglages pour changer les couleurs, la langue et plus.
""",
```

- [ ] **Step 2: Add French granular entries**

```swift
            .helpSectionStart:      "Démarrer",
            .helpSectionFeatures:   "Fonctionnalités",
            .helpSectionWidget:     "Widget & Notifications",
            .helpSectionTips:       "Conseils",
            .helpStep1Title:        "Définir votre objectif",
            .helpStep1Desc:         "Dans l'onglet Réglages, choisissez votre type d'objectif — distance, calories ou durée — puis saisissez votre cible mensuelle.",
            .helpStep2Title:        "Synchroniser Apple Health",
            .helpStep2Desc:         "Accordez l'autorisation et vos données de course seront importées automatiquement.",
            .helpStep3Title:        "Consulter le tableau de bord",
            .helpStep3Desc:         "Visualisez les graphiques journaliers et votre résumé mensuel pour suivre votre progression en un coup d'œil.",
            .helpFeatGoalTitle:     "Objectif kilométrique",
            .helpFeatGoalDesc:      "Votre objectif mensuel et les jours restants sont affichés en un coup d'œil sur le tableau de bord.",
            .helpFeatFreqTitle:     "Fréquence de course",
            .helpFeatFreqDesc:      "Choisissez tous les jours, tous les 2 jours ou tous les 3 jours — la quantité requise par séance est calculée automatiquement.",
            .helpFeatUnitTitle:     "Unité de distance",
            .helpFeatUnitDesc:      "Basculez librement entre km et miles — votre valeur d'objectif se convertit automatiquement.",
            .helpWidgetTitle:       "Widget écran d'accueil",
            .helpWidgetDesc:        "Choisissez parmi 4 dispositions — Minimal, Compact, Équilibré ou Complet. Définissez une photo de fond personnalisée avec Pro.",
            .helpNotifTitle:        "Rappels d'objectif",
            .helpNotifDesc:         "Recevez des notifications 7, 3 et 1 jour avant la fin du mois si votre objectif n'est pas encore atteint.",
            .helpTip1:              "Synchronisez régulièrement pour maintenir vos données à jour.",
            .helpTip2:              "Le widget se rafraîchit automatiquement toutes les heures.",
            .helpTip3:              "Personnalisez les couleurs du thème et la langue dans l'onglet Réglages.",
```

- [ ] **Step 3: Commit**

```bash
git add code/MotivationRun/LocalizedStrings.swift
git commit -m "feat: update FR help strings for accordion"
```

---

### Task 6: Update Chinese dictionary

**Files:**
- Modify: `code/MotivationRun/LocalizedStrings.swift` (Chinese section, around line 870)

- [ ] **Step 1: Remove the Chinese `helpContent` entry**

Find and delete:
```swift
            .helpContent: """
MyMileage 帮助您实现每月跑步目标。

开始使用
1. 打开设置标签页，点击「设置目标」选择目标类型（距离、卡路里或时长）并输入月度目标值。
2. 点击「同步 Apple Health」授权并导入跑步数据。
3. 仪表盘显示每日柱状图和月度摘要，方便查看进度。

主要功能
• 里程目标 — 当前月份会显示本月目标和剩余天数，一目了然。
• 跑步频率 — 选择每天、隔天或每3天，App 自动计算每次所需量。
• 距离单位 — 在设置中切换千米和英里，目标将自动转换。
• 小组件 — 将小组件添加到主屏幕。可选择4种布局（极简、紧凑、均衡、完整），还可设置自定义背景照片。
• 通知 — 月末7天、3天或1天前未完成目标时收到提醒。

使用技巧
• 定期同步以保持数据最新。
• 小组件每小时自动更新一次。
• 在设置标签页中可更改主题颜色、语言等。
""",
```

- [ ] **Step 2: Add Chinese granular entries**

```swift
            .helpSectionStart:      "快速开始",
            .helpSectionFeatures:   "主要功能",
            .helpSectionWidget:     "小组件 & 通知",
            .helpSectionTips:       "使用技巧",
            .helpStep1Title:        "设置目标",
            .helpStep1Desc:         "在设置标签页中选择目标类型——距离、卡路里或时长——然后输入本月目标值。",
            .helpStep2Title:        "同步 Apple Health",
            .helpStep2Desc:         "授予权限后，跑步数据将自动导入。",
            .helpStep3Title:        "查看仪表盘",
            .helpStep3Desc:         "通过每日柱状图和月度摘要，一目了然地查看进度。",
            .helpFeatGoalTitle:     "里程目标",
            .helpFeatGoalDesc:      "本月目标和剩余天数在仪表盘上一目了然。",
            .helpFeatFreqTitle:     "跑步频率",
            .helpFeatFreqDesc:      "选择每天、每2天或每3天跑一次，每次所需目标量将自动计算。",
            .helpFeatUnitTitle:     "距离单位",
            .helpFeatUnitDesc:      "可在公里和英里之间自由切换，目标值会自动换算。",
            .helpWidgetTitle:       "主屏幕小组件",
            .helpWidgetDesc:        "从4种布局中选择——极简、紧凑、均衡或完整。Pro 版本可自定义背景图片。",
            .helpNotifTitle:        "目标提醒",
            .helpNotifDesc:         "如果目标尚未完成，将在月末7天、3天和1天前发送通知提醒。",
            .helpTip1:              "定期同步以保持数据最新。",
            .helpTip2:              "小组件每小时自动刷新一次。",
            .helpTip3:              "可在设置标签页中自定义主题颜色和语言。",
```

- [ ] **Step 3: Commit**

```bash
git add code/MotivationRun/LocalizedStrings.swift
git commit -m "feat: update ZH help strings for accordion"
```

---

### Task 7: Update Spanish dictionary

**Files:**
- Modify: `code/MotivationRun/LocalizedStrings.swift` (Spanish section, around line 1013)

- [ ] **Step 1: Remove the Spanish `helpContent` entry**

Find and delete:
```swift
            .helpContent: """
MyMileage te ayuda a alcanzar tu meta mensual de carrera.

Cómo empezar
1. Abre la pestaña Ajustes y toca «Establecer meta» para elegir el tipo (distancia, calorías o duración) y fijar la meta mensual.
2. Toca «Sincronizar Apple Health» para conceder permiso e importar tus datos de carrera.
3. El panel muestra un gráfico de barras diario y un resumen mensual de tu progreso.

Funciones principales
• Meta de kilometraje — El mes actual muestra tu meta y los días restantes de un vistazo.
• Frecuencia de carrera — Elige diario, cada 2 días o cada 3 días. La app calcula automáticamente la cantidad necesaria por sesión.
• Unidad de distancia — Cambia entre km y millas en los ajustes. La meta se convierte automáticamente.
• Widget — Añade el widget a la pantalla de inicio. Elige entre 4 diseños (Mínimo, Compacto, Equilibrado, Completo) y establece una foto de fondo personalizada.
• Notificaciones — Recordatorios 7, 3 o 1 día antes del fin de mes si no has alcanzado la meta.

Consejos
• Sincroniza regularmente para mantener tu progreso actualizado.
• El widget se actualiza automáticamente cada hora.
• Usa la pestaña Ajustes para cambiar colores, idioma y más.
""",
```

- [ ] **Step 2: Add Spanish granular entries**

```swift
            .helpSectionStart:      "Primeros pasos",
            .helpSectionFeatures:   "Funciones principales",
            .helpSectionWidget:     "Widget & Notificaciones",
            .helpSectionTips:       "Consejos",
            .helpStep1Title:        "Establecer objetivo",
            .helpStep1Desc:         "En la pestaña Ajustes, elige el tipo de objetivo — distancia, calorías o duración — e introduce tu meta mensual.",
            .helpStep2Title:        "Sincronizar Apple Health",
            .helpStep2Desc:         "Concede el permiso y tus datos de carrera se importarán automáticamente.",
            .helpStep3Title:        "Ver el panel",
            .helpStep3Desc:         "Consulta los gráficos de barras diarios y el resumen mensual para ver tu progreso de un vistazo.",
            .helpFeatGoalTitle:     "Objetivo de kilometraje",
            .helpFeatGoalDesc:      "Tu meta mensual y los días restantes se muestran de un vistazo en el panel.",
            .helpFeatFreqTitle:     "Frecuencia de carrera",
            .helpFeatFreqDesc:      "Elige cada día, cada 2 días o cada 3 días — la cantidad necesaria por sesión se calcula automáticamente.",
            .helpFeatUnitTitle:     "Unidad de distancia",
            .helpFeatUnitDesc:      "Cambia libremente entre km y millas — el valor de tu objetivo se convierte automáticamente.",
            .helpWidgetTitle:       "Widget de pantalla de inicio",
            .helpWidgetDesc:        "Elige entre 4 diseños — Mínimo, Compacto, Equilibrado o Completo. Con Pro puedes establecer una foto de fondo personalizada.",
            .helpNotifTitle:        "Recordatorios de objetivo",
            .helpNotifDesc:         "Recibe notificaciones 7, 3 y 1 día antes del fin de mes si tu objetivo aún no se ha alcanzado.",
            .helpTip1:              "Sincroniza regularmente para mantener tus datos actualizados.",
            .helpTip2:              "El widget se actualiza automáticamente cada hora.",
            .helpTip3:              "Personaliza los colores del tema y el idioma en la pestaña de Ajustes.",
```

- [ ] **Step 3: Verify all `helpContent` references are gone**

```bash
grep -n "helpContent" code/MotivationRun/LocalizedStrings.swift
```
Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add code/MotivationRun/LocalizedStrings.swift
git commit -m "feat: update ES help strings, remove all helpContent entries"
```

---

### Task 8: Add AccordionSection struct

**Files:**
- Modify: `code/MotivationRun/ContentView.swift` (after HelpView closing brace, before `// MARK: - 목표 설정 시트`)

- [ ] **Step 1: Insert AccordionSection after HelpView**

In `ContentView.swift`, locate the line `// MARK: - 목표 설정 시트` (around line 882). Insert the following block immediately before it:

```swift
// MARK: - Help Accordion Section

private struct AccordionSection<Content: View>: View {
    let icon: String
    let iconColor: Color
    let iconBgColor: Color
    let title: String
    @Binding var isExpanded: Bool
    let cCard: Color
    let cText: Color
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(iconBgColor)
                            .frame(width: 28, height: 28)
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(iconColor)
                    }
                    Text(title)
                        .font(.pretendard(.semibold, size: 15))
                        .foregroundColor(cText)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray.opacity(0.6))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
                    .padding(.horizontal, 14)
                content()
            }
        }
        .background(cCard)
        .cornerRadius(12)
    }
}

```

- [ ] **Step 2: Commit**

```bash
git add code/MotivationRun/ContentView.swift
git commit -m "feat: add AccordionSection helper view"
```

---

### Task 9: Rewrite HelpView body

**Files:**
- Modify: `code/MotivationRun/ContentView.swift:841-880`

- [ ] **Step 1: Replace the entire HelpView struct**

Find and replace the current `HelpView` struct (from `struct HelpView: View {` through its closing `}`). The current struct ends at line 880 (before the blank line and `// MARK: - 목표 설정 시트`).

Replace with:

```swift
struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    let language: AppLanguage
    let cAccent: Color
    let cBg: Color
    let cCard: Color
    let cText: Color
    let cSub: Color

    @State private var startExpanded = false
    @State private var featuresExpanded = false
    @State private var widgetExpanded = false
    @State private var tipsExpanded = false

    private func t(_ key: LK) -> String { L(key, language) }

    var body: some View {
        NavigationView {
            ZStack {
                cBg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        AccordionSection(
                            icon: "play.circle.fill",
                            iconColor: Color(hex: "#4ade80"),
                            iconBgColor: Color(hex: "#16a34a").opacity(0.13),
                            title: t(.helpSectionStart),
                            isExpanded: $startExpanded,
                            cCard: cCard,
                            cText: cText
                        ) {
                            VStack(spacing: 0) {
                                helpStepRow(num: "1", title: t(.helpStep1Title), desc: t(.helpStep1Desc))
                                helpDivider
                                helpStepRow(num: "2", title: t(.helpStep2Title), desc: t(.helpStep2Desc))
                                helpDivider
                                helpStepRow(num: "3", title: t(.helpStep3Title), desc: t(.helpStep3Desc))
                            }
                        }
                        AccordionSection(
                            icon: "star.fill",
                            iconColor: Color(hex: "#60a5fa"),
                            iconBgColor: Color(hex: "#2563eb").opacity(0.13),
                            title: t(.helpSectionFeatures),
                            isExpanded: $featuresExpanded,
                            cCard: cCard,
                            cText: cText
                        ) {
                            VStack(spacing: 0) {
                                helpFeatureRow(icon: "flag.checkered", iconColor: Color(hex: "#F5C800"), iconBg: Color(hex: "#F5C800").opacity(0.13), title: t(.helpFeatGoalTitle), desc: t(.helpFeatGoalDesc))
                                helpDivider
                                helpFeatureRow(icon: "arrow.2.circlepath", iconColor: Color(hex: "#4ade80"), iconBg: Color(hex: "#4ade80").opacity(0.13), title: t(.helpFeatFreqTitle), desc: t(.helpFeatFreqDesc))
                                helpDivider
                                helpFeatureRow(icon: "ruler", iconColor: Color(hex: "#60a5fa"), iconBg: Color(hex: "#60a5fa").opacity(0.13), title: t(.helpFeatUnitTitle), desc: t(.helpFeatUnitDesc))
                            }
                        }
                        AccordionSection(
                            icon: "bell.and.waves.left.and.right.fill",
                            iconColor: Color(hex: "#a78bfa"),
                            iconBgColor: Color(hex: "#7c3aed").opacity(0.13),
                            title: t(.helpSectionWidget),
                            isExpanded: $widgetExpanded,
                            cCard: cCard,
                            cText: cText
                        ) {
                            VStack(spacing: 0) {
                                helpFeatureRow(icon: "square.grid.2x2.fill", iconColor: Color(hex: "#a78bfa"), iconBg: Color(hex: "#a78bfa").opacity(0.13), title: t(.helpWidgetTitle), desc: t(.helpWidgetDesc))
                                helpDivider
                                helpFeatureRow(icon: "bell.fill", iconColor: Color(hex: "#fb923c"), iconBg: Color(hex: "#fb923c").opacity(0.13), title: t(.helpNotifTitle), desc: t(.helpNotifDesc))
                            }
                        }
                        AccordionSection(
                            icon: "lightbulb.fill",
                            iconColor: Color(hex: "#fbbf24"),
                            iconBgColor: Color(hex: "#ca8a04").opacity(0.13),
                            title: t(.helpSectionTips),
                            isExpanded: $tipsExpanded,
                            cCard: cCard,
                            cText: cText
                        ) {
                            VStack(alignment: .leading, spacing: 4) {
                                helpTipRow(text: t(.helpTip1))
                                helpTipRow(text: t(.helpTip2))
                                helpTipRow(text: t(.helpTip3))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(t(.helpTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(t(.cancelButton)) { dismiss() }
                        .foregroundColor(cAccent)
                        .bold()
                }
            }
        }
        .preferredColorScheme(nil)
    }

    private var helpDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(height: 1)
            .padding(.horizontal, 14)
    }

    private func helpStepRow(num: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#F5C800"))
                    .frame(width: 20, height: 20)
                Text(num)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(Color(hex: "#111111"))
            }
            .padding(.top, 1)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.pretendard(.semibold, size: 13))
                    .foregroundColor(cText)
                Text(desc)
                    .font(.pretendard(.regular, size: 12))
                    .foregroundColor(cSub)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func helpFeatureRow(icon: String, iconColor: Color, iconBg: Color, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(iconBg)
                    .frame(width: 24, height: 24)
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            .padding(.top, 1)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.pretendard(.semibold, size: 13))
                    .foregroundColor(cText)
                Text(desc)
                    .font(.pretendard(.regular, size: 12))
                    .foregroundColor(cSub)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func helpTipRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color(hex: "#F5C800"))
                .frame(width: 5, height: 5)
                .padding(.top, 5)
            Text(text)
                .font(.pretendard(.regular, size: 12))
                .foregroundColor(cSub)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}
```

- [ ] **Step 2: Verify no remaining `helpContent` usage in ContentView**

```bash
grep -n "helpContent" code/MotivationRun/ContentView.swift
```
Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add code/MotivationRun/ContentView.swift
git commit -m "feat: rewrite HelpView with accordion layout"
```

---

### Task 10: Build and visual verification

**Files:** none

- [ ] **Step 1: Open Xcode and build**

Open `code/MotivationRun.xcodeproj` in Xcode. Press **Cmd+B**.

Expected: Build Succeeded with zero errors. If there are errors:
- `Value of type 'HelpView' has no member 'helpContent'` — a stale reference somewhere; search for `helpContent` in the project and remove it
- `Use of unresolved identifier 'AccordionSection'` — the struct was placed inside another struct's scope; verify it's at file scope, not nested inside `HelpView`
- `Extra argument 'cSub' in call` — the `AccordionSection` init doesn't take `cSub`; verify row helpers use `self.cSub` from `HelpView`, not from `AccordionSection`

- [ ] **Step 2: Run on simulator and open HelpView**

Run on any iOS 16+ simulator. In the app: tap **Settings** tab → tap the **?** button (top-right). Verify:
- 4 accordion sections appear, all collapsed
- Tapping a header expands it with chevron rotation animation
- Tapping again collapses
- Multiple sections can be open simultaneously
- Content rows show title (bold) on line 1, description (gray) on line 2
- 시작하기: yellow numbered circles
- 기본 기능 / 위젯&알림: colored SF Symbol icon boxes
- 도움말: yellow dot bullets

- [ ] **Step 3: Switch language to Korean and re-verify**

Settings → Language → 한국어. Open Help again. Verify Korean strings appear in each row.

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "feat: HelpView accordion redesign complete"
```
