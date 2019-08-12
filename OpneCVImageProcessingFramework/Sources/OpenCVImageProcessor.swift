//
//  OpenCVImageProcessor.swift
//  OpneCVImageProcessingFramework
//
//  Created by kotetu on 2019/08/12.
//  Copyright © 2019 kotetu. All rights reserved.
//

public struct Circle {
    var center: CGPoint
    var radius: CGFloat
}

public protocol ImageProcessor {
    associatedtype Image
    func circleDetection(from image: Image, minimumDistance: Double) -> [Circle]
}

public final class OpenCVImageProcessor: ImageProcessor {
    public typealias Image = UIImage

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
