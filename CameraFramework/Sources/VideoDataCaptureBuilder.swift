//
//  VideoDataCaptureBuilder.swift
//  CameraFramework
//
//  Created by kotetu on 2019/08/10.
//  Copyright © 2019 kotetu. All rights reserved.
//

import AVFoundation

public protocol VideoDataCaptureBuilder {
    func build() -> VideoImageCapture?
}

public final class BasicVideoDataCaptureBuilder: VideoDataCaptureBuilder {
    private let deviceBuilder: AVCaptureDeviceBuilder
    private let videoDataOutputBuilder: AVCaptureVideoDataOutputBuilder

    public init(deviceBuilder: AVCaptureDeviceBuilder = BestBackVideoDeviceBuilder(),
                videoDataOutputBuilder: AVCaptureVideoDataOutputBuilder = DefaultBGRAVideoDataOutputBuilder()) {
        self.deviceBuilder = deviceBuilder
        self.videoDataOutputBuilder = videoDataOutputBuilder
    }

    public func build() -> VideoImageCapture? {
        let captureSession = AVCaptureSession()

        //
        // AVCaptureDevice, AVCaptureDeviceInput
        //
        guard
            let device = deviceBuilder.build(),
            let deviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(deviceInput)
            else {
                return nil
        }
        captureSession.addInput(deviceInput)

        //
        // AVCaptureVideoDataOutput
        //
        let videoDataOutput = videoDataOutputBuilder.build()
        guard captureSession.canAddOutput(videoDataOutput) else { return nil }
        captureSession.addOutput(videoDataOutput)

        //
        // AVCaptureConnection
        //
        if let connection = videoDataOutput.connection(with: .video) {
            switch device.position {
            case .front:
                connection.isVideoMirrored = true
            case .back:
                connection.videoOrientation = .portrait
            case .unspecified:
                break
            @unknown default:
                break
            }
        }

        //
        // AVCaptureSession
        //
        captureSession.beginConfiguration()

        // ビデオ解像度(できる限り高解像度を設定する)
        if captureSession.canSetSessionPreset(.hd4K3840x2160) {
            captureSession.sessionPreset = .hd4K3840x2160
        } else if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        } else {
            captureSession.sessionPreset = .high
        }

        captureSession.commitConfiguration()

        let videoDataCapture = VideoImageCapture(captureSession: captureSession,
                                                 videoDataOutput: videoDataOutput)

        return videoDataCapture
    }
}
