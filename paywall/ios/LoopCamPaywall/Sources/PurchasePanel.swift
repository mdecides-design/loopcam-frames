import SwiftUI

/// Pinned purchase panel: three plan tiles, caption, CTA and reassurance/legal. SPEC.md §4
struct PurchasePanel: View {
    @Bindable var store: PaywallStore
    let onPurchase: () -> Void

    var body: some View {
        let copy = store.copy(for: store.selected)
        VStack(spacing: 0) {
            HStack(spacing: 9) {
                ForEach(Plan.allCases) { plan in
                    PlanTile(copy: store.copy(for: plan), isSelected: store.selected == plan) {
                        guard store.selected != plan else { return }
                        store.selected = plan
                    }
                }
            }
            .padding(.top, 10)                          // room for the "3 DAYS FREE" badge
            .redacted(reason: store.isLoaded ? [] : .placeholder)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Choose a plan")

            Text(copy.caption)
                .paywallFont(10, .bold, relativeTo: .caption2)
                .tracking(0.8)
                .foregroundStyle(PaywallColor.text3)
                .lineLimit(1).minimumScaleFactor(0.8)
                .frame(height: 14)                       // fixed: switching plans never moves the panel
                .padding(.top, 12).padding(.bottom, 8)
                .swapTransition(id: copy.caption)

            CTAButton(title: copy.cta, isBusy: store.isPurchasing, action: onPurchase)
                .disabled(!store.isLoaded || store.isPurchasing)

            VStack(spacing: 1) {
                Text(copy.reassurance)
                    .paywallFont(12, .semibold, relativeTo: .caption)
                    .foregroundStyle(PaywallColor.text2)
                Text(copy.legal)
                    .paywallFont(10.5, relativeTo: .caption2)
                    .foregroundStyle(PaywallColor.text4)
                    .lineSpacing(2)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 46, alignment: .top)   // fixed block height
            .padding(.top, 8)
            .swapTransition(id: copy.legal)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
        .background(alignment: .top) {
            // Solid black under the panel, with a 64 pt fade above it so content scrolls under.
            VStack(spacing: 0) {
                LinearGradient(colors: [.black.opacity(0), .black], startPoint: .top, endPoint: .bottom)
                    .frame(height: 64)
                Color.black
            }
            .padding(.top, -64)
            .ignoresSafeArea(edges: .bottom)
            .allowsHitTesting(false)
        }
        .animation(PaywallMotion.selectColors, value: store.selected)
        .sensoryFeedback(.selection, trigger: store.selected)
    }
}

// MARK: - Plan tile

private struct PlanTile: View {
    let copy: PlanCopy
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(copy.title)
                    .paywallFont(13, .semibold, relativeTo: .footnote)
                    .foregroundStyle(isSelected ? PaywallColor.redLight : PaywallColor.text3)
                Text(copy.price)
                    .paywallFont(20, .heavy, relativeTo: .title3)
                    .monospacedDigit()
                    .foregroundStyle(isSelected ? .white : Color(hex: 0xD0D0D0))
                Text(copy.unit)
                    .paywallFont(11, relativeTo: .caption2)
                    .foregroundStyle(isSelected ? PaywallColor.text2 : Color(hex: 0x777777))
            }
            .lineLimit(1).minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity, minHeight: 84)
            .background(isSelected ? PaywallColor.tileSelected : PaywallColor.tile,
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            // Always 2 pt — only the colour changes, so nothing shifts on selection.
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(isSelected ? PaywallColor.red : .white.opacity(0.06), lineWidth: 2))
            .shadow(color: PaywallColor.red.opacity(isSelected ? 0.18 : 0), radius: 12, y: 8)
            .overlay(alignment: .top) {
                if let badge = copy.badge { TileBadge(text: badge).offset(y: -10) }
            }
            .offset(y: isSelected ? -3 : 0)
            .animation(PaywallMotion.selectLift, value: isSelected)
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityLabel("\(copy.title), \(copy.price), \(copy.unit)\(copy.badge.map { ", \($0.lowercased())" } ?? "")")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

private struct TileBadge: View {
    let text: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .tracking(0.54)
            .foregroundStyle(.white)
            .padding(.vertical, 3).padding(.horizontal, 8)
            .background(PaywallColor.red, in: Capsule())
            .fixedSize()
            .phaseAnimator(reduceMotion ? [0] : [0, -2]) { view, y in
                view.offset(y: y)
            } animation: { _ in .easeInOut(duration: 1.2) }
    }
}

// MARK: - CTA with a soft light sweep

private struct CTAButton: View {
    let title: String
    let isBusy: Bool
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .paywallFont(17, .bold, relativeTo: .headline)
                    .foregroundStyle(.white)
                    .opacity(isBusy ? 0 : 1)
                    .swapTransition(id: title)
                if isBusy { ProgressView().tint(.white) }
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(PaywallColor.red, in: Capsule())
            .overlay { if !reduceMotion { Shine().clipShape(Capsule()) } }
        }
        .buttonStyle(PressScaleStyle())
    }
}

/// A light band that sweeps across every 3.2 s (moving for the first 35%).
private struct Shine: View {
    var body: some View {
        TimelineView(.animation) { context in
            GeometryReader { g in
                let cycle = 3.2
                let t = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: cycle) / cycle
                let progress = min(t / 0.35, 1)
                LinearGradient(colors: [.clear, .white.opacity(0.35), .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 60)
                    .rotationEffect(.degrees(10))
                    .offset(x: -80 + (g.size.width + 160) * progress)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Text swap (cross-fade + 2 pt rise when the text changes)

private struct SwapTransition<ID: Hashable>: ViewModifier {
    let id: ID
    func body(content: Content) -> some View {
        content
            .id(id)
            .transition(.asymmetric(insertion: .opacity.combined(with: .offset(y: 2)), removal: .opacity))
            .animation(PaywallMotion.swap, value: id)
    }
}

extension View {
    func swapTransition<ID: Hashable>(id: ID) -> some View { modifier(SwapTransition(id: id)) }
}
