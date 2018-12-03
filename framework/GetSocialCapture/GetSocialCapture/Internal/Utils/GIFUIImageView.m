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

#import "GIFUIImageView.h"
#import "UIImage+GIF.h"

@interface GIFUIImageView()

@property UIImage* animatedImage;

@end

@implementation GIFUIImageView

+ (GIFUIImageView * _Nullable)viewWithAnimationURL:(NSURL * _Nonnull)url {
    GIFUIImageView* view = [[GIFUIImageView alloc] initWithFrame:CGRectZero];
    [view setAnimationURL:url];
    return view;
}

- (void) play {
    self.animationImages = self.animatedImage.images;
    self.animationRepeatCount = 1;
    self.animationDuration = self.animatedImage.duration;
    [self startAnimating];
}

- (void) stop {
    [self startAnimating];
    self.image = self.animatedImage.images.firstObject;
}

- (void) setAnimationURL:(NSURL*)url {
    self.animatedImage = [UIImage imageWithAnimationURL:url];
    self.image = self.animatedImage.images.firstObject;
    self.animationRepeatCount = -1;
}

@end
