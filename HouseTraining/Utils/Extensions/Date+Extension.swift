//
//  Date+Extension.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 17/12/20.
//

import Foundation

extension Date {
    var startOfWeek: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        return gregorian.date(byAdding: .day, value: 1, to: sunday)!
    }
    
    var endOfWeek: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        return gregorian.date(byAdding: .day, value: 7, to: sunday)!
    }
    
    func getDayOfWeek() -> Int {
        let weekDayNum = Calendar.current.component(.weekday, from: self)
        return weekDayNum
    }
    
    func getMonth() -> Int {
        let weekDayNum = Calendar.current.component(.month, from: self)
        return weekDayNum
    }
}
