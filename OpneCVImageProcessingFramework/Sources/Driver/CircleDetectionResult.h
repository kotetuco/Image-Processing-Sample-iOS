//
//  CircleDetectionResult.h
//  OpneCVImageProcessingFramework
//
//  Created by kotetu on 2019/08/12.
//  Copyright © 2019 kotetu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CircleDetectionResult : NSObject

@property (nonatomic) float centerX;
@property (nonatomic) float centerY;
@property (nonatomic) float radius;

- (nullable instancetype)initWithCenterX:(float)centerX centerY:(float)centerY radius:(float)radius;
@end

NS_ASSUME_NONNULL_END
