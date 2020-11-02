//
//  Double+Extension.swift
//  Mis Horas
//
//  Created by Yhondri on 23/09/2020.
//

import UIKit

extension Double {
    func getWithTwoDecimals() -> String {
        NumberFormatter.twoDigits.string(from: NSNumber(value: self)) ?? "--"
    }
}
