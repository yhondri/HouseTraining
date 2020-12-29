//
//  MoreView.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 29/12/20.
//

import SwiftUI

struct DesignerData: Identifiable {
    let id = UUID()
    let text: String
    let link: URL
}

struct MoreView: View {
    let designers: [DesignerData]
    let theNounProjectURL: URL = URL(string: "https://thenounproject.com/")!
    @State var workoutViewIsActive = false

    init() {
        designers = [DesignerData(text: LocalizableKey.author1Text.localized,
                                  link: theNounProjectURL),
                     DesignerData(text: LocalizableKey.author2Text.localized,
                                  link: theNounProjectURL),
                     DesignerData(text: LocalizableKey.author3Text.localized,
                                  link: theNounProjectURL),
                     DesignerData(text: LocalizableKey.author4Text.localized,
                                  link: theNounProjectURL),
                     DesignerData(text: LocalizableKey.author5Text.localized,
                                  link: theNounProjectURL),
                     DesignerData(text: LocalizableKey.author6Text.localized,
                                  link: theNounProjectURL),
                     DesignerData(text: LocalizableKey.author7Text.localized,
                                  link: URL(string: "https://www.freepik.com/vectors/sport")!),
                     DesignerData(text: LocalizableKey.author8Text.localized,
                                  link: URL(string: "https://www.freepik.com/vectors/fitness")!),
        ]
    }
    
    var body: some View {
        List {
            Section(header: Text(LocalizableKey.developedBy.localized)) {
                DeveloperCreditRow()
            }
            
            Section(header: Text(LocalizableKey.supervisedBy.localized)) {
                Text(LocalizableKey.teacherName.localized)
            }
            
            Section(header: Text(LocalizableKey.termsOfUse.localized)) {
                ForEach(designers) { designer in
                    DesignerCreditsRow(designerData: designer)
                        .onTapGesture {
                            workoutViewIsActive.toggle()
                        }
                        .sheet(isPresented: $workoutViewIsActive) {
                            SafariView(url: designer.link)
                        }
                }
            }
            
        }.listStyle(InsetGroupedListStyle())
        .navigationBarTitle(Text(LocalizableKey.more.localized))
    }
}

struct DeveloperCreditRow: View {
    var body: some View {
        VStack(alignment: .center) {
            Text(LocalizableKey.developerText.localized)
            Image("ic_ucm")
        }
    }
}

struct SupervisedByRow: View {
    var body: some View {
        Text(LocalizableKey.supervisedBy.localized)
    }
}

struct DesignerCreditsRow: View {
    let designerData: DesignerData
    
    var body: some View {
        HStack {
            Text(designerData.text)
            Spacer()
            Image(systemName: "info.circle")
        }
    }
}

import UIKit
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    var url: URL
        
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}
