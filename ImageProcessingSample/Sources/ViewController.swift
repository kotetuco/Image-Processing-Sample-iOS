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
    @IBOutlet weak var resizedPreview: UIImageView!

    private let presenter = Presenter(imageProcessor: OpenCVImageProcessor(),
                                      videoAccess: VideoAccess())

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.delegate = self
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

    func didCapture(_ image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.resizedPreview.image = image
        }
    }
}
