//
//  Date + Extension.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/19/24.
//

import Foundation

extension Date {
    
    /// if today return 3:30 PM
    /// if Yesterday return Yesterday
    /// else return date
    var dayOrTimeRepresentaion: String {
        let calender = Calendar.current
        let dateFormatter = DateFormatter()
        
        
        if calender.isDateInToday(self) {
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: self)
        } else if calender.isDateInYesterday(self) {
            return "Yesterday"
        }else {
            dateFormatter.dateFormat = "MM/dd/yy"
            return dateFormatter.string(from: self)
        }
    }
    
    var formatToTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self)
    }
    
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
