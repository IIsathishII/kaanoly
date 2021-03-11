//
//  KOCameraPreviewMovableViewResizeExtension.swift
//  Kaanoly
//
//  Created by SathishKumar on 01/09/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

extension KOCameraPreviewMovableView {
    
    func handleResize(Event event: NSEvent) {
        guard let pos = self.cursorPos, let scale = self.presenterDelegate?.overlayPresenterDelegate?.getPreviewScale(), let screenFrame = self.presenterDelegate?.propertiesManager?.getCurrentScreenFrame(), let diffX = self.presenterDelegate?.getDiff()?.x, let diffY = self.presenterDelegate?.getDiff()?.y else { return }
        let loc = self.convert(event.locationInWindow, from: nil)
        var viewRect = superview!.frame
        viewRect.origin.x += screenFrame.origin.x
        viewRect.origin.y += screenFrame.origin.y
        if let croppedRect = self.presenterDelegate?.propertiesManager?.getCroppedRect() {
            viewRect.origin.x -= croppedRect.origin.x
            viewRect.origin.y -= croppedRect.origin.y
        }
        
        let cornerSpacing = CGFloat(10)
        var delX = (pos == .topright || pos == .bottomright) ? event.deltaX : -event.deltaX
        var delY = event.deltaY
        let width = screenFrame.width * scale
        let size = KORecordingCoordinator.sharedInstance.getPreviewLayerSize()
        let height =  width * CGFloat(size.1)/CGFloat(size.0)
        var newWidth = (width + delX)
        let maxWidth = CameraPreviewConstants.Size.maxScale * screenFrame.width
        let minWidth = max(CameraPreviewConstants.Size.minScale * screenFrame.width, CGFloat(minPreviewWidth))
        var delWidth = delX
        var delHeight = delX*CGFloat(size.1)/CGFloat(size.0)
        if let holdX = self.presenterDelegate?.getHoldLocX() {
            if pos == .topright || pos == .bottomright {
                if !((width == maxWidth && (loc.x <= self.frame.origin.x + self.frame.width)) || (width == minWidth && (loc.x >= self.frame.origin.x + self.frame.width - cornerSpacing) || (delX < 0 && (loc.x <= self.frame.origin.x + self.frame.width)))) { return }
            } else if pos == .topleft || pos == .bottomleft {
                if !((width == maxWidth && (loc.x >= self.frame.origin.x)) || (width == minWidth && (loc.x <= self.frame.origin.x + cornerSpacing)) || (-delX > 0 && (loc.x >= self.frame.origin.x))) { return }
            }
            self.presenterDelegate?.setHoldLoc(X: nil)
        }
        if !(newWidth <= maxWidth && newWidth >= minWidth) {
            newWidth = newWidth >= maxWidth ? maxWidth : minWidth
            if self.presenterDelegate?.getHoldLocX() == nil {
                self.presenterDelegate?.setHoldLoc(X: diffX)
            }
            delWidth = newWidth - width
            delHeight = delWidth*CGFloat(size.1)/CGFloat(size.0)
            if delWidth == 0 {
                return
            }
        }
        if pos == .topleft {
            let leftBorderDiff = getLeftBorderOffset(previewRect: viewRect, recordingFrame: screenFrame, delWidth: delWidth)
            if newWidth > width && leftBorderDiff < 0 {
                newWidth += leftBorderDiff
                delWidth += leftBorderDiff
                delHeight = delWidth*CGFloat(size.1)/CGFloat(size.0)
                self.presenterDelegate?.setHoldLoc(X: diffX)
            }
            self.presenterDelegate?.overlayPresenterDelegate?.setPreview(Scale: newWidth/screenFrame.width)
            delY = -delHeight
            if self.getTopBorderOffset(previewRect: viewRect, recordingFrame: screenFrame, delHeight: delHeight) < 0 {
                delY = 0
            }
        } else if pos == .topright {
            let rightBorderDiff = getRightBorderOffset(previewRect: viewRect, recordingFrame: screenFrame, delWidth: delWidth)
            if newWidth > width && rightBorderDiff > 0 {
                newWidth -= rightBorderDiff
                delWidth -= rightBorderDiff
                delHeight = delWidth*CGFloat(size.1)/CGFloat(size.0)
                self.presenterDelegate?.setHoldLoc(X: diffX)
            }
            self.presenterDelegate?.overlayPresenterDelegate?.setPreview(Scale: newWidth/screenFrame.width)
            delY = -delHeight
            if self.getTopBorderOffset(previewRect: viewRect, recordingFrame: screenFrame, delHeight: delHeight) < 0 {
                delY = 0
            }
        } else if pos == .bottomleft {
            let leftBorderDiff = getLeftBorderOffset(previewRect: viewRect, recordingFrame: screenFrame, delWidth: delWidth)
            if newWidth > width && leftBorderDiff < 0 {
                newWidth += leftBorderDiff
                delWidth += leftBorderDiff
                delHeight = delWidth*CGFloat(size.1)/CGFloat(size.0)
                self.presenterDelegate?.setHoldLoc(X: diffX)
            }
            self.presenterDelegate?.overlayPresenterDelegate?.setPreview(Scale: newWidth/screenFrame.width)
            delY = 0
            if self.getBottomBorderOffset(previewRect: viewRect, recordingFrame: screenFrame, delHeight: delHeight) > 0 {
                delY = -delHeight
            }
        } else if pos == .bottomright {
            let rightBorderDiff = getRightBorderOffset(previewRect: viewRect, recordingFrame: screenFrame, delWidth: delWidth)
            if newWidth > width && rightBorderDiff > 0 {
                newWidth -= rightBorderDiff
                delWidth -= rightBorderDiff
                delHeight = delWidth*CGFloat(size.1)/CGFloat(size.0)
                self.presenterDelegate?.setHoldLoc(X: diffX)
            }
            self.presenterDelegate?.overlayPresenterDelegate?.setPreview(Scale: newWidth/screenFrame.width)
            delY = 0
            if self.getBottomBorderOffset(previewRect: viewRect, recordingFrame: screenFrame, delHeight: delHeight) > 0 {
                delY = -delHeight
            }
        }
        if let croppedRect = self.presenterDelegate?.propertiesManager?.getCroppedRect() {
            viewRect.origin.x += croppedRect.origin.x
            viewRect.origin.y += croppedRect.origin.y
        }
        self.presenterDelegate?.viewDelegate?.resizeCameraPreview(delX: (pos == .topright || pos == .bottomright) ? 0 : -delX, delY: delY, delWidth: delWidth, delHeight: delHeight)
    }
    
    func getRightBorderOffset(previewRect: NSRect, recordingFrame: NSRect, delWidth: CGFloat) -> CGFloat {
        return ((previewRect.origin.x + previewRect.size.width + delWidth) - (recordingFrame.origin.x + recordingFrame.size.width - CameraPreviewConstants.horizontalSpacing))
    }
    
    func getTopBorderOffset(previewRect: NSRect, recordingFrame: NSRect, delHeight: CGFloat) -> CGFloat {
        return ((previewRect.origin.y - delHeight) - (recordingFrame.origin.y + CameraPreviewConstants.verticalSpacing))
    }
    
    func getBottomBorderOffset(previewRect: NSRect, recordingFrame: NSRect, delHeight: CGFloat) -> CGFloat {
        return ((previewRect.origin.y + previewRect.size.height + delHeight) - (recordingFrame.origin.y + recordingFrame.size.height - CameraPreviewConstants.verticalSpacing))
    }
    
    func getLeftBorderOffset(previewRect: NSRect, recordingFrame: NSRect, delWidth: CGFloat) -> CGFloat {
        return ((previewRect.origin.x - delWidth) - (recordingFrame.origin.x + CameraPreviewConstants.horizontalSpacing))
    }
}
