//
//  Intiger.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/15/24.
//

import Foundation

extension Int {
    func to(_ end: Int) -> Range<Int> {
        return 0..<end
    }
    
    func upTo(_ end: Int) -> [Int] {
        return Array(self..<end)
    }
}

