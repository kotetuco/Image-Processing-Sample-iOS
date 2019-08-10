//
//  AVCaptureDeviceBuilder.swift
//  CameraFramework
//
//  Created by kotetu on 2019/08/10.
//  Copyright © 2019 kotetu. All rights reserved.
//

import AVFoundation

public protocol AVCaptureDeviceBuilder {
    func build() -> AVCaptureDevice?
}

public final class DefaultBackVideoDeviceBuilder: AVCaptureDeviceBuilder {
    public init() {}

    public func build() -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
    }
}

public final class BackTrueDepthVideoDeviceBuilder: AVCaptureDeviceBuilder {
    public init() {}

    public func build() -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .back)
    }
}

public final class DefaultFrontVideoDeviceBuilder: AVCaptureDeviceBuilder {
    public init() {}

    public func build() -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .front)
    }
}

public final class BestBackVideoDeviceBuilder: AVCaptureDeviceBuilder {
    public init() {}

    public func build() -> AVCaptureDevice? {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera]
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                                mediaType: .video,
                                                                position: .back)
        return discoverySession.devices.first
    }
}
