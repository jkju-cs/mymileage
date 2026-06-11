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

    private static let gridColumns = [
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
                        LazyVGrid(columns: Self.gridColumns, spacing: 4) {
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
                    if cropSourceID == nil {
                        if let newID = SharedDataManager.shared.saveGalleryImage(rawImage) {
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
            WidgetCenter.shared.reloadAllTimelines()
            activeGalleryID = nil
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
