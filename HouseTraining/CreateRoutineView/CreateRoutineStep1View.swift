//
//  CreateRoutineView.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 23/11/20.
//

import SwiftUI

struct CreateRoutineStep1View: View {
    @StateObject var createRoutineViewModel: CreateRoutineViewModel = CreateRoutineViewModel()
    let exercises: [Exercise] = Exercise.getAvaialableExercises()
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    Section(header: Text("Selecciona los ejercicios").padding()) {
                        ForEach(0 ..< createRoutineViewModel.availableExercises.count, id: \.self) { index in
                            CreateRoutineRowView(createRoutineViewModel: createRoutineViewModel,
                                                 index: index, exercise:
                                                    createRoutineViewModel.availableExercises[index])
                                .roundedCorner(with: Color.itemBackgroundColor)
                        }
                    }
                }
                .padding(.top, 10)
            }
            VStack {
                Spacer()
                
                NavigationLink(LocalizableKey.next.localized, destination: CreateRoutineStep2ControllerRepresentable(exercises: createRoutineViewModel.getExercises())
                                .navigationTitle(LocalizableKey.sortExercises.localized)) //UIKit bug? Cannot change title in UIViewControllerRepresentable
                    .disabled(!createRoutineViewModel.canGoToNextView)
                    .foregroundColor(.white)
                    .padding([.top, .bottom], 10)
                    .padding([.leading, .trailing], 40)
                    .background(createRoutineViewModel.canGoToNextView ? Color.blue : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
            }
        }
        .background(Color.tableViewBackgroundColor)
        .navigationBarTitle(Text(LocalizableKey.newRoutine.localized))
    }
}

struct CreateRoutineRowView: View {
    @ObservedObject var createRoutineViewModel: CreateRoutineViewModel
    let index: Int
    @State var isAdded: Bool = false
    let exercise: Exercise
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: .init(colors: [Color.charBarTopColor, Color.charBarBottomColor]),
                        startPoint: .init(x: 0.5, y: 0),
                        endPoint: .init(x: 0.5, y: 0.6)
                    ))
                    .frame(width: 50, height: 50)
                Image(exercise.imageName)
                    .resizable()
                    .frame(width: 35, height: 35)
            } 
            Text(exercise.actionName)
            Spacer()
            Button(action: {
                if isAdded {
                    createRoutineViewModel.deleteExercise(at: index)
                } else {
                    createRoutineViewModel.addExercise(at: index)
                }
                
                self.isAdded.toggle()
            }) {
                if isAdded {
                    Image(systemName: "minus")
                } else {
                    Image(systemName: "plus")
                }
            }
        }.padding(.leading)
    }
}

struct CreateRoutineView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoutineStep1View()
            .environmentObject(CreateRoutineViewModel())
    }
}
