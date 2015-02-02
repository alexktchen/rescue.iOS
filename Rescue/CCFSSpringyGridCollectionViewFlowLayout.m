//
//  CCFSSpringyGridCollectionViewFlowLayout.m
//  CCFS
//
//  Created by Brian Drell on 7/14/14.
//  Copyright (c) 2014 Bottle Rocket, LLC. All rights reserved.
//

#import "CCFSSpringyGridCollectionViewFlowLayout.h"

@interface CCFSSpringyGridCollectionViewFlowLayout () <UIDynamicAnimatorDelegate>

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) NSMutableSet *visibleIndexPathsSet;
@property (nonatomic, assign) CGFloat latestDelta;
@property (nonatomic, assign) BOOL isCurrentlyUsingGravity;

@end

@implementation CCFSSpringyGridCollectionViewFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _springLength = 0.0;
    _springFrequency = 1.0;
    _springDamping = 1.1;
    _visibleIndexPathsSet = [[NSMutableSet alloc] init];
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    _dynamicAnimator.delegate = self;
}

- (void)invalidateAndRemoveSavedBehaviors
{
    [self.dynamicAnimator removeAllBehaviors];
    [self invalidateLayout];
}

- (void)prepareLayout
{
    if (self.isCurrentlyUsingGravity) return;
    
    for (UIDynamicBehavior *behavior in self.dynamicAnimator.behaviors)
    {
        if ([behavior isKindOfClass:[UIGravityBehavior class]])
        {
            [self.dynamicAnimator removeBehavior:behavior];
        }
    }
    
    [super prepareLayout];
    
    CGRect visibleRect = CGRectInset(CGRectMake(self.collectionView.bounds.origin.x,
                                                self.collectionView.bounds.origin.y,
                                                self.collectionView.frame.size.width,
                                                self.collectionView.frame.size.height), -100 - self.sectionInset.left - self.sectionInset.right, -300 - self.sectionInset.top - self.sectionInset.bottom);
    NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:visibleRect];
    NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];
    
    // Step 1: Remove any behaviours that are no longer visible.
    NSArray *noLongerVisibleBehaviours = [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behaviour, NSDictionary *bindings) {
        BOOL currentlyVisible = [itemsIndexPathsInVisibleRectSet member:[[[behaviour items] firstObject] indexPath]] != nil;
        return !currentlyVisible;
    }]];
    
    [noLongerVisibleBehaviours enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [self.dynamicAnimator removeBehavior:obj];
        [self.visibleIndexPathsSet removeObject:[[[obj items] firstObject] indexPath]];
    }];
    
    // Step 2: Add any newly visible behaviours.
    // A "newly visible" item is one that is in the itemsInVisibleRect(Set|Array) but not in the visibleIndexPathsSet
    NSArray *newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        BOOL currentlyVisible = [self.visibleIndexPathsSet member:item.indexPath] != nil;
        return !currentlyVisible;
    }]];
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
        CGPoint center = item.center;
        UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];
        
        springBehaviour.length = self.springLength;
        springBehaviour.damping = self.springDamping;
        springBehaviour.frequency = self.springFrequency;
        
        // If our touchLocation is not (0,0), we'll need to adjust our item's center "in flight"
        if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
            CGFloat yDistanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
            CGFloat xDistanceFromTouch = fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
            CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0f;
            
            if (self.latestDelta < 0)
            {
                center.y += MAX(self.latestDelta, self.latestDelta*scrollResistance);
            }
            else
            {
                center.y += MIN(self.latestDelta, self.latestDelta*scrollResistance);
            }
            item.center = center;
        }
        [self.dynamicAnimator addBehavior:springBehaviour];
        [self.visibleIndexPathsSet addObject:item.indexPath];
    }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    if (self.isCurrentlyAnimatingBoundsChange)
    {
        return NO;
    }
    UIScrollView *scrollView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
    
    self.latestDelta = delta;
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    __weak __typeof__(self) weakSelf = self;
    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        if (![springBehaviour isKindOfClass:[UIAttachmentBehavior class]])
        {
            return;
        }
        CGFloat yDistanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat xDistanceFromTouch = fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
        CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0f;
        
        UICollectionViewLayoutAttributes *item = [springBehaviour.items firstObject];
        CGPoint center = item.center;
        if (delta < 0)
        {
            center.y += MAX(delta, delta*scrollResistance);
        }
        else
        {
            center.y += MIN(delta, delta*scrollResistance);
        }
        item.center = center;
        
        [weakSelf.dynamicAnimator updateItemUsingCurrentState:item];
    }];
    
    return NO;
}

