//
//  Copyright (c) SRG. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGMediaPlayerController.h"
#import "SRGSegment.h"

#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// Forward declarations
@protocol SRGTimelineViewDelegate;

/**
 *  A view displaying segments associated with a stream as a linear collection of cells
 *
 *  To add a timeline to a custom player layout, simply drag and drop an `RTSTimelineView` onto the player layout,
 *  and bind its segment controller and delegate outlets. You can of course instantiate and configure the view
 *  programatically as well. Then call `-reloadSegmentsWithIdentifier:completionHandler:` when you need to retrieve
 *  segments from the controller
 *
 *  Customisation of timeline cells is achieved through subclassing of `UICollectionViewCell`, exactly like a usual
 *  `UICollectionView`
 */
@interface SRGTimelineView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>

/**
 *  The controller to which the timeline is attached
 */
@property (nonatomic, weak, nullable) IBOutlet SRGMediaPlayerController *mediaPlayerController;

/**
 *  The timeline delegate
 */
@property (nonatomic, weak, nullable) IBOutlet id<SRGTimelineViewDelegate> delegate;

/**
 *  The width of cells within the timeline. Defaults to 60
 */
@property (nonatomic) IBInspectable CGFloat itemWidth;

/**
 * The spacing between cells in the timeline. Defaults to 4
 */
@property (nonatomic) IBInspectable CGFloat itemSpacing;

/**
 *  Register cell classes for reuse. Cells must be subclasses of `UICollectionViewCell` and can be instantiated either
 *  programmatically or using a nib. For more information about cell reuse, refer to `UICollectionView` documentation.
 *  To dequeue cells from the reuse queue, call -dequeueReusableCellWithReuseIdentifier:forSegment:
 */
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

- (void)reloadData;

/**
 *  Dequeue a reusable cell for a given segment
 *
 *  @param identifier The cell identifier (must be appropriately set for the cell)
 *  @param segment    The segment for which a cell must be dequeued
 */
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forSegment:(id<SRGSegment>)segment;

/**
 * Return the list of currently visible cells
 */
- (NSArray<__kindof UICollectionViewCell *> *)visibleCells;

/**
 *  Scroll to make the specified segment visible (does nothing if the segment does not belong to the visible segments
 *  of the segmentsController.
 */
- (void)scrollToSegment:(id<SRGSegment>)segment animated:(BOOL)animated;

@end

/**
 *  Timeline delegate protocol
 */
@protocol SRGTimelineViewDelegate <NSObject>

/**
 *  Return the cell to be displayed for a segment. You should call `-dequeueReusableCellWithReuseIdentifier:forSegment:`
 *  within the implementation of this method to reuse existing cells and improve scrolling smoothness
 *
 *  @param timelineView The timeline
 *  @param segment      The segment for which the cell must be returned
 *
 *  @return The cell to use
 */
- (UICollectionViewCell *)timelineView:(SRGTimelineView *)timelineView cellForSegment:(id<SRGSegment>)segment;

@optional

/**
 * Called when the timeline sees one of its visible segment selected by the user.
 */
- (void)timelineView:(SRGTimelineView *)timelineView didSelectSegmentAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Called when the timeline has been scrolled interactively
 */
- (void)timelineViewDidScroll:(SRGTimelineView *)timelineView;

@end

NS_ASSUME_NONNULL_END
