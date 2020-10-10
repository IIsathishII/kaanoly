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
        guard let pos = self.cursorPos, let scale = self.presenterDelegate?.overlayPresenterDelegate?.getPreviewScale(), let screenFrame = self.presenterDelegate?.propertiesManager?.getCurrentScreenFrame() else { return }
        var viewRect = superview!.frame
        viewRect.origin.x += screenFrame.origin.x
        viewRect.origin.y += screenFrame.origin.y
        
        var delX = event.deltaX
        var delY = event.deltaY
        let width = screenFrame.width * scale
        let size = KORecordingCoordinator.sharedInstance.getPreviewLayerSize()
        let height =  width * CGFloat(size.1)/CGFloat(size.0)
        if pos == .topleft {
//            self.presenterDelegate?.overlayPresenterDelegate?.setPreview(Scale: <#T##CGFloat#>)
        } else if pos == .topright {
//            if delX > delY {
//                delY =
//            } else {
//                self.presenterDelegate?.overlayPresenterDelegate?.setPreview(Scale: (height+))
//            }
//            self.presenterDelegate?.overlayPresenterDelegate?.setPreview(Scale: (width+delX)/screenFrame.width)
        } else if pos == .bottomleft {
            
        } else if pos == .bottomright {
            
        }
        if pos == .right {
            var newWidth = (width + delX)
            let maxWidth = CameraPreviewConstants.Size.maxScale * screenFrame.width
            let minWidth = CameraPreviewConstants.Size.minScale * screenFrame.width
            var delWidth = delX
            var delHeight = delX*CGFloat(size.1)/CGFloat(size.0)
            
            if !(newWidth <= maxWidth && newWidth >= minWidth) {
                newWidth = newWidth >= maxWidth ? maxWidth : minWidth
                delWidth = newWidth - width
                delHeight = delWidth*CGFloat(size.1)/CGFloat(size.0)
                if delWidth == 0 {
                    return
                }
            }
            if newWidth > width && self.isPreviewOnRightBorder(previewRect: viewRect, recordingFrame: screenFrame) {
                return
            }
            self.presenterDelegate?.overlayPresenterDelegate?.setPreview(Scale: newWidth/screenFrame.width)
            delY = -delHeight/2
            if self.isPreviewOnBottomBorder(previewRect: viewRect, recordingFrame: screenFrame) {
                delY = -delHeight
            } else if self.isPreviewOnTopBorder(previewRect: viewRect, recordingFrame: screenFrame) {
                delY = 0
            }
            if viewRect.origin.y + viewRect.size.height + delY + delHeight > screenFrame.origin.y + screenFrame.size.height - CameraPreviewConstants.verticalSpacing {
                delY = -delHeight/2 - ((viewRect.origin.y + viewRect.size.height + delY + delHeight) - (screenFrame.origin.y + screenFrame.size.height - CameraPreviewConstants.verticalSpacing))
            } else if viewRect.origin.y + delY < screenFrame.origin.y + CameraPreviewConstants.verticalSpacing {
                delY = -delHeight/2 + ((screenFrame.origin.y + CameraPreviewConstants.verticalSpacing) - (viewRect.origin.y + delY))
            }
            self.presenterDelegate?.viewDelegate?.resizeCameraPreview(delX: 0, delY: delY, delWidth: delWidth, delHeight: delHeight)
        }
    }
    
    func isPreviewOnRightBorder(previewRect: NSRect, recordingFrame: NSRect) -> Bool {
        return (previewRect.origin.x + previewRect.size.width == recordingFrame.origin.x + recordingFrame.size.width - CameraPreviewConstants.horizontalSpacing)
    }
    
    func isPreviewOnTopBorder(previewRect: NSRect, recordingFrame: NSRect) -> Bool {
        return (previewRect.origin.y == recordingFrame.origin.y + CameraPreviewConstants.verticalSpacing)
    }
    
    func isPreviewOnBottomBorder(previewRect: NSRect, recordingFrame: NSRect) -> Bool {
        return (previewRect.origin.y + previewRect.size.height == recordingFrame.origin.y + recordingFrame.size.height - CameraPreviewConstants.verticalSpacing)
    }
    
    func isPreviewOnLeftBorder(previewRect: NSRect, recordingFrame: NSRect) -> Bool {
        return (previewRect.origin.x == recordingFrame.origin.x + CameraPreviewConstants.horizontalSpacing)
    }
    
//    func willPreviewCrossRigtBorder(previewRect: NSRect, recordingFrame: NSRect, delX: CGFloat, delWidth: CGFloat) -> Bool {
//
//    }
    
    func willPreviewCrossTopBorder(previewRect: NSRect, recordingFrame: NSRect, delY: CGFloat, delHeight: CGFloat) -> CGFloat {
        if previewRect.origin.y + delY < recordingFrame.origin.y + CameraPreviewConstants.verticalSpacing {
            return delY + ((recordingFrame.origin.y + CameraPreviewConstants.verticalSpacing) - (previewRect.origin.y + delY))
        }
        return delY
    }
}
