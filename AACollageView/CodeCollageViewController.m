//
//  CodeCollageViewController.m
//  AACollageView
//
//  Created by Azat Almeev on 04.03.15.
//  Copyright (c) 2015 Azat Almeev. All rights reserved.
//

#import "CodeCollageViewController.h"
#import "AACollageView.h"
#import <BlocksKit/BlocksKit.h>

@interface CodeCollageViewController ()

@end

@implementation CodeCollageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"From code";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    AACollageView *collageView = [[AACollageView alloc] initWithFrame:self.view.frame];
    collageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:collageView];
    NSArray *imageNames = @[ @"1.jpg", @"2.jpg", @"3.jpg", @"4.png", @"5.jpg", @"6.png", @"7.jpg", @"8.jpg", @"9.png" ];
    collageView.imagesArray = [imageNames bk_map:^id(NSString *name) {
        return [UIImage imageNamed:name];
    }];
    [collageView setupCollageConstraintsWithMargin:3 height:NAN orWidth:self.view.frame.size.width refreshCollage:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
}

@end
