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
#ifdef DEBUG
    NSDate *startDate;
    NSDate *endDate;
    startDate = [NSDate date];
#endif

    cv::Mat sourceMat;
    cv::Mat sourceGrayScaleMat;
    cv::Mat gaussianBlurMat;
    std::vector<cv::Vec3f> circles;
    UIImageToMat(sourceImage, sourceMat, false);

    cv::cvtColor(sourceMat, sourceGrayScaleMat, cv::COLOR_BGR2GRAY);
    // そのままの画像だとノイズが大きすぎて円が取れすぎるため、ブラー(ぼかし)を入れてノイズを減らす
    cv::GaussianBlur(sourceGrayScaleMat, gaussianBlurMat, cv::Size(9, 9), 2, 2);
    cv::HoughCircles(gaussianBlurMat, circles, cv::HOUGH_GRADIENT, 1, minDistance);

    NSMutableArray<CircleDetectionResult*> *circleDetectionResults = [[NSMutableArray<CircleDetectionResult*> alloc] init];
    for(auto circle : circles) {
        [circleDetectionResults addObject:[[CircleDetectionResult alloc] initWithCenterX:circle[0] centerY:circle[1] radius:circle[2]]];
    }

#ifdef DEBUG
    endDate = [NSDate date];
    NSTimeInterval interval = [endDate timeIntervalSinceDate:startDate];
    NSLog(@"処理時間 = %.3f秒",interval);
#endif

    return circleDetectionResults;
}

#ifdef DEBUG
- (NSString*)getDateString:(NSDate*)date
{
    // 日付フォーマットオブジェクトの生成
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    // フォーマットを指定の日付フォーマットに設定
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS"];
    // 日付の文字列を生成
    NSString *dateString = [dateFormatter stringFromDate:date];

    return dateString;
}
#endif
@end
