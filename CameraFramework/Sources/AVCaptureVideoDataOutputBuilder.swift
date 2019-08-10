//
//  AVCaptureVideoDataOutputBuilder.swift
//  CameraFramework
//
//  Created by kotetu on 2019/08/10.
//  Copyright © 2019 kotetu. All rights reserved.
//

import AVFoundation

public protocol AVCaptureVideoDataOutputBuilder {
    func build() -> AVCaptureVideoDataOutput
}

public final class DefaultBGRAVideoDataOutputBuilder: AVCaptureVideoDataOutputBuilder {
    public init() {}

    public func build() -> AVCaptureVideoDataOutput {
        let videoDataOutput = AVCaptureVideoDataOutput()
        // UIImageへの変換を想定しBGRAで取るようにする
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        // キューをブロック中にキャプチャしたフレームは破棄
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        return videoDataOutput
    }
}
