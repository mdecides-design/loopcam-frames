import SwiftUI

// MARK: - Reveal on scroll (fade + rise once, SPEC.md §6)

private struct Reveal: ViewModifier {
    var delay: Double = 0
    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let visible = shown || reduceMotion
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 18)
            .onAppear {
                guard !shown else { return }
                withAnimation(PaywallMotion.rise.delay(delay)) { shown = true }
            }
    }
}

extension View {
    func reveal(delay: Double = 0) -> some View { modifier(Reveal(delay: delay)) }
}

// MARK: - Hero (photo grid + PRO badge + tagline), height 340

struct HeroView: View {
    var body: some View {
        ZStack {
            PhotoGridView()
            LinearGradient(stops: [
                .init(color: .black.opacity(0.42), location: 0),
                .init(color: .black.opacity(0.50), location: 0.35),
                .init(color: .black.opacity(0.82), location: 0.72),
                .init(color: .black, location: 1),
            ], startPoint: .top, endPoint: .bottom)

            VStack(spacing: 18) {
                ProBadge().reveal()
                Tagline().reveal(delay: 0.15)
            }
            .padding(.top, 30)
        }
        .frame(height: 340)
        .clipped()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loop Camera Pro. Made for solo creators.")
    }
}

/// Three columns of rounded photos drifting in a slow, endless loop.
struct PhotoGridView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let columns: [(photos: ArraySlice<String>, duration: Double, reverse: Bool, offset: CGFloat)] = [
        (PaywallPhoto.names[0..<3], 38, false, 0),
        (PaywallPhoto.names[3..<6], 44, true, -70),
        (PaywallPhoto.names[6..<9], 50, false, 30),
    ]

    var body: some View {
        GeometryReader { geo in
            let gap: CGFloat = 9
            let tileW = (geo.size.width - 24 - gap * 2) / 3
            let tileH = tileW * 1.5
            let loopH = (tileH + gap) * 3          // one set of 3 photos

            TimelineView(.animation(paused: reduceMotion)) { context in
                let t = context.date.timeIntervalSinceReferenceDate
                HStack(alignment: .top, spacing: gap) {
                    ForEach(0..<3, id: \.self) { i in
                        let c = columns[i]
                        let phase = CGFloat((t / c.duration).truncatingRemainder(dividingBy: 1))
                        let travel = (c.reverse ? phase - 1 : -phase) * loopH
                        VStack(spacing: gap) {
                            ForEach(0..<4, id: \.self) { _ in            // 4 sets = always covered
                                ForEach(Array(c.photos), id: \.self) { name in
                                    PhotoTile(name: name).frame(width: tileW, height: tileH)
                                }
                            }
                        }
                        .offset(y: c.offset + (reduceMotion ? 0 : travel) - 20)
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct PhotoTile: View {
    let name: String
    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .background(LinearGradient(colors: [Color(hex: 0x2A2A2A), Color(hex: 0x141414)],
                                       startPoint: .top, endPoint: .bottom))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct ProBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            PaywallIcon.crown.image
                .resizable().scaledToFit()
                .frame(width: 26, height: 21)
            Text("PRO")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .tracking(1.56)
        }
        .foregroundStyle(.white)
        .padding(.vertical, 11)
        .padding(.leading, 20).padding(.trailing, 22)
        .background(PaywallColor.red, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(.white.opacity(0.18)))
        .shadow(color: PaywallColor.red.opacity(0.35), radius: 20, y: 10)
    }
}

private struct Tagline: View {
    var body: some View {
        HStack(spacing: 10) {
            Rectangle().fill(.white.opacity(0.4)).frame(width: 26, height: 1)
            Text("MADE FOR SOLO CREATORS")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(1)
                .foregroundStyle(Color(hex: 0xD0D0D0))
            Rectangle().fill(.white.opacity(0.4)).frame(width: 26, height: 1)
        }
    }
}

// MARK: - Trust badges (laurel + big value), SPEC.md §3.2b

struct TrustBadgesRow: View {
    var body: some View {
        HStack(spacing: 26) {
            TrustBadge(value: "100%", label: "on-device")
            TrustBadge(value: "4K", label: "free exports")
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("100% on-device. 4K free exports.")
    }
}

private struct TrustBadge: View {
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            leaf
            VStack(spacing: 0) {
                Text(value)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .tracking(-0.64)
                    .foregroundStyle(.white)
                Text(label)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: 0xD9D9D9))
            }
            leaf.scaleEffect(x: -1, y: 1)
        }
    }

    private var leaf: some View {
        PaywallIcon.leaf.image
            .resizable().scaledToFit()
            .frame(width: 32.5, height: 72)
            .foregroundStyle(PaywallColor.leaf)
    }
}

// MARK: - Headline

