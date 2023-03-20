//
//  Date+Helper.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 21/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation

extension Date {
    
    func string(with format: DateFormatter) -> String {
        return format.string(from: self)
    }
    
    init?(string: String, formatter: DateFormatter) {
        guard let date = formatter.date(from: string) else { return nil }
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
 
    
    func shortTimeAgo() -> String {
        
        let calendar = Calendar.current
        
        let components:DateComponents =
            (calendar as NSCalendar).components(
                [.minute, .hour, .day, .weekOfYear, .month, .year, .second],
                from: self,
                to: Date(),
                options: []
        )
        
        if let year = components.year, year >= 1 {
            return "\(year)y"
        } else if let month = components.month, month >= 1 {
            return "\(month)M"
        } else if let weekOfYear = components.weekOfYear, weekOfYear >= 1 {
            return "\(weekOfYear)w"
        } else if let day = components.day, day >= 1 {
            return "\(day)d"
        } else if let hour = components.hour, hour >= 1 {
            return "\(hour)h"
        } else if let minute = components.minute, minute >= 1 {
            return "\(minute)m"
        } else if let second = components.second, second >= 3 {
            return "\(second)s"
        } else {
            return "now"
        }
        
    }
    
    
    static func dayOfWeek() -> Int {
        let date = Date()
        let interval = date.timeIntervalSince1970;
        let days = Int(interval / 86400);
        return (days - 3) % 7;
    }
    
    /// 10
    var timeStamp : TimeInterval {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return TimeInterval(timeStamp)
    }
    
}

extension Date {
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day],from: self,to: toDate)
        return components.day ?? 0
    }
}

