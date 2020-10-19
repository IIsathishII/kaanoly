//
//  KOCameraPreviewMovableViewDragExtension.swift
//  Kaanoly
//
//  Created by SathishKumar on 01/09/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

extension KOCameraPreviewMovableView {
    
    func handleDrag(Event event: NSEvent) {
        guard let screenFrame = self.presenterDelegate?.propertiesManager?.getCurrentScreenFrame() else { return }
        var viewRect = superview!.frame
        viewRect.origin.x += screenFrame.origin.x
        viewRect.origin.y += screenFrame.origin.y
        var delX: CGFloat = 0, delY: CGFloat = 0
        var isAnimated = false
        guard let diffX = self.presenterDelegate?.getDiff()?.x, let diffY = self.presenterDelegate?.getDiff()?.y else { return }
        if self.presenterDelegate?.getIsPinnedToCorner() == false {
            if self.presenterDelegate?.getHoldLocX() == nil {
                if viewRect.origin.x + event.deltaX >= screenFrame.origin.x + CameraPreviewConstants.horizontalSpacing && viewRect.origin.x + event.deltaX + viewRect.width <= screenFrame.origin.x + screenFrame.width-CameraPreviewConstants.horizontalSpacing {
                    delX = event.deltaX
                } else {
                    if event.deltaX < 0, viewRect.origin.x - (screenFrame.origin.x + CameraPreviewConstants.horizontalSpacing) > 0 {
                        delX =  -(viewRect.origin.x - (screenFrame.origin.x + CameraPreviewConstants.horizontalSpacing))
                    } else if event.deltaX > 0, (screenFrame.origin.x + screenFrame.width) - (CameraPreviewConstants.horizontalSpacing + viewRect.origin.x + viewRect.width) > 0 {
                        delX = (screenFrame.origin.x + screenFrame.width) - (CameraPreviewConstants.horizontalSpacing + viewRect.origin.x + viewRect.width)
                    }
                    self.presenterDelegate?.setHoldLoc(X: diffX)
                }
            } else {
                let loc = self.convert(event.locationInWindow, from: nil)
                if (viewRect.origin.x == screenFrame.origin.x + CameraPreviewConstants.horizontalSpacing && loc.x >= diffX) || (viewRect.origin.x+CameraPreviewConstants.horizontalSpacing+viewRect.width == screenFrame.origin.x + screenFrame.width && loc.x <= diffX) {
                    self.presenterDelegate?.setHoldLoc(X: nil)
                    delX = loc.x - diffX
                }
            }
            if self.presenterDelegate?.getHoldLocY() == nil {
                if viewRect.origin.y + event.deltaY >= screenFrame.origin.y + CameraPreviewConstants.verticalSpacing && viewRect.origin.y + event.deltaY + viewRect.height <= screenFrame.origin.y + screenFrame.height - CameraPreviewConstants.verticalSpacing {
                    delY = event.deltaY
                } else {
                    if event.deltaY < 0, viewRect.origin.y - (screenFrame.origin.y + CameraPreviewConstants.verticalSpacing) > 0 {
                        delY = -(viewRect.origin.y - (screenFrame.origin.y + CameraPreviewConstants.verticalSpacing))
                    } else if event.deltaY > 0, (screenFrame.origin.y + screenFrame.height) - (CameraPreviewConstants.verticalSpacing + viewRect.origin.y + viewRect.height) > 0 {
                        delY = (screenFrame.origin.y + screenFrame.height) - (CameraPreviewConstants.verticalSpacing + viewRect.origin.y + viewRect.height)
                    }
                    self.presenterDelegate?.setHoldLoc(Y: diffY)
                }
            } else {
                let loc = self.convert(event.locationInWindow, from: nil)
                if (viewRect.origin.y == screenFrame.origin.y + CameraPreviewConstants.verticalSpacing && loc.y >= diffY) || (viewRect.origin.y+CameraPreviewConstants.verticalSpacing+viewRect.height == screenFrame.origin.y + screenFrame.height && loc.y <= diffY) {
                    self.presenterDelegate?.setHoldLoc(Y: nil)
                    delY = loc.y - diffY
                }
            }
        }
        let loc = self.convert(event.locationInWindow, from: nil)
        if self.presenterDelegate?.getIsPinnedToCorner() == false && self.presenterDelegate?.getHoldLocX() != nil && self.presenterDelegate?.getHoldLocY() != nil {
            if (self.canPreviewBePinnedToBottomLeft(previewRect: viewRect, recordingFrame: screenFrame) && loc.x < diffX - CameraPreviewConstants.horizontalSpacing && loc.y > diffY + CameraPreviewConstants.verticalSpacing) {
                delX = -CameraPreviewConstants.horizontalSpacing
                delY = CameraPreviewConstants.verticalSpacing
                self.presenterDelegate?.setIsPinnedToCorner(true)
            } else if (self.canPreviewBePinnedToBottomRight(previewRect: viewRect, recordingFrame: screenFrame) && loc.x > diffX + CameraPreviewConstants.horizontalSpacing && loc.y > diffY + CameraPreviewConstants.verticalSpacing) {
                delX = CameraPreviewConstants.horizontalSpacing
                delY = CameraPreviewConstants.verticalSpacing
                self.presenterDelegate?.setIsPinnedToCorner(true)
            } else if (self.canPreviewBePinnedToTopLeft(previewRect: viewRect, recordingFrame: screenFrame) && loc.x < diffX - CameraPreviewConstants.horizontalSpacing && loc.y < diffY - CameraPreviewConstants.verticalSpacing ) {
                delX = -CameraPreviewConstants.horizontalSpacing
                delY = -CameraPreviewConstants.verticalSpacing
                self.presenterDelegate?.setIsPinnedToCorner(true)
            } else if (self.canPreviewBePinnedToTopRight(previewRect: viewRect, recordingFrame: screenFrame) && loc.x > diffX + CameraPreviewConstants.horizontalSpacing && loc.y < diffY - CameraPreviewConstants.verticalSpacing) {
                delX = CameraPreviewConstants.horizontalSpacing
                delY = -CameraPreviewConstants.verticalSpacing
                self.presenterDelegate?.setIsPinnedToCorner(true)
            }
            if self.presenterDelegate?.getIsPinnedToCorner() == true {
                isAnimated = true
            }
        } else if self.presenterDelegate?.getIsPinnedToCorner() == true {
            if (self.isPreviewPinnedToBottomLeft(previewRect: viewRect, recordingFrame: screenFrame) && loc.x >= diffX + CameraPreviewConstants.horizontalSpacing && loc.y <= diffY - CameraPreviewConstants.verticalSpacing)  {
                self.presenterDelegate?.setIsPinnedToCorner(false)
            } else if (self.isPreviewPinnedToBottomRight(previewRect: viewRect, recordingFrame: screenFrame) && loc.x <= diffX - CameraPreviewConstants.horizontalSpacing && loc.y <= diffY - CameraPreviewConstants.verticalSpacing) {
                self.presenterDelegate?.setIsPinnedToCorner(false)
            } else if (self.isPreviewPinnedToTopLeft(previewRect: viewRect, recordingFrame: screenFrame) && loc.x >= diffX + CameraPreviewConstants.horizontalSpacing && loc.y >= diffY + CameraPreviewConstants.verticalSpacing) {
                self.presenterDelegate?.setIsPinnedToCorner(false)
            } else if (self.isPreviewPinnedToTopRight(previewRect: viewRect, recordingFrame: screenFrame) && loc.x <= diffX - CameraPreviewConstants.horizontalSpacing && loc.y >= diffY + CameraPreviewConstants.verticalSpacing) {
                self.presenterDelegate?.setIsPinnedToCorner(false)
            }
            if self.presenterDelegate?.getIsPinnedToCorner() == false {
                //TODO :: Check del values for part of screen cases.
                delX = (loc.x - diffX)
                delY = (loc.y - diffY)
                isAnimated = true
                if viewRect.origin.x + delX >= screenFrame.origin.x + CameraPreviewConstants.horizontalSpacing && viewRect.origin.x + delX + viewRect.width <= screenFrame.origin.x + screenFrame.width-CameraPreviewConstants.horizontalSpacing {
                    self.presenterDelegate?.setHoldLoc(X: nil)
                } else {
                    if viewRect.origin.x + delX >= screenFrame.origin.x + CameraPreviewConstants.horizontalSpacing {
                        delX = screenFrame.origin.x+screenFrame.width-viewRect.width-CameraPreviewConstants.horizontalSpacing
                    } else {
                        delX = -(viewRect.origin.x-CameraPreviewConstants.horizontalSpacing)
                    }
                }
                if viewRect.origin.y + delY >= screenFrame.origin.y + CameraPreviewConstants.verticalSpacing && viewRect.origin.y + delY + viewRect.height <= screenFrame.origin.y + screenFrame.height - CameraPreviewConstants.verticalSpacing {
                    self.presenterDelegate?.setHoldLoc(Y: nil)
                } else {
                    if viewRect.origin.y + delY >= screenFrame.origin.y + CameraPreviewConstants.verticalSpacing {
                        delY = screenFrame.origin.y+screenFrame.height-viewRect.height-CameraPreviewConstants.verticalSpacing
                    } else {
                        delY = -(viewRect.origin.y-CameraPreviewConstants.verticalSpacing)
                    }
                }
            }
        }
        viewRect.origin.x -= screenFrame.origin.x
        viewRect.origin.y -= screenFrame.origin.y        
        self.presenterDelegate?.viewDelegate?.moveCameraPreview(locX: viewRect.origin.x+delX, locY: viewRect.origin.y+delY, isAnimated: isAnimated)
    }
    
