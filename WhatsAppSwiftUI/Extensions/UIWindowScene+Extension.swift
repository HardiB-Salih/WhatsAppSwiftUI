//
//  UIWindowScene+Extension.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 6/13/24.
//

import UIKit

extension UIWindowScene {
    static var current: UIWindowScene? {
        return UIApplication.shared.connectedScenes
            .first { $0 is UIWindowScene } as? UIWindowScene
    }
    
    
    
    var screenHeight: CGFloat {
        return self.screen.bounds.height
//        return UIWindowScene.current?.screen.bounds.height
//        return UIScreen.main.bounds.height
    }
    
    var screenWidth: CGFloat {
        return self.screen.bounds.width
//        return UIWindowScene.current?.screen.bounds.width
//        return UIScreen.main.bounds.width
    }
}
