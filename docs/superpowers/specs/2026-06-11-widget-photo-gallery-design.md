# Widget Photo Gallery — Design Spec
Date: 2026-06-11

## Overview

위젯 배경 사진 선택 플로우에 갤러리 중간 화면을 추가한다. 기존에는 Settings에서 바로 PhotosPicker로 진입했지만, 이제는 갤러리 화면을 거쳐 이전에 저장한 사진을 재사용하거나 새 사진을 추가할 수 있다.

## User Flow

**변경 전:**
```
Settings → PhotosPicker → 크롭 → widget_bg.jpg 저장
```

**변경 후:**
```
Settings → [NavigationLink] → PhotoGalleryView
  ├─ "신규 사진 추가" 탭 → PhotosPicker → 크롭 → 갤러리 원본 저장 + widget_bg.jpg 저장
  ├─ 갤러리 사진 탭 → 크롭 재진입 → widget_bg.jpg 저장
  └─ [편집] → 개별 사진 삭제
```

## Storage Architecture

### 파일 구조 (App Group 컨테이너)
```
<AppGroup>/
  widget_bg.jpg          — 현재 위젯 적용 크롭 이미지 (기존, 변경 없음)
  widget_gallery/
    gallery_<uuid>.jpg   — 원본 이미지 (최대 10장)
```

### UserDefaults 키 (App Group)
| 키 | 타입 | 설명 |
|---|---|---|
| `galleryImageIDs` | `[String]` (JSON) | 저장 순서 보존용 UUID 배열 |
| `hasWidgetBgImage` | `Bool` | 기존 키, 변경 없음 |
| `widgetBgIsDark` | `Bool` | 기존 키, 변경 없음 |

### 이미지 저장 정책
- 갤러리 원본: 최대 1200px 리사이즈, JPEG 0.8 품질 (위젯 bg보다 고품질 유지)
- 위젯 bg (`widget_bg.jpg`): 기존 800px, JPEG 0.7 유지

## Components

### 1. SharedDataManager 확장

새 섹션 `// MARK: - Widget Photo Gallery` 추가:

```swift
func saveGalleryImage(_ image: UIImage) -> String?
// UUID 생성 → 파일 저장 → galleryImageIDs 앞에 추가 → UUID 반환
// 10장 초과 시 nil 반환

func loadGalleryImages() -> [(id: String, image: UIImage)]
// galleryImageIDs 순서대로 파일 로드, 파일 없는 ID는 자동 제거

func deleteGalleryImage(id: String)
// 파일 삭제 → galleryImageIDs에서 제거

var galleryCount: Int
// galleryImageIDs.count

func setActiveGalleryID(_ id: String?)
// userDefaults?.set(id, forKey: "activeGalleryID")

func getActiveGalleryID() -> String?
// userDefaults?.string(forKey: "activeGalleryID")

private var galleryDirectoryURL: URL?
// <AppGroup>/widget_gallery/

private func galleryImageURL(id: String) -> URL?
// <AppGroup>/widget_gallery/gallery_<id>.jpg
```

`resetAll()` 수정: `widget_gallery/` 디렉토리 전체 삭제 + `galleryImageIDs` 키 제거 추가

### 2. PhotoGalleryView (신규 파일: PhotoGalleryView.swift)

**Props:**
- `accentColor: Color`
- `bg: ThemeBackground`
- `language: Language`

**State:**
- `@State private var galleryItems: [(id: String, image: UIImage)]`
- `@State private var isEditMode: Bool`
- `@State private var selectedPhotoItem: PhotosPickerItem?`
- `@State private var pickedRawImage: UIImage?`
- `@State private var showCropSheet: Bool`
- `@State private var cropSourceID: String?` — 갤러리 사진 탭 시 해당 ID 저장 (nil이면 신규 추가)

**Layout:**
```
NavigationBar: "위젯 배경 사진" | [편집/완료]
─────────────────────────────────
[+ 신규 사진 추가] 버튼 (10장이면 비활성화)
─────────────────────────────────
LazyVGrid(3열) {
  ForEach(galleryItems) { item in
    ZStack {
      Image(item.image) // 정사각형 썸네일
      if isEditMode { DeleteButton }
      if item.id == currentActiveID { CheckmarkOverlay }
    }
    .onTapGesture { if !isEditMode { openCrop(item) } }
  }
}
```

