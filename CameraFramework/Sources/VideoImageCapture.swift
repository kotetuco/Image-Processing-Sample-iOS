//
//  VideoImageCapture.swift
//  CameraFramework
//
//  Created by kotetu on 2019/08/06.
//  Copyright © 2019 kotetu. All rights reserved.
//

import AVFoundation

public final class VideoImageCapture: NSObject {
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

    public func setupPreviewLayer(previewContainer: CALayer) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = previewContainer.bounds
        previewLayer.contentsGravity = CALayerContentsGravity.resizeAspectFill
        previewLayer.videoGravity = .resizeAspectFill
        previewContainer.insertSublayer(previewLayer, at: 0)
    }

    public func start() {
        guard !captureSession.isRunning else { return }
        captureSession.startRunning()
    }

    public func stop() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension VideoImageCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
}
