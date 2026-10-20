import Foundation
import StoreKit
import Observation

/// Loads the three products, works out trial eligibility, and runs purchase / restore with StoreKit 2.
/// Prices always come from StoreKit (SPEC.md §4). The fallback prices are only used in previews.
@MainActor
@Observable
public final class PaywallStore {

    public enum Mode { case live, preview }

    // UI state
    var selected: Plan = .yearly
    private(set) var isLoaded = false
    private(set) var isPurchasing = false
    private(set) var trial: TrialInfo?          // nil = no trial (not eligible / no offer)

    let config: PaywallConfig
    private let mode: Mode
    private var products: [Plan: Product] = [:]
    private var prices: [Plan: PlanPrice]

    public init(config: PaywallConfig = PaywallConfig(), mode: Mode = .live) {
        self.config = config
        self.mode = mode
        self.prices = Self.fallbackPrices
        if mode == .preview {
            trial = TrialInfo(value: 3, unit: .day)
            isLoaded = true
        }
    }

    /// Shown in previews and as placeholders while StoreKit loads.
    private static let fallbackPrices: [Plan: PlanPrice] = {
        let usd = Decimal.FormatStyle.Currency(code: "USD")
        func p(_ v: Decimal) -> PlanPrice { PlanPrice(price: v, displayPrice: v.formatted(usd), format: usd) }
        return [.weekly: p(3.99), .yearly: p(29.99), .lifetime: p(44.99)]
    }()

    var showsTrial: Bool { trial != nil }

    // MARK: Loading

    func load() async {
        guard mode == .live, !isLoaded else { return }
        do {
            let loaded = try await Product.products(for: config.allIDs)
            for plan in Plan.allCases {
                guard let product = loaded.first(where: { $0.id == config.id(for: plan) }) else { continue }
                products[plan] = product
                prices[plan] = PlanPrice(price: product.price,
                                         displayPrice: product.displayPrice,
                                         format: product.priceFormatStyle)
            }
            trial = await Self.trialInfo(for: products[.yearly])
        } catch {
            // Keep placeholder prices visible; purchase will report the error.
        }
        isLoaded = true
    }

    private static func trialInfo(for product: Product?) async -> TrialInfo? {
        guard let sub = product?.subscription,
              let offer = sub.introductoryOffer,
              offer.paymentMode == .freeTrial,
              await sub.isEligibleForIntroOffer else { return nil }
        let unit: TrialInfo.Unit
        switch offer.period.unit {
        case .day: unit = .day
        case .week: unit = .week
        case .month: unit = .month
        case .year: unit = .year
        @unknown default: unit = .day
        }
        return TrialInfo(value: offer.period.value, unit: unit)
    }

    // MARK: Copy (SPEC.md §4)

    /// "SAVE 85%": 1 − yearly / (weekly × 52), rounded down.
    var savingsPercent: Int? {
        guard let w = prices[.weekly]?.price, let y = prices[.yearly]?.price, w > 0 else { return nil }
        let ratio = NSDecimalNumber(decimal: 1 - y / (w * 52)).doubleValue
        let pct = Int((ratio * 100).rounded(.down))
        return pct > 0 ? pct : nil
    }

    func copy(for plan: Plan) -> PlanCopy {
        let price = prices[plan]?.displayPrice ?? ""
        switch plan {
        case .weekly:
            return PlanCopy(title: plan.title, price: price, unit: "per week", badge: nil,
                            caption: "WEEK BY WEEK · CANCEL ANYTIME",
                            cta: "Subscribe for \(price)/week",
                            reassurance: "Cancel anytime",
                            legal: "\(price) per week. Renews automatically until you cancel in Settings.")
        case .yearly:
            let perWeek = prices[.yearly].map { $0.formatted($0.price / 52) } ?? ""
            let save = savingsPercent.map { " · SAVE \($0)%" } ?? ""
            if let trial {
                return PlanCopy(title: plan.title, price: price, unit: "\(perWeek) a week",
                                badge: "\(trial.long.uppercased()) FREE",
                                caption: "\(trial.long.uppercased()) FREE, THEN \(price)/YEAR\(save)",
                                cta: "Try \(trial.long) free",
                                reassurance: "No payment now · Cancel anytime",
                                legal: "Then \(price) a year after \(trial.long). Renews until you cancel in Settings.")
            }
            return PlanCopy(title: plan.title, price: price, unit: "\(perWeek) a week", badge: nil,
                            caption: "BEST VALUE\(save)",
                            cta: "Subscribe for \(price)/year",
                            reassurance: "Cancel anytime",
                            legal: "\(price) per year. Renews automatically until you cancel in Settings.")
        case .lifetime:
            return PlanCopy(title: plan.title, price: price, unit: "pay once", badge: nil,
                            caption: "YOURS FOREVER · NOTHING RENEWS",
                            cta: "Buy once for \(price)",
                            reassurance: "One payment · No subscription",
                            legal: "Nothing renews and there is nothing to cancel.")
        }
    }

    var yearlyPriceText: String { prices[.yearly]?.displayPrice ?? "" }

    // MARK: Purchase / restore

    func purchase() async -> PurchaseOutcome {
        if mode == .preview {
            isPurchasing = true
            try? await Task.sleep(for: .seconds(1))
            isPurchasing = false
            return .purchased(productID: config.id(for: selected))
        }
        guard let product = products[selected] else {
            return .failed("This plan isn't available right now. Please try again.")
        }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                let transaction = try Self.verified(verification)
                await transaction.finish()
                return .purchased(productID: transaction.productID)
            case .userCancelled:
                return .cancelled
            case .pending:
                return .pending
            @unknown default:
                return .cancelled
            }
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    func restore() async -> RestoreOutcome {
        if mode == .preview { return .nothingToRestore }
        do {
            try await AppStore.sync()
        } catch {
            return .failed(error.localizedDescription)
        }
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, config.allIDs.contains(t.productID), t.revocationDate == nil {
                return .restored
            }
        }
        return .nothingToRestore
    }

    private static func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value): return value
        case .unverified(_, let error): throw error
        }
    }
}
