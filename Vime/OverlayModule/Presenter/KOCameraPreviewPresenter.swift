//
//  KOCameraPreviewPresenter.swift
//  Kaanoly
//
//  Created by SathishKumar on 06/09/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOCameraPreviewPresenter : KOCameraPreviewPresenterDelegate {
    
    weak var viewDelegate : KOOverlayViewDelegate?
    weak var overlayPresenterDelegate : KOOverlayPresenterDelegate?
    weak var propertiesManager : KOPropertiesDataManager?
    
    var diff : NSPoint?
    var holdLocX : CGFloat?
    var holdLocY : CGFloat?

    var isPinnedToCorner = false {
        didSet {
            self.viewDelegate?.adjustCameraPreviewStyle(isPinnedToCorner: self.isPinnedToCorner)
        }
    }
    
    var canResize = false
    var isResizing = false
    
    init() {}
    
    func setDiff(_ diff: NSPoint?) {
        self.diff = diff
    }
    
    func getDiff() -> NSPoint? {
        return self.diff
    }
    
    func setHoldLoc(X x: CGFloat?) {
        self.holdLocX = x
    }
    
    func getHoldLocX() -> CGFloat? {
        return self.holdLocX
    }
    
    func setHoldLoc(Y y: CGFloat?) {
        self.holdLocY = y
    }
    
    func getHoldLocY() -> CGFloat? {
        return self.holdLocY
    }
    
    func setIsPinnedToCorner(_ val: Bool) {
        self.isPinnedToCorner = val
    }
    
    func getIsPinnedToCorner() -> Bool {
        return self.isPinnedToCorner
    }
    
    func setCanResize(_ val: Bool) {
        self.canResize = val
    }
    
    func getCanResize() -> Bool {
        return self.canResize
    }
    
    func setIsResizing(_ val: Bool) {
        self.isResizing = val
    }
    
    func getIsResizing() -> Bool {
        return self.isResizing
    }
}
