//
//  KOOverlayPresenter.swift
//  Kaanoly
//
//  Created by SathishKumar on 06/09/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

class KOOverlayPresenter : KOOverlayPresenterDelegate {
    
    weak var viewDelegate : KOOverlayViewDelegate?
    weak var propertiesManager : KOPropertiesDataManager?
    
    var previewScale = CameraPreviewConstants.Size.defaultScale
    
    init() {
    }
    
    func handleSourceChanged() {
        guard let source = self.propertiesManager?.getSource() else { return }
        if source.contains(.camera) {
            if source.contains(.screen) {
                self.previewScale = CameraPreviewConstants.Size.defaultScale
            } else {
                self.previewScale = CameraPreviewConstants.Size.maxScale
            }
            self.viewDelegate?.setCameraPreview()
        } else {
            self.viewDelegate?.removeCameraPreview()
        }
    }
    
    func getPreviewScale() -> CGFloat {
        return self.previewScale
    }
    
    func setPreview(Scale scale: CGFloat) {
        self.previewScale = scale
    }
}
