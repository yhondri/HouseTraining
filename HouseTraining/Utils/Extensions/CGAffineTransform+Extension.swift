//
//  CGAffineTransform+Extension.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 31/3/21.
//

import UIKit

extension CGAffineTransform {
    static var verticalFlip = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
    static var horizontalFlip = CGAffineTransform(rotationAngle: CGFloat.pi/2).translatedBy(x: 0, y: -1)
}


