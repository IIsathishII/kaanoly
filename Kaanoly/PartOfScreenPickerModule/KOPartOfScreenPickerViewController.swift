//
//  KOPartOfScreenPickerViewController.swift
//  Kaanoly
//
//  Created by SathishKumar on 07/11/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOPartOfScreenPickerViewController : NSViewController {
    
    weak var propertiesManager : KOPropertiesDataManager?
    var dimView = KOPartOfScreenPickerView.init()
    var trackingArea : NSTrackingArea!

    var screenMask = CAShapeLayer.init()
    var startPoint : NSPoint?
    var cropRect : NSRect?
    
    var selectionView : KOPartOfScreenSelectionView?
    
    override func loadView() {
        self.view = NSFlippedView.init()
    }
    
    func setup(propertiesManager: KOPropertiesDataManager?) {
        self.propertiesManager = propertiesManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        
        self.setTrackingArea()
        
        dimView.wantsLayer = true
        dimView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        self.view.addSubview(dimView)
        dimView.autoresizingMask = [.width, .height]
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        screenMask.fillRule = .evenOdd
    }
    
    func setTrackingArea() {
        self.trackingArea = NSTrackingArea.init(rect: self.view.bounds, options: [.activeAlways, .enabledDuringMouseDrag, .inVisibleRect, .mouseEnteredAndExited], owner: self, userInfo: nil)
        self.view.addTrackingArea(self.trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.view.window?.makeKey()
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.propertiesManager?.viewDelegate?.clearPartOfScreenSelectionsInAllScreens()
        self.startPoint = self.view.convert(event.locationInWindow, from: nil)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        let currentPos = self.view.convert(event.locationInWindow, from: nil)
        let rectOrigin = self.getAdjustedOrigin(ForPoint: currentPos)
        self.cropRect = NSRect.init(origin: rectOrigin, size: CGSize.init(width: currentPos.x-self.startPoint!.x, height: currentPos.y-self.startPoint!.y))
        self.startPoint = nil
        self.setPartOfScreenSelection()
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        let currentPos = self.view.convert(event.locationInWindow, from: nil)
        let rectOrigin = self.getAdjustedOrigin(ForPoint: currentPos)
        self.cropRect = NSRect.init(origin: rectOrigin, size: CGSize.init(width: abs(currentPos.x-self.startPoint!.x), height: abs(currentPos.y-self.startPoint!.y)))
        self.setSelectionMask()
    }
    
    func getAdjustedOrigin(ForPoint point: NSPoint) -> NSPoint {
        var rectOrigin = self.startPoint!
        if point.x < rectOrigin.x {
            rectOrigin.x = point.x
        }
        if point.y < rectOrigin.y {
            rectOrigin.y = point.y
        }
        return rectOrigin
    }
    
    func setSelectionMask() {
        let path = NSBezierPath.init(rect: self.dimView.bounds)
        path.appendRect(self.cropRect!)
        screenMask.path = path.cgPath
        self.dimView.layer?.mask = screenMask
    }
    
    func setPartOfScreenSelection() {
        guard self.cropRect != nil else { return }
        self.cropRect!.size.width = max(self.cropRect!.width, 100)
        self.cropRect!.size.height = max(self.cropRect!.height, 100)
        self.setSelectionMask()
        self.selectionView = KOPartOfScreenSelectionView.init()
        self.selectionView?.viewDelegate = self
        self.view.addSubview(self.selectionView!, positioned: .below, relativeTo: self.dimView)
        self.selectionView?.frame = self.cropRect!
    }
    
    func clearPartOfScreenSelection() {
        self.selectionView?.removeFromSuperview()
        self.dimView.layer?.mask = nil
    }
}

extension KOPartOfScreenPickerViewController : KOPartOfScreenSelectionViewDelegate {
    
    func selectionAreaSelected() {
        self.propertiesManager?.setCropped(Rect: self.cropRect, displayId: (self.view.window as! KOPartOfScreenPickerWindow).displayId)
    }
}

class KOPartOfScreenPickerView : NSFlippedView {
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}
