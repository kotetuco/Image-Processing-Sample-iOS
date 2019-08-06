//
//  VideoAccess.swift
//  CameraFramework
//
//  Created by kotetu on 2019/08/07.
//  Copyright © 2019 kotetu. All rights reserved.
//

import AVFoundation
import RxSwift

open class VideoAccess {
    public enum VideoAccessError: Error {
        case denied
        case general
    }

    public init() {}

    public func requestVideoAccess() -> Completable {
        return Completable.create { completable in
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                completable(.completed)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (authorized) in
                    if authorized {
                        completable(.completed)
                    } else {
                        completable(.error(VideoAccessError.denied))
                    }
                })
            case .denied:
                completable(.error(VideoAccessError.denied))
            case .restricted:
                completable(.error(VideoAccessError.general))
            @unknown default:
                completable(.error(VideoAccessError.general))
            }
            return Disposables.create {}
        }
    }
}
