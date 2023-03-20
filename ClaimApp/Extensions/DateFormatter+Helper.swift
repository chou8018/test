//
//  DateFormatter+Helper.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 21/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static func makeCurrencyDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: AppDataHelper.languageCode?.rawValue ?? "en")
        return formatter
    }
    
    @nonobjc static let creditCardExpiryDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    @nonobjc static let ddMMyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        return formatter
    }()
    
    @nonobjc static let dd_MM_yyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()

    @nonobjc static let monthAndYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yyyy"
        return formatter
    }()
    
    @nonobjc static let MMMyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy"
        return formatter
    }()
    
    @nonobjc static let MMMMyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    @nonobjc static let MMMyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()
    
    @nonobjc static let dayMonthAndYear: DateFormatter = {
        let formatter = makeCurrencyDateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    @nonobjc static let dayMonth: DateFormatter = {
        let formatter = makeCurrencyDateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter
    }()
    
    @nonobjc static let onlyMonth: DateFormatter = {
        let formatter = makeCurrencyDateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
    
    @nonobjc static let dayMonthAndShortYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yy"
        return formatter
    }()
    
    @nonobjc static let dayMonthAndYearWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy', 'hh:mm a"
        return formatter
    }()
    
    @nonobjc static let DayFullMonthAndYearWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy', 'hh:mm"
        return formatter
    }()
    
    @nonobjc static let newDayMonthAndYearWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy', 'hh:mm"
        return formatter
    }()
    
    @nonobjc static let dayAmOrPmTime: DateFormatter = {
        let formatter = makeCurrencyDateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    @nonobjc static let timeWithDayMonthAndYear: DateFormatter = {
        let formatter = makeCurrencyDateFormatter()
        formatter.dateFormat = "hh:mm a', 'dd MMM yyyy"
        return formatter
    }()
    
    @nonobjc static let dashSeparatedYearMonthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    @nonobjc static let dashSeparatedYearMonthDayWithTime: DateFormatter = {
        let formatter = makeCurrencyDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH':'mm':'ss"
        return formatter
    }()
    
    @nonobjc static let dashSeparatedYearMonthDayWithTeeTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH':'mm':'ss"
        return formatter
    }()
    
    @nonobjc static let digitsOnlyDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()

    @nonobjc static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.dateFormat = "HH':'mm':'ss"
        return formatter
    }()
    
    @nonobjc static let amPmTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.dateFormat = "ha"
        return formatter
    }()
    
    @nonobjc static let relativeTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    @nonobjc static let relativeDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    @nonobjc static let weekdayDateAndMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMMM"
        return formatter
    }()
    
    @nonobjc static let timeWithHourMinutes: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

