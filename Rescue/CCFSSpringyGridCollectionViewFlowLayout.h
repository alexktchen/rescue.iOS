//
//  CCFSSpringyGridCollectionViewFlowLayout.h
//  CCFS
//
//  Created by Brian Drell on 7/14/14.
//  Copyright (c) 2014 Bottle Rocket, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CCFSLayoutDirection) {
    CCFSLayoutDirectionRight = 0,
    CCFSLayoutDirectionDown = 90,
    CCFSLayoutDirectionLeft = 180,
    CCFSLayoutDirectionUp = 270
};

typedef void(^CCFSLayoutBlock)();

@interface CCFSSpringyGridCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic) CGFloat springLength;
@property (nonatomic) CGFloat springDamping;
@property (nonatomic) CGFloat springFrequency;
@property (nonatomic) CGFloat additionalTopInset;

@property (nonatomic, assign) BOOL isCurrentlyAnimatingBoundsChange;

- (void)invalidateAndRemoveSavedBehaviors;
- (void)makeAllCellsFlyOffScreenInDirection:(CCFSLayoutDirection)direction completionBlock:(CCFSLayoutBlock)completionBlock;
- (void)moveVisibleAttributesOffscreenAndSpringIntoPositionWithExtraDragDistance:(CGFloat)extraDistance fromDirection:(CCFSLayoutDirection)direction startBlock:(CCFSLayoutBlock)startBlock;

@end
