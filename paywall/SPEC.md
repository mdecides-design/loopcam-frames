# Loop Camera Pro: paywall build spec (P3)

Hand this file to whoever builds the upgrade screen. It matches the design exactly.

- **Live prototype:** https://mdecides-design.github.io/loopcam-frames/paywall/ (tap around, it works)
- **Figma:** [P3 · Combined — full length](https://www.figma.com/design/LXjx2bd43Kfr47sKeGzhr2/Loop-Camera-%E2%80%94-Redesign?node-id=140-926), file "Loop Camera — Redesign", page "08 · D — full set"
- **Prototype source:** `index.html`, `img/`, `icons/` next to this file. Values in this spec come from that source and the Figma frame.

Design canvas is **402 pt wide** (iPhone 16 Pro Max / 17 Pro Max class). Use points and let Auto Layout / SwiftUI scale; side margins are **24 pt** everywhere.

---

## 1. Structure

One screen, two layers:

1. **Scroll content.** Everything from the hero down to the story card. It scrolls vertically and has no horizontal scroll.
2. **Purchase panel.** Pinned to the bottom safe area and always visible. Content scrolls **under** it, and a 64 pt black fade sits at its top edge.

Fixed chrome on top of both: the status bar and the **✕ close** button (top-right, 44 × 44 pt).

```
┌──────────────────────────────┐
│ status bar            [✕]    │  ← fixed
│ HERO (photo grid + PRO badge)│  ┐
│ Headline + trust badges      │  │
│ WHAT PRO ADDS ×3             │  │ scroll
│ How your free trial works    │  │
│ Free for everyone · Top 8    │  │
│ Not ready? · Restore · links │  │
│ Story card (clapper)         │  ┘
│░░░░░░░ 64 pt fade ░░░░░░░░░░░│  ← panel (fixed)
│ [Weekly][Yearly][Lifetime]   │
│ caption                      │
│ [   Try 3 days free   ]      │
│ reassurance + legal          │
└──────────────────────────────┘
```

Bottom padding of the scroll content is **270 pt**, so the last card stops about 40 pt above the plan tiles when scrolled to the end. Don't leave a big empty gap here.

---

## 2. Design tokens

### Colours
| Token | Hex | Use |
|---|---|---|
| `bg` | `#000000` | screen background |
| `card` | `#0D0D0D` | timeline card, Top 8 card |
| `tile` | `#141414` | plan tiles (unselected), pills, Restore button |
| `tileSelected` | `#2A0508` | selected plan tile fill |
| `slate` | `#111111` | story card body |
| `hairline` | `#FFFFFF` @ 8% | card borders, dividers |
| `red` | `#F10219` | brand red: button, badges, selected border, icons |
| `redLight` | `#FF4655` | red text on black (labels, links, "to" value) |
| `redDark` | `#39040C` | icon circle background |
| `text1` | `#FFFFFF` | titles |
| `text2` | `#C8C8C8` | sub-headline, reassurance line |
| `text3` | `#999999` | body / descriptions |
| `text4` | `#8A8A8A` | small print, legal, "from" value (≥ 4.5:1 on black) |
| `slateLabel` | `#7A7A7A` | PROD. / SCENE / TAKE labels |
| `stripeLight` / `stripeDark` | `#2E2E2E` / `#1A1A1A` | clapper stripes |

### Type
- **System font (SF Pro)** for everything, via `.font(.system(...))`.
- **SF Pro Rounded** (`.design(.rounded)`) only for the hero: the PRO badge and the "MADE FOR SOLO CREATORS" line.
- Support Dynamic Type for body text. Titles may cap at `.accessibility1`.

| Style | Size / weight | Where |
|---|---|---|
| Badge | 26 / Heavy, rounded, +6% tracking | "PRO" |
| H1 | 28 / Heavy | "Keep the loop going." |
| H3 | 17 / Semibold | Pro feature titles |
| Row title | 15 / Semibold | timeline steps, Top 8 titles |
| Body | 15 / Regular, line height 22–23 | sub-headline, story |
| Desc | 14 / Regular, line height 20 (13 in rows) | descriptions |
| Kicker | 10 / Bold, +10% tracking, ALL CAPS | section labels |
| Price | 20 / Heavy (tabular numbers) | tile price |
| Button | 17 / Bold | CTA |
| Legal | 10.5 / Regular, line height 15 | renewal terms |

### Radii and spacing
- **Radii:** cards 22, plan tiles 18, CTA 28 (pill), Restore 22, icon circles full circle, PRO badge 26, story card 6 on top and 18 on the bottom.
- **Spacing:** sections are separated by 20–48 pt (see each section). Inside cards the padding is 20 pt vertical and 18 pt horizontal.

---

## 3. Sections (top → bottom)

### 3.1 Hero (height 340)
- **Photo grid:** 3 columns of rounded photos (radius 22), 9 pt gaps, 12 pt side insets, at the 120:180 aspect ratio. Columns are offset (−70 / 0 / +30 pt) and **drift vertically in a slow endless loop** (see Animation).
- **Overlay:** a black gradient from top to bottom at 42% → 50% (35%) → 82% (72%) → 100%. It fades smoothly into the black page. **No hard edge or divider.**
- **Centred content:**
  - **PRO badge:** a red pill with a 1 pt white 18% border, 11 pt vertical and 20–22 pt horizontal padding. It holds the **crown icon** (`icons/crown.svg`, 26 × 21, white) and **PRO**, with an 8 pt gap.
  - **Tagline:** 18 pt below the badge, "— MADE FOR SOLO CREATORS —" (10 / Bold rounded, +10%, `#D0D0D0`), with 26 pt hairlines on each side.

### 3.2 Headline (12 pt below hero)
- **"Keep the loop going."** (H1, centred)
- **"Try every Pro upgrade free for 3 days."** (15 / Regular, `text2`, 6 pt below)

### 3.2b Trust badges (22 pt below the headline)
Two laurel badges side by side, 26 pt apart, centred:

| Big text | Small label |
|---|---|
| **100%** | on-device |
| **4K** | free exports |

- **Laurel:** `icons/leaf.svg` (Niru's file), white, 32.5 × 72 pt. The left branch is as drawn; the right one is the same asset flipped horizontally.
- **Text:** the big text is 32 / Heavy, SF Pro Rounded, −2% tracking, line height 36. The label is 12 / Bold, SF Pro Rounded, `#D9D9D9`. Leaves and text are 4 pt apart.
- **Honesty:** both claims are true per the Feature Guide (clips stay on the phone; 4K export is free for everyone). Swap in a real rating badge ("4.x ★ · N ratings") only once those numbers exist.

### 3.3 What Pro adds
Kicker **WHAT PRO ADDS** (`redLight`), 28 pt above and 26 pt below. Then three centred blocks, max width 300, 34 pt apart. Each block is:
- an icon (24 pt, red),
- the title (8 pt below),
- the description (6 pt below),
- a **Free → Pro pill** (12 pt below): `tile` fill, 1 pt hairline, radius 14, padding 6 × 12, 12 pt text. "From" is `text4` with a strikethrough, the arrow is `text4`, and "to" is `redLight` Bold.

| Icon | Title | Description | From → To |
|---|---|---|---|
| `pro1` stack-plus | Never hit the project limit | Start a new project for every idea. No deleting old ones to make room. | 10 + 10 projects → Unlimited |
| `pro2` timer | Longer takes, more loops | Timers up to 180 s and any loop count, for long recipes, workouts and tutorials. | 45 s · 15 loops → 180 s · any count |
| `pro3` eraser | Post it with no logo | No corner watermark and no 2-second Loop Camera outro on videos, photos and GIFs. | Watermark + outro → Clean exports |

> These three are the **only** Pro features (Feature Guide, build 25 (14)). Free = 10 video + 10 photo projects, timers ≤ 45 s, loops ≤ 15 (∞ is free), watermarked exports. **4K export is free**, so never list it as Pro.

### 3.4 How your free trial works (card)
`card` fill, hairline border, radius 22. Kicker **HOW YOUR FREE TRIAL WORKS** (`text3`), then 3 steps. Each step has a 14 pt dot on the left (2 pt border) with a 2 pt rail running to the next dot, and the text on the right.

| Dot | Title | Text |
|---|---|---|
| red (filled) | Today | Every Pro upgrade unlocks. No payment now. |
| hollow | Day 3 | Your trial ends and $29.99 for the year begins, unless you cancel first. |
| hollow | Any time | Cancel in Settings › your name › Subscriptions. |

Don't add a "Day 2 — we'll remind you" step unless the app actually sends a trial-end reminder.

### 3.5 Free for everyone · Top 8 (card, 20 pt below)
Same card style. Kicker **FREE FOR EVERYONE · TOP 8**. Then 8 rows, 14 pt apart. Each row has a 36 pt `redDark` circle holding an 18 pt red icon, then the title (15 Semibold) and the description (13, `text3`). Footer (12, `text4`): "All of this is free. Pro adds the three upgrades above."

| # | Icon | Title | Description |
|---|---|---|---|
| 1 | `top1` timer | Auto-loop timer | Set it once. It keeps recording. |
| 2 | `top2` watch | Hands-free control | Watch, voice, AirPods or a clicker. |
| 3 | `top3` magic wand | Auto Shorts | One video in, ready-made shorts out. |
| 4 | `top4` camera-rotate | Dual camera | Portrait and landscape of every shot. |
| 5 | `top5` phone | Second phone | More iPhones, more angles. |
| 6 | `top6` scissors | Timeline editor | Trim, text, music and voiceover. |
| 7 | `top7` frame | 180+ frames · 280+ stickers | Dress up any clip. |
| 8 | `top8` camera | Photo to video or GIF | Timed photos, turned into motion. |

### 3.6 Not ready / Restore / links
- **Note** (12, `text4`, centred, max width 300, 40 pt above): "Not ready? Keep filming free. Your projects will be right here."
- **Restore Purchase** button: 330 × 44, `tile`, radius 22, 14 Semibold. It calls `AppStore.sync()` / restore.
- **Links row:** **Redeem code** · **Terms of Use** · **Privacy Policy** (12 Medium, `redLight`, 20 pt gaps, each with a ≥ 44 pt tap area).
  - Redeem code opens `offerCodeRedemption`.
  - Terms of Use opens the Apple standard EULA.
  - Privacy Policy opens `https://www.getappstudio.com/privacy`.

### 3.7 Story card: hinged clapper (30 pt below links)
Width = content width (354).
- **Clapper (vector):**
  - **Base stick:** 18 pt high, `stripeLight` with `stripeDark` diagonal bands (16 pt wide, every 34 pt).
  - **Arm:** 16 pt high, pivoting from the stick's top-left corner and open **−4°**.
  - **Hinge plate:** a 21 × 35 metal-grey plate at the left end, a **red pivot screw** (r 4.2) and a small grey screw below it.
  - **No animation:** the card is static and only fades in like the other sections.
- **Slate body:** `slate` fill, 6% hairline, radius 6/6/18/18, padding 20 × 18. It contains:
  - **Fields row:** PROD. **Loop Cam** │ SCENE **01** │ TAKE **∞** (∞ in red). Labels are 9 / Bold, +12%, `slateLabel`; values are 15 Semibold `#E0E0E0`, separated by 1 pt hairlines.
  - **Story** (15 / Regular, line height 23, `#BDBDBD`): "Filming yourself is a strange little workout. Tap record, run into frame, do the thing, run back, tap stop. Again. And again. So we made a camera that loops for you. Thus Loop Cam."
  - **Tag:** "SET IT · STEP IN · LOOP" (9 / Bold, +14%, `slateLabel`).

---

## 4. Purchase panel (pinned)

- **Background:** transparent → black over the top 64 pt, then solid black. Padding is 24 pt at the sides and 18 pt + safe area at the bottom.
- **Plan tiles:** 3 equal tiles, 9 pt gaps, 84 pt tall, radius 18.
  - **Unselected:** `tile` fill, hairline border, name `text3`, price `#D0D0D0`, unit `#777`.
  - **Selected:** `tileSelected` fill, **2 pt red border**, lifted −3 pt, name `redLight`, price white, unit `text2`.
  - **Yearly** carries a **"3 DAYS FREE"** badge: red pill, 9 / Bold, +6% tracking, centred on the top edge (−10 pt).
- **Caption:** 10 / Bold, +8% tracking, `text3`, centred, 12 pt above and 8 pt below.
- **CTA:** full width, 56 pt, radius 28, red, 17 / Bold white.
- **Reassurance + legal:** line 1 is 12 Semibold `text2`, line 2 is 10.5 `text4`, centred.

### Plan states (default = **Yearly**)
| Plan | Tile price / unit | Caption | CTA | Line 1 | Line 2 |
|---|---|---|---|---|---|
| Weekly | $3.99 / per week | WEEK BY WEEK · CANCEL ANYTIME | Subscribe for $3.99/week | Cancel anytime | $3.99 per week. Renews automatically until you cancel in Settings. |
| **Yearly** | $29.99 / $0.58 a week | 3 DAYS FREE, THEN $29.99/YEAR · SAVE 85% | **Try 3 days free** | No payment now · Cancel anytime | Then $29.99 a year after 3 days. Renews until you cancel in Settings. |
| Lifetime | $44.99 / pay once | YOURS FOREVER · NOTHING RENEWS | Buy once for $44.99 | One payment · No subscription | Nothing renews and there is nothing to cancel. |

**Prices must come from StoreKit, never hard-coded.** Use `Product.displayPrice` and localised period strings.
- **Weekly price:** "$0.58 a week" = yearly price ÷ 52, formatted in the user's currency.
- **"SAVE 85%":** `1 − yearly / (weekly × 52)`, rounded down.
- **No trial offer:** if `isEligibleForIntroOffer` is false, or the product has no intro offer, hide the "3 DAYS FREE" badge, the CTA becomes "Subscribe for $29.99/year", line 1 becomes "Cancel anytime", the caption becomes "BEST VALUE · SAVE 85%", and the trial timeline card (3.4) is hidden.

---

## 5. Interactions

- **Tap a plan tile:** select it, update the caption, CTA and legal lines with a 0.35 s fade-up, and play a light haptic (`.selection`).
- **CTA:** call `product.purchase()` for the selected plan.
  - **Success:** dismiss the paywall and unlock Pro.
  - **Cancelled:** stay on the paywall.
  - **Error:** show an alert.
  - The prototype shows a mock sheet and a "You're Pro." screen to illustrate the flow; use the real StoreKit sheet.
- **✕ close:** dismiss with the standard sheet-down animation.
- **Restore Purchase:** run restore. On success dismiss; if nothing was found, show a toast "No previous purchase found".
- **Scroll:** once offset > 200 pt, fade in a black gradient behind the status bar (0 → 90% over 0.3 s).
- **Analytics (Mixpanel, events only):**
  - `paywall_shown` (with `trigger`: onboarding / project_limit / timer_lock / watermark / export / settings)
  - `paywall_plan_selected`
  - `paywall_purchase_started`
  - `paywall_purchase_success` / `_cancel` / `_error`
  - `paywall_restore`
  - `paywall_closed`

---

## 6. Animation (keep it calm)

| Element | Animation | Timing |
|---|---|---|
| Photo grid | Each column translates up by half its height in a seamless loop (images duplicated); the middle column runs in reverse | 38 s / 44 s / 50 s, linear, infinite |
| PRO badge, tagline | Rise 12 pt and fade in | 0.7 s spring (0.34, 1.56, 0.64, 1), staggered 0.15 s |
| Each section | Fade in and rise 18 pt when 25% visible (once) | 0.6–0.7 s spring |
| Free → Pro pill | Strikethrough draws across "from", then "to" slides in from −6 pt | 0.6 s @ 0.3 s delay, then 0.5 s @ 0.8 s |
| Trial timeline | The "Today" dot pulses (red ring 0 → 10 pt, fading); the first rail fills red | Pulse every 1.8 s; fill 0.8 s |
| Top 8 rows | Stagger in, rising 10 pt | 60 ms apart |
| Selected tile | Lifts −3 pt with a spring | 0.35 s spring |
| "3 DAYS FREE" badge | Gentle 2 pt bob | 2.4 s, infinite |
| CTA | Soft light sweep across the button | 3.2 s loop, starts after 1.5 s |
| Story card | **Static** (fade-in only) | — |

**Reduce Motion:** when `UIAccessibility.isReduceMotionEnabled`, stop the grid drift, the pulse, the bob and the shine, and show sections without movement.

---

## 7. Accessibility
- **Plan tiles:** behave as a radio group (`.accessibilityAddTraits(.isSelected)` on the selected tile). The label reads e.g. "Yearly, $29.99 per year, 3 days free".
- **Labels:** the ✕ is labelled "Close" and the crown is decorative (hidden).
- **Contrast:** all text meets 4.5:1 on black (the smallest greys are `#8A8A8A` / `#7A7A7A`). Don't go darker.
- **Tap targets:** all are ≥ 44 × 44 pt, including the links row.
- **Dynamic Type:** the panel must stay usable at large sizes. If the caption wraps, let the scroll padding grow with the panel height.

---

## 8. Assets
| File | Notes |
|---|---|
| `icons/crown.svg` | Crown from the DIML Pro file (Figma `vbNkeIS6D8AzXfFXEpTKhh`, node 9:665), white |
| `icons/pro1–3.svg` | Pro feature icons (24 pt, red) from the Loop Camera icon library (Phosphor) |
| `icons/top1–8.svg` | Top 8 icons (18 pt, red) |
| `icons/close.svg` | ✕ (16 pt, white) |
| `icons/leaf.svg` | Laurel branch for the trust badges (white, flip for the right side) |
| `img/p1–p9.jpg` | Hero grid photos from **Pexels** (free licence). Swap them for real Loop Cam footage before release if possible. |

Use the SVGs as PDF/SVG assets with "Preserve Vector Data", or as SF Symbols where an exact match exists. Colours are baked in, so recolour them via template rendering if needed.

---

## 9. App Store review checklist
- **Price and period:** shown before purchase in the tiles and the legal line.
- **Trial terms:** length, the price after the trial, and auto-renewal are stated next to the CTA, not only in fine print.
- **Required actions:** Restore and the Terms/Privacy links are visible without leaving the paywall.
- **Close:** ✕ is always reachable; don't hide or delay it.
- **No fake urgency or reviews:** the app has very few ratings, so don't add review stars or testimonials.
