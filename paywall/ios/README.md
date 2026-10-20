# Loop Camera Pro paywall: SwiftUI

Native SwiftUI version of the P3 paywall. It matches the [live prototype](https://mdecides-design.github.io/loopcam-frames/paywall/) and the [build spec](https://github.com/mdecides-design/loopcam-frames/blob/main/paywall/SPEC.md): same layout, copy, colours, fonts and animations. It also has working StoreKit 2 purchases.

**Requirements:** iOS 17+, Xcode 16+, Swift 5.9 or 6, no third-party dependencies.

## What's in the folder

| Path | What it is |
|---|---|
| `LoopCamPaywall/Sources/LoopCamPaywallView.swift` | The screen: scroll content, pinned purchase panel, ✕, toast, purchase/restore flow, preview |
| `LoopCamPaywall/Sources/PurchasePanel.swift` | Plan tiles, caption, CTA (with light sweep) and reassurance/legal lines |
| `LoopCamPaywall/Sources/PaywallSections.swift` | Hero photo grid, PRO badge, trust badges, headline, Pro features, trial timeline, Top 8, footer links |
| `LoopCamPaywall/Sources/StoryClapperCard.swift` | Story card with the vector clapper (drawn in `Canvas`, static) |
| `LoopCamPaywall/Sources/PaywallStore.swift` | StoreKit 2: loads products, checks trial eligibility, purchase, restore, and builds all plan copy |
| `LoopCamPaywall/Sources/PaywallModels.swift` | Product IDs and links (`PaywallConfig`), plans, analytics events |
| `LoopCamPaywall/Sources/PaywallTheme.swift` | Colour tokens, Dynamic Type font helper, motion curves |
| `LoopCamPaywall/Sources/PaywallIcons.swift` | Icon names, with SF Symbol fallbacks if an asset is missing |
| `LoopCamPaywall/PaywallAssets.xcassets` | Figma icons (vector, template rendering) and the 9 hero photos |

## Setup (about 5 minutes)

1. **Add the files:** drag the `LoopCamPaywall` folder into the app target (Sources and `PaywallAssets.xcassets`).
2. **Set the product IDs:** set your App Store Connect IDs in `PaywallConfig` (`PaywallModels.swift`), or pass a config in:
   ```swift
   let store = PaywallStore(config: PaywallConfig(weeklyID: "…", yearlyID: "…", lifetimeID: "…"))
   ```
   Weekly and Yearly are auto-renewing subscriptions in the same group; Lifetime is non-consumable. Give Yearly a **3-day free trial** introductory offer. The UI reads the trial length from StoreKit, so "3 days" updates automatically if you change it.
3. **Present the screen:**
   ```swift
   .fullScreenCover(isPresented: $showPaywall) {
       LoopCamPaywallView(
           onClose: { showPaywall = false },
           onPurchased: { productID in
               showPaywall = false
               // unlock Pro (or let your entitlement listener pick it up)
           },
           onEvent: { event in Analytics.track(event) }   // Mixpanel, events only
       )
   }
   ```
4. **Test in the simulator:** add a StoreKit Configuration file (File → New → StoreKit Configuration File) with the same three IDs and prices: $3.99/week, $29.99/year with a 3-day free trial, $44.99 lifetime. Then select it in the scheme (Run → Options → StoreKit Configuration).

Use the `#Preview` in `LoopCamPaywallView.swift` (`PaywallStore(mode: .preview)`) to see the screen without StoreKit.

## How it behaves

- **Prices come from StoreKit, never hard-coded:**
  - Yearly's "$0.58 a week" is the yearly price ÷ 52.
  - "SAVE 85%" is `1 − yearly / (weekly × 52)`, rounded down.
  - Everything is formatted in the user's currency.
- **No trial (not eligible or no offer):** the trial badge, the "How your free trial works" card and all trial wording are hidden. The CTA becomes "Subscribe for $29.99/year".
- **Smooth plan selection:** the tiles are never rebuilt. The border is always 2 pt and only its colour changes, and the caption and legal blocks have fixed heights, so nothing jumps. Selection plays a `.selection` haptic.
- **Purchase:** `product.purchase()`, then verify and finish the transaction, then call `onPurchased`. A cancel stays on the screen, an error shows an alert, and a pending purchase shows a toast.
- **Restore:** `AppStore.sync()`, then check `Transaction.currentEntitlements`. If nothing is found, a "No previous purchase found" toast appears.
- **Redeem code:** uses the system offer-code sheet (`offerCodeRedemption`).
- **Accessibility:**
  - Dynamic Type on all body text.
  - Tiles expose `.isSelected` and full labels.
  - ✕ is labelled "Close" and decorative images are hidden.
  - Every tap target is at least 44 pt.
  - **Reduce Motion** stops the grid drift, the pulse, the badge bob and the CTA shine, and sections appear without movement.

## Make sure Pro is real

These are the only Pro features (from the Feature Guide). Gate them in the app:

- **Projects:** 10 video + 10 photo on free, unlimited on Pro.
- **Timers and loops:** up to 45 s and 15 loops on free (∞ stays free), up to 180 s and any loop count on Pro.
- **Exports:** watermark + 2 s logo outro on free, clean on Pro.

**4K export is free for everyone.** Don't add it to the Pro list. The current upgrade screen says "High quality exports"; this one replaces it.

## Assets

- **Icons:** exported from the Loop Camera Figma file. The crown comes from the DIML Pro file and the leaf is Niru's `leaf.svg`.
  - They're set to **template** rendering, so the code colours them (red, white, or grey `#999999` for the leaves).
  - If an icon is missing, `PaywallIcon` falls back to a similar SF Symbol.
- **Hero photos:** `paywall_photo_1…9` are from Pexels (free licence). Swap them for real Loop Cam footage when you can.
