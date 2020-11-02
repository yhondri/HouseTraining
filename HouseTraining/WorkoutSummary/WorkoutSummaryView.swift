//
//  WorkoutResumeView.swift
//  HouseTraining
//
//  Created by Yhondri on 02/11/2020.
//

import SwiftUI

struct WorkoutSummaryView: View {
    
    let workoutSummary: WorkoutSummary
    
    var body: some View {
        NavigationView {
            List {
                Section(header: WorkoutSummaryHeaderView(workoutSummary: workoutSummary)) {}.textCase(nil).listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                //                ForEach(activityViewModel.activities.keys.sorted(by: {$0 > $1}), id: \.self) { key in
                //                    Section(header: Text(key.mediumDate).padding(5)) {
                ForEach(0..<workoutSummary.exercises.count) {
                    WorkoutSummaryItemView(exercise: workoutSummary.exercises[$0])
                }
                .listRowBackground(Color.clear)
                //
                //                    }.listRowInsets(EdgeInsets())
                //                }
            }
            .listStyle(GroupedListStyle())
            .onAppear{UITableView.appearance().separatorColor = .clear}
            .background(Color.tableViewBackgroundColor)
            .navigationBarTitle(Text("Resumen"))
        }
    }
}

struct WorkoutResumeView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutSummary = WorkoutSummary.getPreview()
        WorkoutSummaryView(workoutSummary: workoutSummary)
    }
}
