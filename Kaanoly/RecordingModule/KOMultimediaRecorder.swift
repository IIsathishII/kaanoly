//
//  KOMultimediaRecorder.swift
//  Kaanoly
//
//  Created by SathishKumar on 02/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMediaIO
import AppKit
import CoreGraphics
import Vision

class KOMultimediaRecorder : NSObject {
    
    weak var propertiesManager : KOPropertiesDataManager?
    
    var screenCaptureSession : AVCaptureSession?
    var cameraCaptureSession : AVCaptureSession?
    
    var camera : AVCaptureDevice?
    var microphone : AVCaptureDevice?
    
    var screenInput : AVCaptureScreenInput?
    var cameraInput : AVCaptureDeviceInput?
    var audioInput : AVCaptureDeviceInput?
    
    var cameraPreview : AVCaptureVideoPreviewLayer?
    
    var videoOutput : AVCaptureVideoDataOutput?
    var audioOutput : AVCaptureAudioDataOutput?
    
    var recordingDest : URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("final.mov")
    
    var assetWriter : AVAssetWriter?
    var isRecording = false
    var sessionAtSourceTime : CMTime?
    var videoWriterInput : AVAssetWriterInput?
    var audioWriterInput : AVAssetWriterInput?
    
    var isPrepared = false
    
    var sequenceRequestHandler = VNSequenceRequestHandler.init()
    var faceView = CALayer.init()
    
    override init() {
        super.init()
        faceView.backgroundColor = NSColor.clear.cgColor
        faceView.borderColor = NSColor.red.cgColor
        faceView.borderWidth = 2
    }
    
    func clearRecorder() {
        screenCaptureSession = nil; cameraCaptureSession = nil
        camera = nil; microphone = nil
        screenInput = nil; cameraInput = nil; audioInput = nil
//        cameraPreview = nil
//        cameraPreview?.session = nil
        videoOutput = nil; audioOutput = nil
        self.isPrepared = false
    }
    
    func setup(propertiesManager: KOPropertiesDataManager?) {
        self.propertiesManager = propertiesManager
        if let url = self.propertiesManager?.getStorageDirectory() {
            let formatter = DateFormatter.init()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            let dateTime = formatter.string(from: Date.init())
            url.startAccessingSecurityScopedResource()
            self.recordingDest = url.appendingPathComponent("Xplnr Video Message \(dateTime).mov")
        }
        self.setupRecorder()
    }
    
    func setupRecorder() {
        guard let sources = self.propertiesManager?.getSource(), let displayId = self.propertiesManager?.getCurrentScreen()?.deviceDescription[NSDeviceDescriptionKey.init("NSScreenNumber")] as? CGDirectDisplayID else { return }
        if sources.contains(.screen) {
            screenCaptureSession = AVCaptureSession.init()
            screenInput = AVCaptureScreenInput.init(displayID: displayId)
            if let croppedRect = self.propertiesManager?.getCroppedRect(), let screen = self.propertiesManager?.getCurrentScreen() {
                screenInput?.cropRect = NSRect.init(x: croppedRect.origin.x, y: screen.frame.height-croppedRect.origin.y-croppedRect.height, width: croppedRect.width, height: croppedRect.height)
            }
            self.setMouseHighlighterProp()
        }
        if sources.contains(.camera) {
            cameraCaptureSession = AVCaptureSession.init()
            cameraPreview = AVCaptureVideoPreviewLayer.init(session: cameraCaptureSession!)
            cameraPreview?.contentsGravity = .resize
            camera = AVCaptureDevice.default(for: .video)
            if camera != nil {
                cameraInput = try? AVCaptureDeviceInput.init(device: camera!)
            }
        }
        if sources.contains(.audio) {
            microphone = AVCaptureDevice.default(for: .audio)
            if microphone != nil {
                audioInput = try? AVCaptureDeviceInput.init(device: microphone!)
            }
        }
        videoOutput = AVCaptureVideoDataOutput.init()
        audioOutput = AVCaptureAudioDataOutput.init()
        self.prepareForRecording(sources: sources)
    }
    
