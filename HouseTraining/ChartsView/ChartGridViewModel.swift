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
    let data: [Int: Double]
    let maxValue: Double
}

class ChartGridViewModel: NSObject, ObservableObject {
    @Published var charts: [ChartViewData] = []
    private var cancellables = [AnyCancellable]()

    override init() {
        super.init()
//        charts = [ChartViewData(title: LocalizableKey.weeklyActivity.localized,
//                                barTitles: Calendar.current.veryShortStandaloneWeekdaySymbols,
//                                data: [50, 90, 80, 20, 100, 90, 7]),
//                  ChartViewData(title: LocalizableKey.monthActivity.localized,
//                                barTitles: Calendar.current.veryShortStandaloneMonthSymbols,
//                                data: [50, 90, 80, 20, 100, 90, 7, 80, 20, 100, 90, 7])]
        
        loadData()
    }
    
    private func loadData() {
        CoreDataPublisher(request: ExerciseRecordEntity.getAllFetchRequest(by: Date()), context: CoreDataStack.shared.viewContext)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error \(error)")
                }
            }, receiveValue: { [weak self] records in
                guard let self = self else { return }
                self.mapData(records: records)
            })
            .store(in: &cancellables)
    }
    
    private func mapData(records: [ExerciseRecordEntity]) {
        var weekDataDictionary: [Int: Double] = [1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0]
        var yearDataDictionary: [Int: Double] = [1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0, 8:0, 9:0, 10:0, 11:0, 12:0]
        records.forEach { record in
            weekDataDictionary[record.date.getDayOfWeek()]! += Double(Exercise.exerciseTime)
            yearDataDictionary[record.date.getMonth()]! += Double(Exercise.exerciseTime)
        }
        
        var maxWeekvalue: Double = 0
        var maxMonthValue: Double = 0
        
        weekDataDictionary.forEach { _, value in
            maxWeekvalue = Double.maximum(maxWeekvalue, value)
        }
        
        yearDataDictionary.forEach { _, value in
            maxMonthValue = Double.maximum(maxMonthValue, value)
        }
        
        charts = [ChartViewData(title: LocalizableKey.weeklyActivity.localized,
                                barTitles: Calendar.current.veryShortStandaloneWeekdaySymbols,
                                data: weekDataDictionary,
                                maxValue: maxWeekvalue),
                  ChartViewData(title: LocalizableKey.monthActivity.localized,
                                barTitles: Calendar.current.veryShortStandaloneMonthSymbols,
                                data: yearDataDictionary,
                                maxValue: maxMonthValue)]
    }
}


