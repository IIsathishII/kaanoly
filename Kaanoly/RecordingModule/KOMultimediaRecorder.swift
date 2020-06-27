//
//  KOMultimediaRecorder.swift
//  Kaanoly
//
//  Created by SathishKumar on 02/06/20.
//  Copyright © 2020 Ghost. All rights reserved.
//

import Foundation
import AVFoundation

class KOMultimediaRecorder : NSObject, AVCaptureFileOutputRecordingDelegate {
    
    var sources : KOMediaSettings.MediaSource
    
    var screenCaptureSession : AVCaptureSession?
    var cameraCaptureSession : AVCaptureSession?
    
    var camera : AVCaptureDevice?
    var microphone : AVCaptureDevice?
    
    var screenInput : AVCaptureScreenInput?
    var cameraInput : AVCaptureDeviceInput?
    var audioInput : AVCaptureDeviceInput?
    
    var cameraPreview : AVCaptureVideoPreviewLayer?
    
    var screenOutput : AVCaptureMovieFileOutput?
    var cameraOutput : AVCaptureMovieFileOutput?
    
    let recordingDest = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("final.mov")
    
    init(mediaSource: KOMediaSettings.MediaSource) {
        sources = mediaSource
        super.init()
        self.setupRecorder(mediaSource: mediaSource)
    }
    
    func destroyRecorder() {
        screenCaptureSession = nil; cameraCaptureSession = nil
        camera = nil; microphone = nil
        screenInput = nil; cameraInput = nil; audioInput = nil
        cameraPreview = nil
        cameraPreview?.session = nil
        screenOutput = nil; cameraOutput = nil
    }
    
    func setupRecorder(mediaSource: KOMediaSettings.MediaSource) {
        if mediaSource.contains(.screen) {
            screenCaptureSession = AVCaptureSession.init()
            screenOutput = AVCaptureMovieFileOutput.init()
            screenInput = AVCaptureScreenInput.init(displayID: CGMainDisplayID())
        }
        if mediaSource.contains(.camera) {
            cameraCaptureSession = AVCaptureSession.init()
            cameraPreview = AVCaptureVideoPreviewLayer.init(session: cameraCaptureSession!)
            cameraPreview?.contentsGravity = .resize
            camera = AVCaptureDevice.default(for: .video)
            if camera != nil {
                cameraInput = try? AVCaptureDeviceInput.init(device: camera!)
            }
            if !mediaSource.contains(.screen) {
                cameraOutput = AVCaptureMovieFileOutput.init()
            }
        }
        if mediaSource.contains(.audio) {
            microphone = AVCaptureDevice.default(for: .audio)
            if microphone != nil {
                audioInput = try? AVCaptureDeviceInput.init(device: microphone!)
            }
        }
        self.prepareForRecording()
    }
    
    func prepareForRecording() {
        if screenCaptureSession != nil, screenInput != nil {
//            screenCaptureSession?.beginConfiguration()
//            if screenCaptureSession?.canSetSessionPreset(.hd4K3840x2160) == true {
//                screenCaptureSession?.sessionPreset = .hd4K3840x2160
//            }
            if screenCaptureSession!.canAddInput(screenInput!) {
                screenCaptureSession!.addInput(screenInput!)
            }
            var displays : [CGDirectDisplayID] = []
            var count : UInt32 = 0
            if audioInput != nil && screenCaptureSession!.canAddInput(audioInput!) {
                screenCaptureSession!.addInput(audioInput!)
            }
            if screenCaptureSession!.canAddOutput(screenOutput!) {
                screenCaptureSession!.addOutput(screenOutput!)
            }
//            screenCaptureSession?.commitConfiguration()
        }
        if cameraCaptureSession != nil, cameraInput != nil {
            if cameraCaptureSession!.canAddInput(cameraInput!) {
                cameraCaptureSession!.addInput(cameraInput!)
            }
            if cameraOutput != nil && audioInput != nil {
                if cameraCaptureSession!.canAddInput(audioInput!) {
                    cameraCaptureSession!.addInput(audioInput!)
                }
                if cameraCaptureSession!.canAddOutput(cameraOutput!) {
                    cameraCaptureSession!.addOutput(cameraOutput!)
                }
            }
            cameraCaptureSession?.commitConfiguration()
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
        screenOutput?.startRecording(to: recordingDest, recordingDelegate: self)
        cameraOutput?.startRecording(to: recordingDest, recordingDelegate: self)
    }
    
    func endRecording() {
        screenOutput?.stopRecording()
        cameraOutput?.stopRecording()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil {
            print("Error in recording :: ", error.debugDescription)
        }
        if output == screenOutput {
            screenCaptureSession?.stopRunning()
            cameraCaptureSession?.stopRunning()
        } else if output == cameraOutput {
            cameraCaptureSession?.stopRunning()
        }
    }
    
}
