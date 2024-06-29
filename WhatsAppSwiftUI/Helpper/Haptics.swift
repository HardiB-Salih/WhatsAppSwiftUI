//
//  Haptics.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 6/29/24.
//

import Foundation
import UIKit

enum Haptic {
    enum Style {
        case light
        case medium
        case heavy
        case success
        case warning
        case error
    }

    private static let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private static let notificationGenerator = UINotificationFeedbackGenerator()

    static func impact(_ style: Style) {
        switch style {
        case .light:
            lightGenerator.impactOccurred()
        case .medium:
            mediumGenerator.impactOccurred()
        case .heavy:
            heavyGenerator.impactOccurred()
        case .success:
            notificationGenerator.notificationOccurred(.success)
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
        case .error:
            notificationGenerator.notificationOccurred(.error)
        }
    }
}
