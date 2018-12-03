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

#import "GetSocialCapturePreview+Internal.h"
#import "GetSocialCapture.h"
#import "GIFUIImageView.h"

@interface GetSocialCapturePreview()

@property id<GetSocialCapturePreviewing> contentView;

@end

@implementation GetSocialCapturePreview

- (instancetype) initWithAnimationURL:(NSURL*)url {
    if (self = [super init]) {
        switch (GetSocialCapture.playbackFormat) {
            case GIF:
                _contentView = [GIFUIImageView viewWithAnimationURL:url];
                [self addSubview: (UIView*)_contentView];
                break;

            default:
                break;
        }
    }
    return self;
}

- (void) play {
    [self.contentView play];
}

- (void) stop {
    [self.contentView stop];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    ((UIView*)self.contentView).frame = self.bounds;
}

@end
