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
    func draw(ciImage: CIImage)
}

final class Presenter {
    private let processingImageHeight: CGFloat = 1500
    private let minimumDistance: Double = 20

    private let imageProcessor: ImageProcessor
    private let videoAccess: VideoAccess

    private let disposeBag = DisposeBag()
    private let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    private let circleDetectionQueue = DispatchQueue(label: "co.kotetu.circle.detection.queue", qos: .utility)
    private var videoCapture: VideoImageCapture?
    private var previewSize: CGSize?
    private let context = CIContext()
    private var isProcessing: Bool = false

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
    func didOutput(ciImage: CIImage) {
        delegate?.draw(ciImage: ciImage)
        if !isProcessing {
            circleDetectionQueue.async { [weak self] in
                #if DEBUG
                let start = Date()
                #endif
//                self?.circleDetectionResizeUIImage(by: ciImage)
                self?.circleDetectionResizeCIImage(by: ciImage)
                #if DEBUG
                let interval = Date().timeIntervalSince(start)
                NSLog("Processing Time : %.5f (Presenter#didOutput)", interval)
                #endif
            }
        }
    }
}

private extension Presenter {
    func circleDetectionResizeUIImage(by ciImage: CIImage) {
        isProcessing = true
        guard let previewSize = previewSize, let uiImage = convert(from: ciImage) else { return }

        let aspectRatioForPreview = (previewSize.width / previewSize.height)
        let processingScale = processingImageHeight / ciImage.extent.height

        // プレビュー表示されない領域幅の片側オフセット値(原寸大画像ベースで算出)
        // AVCaptureVideoPreviewLayerでvideoGravityをresizeAspectFillにした場合、縦については全て表示され
        // 左右は切り取られるように表示調整されることから、非表示領域内にある原点を考慮しこのような実装となっている
        let offsetX: CGFloat = (uiImage.size.width - (uiImage.size.height * aspectRatioForPreview)) / 2
        let drawScale: CGFloat = previewSize.height / uiImage.size.height
        // offsetXを表示スクリーン換算で算出
        let offsetForDrawScaleX = offsetX * drawScale

        let resizedImage = uiImage.resize(to: processingScale)
//        let resizedImage = uiImage.resizeForOLD(to: processingScale)!
        let drawableCircles = imageProcessor.circleDetection(from: resizedImage, minimumDistance: minimumDistance).compactMap { circle -> Circle in
            let center = CGPoint(x: ((circle.center.x / processingScale) * drawScale) - offsetForDrawScaleX,
                                 y: ((circle.center.y / processingScale) * drawScale))
            return Circle(center: center, radius: (circle.radius / processingScale) * drawScale)
        }

        delegate?.draw(circles: drawableCircles)
        isProcessing = false
    }

    func circleDetectionResizeCIImage(by ciImage: CIImage) {
        isProcessing = true
        let processingScale = processingImageHeight / ciImage.extent.height
//        guard let previewSize = previewSize, let resizedImage = convert(from: ciImage, affine: processingScale) else { return }
//        guard let previewSize = previewSize, let resizedImage = convert(from: ciImage, lanczos: processingScale) else { return }
        guard let previewSize = previewSize, let resizedImage = convert(from: ciImage, bicubic: processingScale) else { return }

        let aspectRatioForPreview = (previewSize.width / previewSize.height)

        // プレビュー表示されない領域幅の片側オフセット値(原寸大画像ベースで算出)
        // AVCaptureVideoPreviewLayerでvideoGravityをresizeAspectFillにした場合、縦については全て表示され
        // 左右は切り取られるように表示調整されることから、非表示領域内にある原点を考慮しこのような実装となっている
        let offsetX: CGFloat = (ciImage.extent.width - (ciImage.extent.height * aspectRatioForPreview)) / 2
        let drawScale: CGFloat = previewSize.height / ciImage.extent.height

        // offsetXを表示スクリーン換算で算出
        let offsetForDrawScaleX = offsetX * drawScale

        let drawableCircles = imageProcessor.circleDetection(from: resizedImage, minimumDistance: minimumDistance).compactMap { circle -> Circle in
            let center = CGPoint(x: ((circle.center.x / processingScale) * drawScale) - offsetForDrawScaleX,
                                 y: ((circle.center.y / processingScale) * drawScale))
            return Circle(center: center, radius: (circle.radius / processingScale) * drawScale)
        }

        delegate?.draw(circles: drawableCircles)
        isProcessing = false
    }
}

private extension Presenter {
    /// UIImageへのコンバートのみ行う
    func convert(from ciImage: CIImage) -> UIImage? {
        return autoreleasepool { [weak self] in
            // UIImage -> CGImage -> UIImage
            guard let self = self,
                let cgImage = self.context.createCGImage(ciImage, from: ciImage.extent) else {
                    return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }

    /// UIImageへのコンバートとリサイズを並行して行う(アフィン変換)
    func convert(from ciImage: CIImage, affine scale: CGFloat) -> UIImage? {
        return autoreleasepool { [weak self] in
            // UIImage -> CGImage -> UIImage
            guard let self = self,
                let outputImage = ciImage.resizeUsingAffine(to: scale),
                let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent) else {
                    return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }

    /// UIImageへのコンバートとリサイズを並行して行う(lanczos法)
    func convert(from ciImage: CIImage, lanczos scale: CGFloat) -> UIImage? {
        return autoreleasepool { [weak self] in
            // UIImage -> CGImage -> UIImage
            guard let self = self,
                let outputImage = ciImage.resizeUsingLanczos(to: scale),
                let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent) else {
                    return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }

    /// UIImageへのコンバートとリサイズを並行して行う(bicubic法)
    func convert(from ciImage: CIImage, bicubic scale: CGFloat) -> UIImage? {
        return autoreleasepool { [weak self] in
            // UIImage -> CGImage -> UIImage
            guard let self = self,
                let outputImage = ciImage.resizeUsingBicubic(to: scale),
                let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent) else {
                    return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }
}
