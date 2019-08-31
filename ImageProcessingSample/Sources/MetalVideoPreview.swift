//
//  MetalVideoPreview.swift
//  ImageProcessingSample
//
//  Created by Kuriyama Toru on 2019/08/29.
//  Copyright © 2019 kotetu. All rights reserved.
//

import MetalKit

final class MetalVideoPreview: MTKView {
    private let ciContext: CIContext?
    private let commandQueue: MTLCommandQueue?

    required init(coder: NSCoder) {
        if let mtlDevice = MTLCreateSystemDefaultDevice() {
            ciContext = CIContext(mtlDevice: mtlDevice)
            commandQueue = mtlDevice.makeCommandQueue()
            super.init(coder: coder)
            self.device = mtlDevice
        } else {
            ciContext = nil
            commandQueue = nil
            super.init(coder: coder)
        }
    }
}

extension MetalVideoPreview: CIImageDrawable {
    /// CIImageの描画(別スレッドから呼び出してもクラッシュしない)
    func draw(image: CIImage) {
        guard let ciContext = ciContext,
            let commandQueue = commandQueue,
            let mtlDrawable = currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer() else { return }

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        // 描画領域と同じサイズの画像を用意する(はみ出た分は切り取る)
        let aspectRatio = drawableSize.width / drawableSize.height
        let imageWidthAspectFit = image.extent.height * aspectRatio
        let scale = (drawableSize.height / image.extent.height)
        let displayImage = image
            .cropped(to: CGRect(origin: CGPoint(x: (image.extent.width - imageWidthAspectFit) / 2, y: 0),
                                size: CGSize(width: imageWidthAspectFit, height: image.extent.height)))
            .transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        ciContext.render(displayImage,
                         to: mtlDrawable.texture,
                         commandBuffer: commandBuffer,
                         bounds: displayImage.extent,
                         colorSpace: colorSpace)

        commandBuffer.present(mtlDrawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
