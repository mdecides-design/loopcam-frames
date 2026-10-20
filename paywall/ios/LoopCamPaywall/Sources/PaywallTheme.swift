import SwiftUI

// MARK: - Colours (SPEC.md §2)

enum PaywallColor {
    static let background   = Color.black
    static let card         = Color(hex: 0x0D0D0D)
    static let tile         = Color(hex: 0x141414)
    static let tileSelected = Color(hex: 0x2A0508)
    static let slate        = Color(hex: 0x111111)
    static let hairline     = Color.white.opacity(0.08)

    static let red          = Color(hex: 0xF10219)
    static let redLight     = Color(hex: 0xFF4655)
    static let redDark      = Color(hex: 0x39040C)

    static let text1        = Color.white
    static let text2        = Color(hex: 0xC8C8C8)
    static let text3        = Color(hex: 0x999999)
    static let text4        = Color(hex: 0x8A8A8A)
    static let slateLabel   = Color(hex: 0x7A7A7A)
    static let leaf         = Color(hex: 0x999999)

    static let stripeLight  = Color(hex: 0x2E2E2E)
    static let stripeDark   = Color(hex: 0x1A1A1A)
}

extension Color {
    /// `Color(hex: 0xF10219)`
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}

// MARK: - Type (SPEC.md §2)
// SF Pro everywhere; SF Pro Rounded only for the hero badge, tagline and trust badges.
// Sizes scale with Dynamic Type relative to the text style passed in.

struct ScaledFont: ViewModifier {
    @ScaledMetric private var size: CGFloat
    private let weight: Font.Weight
    private let design: Font.Design

    init(size: CGFloat, weight: Font.Weight, design: Font.Design, relativeTo style: Font.TextStyle) {
        _size = ScaledMetric(wrappedValue: size, relativeTo: style)
        self.weight = weight
        self.design = design
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight, design: design))
    }
}

extension View {
    func paywallFont(_ size: CGFloat,
                     _ weight: Font.Weight = .regular,
                     design: Font.Design = .default,
                     relativeTo style: Font.TextStyle = .body) -> some View {
        modifier(ScaledFont(size: size, weight: weight, design: design, relativeTo: style))
    }

    /// Small caps-style section label ("WHAT PRO ADDS").
    func kicker(_ color: Color = PaywallColor.text3) -> some View {
        self.paywallFont(10, .bold, relativeTo: .caption2)
            .tracking(1)
            .foregroundStyle(color)
    }
}

// MARK: - Motion (SPEC.md §6)

enum PaywallMotion {
    /// Entrance spring used for sections, badge and tagline.
    static let rise = Animation.spring(response: 0.6, dampingFraction: 0.82)
    /// Plan selection: colours 0.28 s, lift 0.32 s ease-out.
    static let selectColors = Animation.easeInOut(duration: 0.28)
    static let selectLift = Animation.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.32)
    /// Text swap in the purchase panel.
    static let swap = Animation.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.3)
}
