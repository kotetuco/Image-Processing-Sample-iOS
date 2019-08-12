//
//  OpenCVDriver.h
//  OpneCVImageProcessingFramework
//
//  Created by kotetu on 2019/08/12.
//  Copyright © 2019 kotetu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CircleDetectionResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVDriver : NSObject

/// 入力画像はグレイスケールした画像を指定するようにしてください
- (NSArray<CircleDetectionResult *> *)circleDetectionWithUIImage: (UIImage *)sourceImage minimumDistance:(double)minDistance;

@end

NS_ASSUME_NONNULL_END
