//
//  Created by Frédéric Humbert-Droz on 16/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import "CustomRTSMultiPlayerThumbnailCell.h"
#import <RTSMediaPlayer/RTSMediaFailureOverlayView.h>

@interface CustomRTSMultiPlayerThumbnailCell ()
@property (nonatomic, weak) IBOutlet RTSMediaFailureOverlayView *thumbnailMediaFailureOverlayView;

@end

@implementation CustomRTSMultiPlayerThumbnailCell

- (void) setMediaPlayerController:(RTSMediaPlayerController *)mediaPlayerController
{
	[self.thumbnailMediaFailureOverlayView setMediaPlayerController:mediaPlayerController];
	[super setMediaPlayerController:mediaPlayerController];
}



#pragma mark - Actions

- (IBAction) retry:(id)sender
{
	self.thumbnailMediaFailureOverlayView.hidden = YES;
	[self.mediaPlayerController play];
}

@end
