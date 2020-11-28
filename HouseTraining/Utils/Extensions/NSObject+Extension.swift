//
//  NSObject.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 28/11/20.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