**크롭 완료 콜백:**
```
onSave(croppedImage) {
  SharedDataManager.shared.saveWidgetBackgroundImage(croppedImage)
  if cropSourceID == nil {
    // 신규 추가: 원본을 갤러리에 저장
    SharedDataManager.shared.saveGalleryImage(pickedRawImage!)
  }
  // cropSourceID != nil: 기존 갤러리 원본 재사용, 갤러리 저장 불필요
  WidgetCenter.shared.reloadAllTimelines()
  galleryItems = SharedDataManager.shared.loadGalleryImages()
}
```

**현재 적용 중인 사진 식별:**
- `UserDefaults(App Group)`에 `activeGalleryID: String?` 키 추가
- 크롭 완료 시 해당 ID 저장 (신규 추가면 방금 저장한 UUID)
- 삭제 시 해당 ID면 `activeGalleryID` 제거

### 3. SettingsView 변경

**변경 전 (PhotosPicker 직접 노출):**
```swift
PhotosPicker(selection: $selectedPhotoItem, ...) { ... }
if hasWidgetBgImage { /* 삭제 버튼 */ }
```

**변경 후 (NavigationLink):**
```swift
NavigationLink {
    PhotoGalleryView(accentColor: accentColor, bg: background, language: language)
} label: {
    HStack {
        settingsIcon("photo.on.rectangle", Color(hex: "#3478FE"))
        Text(t(.widgetBgSelectPhoto))
        Spacer()
        if let thumb = widgetBgPreview {
            Image(uiImage: thumb)
                .resizable().scaledToFill()
                .frame(width: 36, height: 17).clipped()
                .cornerRadius(4)
        }
        Image(systemName: "chevron.right")
    }
}
```

- `selectedPhotoItem`, `pickedRawImage`, `showCropSheet` State는 SettingsView에서 제거
- `widgetBgPreview`는 유지 (썸네일 표시용)
- "사진 삭제" 버튼은 SettingsView에서 제거 (갤러리에서 처리)

## Localization

`LocalizedStrings.swift`에 추가할 키:

| 키 | 한국어 | 영어 |
|---|---|---|
| `widgetGalleryTitle` | 위젯 배경 사진 | Widget Background |
| `widgetGalleryAddPhoto` | 신규 사진 추가 | Add New Photo |
| `widgetGalleryEditButton` | 편집 | Edit |
| `widgetGalleryDoneButton` | 완료 | Done |
| `widgetGalleryMaxReached` | 최대 10장까지 저장할 수 있습니다 | Up to 10 photos can be saved |
| `widgetGalleryEmpty` | 사진을 추가해보세요 | Add your first photo |

## Edge Cases

| 상황 | 처리 |
|---|---|
| 갤러리 10장 초과 시도 | "신규 사진 추가" 비활성화, 탭 시 토스트 |
| 현재 적용 중인 사진 삭제 | `widget_bg.jpg` + `activeGalleryID` 제거, 위젯 배경 없음 상태 |
| 크롭 취소 | 갤러리 저장 없이 갤러리 화면 복귀 |
| `resetAll()` | `widget_gallery/` 전체 삭제 + `galleryImageIDs`, `activeGalleryID` 키 제거 |
| 갤러리 비어있을 때 | "신규 사진 추가" 버튼만 표시, 빈 상태 안내 텍스트 |
| 파일은 없는데 ID 남아있는 경우 | `loadGalleryImages()` 호출 시 자동 정리 |

## Files Changed

| 파일 | 변경 유형 |
|---|---|
| `SharedDataManager.swift` | 수정 — 갤러리 메서드 추가, `resetAll()` 수정 |
| `ContentView.swift` | 수정 — SettingsView에서 PhotosPicker 제거, NavigationLink 추가 |
| `LocalizedStrings.swift` | 수정 — 갤러리 관련 문자열 추가 |
| `PhotoGalleryView.swift` | 신규 생성 |
| `MotivationRun.xcodeproj` | 수정 — PhotoGalleryView.swift 타겟 추가 |
