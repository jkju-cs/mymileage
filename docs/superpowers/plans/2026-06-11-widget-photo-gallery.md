# Widget Photo Gallery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Settings → 갤러리 중간 화면 → 신규 사진 추가 or 기존 사진 재사용(크롭 후 위젯 적용)

**Architecture:** `SharedDataManager`에 갤러리 CRUD 메서드를 추가하고, 새 `PhotoGalleryView`를 NavigationLink로 연결한다. SettingsView에서 PhotosPicker와 "사진 삭제" 버튼을 제거하고 NavigationLink로 대체. 갤러리 원본 이미지는 App Group 컨테이너의 `widget_gallery/` 디렉토리에 저장, UUID 순서는 `galleryImageIDs` UserDefaults 키로 관리.

**Tech Stack:** SwiftUI, PhotosUI, WidgetKit, FileManager (App Group), UserDefaults (App Group)

---

## File Map

| 파일 | 변경 유형 | 책임 |
|---|---|---|
| `code/MotivationRun/LocalizedStrings.swift` | 수정 | 갤러리 관련 LK 케이스 + 6개 언어 번역 추가 |
| `code/MotivationRun/SharedDataManager.swift` | 수정 | 갤러리 CRUD 메서드, `activeGalleryID` 관리, `resetAll()` 수정 |
| `code/MotivationRun/PhotoGalleryView.swift` | 신규 생성 | 갤러리 UI — 3열 그리드, 편집 모드, 크롭 연결 |
| `code/MotivationRun.xcodeproj/project.pbxproj` | 수정 | `PhotoGalleryView.swift` 메인 앱 타겟에 등록 |
| `code/MotivationRun/ContentView.swift` | 수정 | SettingsView — PhotosPicker → NavigationLink 교체, 불필요 State 제거 |

---

## Task 1: LocalizedStrings — 갤러리 문자열 추가

**Files:**
- Modify: `code/MotivationRun/LocalizedStrings.swift`

- [ ] **Step 1: LK enum에 케이스 6개 추가**

