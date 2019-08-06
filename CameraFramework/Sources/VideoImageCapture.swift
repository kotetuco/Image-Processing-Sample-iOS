//
//  VideoImageCapture.swift
//  CameraFramework
//
//  Created by kotetu on 2019/08/06.
//  Copyright © 2019 kotetu. All rights reserved.
//

import AVFoundation
import RxSwift

open class VideoImageCapture: NSObject {
    private let captureSession: AVCaptureSession
    private let videoDataOutput: AVCaptureVideoDataOutput
    private let bufferQueue = DispatchQueue(label: "co.kotetu.buffer.queue")

    init(captureSession: AVCaptureSession,
         videoDataOutput: AVCaptureVideoDataOutput) {
        self.captureSession = captureSession
        self.videoDataOutput = videoDataOutput
        super.init()

        self.videoDataOutput.setSampleBufferDelegate(self, queue: bufferQueue)
    }

    func start() {
        guard !captureSession.isRunning else { return }
        captureSession.startRunning()
    }

    func stop() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension VideoImageCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }

    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
}

open class VideoAuthenticator {
    func requestVideoAccess() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    // TODO:
                }
            }
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }
}
