//
//  GetSocialMP4GeneratorTests.m
//  GetSocialCaptureTests
//
//  Created by Vass Gábor on 18/05/2018.
//  Copyright © 2018 GetSocial. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "GetSocialMP4Generator.h"
#import "TestHelper.h"

@interface GetSocialMP4GeneratorTests : XCTestCase

@property NSMutableArray* frames;

@end

@implementation GetSocialMP4GeneratorTests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFileGeneration_landscapeImages {
    [self measureBlock:^{
        self.frames = [TestHelper testImagesFromFolder: @"facepalm-png"];
        
        XCTestExpectation *expectation = [self expectationWithDescription:@"should finish"];
        
        GetSocialMP4Generator* generator = [[GetSocialMP4Generator alloc] initWithResultConfiguration:[self resultConfiguration]];
        [generator generateFileWithFrames:self.frames result:^(NSURL * fileURL) {
            NSLog(@"FINISHED: %@", fileURL);
            [NSThread sleepForTimeInterval:1];
            [expectation fulfill];
        }];
        [self waitForExpectationsWithTimeout:10.0 handler:nil];
    }];
}

- (void)testFileGeneration_portrait {
    [self measureBlock:^{
        XCTestExpectation *expectation = [self expectationWithDescription:@"should finish"];
        self.frames = [TestHelper testImagesFromFolder:@"pointing-png"];
        GetSocialMP4Generator* generator = [[GetSocialMP4Generator alloc] initWithResultConfiguration:[self resultConfiguration]];
        [generator generateFileWithFrames:self.frames result:^(NSURL * fileURL) {
            NSLog(@"FINISHED: %@", fileURL);
            [NSThread sleepForTimeInterval:1];
            [expectation fulfill];
        }];
        [self waitForExpectationsWithTimeout:10.0 handler:nil];
    }];
}

- (GetSocialCaptureResultConfiguration*)resultConfiguration {
    GetSocialCaptureResultConfiguration* config = [GetSocialCaptureResultConfiguration new];
    config.playbackFrameRate = 24.0f;
    return config;
}

@end
