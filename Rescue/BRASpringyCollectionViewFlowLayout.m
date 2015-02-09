//
//  BRASpringyCollectionViewFlowLayout.m
//
//  Created by Brian Drell on 2014-06-16.
//  Copyright (c) 2014 Bottle Rocket, LLC. All rights reserved.
//

//  Based on ASHSpringyCollectionViewFlowLayout by Ash Furrow,
//  Copyright (c) 2013 Ash Furrow.

#import "BRASpringyCollectionViewFlowLayout.h"

@interface BRASpringyCollectionViewFlowLayout () <UIDynamicAnimatorDelegate>

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) NSMutableSet *visibleIndexPathsSet;
@property (nonatomic, assign) CGFloat latestDelta;
@property (nonatomic, copy) BRASpringyCollectionViewFlowLayoutBlock animateStartBlock;
@property (nonatomic) BOOL isCurrentlyUsingGravity;

@property (nonatomic) NSInteger numberOfItems;

@property (nonatomic, strong) UICollectionViewLayoutAttributes *attributesForFirstCellBeforeAnimation;
@property (nonatomic) UIEdgeInsets originalEdgeInsets;

@property (nonatomic) CGFloat originalInterItemSpacing;
@property (nonatomic) CGFloat originalLineSpacing;
@property (nonatomic) NSInteger previousNumberOfItems;

@end

@implementation BRASpringyCollectionViewFlowLayout

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
    
    _originalEdgeInsets = self.sectionInset;
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    _dynamicAnimator.delegate = self;
    _visibleIndexPathsSet = [[NSMutableSet alloc] init];
    _springLength = 0.0;
    _springFrequency = 1.0;
    _springDamping = 1.1;
    _largeCellDimension = 140.0;
    _mediumCellDimension = 150.0;
    _smallCellDimension = 76.0;
    _minimumNumberOfCellsForStaggeringLayout = 4;
    _minimumNumberOfCellsToShrink = 8;
    _minimumNumberOfCellsForGridLayout = 9;
    _directionForFinalAttributes = BRASpringyCollectionViewFlowLayoutDirectionUp;
    _directionForInitialAttributes = BRASpringyCollectionViewFlowLayoutDirectionDown;
    _originalInterItemSpacing = self.minimumInteritemSpacing;
    _originalLineSpacing = self.minimumLineSpacing;
    _overrideMinimumItemSpacing = self.minimumInteritemSpacing;
    _overrideMinimumLineSpacing = self.minimumLineSpacing;
    _numberOfItems = -1;
}

- (void)invalidateLayout
{
    [super invalidateLayout];
}

- (void)invalidateAndClearSavedBehaviors
{
    self.visibleIndexPathsSet = [[NSMutableSet alloc] init];
    NSMutableArray *oldAttributes = [[NSMutableArray alloc] init];
    for (UIAttachmentBehavior *attachment in self.dynamicAnimator.behaviors)
    {
        if ([attachment isKindOfClass:[UIAttachmentBehavior class]])
        {
            [oldAttributes addObject:[attachment.items firstObject]];
        }
    }
    [self.dynamicAnimator removeAllBehaviors];
    [self invalidateLayout];
    self.attributesForFirstCellBeforeAnimation = nil;
}

- (void)overrideSectionInset:(UIEdgeInsets)insets
{
    self.sectionInset = insets;
    self.originalEdgeInsets = insets;
}

- (void)cleanupLayout
{
    [self.dynamicAnimator removeAllBehaviors];
    self.visibleIndexPathsSet = [[NSMutableSet alloc] init];
}

