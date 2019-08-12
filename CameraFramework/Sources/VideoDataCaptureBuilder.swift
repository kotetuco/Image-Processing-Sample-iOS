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
        // AVCaptureDevice
        //
        guard let device = deviceBuilder.build() else {
                return nil
        }

        do {
            try device.lockForConfiguration()
        } catch {
            return nil
        }

        // 撮影対象までの距離が近い場合はautoFocusRangeRestrictionの設定を行うことで最適化できる場合がある
        if device.isAutoFocusRangeRestrictionSupported {
            device.autoFocusRangeRestriction = .near
        }

        device.unlockForConfiguration()

        //
        // AVCaptureDeviceInput
        //
        guard
            let deviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(deviceInput) else {
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
            // フロントカメラの場合に左右反転させる
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

            // 手ブレ補正
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .auto
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
