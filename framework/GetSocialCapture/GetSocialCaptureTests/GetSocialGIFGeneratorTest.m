//
//  GetSocialGIFGeneratorTest.m
//  GetSocialCaptureTests
//
//  Created by Vass Gábor on 18/05/2018.
//  Copyright © 2018 GetSocial. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GetSocialGIFGenerator.h"
#import "TestHelper.h"

@interface GetSocialGIFGeneratorTest : XCTestCase

@property NSMutableArray* frames;

@end

@implementation GetSocialGIFGeneratorTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFileGeneration_landscapeImages {
    
    [self measureBlock:^{
        self.frames = [TestHelper testImagesFromFolder: @"facepalm-png"];
        
        XCTestExpectation *expectation = [self expectationWithDescription:@"should finish"];
        
        GetSocialGIFGenerator* generator = [[GetSocialGIFGenerator alloc] initWithResultConfiguration:nil];
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
        self.frames = [TestHelper testImagesFromFolder:@"pointing-png"];
        
        XCTestExpectation *expectation = [self expectationWithDescription:@"should finish"];
        
        GetSocialGIFGenerator* generator = [[GetSocialGIFGenerator alloc] initWithResultConfiguration:nil];
        [generator generateFileWithFrames:self.frames result:^(NSURL * fileURL) {
            NSLog(@"FINISHED: %@", fileURL);
            [NSThread sleepForTimeInterval:1];
            [expectation fulfill];
        }];
        [self waitForExpectationsWithTimeout:10.0 handler:nil];
    }];
}

@end