- (void)prepareLayout
{
    if (self.isCurrentlyUsingGravity) return;
    
    NSInteger numberOfItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    if (numberOfItems != self.previousNumberOfItems)
    {
        [self.dynamicAnimator removeAllBehaviors];
        [self setInsetsAndItemSizeForNumberOfItems:numberOfItems];
        self.previousNumberOfItems = numberOfItems;
        self.visibleIndexPathsSet = [[NSMutableSet alloc] init];
    }
    
    [super prepareLayout];
    
    for (UIDynamicBehavior *behavior in self.dynamicAnimator.behaviors)
    {
        if ([behavior isKindOfClass:[UIGravityBehavior class]])
        {
            [self.dynamicAnimator removeBehavior:behavior];
        }
    }
    
    // Need to overflow our actual visible rect slightly to avoid flickering.
    
    CGFloat verticalRectOverflow = 300;
    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        verticalRectOverflow = 500;
    }
    CGRect visibleRect = CGRectInset(CGRectMake(self.collectionView.bounds.origin.x,
                                                self.collectionView.bounds.origin.y,
                                                self.collectionView.frame.size.width,
                                                self.collectionView.frame.size.height), -100 - self.sectionInset.left - self.sectionInset.right, -verticalRectOverflow - self.sectionInset.top - self.sectionInset.bottom);
    
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
        
        if (numberOfItems >= self.minimumNumberOfCellsForGridLayout)
        {
            CGFloat width = (self.itemSize.width + self.minimumInteritemSpacing) / 4.;
            width = roundf(width);
            if ((item.indexPath.item/3) %2)
            {
                center.x += width;
            }
            else
            {
                center.x -= width;
            }
        }
        else
        {
            if (numberOfItems >= self.minimumNumberOfCellsForStaggeringLayout)
            {
                NSInteger column = item.indexPath.item % 2;
                if (column)
                {
                    center.y += self.itemSize.height / 2 + self.minimumLineSpacing / 2;
                }
            }
        }
        item.center = center;
        
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
        
        if ([item.indexPath isEqual:[NSIndexPath indexPathForItem:0 inSection:0]] && !self.attributesForFirstCellBeforeAnimation)
        {
            self.attributesForFirstCellBeforeAnimation = [item copy];
        }
        
        [self.dynamicAnimator addBehavior:springBehaviour];
        [self.visibleIndexPathsSet addObject:item.indexPath];
    }];
}

- (CGRect)frameForFirstCell
{
    return self.attributesForFirstCellBeforeAnimation.frame;
}

- (void)setInsetsAndItemSizeForNumberOfItems:(NSInteger)numberOfItems
{
    [self setItemSizeForNumberOfItems:numberOfItems];
    [self setInsetsForNumberOfItems:numberOfItems];
}

- (void)setItemSizeForNumberOfItems:(NSInteger)numberOfItems
{
    if (numberOfItems < self.minimumNumberOfCellsForStaggeringLayout)
    {
        self.itemSize = CGSizeMake(self.largeCellDimension, self.largeCellDimension);
    }
    else if (numberOfItems < self.minimumNumberOfCellsToShrink)
    {
        self.itemSize = CGSizeMake(140, 140);
    }
    else
    {
        self.itemSize = CGSizeMake(self.smallCellDimension, self.smallCellDimension);
    }
}

