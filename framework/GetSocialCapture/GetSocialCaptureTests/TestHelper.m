//
//  TestHelper.m
//  GetSocialCaptureTests
//
//  Created by Vass Gábor on 18/05/2018.
//  Copyright © 2018 GetSocial. All rights reserved.
//

#import "TestHelper.h"
#import <UIKit/UIKit.h>

@implementation TestHelper

+ (NSMutableArray*) testImagesFromFolder:(NSString*)folderName {
    NSMutableArray* testImages = [NSMutableArray array];
    
    NSString* bundlePath = [[NSBundle bundleForClass:[self class]] bundlePath];
    NSString* dirPath = [bundlePath stringByAppendingPathComponent:folderName];
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    [files enumerateObjectsUsingBlock:^(NSString*  imagePath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* fullImagePath = [dirPath stringByAppendingPathComponent:imagePath];
        UIImage* image = [UIImage imageWithContentsOfFile:fullImagePath];
        [testImages addObject:image];
    }];
    return testImages;
}

@end
