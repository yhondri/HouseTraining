//
//  ChartGridView.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 30/11/20.
//

import SwiftUI

struct ChartGridView: View {
    @ObservedObject var chartGridViewModel = ChartGridViewModel()

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(chartGridViewModel.charts, id: \.self) { data in
                    BarChartView(data: data)
                        .frame(height: 200)
                        .roundedCorner()
                }
            }
            .padding([.top, .bottom], 10)
            .padding([.leading, .trailing], 5)
        }
        .background(Color.tableViewBackgroundColor)
        .navigationBarTitle(Text(LocalizableKey.charts.localized))
    }
}

struct ChartGridView_Previews: PreviewProvider {
    static var previews: some View {
        ChartGridView()
    }
}
