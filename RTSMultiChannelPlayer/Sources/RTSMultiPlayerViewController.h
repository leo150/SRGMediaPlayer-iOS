//
//  Created by Frédéric Humbert-Droz on 08/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTSMultiPlayerController.h"
#import "RTSMultiPlayerViewDataSource.h"
#import "RTSMultiPlayerViewDelegate.h"

/**
 *  <#Description#>
 */
@interface RTSMultiPlayerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, RTSMultiPlayerViewDataSource, RTSMultiPlayerViewDelegate>

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
 *  <#Description#>
 */
@property (nonatomic, weak) IBOutlet UIView  *mainMediaTitleView;

/**
 *  <#Description#>
 */
@property (nonatomic, weak) IBOutlet UILabel *mainMediaTitleLabel;

/**
 *  <#Description#>
 */
@property (nonatomic, weak) IBOutlet UILabel *mainMediaSubtitleLabel;

/**
 *  <#Description#>
 */
@property (nonatomic, weak) IBOutlet UIView *thumbnailsView;

/**
 *  <#Description#>
 */
@property (nonatomic, weak) IBOutlet UICollectionView *thumbnailsCollectionView;

/**
 *  <#Description#>
 */
@property (nonatomic, weak) IBOutlet UIButton *thumbnailsViewToggleButton;

/**
 *  <#Description#>
 */
@property (nonatomic, weak) IBOutlet UILabel *thumbnailViewTitleLabel;

/**
 *  --------------------------------------------
 *  @name Actions
 *  --------------------------------------------
 */

/**
 *  <#Description#>
 *
 *  @param sender <#sender description#>
 */
- (IBAction) dismissMultiPlayerViewController:(id)sender;

/**
 *  --------------------------------------------
 *  @name Initializing a Multi Player Controller
 *  --------------------------------------------
 */

/**
 *  <#Description#>
 */
@property (nonatomic, strong, readonly) RTSMultiPlayerController *multiPlayerController;

/**
 *  <#Description#>
 */
@property (nonatomic, weak) id<RTSMultiPlayerControllerDataSource> multiPlayerControllerDataSource;

/**
 *  <#Description#>
 */
@property (nonatomic, weak) id<RTSMultiPlayerViewDataSource> multiPlayerViewDataSource;

/**
 *  <#Description#>
 */
@property (nonatomic, weak) id<RTSMultiPlayerViewDelegate> multiPlayerViewDelegate;

@end
