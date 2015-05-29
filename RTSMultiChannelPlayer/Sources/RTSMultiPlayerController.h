//
//  Created by Frédéric Humbert-Droz on 08/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTSMultiPlayerControllerDataSource.h"

/**
 *  <#Description#>
 */
@interface RTSMultiPlayerController : NSObject

/**
 *  -------------------
 *  @name Notifications
 *  -------------------
 */

FOUNDATION_EXTERN NSString * const RTSMultiPlayerMainMediaWillChangeNotification;
FOUNDATION_EXTERN NSString * const RTSMultiPlayerMainMediaDidChangeNotification;

FOUNDATION_EXTERN NSString * const RTSMultiPlayerNumberOfMediaDidChangeNotification;

FOUNDATION_EXTERN NSString * const RTSMultiPlayerWillReloadDataNotification;
FOUNDATION_EXTERN NSString * const RTSMultiPlayerDidReloadDataNotification;

FOUNDATION_EXTERN NSString * const RTSMultiPlayerPlaybackStateDidChangeNotification;

FOUNDATION_EXTERN NSString * const RTSMultiPlayerWillShowControlOverlaysNotification;
FOUNDATION_EXTERN NSString * const RTSMultiPlayerDidShowControlOverlaysNotification;
FOUNDATION_EXTERN NSString * const RTSMultiPlayerWillHideControlOverlaysNotification;
FOUNDATION_EXTERN NSString * const RTSMultiPlayerDidHideControlOverlaysNotification;


/**
 *  --------------------------------------------
 *  @name Initializing a Multi Player Controller
 *  --------------------------------------------
 */

/**
 *  <#Description#>
 *
 *  @param playerView <#playerView description#>
 *
 *  @return <#return value description#>
 */
- (instancetype) initWithMainPlayerView:(UIView *)mainPlayerView;

/**
 *  ------------------------
 *  @name Accessing the View
 *  ------------------------
 */

/**
 *  <#Description#>
 */
@property (nonatomic, weak) IBOutlet UIView *mainPlayerView;

/**
 *  ------------------------
 *  @name Accessing the View
 *  ------------------------
 */

/**
 *  <#Description#>
 *
 *  @param identifier <#identifier description#>
 */
- (void) setMainIdentifier:(NSString *)identifier;

/**
 *  <#Description#>
 */
- (void) setNextMainIdentifier;

/**
 *  <#Description#>
 */
- (void) setPreviousMainIdentifier;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSUInteger) numberOfThumbnailMediaPlayerControllers;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (RTSMediaPlayerController *) mainMediaPlayerController;

/**
 *  <#Description#>
 *
 *  @param index <#index description#>
 *
 *  @return <#return value description#>
 */
- (RTSMediaPlayerController *) thumbnailMediaPlayerControllerAtIndex:(NSUInteger)index;

/**
 *  <#Description#>
 *
 *  @param mediaPlayerController <#mediaPlayerController description#>
 *
 *  @return <#return value description#>
 */
- (BOOL) isMainMediaPlayerController:(RTSMediaPlayerController *) mediaPlayerController;

/**
 *  <#Description#>
 */
- (void) playThumbnails;

/**
 *  <#Description#>
 */
- (void) resetThumbnails;

/**
 *  ---------------------------------------------
 *  @name Accessing Multi Player Media Properties
 *  ---------------------------------------------
 */

/**
 *  <#Description#>
 */
@property (nonatomic, weak) IBOutlet id<RTSMultiPlayerControllerDataSource> dataSource;

@end
