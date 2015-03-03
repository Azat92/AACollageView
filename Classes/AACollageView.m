//
//  AACollageView.m
//  PhotoCollage
//
//  Created by Azat Almeev on 02.03.15.
//  Copyright (c) 2015 Azat Almeev. All rights reserved.
//

#import "AACollageView.h"
#import "AACollageMaker.h"
#import <BlocksKit/BlocksKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface AACollageView () {
    CGFloat _imagesMargin;
    CGFloat _heightConstraint;
    CGFloat _widthConstraint;
}
@property (readonly) BOOL assignedPropertiesAreCorrect;
@property (readonly) NSArray *imagesSizesArray;
@end

@implementation AACollageView

#define kIncorrectSetup @"Incorrect setup parameters"

- (BOOL)assignedPropertiesAreCorrect {
    if (!_imagesArray && !_delegate)
        return NO;
    if ((_heightConstraint <= 0 && _widthConstraint <= 0) || _imagesMargin < 0)
        @throw [NSException exceptionWithName:kIncorrectSetup reason:@"Constraints setup is incorrect" userInfo:nil];
    if (_imagesArray)
        return YES;
    if (!_delegate)
        @throw [NSException exceptionWithName:kIncorrectSetup reason:@"Should pass either imagesArray or delegate" userInfo:nil];
    if (![_delegate respondsToSelector:@selector(imagesCountInCollageView:)])
        return NO;
    if ([_delegate respondsToSelector:@selector(collageView:imageForIndex:)])
        return YES;
    if (![_delegate respondsToSelector:@selector(collageView:URLForImageAtIndex:)] || ![_delegate respondsToSelector:@selector(collageView:sizeForImageAtIndex:)])
        @throw [NSException exceptionWithName:kIncorrectSetup reason:@"Delegate should implement either -collageView:imageForIndex: or both of -collageView:URLForImageAtIndex: and -collageView:sizeForImageAtIndex: methods" userInfo:nil];
    return YES;
}

- (CGSize)collageViewSize {
    if (!self.assignedPropertiesAreCorrect)
        return CGSizeMake(_widthConstraint, _heightConstraint);
    else
        return [AACollageMaker resultSizeForViewsWithSizes:self.imagesSizesArray widthConstraint:_widthConstraint heightConstraint:_heightConstraint];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (isnan(_heightConstraint))
        _widthConstraint = frame.size.width;
    else if (isnan(_widthConstraint))
        _heightConstraint = frame.size.height;
    [self refreshCollage];
}

- (void)setupCollageConstraintsWithMargin:(CGFloat)imagesMargin
                                   height:(CGFloat)heightConstraint
                                  orWidth:(CGFloat)widthConstraint
                           refreshCollage:(BOOL)needRefresh {
    NSAssert((isnan(heightConstraint) ^ isnan(widthConstraint)) == 1, @"Should pass constraint only by one dimension");
    NSAssert((heightConstraint > 0 || widthConstraint > 0) && imagesMargin >= 0, @"Should pass meaningful parameters");
    _imagesMargin = imagesMargin;
    _heightConstraint = heightConstraint;
    _widthConstraint = widthConstraint;
    if (needRefresh)
        [self refreshCollage];
}

- (void)refreshCollage {
    if (!self.assignedPropertiesAreCorrect)
        return;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSArray *frames = [AACollageMaker rectsForViewsWithSizes:self.imagesSizesArray widthConstraint:_widthConstraint heightConstraint:_heightConstraint];
    [frames enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:self.imagesArray[idx]];
        if (self.imagesArray)
            imgView.image = self.imagesArray[idx];
        else
            [imgView sd_setImageWithURL:[_delegate collageView:self URLForImageAtIndex:idx]];
        imgView.frame = CGRectInset(value.CGRectValue, _imagesMargin / 2, _imagesMargin / 2);
        imgView.tag = idx;
        if ([_delegate respondsToSelector:@selector(collageView:didTapAtImageView:atIndex:)]) {
            imgView.userInteractionEnabled = YES;
            UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecogmiserDidFire:)];
            imgView.gestureRecognizers = @[ rec ];
        }
        [self addSubview:imgView];
    }];
}

- (NSArray *)imagesSizesArray {
    if (self.imagesArray)
        return [self.imagesArray bk_map:^id(UIImage *img) {
            return [NSValue valueWithCGSize:img.size];
        }];
    else {
        NSMutableArray *sizes = [NSMutableArray new];
        for (NSUInteger index = 0; index < [_delegate imagesCountInCollageView:self]; index++)
            [sizes addObject:[NSValue valueWithCGSize:[_delegate collageView:self sizeForImageAtIndex:index]]];
        return sizes;
    }
}

- (IBAction)tapGestureRecogmiserDidFire:(UITapGestureRecognizer *)sender {
    if ([_delegate respondsToSelector:@selector(collageView:didTapAtImageView:atIndex:)])
        [_delegate collageView:self didTapAtImageView:(UIImageView *)sender.view atIndex:sender.view.tag];
}

@end
