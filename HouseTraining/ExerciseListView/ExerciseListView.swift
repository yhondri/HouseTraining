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
        .frame(minHeight: 70)
    }
    
    private func getDataView() -> some View {
        ZStack {
            HStack {
                Image("ic_temp_activity")
                    .padding(.leading, 2)
                    .padding(.trailing, 6)
                VStack {
                    HStack(alignment: .top) {
                        Text(exercise.name)
                            .font(.body)
                            .fontWeight(.medium)
                        Spacer()
                        HStack {
                        Text("22-02-1993")
                            .font(Font.system(size: 10))
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                        }
                        .padding(.top, 3)
                        
                    }
                    Spacer()
                }
            }
        }
        .roundedCorner(with: .itemBackgroundColor)
        .frame(maxHeight: .infinity)
    }
}

struct ExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseListView()
    }
}
