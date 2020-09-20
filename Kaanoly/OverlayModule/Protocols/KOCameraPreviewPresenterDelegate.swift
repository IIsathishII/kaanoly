//
//  KOCameraPreviewPresenterDelegate.swift
//  Kaanoly
//
//  Created by SathishKumar on 06/09/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import Foundation

protocol KOCameraPreviewPresenterDelegate : class {
    
    var viewDelegate : KOOverlayViewDelegate? { get set }
    var overlayPresenterDelegate : KOOverlayPresenterDelegate? { get set }
    var propertiesManager : KOPropertiesDataManager? { get set }
    
    func setDiff(_ diff: NSPoint?)
    func getDiff() -> NSPoint?
    func setHoldLoc(X x: CGFloat?)
    func getHoldLocX() -> CGFloat?
    func setHoldLoc(Y y: CGFloat?)
    func getHoldLocY() -> CGFloat?
    func setIsPinnedToCorner(_ val: Bool)
    func getIsPinnedToCorner() -> Bool
    func setCanResize(_ val: Bool)
    func getCanResize() -> Bool
    func setIsResizing(_ val: Bool)
    func getIsResizing() -> Bool
}
