//
//  BarChartView.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 30/11/20.
//

import SwiftUI

public class SelectedChartValue: ObservableObject {
    @Published var currentValue: Double = 0
    @Published var interactionInProgress: Bool = false
}

struct BarChartView: View {
    let data: ChartViewData
    @State var touchLocation: CGFloat = -1.0
    @ObservedObject var chartValue: SelectedChartValue = SelectedChartValue()
    
    private func getExerciseTimeText(interval: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        return String(format: "%@: %@", LocalizableKey.exercise.localized, formatter.string(from: TimeInterval(interval))!)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 12) {
                Text(data.title)
                if chartValue.currentValue > 0 {
                    Text(getExerciseTimeText(interval: chartValue.currentValue))
                        .font(.footnote)
                        .frame(height: 15)
                }
                HStack {
                    ForEach(0..<data.data.count) { index in
                        VStack {
                            Spacer()
                            VStack {
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
                .gesture(DragGesture()
                    .onChanged({ value in
                        let width = geometry.frame(in: .local).width
                        self.touchLocation = value.location.x/width
                        if let currentValue = self.getTouchingValue(width: width) {
                            self.chartValue.currentValue = currentValue
                            self.chartValue.interactionInProgress = true
                        }
                    })
                    .onEnded({ value in
                        self.chartValue.interactionInProgress = false
                        self.touchLocation = -1
                    })
                )
            }
        }.background(Color.white)
    }
    
    func normalizedValue(index: Int) -> Double {
        return Double(data.data[index+1]!)/Double(data.maxValue)
    }
    
    private func getTouchingValue(width: CGFloat) -> Double? {
        guard data.data.count > 0 else { return nil}
        let index = max(0,min(data.data.count-1,Int(floor((self.touchLocation*width)/(width/CGFloat(data.data.count))))))
        return data.data[index+1]
    }
}

struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        let data = ChartViewData(title: "Actividad semanal",
                                barTitles: Calendar.current.shortWeekdaySymbols,
                                data: [1:50, 2:90, 3:80, 4:20, 5:100, 6:90, 7:7],
                                maxValue: 100)
        BarChartView(data: data)
    }
}
