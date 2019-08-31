//
//  UIImage+Resize.swift
//  ImageProcessingSample
//
//  Created by kotetu on 2019/08/31.
//  Copyright © 2019 kotetu. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(scale: CGFloat) -> UIImage {
        let resizedSize = CGSize(width: size.width * scale,
                                 height: size.height * scale)
        // UIGraphicsImageRendererデバイスのスクリーンスケールに合わせて画像をリサイズするようになっている。
        // ただ、ここでは画像処理用のリサイズを行いたいので、UIGraphicsImageRendererFormat.scaleを1に設定する必要がある。
        // ※ UI表示用にリサイズする場合は逆にscale設定しない方が良い
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: resizedSize, format: format)
        return renderer.image(actions: { context in
            self.draw(in: CGRect(origin: .zero, size: resizedSize))
        })
    }

    func resizeOLD(scale: CGFloat) -> UIImage? {
        let newWidth = size.width * scale
        let newHeight = size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
