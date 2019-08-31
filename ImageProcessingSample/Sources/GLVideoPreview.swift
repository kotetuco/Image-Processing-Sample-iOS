//
//  GLVideoPreview.swift
//  ImageProcessingSample
//
//  Created by Kuriyama Toru on 2019/08/29.
//  Copyright © 2019 kotetu. All rights reserved.
//

import GLKit

// GLKViewはiOS12でdeprecatedになったので、検証目的以外では使用しないでください。
final class GLVideoPreview: GLKView {
    private let ciContext: CIContext?

    required init?(coder aDecoder: NSCoder) {
        if let eaglContext = EAGLContext(api: .openGLES3) {
            ciContext = CIContext(eaglContext: eaglContext)
            super.init(coder: aDecoder)
            self.context = eaglContext
        } else {
            ciContext = nil
            super.init(coder: aDecoder)
        }

        EAGLContext.setCurrent(self.context)
        enableSetNeedsDisplay = false
        contentScaleFactor = UIScreen.main.scale
        bindDrawable()
    }
}

extension GLVideoPreview: CIImageDrawable {
    /// CIImageの描画(別スレッドから呼び出してもクラッシュしない)
    func draw(image: CIImage) {
        guard let ciContext = ciContext else { return }
        let videoDisplayViewBounds
            = CGRect(x: 0, y: 0, width: CGFloat(drawableWidth), height: CGFloat(drawableHeight))

        // 描画領域と同じサイズの画像を用意する(はみ出た分は切り取る)
        let aspectRatio: CGFloat = CGFloat(drawableWidth) / CGFloat(drawableHeight)
        let imageWidthAspectFit = image.extent.height * aspectRatio
        let scale: CGFloat = (CGFloat(drawableHeight) / image.extent.height)
        let displayImage = image
            .cropped(to: CGRect(origin: CGPoint(x: (image.extent.width - imageWidthAspectFit) / 2, y: 0),
                                size: CGSize(width: imageWidthAspectFit, height: image.extent.height)))
            .transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        bindDrawable()
        ciContext.draw(displayImage, in: videoDisplayViewBounds, from: displayImage.extent)
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
}
