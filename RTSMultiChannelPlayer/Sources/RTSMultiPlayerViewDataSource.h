//
//  Created by Frédéric Humbert-Droz on 14/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTSMediaPlayerController, RTSMultiPlayerViewController, RTSMultiPlayerThumbnailCell;

/**
 *  <#Description#>
 */
@protocol RTSMultiPlayerViewDataSource <NSObject>

@optional

/**
 *  <#Description#>
 *
 *  @param multiPlayerViewController <#multiPlayerViewController description#>
 *  @param identifier                <#identifier description#>
 *
 *  @return <#return value description#>
 */
- (NSString *) multiPlayerViewController:(RTSMultiPlayerViewController *)multiPlayerViewController titleForMainMediaWithIdentifier:(NSString *)identifier;

/**
 *  <#Description#>
 *
 *  @param multiPlayerViewController <#multiPlayerViewController description#>
 *  @param identifier                <#identifier description#>
 *
 *  @return <#return value description#>
 */
- (NSString *) multiPlayerViewController:(RTSMultiPlayerViewController *)multiPlayerViewController subTitleForMainMediaWithIdentifier:(NSString *)identifier;



/**
 *  <#Description#>
 *
 *  @param multiPlayerViewController <#multiPlayerViewController description#>
 *
 *  @return <#return value description#>
 */
- (NSString *) multiPlayerViewControllerTitleForThumbnailsViewHeader:(RTSMultiPlayerViewController *)multiPlayerViewController;


/**
 *  <#Description#>
 *
 *  @param multiPlayerViewController <#multiPlayerViewController description#>
 *  @param cell                      <#cell description#>
 *  @param mediaPlayerController     <#mediaPlayerController description#>
 *  @param indexPath                 <#indexPath description#>
 */
- (void) multiPlayerViewController:(RTSMultiPlayerViewController *)multiPlayerViewController configureThumbnailCell:(RTSMultiPlayerThumbnailCell *)cell mediaPlayerController:(RTSMediaPlayerController *)mediaPlayerController atIndexPath:(NSIndexPath *)indexPath;

/**
 *  <#Description#>
 *
 *  @param availableSize        <#availableSize description#>
 *  @param interfaceOrientation <#interfaceOrientation description#>
 *
 *  @return <#return value description#>
 */
- (CGSize) thumbnailSizeForAvailableSize:(CGSize)availableSize interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
