//
//  Created by Frédéric Humbert-Droz on 08/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTSMultiPlayerViewDelegate.h"

@class RTSMediaPlayerController;

/**
 *  <#Description#>
 */
@interface RTSMultiPlayerThumbnailCell : UICollectionViewCell

/**
 *  <#Description#>
 */
@property (nonatomic, weak) RTSMediaPlayerController *mediaPlayerController;

/**
 *  <#Description#>
 */
@property (nonatomic, weak) id<RTSMultiPlayerViewDelegate> multiPlayerViewDelegate;

/**
 *  <#Description#>
 */
@property (nonatomic, weak) IBOutlet UIView  *mediaPlayerTitleView;

/**
 *  <#Description#>
 */
@property (nonatomic, weak) IBOutlet UILabel *mediaPlayerTitleLabel;

/**
 *  <#Description#>
 *
 *  @param hidden <#hidden description#>
 */
- (void) setControlsOverlayHidden:(BOOL)hidden;

@end
