//
//  UIImage+Resize.swift
//  ImageProcessingSample
//
//  Created by kotetu on 2019/08/31.
//  Copyright © 2019 kotetu. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(to scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width * scale,
                             height: size.height * scale)
        return resize(to: newSize)
    }

    func resize(to size: CGSize) -> UIImage {
        // UIGraphicsImageRendererデバイスのスクリーンスケールに合わせて画像をリサイズするようになっている。
        // ただ、ここでは画像処理用のリサイズを行いたいので、UIGraphicsImageRendererFormat.scaleを1に設定する必要がある。
        // ※ UI表示用にリサイズする場合は逆にscale設定しない方が良い
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image(actions: { context in
            let newRect = CGRect(origin: .zero, size: size)
            self.draw(in: newRect)
        })
    }

    func resizeForOLD(to scale: CGFloat) -> UIImage? {
        let newSize = CGSize(width: size.width * scale,
                             height: size.height * scale)
        return resizeForOLD(to: newSize)
    }

    func resizeForOLD(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        let newRect = CGRect(origin: .zero, size: size)
        draw(in: newRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
