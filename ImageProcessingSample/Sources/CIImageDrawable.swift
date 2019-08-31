//
//  CIImageDrawable.swift
//  ImageProcessingSample
//
//  Created by kotetu on 2019/08/31.
//  Copyright © 2019 kotetu. All rights reserved.
//

import CoreImage

protocol CIImageDrawable {
    var isHidden: Bool { get set }

    func draw(image: CIImage)
}
