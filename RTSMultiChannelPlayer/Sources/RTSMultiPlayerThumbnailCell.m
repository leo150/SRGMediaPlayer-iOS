//
//  Created by Frédéric Humbert-Droz on 08/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import "RTSMultiPlayerThumbnailCell.h"

#import "RTSMultiPlayerController.h"
#import <RTSMediaPlayer/RTSMediaPlayerController.h>

@interface RTSMultiPlayerThumbnailCell ()

@property (nonatomic, weak) IBOutlet UIView *playerView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicatorView;

@end

@implementation RTSMultiPlayerThumbnailCell

- (void) dealloc
{
	self.mediaPlayerController = nil;
}

- (void) prepareForReuse
{
	self.mediaPlayerController = nil;
}

- (void) setMediaPlayerController:(RTSMediaPlayerController *)mediaPlayerController
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_mediaPlayerController = mediaPlayerController;
	
	[self updatePlaybackState];
	
	if (!mediaPlayerController)
		return;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerPlaybackStateDidChange:) name:RTSMediaPlayerPlaybackStateDidChangeNotification object:mediaPlayerController];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerDidShowControlOverlays:) name:RTSMultiPlayerDidShowControlOverlaysNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerDidHideControlOverlays:) name:RTSMultiPlayerDidHideControlOverlaysNotification object:nil];
	
	[mediaPlayerController attachPlayerToView:self.playerView];
	[mediaPlayerController play];
}

- (void) setControlsOverlayHidden:(BOOL)hidden
{
	if ([self.multiPlayerViewDelegate respondsToSelector:@selector(multiPlayerViewController:canToggleControlsOverlay:)])
	{
		if (![self.multiPlayerViewDelegate multiPlayerViewController:nil canToggleControlsOverlay:hidden])
			return;
	}
	
	[UIView animateWithDuration:0.3f animations:^{
		BOOL mediaTitleViewHidden = hidden ?: self.mediaPlayerTitleLabel.text.length == 0;
		self.mediaPlayerTitleView.alpha = mediaTitleViewHidden ? 0.0f : 1.0f;
	}];
}

- (void) updatePlaybackState
{
	switch (self.mediaPlayerController.playbackState)
	{
		case RTSMediaPlaybackStatePreparing:
		case RTSMediaPlaybackStateReady:
		case RTSMediaPlaybackStateStalled:
		{
			if (!self.loadingIndicatorView.isAnimating)
				[self.loadingIndicatorView startAnimating];
			break;
		}
		default:
		{
			if (self.loadingIndicatorView.isAnimating)
				[self.loadingIndicatorView stopAnimating];
			break;
		}
	}
}



#pragma mark - Notifications

- (void) mediaPlayerPlaybackStateDidChange:(NSNotification *)notification
{
	[self updatePlaybackState];
}

- (void) mediaPlayerDidShowControlOverlays:(NSNotification *)notification
{
	[self setControlsOverlayHidden:NO];
}

- (void) mediaPlayerDidHideControlOverlays:(NSNotification *)notification
{
	[self setControlsOverlayHidden:YES];
}

@end
