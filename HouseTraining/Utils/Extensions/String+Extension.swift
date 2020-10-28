//
//  String+Extension.swift
//  HouseTraining
//
//  Created by Yhondri on 28/10/2020.
//

import Foundation

extension String {
    var localized: String {
        let value = NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        if value == self {
            return getFallbackValue()
        }
        
        return value
    }
    
    private func getFallbackValue() -> String {
        if let bundleIdentifier = Bundle.main.bundleIdentifier,
           let bundlePath = Bundle(identifier: bundleIdentifier)?.path(forResource: "es", ofType: "lproj") {
            let value = Bundle(path: bundlePath)?.localizedString(forKey: self, value: nil, table: nil) ?? ""
            return value
        } else {
            return ""
        }
    }
}
