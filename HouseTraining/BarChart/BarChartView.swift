//
//  BarChartView.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 30/11/20.
//

import SwiftUI

struct BarChartView: View {
    let data: ChartViewData
    
    var maxValue: Double {
        guard let max = data.data.max() else {
            return 1
        }
        return max != 0 ? max : 1
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 12) {
                Text(data.title)
                HStack {
                    ForEach(0..<data.data.count) { index in
                        VStack {
                            Spacer()
                            VStack {
                                Text("35m")
                                    .font(.footnote)
                                Rectangle()
                                    .fill(Color.green)
                                    .scaleEffect(CGSize(width: 1, height: normalizedValue(index: index)), anchor: .bottom)
                            }
                            Text(data.barTitles[index])
                                .font(.footnote)
                                .frame(height: 20)
                        }
                    }
                }
            }
        }.background(Color.white)
    }
    
    func normalizedValue(index: Int) -> Double {
        return Double(data.data[index])/Double(self.maxValue)
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        let data = ChartViewData(title: "Actividad semanal",
                                barTitles: Calendar.current.shortWeekdaySymbols,
                                data: [50, 90, 80, 20, 100, 90, 7])
        BarChartView(data: data)
    }
}
