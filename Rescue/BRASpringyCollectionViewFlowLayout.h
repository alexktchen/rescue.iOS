//
//  BRASpringyCollectionViewFlowLayout.h
//
//  Created by Brian Drell on 2014-06-16.
//  Copyright (c) 2014 Bottle Rocket, LLC. All rights reserved.
//

//  Based on ASHSpringyCollectionViewFlowLayout by Ash Furrow,
//  Copyright (c) 2013 Ash Furrow.

// Bottle Rocket note: This layout is MIT licensed and was pulled from:
// https://github.com/objcio/issue-5-springy-collection-view
// Original notes:
/*
 This implementation is based on https://github.com/TeehanLax/UICollectionView-Spring-Demo
 which I developed at Teehan+Lax. Check it out.
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BRASpringyCollectionViewFlowLayoutDirection) {
    BRASpringyCollectionViewFlowLayoutDirectionRight = 0,
    BRASpringyCollectionViewFlowLayoutDirectionDown = 90,
    BRASpringyCollectionViewFlowLayoutDirectionLeft = 180,
    BRASpringyCollectionViewFlowLayoutDirectionUp = 270
};

// Fly makes the cells fly off screen (or on screen) from the directions specified in
//   the properties 'directionForInitialAttributes' and 'directionForFinalAttributes'.
typedef NS_ENUM(NSInteger, BRASpringyCollectionViewFlowLayoutAnimationType) {
    BRASpringyCollectionViewFlowLayoutAnimationTypeFly,
    BRASpringyCollectionViewFlowLayoutAnimationTypeScale
};

typedef void(^BRASpringyCollectionViewFlowLayoutBlock)();

@interface BRASpringyCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic) CGFloat springLength;
@property (nonatomic) CGFloat springDamping;
@property (nonatomic) CGFloat springFrequency;

@property (nonatomic) CGFloat largeCellDimension;
@property (nonatomic) CGFloat mediumCellDimension;
@property (nonatomic) CGFloat smallCellDimension;

@property (nonatomic) CGFloat overrideMinimumLineSpacing;
@property (nonatomic) CGFloat overrideMinimumItemSpacing;
@property (nonatomic) CGFloat extraTopInsetForSingleScreenLayout;

@property (nonatomic) NSInteger minimumNumberOfCellsForStaggeringLayout;
@property (nonatomic) NSInteger minimumNumberOfCellsToShrink;
@property (nonatomic) NSInteger minimumNumberOfCellsForGridLayout;

@property (nonatomic) BRASpringyCollectionViewFlowLayoutAnimationType animationType;
@property (nonatomic) BRASpringyCollectionViewFlowLayoutDirection directionForInitialAttributes;
@property (nonatomic) BRASpringyCollectionViewFlowLayoutDirection directionForFinalAttributes;

@property (nonatomic) BOOL isCurrentlyAnimatingBoundsChange;

- (void)overrideSectionInset:(UIEdgeInsets)insets;

- (CGRect)frameForFirstCell;

- (void)moveVisibleAttributesOffscreenAndSpringIntoPositionWithExtraDragDistance:(CGFloat)extraDistance fromDirection:(BRASpringyCollectionViewFlowLayoutDirection)direction startBlock:(BRASpringyCollectionViewFlowLayoutBlock)startBlock;
- (void)makeAllCellsFlyOffScreenInDirection:(BRASpringyCollectionViewFlowLayoutDirection)direction completionBlock:(BRASpringyCollectionViewFlowLayoutBlock)completionBlock;

- (void)invalidateAndClearSavedBehaviors;

- (void)cleanupLayout;

@end
