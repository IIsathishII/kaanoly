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
    
    let recordingDest = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("final.mov")
    
    var assetWriter : AVAssetWriter?
    var isRecording = false
    var sessionAtSourceTime : CMTime?
    var videoWriterInput : AVAssetWriterInput?
    var audioWriterInput : AVAssetWriterInput?
    
    var isPrepared = false
    
    override init() {
        super.init()
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
        self.setupRecorder()
    }
    
    func setupRecorder() {
        guard let sources = self.propertiesManager?.getSource() else { return }
        if sources.contains(.screen) {
            screenCaptureSession = AVCaptureSession.init()
            screenInput = AVCaptureScreenInput.init(displayID: CGMainDisplayID())
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
                var buffer = sampleBuffer
                if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                    var image = CIImage.init(cvImageBuffer: imageBuffer)
//                    image.cropped(to: CGRect.init(origin: .zero, size: CGSize.init(width: 200, height: 100)))
                    image = image.applyingGaussianBlur(sigma: 2.0)
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
}
