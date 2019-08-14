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
    func draw(circles: [Circle])
    func draw(image: UIImage)
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
        guard let previewSize = previewSize,
            let uiImage = uiImage(from: image) else { return }
        // FIXME: プレビューViewと同じアスペクト比にする(左右はみ出た分についてはクロップするか座標計算に反映させる)
        delegate?.draw(image: uiImage)
        let detectCircles = self.imageProcessor.circleDetection(from: uiImage,
                                                                minimumDistance: 30)
        let drawScale: CGFloat = previewSize.height / image.extent.height
        let drawableCircles = detectCircles.compactMap {
            return Circle(center: CGPoint(x: $0.center.x * drawScale,
                                          y: $0.center.y * drawScale),
                          radius: $0.radius * drawScale )
        }
        delegate?.draw(circles: drawableCircles)
    }
}

private extension Presenter {
    func uiImage(from image: CIImage) -> UIImage? {
        return autoreleasepool { [weak self] in
            // UIImage -> CGImage -> UIImage
            guard let self = self,
                let cgImage = self.context.createCGImage(image, from: image.extent) else {
                    return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }

    func uiImage(from image: CIImage, scale: CGFloat) -> UIImage? {
        return autoreleasepool { [weak self] in
            // UIImage -> CGImage -> UIImage
            guard let self = self,
                let outputImage = image.resize(scale: scale),
                let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent) else {
                    return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }
}
