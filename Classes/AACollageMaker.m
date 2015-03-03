//
//  AACollageMaker.m
//  PhotoCollage
//
//  Created by Azat Almeev on 02.03.15.
//  Copyright (c) 2015 Azat Almeev. All rights reserved.
//

@import UIKit;
#import "AACollageMaker.h"
#import <BlocksKit/BlocksKit.h>

typedef enum : NSUInteger {
    AACollageMakerContainerTypeBox,   //Container
    AACollageMakerContainerTypeObject //Some object
} AACollageMakerContainerType;

typedef enum : NSUInteger {
    AACollageMakerContainerTypeSplitU,//Undefined
    AACollageMakerContainerTypeSplitV,//Vertical
    AACollageMakerContainerTypeSplitH //Horizontal
} AACollageMakerContainerTypeSplit;

@interface AACollageMakerContainer : NSObject
@property (nonatomic) CGSize size;
@property (nonatomic) CGPoint origin;
@property (nonatomic) AACollageMakerContainerType type;
@property (nonatomic) AACollageMakerContainerTypeSplit containerType;
@property (nonatomic) AACollageMakerContainerTypeSplit parentContainerType;
@property (nonatomic) BOOL pixelCheck;
@property (nonatomic, retain) NSNumber *inputOrder;
@property (nonatomic, strong) AACollageMakerContainer *firstChild;
@property (nonatomic, strong) AACollageMakerContainer *secondChild;
@property (nonatomic) double totalWidth;
@property (nonatomic) double totalHeight;
@property (nonatomic) double parentTotalWidth;
@property (nonatomic) double parentTotalHeight;
@property (nonatomic) double siblingsTotalWidth;
@property (nonatomic) double siblingsTotalHeight;
@end

@implementation AACollageMaker

+ (AACollageMakerContainer *)resultContainerForViewsWithSizes:(NSArray *)sizes
                                              widthConstraint:(CGFloat)widthConstraint
                                             heightConstraint:(CGFloat)heightConstraint {
    __block NSInteger index = 0;
    NSMutableArray *containers = [[sizes bk_map:^id(NSValue *obj) {
        CGSize size = obj.CGSizeValue;
        AACollageMakerContainer *container = [AACollageMakerContainer new];
        container.inputOrder = @(index++);
        container.type = AACollageMakerContainerTypeObject;
        container.totalWidth = size.width;
        container.totalHeight = size.height;
        return container;
    }] mutableCopy];
    return [self layoutFitContainers:containers widthConstraint:widthConstraint heightConstraint:heightConstraint];
}

+ (CGSize)resultSizeForViewsWithSizes:(NSArray *)sizes
                      widthConstraint:(CGFloat)widthConstraint
                     heightConstraint:(CGFloat)heightConstraint {
    AACollageMakerContainer *resizedContainers = [self resultContainerForViewsWithSizes:sizes widthConstraint:widthConstraint heightConstraint:heightConstraint];
    return resizedContainers.size;
}

+ (NSArray *)rectsForViewsWithSizes:(NSArray *)sizes
                    widthConstraint:(CGFloat)widthConstraint
                   heightConstraint:(CGFloat)heightConstraint {
    AACollageMakerContainer *resizedContainers = [self resultContainerForViewsWithSizes:sizes widthConstraint:widthConstraint heightConstraint:heightConstraint];
    NSMutableArray *frames = [NSMutableArray new];
    NSMutableArray *stack = [NSMutableArray new];
    [stack addObject:resizedContainers];
    while (stack.count > 0) {
        AACollageMakerContainer *container = [stack lastObject];
        if (container.inputOrder)
            [frames addObject:container];
        [stack removeLastObject];
        if (container.firstChild) {
            container.firstChild.origin = container.origin;
            [stack addObject:container.firstChild];
            if (container.containerType == AACollageMakerContainerTypeSplitH)
                container.secondChild.origin = CGPointMake(container.origin.x, container.origin.y + container.firstChild.size.height);
            else
                container.secondChild.origin = CGPointMake(container.origin.x + container.firstChild.size.width, container.origin.y);
            [stack addObject:container.secondChild];
        }
    }
    NSArray *outputArray = [[frames filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"inputOrder != nil"]] sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"inputOrder" ascending:YES] ]];
    return [outputArray bk_map:^id(AACollageMakerContainer *obj) {
        return [NSValue valueWithCGRect:CGRectMake(obj.origin.x, obj.origin.y, obj.size.width, obj.size.height)];
    }];
}

