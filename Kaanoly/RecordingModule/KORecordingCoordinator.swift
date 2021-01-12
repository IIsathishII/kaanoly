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
    
    weak var propertiesManager : KOPropertiesDataManager?
    
    private init() {
        
    }
    
    class func isRecorderAvailable() -> Bool {
        return sharedInstance.recorder != nil
    }
    
    func setupRecorder(propertiesManager: KOPropertiesDataManager?) {
        KORecordingCoordinator.sharedInstance.recorder = KOMultimediaRecorder.init()
        KORecordingCoordinator.sharedInstance.recorder?.setup(propertiesManager: propertiesManager)
    }
    
    func modifyRecorder(propertiesManager: KOPropertiesDataManager? = nil) {
        if self.recorder == nil {
            self.setupRecorder(propertiesManager: propertiesManager)
            return
        }
        self.recorder?.clearRecorder()
        self.recorder?.setupRecorder()
    }
    
    func beginRecording() {
        KORecordingCoordinator.sharedInstance.recorder?.beginRecording()
    }
    
    func endRecording() {
        KORecordingCoordinator.sharedInstance.recorder?.endRecording()
    }
    
    func pauseRecording() {
        KORecordingCoordinator.sharedInstance.recorder?.pauseRecording()
    }
    
    func resumeRecording() {
        KORecordingCoordinator.sharedInstance.recorder?.resumeRecording()
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
    
    func setSession(Props props: [KORecordingSessionProps]) {
        KORecordingCoordinator.sharedInstance.recorder?.setSession(Props: props)
    }
    
    func setAudio(Source source : AVCaptureDevice) {
        KORecordingCoordinator.sharedInstance.recorder?.setAudio(Source: source)
    }
    
    func setVideo(Source source: AVCaptureDevice) {
        KORecordingCoordinator.sharedInstance.recorder?.setVideo(Source: source)
    }
}
