//
//  ScaleFilter.swift
//  ImageProcessingSample
//
//  Created by kotetu on 2019/08/13.
//  Copyright © 2019 kotetu. All rights reserved.
//

import CoreImage

extension CIImage {
    func resizeAffine(scale: CGFloat) -> CIImage? {
        return self.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    }

    func resizeLanczos(scale: CGFloat) -> CIImage? {
        guard let filter = CIFilter(name: "CILanczosScaleTransform") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)
        return filter.outputImage
    }

    func resizeBicubic(scale: CGFloat) -> CIImage? {
        guard let filter = CIFilter(name: "CIBicubicScaleTransform") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)
        return filter.outputImage
    }
}
