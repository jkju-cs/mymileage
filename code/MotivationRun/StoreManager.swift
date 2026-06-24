//
//  StoreManager.swift
//  MotivationRun
//
//  StoreKit 2 기반 Pro 일회성 구매 관리
//

import Foundation
import StoreKit

@MainActor
final class StoreManager: ObservableObject {
    static let shared = StoreManager()
    private init() {}

    static let proProductID = "com.jangkyuju.motivationrun.pro"

    @Published private(set) var isPro: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return SharedDataManager.shared.getIsPro()
        #endif
    }()
    @Published private(set) var proProduct: Product?
    @Published private(set) var purchaseInProgress: Bool = false

    private var transactionListener: Task<Void, Never>?

    // MARK: - 초기화

    func start() {
        print("🚀 [StoreManager] start() 호출됨 | isPro: \(isPro)")
        transactionListener = listenForTransactions()
        Task { await loadProduct() }
        #if !targetEnvironment(simulator)
        Task { await refreshPurchaseStatus() }
        #endif
    }

    // MARK: - 상품 로드

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.proProductID])
            proProduct = products.first
        } catch {
            print("❌ [StoreManager] 상품 로드 실패: \(error)")
        }
    }

    // MARK: - 구매

    func purchasePro() async -> Bool {
        guard let product = proProduct else { return false }
        purchaseInProgress = true
        defer { purchaseInProgress = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                setProStatus(true)
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            print("❌ [StoreManager] 구매 실패: \(error)")
            return false
        }
    }

    // MARK: - 구매 복원

    func restorePurchases() async {
        try? await AppStore.sync()
        // 명시적 복원 시에는 엔타이틀먼트 없으면 Pro 해제 (사용자 의도)
        var foundPro = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == Self.proProductID {
                setProStatus(true)
                foundPro = true
                break
            }
        }
        if !foundPro { setProStatus(false) }
    }

    // MARK: - 구매 상태 확인

    func refreshPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == Self.proProductID {
                setProStatus(true)
                return
            }
        }
        // StoreKit이 엔타이틀먼트를 반환하지 않을 때 네트워크 오류와 실제 미구매를 구분할 수 없으므로
        // 캐시된 Pro 상태를 유지 — 사용자가 명시적으로 '구매 복원'을 해야만 false로 전환
    }

    // MARK: - 트랜잭션 리스너

    private func listenForTransactions() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                if let transaction = try? checkVerified(result),
                   transaction.productID == Self.proProductID {
                    await transaction.finish()
                    setProStatus(true)
                }
            }
        }
    }

    // MARK: - 헬퍼

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let value):      return value
        }
    }

    private func setProStatus(_ value: Bool) {
        isPro = value
        SharedDataManager.shared.saveIsPro(value)
    }
}
