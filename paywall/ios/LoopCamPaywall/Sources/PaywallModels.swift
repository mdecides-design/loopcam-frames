import Foundation
import SwiftUI

// MARK: - Configuration

/// Product IDs and links. Replace the IDs with the ones in App Store Connect.
public struct PaywallConfig: Sendable {
    public var weeklyID: String
    public var yearlyID: String
    public var lifetimeID: String
    public var termsURL: URL
    public var privacyURL: URL

    public init(weeklyID: String = "loopcam.pro.weekly",
                yearlyID: String = "loopcam.pro.yearly",
                lifetimeID: String = "loopcam.pro.lifetime",
                termsURL: URL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!,
                privacyURL: URL = URL(string: "https://www.getappstudio.com/privacy")!) {
        self.weeklyID = weeklyID
        self.yearlyID = yearlyID
        self.lifetimeID = lifetimeID
        self.termsURL = termsURL
        self.privacyURL = privacyURL
    }

    var allIDs: [String] { [weeklyID, yearlyID, lifetimeID] }

    func id(for plan: Plan) -> String {
        switch plan {
        case .weekly: weeklyID
        case .yearly: yearlyID
        case .lifetime: lifetimeID
        }
    }
}

// MARK: - Plans

public enum Plan: String, CaseIterable, Identifiable, Sendable {
    case weekly, yearly, lifetime
    public var id: String { rawValue }

    var title: String {
        switch self {
        case .weekly: "Weekly"
        case .yearly: "Yearly"
        case .lifetime: "Lifetime"
        }
    }
}

/// Price data the UI needs. Built from StoreKit `Product`s, or from fallbacks in previews.
struct PlanPrice: Sendable {
    var price: Decimal
    var displayPrice: String
    var format: Decimal.FormatStyle.Currency

    func formatted(_ value: Decimal) -> String { value.formatted(format) }
}

/// Free-trial info read from the yearly product's introductory offer.
struct TrialInfo: Sendable, Equatable {
    var value: Int          // e.g. 3
    var unit: Unit          // e.g. .day

    enum Unit: Sendable { case day, week, month, year }

    /// "3 days"
    var long: String {
        let word: String
        switch unit {
        case .day: word = value == 1 ? "day" : "days"
        case .week: word = value == 1 ? "week" : "weeks"
        case .month: word = value == 1 ? "month" : "months"
        case .year: word = value == 1 ? "year" : "years"
        }
        return "\(value) \(word)"
    }

    /// "3-day"
    var adjective: String {
        let word: String
        switch unit {
        case .day: word = "day"
        case .week: word = "week"
        case .month: word = "month"
        case .year: word = "year"
        }
        return "\(value)-\(word)"
    }
}

/// Everything the purchase panel shows for one plan (SPEC.md §4 table).
struct PlanCopy: Equatable {
    var title: String
    var price: String
    var unit: String
    var badge: String?
    var caption: String
    var cta: String
    var reassurance: String
    var legal: String
}

// MARK: - Results and analytics

public enum PurchaseOutcome: Sendable {
    case purchased(productID: String)
    case cancelled
    case pending
    case failed(String)
}

public enum RestoreOutcome: Sendable {
    case restored
    case nothingToRestore
    case failed(String)
}

/// Hook these into Mixpanel (events only, never media). SPEC.md §5.
public enum PaywallEvent: Sendable {
    case shown
    case planSelected(Plan)
    case purchaseStarted(Plan)
    case purchaseSucceeded(Plan)
    case purchaseCancelled(Plan)
    case purchaseFailed(Plan, String)
    case restoreTapped
    case closed
}