    func canPreviewBePinnedToBottomLeft(previewRect: NSRect, recordingFrame: NSRect) -> Bool {
        return (previewRect.origin.x == recordingFrame.origin.x + CameraPreviewConstants.horizontalSpacing && previewRect.origin.y + previewRect.size.height + CameraPreviewConstants.verticalSpacing == recordingFrame.origin.y + recordingFrame.height)
    }
    
    func canPreviewBePinnedToBottomRight(previewRect: NSRect, recordingFrame: NSRect) -> Bool {
        return (previewRect.origin.x + previewRect.size.width + CameraPreviewConstants.horizontalSpacing == recordingFrame.origin.x + recordingFrame.width && previewRect.origin.y + previewRect.size.height + CameraPreviewConstants.verticalSpacing == recordingFrame.origin.y + recordingFrame.height)
    }
    
    func canPreviewBePinnedToTopLeft(previewRect: NSRect, recordingFrame: NSRect) -> Bool {
        return (previewRect.origin.x == recordingFrame.origin.x + CameraPreviewConstants.horizontalSpacing && previewRect.origin.y == recordingFrame.origin.y + CameraPreviewConstants.verticalSpacing)
    }
    
    func canPreviewBePinnedToTopRight(previewRect: NSRect, recordingFrame: NSRect) -> Bool {
        return (previewRect.origin.x + previewRect.size.width + CameraPreviewConstants.horizontalSpacing == recordingFrame.origin.x + recordingFrame.width && previewRect.origin.y == recordingFrame.origin.y + CameraPreviewConstants.verticalSpacing)
    }
    
    func isPreviewPinnedToBottomLeft(previewRect: NSRect, recordingFrame: NSRect) -> Bool {
        return (previewRect.origin.x == recordingFrame.origin.x && previewRect.origin.y + previewRect.size.height == recordingFrame.origin.y + recordingFrame.height)
    }
    
    func isPreviewPinnedToBottomRight(previewRect: NSRect, recordingFrame: NSRect) -> Bool {
        return (previewRect.origin.x + previewRect.size.width == recordingFrame.origin.x + recordingFrame.width && previewRect.origin.y + previewRect.size.height == recordingFrame.origin.y + recordingFrame.height)
    }
    
    func isPreviewPinnedToTopLeft(previewRect: NSRect, recordingFrame: NSRect) -> Bool {
        return (previewRect.origin.x == recordingFrame.origin.x && previewRect.origin.y == recordingFrame.origin.y)
    }
    
    func isPreviewPinnedToTopRight(previewRect: NSRect, recordingFrame: NSRect) -> Bool {
        return (previewRect.origin.x + previewRect.size.width == recordingFrame.origin.x + recordingFrame.width && previewRect.origin.y == recordingFrame.origin.y)
    }
}
