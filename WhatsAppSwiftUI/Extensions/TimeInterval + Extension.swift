//
//  TimeInterval + Extension.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 6/6/24.
//

import Foundation

extension TimeInterval {
    var formatElapsedTime: String {
        // Calculate the total minutes and remaining seconds
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        
        // Return the formatted string
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    static var stubTimeInterval: TimeInterval {
        return TimeInterval()
    }
}
