//
//  ViewController.swift
//  ImageProcessingSample
//
//  Created by kotetu on 2019/07/30.
//  Copyright © 2019 kotetu. All rights reserved.
//

import CameraFramework
import OpneCVImageProcessingFramework

final class ViewController: UIViewController {
    @IBOutlet private weak var cameraPreview: UIView!
    @IBOutlet private weak var detectCirclePreview: UIView!
    @IBOutlet private weak var glkPreview: GLVideoPreview!
    @IBOutlet private weak var mtkPreview: MetalVideoPreview!

    /// CIImageの描画先Viewを指定する(GLVideoPreview or MetalVideoPreview)
    private var drawView: CIImageDrawable!

    private let presenter = Presenter(imageProcessor: OpenCVImageProcessor(),
                                      videoAccess: VideoAccess())

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.delegate = self

        // CIImageの描画については下記設定を変更する
        drawView = mtkPreview
        drawView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.initializePreview()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.terminate()
    }
}

extension ViewController: PresenterDelegate {
    func showAccessDeniedError() {
        let alert = UIAlertController(title: "エラー",
                                      message: "カメラのアクセスを許可してください。",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showCameraInitializationError() {
        let alert = UIAlertController(title: "エラー",
                                      message: "カメラの初期化に失敗しました。",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func initializationDidSuccess() {
        presenter.startPreview(with: cameraPreview.layer)
    }

    func draw(circles: [Circle]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.drawShapeLayer(circles: circles)
        }
    }

    func draw(ciImage: CIImage) {
//        drawView.draw(image: ciImage)
    }
}

private extension ViewController {
    func drawShapeLayer(circles: [Circle]) {
        detectCirclePreview.layer.sublayers
            = circles.map({ circle -> CAShapeLayer in
                let shapeLayer = CAShapeLayer()
                let path = CGMutablePath()
                path.addArc(center: circle.center,
                            radius: circle.radius,
                            startAngle: 0,
                            endAngle: CGFloat.pi * 2,
                            clockwise: true)
                shapeLayer.path = path
                shapeLayer.strokeColor = UIColor.yellow.cgColor
                shapeLayer.fillColor = nil
                shapeLayer.lineWidth = 3.0
                return shapeLayer
            })
    }
}
