//
//  ViewController.swift
//  ImageProcessingSample
//
//  Created by kotetu on 2019/07/30.
//  Copyright © 2019 kotetu. All rights reserved.
//

import UIKit
import CameraFramework
import RxSwift

class ViewController: UIViewController {
    @IBOutlet private weak var previewView: UIView!

    private var videoCapture: VideoImageCapture?
    private let videoAccess = VideoAccess()
    private let disposeBag = DisposeBag()
    private let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestVideoAccess()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoCapture?.stop()
    }

    private func requestVideoAccess() {
        guard videoCapture == nil else { return }
        videoAccess
            .requestVideoAccess()
            .subscribeOn(backgroundScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] completable in
                guard let self = self else { return }
                switch completable {
                case .completed:
                    if let videoCapture = BasicVideoDataCaptureBuilder().build() {
                        videoCapture.setupPreviewLayer(previewContainer: self.previewView.layer)
                        videoCapture.start()
                        self.videoCapture = videoCapture
                    }
                case .error(_):
                    let alert = UIAlertController(title: "エラー",
                                                  message: "カメラのアクセスを許可してください。",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
    }
}
