//
//  OpenCVImageProcessor.m
//  OpneCVImageProcessingFramework
//
//  Created by kotetu on 2019/08/12.
//  Copyright © 2019 kotetu. All rights reserved.
//

// OpenCV系のヘッダはApple系のヘッダよりも先にimportすること
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#endif

#import "OpenCVDriver.h"

@implementation OpenCVDriver

- (NSArray<CircleDetectionResult *> *)circleDetectionWithUIImage:(UIImage *)sourceImage minimumDistance:(double)minDistance
{
    // 検証用コードなので、入力時点でグレイスケールされた画像が入力される前提の処理となっている
    cv::Mat souceMat;
    std::vector<cv::Vec3f> circles;
    UIImageToMat(sourceImage, souceMat, false);

    cv::HoughCircles(souceMat, circles, cv::HOUGH_GRADIENT, 1, minDistance);
    NSMutableArray<CircleDetectionResult*> *circleDetectionResults = [[NSMutableArray<CircleDetectionResult*> alloc] init];
    for(auto circle : circles) {
        [circleDetectionResults addObject:[[CircleDetectionResult alloc] initWithCenterX:circle[0] centerY:circle[1] radius:circle[2]]];
    }
    return circleDetectionResults;
}
@end
