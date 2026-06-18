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
        #if DEBUG
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
        #if !DEBUG
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
        await refreshPurchaseStatus()
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
        // entitlement 없으면 무료 상태
        setProStatus(false)
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