struct HeadlineView: View {
    let trial: TrialInfo?
    var body: some View {
        VStack(spacing: 6) {
            Text("Keep the loop going.")
                .paywallFont(28, .heavy, relativeTo: .title)
                .foregroundStyle(PaywallColor.text1)
            Text(trial.map { "Try every Pro upgrade free for \($0.long)." } ?? "Unlock every Pro upgrade.")
                .paywallFont(15, relativeTo: .subheadline)
                .foregroundStyle(PaywallColor.text2)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
    }
}

// MARK: - What Pro adds (SPEC.md §3.3)

struct ProFeature: Identifiable {
    let id = UUID()
    let icon: PaywallIcon
    let title: String
    let detail: String
    let from: String
    let to: String

    static let all: [ProFeature] = [
        .init(icon: .proProjects, title: "Never hit the project limit",
              detail: "Start a new project for every idea. No deleting old ones to make room.",
              from: "10 + 10 projects", to: "Unlimited"),
        .init(icon: .proTimer, title: "Longer takes, more loops",
              detail: "Timers up to 180 s and any loop count, for long recipes, workouts and tutorials.",
              from: "45 s · 15 loops", to: "180 s · any count"),
        .init(icon: .proNoWatermark, title: "Post it with no logo",
              detail: "No corner watermark and no 2-second Loop Camera outro on videos, photos and GIFs.",
              from: "Watermark + outro", to: "Clean exports"),
    ]
}

struct ProFeaturesSection: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("WHAT PRO ADDS").kicker(PaywallColor.redLight)
                .padding(.top, 28).padding(.bottom, 26)
                .reveal()
            VStack(spacing: 34) {
                ForEach(ProFeature.all) { ProFeatureBlock(feature: $0).reveal() }
            }
        }
    }
}

private struct ProFeatureBlock: View {
    let feature: ProFeature
    var body: some View {
        VStack(spacing: 0) {
            feature.icon.image
                .resizable().scaledToFit().frame(width: 24, height: 24)
                .foregroundStyle(PaywallColor.red)
                .accessibilityHidden(true)
            Text(feature.title)
                .paywallFont(17, .semibold, relativeTo: .headline)
                .foregroundStyle(PaywallColor.text1)
                .padding(.top, 10)
            Text(feature.detail)
                .paywallFont(14, relativeTo: .subheadline)
                .foregroundStyle(PaywallColor.text3)
                .lineSpacing(3)
                .padding(.top, 6)
            FreeToProPill(from: feature.from, to: feature.to).padding(.top, 12)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: 300)
    }
}

/// "~~10 + 10 projects~~ → Unlimited": the strike draws, then the Pro value slides in.
private struct FreeToProPill: View {
    let from: String
    let to: String
    @State private var played = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let on = played || reduceMotion
        HStack(spacing: 8) {
            Text(from)
                .paywallFont(12, .medium, relativeTo: .caption)
                .foregroundStyle(PaywallColor.text4)
                .overlay(alignment: .leading) {
                    GeometryReader { g in
                        Rectangle().fill(PaywallColor.text4)
                            .frame(width: on ? g.size.width : 0, height: 1)
                            .frame(maxHeight: .infinity)
                    }
                }
            Text("→").paywallFont(12, .bold, relativeTo: .caption).foregroundStyle(PaywallColor.text4)
            Text(to)
                .paywallFont(12, .bold, relativeTo: .caption)
                .foregroundStyle(PaywallColor.redLight)
                .opacity(on ? 1 : 0)
                .offset(x: on ? 0 : -6)
        }
        .padding(.vertical, 6).padding(.horizontal, 12)
        .background(PaywallColor.tile, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(PaywallColor.hairline))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Free: \(from). Pro: \(to).")
        .onAppear {
            guard !played else { return }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) { played = true }
        }
        .animation(PaywallMotion.rise.delay(0.8), value: played)
    }
}

// MARK: - Card shell

struct PaywallCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .padding(.vertical, 20).padding(.horizontal, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(PaywallColor.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(PaywallColor.hairline))
    }
}

// MARK: - How your free trial works (SPEC.md §3.4) — only when a trial is offered

struct TrialTimelineCard: View {
    let trial: TrialInfo
    let yearlyPrice: String

    /// "Day 3" for day-based trials, otherwise "When the trial ends".
    private var endTitle: String {
        guard trial.unit == .day else { return "When the trial ends" }
        return trial.value == 1 ? "Tomorrow" : "Day \(trial.value)"
    }

    private var steps: [(title: String, text: String, active: Bool)] {[
        ("Today", "Every Pro upgrade unlocks. No payment now.", true),
        (endTitle, "Your trial ends and \(yearlyPrice) for the year begins, unless you cancel first.", false),
        ("Any time", "Cancel in Settings › your name › Subscriptions.", false),
    ]}

