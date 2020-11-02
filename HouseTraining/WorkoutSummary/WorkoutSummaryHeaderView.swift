//
//  WorkoutSummaryHeaderView.swift
//  HouseTraining
//
//  Created by Yhondri on 02/11/2020.
//

import SwiftUI

struct WorkoutSummaryHeaderView: View {
    
    let workoutSummary: WorkoutSummary
    
    let titles = ["Duration", "Success Rate", "Heart rate", "Calories Burned"]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
   var body: some View {
       LazyVGrid(columns: columns, spacing: 10) {
           ForEach(0..<4) { i in
               switch i {
               case 0:
                BoxView(title: titles[0], value: workoutSummary.successRate, imageColor: .blue)
               case 1:
                   BoxView(title: titles[1], value: workoutSummary.successRate, imageColor: .blue)
               case 2:
                   BoxView(title: titles[2], value: workoutSummary.heartRate, imageColor: .blue)
               case 3:
                   BoxView(title: titles[3], value: workoutSummary.caloriesBurned, imageColor: .red)
               default:
                   fatalError("Caso no contemplado")
               }
           }
       }
   }
}

struct BoxView: View {
    let title: String
    let value: Double
    let imageColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: "calendar.circle.fill")
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundColor(Color.blue)
            
            VStack {
                Spacer(minLength: 5)
                Text(title)
                    .font(.subheadline)
                if let value = NumberFormatter.twoFractionDigits.string(from: NSNumber(value: value)) {
                    Text("\(value)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.itemTextColor)
               }
                Spacer(minLength: 5)
            }
            
            Spacer()
        }
        .padding(5)
        .background(Color.itemBackgroundColor)
        .cornerRadius(12)
    }
}

struct WorkoutSummaryHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutSummary = WorkoutSummary.getPreview()
        WorkoutSummaryHeaderView(workoutSummary: workoutSummary)
    }
}
