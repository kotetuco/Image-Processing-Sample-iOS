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

    private func circleDetection(by ciImage: CIImage) {
        isProcessing = true
        guard let previewSize = previewSize, let uiImage = convert(from: ciImage) else { return }
        let aspectRatioForPreview = (previewSize.width / previewSize.height)
        // プレビュー表示されない領域幅の片側オフセット値(原寸大画像ベースで算出)
        // AVCaptureVideoPreviewLayerでvideoGravityをresizeAspectFillにした場合、縦については全て表示され
        // 左右は切り取られるように表示調整されることから、非表示領域内にある原点を考慮しこのような実装となっている
        let offsetX: CGFloat = (uiImage.size.width - (uiImage.size.height * aspectRatioForPreview)) / 2
        let detectCircles = self.imageProcessor.circleDetection(from: uiImage, minimumDistance: 30)
        let drawScale: CGFloat = previewSize.height / ciImage.extent.height
        // offsetXを表示スクリーン換算で算出
        let offsetForDrawScaleX = offsetX * drawScale
        let drawableCircles = detectCircles.compactMap { circle -> Circle in
            let center = CGPoint(x: (circle.center.x * drawScale) - offsetForDrawScaleX,
                                 y: circle.center.y * drawScale)
            return Circle(center: center, radius: circle.radius * drawScale )
        }
        delegate?.draw(circles: drawableCircles)
        isProcessing = false
    }
}

extension Presenter: VideoImageCaptureDelegate {
    func didOutput(ciImage: CIImage) {
        delegate?.draw(ciImage: ciImage)
        if !isProcessing {
            circleDetectionQueue.async { [weak self] in
                self?.circleDetection(by: ciImage)
            }
        }
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

    /// UIImageへのコンバートとリサイズを並行して行う
    func convert(from ciImage: CIImage, scale: CGFloat) -> UIImage? {
        return autoreleasepool { [weak self] in
            // UIImage -> CGImage -> UIImage
            guard let self = self,
                let outputImage = ciImage.resize(scale: scale),
                let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent) else {
                    return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }
}
