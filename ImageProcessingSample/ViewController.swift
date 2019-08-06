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
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestVideoAccess()
    }

    private func requestVideoAccess() {
        let videoAccess = VideoAccess()
        videoAccess
            .requestVideoAccess()
            .observeOn(MainScheduler.instance)
            .subscribe { completable in
                switch completable {
                case .completed:
                    // TODO: start session
                    #if DEBUG
                    print("success")
                    #endif
                    break
                case .error(_):
                    // TODO: alert
                    #if DEBUG
                    print("failure")
                    #endif
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}
