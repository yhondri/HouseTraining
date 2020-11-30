//
//  ChartGridViewModel.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 30/11/20.
//


import Foundation
import CoreData
import Combine

struct ChartViewData: Hashable {
    let title: String
    let barTitles: [String]
    let data: [Double]
}

class ChartGridViewModel: NSObject, ObservableObject {
    @Published var charts: [ChartViewData] = []
    
    override init() {
        super.init()
        charts = [ChartViewData(title: LocalizableKey.weeklyActivity.localized,
                                barTitles: Calendar.current.veryShortStandaloneWeekdaySymbols,
                                data: [50, 90, 80, 20, 100, 90, 7]),
                  ChartViewData(title: LocalizableKey.monthActivity.localized,
                                barTitles: Calendar.current.veryShortStandaloneMonthSymbols,
                                data: [50, 90, 80, 20, 100, 90, 7, 80, 20, 100, 90, 7])]
    }
}


