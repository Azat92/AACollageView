//
//  DelegateCollageViewController.m
//  AACollageView
//
//  Created by Azat Almeev on 04.03.15.
//  Copyright (c) 2015 Azat Almeev. All rights reserved.
//

#import "DelegateCollageViewController.h"
#import "AACollageView.h"
#import <BlocksKit/BlocksKit.h>
#import "ImageShowViewController.h"

@interface DelegateCollageViewController () <AACollageViewDelegate>
@property (weak, nonatomic) IBOutlet AACollageView *collageView;
@property (readonly) NSArray *imageURLS;
@property (readonly) NSArray *imageSizes;
@end

@implementation DelegateCollageViewController
@synthesize imageURLS = _imageURLS;
@synthesize imageSizes = _imageSizes;

- (NSArray *)imageURLS {
    if (!_imageURLS) {
        NSArray *imageNames = @[ @"1.jpg", @"2.jpg", @"3.jpg", @"4.png", @"5.jpg", @"6.png", @"7.jpg", @"8.jpg", @"9.png" ];
        _imageURLS = [imageNames bk_map:^id(id obj) {
            return [[NSBundle mainBundle] URLForResource:obj withExtension:@""];
        }];
    }
    return _imageURLS;
}

- (NSArray *)imageSizes {
    if (!_imageSizes) {
        _imageSizes = @[ [NSValue valueWithCGSize:CGSizeMake(319, 136)],
                         [NSValue valueWithCGSize:CGSizeMake(429, 285)],
                         [NSValue valueWithCGSize:CGSizeMake(274, 274)],
                         [NSValue valueWithCGSize:CGSizeMake(144, 120)],
                         [NSValue valueWithCGSize:CGSizeMake(150, 150)],
                         [NSValue valueWithCGSize:CGSizeMake(75, 250)],
                         [NSValue valueWithCGSize:CGSizeMake(133, 480)],
                         [NSValue valueWithCGSize:CGSizeMake(180, 133)],
                         [NSValue valueWithCGSize:CGSizeMake(225, 75)] ];
    }
    return _imageSizes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"With delegate";
    self.collageView.delegate = self;
    [self.collageView setupCollageConstraintsWithMargin:3 height:NAN orWidth:self.view.frame.size.width refreshCollage:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowImageSegue"]) {
        ImageShowViewController *dvc = segue.destinationViewController;
        dvc.image = sender;
    }
}

#pragma mark - Collage View Delegate
- (NSInteger)imagesCountInCollageView:(AACollageView *)collageView {
    return 9;
}

- (CGSize)collageView:(AACollageView *)collageView sizeForImageAtIndex:(NSUInteger)index {
    return [self.imageSizes[index] CGSizeValue];
}

- (NSURL *)collageView:(AACollageView *)collageView URLForImageAtIndex:(NSUInteger)index {
    //Could be URL from the web
    return self.imageURLS[index];
}

- (void)collageView:(AACollageView *)collageView didTapAtImageView:(UIImageView *)imageView atIndex:(NSUInteger)index {
    [self performSegueWithIdentifier:@"ShowImageSegue" sender:imageView.image];
}

@end
