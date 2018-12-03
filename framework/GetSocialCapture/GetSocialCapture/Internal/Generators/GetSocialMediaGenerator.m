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

#import "GetSocialMediaGenerator.h"
#import "GetSocialGIFGenerator.h"
#import "GetSocialCapture.h"

@interface GetSocialMediaGenerator()

@property (nonatomic) id<GetSocialMediaGenerating> selectedMediaGenerator;

@end

@implementation GetSocialMediaGenerator

- (instancetype) init {
    if (self = [super init]) {
        switch (GetSocialCapture.playbackFormat) {
            case GIF:
                self.selectedMediaGenerator = [[GetSocialGIFGenerator alloc] init];
                break;

            default:
                break;
        }
    }
    return self;
}

- (void) generateFile:(NSURL*)filePath withFrames:(NSMutableArray*)capturedFrames size:(CGSize)size result:(void (^)(void))completion {
    __block long startTime = [[NSDate date] timeIntervalSince1970] * 1000;
    [self.selectedMediaGenerator generateFile:filePath withFrames:capturedFrames size:size result:^(void) {
        long duration = ([[NSDate date] timeIntervalSince1970] * 1000) - startTime;
        CaptureLog(@"Generating result of %lu frames took %ld msec", capturedFrames.count, duration);
        completion();
    }];
}

@end
