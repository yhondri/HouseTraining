//
//  ExerciseListView.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 22/11/20.
//

import SwiftUI
import Introspect

struct ExerciseListView: View {

    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: ExerciseEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseEntity.name, ascending: true)]
    ) var exercises: FetchedResults<ExerciseEntity>
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(exercises, id: \.self) { exercise in
                    ExercieRowView(exercise: exercise)
                        .listRowInsets(EdgeInsets())
                    
                }
            }
            .padding(.top, 10)
        }
        .background(Color.tableViewBackgroundColor)
        .navigationBarTitle(Text(LocalizableKey.exercises.localized))
    }
}

struct ExercieRowView: View {
    let exercise: ExerciseEntity
    
    var body: some View {
        NavigationLink(destination: Text("Somewhere")) {
            getDataView()
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.leading, 5)
        .padding(.trailing, 5)
        .frame(minHeight: 70)
    }
    
    private func getDataView() -> some View {
        ZStack {
            Color.white
                .cornerRadius(12)
            HStack {
                Image("ic_temp_activity")
                    .padding(.trailing, 8)
                VStack(alignment: .leading) {
                    Text(exercise.name)
                        .font(.body)
                        .fontWeight(.medium)
                    HStack {
                        Spacer()
                        Text("22-02-1993")
                            .font(Font.system(size: 10))
                        Image(systemName: "chevron.right")
                    }
                }
                Spacer()
            }.padding(.leading)
        }.frame(maxHeight: .infinity)
    }
}

struct ExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseListView()
    }
}
