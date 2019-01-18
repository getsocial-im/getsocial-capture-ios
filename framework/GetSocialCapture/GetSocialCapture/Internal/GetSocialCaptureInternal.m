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
#import <QuartzCore/QuartzCore.h>
#import "NSMutableArray+Queue.h"
#import "GetSocialCapturePreview+Internal.h"
#import "GetSocialMediaGenerator.h"
#import "GetSocialGIFGenerator.h"
#import "GetSocialCaptureInternal.h"
#import "NSData+Compression.h"
#import <MetalKit/MetalKit.h>
#import <SpriteKit/SpriteKit.h>

@interface GetSocialCaptureInternal()

typedef NS_ENUM(NSInteger, GetSocialCaptureGameEngine) {
    SpriteKit = 0,
    MetalKit = 1,
    Basic = 2
};

@property (nonatomic) UIView* contentView;
@property (nonatomic) NSTimer* captureTimer;
@property (nonatomic) NSMutableArray* capturedFrames;
@property (nonatomic) NSURL* generatedFileURL;
@property (nonatomic) NSString* captureSessionId;
@property (nonatomic) int captureWidth;
@property (nonatomic) int captureHeight;
@property (nonatomic) CGSize captureSize;
@property (nonatomic) GetSocialCaptureGameEngine gameEngine;

@end

@implementation GetSocialCaptureInternal

#pragma mark - Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        self.capturedFrames = [NSMutableArray arrayWithMaximumSize:GetSocialCapture.maxCapturedFrames];
        self.captureSessionId = [NSUUID UUID].UUIDString;
        CaptureLog(@"Configured Capture FPS: %d", GetSocialCapture.captureFrameRate);
        CaptureLog(@"Configured Max Frames: %d", GetSocialCapture.maxCapturedFrames);
        CaptureLog(@"Configured Mode: %ld", GetSocialCapture.captureMode);
        CaptureLog(@"Configured Playback FPS: %f", GetSocialCapture.playbackFrameRate);
        CaptureLog(@"Configured Playback format: %ld", GetSocialCapture.playbackFormat);
    }
    return self;
}

#pragma mark - GetSocialCapture methods

- (void) startWithView:(UIView* )view {
    self.contentView = view;
    self.captureWidth = view.bounds.size.width / 2;
    self.captureHeight = view.bounds.size.height / 2;
    self.captureSize = CGSizeMake(self.captureWidth, self.captureHeight);

    self.gameEngine = [self detectGameEngine];

    [self startCapturing];
}

- (void) pause {
    [self stopCapturing];
}

- (void) resume {
    [self startCapturing];
}

- (void) captureFrame:(UIView* )view {
    self.contentView = view;
    self.captureWidth = view.bounds.size.width / 2;
    self.captureHeight = view.bounds.size.height / 2;
    self.captureSize = CGSizeMake(self.captureWidth, self.captureHeight);

    [self startCapturing];
}

- (void) generateCapture:(void (^)(NSData *))result {
    [self stopCapturing];
    
    self.generatedFileURL = [self generateResultFileURL];

    GetSocialMediaGenerator* mediaGenerator = [[GetSocialMediaGenerator alloc] init];
    [mediaGenerator generateFile:self.generatedFileURL withFrames:self.capturedFrames size:CGSizeMake(self.captureWidth, self.captureHeight) result:^(void) {
        CaptureLog(@"Generated file: %@", self.generatedFileURL);
        result([NSData dataWithContentsOfURL:self.generatedFileURL]);
        self.capturedFrames = [NSMutableArray new];
    }];
}

- (GetSocialCapturePreview*) generatePreview {
    GetSocialCapturePreview* preview = [[GetSocialCapturePreview alloc] initWithAnimationURL:self.generatedFileURL];
    return preview;
}

- (void) cleanup {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.generatedFileURL.absoluteString]) {
        [fileManager removeItemAtURL:self.generatedFileURL error:nil];
    }
}

#pragma mark - Private methods

- (void) startCapturing {
    float captureFrequency;
    BOOL repeat;
    switch (GetSocialCapture.captureMode) {
        case Continuous:
            captureFrequency = 1.0f / GetSocialCapture.captureFrameRate;
            repeat = YES;
            break;
        case Manual:
            captureFrequency = 0.0f;
            repeat = NO;
            break;
        default:
            break;
    }
    CaptureLog(@"Capture frequency set to %f msec", captureFrequency);
    self.captureTimer = [NSTimer timerWithTimeInterval: captureFrequency target:self selector:@selector(createScreenshot) userInfo:nil repeats:YES];

    // start
    CaptureLog(@"Start capturing");
    [[NSRunLoop mainRunLoop] addTimer:self.captureTimer forMode:NSDefaultRunLoopMode];
}

