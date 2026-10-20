import SwiftUI

/// Loop Camera Pro paywall (P3). Present it full-screen:
///
/// ```swift
/// .fullScreenCover(isPresented: $showPaywall) {
///     LoopCamPaywallView(onClose: { showPaywall = false },
///                        onPurchased: { _ in showPaywall = false /* unlock Pro */ },
///                        onEvent: { Analytics.track($0) })
/// }
/// ```
public struct LoopCamPaywallView: View {
    @State private var store: PaywallStore
    private let onClose: () -> Void
    private let onPurchased: (String) -> Void
    private let onEvent: (PaywallEvent) -> Void

    @State private var scrolledPastHero = false
    @State private var isRestoring = false
    @State private var showRedeem = false
    @State private var toast: String?
    @State private var errorMessage: String?

    @MainActor
    public init(store: PaywallStore? = nil,
                onClose: @escaping () -> Void,
                onPurchased: @escaping (_ productID: String) -> Void,
                onEvent: @escaping (PaywallEvent) -> Void = { _ in }) {
        _store = State(initialValue: store ?? PaywallStore())
        self.onClose = onClose
        self.onPurchased = onPurchased
        self.onEvent = onEvent
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                HeroView()
                    .onGeometryChange(for: Bool.self) { $0.frame(in: .scrollView).minY < -200 } action: {
                        scrolledPastHero = $0
                    }

                TrustBadgesRow()
                    .padding(.top, 24).padding(.bottom, 20)
                    .reveal()

                HeadlineView(trial: store.trial).reveal()

                ProFeaturesSection().padding(.horizontal, 24)

                VStack(spacing: 20) {
                    if let trial = store.trial {
                        TrialTimelineCard(trial: trial, yearlyPrice: store.yearlyPriceText).reveal()
                    }
                    IncludedCard().reveal()
                }
                .padding(.horizontal, 24)
                .padding(.top, 6)

                FooterLinks(isRestoring: isRestoring,
                            onRestore: restore,
                            onRedeem: { showRedeem = true },
                            termsURL: store.config.termsURL,
                            privacyURL: store.config.privacyURL)
                    .padding(.horizontal, 24)

                StoryClapperCard()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)               // ~40 pt above the tiles when scrolled to the end
                    .reveal()
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PurchasePanel(store: store, onPurchase: purchase)
        }
        .overlay(alignment: .top) { topChrome }
        .overlay(alignment: .top) { toastView }
        .background(PaywallColor.background.ignoresSafeArea())
        .environment(\.colorScheme, .dark)
        .onChange(of: store.selected) { _, plan in onEvent(.planSelected(plan)) }
        .task {
            onEvent(.shown)
            await store.load()
        }
        .alert("Purchase failed", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        #if os(iOS)
        .offerCodeRedemption(isPresented: $showRedeem) { _ in }
        .statusBarHidden(false)
        #endif
    }

    // MARK: Chrome

    /// Black fade behind the status bar once the hero has scrolled away, plus the ✕ button.
    private var topChrome: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(colors: [.black.opacity(0.9), .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: 110)
                .ignoresSafeArea(edges: .top)
                .opacity(scrolledPastHero ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: scrolledPastHero)
                .allowsHitTesting(false)

            Button {
                onEvent(.closed)
                onClose()
            } label: {
                PaywallIcon.close.image
                    .resizable().scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().strokeBorder(.white.opacity(0.18)))
            }
            .buttonStyle(PressScaleStyle())
            .accessibilityLabel("Close")
            .padding(.trailing, 22)
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    @ViewBuilder private var toastView: some View {
        if let toast {
            Text(toast)
                .paywallFont(13, .medium, relativeTo: .footnote)
                .foregroundStyle(.white)
                .padding(.vertical, 10).padding(.horizontal, 16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.top, 56)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func showToast(_ text: String) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { toast = text }
        Task {
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(.easeOut(duration: 0.25)) { if toast == text { toast = nil } }
        }
    }

    // MARK: Actions

    private func purchase() {
        let plan = store.selected
        onEvent(.purchaseStarted(plan))
        Task {
            switch await store.purchase() {
            case .purchased(let id):
                onEvent(.purchaseSucceeded(plan))
                onPurchased(id)
            case .cancelled:
                onEvent(.purchaseCancelled(plan))
            case .pending:
                showToast("Purchase pending approval")
            case .failed(let message):
                onEvent(.purchaseFailed(plan, message))
                errorMessage = message
            }
        }
    }

    private func restore() {
        onEvent(.restoreTapped)
        isRestoring = true
        Task {
            let outcome = await store.restore()
            isRestoring = false
            switch outcome {
            case .restored: onPurchased(store.config.id(for: store.selected))
            case .nothingToRestore: showToast("No previous purchase found")
            case .failed(let message): showToast(message)
            }
        }
    }
}

#Preview("Paywall") {
    LoopCamPaywallView(store: PaywallStore(mode: .preview), onClose: {}, onPurchased: { _ in })
}
