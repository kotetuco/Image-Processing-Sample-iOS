//
//  Presenter.swift
//  ImageProcessingSample
//
//  Created by kotetu on 2019/08/12.
//  Copyright © 2019 kotetu. All rights reserved.
//

import CameraFramework
import OpneCVImageProcessingFramework
import RxSwift

protocol PresenterDelegate: AnyObject {
    func showAccessDeniedError()
    func showCameraInitializationError()
    func initializationDidSuccess()
    func didCapture(_ image: UIImage)
}

final class Presenter {
    private let imageProcessor: ImageProcessor
    private let videoAccess: VideoAccess

    private let disposeBag = DisposeBag()
    private let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    private var videoCapture: VideoImageCapture?
    private var previewSize: CGSize?
    private let context = CIContext()

    weak var delegate: PresenterDelegate?

    init(imageProcessor: ImageProcessor, videoAccess: VideoAccess) {
        self.imageProcessor = imageProcessor
        self.videoAccess = videoAccess
    }

    func initializePreview() {
        requestVideoAccess()
    }

    func startPreview(with previewLayer: CALayer?) {
        guard let videoCapture = BasicVideoDataCaptureBuilder().build() else {
            delegate?.showCameraInitializationError()
            return
        }
        if let previewLayer = previewLayer {
            videoCapture.setPreviewLayer(previewLayer)
            self.previewSize = previewLayer.bounds.size
        }
        videoCapture.setVideoImageCaptureDelegate(self)
        videoCapture.start()
        self.videoCapture = videoCapture
    }

    func terminate() {
        stopVideoCapture()
    }

    private func requestVideoAccess() {
        videoAccess
            .requestVideoAccess()
            .subscribeOn(backgroundScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] completable in
                guard let self = self else { return }
                switch completable {
                case .completed:
                    self.delegate?.initializationDidSuccess()
                case .error(_):
                    self.delegate?.showAccessDeniedError()
                }
            }
            .disposed(by: disposeBag)
    }

    private func startVideoCapture() {
        guard let videoCapture = videoCapture else { return }
        videoCapture.start()
    }

    private func stopVideoCapture() {
        guard let videoCapture = videoCapture else { return }
        videoCapture.stop()
    }
}

extension Presenter: VideoImageCaptureDelegate {
    func didOutput(_ image: CIImage) {
        // UIImage -> CGImage -> UIImage
        if let cgImage = self.context.createCGImage(image, from: image.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            delegate?.didCapture(uiImage)
        }
    }
}
