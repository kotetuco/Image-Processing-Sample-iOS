//
//  OpenCVImageProcessor.swift
//  OpneCVImageProcessingFramework
//
//  Created by kotetu on 2019/08/12.
//  Copyright © 2019 kotetu. All rights reserved.
//

public struct Circle {
    public var center: CGPoint
    public var radius: CGFloat

    public init(center: CGPoint, radius: CGFloat) {
        self.center = center
        self.radius = radius
    }
}

public protocol ImageProcessor {
    /// 将来的に、OpenCV以外でも使えるInterfaceにするために、UIImageではない抽象的な画像型を使うようにする
    func circleDetection(from image: UIImage, minimumDistance: Double) -> [Circle]
}

public final class OpenCVImageProcessor: ImageProcessor {
    let driver: OpenCVDriver

    public init(driver: OpenCVDriver = OpenCVDriver()) {
        self.driver = driver
    }

    public func circleDetection(from image: UIImage, minimumDistance: Double = 2) -> [Circle] {
        return driver.circleDetection(with: image, minimumDistance: minimumDistance).compactMap {
            Circle(center: CGPoint(x: CGFloat($0.centerX),
                                   y: CGFloat($0.centerY)),
                   radius: CGFloat($0.radius)) }
    }
}
