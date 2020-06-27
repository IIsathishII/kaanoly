//
//  KORecordingCoordinator.swift
//  Kaanoly
//
//  Created by SathishKumar on 02/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import AVFoundation
import CoreMedia

class KORecordingCoordinator {

    private var recorder: KOMultimediaRecorder?
    static let sharedInstance = KORecordingCoordinator.init()
    
    private init() {
        
    }
    
    class func isRecorderAvailable() -> Bool {
        return sharedInstance.recorder != nil
    }
    
    func setupRecorder(mediaSource: KOMediaSettings.MediaSource) {
        KORecordingCoordinator.sharedInstance.recorder = KOMultimediaRecorder.init(mediaSource: mediaSource)
    }
    
    func modifyRecorder(mediaSource: KOMediaSettings.MediaSource) {
        if self.recorder == nil {
            self.setupRecorder(mediaSource: mediaSource)
            return
        }
        self.recorder?.setupRecorder(mediaSource: mediaSource)
    }
    
    func beginRecording() {
        KORecordingCoordinator.sharedInstance.recorder?.beginRecording()
    }
    
    func endRecording() {
        KORecordingCoordinator.sharedInstance.recorder?.endRecording()
    }
    
    func destroyRecorder() {
        KORecordingCoordinator.sharedInstance.recorder = nil
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        KORecordingCoordinator.sharedInstance.recorder?.cameraPreview
    }
    
    func getPreviewLayerSize() -> (Int, Int) {
        let dim = CMVideoFormatDescriptionGetDimensions((KORecordingCoordinator.sharedInstance.recorder!.cameraCaptureSession?.inputs[0] as! AVCaptureDeviceInput).device.activeFormat.formatDescription)
        return (Int(dim.width), Int(dim.height))
    }
}
