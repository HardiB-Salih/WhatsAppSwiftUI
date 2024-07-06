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


extension Date {
    var relativeDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if isCurrentWeek { // Monday, Wednesday
            return toString(format: "EEEE")
        } else if isCurrentYear { // Mon, Feb 19
            return toString(format: "E, MMM d")
        } else { // Mon, Feb 19, 2019
            return toString(format: "MMM dd, yyyy")
        }
    }
    
    private var isCurrentWeek: Bool {
        let calendar = Calendar.current
        let currentWeekOfYear = calendar.component(.weekOfYear, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        let weekOfYear = calendar.component(.weekOfYear, from: self)
        let year = calendar.component(.year, from: self)
        return currentWeekOfYear == weekOfYear && currentYear == year
    }
    
    private var isCurrentYear: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    
    
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
}
