//
//  UIHelperManager.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/15/24.
//

import Foundation
import SwiftUI
import UIKit

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

    
    func makeNavigationBarOpaque() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    /// Sets the navigation bar to an opaque appearance with customizable colors.
    ///
    /// - Parameters:
    ///   - backgroundColor: The background color of the navigation bar.
    ///   - titleColor: The color of the title text in the navigation bar.
    ///   - largeTitleColor: The color of the large title text in the navigation bar.
//    func makeNavigationBarOpaque(backgroundColor: UIColor, titleColor: UIColor, largeTitleColor: UIColor) {
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = backgroundColor
//        appearance.titleTextAttributes = [.foregroundColor: titleColor]
//        appearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
//        
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        UINavigationBar.appearance().compactAppearance = appearance
//    }
    
}
