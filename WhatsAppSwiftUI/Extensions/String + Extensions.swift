//
//  String + Extensions.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/18/24.
//

import Foundation

extension String {
    var isEmptyOrWhitespaces: Bool { return !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty}
}


