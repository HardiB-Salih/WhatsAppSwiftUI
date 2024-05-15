//
//  UIHelperManager.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/15/24.
//

import Foundation
import SwiftUI

let UIHelperManager = _UIHelperManager()
class _UIHelperManager {
    
    
    /// Configures the tab bar to have an opaque background.
    ///
    /// This function sets up the `UITabBarAppearance` for the tab bar and applies
    /// an opaque background to it, ensuring it appears solid and not transparent.
    func makeTabBarOpaque() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    /// Configures the navigation bar to have an opaque background.
    ///
    /// This function sets up the `UINavigationBarAppearance` for the navigation bar
    /// and applies an opaque background to it, ensuring it appears solid and not transparent.
    func makeNavigationBarOpaque() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    
    
}