    func prepareForRecording(sources: KOMediaSettings.MediaSource) {
//        var property = CMIOObjectPropertyAddress(mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices), mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal), mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster))
//        var allow : UInt32 = 1
//        let sizeOfAllow = MemoryLayout<UInt32>.size
//        CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &property, 0, nil, UInt32(sizeOfAllow), &allow)
        if sources.contains(.screen) {
            screenCaptureSession?.beginConfiguration()
            if screenCaptureSession!.canAddInput(screenInput!) {
                screenCaptureSession!.addInput(screenInput!)
            }
            if audioInput != nil && screenCaptureSession!.canAddInput(audioInput!) {
                screenCaptureSession!.addInput(audioInput!)
            }

            videoOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
            videoOutput?.alwaysDiscardsLateVideoFrames = true
            
            let queue = DispatchQueue.init(label: "screen-queue")
            
            if screenCaptureSession!.canAddOutput(videoOutput!) {
                videoOutput?.setSampleBufferDelegate(self, queue: queue)
                screenCaptureSession!.addOutput(videoOutput!)
            }
            if screenCaptureSession!.canAddOutput(audioOutput!) {
                audioOutput?.setSampleBufferDelegate(self, queue: queue)
                screenCaptureSession!.addOutput(audioOutput!)
            }
            screenCaptureSession?.commitConfiguration()
        }
        if sources.contains(.camera) {
            if cameraCaptureSession!.canAddInput(cameraInput!) {
                cameraCaptureSession!.addInput(cameraInput!)
                self.setMirroredProp()
            }
            if !sources.contains(.screen) {
                cameraCaptureSession?.beginConfiguration()
                if audioInput != nil && cameraCaptureSession!.canAddInput(audioInput!) {
                    cameraCaptureSession!.addInput(audioInput!)
                }
                
                videoOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
                videoOutput?.alwaysDiscardsLateVideoFrames = true
                
                let queue = DispatchQueue.init(label: "camera-queue")
                
                if cameraCaptureSession!.canAddOutput(videoOutput!) {
                    videoOutput?.setSampleBufferDelegate(self, queue: queue)
                    cameraCaptureSession!.addOutput(videoOutput!)
                }
                if cameraCaptureSession!.canAddOutput(audioOutput!) {
                    audioOutput?.setSampleBufferDelegate(self, queue: queue)
                    cameraCaptureSession?.addOutput(audioOutput!)
                }
                cameraCaptureSession?.commitConfiguration()
            }
        }
        if FileManager.default.fileExists(atPath: recordingDest.path) {
            do {
                try FileManager.default.removeItem(at: recordingDest)
            } catch {
                print("Error deleting existing file")
            }
        }
//        DispatchQueue.global().async {
        self.screenCaptureSession?.startRunning()
        self.cameraCaptureSession?.startRunning()
//        }
    }
    
    func beginRecording() {
        assetWriter?.startWriting()
        self.isRecording = true
    }
    
    func endRecording() {
        self.isRecording = false
        assetWriter?.finishWriting {
            if self.assetWriter?.status == .failed || self.assetWriter?.status == .cancelled {
                if FileManager.default.fileExists(atPath: self.recordingDest.path) {
                    do {
                        try FileManager.default.removeItem(at: self.recordingDest)
                    } catch {
                        print("Error deleting existing file")
                    }
                }
                return
            }
            self.propertiesManager?.bookmarkRecording(Path: self.recordingDest)
//            self.propertiesManager?.getStorageDirectory()?.stopAccessingSecurityScopedResource()
        }
    }
    
}

