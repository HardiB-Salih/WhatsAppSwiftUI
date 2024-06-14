//
//  UIApplication+Extensions.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 6/13/24.
//

import UIKit

extension UIApplication {
    static func dismissKeyboard() {
        UIApplication
            .shared
            .sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
