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

#import "GetSocialGIFGenerator.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "GetSocialCapture.h"
#import "NSData+Compression.h"

@implementation GetSocialGIFGenerator

- (void) generateFile:(NSURL*)filePath withFrames:(NSMutableArray*)capturedFrames size:(CGSize)size result:(void (^)(void))result {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self generateGIFFile:(NSURL*)filePath withFrames:capturedFrames size:size result:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                result();
            });
        }];
    });
}

#pragma mark - File Generation

- (void) generateGIFFile:(NSURL*)filePath withFrames:(NSMutableArray*)capturedFrames size:(CGSize)size result:(void (^)(void))result {
    float frameDuration = 1.0f / GetSocialCapture.playbackFrameRate;

    NSUInteger kFrameCount = capturedFrames.count;
    
    CaptureLog(@"Starting GIF generation");
    
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary : @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount : @1
                                             }
                                     };
    
    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary : @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime : [NSNumber numberWithFloat: frameDuration]  // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                              }
                                      };
        
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)filePath, kUTTypeGIF, kFrameCount, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    for (NSUInteger frameCounter = 0; frameCounter < kFrameCount; frameCounter++) {
        @autoreleasepool {
            NSData* compressedImage = capturedFrames[frameCounter];
            UIImage* image = [UIImage imageWithData:[compressedImage decompress]];
            CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    if (!CGImageDestinationFinalize(destination)) {
        CaptureLog(@"failed to finalize image destination");
    } else {
        CaptureLog(@"Finished GIF generation");
    }
    CFRelease(destination);
    result();
}

@end
