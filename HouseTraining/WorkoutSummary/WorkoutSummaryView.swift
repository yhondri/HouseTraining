//
//  WorkoutResumeView.swift
//  HouseTraining
//
//  Created by Yhondri on 02/11/2020.
//

import SwiftUI

struct WorkoutSummaryView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let workoutSummary: WorkoutSummary

    var body: some View {
        ZStack {
            List {
                Section(header: WorkoutSummaryHeaderView(workoutSummary: workoutSummary)) {}.textCase(nil).listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                ForEach(0..<workoutSummary.exercises.count) {
                    WorkoutSummaryItemView(exercise: workoutSummary.exercises[$0])
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(GroupedListStyle())
            .onAppear{UITableView.appearance().separatorColor = .clear}
            
            VStack {
                Spacer()
                
                Button(LocalizableKey.save.localized, action: {
                    NotificationCenter.default.post(Notification(name: .dismissWorkoutWorkflow))
                })
                .foregroundColor(.white)
                .padding([.top, .bottom], 10)
                .padding([.leading, .trailing], 40)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
            }
            
        }
        .background(Color.tableViewBackgroundColor)
        .navigationBarTitle(Text(LocalizableKey.summary.localized))
        .navigationBarBackButtonHidden(true)
    }
}

struct WorkoutResumeView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutSummary = WorkoutSummary.getPreview()
        WorkoutSummaryView(workoutSummary: workoutSummary)
    }
}