+ (AACollageMakerContainer *)layoutFitContainers:(NSMutableArray *)containers
                                 widthConstraint:(CGFloat)widthConstraint
                                heightConstraint:(CGFloat)heightConstraint {
    AACollageMakerContainer *container = [self layoutWithContainers:containers andType:NO];
    container = [self layoutScaleContainer:container withSize:CGSizeMake(widthConstraint, heightConstraint)];
    return [self layoutCreateTreeWithRootContainer:container widthConstaint:widthConstraint heightConstraint:heightConstraint];
}

+ (AACollageMakerContainer *)layoutWithContainers:(NSMutableArray *)containers andType:(BOOL)type {
    NSUInteger count = containers.count;
    AACollageMakerContainer *result;
    
    if (count >= 2) {
        int index = floor(count / 2);
        NSMutableArray *containers1 = [[containers subarrayWithRange:NSMakeRange(0, index)] mutableCopy];
        NSMutableArray *containers2 = [[containers subarrayWithRange:NSMakeRange(index, count - index)] mutableCopy];
        
        result = [AACollageMakerContainer new];
        result.type = AACollageMakerContainerTypeBox;
        result.containerType = type ? AACollageMakerContainerTypeSplitH : AACollageMakerContainerTypeSplitV;
        result.pixelCheck = NO;
        result.firstChild = [self layoutWithContainers:containers1 andType:!type];
        result.secondChild = [self layoutWithContainers:containers2 andType:!type];
        result.firstChild.parentContainerType = result.secondChild.parentContainerType = result.containerType;
        result.firstChild.pixelCheck = NO;
        result.secondChild.pixelCheck = YES;
        
        CGSize dimensions = CGSizeMake(NAN, NAN);
        if (type)
            dimensions.width = result.firstChild.totalWidth;
        else
            dimensions.height = result.firstChild.totalHeight;
        
        result.secondChild = [self layoutScaleContainer:result.secondChild withSize:dimensions];
        
        if (type) {
            // Horizontal contact; vertical box type.
            result.totalHeight = result.firstChild.totalHeight + result.secondChild.totalHeight;
            result.totalWidth = result.firstChild.totalWidth;
        }else {
            // Vertical contact; horizontal box type.
            result.totalWidth = result.firstChild.totalWidth + result.secondChild.totalWidth;
            result.totalHeight = result.firstChild.totalHeight;
        }
        
        result.firstChild.parentTotalWidth = result.secondChild.parentTotalWidth = result.totalWidth;
        result.firstChild.parentTotalHeight = result.secondChild.parentTotalHeight = result.totalHeight;
        result.firstChild.siblingsTotalWidth = result.secondChild.totalWidth;
        result.firstChild.siblingsTotalHeight = result.secondChild.totalHeight;
        result.secondChild.siblingsTotalWidth = result.firstChild.totalWidth;
        result.secondChild.siblingsTotalHeight = result.firstChild.totalHeight;
        
    } else if (count == 1) {
        result = [containers firstObject];
        [containers removeAllObjects];
    }
    
    return result;
}

