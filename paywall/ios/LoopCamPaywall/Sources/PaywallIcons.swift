import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Icons from the Figma file, shipped in `PaywallAssets.xcassets` as template vectors.
/// If an asset is missing the closest SF Symbol is used, so the screen never shows a blank.
enum PaywallIcon: String {
    case crown = "paywall_crown"
    case close = "paywall_close"
    case leaf = "paywall_leaf"
    // What Pro adds
    case proProjects = "paywall_pro_projects"
    case proTimer = "paywall_pro_timer"
    case proNoWatermark = "paywall_pro_eraser"
    // Free for everyone · Top 8
    case autoLoop = "paywall_top_timer"
    case handsFree = "paywall_top_watch"
    case autoShorts = "paywall_top_wand"
    case dualCamera = "paywall_top_camera_rotate"
    case secondPhone = "paywall_top_phone"
    case editor = "paywall_top_scissors"
    case frames = "paywall_top_frame"
    case photoToVideo = "paywall_top_camera"

    private var symbol: String {
        switch self {
        case .crown: "crown.fill"
        case .close: "xmark"
        case .leaf: "laurel.leading"
        case .proProjects: "square.stack.3d.up"
        case .proTimer, .autoLoop: "timer"
        case .proNoWatermark: "eraser"
        case .handsFree: "applewatch"
        case .autoShorts: "wand.and.stars"
        case .dualCamera: "arrow.triangle.2.circlepath.camera"
        case .secondPhone: "iphone"
        case .editor: "scissors"
        case .frames: "photo.artframe"
        case .photoToVideo: "camera"
        }
    }

    /// Template image: colour it with `.foregroundStyle`.
    var image: Image {
        Self.hasAsset(rawValue) ? Image(rawValue).renderingMode(.template) : Image(systemName: symbol)
    }

    private static func hasAsset(_ name: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: name) != nil
        #else
        return true
        #endif
    }
}

/// Hero photos (`paywall_photo_1` … `_9`). Replace with real Loop Cam footage before release.
enum PaywallPhoto {
    static let names = (1...9).map { "paywall_photo_\($0)" }
}
