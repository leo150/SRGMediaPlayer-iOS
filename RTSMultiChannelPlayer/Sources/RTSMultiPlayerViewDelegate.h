//
//  Created by Frédéric Humbert-Droz on 15/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RTSMultiPlayerViewController;

/**
 *  <#Description#>
 */
@protocol RTSMultiPlayerViewDelegate <NSObject>
@optional

/**
 *  <#Description#>
 *
 *  @param multiPlayerViewController <#multiPlayerViewController description#>
 *  @param hidden                    <#hidden description#>
 *
 *  @return <#return value description#>
 */
- (BOOL) multiPlayerViewController:(RTSMultiPlayerViewController *)multiPlayerViewController canToggleControlsOverlay:(BOOL)hidden;

/**
 *  <#Description#>
 *
 *  @param multiPlayerViewController <#multiPlayerViewController description#>
 */
- (void) multiPlayerViewControllerThumbnailsViewWillOpen:(RTSMultiPlayerViewController *)multiPlayerViewController;

/**
 *  <#Description#>
 *
 *  @param multiPlayerViewController <#multiPlayerViewController description#>
 */
- (void) multiPlayerViewControllerThumbnailsViewWillClose:(RTSMultiPlayerViewController *)multiPlayerViewController;

@end