extension KOMultimediaRecorder : AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !self.isPrepared && output == videoOutput {
            self.prepareWriter(sampleBuffer: sampleBuffer)
            self.isPrepared = true
        }
        guard CMSampleBufferDataIsReady(sampleBuffer), self.isRecording else { return }
        if sessionAtSourceTime == nil {
            sessionAtSourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            assetWriter?.startSession(atSourceTime: sessionAtSourceTime!)
        }
        if output == videoOutput {
            if videoWriterInput?.isReadyForMoreMediaData == true {
                if let imageBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
//                    let request = VNDetectFaceRectanglesRequest.init { (request, error) in
//                        DispatchQueue.main.async {
//                            guard let results = request.results as? [VNFaceObservation], let result = results.first else {
//                                self.faceView.removeFromSuperlayer()
//                                return
//                            }
//                            let box = result.boundingBox
//                            if self.faceView.superlayer == nil {
//                                self.cameraPreview?.addSublayer(self.faceView)
//                            }
////                            self.faceView.frame = VNImageRectForNormalizedRect(box, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))
//                            if let description = CMSampleBufferGetFormatDescription(sampleBuffer) {
//                                let videoDimension = CMVideoFormatDescriptionGetDimensions(description)
//                                var width = CGFloat(videoDimension.width)
//                                var height = CGFloat(videoDimension.height)
//                                let wScale = self.cameraPreview!.frame.width/width
//                                let hScale = self.cameraPreview!.frame.height/height
//                                let frame = VNImageRectForNormalizedRect(box, Int(videoDimension.width), Int(videoDimension.height))
//                                width = frame.width
//                                height = frame.height
//                                if wScale == 0 || hScale == 0 {
//                                    
//                                }
//                                self.faceView.frame = NSRect.init(x: width*box.origin.x, y: height*box.origin.y, width: width*box.width, height: height*box.height)
//                            }
////                            let width = CGFloat(CVPixelBufferGetWidth(imageBuffer))
////                            let height = CGFloat(CVPixelBufferGetHeight(imageBuffer))
////                            self.faceView.frame = NSRect.init(x: width*box.origin.x/(self.cameraPreview!.frame.width/width), y: height*box.origin.y/(self.cameraPreview!.frame.height/height), width: width*box.width/(self.cameraPreview!.frame.width/width), height: height*box.height/(self.cameraPreview!.frame.height/height))
//                            print("Box >>>>>>>>>>> ", box )
//                        }
//                    }
//                    do {
//                        try sequenceRequestHandler.perform([request], on: imageBuffer)
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                    var image = CIImage.init(cvImageBuffer: imageBuffer)
////                    image.cropped(to: CGRect.init(origin: .zero, size: CGSize.init(width: 200, height: 100)))
//                    image = image.applyingGaussianBlur(sigma: 2.0)
                }
                videoWriterInput?.append(sampleBuffer)
            }
        }
        if output == audioOutput {
            if audioWriterInput?.isReadyForMoreMediaData == true {
                audioWriterInput?.append(sampleBuffer)
            }
        }
    }
    
    func prepareWriter(sampleBuffer: CMSampleBuffer) {
        var dimension = CGSize.init(width: NSScreen.main!.frame.size.width, height: NSScreen.main!.frame.size.height)
        if let description = CMSampleBufferGetFormatDescription(sampleBuffer) {
            let videoDimension = CMVideoFormatDescriptionGetDimensions(description)
            dimension.width = CGFloat(videoDimension.width)
            dimension.height = CGFloat(videoDimension.height)
        }
        assetWriter = try? AVAssetWriter.init(url: recordingDest, fileType: .mp4)
        videoWriterInput = AVAssetWriterInput.init(mediaType: .video, outputSettings: [ AVVideoCodecKey: AVVideoCodecType.h264.rawValue, AVVideoWidthKey: dimension.width, AVVideoHeightKey: dimension.height, AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 2300000]])
        videoWriterInput?.expectsMediaDataInRealTime = true
        if assetWriter!.canAdd(videoWriterInput!) {
            assetWriter?.add(videoWriterInput!)
        }
        
        audioWriterInput = AVAssetWriterInput.init(mediaType: .audio, outputSettings: [ AVFormatIDKey: kAudioFormatMPEG4AAC, AVNumberOfChannelsKey: 1, AVSampleRateKey: 44100, AVEncoderBitRateKey: 64000,])
        audioWriterInput?.expectsMediaDataInRealTime = true
        if assetWriter!.canAdd(audioWriterInput!) {
            assetWriter?.add(audioWriterInput!)
        }
    }
    
    func convert(rect: CGRect) -> CGRect {
      let origin = cameraPreview!.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        let size = cameraPreview!.layerPointConverted(fromCaptureDevicePoint: CGPoint.init(x: rect.size.width, y: rect.size.height))
        return CGRect.init(origin: origin, size: CGSize.init(width: size.x-origin.x, height: size.y-origin.y))
    }
    
    func setMirroredProp() {
        if let connection = cameraCaptureSession?.connections[0], let isMirrored = self.propertiesManager?.getIsMirrored() {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = isMirrored
        }
    }
    
    func setMouseHighlighterProp() {
        if let shouldCaptureMouseClick = self.propertiesManager?.shouldCaptureMouseClick() {
            screenInput?.capturesMouseClicks = shouldCaptureMouseClick
        }
    }
    
    func setSession(Props props: [KORecordingSessionProps]) {
        if props.contains(.mirrored) {
            self.setMirroredProp()
        }
        if props.contains(.mouseHighlighter) {
            self.setMouseHighlighterProp()
        }
    }
}