    var body: some View {
        PaywallCard {
            Text("HOW YOUR FREE TRIAL WORKS").kicker().padding(.bottom, 16)
            ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 4) {
                        TimelineDot(active: step.active).padding(.top, 3)
                        if i < steps.count - 1 { TimelineRail(filled: i == 0) }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.title).paywallFont(15, .semibold, relativeTo: .subheadline)
                            .foregroundStyle(PaywallColor.text1)
                        Text(step.text).paywallFont(13, relativeTo: .footnote)
                            .foregroundStyle(PaywallColor.text3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, i < steps.count - 1 ? 18 : 0)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

private struct TimelineDot: View {
    let active: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if active && !reduceMotion {
                Circle().stroke(PaywallColor.red.opacity(0.55), lineWidth: 2)
                    .phaseAnimator([false, true]) { ring, expanded in
                        ring.scaleEffect(expanded ? 2.4 : 1).opacity(expanded ? 0 : 0.9)
                    } animation: { expanded in expanded ? .easeOut(duration: 1.3) : .linear(duration: 0.5) }
            }
            Circle()
                .fill(active ? PaywallColor.red : .black)
                .overlay(Circle().strokeBorder(active ? PaywallColor.red : .white.opacity(0.35), lineWidth: 2))
        }
        .frame(width: 14, height: 14)
    }
}

private struct TimelineRail: View {
    let filled: Bool
    @State private var progress: CGFloat = 0
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .top) {
                Rectangle().fill(.white.opacity(0.12))
                if filled { Rectangle().fill(PaywallColor.red).frame(height: g.size.height * progress) }
            }
        }
        .frame(width: 2)
        .frame(minHeight: 20)
        .onAppear { withAnimation(.easeInOut(duration: 0.8).delay(0.4)) { progress = 1 } }
    }
}

// MARK: - Free for everyone · Top 8 (SPEC.md §3.5)

struct IncludedFeature: Identifiable {
    let id = UUID()
    let icon: PaywallIcon
    let title: String
    let detail: String

    static let top8: [IncludedFeature] = [
        .init(icon: .autoLoop, title: "Auto-loop timer", detail: "Set it once. It keeps recording."),
        .init(icon: .handsFree, title: "Hands-free control", detail: "Watch, voice, AirPods or a clicker."),
        .init(icon: .autoShorts, title: "Auto Shorts", detail: "One video in, ready-made shorts out."),
        .init(icon: .dualCamera, title: "Dual camera", detail: "Portrait and landscape of every shot."),
        .init(icon: .secondPhone, title: "Second phone", detail: "More iPhones, more angles."),
        .init(icon: .editor, title: "Timeline editor", detail: "Trim, text, music and voiceover."),
        .init(icon: .frames, title: "180+ frames · 280+ stickers", detail: "Dress up any clip."),
        .init(icon: .photoToVideo, title: "Photo to video or GIF", detail: "Timed photos, turned into motion."),
    ]
}

struct IncludedCard: View {
    var body: some View {
        PaywallCard {
            Text("FREE FOR EVERYONE · TOP 8").kicker().padding(.bottom, 16)
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(IncludedFeature.top8.enumerated()), id: \.element.id) { i, f in
                    HStack(spacing: 12) {
                        f.icon.image.resizable().scaledToFit().frame(width: 18, height: 18)
                            .foregroundStyle(PaywallColor.red)
                            .frame(width: 36, height: 36)
                            .background(PaywallColor.redDark, in: Circle())
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(f.title).paywallFont(15, .semibold, relativeTo: .subheadline)
                                .foregroundStyle(PaywallColor.text1)
                            Text(f.detail).paywallFont(13, relativeTo: .footnote)
                                .foregroundStyle(PaywallColor.text3)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .reveal(delay: Double(i) * 0.06)
                }
            }
            Text("All of this is free. Pro adds the three upgrades above.")
                .paywallFont(12, relativeTo: .caption)
                .foregroundStyle(PaywallColor.text4)
                .padding(.top, 16)
        }
    }
}

// MARK: - Not ready / Restore / links (SPEC.md §3.6)

struct FooterLinks: View {
    let isRestoring: Bool
    let onRestore: () -> Void
    let onRedeem: () -> Void
    let termsURL: URL
    let privacyURL: URL

    var body: some View {
        VStack(spacing: 0) {
            Text("Not ready? Keep filming free. Your projects will be right here.")
                .paywallFont(12, relativeTo: .caption)
                .foregroundStyle(PaywallColor.text4)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
                .padding(.top, 40).padding(.bottom, 18)

            Button(action: onRestore) {
                ZStack {
                    Text("Restore Purchase").opacity(isRestoring ? 0 : 1)
                    if isRestoring { ProgressView().tint(.white) }
                }
                .paywallFont(14, .semibold, relativeTo: .subheadline)
                .foregroundStyle(PaywallColor.text1)
                .frame(maxWidth: 330, minHeight: 44)
                .background(PaywallColor.tile, in: Capsule())
            }
            .buttonStyle(PressScaleStyle())
            .disabled(isRestoring)

            HStack(spacing: 20) {
                Button("Redeem code", action: onRedeem)
                Link("Terms of Use", destination: termsURL)
                Link("Privacy Policy", destination: privacyURL)
            }
            .paywallFont(12, .medium, relativeTo: .caption)
            .foregroundStyle(PaywallColor.redLight)
            .tint(PaywallColor.redLight)
            .frame(minHeight: 44)
            .padding(.top, 2).padding(.bottom, 26)
        }
    }
}

struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
