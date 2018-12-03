/*
 *        Copyright 2015-2018 GetSocial B.V.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import <UIKit/UIKit.h>

//! Project version number for GetSocialCapture.
FOUNDATION_EXPORT double GetSocialCaptureVersionNumber;

//! Project version string for GetSocialCapture.
FOUNDATION_EXPORT const unsigned char GetSocialCaptureVersionString[];

#import <GetSocialCapture/GetSocialCapturePreview.h>

#define CAPTURE_DEBUG_ENABLED 1

#if CAPTURE_DEBUG_ENABLED
#define CaptureLog( s, ... ) NSLog( @"<%@:(%d)> %@", \
[[NSString stringWithUTF8String:__FILE__] lastPathComponent], \
__LINE__, \
[NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define CaptureLog( s, ... ) ;
#endif

/**
 * Class to invoke capturing actions.
 */
@interface GetSocialCapture : NSObject

typedef NS_ENUM(NSInteger, GetSocialCapturePlaybackFormat) {
    GIF = 0
};

typedef NS_ENUM(NSInteger, GetSocialCaptureMode) {
    Continuous = 0,
    Manual
};

#pragma mark - Capture configuration

/**
 * @abstract Number of captured frames per second. Default is 10.
 */
@property (class) int captureFrameRate;

/**
 * @abstract Capture mode. Default is Continuous.
 */
@property (class) GetSocialCaptureMode captureMode;

/**
 * @abstract Max. number of captured frames during the session. Default is 50.
 */
@property  (class) int maxCapturedFrames;

#pragma mark - Playback configuration

/**
 * @abstract    Result type. Default is gif.
 */
@property (class) GetSocialCapturePlaybackFormat playbackFormat;

/**
 * @abstract    Number of displayed frames per second. Default is 30.0f.
 */
@property (class) float playbackFrameRate;

#pragma mark - Public methods

/**
 * @abstract    Resumes the previously paused recording or starts a new one if there is no previous.
 * @param       view content to be captured.
 */
+ (void) startWithView:(UIView* )view;

/**
 * @abstract    Stops the started recording. It can be continued until a recording is started.
 */
+ (void) pause;

/**
 * @abstract    Resumes the previously paused recording or starts a new one.
 */
+ (void) resume;

/**
 * @abstract    Captures a single frame.
 */
+ (void) captureFrame:(UIView* )view;

/**
 * @abstract    Generates result.
 * @param       result block invoked when generation is finished.
 */
+ (void) generateCapture:(void (^)(NSData* ))result;


+ (GetSocialCapturePreview*) generatePreview;

@end
