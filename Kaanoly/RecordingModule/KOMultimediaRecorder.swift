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
    
    var currentCameraSource : AVCaptureDevice = AVCaptureDevice.default(for: .video)!
    var currentAudioSource : AVCaptureDevice = AVCaptureDevice.default(for: .audio)!
    
    var cameraPreview : AVCaptureVideoPreviewLayer?
    
    var videoOutput : AVCaptureVideoDataOutput?
    var audioOutput : AVCaptureAudioDataOutput?
    
    var recordingDest : URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("final.mov")
    
    var assetWriter : AVAssetWriter?
    var isRecording = false
    var videoWriterInput : AVAssetWriterInput?
    var audioWriterInput : AVAssetWriterInput?
    
    var isPrepared = false
    
    var sessionAtSourceTime : CMTime?
    var _prevVideoTimestamp : CMTime?
    var _prevAudioTimestamp : CMTime?
    var videoOffset = CMTime.zero
    var audioOffset = CMTime.zero
    var didJustResumeVideo = false
    var didJustResumeAudio = false
    
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
        let formatter = DateFormatter.init()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let dateTime = formatter.string(from: Date.init())
        if let isCloudDirectory = self.propertiesManager?.getIsCloudDirectory(), isCloudDirectory {
            let url = FileManager.default.homeDirectoryForCurrentUser
            self.recordingDest = url.appendingPathComponent("Xplnr Video Message \(dateTime).mov")
        } else if let url = self.propertiesManager?.getStorageDirectory() {
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
            camera = self.currentCameraSource
            if camera != nil {
                cameraInput = try? AVCaptureDeviceInput.init(device: camera!)
            }
        }
        if sources.contains(.audio) {
            microphone = self.currentAudioSource
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
            DispatchQueue.main.sync {
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
                if self.propertiesManager?.getIsCloudDirectory() == true {
                    DispatchQueue.global().async {
                        let containerUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)
                        if let iCloudDocsUrl = containerUrl?.appendingPathComponent("Documents") {
                            let iCloudFile = iCloudDocsUrl.appendingPathComponent(self.recordingDest.lastPathComponent)
                            if !FileManager.default.fileExists(atPath: iCloudDocsUrl.path, isDirectory: nil) {
                                try? FileManager.default.createDirectory(at: iCloudDocsUrl, withIntermediateDirectories: true, attributes: nil)
                            }
                            do {
                                try FileManager.default.copyItem(at: self.recordingDest, to: iCloudFile)
                                try FileManager.default.removeItem(at: self.recordingDest)
                                self.recordingDest = iCloudFile
                            } catch {
                                print("Error in copying file to iCloud")
                                return
                            }
                        }
                    }
                    self.propertiesManager?.bookmarkRecording(Path: self.recordingDest)
                } else {
                    self.propertiesManager?.bookmarkRecording(Path: self.recordingDest)
                }
    //            self.propertiesManager?.getStorageDirectory()?.stopAccessingSecurityScopedResource()
            }
        }
    }
    
    func pauseRecording() {
        self.isRecording = false
    }
    
    func resumeRecording() {
        self.isRecording = true
        self.didJustResumeVideo = true
        self.didJustResumeAudio = true
    }
    
    func cancelRecording() {
        self.isRecording = false
        assetWriter?.cancelWriting()
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
                if let last = self._prevVideoTimestamp, didJustResumeVideo {
                    didJustResumeVideo = false
                    let currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                    let timeOffset = CMTimeSubtract(currentTime, last)
                    self.videoOffset = timeOffset
                }
                if self.videoOffset != .zero {
                    let newSampleBuffer = self.adjustTime(For: sampleBuffer, by: self.videoOffset)
                    videoWriterInput?.append(newSampleBuffer)
                } else {
                    videoWriterInput?.append(sampleBuffer)
                }
                var bufferTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                let bufferDuration = CMSampleBufferGetDuration(sampleBuffer)
                if bufferDuration.value > 0 {
                    bufferTime = CMTimeAdd(bufferTime, bufferDuration)
                }
                self._prevVideoTimestamp = bufferTime
            }
        }
        if output == audioOutput {
            if audioWriterInput?.isReadyForMoreMediaData == true {
                if let last = self._prevAudioTimestamp, didJustResumeAudio {
                    didJustResumeAudio = false
                    var bufferTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                    let timeOffset = CMTimeSubtract(bufferTime, last)
                    self.audioOffset = timeOffset
                }
                if self.audioOffset != .zero {
                    let newSampleBuffer = self.adjustTime(For: sampleBuffer, by: self.audioOffset)
                    audioWriterInput?.append(newSampleBuffer)
                } else {
                    audioWriterInput?.append(sampleBuffer)
                }
                var bufferTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                let bufferDuration = CMSampleBufferGetDuration(sampleBuffer)
                if bufferDuration.value > 0 {
                    bufferTime = CMTimeAdd(bufferTime, bufferDuration)
                }
                self._prevAudioTimestamp = bufferTime
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
        videoWriterInput = AVAssetWriterInput.init(mediaType: .video, outputSettings: [ AVVideoCodecKey: AVVideoCodecType.h264.rawValue, AVVideoWidthKey: dimension.width, AVVideoHeightKey: dimension.height])//, AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 2300000]
        videoWriterInput?.expectsMediaDataInRealTime = true
        if assetWriter!.canAdd(videoWriterInput!) {
            assetWriter?.add(videoWriterInput!)
        }
        
        audioWriterInput = AVAssetWriterInput.init(mediaType: .audio, outputSettings: [ AVFormatIDKey: kAudioFormatMPEG4AAC, AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100, AVEncoderBitRateKey: 64000,])
        audioWriterInput?.expectsMediaDataInRealTime = true
        if assetWriter!.canAdd(audioWriterInput!) {
            assetWriter?.add(audioWriterInput!)
        }
    }
    
    func adjustTime(For sampleBuffer: CMSampleBuffer, by offset: CMTime) -> CMSampleBuffer {
        var count : CMItemCount = 0
        CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, entryCount: 0, arrayToFill: nil, entriesNeededOut: &count)
        var sampleInfo = [CMSampleTimingInfo](repeating: CMSampleTimingInfo.init(duration: .zero, presentationTimeStamp: .zero, decodeTimeStamp: .zero), count: count)
        CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, entryCount: count, arrayToFill: &sampleInfo, entriesNeededOut: &count)
        for i in 0..<count {
            sampleInfo[i].decodeTimeStamp = CMTimeSubtract(sampleInfo[i].decodeTimeStamp, offset)
            sampleInfo[i].presentationTimeStamp = CMTimeSubtract(sampleInfo[i].presentationTimeStamp, offset)
        }
        var newSampleBuffer : CMSampleBuffer?
        CMSampleBufferCreateCopyWithNewTiming(allocator: nil, sampleBuffer: sampleBuffer, sampleTimingEntryCount: count, sampleTimingArray: sampleInfo, sampleBufferOut: &newSampleBuffer)
        return newSampleBuffer ?? sampleBuffer
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
    
    func setAudio(Source source : AVCaptureDevice) {
        self.currentAudioSource = source
    }
    
    func setVideo(Source source: AVCaptureDevice) {
        self.currentCameraSource = source
    }
}