+ (AACollageMakerContainer *)layoutScaleContainer:(AACollageMakerContainer *)container withSize:(CGSize)dimensions {
    CGSize dimensions1, dimensions2;
    NSAssert(dimensions.width > 1 || dimensions.height > 1, @"Neccessary for proper work");
    
    // If it is an image - just resize it (change dimensions).
    if (container.type == AACollageMakerContainerTypeObject) {
        if (dimensions.width > 1) {
            container.totalHeight = (dimensions.width / container.totalWidth) * container.totalHeight;
            container.totalWidth = dimensions.width;
        }
        else if (dimensions.height > 1) {
            container.totalWidth = (dimensions.height / container.totalHeight) * container.totalWidth;
            container.totalHeight = dimensions.height;
        }
        return container;
    }
    
    // If it is a box - then it should consist of two box elements;
    // Determine sizes of elements and resize them.
    if (dimensions.width > 1) {
        // Vertical box type; horizontal contact.
        if (container.containerType == AACollageMakerContainerTypeSplitH) {
            dimensions1 = dimensions2 = dimensions;
        }
        // Horizontal box type; vertical contact.
        else if (container.containerType == AACollageMakerContainerTypeSplitV) {
            dimensions1.width = (container.firstChild.totalWidth / (container.firstChild.totalWidth + container.secondChild.totalWidth)) * dimensions.width;
            dimensions2.width = (container.secondChild.totalWidth / (container.firstChild.totalWidth + container.secondChild.totalWidth)) * dimensions.width;
        }
    }
    else if (dimensions.height > 1) {
        // Vertical box type; horizontal contact.
        if (container.containerType == AACollageMakerContainerTypeSplitH) {
            dimensions1.height = (container.firstChild.totalHeight / (container.firstChild.totalHeight + container.secondChild.totalHeight)) * dimensions.height;
            dimensions2.height = (container.secondChild.totalHeight / (container.firstChild.totalHeight + container.secondChild.totalHeight)) * dimensions.height;
        }
        // Horizontal box type; vertical contact.
        else if (container.containerType == AACollageMakerContainerTypeSplitV) {
            dimensions1 = dimensions2 = dimensions;
        }
    }
    
    container.firstChild = [self layoutScaleContainer:container.firstChild withSize:dimensions1];
    container.secondChild = [self layoutScaleContainer:container.secondChild withSize:dimensions2];
    
    if (container.containerType == AACollageMakerContainerTypeSplitH) {
        container.totalHeight = container.firstChild.totalHeight + container.secondChild.totalHeight;
        container.totalWidth = container.firstChild.totalWidth;
    }
    else if (container.containerType == AACollageMakerContainerTypeSplitV) {
        container.totalWidth = container.firstChild.totalWidth + container.secondChild.totalWidth;
        container.totalHeight = container.firstChild.totalHeight;
    }
    container.firstChild.parentTotalWidth = container.secondChild.parentTotalWidth = container.totalWidth;
    container.firstChild.parentTotalHeight = container.secondChild.parentTotalHeight = container.totalHeight;
    container.firstChild.siblingsTotalWidth = container.secondChild.totalWidth;
    container.firstChild.siblingsTotalHeight = container.secondChild.totalHeight;
    container.secondChild.siblingsTotalWidth = container.firstChild.totalWidth;
    container.secondChild.siblingsTotalHeight = container.firstChild.totalHeight;
    
    return container;
}

+ (AACollageMakerContainer *)layoutCreateTreeWithRootContainer:(AACollageMakerContainer *)container widthConstaint:(CGFloat)width heightConstraint:(CGFloat)height {
    
    if (container.parentContainerType != AACollageMakerContainerTypeSplitU) {
        if (container.parentContainerType == AACollageMakerContainerTypeSplitH) {
            container.totalWidth = container.parentTotalWidth;
        } else if (container.parentContainerType == AACollageMakerContainerTypeSplitV) {
            container.totalHeight = container.parentTotalHeight;
        }
    }
    
    if (container.pixelCheck) {
        if (container.parentContainerType == AACollageMakerContainerTypeSplitH) {
            container.totalHeight += floor(container.parentTotalHeight) - floor(container.totalHeight) - floor(container.siblingsTotalHeight);
        }
        else if (container.parentContainerType == AACollageMakerContainerTypeSplitV) {
            container.totalWidth += floor(container.parentTotalWidth) - floor(container.totalWidth) - floor(container.siblingsTotalWidth);
        }
    }
    
    if (container.type == AACollageMakerContainerTypeBox) {
        container.firstChild.parentTotalHeight = container.secondChild.parentTotalHeight = container.totalHeight;
        container.firstChild.parentTotalWidth = container.secondChild.parentTotalWidth = container.totalWidth;
    }
    
    if (container.type == AACollageMakerContainerTypeObject) {
        container.size = CGSizeMake(floor(container.totalWidth), floor(container.totalHeight));
        return container;
        
    }else if (container.type == AACollageMakerContainerTypeBox) {
        container.size = CGSizeMake(floor(container.totalWidth), floor(container.totalHeight));
        container.firstChild = [self layoutCreateTreeWithRootContainer:container.firstChild widthConstaint:width heightConstraint:height];
        container.secondChild = [self layoutCreateTreeWithRootContainer:container.secondChild widthConstaint:width heightConstraint:height];
        return container;
    }
    else
        return nil;
}

@end

@implementation AACollageMakerContainer @end
