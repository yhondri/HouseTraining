//
//  WorkoutSummaryItemView.swift
//  HouseTraining
//
//  Created by Yhondri on 02/11/2020.
//

import SwiftUI

struct WorkoutSummaryItemView: View {
    
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "calendar.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(Color.green)
            
            VStack(alignment: .leading) {
                Text(exercise.actionName)
                    .font(.subheadline)
                    .foregroundColor(.itemTextColor)
                Text(exercise.scoreValue)
                    .font(.largeTitle)
            }
            Spacer()
        }
        .padding(5)
        .background(Color.itemBackgroundColor)
        .cornerRadius(12)
    }
}

struct WorkoutSummaryItemView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutSummaryItemView(exercise: JumpingJacks())
    }
}
