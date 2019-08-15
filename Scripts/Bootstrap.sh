#!/bin/sh

SCRIPT_DIR=$(cd $(dirname $0); pwd)/
PROJECT_DIR=$SCRIPT_DIR..

#
# Carthage Build
#

carthage bootstrap --platform iOS

#
# Downloading OpenCV
#

OPENCV_VERISON=4.1.1
OPENCV_DIR=$PROJECT_DIR/OpenCV
OPENCV_ZIP_FILE=$OPENCV_DIR/opencv-$OPENCV_VERISON-ios-framework.zip
OPENCV_FRAMEWORK_DIR=$OPENCV_DIR/opencv2.framework

if [ ! -d $OPENCV_DIR ]; then
    mkdir $OPENCV_DIR
fi

if [ ! -f $OPENCV_ZIP_FILE ]; then
    curl -L -o $OPENCV_ZIP_FILE -O https://github.com/opencv/opencv/releases/download/$OPENCV_VERISON/opencv-$OPENCV_VERISON-ios-framework.zip
fi

if [ ! -d $OPENCV_FRAMEWORK_DIR ]; then
    unzip $OPENCV_ZIP_FILE -d $OPENCV_DIR
fi
