//
//  ImageShowViewController.m
//  AACollageView
//
//  Created by Azat Almeev on 04.03.15.
//  Copyright (c) 2015 Azat Almeev. All rights reserved.
//

#import "ImageShowViewController.h"

@interface ImageShowViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ImageShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Image";
    self.imageView.image = self.image;
}

@end
