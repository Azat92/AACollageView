//
//  AACollageMaker.h
//  PhotoCollage
//
//  Created by Azat Almeev on 02.03.15.
//  Copyright (c) 2015 Azat Almeev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AACollageMaker : NSObject

+ (CGSize)resultSizeForViewsWithSizes:(NSArray *)sizes
                      widthConstraint:(CGFloat)widthConstraint
                     heightConstraint:(CGFloat)heightConstraint;

+ (NSArray *)rectsForViewsWithSizes:(NSArray *)sizes
                    widthConstraint:(CGFloat)widthConstraint
                   heightConstraint:(CGFloat)heightConstraint;

@end
