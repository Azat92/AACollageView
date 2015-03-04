//
//  StoryboardCollageViewController.m
//  AACollageView
//
//  Created by Azat Almeev on 04.03.15.
//  Copyright (c) 2015 Azat Almeev. All rights reserved.
//

#import "StoryboardCollageViewController.h"
#import "AACollageView.h"
#import <BlocksKit/BlocksKit.h>

@interface StoryboardCollageViewController ()
@property (weak, nonatomic) IBOutlet AACollageView *collageView;
@end

@implementation StoryboardCollageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"From storyboard";
    NSArray *imageNames = @[ @"1.jpg", @"2.jpg", @"3.jpg", @"4.png", @"5.jpg", @"6.png", @"7.jpg", @"8.jpg", @"9.png" ];
    self.collageView.imagesArray = [imageNames bk_map:^id(NSString *name) {
        return [UIImage imageNamed:name];
    }];
    [self.collageView setupCollageConstraintsWithMargin:3 height:NAN orWidth:self.view.frame.size.width refreshCollage:YES];
}

@end
