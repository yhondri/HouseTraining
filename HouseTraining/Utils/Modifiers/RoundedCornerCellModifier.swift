//
//  RoundedCornerCellModifier.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 23/11/20.
//

import SwiftUI

struct RoundedCornerCellModifier: ViewModifier {
    var backgroundColor: Color
    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.leading, 10)
            .padding(.trailing, 10)
    }
}

extension View {
    func roundedCorner(with backgroundColor: Color = .white) -> some View {
        modifier(RoundedCornerCellModifier(backgroundColor: backgroundColor))
    }
}
