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
            self.presenterDelegate?.overlayPresenterDelegate?.setPreview(Scale: (width+delX)/screenFrame.width)
            self.presenterDelegate?.viewDelegate?.resizeCameraPreview(delX: delX, delY: delX*CGFloat(size.1)/CGFloat(size.0))
        }
    }
}
