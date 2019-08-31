//
//  VideoImageCapture.swift
//  CameraFramework
//
//  Created by kotetu on 2019/08/06.
//  Copyright © 2019 kotetu. All rights reserved.
//

import AVFoundation

public protocol VideoImageCaptureDelegate: AnyObject {
    func didOutput(ciImage: CIImage)
}

public final class VideoImageCapture: NSObject {
    private let captureSession: AVCaptureSession
    private let videoDataOutput: AVCaptureVideoDataOutput
    private let bufferQueue = DispatchQueue(label: "co.kotetu.buffer.queue")

    private weak var videoImageCaptureDelegate: VideoImageCaptureDelegate?

    init(captureSession: AVCaptureSession,
         videoDataOutput: AVCaptureVideoDataOutput) {
        self.captureSession = captureSession
        self.videoDataOutput = videoDataOutput
        super.init()

        self.videoDataOutput.setSampleBufferDelegate(self, queue: bufferQueue)
    }

    public func setPreviewLayer(_ layer: CALayer) {
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // アスペクト比に合わせて左右を切り取る(上下は切り取らない)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = layer.bounds
        layer.insertSublayer(videoPreviewLayer, at: 0)
    }

    public func setVideoImageCaptureDelegate(_ delegate: VideoImageCaptureDelegate) {
        videoImageCaptureDelegate = delegate
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

extension VideoImageCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        videoImageCaptureDelegate?.didOutput(ciImage: ciImage)
    }
}