[LocalizedStrings.swift:154](code/MotivationRun/LocalizedStrings.swift#L154) 의 `calRestDay` 케이스 다음에 추가:

```swift
    // Widget photo gallery
    case widgetGalleryTitle
    case widgetGalleryAddPhoto
    case widgetGalleryEdit
    case widgetGalleryDone
    case widgetGalleryMaxReached
    case widgetGalleryEmpty
```

- [ ] **Step 2: English 번역 추가**

[LocalizedStrings.swift:278](code/MotivationRun/LocalizedStrings.swift#L278) `.calRestDay: "Rest day",` 다음에 추가:

```swift
            .widgetGalleryTitle:        "Widget Background",
            .widgetGalleryAddPhoto:     "Add New Photo",
            .widgetGalleryEdit:         "Edit",
            .widgetGalleryDone:         "Done",
            .widgetGalleryMaxReached:   "Up to 10 photos can be saved",
            .widgetGalleryEmpty:        "Add your first photo",
```

- [ ] **Step 3: Korean 번역 추가**

Korean 섹션의 `.calRestDay: "휴식일",` 다음에 추가:

```swift
            .widgetGalleryTitle:        "위젯 배경 사진",
            .widgetGalleryAddPhoto:     "신규 사진 추가",
            .widgetGalleryEdit:         "편집",
            .widgetGalleryDone:         "완료",
            .widgetGalleryMaxReached:   "최대 10장까지 저장할 수 있습니다",
            .widgetGalleryEmpty:        "사진을 추가해보세요",
```

- [ ] **Step 4: German 번역 추가**

German 섹션의 `.calRestDay: "Ruhetag",` 다음에 추가:

```swift
            .widgetGalleryTitle:        "Widget-Hintergrund",
            .widgetGalleryAddPhoto:     "Neues Foto hinzufügen",
            .widgetGalleryEdit:         "Bearbeiten",
            .widgetGalleryDone:         "Fertig",
            .widgetGalleryMaxReached:   "Bis zu 10 Fotos können gespeichert werden",
            .widgetGalleryEmpty:        "Füge dein erstes Foto hinzu",
```

- [ ] **Step 5: French 번역 추가**

French 섹션의 `.calRestDay: "Jour de repos",` 다음에 추가:

```swift
            .widgetGalleryTitle:        "Fond du widget",
            .widgetGalleryAddPhoto:     "Ajouter une nouvelle photo",
            .widgetGalleryEdit:         "Modifier",
            .widgetGalleryDone:         "Terminé",
            .widgetGalleryMaxReached:   "Vous pouvez enregistrer jusqu'à 10 photos",
            .widgetGalleryEmpty:        "Ajoutez votre première photo",
```

- [ ] **Step 6: Chinese 번역 추가**

Chinese 섹션의 `.calRestDay: "休息日",` 다음에 추가:

```swift
            .widgetGalleryTitle:        "小组件背景",
            .widgetGalleryAddPhoto:     "添加新照片",
            .widgetGalleryEdit:         "编辑",
            .widgetGalleryDone:         "完成",
            .widgetGalleryMaxReached:   "最多可保存10张照片",
            .widgetGalleryEmpty:        "添加您的第一张照片",
```

- [ ] **Step 7: Spanish 번역 추가**

Spanish 섹션의 `.calRestDay: "Día de descanso",` 다음에 추가:

```swift
            .widgetGalleryTitle:        "Fondo del widget",
            .widgetGalleryAddPhoto:     "Agregar nueva foto",
            .widgetGalleryEdit:         "Editar",
            .widgetGalleryDone:         "Listo",
            .widgetGalleryMaxReached:   "Se pueden guardar hasta 10 fotos",
            .widgetGalleryEmpty:        "Agrega tu primera foto",
```

- [ ] **Step 8: Commit**

```bash
git -C /Users/jkju/app_dev_motivationRun add code/MotivationRun/LocalizedStrings.swift
git -C /Users/jkju/app_dev_motivationRun commit -m "feat: add gallery localization strings (6 languages)"
```

---

## Task 2: SharedDataManager — 갤러리 CRUD 추가

**Files:**
- Modify: `code/MotivationRun/SharedDataManager.swift`

- [ ] **Step 1: 갤러리 MARK 섹션 및 헬퍼 프로퍼티 추가**

[SharedDataManager.swift:160](code/MotivationRun/SharedDataManager.swift#L160) 의 `// MARK: - Widget Background Image` 블록 앞에 새 섹션 추가:

```swift
    // MARK: - Widget Photo Gallery

    private var galleryDirectoryURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("widget_gallery", isDirectory: true)
    }

    private func galleryImageURL(id: String) -> URL? {
        galleryDirectoryURL?.appendingPathComponent("gallery_\(id).jpg")
    }

    private func ensureGalleryDirectoryExists() {
        guard let dir = galleryDirectoryURL else { return }
        guard !FileManager.default.fileExists(atPath: dir.path) else { return }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    private var galleryImageIDs: [String] {
        get {
            guard let data = userDefaults?.data(forKey: "galleryImageIDs"),
                  let ids = try? JSONDecoder().decode([String].self, from: data) else { return [] }
            return ids
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            userDefaults?.set(data, forKey: "galleryImageIDs")
        }
    }

    var galleryCount: Int { galleryImageIDs.count }

    @discardableResult
    func saveGalleryImage(_ image: UIImage) -> String? {
        guard galleryCount < 10 else { return nil }
        ensureGalleryDirectoryExists()
        let id = UUID().uuidString
        guard let url = galleryImageURL(id: id) else { return nil }
        let resized = image.resizedToFit(maxDimension: 1200)
        guard let data = resized.jpegData(compressionQuality: 0.8) else { return nil }
        try? data.write(to: url, options: .atomic)
        var ids = galleryImageIDs
        ids.insert(id, at: 0)
        galleryImageIDs = ids
        return id
    }

    func loadGalleryImages() -> [(id: String, image: UIImage)] {
        let ids = galleryImageIDs
        var result: [(id: String, image: UIImage)] = []
        var orphanedIDs: [String] = []
        for id in ids {
            guard let url = galleryImageURL(id: id),
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                orphanedIDs.append(id)
                continue
            }
            result.append((id: id, image: image))
        }
        if !orphanedIDs.isEmpty {
            galleryImageIDs = result.map { $0.id }
        }
        return result
    }

    func deleteGalleryImage(id: String) {
        if let url = galleryImageURL(id: id) {
            try? FileManager.default.removeItem(at: url)
        }
        galleryImageIDs = galleryImageIDs.filter { $0 != id }
    }

    func setActiveGalleryID(_ id: String?) {
        if let id = id {
            userDefaults?.set(id, forKey: "activeGalleryID")
        } else {
            userDefaults?.removeObject(forKey: "activeGalleryID")
        }
    }

    func getActiveGalleryID() -> String? {
        userDefaults?.string(forKey: "activeGalleryID")
    }

```

- [ ] **Step 2: resetAll()에 갤러리 정리 추가**

[SharedDataManager.swift:235](code/MotivationRun/SharedDataManager.swift#L235) 의 `func resetAll()` 메서드를 수정:

현재 코드:
```swift
    func resetAll() {
        let keys = ["monthlyStats", "goalType", "goalTarget", "runFrequency",
                    "themeAccent", "themeBackground", "distanceUnit",
                    "notificationSettings", "hasWidgetBgImage",
                    "widgetBgIsDark", "widgetDesign", "workoutSourcePreference"]
        keys.forEach { userDefaults?.removeObject(forKey: $0) }
        if let url = widgetBgImageURL { try? FileManager.default.removeItem(at: url) }
        UserDefaults.standard.removeObject(forKey: "hkAuthRequested")
        print("🗑️ [SharedDataManager] 전체 데이터 초기화 완료")
    }
```

수정 후:
```swift
    func resetAll() {
        let keys = ["monthlyStats", "goalType", "goalTarget", "runFrequency",
                    "themeAccent", "themeBackground", "distanceUnit",
                    "notificationSettings", "hasWidgetBgImage",
                    "widgetBgIsDark", "widgetDesign", "workoutSourcePreference",
                    "galleryImageIDs", "activeGalleryID"]
        keys.forEach { userDefaults?.removeObject(forKey: $0) }
        if let url = widgetBgImageURL { try? FileManager.default.removeItem(at: url) }
        if let dir = galleryDirectoryURL { try? FileManager.default.removeItem(at: dir) }
        UserDefaults.standard.removeObject(forKey: "hkAuthRequested")
        print("🗑️ [SharedDataManager] 전체 데이터 초기화 완료")
    }
```

- [ ] **Step 3: Commit**

```bash
git -C /Users/jkju/app_dev_motivationRun add code/MotivationRun/SharedDataManager.swift
git -C /Users/jkju/app_dev_motivationRun commit -m "feat: add widget photo gallery CRUD to SharedDataManager"
```

---

## Task 3: PhotoGalleryView.swift 신규 생성

**Files:**
- Create: `code/MotivationRun/PhotoGalleryView.swift`

- [ ] **Step 1: 파일 생성**

`code/MotivationRun/PhotoGalleryView.swift` 를 아래 내용으로 생성:

```swift
//
//  PhotoGalleryView.swift
//  MotivationRun
//

import SwiftUI
import PhotosUI
import WidgetKit

struct PhotoGalleryView: View {
    let accentColor: Color
    let bg: ThemeBackground
    let language: AppLanguage

    @State private var galleryItems: [(id: String, image: UIImage)] = []
    @State private var isEditMode: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var pickedRawImage: UIImage?
    @State private var showCropSheet: Bool = false
    @State private var cropSourceID: String? = nil
    @State private var activeGalleryID: String? = SharedDataManager.shared.getActiveGalleryID()
    @State private var isShowingToast: Bool = false
    @State private var toastMessage: String = ""

    private func t(_ key: LK) -> String { L(key, language) }

    private let gridColumns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            bg.appBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    addPhotoButton
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    if galleryItems.isEmpty {
                        Text(t(.widgetGalleryEmpty))
                            .font(.pretendard(.regular, size: 14))
                            .foregroundColor(bg.subText)
                            .padding(.top, 48)
                    } else {
                        LazyVGrid(columns: gridColumns, spacing: 4) {
                            ForEach(galleryItems, id: \.id) { item in
                                galleryCell(item: item)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 40)
                }
            }

            if isShowingToast {
                Text(toastMessage)
                    .font(.pretendard(.regular, size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(Color.black.opacity(0.78))
                    .cornerRadius(24)
                    .padding(.bottom, 32)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isShowingToast)
        .navigationTitle(t(.widgetGalleryTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditMode ? t(.widgetGalleryDone) : t(.widgetGalleryEdit)) {
                    withAnimation { isEditMode.toggle() }
                }
                .font(.pretendard(.regular, size: 16))
                .foregroundColor(accentColor)
                .disabled(galleryItems.isEmpty)
            }
        }
        .sheet(isPresented: $showCropSheet) {
            if let rawImage = pickedRawImage {
                WidgetImageCropView(image: rawImage, accentColor: accentColor, language: language) { croppedImage in
                    SharedDataManager.shared.saveWidgetBackgroundImage(croppedImage)
                    WidgetCenter.shared.reloadAllTimelines()
                    if cropSourceID == nil {
                        if let newID = SharedDataManager.shared.saveGalleryImage(pickedRawImage!) {
                            SharedDataManager.shared.setActiveGalleryID(newID)
                            activeGalleryID = newID
                        }
                    } else {
                        SharedDataManager.shared.setActiveGalleryID(cropSourceID)
                        activeGalleryID = cropSourceID
                    }
                    galleryItems = SharedDataManager.shared.loadGalleryImages()
                    displayToast(L(.widgetBgSaved, language))
                }
            }
        }
        .onAppear {
            galleryItems = SharedDataManager.shared.loadGalleryImages()
            activeGalleryID = SharedDataManager.shared.getActiveGalleryID()
        }
    }

    @ViewBuilder
    private var addPhotoButton: some View {
        let isFull = galleryItems.count >= 10
        Group {
            if isFull {
                Button {
                    displayToast(t(.widgetGalleryMaxReached))
                } label: {
                    addPhotoLabel(isFull: true)
                }
                .buttonStyle(.plain)
            } else {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    addPhotoLabel(isFull: false)
                }
                .onChange(of: selectedPhotoItem) {
                    guard let item = selectedPhotoItem else { return }
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let img = UIImage(data: data) {
                            await MainActor.run {
                                pickedRawImage = img.normalizedOrientation()
                                cropSourceID = nil
                                selectedPhotoItem = nil
                                showCropSheet = true
                            }
                        }
                    }
                }
            }
        }
    }

    private func addPhotoLabel(isFull: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "plus")
                .font(.system(size: 15, weight: .semibold))
            Text(t(.widgetGalleryAddPhoto))
                .font(.pretendard(.semiBold, size: 16))
        }
        .foregroundColor(isFull ? bg.inkOff : accentColor)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(bg.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isFull ? bg.inkOff.opacity(0.3) : accentColor.opacity(0.4),
                            lineWidth: 1.5
                        )
                )
        )
    }

    @ViewBuilder
    private func galleryCell(item: (id: String, image: UIImage)) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Image(uiImage: item.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.width)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard !isEditMode else { return }
                        pickedRawImage = item.image
                        cropSourceID = item.id
                        showCropSheet = true
                    }

                if item.id == activeGalleryID {
                    ZStack {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(6)
                }

                if isEditMode {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                deleteItem(id: item.id)
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "#EF4444"))
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "minus")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(6)
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(8)
    }

    private func deleteItem(id: String) {
        SharedDataManager.shared.deleteGalleryImage(id: id)
        if id == activeGalleryID {
            SharedDataManager.shared.removeWidgetBackgroundImage()
            SharedDataManager.shared.setActiveGalleryID(nil)
            activeGalleryID = nil
            WidgetCenter.shared.reloadAllTimelines()
        }
        withAnimation {
            galleryItems = SharedDataManager.shared.loadGalleryImages()
            if galleryItems.isEmpty { isEditMode = false }
        }
    }

    private func displayToast(_ msg: String) {
        toastMessage = msg
        withAnimation { isShowingToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { isShowingToast = false }
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git -C /Users/jkju/app_dev_motivationRun add code/MotivationRun/PhotoGalleryView.swift
git -C /Users/jkju/app_dev_motivationRun commit -m "feat: add PhotoGalleryView for widget background photo gallery"
```

---

## Task 4: Xcode 프로젝트에 PhotoGalleryView.swift 등록

**Files:**
- Modify: `code/MotivationRun.xcodeproj/project.pbxproj`

- [ ] **Step 1: PBXBuildFile 섹션에 빌드 파일 항목 추가**

`project.pbxproj` 의 `/* End PBXBuildFile section */` 바로 위 (line 44 근처), 현재 마지막 항목인:
```
		AABBCC001122334455667741 /* ModernComponents.swift in Sources */ = {isa = PBXBuildFile; fileRef = AABBCC001122334455667740 /* ModernComponents.swift */; };
```
다음에 추가:

```
		AABBCC001122334455667743 /* PhotoGalleryView.swift in Sources */ = {isa = PBXBuildFile; fileRef = AABBCC001122334455667742 /* PhotoGalleryView.swift */; };
```

- [ ] **Step 2: PBXFileReference 섹션에 파일 참조 추가**

`/* End PBXFileReference section */` 바로 위 (line 122 근처), 현재 마지막 항목인:
```
		AABBCC001122334455667740 /* ModernComponents.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ModernComponents.swift; sourceTree = "<group>"; };
```
다음에 추가:

```
		AABBCC001122334455667742 /* PhotoGalleryView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PhotoGalleryView.swift; sourceTree = "<group>"; };
```

- [ ] **Step 3: PBXGroup (MotivationRun 그룹)에 파일 추가**

`66B64BD82F3B54AD0046DB87 /* MotivationRun */` 그룹 children 안에서 `ModernComponents.swift` 항목 다음에 추가:

현재:
```
			AABBCC001122334455667740 /* ModernComponents.swift */,
```
다음에 추가:
```
			AABBCC001122334455667742 /* PhotoGalleryView.swift */,
```

- [ ] **Step 4: PBXSourcesBuildPhase (메인 앱 타겟)에 빌드 파일 추가**

`66B64BD22F3B54AD0046DB87 /* Sources */` 빌드 페이즈 files 안에서 `ModernComponents.swift in Sources` 항목 다음에 추가:

현재:
```
				AABBCC001122334455667741 /* ModernComponents.swift in Sources */,
```
다음에 추가:
```
				AABBCC001122334455667743 /* PhotoGalleryView.swift in Sources */,
```

- [ ] **Step 5: Commit**

```bash
git -C /Users/jkju/app_dev_motivationRun add "code/MotivationRun.xcodeproj/project.pbxproj"
git -C /Users/jkju/app_dev_motivationRun commit -m "chore: register PhotoGalleryView.swift in Xcode project"
```

---

## Task 5: ContentView.swift — SettingsView 수정

**Files:**
- Modify: `code/MotivationRun/ContentView.swift`

- [ ] **Step 1: SettingsView State 변수 정리**

[ContentView.swift:997-1001](code/MotivationRun/ContentView.swift#L997-L1001) 에서 불필요한 State 제거.

현재:
```swift
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var hasWidgetBgImage: Bool = SharedDataManager.shared.hasWidgetBackgroundImage()
    @State private var widgetBgPreview: UIImage? = SharedDataManager.shared.loadWidgetBackgroundImage()
    @State private var pickedRawImage: UIImage?
    @State private var showCropSheet: Bool = false
```

수정 후:
```swift
    @State private var widgetBgPreview: UIImage? = SharedDataManager.shared.loadWidgetBackgroundImage()
```

(`selectedPhotoItem`, `hasWidgetBgImage`, `pickedRawImage`, `showCropSheet` 제거. `widgetBgPreview`만 유지)

- [ ] **Step 2: NavigationView ZStack에 onAppear 추가 (갤러리 복귀 시 썸네일 갱신)**

[ContentView.swift:1081](code/MotivationRun/ContentView.swift#L1081) 의 `ZStack {` 블록에 `.onAppear` 추가.

`background.appBg.ignoresSafeArea()` 바로 다음에 오는 형제 modifier가 아닌, ZStack closing brace 직전에 modifier 추가. ZStack 전체가 끝나는 지점 (`.navigationTitle("Settings")` 바로 위) 에 추가:

현재 (line 1561):
```swift
            .navigationTitle("Settings")
```

위에 추가:
```swift
            .onAppear {
                widgetBgPreview = SharedDataManager.shared.loadWidgetBackgroundImage()
            }
            .navigationTitle("Settings")
```

- [ ] **Step 3: Widget 섹션의 PhotosPicker + 삭제 버튼 → NavigationLink로 교체**

[ContentView.swift:1278-1341](code/MotivationRun/ContentView.swift#L1278-L1341) 의 `if storeManager.isPro { ... } else { ... }` 블록 전체를 교체.

현재 (`rowDivider` 다음부터 `}` 닫는 괄호 직전까지):
```swift
                                if storeManager.isPro {
                                    rowDivider
                                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                        HStack(spacing: 12) {
                                            settingsIcon("photo.on.rectangle", Color(hex: "#3478FE"))
                                            Text(t(.widgetBgSelectPhoto))
                                                .font(.pretendard(.regular, size: 16))
                                                .foregroundColor(background.mainText)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 14).padding(.vertical, 13)
                                    }
                                    .onChange(of: selectedPhotoItem) {
                                        guard let item = selectedPhotoItem else { return }
                                        Task {
                                            if let data = try? await item.loadTransferable(type: Data.self),
                                               let img = UIImage(data: data) {
                                                await MainActor.run {
                                                    pickedRawImage = img.normalizedOrientation()
                                                    selectedPhotoItem = nil
                                                    showCropSheet = true
                                                }
                                            }
                                        }
                                    }
                                    if hasWidgetBgImage {
                                        rowDivider
                                        Button(action: {
                                            SharedDataManager.shared.removeWidgetBackgroundImage()
                                            widgetBgPreview = nil
                                            hasWidgetBgImage = false
                                            selectedPhotoItem = nil
                                            WidgetCenter.shared.reloadAllTimelines()
                                            showSettingsToast(t(.widgetBgRemoved))
                                        }) {
                                            HStack(spacing: 12) {
                                                settingsIcon("trash", Color(hex: "#EF4444"))
                                                Text(t(.widgetBgRemovePhoto))
                                                    .font(.pretendard(.regular, size: 16))
                                                    .foregroundColor(Color(hex: "#EF4444"))
                                                Spacer()
                                            }
                                            .padding(.horizontal, 14).padding(.vertical, 13)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                } else {
                                    rowDivider
                                    HStack(spacing: 12) {
                                        settingsIcon("photo.on.rectangle", Color(hex: "#3478FE"))
                                        Text(t(.widgetBgSelectPhoto))
                                            .font(.pretendard(.regular, size: 16))
                                            .foregroundColor(background.mainText)
                                        Spacer()
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(background.inkOff)
                                        Text("Pro")
                                            .font(.pretendard(.semiBold, size: 12))
                                            .foregroundColor(accentColor)
                                    }
                                    .padding(.horizontal, 14).padding(.vertical, 13)
                                    .opacity(0.65)
                                }
```

수정 후:
```swift
                                if storeManager.isPro {
                                    rowDivider
                                    NavigationLink {
                                        PhotoGalleryView(
                                            accentColor: accentColor,
                                            bg: background,
                                            language: language
                                        )
                                    } label: {
                                        HStack(spacing: 12) {
                                            settingsIcon("photo.on.rectangle", Color(hex: "#3478FE"))
                                            Text(t(.widgetBgSelectPhoto))
                                                .font(.pretendard(.regular, size: 16))
                                                .foregroundColor(background.mainText)
                                            Spacer()
                                            if let thumb = widgetBgPreview {
                                                Image(uiImage: thumb)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 36, height: 17)
                                                    .clipped()
                                                    .cornerRadius(4)
                                            }
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(background.inkOff)
                                        }
                                        .padding(.horizontal, 14).padding(.vertical, 13)
                                    }
                                } else {
                                    rowDivider
                                    HStack(spacing: 12) {
                                        settingsIcon("photo.on.rectangle", Color(hex: "#3478FE"))
                                        Text(t(.widgetBgSelectPhoto))
                                            .font(.pretendard(.regular, size: 16))
                                            .foregroundColor(background.mainText)
                                        Spacer()
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(background.inkOff)
                                        Text("Pro")
                                            .font(.pretendard(.semiBold, size: 12))
                                            .foregroundColor(accentColor)
                                    }
                                    .padding(.horizontal, 14).padding(.vertical, 13)
                                    .opacity(0.65)
                                }
```

- [ ] **Step 4: showCropSheet sheet modifier 제거**

[ContentView.swift:1598-1608](code/MotivationRun/ContentView.swift#L1598-L1608) 의 `.sheet(isPresented: $showCropSheet)` 블록 전체 삭제:

```swift
            .sheet(isPresented: $showCropSheet) {
                if let rawImage = pickedRawImage {
                    WidgetImageCropView(image: rawImage, accentColor: accentColor, language: language) { croppedImage in
                        SharedDataManager.shared.saveWidgetBackgroundImage(croppedImage)
                        widgetBgPreview = SharedDataManager.shared.loadWidgetBackgroundImage()
                        hasWidgetBgImage = true
                        WidgetCenter.shared.reloadAllTimelines()
                        showSettingsToast(t(.widgetBgSaved))
                    }
                }
            }
```

이 블록만 삭제 (나머지 sheet modifier 두 개는 유지).

- [ ] **Step 5: Commit**

```bash
git -C /Users/jkju/app_dev_motivationRun add code/MotivationRun/ContentView.swift
git -C /Users/jkju/app_dev_motivationRun commit -m "feat: replace photo picker with gallery NavigationLink in SettingsView"
```

---

## Task 6: 빌드 검증

**Files:** 없음 (검증만)

- [ ] **Step 1: xcodebuild로 컴파일 오류 확인**

```bash
cd /Users/jkju/app_dev_motivationRun/code && xcodebuild \
  -scheme MotivationRun \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet \
  build 2>&1 | tail -30
```

Expected: `** BUILD SUCCEEDED **`

오류 발생 시: 에러 메시지를 읽고 해당 파일을 수정 후 다시 빌드.

- [ ] **Step 2: 빌드 성공 확인 후 최종 커밋 (오류 수정이 있을 경우에만)**

```bash
git -C /Users/jkju/app_dev_motivationRun add -A
git -C /Users/jkju/app_dev_motivationRun commit -m "fix: resolve build errors from gallery integration"
```

빌드가 처음부터 성공하면 이 단계는 건너뜀.

---

## 주요 주의사항

1. **`pickedRawImage!` 강제 언래핑**: Task 3 PhotoGalleryView의 crop 콜백에서 `cropSourceID == nil`일 때만 `saveGalleryImage(pickedRawImage!)`를 호출. 이 시점에 `pickedRawImage`는 반드시 non-nil (crop sheet가 열릴 때 설정됨).

2. **`galleryImageIDs` computed property**: `get`/`set` 양쪽이 App Group UserDefaults를 사용. `userDefaults`가 nil이면 get은 `[]` 반환, set은 아무 동작 없음 — 안전.

3. **onAppear 위치**: SettingsView의 `ZStack`이 아니라 NavigationView 내부 컨텐츠에 붙여야 NavigationLink pop 시 발화함.

4. **widgetBgPreview thumbnail 비율**: 위젯 배경 비율 360:169 → `frame(width: 36, height: 17)` 사용.
