//
//  ChartGridView.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 30/11/20.
//

import SwiftUI

struct ChartGridView: View {
    @ObservedObject var chartGridViewModel = ChartGridViewModel()

    @ViewBuilder var body: some View {
        if chartGridViewModel.charts.isEmpty {
             getEmtpyView()
        } else {
             getBodyWithData()
        }
    }
    
    private func getEmtpyView() -> some View {
        VStack(alignment: .center) {
            Image("no_chart_data")
                .resizable()
                .frame(width: 300, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            Text(LocalizableKey.chartsViewNoData.localized)
                .multilineTextAlignment(.center)
                .padding()
        }
        .navigationBarTitle(Text(LocalizableKey.charts.localized))
    }
    
    private func getBodyWithData() ->  some View {
        ScrollView {
            LazyVStack {
                ForEach(chartGridViewModel.charts, id: \.self) { data in
                    BarChartView(data: data)
                        .frame(height: 200)
                        .roundedCorner(with: Color.itemBackgroundColor)
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