- (void) stopCapturing {
    [self.captureTimer invalidate];
    self.captureTimer = nil;
    CaptureLog(@"Finish capturing");
}

- (void) createScreenshot {
    CGImageRef imageRef = nil;
    switch (self.gameEngine) {
        case MetalKit:
            imageRef = [self createScreenshotUsingMetalKit];
            break;
        case SpriteKit:
            imageRef = [self createScreenshotUsingSpriteKit];
            break;
        case Basic:
            imageRef = [self createDefaultScreenshot];
            break;
        default:
            break;
    }
    UIImage *capturedImage = [UIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    [self storeCapturedScreenshot:capturedImage];
}

- (CGImageRef) createScreenshotUsingSpriteKit {
    SKView* view = self.contentView.subviews[0];
    SKNode* node = view.scene;
    SKTexture* texture = [view textureFromNode:node];
    return texture.CGImage;
}

- (CGImageRef) createScreenshotUsingMetalKit {
#if !TARGET_OS_SIMULATOR
    MTKView* view = (MTKView*)self.contentView;
    // set framebufferOnly to No to be able to create screenshot
    view.framebufferOnly = NO;
    id<MTLTexture> texture = [view currentDrawable].texture;
    CIImage* ciImage = [CIImage imageWithMTLTexture:texture options:nil];
    
    // resize image
    CIFilter* filter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [filter setValue:ciImage forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithDouble:0.5] forKey:@"inputScale"];
    [filter setValue:[NSNumber numberWithDouble:1.0] forKey:@"inputAspectRatio"];
    CIImage* resizedImage = (CIImage*)[filter valueForKey:@"outputImage"];
    CIContext* ciContext = [CIContext new];
    return [ciContext createCGImage:resizedImage fromRect:resizedImage.extent];
#else
    return nil;
#endif
}

- (CGImageRef) createDefaultScreenshot {
    CGRect screenshotRect = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.contentView.bounds.size, YES, 0.0);
    
    [self.contentView drawViewHierarchyInRect:screenshotRect afterScreenUpdates: NO];
    
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return capturedImage.CGImage;
}

- (GetSocialCaptureGameEngine) detectGameEngine {
    if ([[self.contentView class] isSubclassOfClass:[MTKView class]]) {
        CaptureLog(@"Game engine is MetalKit");
        return MetalKit;
    }
    if ([[self.contentView class] isKindOfClass:[SKView class]]) {
        CaptureLog(@"Game engine is SpriteKit");
        return SpriteKit;
    }
    for (id subview in self.contentView.subviews) {
        if ([[subview class] isSubclassOfClass:[SKView class]]) {
            CaptureLog(@"Game Engine is SpriteKit");
            return SpriteKit;
        }
    }
    CaptureLog(@"Unknown Game Engine, fallback to basic capture method.");
    return Basic;
}

- (void) storeCapturedScreenshot: (UIImage*) capturedScreenshot {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @autoreleasepool {
            NSData* compressedImage = [self compressUIImage:capturedScreenshot];
            //[self saveImageToFile:compressedImage]; // only for debugging
            [self.capturedFrames appendObject:compressedImage];
        }
    });
    
}

- (NSData*) compressUIImage:(UIImage*)image {
    NSData* uncompressed = UIImageJPEGRepresentation(image, 5);
    NSData* compressed = [uncompressed compress];
    return compressed;
}

- (NSURL*) generateResultFileURL {
    NSString* extension;
    switch (GetSocialCapture.playbackFormat) {
        case GIF:
            extension = @"gif";
            break;

        default:
            break;
    }
    NSURL *documentsDirectoryURL =
    [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    
    NSString* fileName = [NSString stringWithFormat:@"capturesession-%@.%@", self.captureSessionId, extension];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent: fileName] ;
    return fileURL;
}

#pragma mark - ONLY FOR DEBUGGING

- (void)saveImageToFile:(UIImage*)image {
    NSURL *documentsDirectoryURL =
    [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:@"image.png"];
    NSData* imageData = UIImagePNGRepresentation(image);
    [imageData writeToURL:fileURL atomically:NO];
    CaptureLog(@"Sample image saved to: %@", fileURL.absoluteString);
}


@end
