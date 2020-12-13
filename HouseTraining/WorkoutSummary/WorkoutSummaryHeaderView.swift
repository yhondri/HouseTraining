//
//  WorkoutSummaryHeaderView.swift
//  HouseTraining
//
//  Created by Yhondri on 02/11/2020.
//

import SwiftUI

struct WorkoutSummaryHeaderView: View {
    
    let workoutSummary: WorkoutSummary
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<2) { i in
                switch i {
                case 0:
                    BoxView(title: LocalizableKey.duration.localized,
                            value: workoutSummary.successRate,
                            imageColor: .blue,
                            imageName: "calendar.circle.fill")
                case 1:
                    BoxView(title: LocalizableKey.successRate.localized,
                            value: workoutSummary.successRate,
                            imageColor: .green,
                            imageName: "star.circle.fill")
                case 2:
                    BoxView(title: LocalizableKey.heartRate.localized,
                            value: workoutSummary.heartRate,
                            imageColor: .blue,
                            imageName: "calendar.circle.fill")
                case 3:
                    BoxView(title: LocalizableKey.calories.localized,
                            value: workoutSummary.caloriesBurned,
                            imageColor: .red,
                            imageName: "calendar.circle.fill")
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
    let imageName: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
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
