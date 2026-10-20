import SwiftUI

/// Story card: muted clapperboard with a hinged arm (open −4°), metal hinge plate and red pivot screw.
/// Static by design — it only fades in like the other sections. SPEC.md §3.7
struct StoryClapperCard: View {
    var body: some View {
        VStack(spacing: 0) {
            ClapperTop()
                .aspectRatio(354 / 78, contentMode: .fit)
                .accessibilityHidden(true)
            slate.padding(.top, 4)
        }
        .accessibilityElement(children: .combine)
    }

    private var slate: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                field("PROD.", "Loop Cam")
                divider
                field("SCENE", "01")
                divider
                field("TAKE", "∞", accent: true)
            }
            Rectangle().fill(.white.opacity(0.06)).frame(height: 1).padding(.vertical, 16)
            Text("Filming yourself is a strange little workout. Tap record, run into frame, do the thing, run back, tap stop. Again. And again. So we made a camera that loops for you. Thus Loop Cam.")
                .paywallFont(15, relativeTo: .subheadline)
                .foregroundStyle(Color(hex: 0xBDBDBD))
                .lineSpacing(5)
            Text("SET IT · STEP IN · LOOP")
                .paywallFont(9, .bold, relativeTo: .caption2)
                .tracking(1.3)
                .foregroundStyle(PaywallColor.slateLabel)
                .padding(.top, 16)
        }
        .padding(.vertical, 20).padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PaywallColor.slate,
                    in: UnevenRoundedRectangle(topLeadingRadius: 6, bottomLeadingRadius: 18,
                                               bottomTrailingRadius: 18, topTrailingRadius: 6, style: .continuous))
        .overlay(UnevenRoundedRectangle(topLeadingRadius: 6, bottomLeadingRadius: 18,
                                        bottomTrailingRadius: 18, topTrailingRadius: 6, style: .continuous)
            .strokeBorder(.white.opacity(0.06)))
    }

    private var divider: some View {
        Rectangle().fill(.white.opacity(0.08)).frame(width: 1).padding(.horizontal, 14)
    }

    private func field(_ label: String, _ value: String, accent: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).paywallFont(9, .bold, relativeTo: .caption2).tracking(1.1)
                .foregroundStyle(PaywallColor.slateLabel)
            Text(value).paywallFont(accent ? 18 : 15, .semibold, relativeTo: .subheadline)
                .foregroundStyle(accent ? PaywallColor.red : Color(hex: 0xE0E0E0))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Vector clapper drawn on a 354 × 78 design grid and scaled to the available width.
private struct ClapperTop: View {
    var body: some View {
        Canvas { ctx, size in
            let s = size.width / 354
            ctx.scaleBy(x: s, y: s)

            let stick = CGRect(x: 0, y: 60, width: 354, height: 18)
            let arm = CGRect(x: 8, y: 44, width: 344, height: 16)

            func stripes(in rect: CGRect, slantRight: Bool) -> Path {
                var p = Path()
                var x: CGFloat = -30
                while x < 400 {
                    let top = rect.minY, bottom = rect.maxY
                    if slantRight {           // base stick: "/" bands
                        p.addLines([CGPoint(x: x, y: top), CGPoint(x: x + 16, y: top),
                                    CGPoint(x: x + 6, y: bottom), CGPoint(x: x - 10, y: bottom)])
                    } else {                  // arm: "\" bands
                        p.addLines([CGPoint(x: x, y: top), CGPoint(x: x + 16, y: top),
                                    CGPoint(x: x + 26, y: bottom), CGPoint(x: x + 10, y: bottom)])
                    }
                    p.closeSubpath()
                    x += 34
                }
                return p
            }

            // Base stick
            let stickShape = Path(roundedRect: stick, cornerRadius: 3)
            ctx.fill(stickShape, with: .color(PaywallColor.stripeLight))
            ctx.drawLayer { layer in
                layer.clip(to: stickShape)
                layer.fill(stripes(in: stick, slantRight: true), with: .color(PaywallColor.stripeDark))
            }

            // Arm, pivoting from the stick's top-left corner (8, 60), open −4°
            ctx.drawLayer { layer in
                layer.translateBy(x: 8, y: 60)
                layer.rotate(by: .degrees(-4))
                layer.translateBy(x: -8, y: -60)
                let armShape = Path(roundedRect: arm, cornerRadius: 3)
                layer.fill(armShape, with: .color(PaywallColor.stripeLight))
                layer.clip(to: armShape)
                layer.fill(stripes(in: arm, slantRight: false), with: .color(PaywallColor.stripeDark))
            }

            // Hinge plate + screws
            let plate = Path(roundedRect: CGRect(x: 1.5, y: 41, width: 21, height: 35), cornerRadius: 4)
            ctx.fill(plate, with: .linearGradient(Gradient(colors: [Color(hex: 0x4A4A4A), Color(hex: 0x2F2F2F)]),
                                                  startPoint: CGPoint(x: 1.5, y: 0), endPoint: CGPoint(x: 22.5, y: 0)))
            ctx.stroke(plate, with: .color(.white.opacity(0.12)), lineWidth: 1)
            ctx.fill(Path(CGRect(x: 1.5, y: 59, width: 21, height: 1.2)), with: .color(.black.opacity(0.45)))
            ctx.fill(Path(ellipseIn: CGRect(x: 12 - 4.2, y: 52 - 4.2, width: 8.4, height: 8.4)), with: .color(PaywallColor.red))
            ctx.fill(Path(ellipseIn: CGRect(x: 12 - 1.4, y: 52 - 1.4, width: 2.8, height: 2.8)), with: .color(Color(hex: 0x7A0010)))
            let lower = Path(ellipseIn: CGRect(x: 12 - 2.2, y: 68 - 2.2, width: 4.4, height: 4.4))
            ctx.fill(lower, with: .color(Color(hex: 0x1C1C1C)))
            ctx.stroke(lower, with: .color(.white.opacity(0.15)), lineWidth: 0.8)
        }
    }
}
