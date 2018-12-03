//
//  ViewController.m
//  spritybird
//
//  Created by Alexis Creuzot on 09/02/2014.
//  Copyright (c) 2014 Alexis Creuzot. All rights reserved.
//

#import "ViewController.h"
#import "Scene.h"
#import "Score.h"
#import <GetSocialCapture/GetSocialCapture.h>

@interface ViewController ()
@property (weak,nonatomic) IBOutlet SKView * gameView;
@property (weak,nonatomic) IBOutlet UIView * getReadyView;

@property (weak,nonatomic) IBOutlet UIView * gameOverView;
@property (weak,nonatomic) IBOutlet UIImageView * medalImageView;
@property (weak,nonatomic) IBOutlet UILabel * currentScore;
@property (weak,nonatomic) IBOutlet UILabel * bestScoreLabel;

@property UIView* capturePreviewPlaceholder;
@property GetSocialCapturePreview* capturePreview;

@end

@implementation ViewController
{
    Scene * scene;
    UIView * flash;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
	// Configure the view.
    //self.gameView.showsFPS = YES;
    //self.gameView.showsNodeCount = YES;
    
    // Create and configure the scene.
    scene = [Scene sceneWithSize:self.gameView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.delegate = self;
    
    // Present the scene
    self.gameOverView.alpha = 0;
    self.gameOverView.transform = CGAffineTransformMakeScale(.9, .9);
    [self.gameView presentScene:scene];
    
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Bouncing scene delegate

- (void)eventStart
{
    [self.capturePreviewPlaceholder removeFromSuperview];
    self.capturePreviewPlaceholder = nil;
    self.capturePreview = nil;
    
    [UIView animateWithDuration:.2 animations:^{
        self.gameOverView.alpha = 0;
        self.gameOverView.transform = CGAffineTransformMakeScale(.8, .8);
        flash.alpha = 0;
        self.getReadyView.alpha = 1;
    } completion:^(BOOL finished) {
        [flash removeFromSuperview];
    }];
}

- (void)eventPlay
{
    [UIView animateWithDuration:.5 animations:^{
        self.getReadyView.alpha = 0;
    }];
    GetSocialCapture.captureFrameRate = [[NSUserDefaults standardUserDefaults] integerForKey:@"capture_fps"];
    GetSocialCapture.maxCapturedFrames = [[NSUserDefaults standardUserDefaults] integerForKey:@"max_captured_frames"];
    GetSocialCapture.playbackFrameRate = [[NSUserDefaults standardUserDefaults] floatForKey:@"playback_fps"];
    GetSocialCapture.playbackFormat = [[NSUserDefaults standardUserDefaults] integerForKey:@"playback_format"];
    
    [GetSocialCapture startWithView:self.view];
}

- (void)eventWasted
{
    flash = [[UIView alloc] initWithFrame:self.view.frame];
    flash.backgroundColor = [UIColor whiteColor];
    flash.alpha = .9;
    [self.gameView insertSubview:flash belowSubview:self.getReadyView];
    
    [self shakeFrame];
    
    [UIView animateWithDuration:.6 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        // Display game over
        flash.alpha = .4;
        self.gameOverView.alpha = 1;
        self.gameOverView.transform = CGAffineTransformMakeScale(1, 1);
        
        // Set medal
        if(scene.score >= 40){
            self.medalImageView.image = [UIImage imageNamed:@"medal_platinum"];
        }else if (scene.score >= 30){
            self.medalImageView.image = [UIImage imageNamed:@"medal_gold"];
        }else if (scene.score >= 20){
            self.medalImageView.image = [UIImage imageNamed:@"medal_silver"];
        }else if (scene.score >= 10){
            self.medalImageView.image = [UIImage imageNamed:@"medal_bronze"];
        }else{
            self.medalImageView.image = nil;
        }
        
        // Set scores
        self.currentScore.text = F(@"%li",scene.score);
        self.bestScoreLabel.text = F(@"%li",(long)[Score bestScore]);
        
    } completion:^(BOOL finished) {
        flash.userInteractionEnabled = NO;

        self.capturePreviewPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 270)];
        self.capturePreviewPlaceholder.layer.borderColor = [UIColor redColor].CGColor;
        self.capturePreviewPlaceholder.layer.borderWidth = 2.0f;
        UIActivityIndicatorView* iv = [[UIActivityIndicatorView alloc] initWithFrame:self.capturePreviewPlaceholder.bounds];
        [self.capturePreviewPlaceholder addSubview:iv];
        [iv startAnimating];
        [self.view addSubview:self.capturePreviewPlaceholder];
        [GetSocialCapture generateCapture:^(NSData * result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.capturePreview = [GetSocialCapture generatePreview];
                
                self.capturePreview.frame = CGRectMake(0, 0, 150, 270);
                
                UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo)];
                [self.capturePreview addGestureRecognizer: recognizer];
                
                [iv stopAnimating];
                [iv removeFromSuperview];
                [self.capturePreviewPlaceholder addSubview:self.capturePreview];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.capturePreview play];
                });
            });
        }];

    }];
    
}

- (void)playVideo {
    [self.capturePreview play];
}

- (void) shakeFrame
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:4];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([self.view  center].x - 4.0f, [self.view  center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([self.view  center].x + 4.0f, [self.view  center].y)]];
    [[self.view layer] addAnimation:animation forKey:@"position"];
}

@end