- (void)setInsetsForNumberOfItems:(NSInteger)numberOfItems
{
    CGFloat topInset = 0.;
    CGFloat collectionViewHeight = CGRectGetHeight(self.collectionView.frame);
    

    
    CGFloat itemWidth = self.itemSize.width;
    CGFloat totalWidth = CGRectGetWidth(self.collectionView.frame) - self.minimumInteritemSpacing;
    
    self.sectionInset = self.originalEdgeInsets;
    
    if (numberOfItems < self.minimumNumberOfCellsForStaggeringLayout)
    {
        self.minimumLineSpacing = self.overrideMinimumLineSpacing;
        self.minimumInteritemSpacing = self.overrideMinimumItemSpacing;
        
        CGFloat totalLineSpacing = (numberOfItems - 1) * self.minimumLineSpacing;
        CGFloat totalItemHeight = numberOfItems * self.itemSize.height;
        topInset = (collectionViewHeight - totalLineSpacing - totalItemHeight) / 2.;
        CGFloat sideInset = (totalWidth - itemWidth) / 2;
        self.sectionInset = UIEdgeInsetsMake(topInset + self.extraTopInsetForSingleScreenLayout, sideInset, topInset - self.extraTopInsetForSingleScreenLayout, sideInset);
    }
    else if (numberOfItems < self.minimumNumberOfCellsForGridLayout)
    {
        self.minimumLineSpacing = self.overrideMinimumLineSpacing;
        self.minimumInteritemSpacing = self.overrideMinimumItemSpacing;
        
        CGFloat floatItems = (CGFloat)numberOfItems;
        CGFloat lines = floatItems / 2.;
        NSInteger numberOfLines = (NSInteger)ceilf(lines);
        CGFloat totalLineSpacing = (numberOfLines - 1) * self.minimumLineSpacing;
        CGFloat totalItemHeight = numberOfLines * self.itemSize.height;
        CGFloat topBottomOffset = 0.;
        if (!(numberOfItems % 2))
        {
            totalItemHeight -= self.itemSize.height / 2;
            topBottomOffset = self.itemSize.height / 4;
        }
        NSInteger nItemsRemainder = numberOfItems % 2;
        nItemsRemainder = !nItemsRemainder;
        topInset = (collectionViewHeight - totalLineSpacing - totalItemHeight) / 2. - nItemsRemainder * self.itemSize.height / 3.;
        CGFloat sideInset = (totalWidth - 2*itemWidth - self.minimumInteritemSpacing) / 2;
        self.sectionInset = UIEdgeInsetsMake(topInset + self.extraTopInsetForSingleScreenLayout - topBottomOffset, sideInset, topInset - self.extraTopInsetForSingleScreenLayout + topBottomOffset, sideInset);
    }
    else
    {
        
        self.minimumLineSpacing = self.originalLineSpacing;
        self.minimumInteritemSpacing = self.originalInterItemSpacing;
        
        CGFloat sideInset = (totalWidth - 3.*itemWidth - 2 * self.minimumInteritemSpacing) / 2 ;
        self.sectionInset = UIEdgeInsetsMake(self.sectionInset.top, sideInset, self.sectionInset.bottom, sideInset);
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attr = [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
    if (!attr)
    {
        //DebugLog(@"Missing attributes!");
    }
    return attr;
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

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attr = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    attr.alpha = 1;
    switch (self.animationType) {
        case BRASpringyCollectionViewFlowLayoutAnimationTypeFly:
        {
            attr = [self transformInitialAttributesForFlyAnimation:attr indexPath:itemIndexPath];
            break;
        }
        case BRASpringyCollectionViewFlowLayoutAnimationTypeScale:
        {
            attr = [self transformAttributesForScaleAnimation:attr indexPath:itemIndexPath];
            break;
        }
    }
    return attr;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attr = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    attr.alpha = 1;
    switch (self.animationType) {
        case BRASpringyCollectionViewFlowLayoutAnimationTypeFly:
        {
            attr = [self transformFinalAttributesForFlyAnimation:attr indexPath:itemIndexPath];
            break;
        }
        case BRASpringyCollectionViewFlowLayoutAnimationTypeScale:
        {
            attr = [self transformAttributesForScaleAnimation:attr indexPath:itemIndexPath];
            break;
        }
    }
    return attr;
}

- (UICollectionViewLayoutAttributes *)transformInitialAttributesForFlyAnimation:(UICollectionViewLayoutAttributes *)attr indexPath:(NSIndexPath *)itemIndexPath
{
    NSInteger numberOfItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    NSInteger thisItemIndex = numberOfItems - itemIndexPath.item;
    switch (self.directionForInitialAttributes) {
        case BRASpringyCollectionViewFlowLayoutDirectionUp:
        {
            CGPoint center = attr.center;
            center.y -= 1.4*self.collectionView.contentSize.height + self.sectionInset.top + self.sectionInset.bottom + thisItemIndex * self.itemSize.height;
            attr.center = center;
            break;
        }
        case BRASpringyCollectionViewFlowLayoutDirectionDown:
        {
            CGPoint center = attr.center;
            center.y += CGRectGetHeight(self.collectionView.frame) + itemIndexPath.item * 2.*self.itemSize.height;
            attr.center = center;
            break;
        }
        case BRASpringyCollectionViewFlowLayoutDirectionLeft:
        {
            CGPoint center = attr.center;
            center.x -= CGRectGetWidth(self.collectionView.frame);
            attr.center = center;
            break;
        }
        case BRASpringyCollectionViewFlowLayoutDirectionRight:
        {
            CGPoint center = attr.center;
            center.x += CGRectGetWidth(self.collectionView.frame);
            attr.center = center;
            break;
        }
    }
    return attr;
}

- (UICollectionViewLayoutAttributes *)transformFinalAttributesForFlyAnimation:(UICollectionViewLayoutAttributes *)attr indexPath:(NSIndexPath *)itemIndexPath
{
    switch (self.directionForFinalAttributes) {
        case BRASpringyCollectionViewFlowLayoutDirectionUp:
        {
            CGPoint center = attr.center;
            center.y -= 2.*CGRectGetHeight(self.collectionView.frame);
            attr.center = center;
            break;
        }
        case BRASpringyCollectionViewFlowLayoutDirectionDown:
        {
            CGPoint center = attr.center;
            center.y += 2.*CGRectGetHeight(self.collectionView.frame);
            attr.center = center;
            break;
        }
        case BRASpringyCollectionViewFlowLayoutDirectionLeft:
        {
            CGPoint center = attr.center;
            center.x -= CGRectGetWidth(self.collectionView.frame);
            attr.center = center;
            break;
        }
        case BRASpringyCollectionViewFlowLayoutDirectionRight:
        {
            CGPoint center = attr.center;
            center.x += CGRectGetWidth(self.collectionView.frame);
            attr.center = center;
            break;
        }
    }
    return attr;
}

- (UICollectionViewLayoutAttributes *)transformAttributesForScaleAnimation:(UICollectionViewLayoutAttributes *)attr indexPath:(NSIndexPath *)itemIndexPath
{
    attr.transform = CGAffineTransformMakeScale(0.0, 0.0);
    return attr;
}

#pragma mark - Animations

- (void)moveVisibleAttributesOffscreenAndSpringIntoPositionWithExtraDragDistance:(CGFloat)extraDistance fromDirection:(BRASpringyCollectionViewFlowLayoutDirection)direction startBlock:(BRASpringyCollectionViewFlowLayoutBlock)startBlock
{
    self.animateStartBlock = startBlock;
    __weak __typeof__(self) weakSelf = self;
    __block CGFloat blockExtraDistance = 50.;
    if (!extraDistance) extraDistance = 750.;
    
    BOOL compareFlag = NO;
    if (direction == BRASpringyCollectionViewFlowLayoutDirectionDown
        || direction == BRASpringyCollectionViewFlowLayoutDirectionRight)
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
        if (direction == BRASpringyCollectionViewFlowLayoutDirectionDown
            || direction == BRASpringyCollectionViewFlowLayoutDirectionUp)
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

- (void)makeAllCellsFlyOffScreenInDirection:(BRASpringyCollectionViewFlowLayoutDirection)direction completionBlock:(BRASpringyCollectionViewFlowLayoutBlock)completionBlock
{
    for (UIDynamicBehavior *behavior in self.dynamicAnimator.behaviors)
    {
        if ([behavior isKindOfClass:[UIGravityBehavior class]])
        {
            return;
        }
    }
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
    gravity.magnitude = 5.;
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

#pragma mark - UIDynamicAnimatorDelegate

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    
}

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator *)animator
{
    if (self.animateStartBlock)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.animateStartBlock();
            self.animateStartBlock = nil;
        });
    }
}

@end
