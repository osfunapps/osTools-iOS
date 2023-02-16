//
//  DateUtils.swift
//  TelegraphWebServer
//
//  Created by Oz Shabbat on 13/02/2023.
//

import Foundation
/**
 This is just a small helper class to use when you want to show a Date() in a nice tidy string of your choice (like July 2022).
 
 To use, just use one of the formatters below.
 For example:
 let stringDate = DateUtils.dayMonthYearHourMinute.string(from: date)
 */
public class DateUtils {

    /// July 2022
    public static var monthYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    /// July
    public static var month: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }
    
    /// 2022
    public static var year: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }
    
    
    /// 14 July 2022 10:39
    public static var dayMonthYearHourMinute: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy HH:mm"
        return formatter
    }
    
}
