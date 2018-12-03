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

#import "GetSocialCapture.h"
#import "GetSocialCaptureInternal.h"

@interface GetSocialCapture()

@end

@implementation GetSocialCapture

static GetSocialCaptureInternal* _captureInternal;

static int _captureFrameRate = 10;
static int _maxCapturedFrames = 50;
static int _captureMode = Continuous;
static GetSocialCapturePlaybackFormat _playbackFormat = GIF;
static float _playbackFrameRate = 30;

#pragma mark - Lifecycle
+ (GetSocialCaptureInternal*) captureInternal:(BOOL)createNewSession {
    if (createNewSession) {
        _captureInternal = nil;
    }
    if (_captureInternal == nil) {
        _captureInternal = [GetSocialCaptureInternal new];
    }
    return _captureInternal;
}


#pragma mark - GetSocialCapture methods

+ (void) startWithView:(UIView *)view {
    [[GetSocialCapture captureInternal:YES] startWithView: view];
}

+ (void) pause {
    [[GetSocialCapture captureInternal:NO] pause];
}

+ (void) resume {
    [[GetSocialCapture captureInternal:NO] resume];
}

+ (void) captureFrame:(UIView* )view {
    [[GetSocialCapture captureInternal:NO] resume];
}

+ (void) generateCapture:(void (^)(NSData *))result {
    [[GetSocialCapture captureInternal:NO] generateCapture:result];
}

+ (GetSocialCapturePreview*) generatePreview {
    return [[GetSocialCapture captureInternal:NO] generatePreview];
}

#pragma mark - Static property accessors

+ (int) captureFrameRate {
    return _captureFrameRate;
}

+ (int) maxCapturedFrames {
    return _maxCapturedFrames;
}

+ (GetSocialCaptureMode) captureMode {
    return _captureMode;
}

+ (GetSocialCapturePlaybackFormat) playbackFormat {
    return _playbackFormat;
}

+ (float) playbackFrameRate {
    return _playbackFrameRate;
}

+ (void) setCaptureFrameRate:(int)captureFrameRate {
    _captureFrameRate = captureFrameRate;
}

+ (void) setMaxCapturedFrames:(int)maxCapturedFrames {
    _maxCapturedFrames = maxCapturedFrames;
}

+ (void) setCaptureMode:(GetSocialCaptureMode)captureMode {
    _captureMode = captureMode;
}

+ (void) setPlaybackFormat:(GetSocialCapturePlaybackFormat)playbackFormat {
    _playbackFormat = playbackFormat;
}

+ (void) setPlaybackFrameRate:(float)playbackFrameRate {
    _playbackFrameRate = playbackFrameRate;
}


@end