#pragma mark - Animations

- (void)moveVisibleAttributesOffscreenAndSpringIntoPositionWithExtraDragDistance:(CGFloat)extraDistance fromDirection:(CCFSLayoutDirection)direction startBlock:(CCFSLayoutBlock)startBlock
{
//    self.animateStartBlock = startBlock;
    __weak __typeof__(self) weakSelf = self;
    __block CGFloat blockExtraDistance = 50.;
    if (!extraDistance) extraDistance = 750.;
    
    BOOL compareFlag = NO;
    if (direction == CCFSLayoutDirectionDown
        || direction == CCFSLayoutDirectionRight)
    {
        compareFlag = YES;
    }
    NSArray *behaviors = [self.dynamicAnimator.behaviors sortedArrayUsingComparator:^NSComparisonResult(UIAttachmentBehavior *obj1, UIAttachmentBehavior *obj2) {
        UICollectionViewLayoutAttributes *attr1 = [obj1.items firstObject];
        UICollectionViewLayoutAttributes *attr2 = [obj2.items firstObject];
        if (compareFlag)
        {
            return [attr1.indexPath compare:attr2.indexPath];
        }
        else
        {
            return [attr2.indexPath compare:attr1.indexPath];
        }
    }];
    
    CGFloat sign = 1.;
    if (!compareFlag)
    {
        sign = -1.;
    }
    
    [behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *behavior, NSUInteger idx, BOOL *stop) {
        UICollectionViewLayoutAttributes *item = [behavior.items firstObject];
        
        CGFloat distance = CGRectGetHeight(weakSelf.collectionView.frame);
        distance += blockExtraDistance;
        blockExtraDistance += extraDistance;
        
        CGPoint itemCenter = item.center;
        if (direction == CCFSLayoutDirectionDown
            || direction == CCFSLayoutDirectionUp)
        {
            itemCenter.y += sign * distance;
        }
        else
        {
            itemCenter.x += sign * distance;
        }
        item.center = itemCenter;
        
        [weakSelf.dynamicAnimator updateItemUsingCurrentState:item];
    }];
}

- (void)makeAllCellsFlyOffScreenInDirection:(CCFSLayoutDirection)direction completionBlock:(CCFSLayoutBlock)completionBlock
{
    CGFloat angle = direction * M_PI/180.;
    BOOL compareFlag = YES;
    if (angle > M_PI_2 + 0.01 && angle <= 3.*M_PI_2 + 0.01)
    {
        compareFlag = NO;
    }
    NSArray *behaviors = [self.dynamicAnimator.behaviors sortedArrayUsingComparator:^NSComparisonResult(UIAttachmentBehavior *obj1, UIAttachmentBehavior *obj2) {
        UICollectionViewLayoutAttributes *attr1 = [obj1.items firstObject];
        UICollectionViewLayoutAttributes *attr2 = [obj2.items firstObject];
        if (compareFlag)
        {
            return [attr2.indexPath compare:attr1.indexPath];
        }
        else
        {
            return [attr1.indexPath compare:attr2.indexPath];
        }
    }];
    double delay = 0.;
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] init];
    gravity.magnitude = 3.;
    gravity.angle = angle;
    [self.dynamicAnimator addBehavior:gravity];
    for (UIAttachmentBehavior *attachmentBehavior in behaviors)
    {
        UICollectionViewLayoutAttributes *attr = [attachmentBehavior.items firstObject];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.dynamicAnimator removeBehavior:attachmentBehavior];
            [gravity addItem:attr];
        });
        delay += 0.02;
    }
    
    self.visibleIndexPathsSet = [[NSMutableSet alloc] init];
    self.isCurrentlyUsingGravity = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay + 1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completionBlock) completionBlock();
        self.isCurrentlyUsingGravity = NO;
        [self invalidateLayout];
    });
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attr = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    attr.alpha = 1;
    attr.transform = CGAffineTransformMakeScale(0, 0);
    return attr;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attr = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    attr.alpha = 1;
    attr.transform = CGAffineTransformMakeScale(0, 0);
    return attr;
}

@end
