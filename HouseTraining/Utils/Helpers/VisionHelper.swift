//
//  VisionHelper.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 11/8/20.
//

import UIKit
import AVFoundation

struct VisionHelper {
    // This helper function is used to convert rects returned by Vision to the video content rect coordinates.
    //
    // The video content rect (camera preview or pre-recorded video)
    // is scaled to fit into the view controller's view frame preserving the video's aspect ratio
    // and centered vertically and horizontally inside the view.
    //
    // Vision coordinates have origin at the bottom left corner and are normalized from 0 to 1 for both dimensions.
    //
    static func viewRectForVisionRect(_ visionRect: CGRect,
                                      cameraFeedView: CameraFeedView,
                                      transfrom: CGAffineTransform = CGAffineTransform.verticalFlip) -> CGRect {
        let flippedRect = visionRect.applying(transfrom)
        return cameraFeedView.viewRectConverted(fromNormalizedContentsRect: flippedRect)
    }
    
    // This helper function is used to convert points returned by Vision to the video content rect coordinates.
    //
    // The video content rect (camera preview or pre-recorded video)
    // is scaled to fit into the view controller's view frame preserving the video's aspect ratio
    // and centered vertically and horizontally inside the view.
    //
    // Vision coordinates have origin at the bottom left corner and are normalized from 0 to 1 for both dimensions.
    //
   static func viewPointForVisionPoint(_ visionPoint: CGPoint, cameraFeedView: CameraFeedView) -> CGPoint {
        let flippedPoint = visionPoint.applying(CGAffineTransform.verticalFlip)
        return cameraFeedView.viewPointConverted(fromNormalizedContentsPoint: flippedPoint)
    }
}
