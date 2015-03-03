//
//  AACollageView.h
//  PhotoCollage
//
//  Created by Azat Almeev on 02.03.15.
//  Copyright (c) 2015 Azat Almeev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AACollageView;

@protocol AACollageViewDelegate <NSObject>
/**
 * @brief Obligatory method if working with delegate. Tells the number of images
 * @param collageView collage view to populate
 */
- (NSInteger)imagesCountInCollageView:(AACollageView *)collageView;

//You should implement this method of couple of next methods
/**
 * @brief Tells the delegate a imageView at the specified index
 * @param collageView collage view to populate
 * @param index index of image in collage view
 */
- (UIImage *)collageView:(AACollageView *)collageView imageForIndex:(NSUInteger)index;
/**
 * @brief Tells the delegate a URL for image at the specified index
 * @param collageView collage view to populate
 * @param index index of image in collage view
 */
- (NSURL *)collageView:(AACollageView *)collageView URLForImageAtIndex:(NSUInteger)index;
/**
 * @brief Tells the delegate actual size for image at the specified index
 * @param collageView collage view to populate
 * @param index index of image in collage view
 */
- (CGSize)collageView:(AACollageView *)collageView sizeForImageAtIndex:(NSUInteger)index;

@optional
/**
 * @brief Tells the delegate that user tapped some particular image
 * @param collageView sender collage view
 * @param imageView user tapped view
 * @param index index of image in collage view
 */
- (void)collageView:(AACollageView *)collageView didTapAtImageView:(UIImageView *)imageView atIndex:(NSUInteger)index;
@end

@interface AACollageView : UIView
@property (nonatomic, strong) NSArray *imagesArray;
@property (nonatomic, weak) id <AACollageViewDelegate> delegate;
@property (readonly) CGSize collageViewSize;
@property (readonly) CGFloat imagesMargin;
@property (readonly) CGFloat collageHeightConstraint;
@property (readonly) CGFloat collageWidthConstraint;

/**
 * @brief You should call this method before refreshing collage or asking a resulting size. Here you pass constraints to collage view by width or height dimension - one of them should be NAN
 * @param imagesMargin margin to leave between images
 * @param heightConstraint maximum allowed height
 * @param heightConstraint maximum allowed width
 * @param needRefresh should call -refreshCollage method automatically or not
 */
- (void)setupCollageConstraintsWithMargin:(CGFloat)imagesMargin
                                   height:(CGFloat)heightConstraint
                                  orWidth:(CGFloat)widthConstraint
                           refreshCollage:(BOOL)needRefresh;

/**
 * @brief Refreshes collage at the screen. You should call this method only after setuping a constraints
 */
- (void)refreshCollage;

@end
