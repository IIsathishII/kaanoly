//
//  KOOverlayViewDelegate.swift
//  Kaanoly
//
//  Created by SathishKumar on 06/09/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import Foundation

protocol KOOverlayViewDelegate : class {
    
    func setCameraPreview()
    func removeCameraPreview()
    func resetCameraPreviewPosition()
    
    func moveCameraPreview(locX: CGFloat, locY: CGFloat, isAnimated: Bool)
    func adjustCameraPreviewStyle(isPinnedToCorner: Bool)
    func resizeCameraPreview(delX: CGFloat, delY: CGFloat, delWidth: CGFloat, delHeight: CGFloat)
}
