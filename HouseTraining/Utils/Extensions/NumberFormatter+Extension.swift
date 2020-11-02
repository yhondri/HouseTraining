//
//  NumberFormatter+Extension.swift
//  HouseTraining
//
//  Created by Yhondri on 02/11/2020.
//

import Foundation

extension NumberFormatter {
    static let twoFractionDigits: NumberFormatter = {
        let formatter = NumberFormatter()
        //        formatter.roundingMode = .down
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let twoDigits: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
     }()
}
