//
//  String + Extensions.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/18/24.
//

import Foundation

//extension String {
//    var isEmptyOrWhitespaces: Bool { return !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty}
//}

extension String {
    var isEmptyOrWhitespaces: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var isNotEmptyOrWhitespaces: Bool {
        return !isEmptyOrWhitespaces
    }
    
    func truncated(to maxLength: Int = 20) -> String {
        let trailingChars = count > maxLength ? "..." : ""
        return String(prefix(maxLength) + trailingChars)
    }
}


