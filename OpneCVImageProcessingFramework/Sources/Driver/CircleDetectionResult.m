//
//  CircleDetectionResult.m
//  OpneCVImageProcessingFramework
//
//  Created by kotetu on 2019/08/12.
//  Copyright © 2019 kotetu. All rights reserved.
//

#import "CircleDetectionResult.h"

@implementation CircleDetectionResult

- (nullable instancetype)initWithCenterX:(float)centerX centerY:(float)centerY radius:(float)radius
{
    self = [super init];
    if (self) {
        self.centerX = centerX;
        self.centerY = centerY;
        self.radius = radius;
    }
    return self;
}
@end
