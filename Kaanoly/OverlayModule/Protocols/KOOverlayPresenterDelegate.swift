//
//  KOOverlayPresenterDelegate.swift
//  Kaanoly
//
//  Created by SathishKumar on 06/09/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AppKit

protocol KOOverlayPresenterDelegate : class {
    var viewDelegate : KOOverlayViewDelegate? { get set }
    var propertiesManager : KOPropertiesDataManager? { get set }
    
    //Overlay view controller
    func handleSourceChanged()
    func getPreviewScale() -> CGFloat
    func setPreview(Scale scale: CGFloat)
}
