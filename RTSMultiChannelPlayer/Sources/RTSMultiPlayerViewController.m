//
//  Created by Frédéric Humbert-Droz on 08/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import "RTSMultiPlayerViewController.h"
#import "RTSMultiPlayerThumbnailCell.h"
#import <RTSMediaplayer/RTSMediaPlayerController.h>

@interface RTSMultiPlayerViewController ()

@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, strong, readwrite) RTSMultiPlayerController *multiPlayerController;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *mainMediaPlayerLoadingIndicator;

@property (nonatomic, weak) IBOutlet UIView *thumbnailsOverlayView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailsViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailsViewWidthConstraints;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailsViewBottomConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailsOverlayViewHeightConstant;

@end

@implementation RTSMultiPlayerViewController

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.multiPlayerController = nil;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if (!(self = [super initWithCoder:aDecoder]))
		return nil;
	
	_multiPlayerViewDataSource = self;
	_multiPlayerViewDelegate = self;
	
	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(multiPlayerMainMediaDidChange:) name:RTSMultiPlayerMainMediaDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(multiPlayerPlaybackStateDidChange:) name:RTSMultiPlayerPlaybackStateDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(multiPlayerDidShowControlOverlays:) name:RTSMultiPlayerDidShowControlOverlaysNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(multiPlayerDidHideControlOverlays:) name:RTSMultiPlayerDidHideControlOverlaysNotification object:nil];
	
	self.multiPlayerController = [[RTSMultiPlayerController alloc] initWithMainPlayerView:self.mainPlayerView];
	self.multiPlayerController.dataSource = self.multiPlayerControllerDataSource;
	
	[self updateThumbnailsSizeForInterfaceOrientation:self.interfaceOrientation];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self updateThumbnailsSizeForInterfaceOrientation:toInterfaceOrientation];
}



#pragma mark - Interface

- (void) updateMainMediaPlayerControllerInterface
{
	RTSMediaPlayerController *mainMediaPlayerController = self.multiPlayerController.mainMediaPlayerController;
	
	NSString *mainMediaTitle = nil;
	if ([self.multiPlayerViewDataSource respondsToSelector:@selector(multiPlayerViewController:titleForMainMediaWithIdentifier:)])
		mainMediaTitle = [self.multiPlayerViewDataSource multiPlayerViewController:self titleForMainMediaWithIdentifier:mainMediaPlayerController.identifier];
	self.mainMediaTitleLabel.text = mainMediaTitle;
	
	NSString *mainMediaSubtitle = nil;
	if ([self.multiPlayerViewDataSource respondsToSelector:@selector(multiPlayerViewController:subTitleForMainMediaWithIdentifier:)])
		mainMediaSubtitle = [self.multiPlayerViewDataSource multiPlayerViewController:self subTitleForMainMediaWithIdentifier:mainMediaPlayerController.identifier];
	self.mainMediaSubtitleLabel.text = mainMediaSubtitle;
	
	self.mainMediaTitleView.hidden = (self.mainMediaTitleLabel.text.length == 0 && self.mainMediaSubtitleLabel.text.length == 0);

	switch (mainMediaPlayerController.playbackState)
	{
		case RTSMediaPlaybackStatePreparing:
		case RTSMediaPlaybackStateReady:
		case RTSMediaPlaybackStateStalled:
		{
			if (!self.mainMediaPlayerLoadingIndicator.isAnimating)
				[self.mainMediaPlayerLoadingIndicator startAnimating];
			break;
		}
		default:
		{
			if (self.mainMediaPlayerLoadingIndicator.isAnimating)
				[self.mainMediaPlayerLoadingIndicator stopAnimating];
			break;
		}
	}
}



#pragma mark - Actions

- (IBAction) dismissMultiPlayerViewController:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction) toggleThumbnailsVisibility:(id)sender
{
	if (self.thumbnailsViewBottomConstraint.constant < 0)
		[self openThumbnailsView];
	else
		[self closeThumbnailsView];
}

- (IBAction) swipedLeft:(id)sender
{
	[self.multiPlayerController setNextMainIdentifier];
}

- (IBAction) swipedRight:(id)sender
{
	[self.multiPlayerController setPreviousMainIdentifier];
}



#pragma mark - Multi Player Notifications

- (void) multiPlayerMainMediaDidChange:(NSNotification *)notification
{
	[self updateMainMediaPlayerControllerInterface];
	[self.thumbnailsCollectionView reloadData];
}

- (void) multiPlayerPlaybackStateDidChange:(NSNotification *)notification
{
	[self updateMainMediaPlayerControllerInterface];
}

- (void) multiPlayerDidShowControlOverlays:(NSNotification *)notification
{
	[self setControlsOverlayHidden:NO];
}

- (void) multiPlayerDidHideControlOverlays:(NSNotification *)notification
{
	[self setControlsOverlayHidden:YES];
}

- (void) setControlsOverlayHidden:(BOOL)hidden
{
	if ([self.multiPlayerViewDelegate respondsToSelector:@selector(multiPlayerViewController:canToggleControlsOverlay:)])
	{
		if (![self.multiPlayerViewDelegate multiPlayerViewController:self canToggleControlsOverlay:hidden])
			return;
	}
	
	[self.navigationController setNavigationBarHidden:hidden animated:YES];
	[self setStatusBarHidden:hidden];
	
	BOOL mainMediaTitleViewHidden = hidden ?: (self.mainMediaTitleLabel.text.length == 0 && self.mainMediaSubtitleLabel.text.length == 0);
	BOOL thumbnailsOverlayViewHidden = hidden ?: [self.multiPlayerController numberOfThumbnailMediaPlayerControllers] == 0;
	
	[UIView animateWithDuration:0.3f animations:^{
		self.mainMediaTitleView.alpha = mainMediaTitleViewHidden ? 0.0f : 1.0f;
		self.thumbnailsOverlayView.alpha = thumbnailsOverlayViewHidden ? 0.0f : 1.0f;
	}];
}



#pragma mark - Status Bar

- (void) setStatusBarHidden:(BOOL)statusBarHidden
{
	self.statusBarHidden = statusBarHidden;
	
	[[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden withAnimation:self.preferredStatusBarUpdateAnimation];
	[UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
		[self setNeedsStatusBarAppearanceUpdate];
	}];
}

- (BOOL) prefersStatusBarHidden
{
	return self.statusBarHidden;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation) preferredStatusBarUpdateAnimation
{
	return UIStatusBarAnimationSlide;
}



#pragma mark - UICollectionViewDataSource

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	NSString *titleForThumbnailsViewHeader = nil;
	if ([self.multiPlayerViewDataSource respondsToSelector:@selector(multiPlayerViewControllerTitleForThumbnailsViewHeader:)])
		titleForThumbnailsViewHeader = [self.multiPlayerViewDataSource multiPlayerViewControllerTitleForThumbnailsViewHeader:self];
	self.thumbnailViewTitleLabel.text = titleForThumbnailsViewHeader;
	
	NSUInteger numberOfThumbnails = [self.multiPlayerController numberOfThumbnailMediaPlayerControllers];
	[self setThumbnailsHidden:(numberOfThumbnails == 0)];
	
	return [self.multiPlayerController numberOfThumbnailMediaPlayerControllers];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	RTSMultiPlayerThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(RTSMultiPlayerThumbnailCell.class) forIndexPath:indexPath];
	
	RTSMediaPlayerController *mediaPlayerController = [self.multiPlayerController thumbnailMediaPlayerControllerAtIndex:indexPath.item];
	cell.multiPlayerViewDelegate = self;
	cell.mediaPlayerTitleLabel.text = nil;
	
	if ([self.multiPlayerViewDataSource respondsToSelector:@selector(multiPlayerViewController:configureThumbnailCell:mediaPlayerController:atIndexPath:)])
		[self.multiPlayerViewDataSource multiPlayerViewController:self configureThumbnailCell:cell mediaPlayerController:mediaPlayerController atIndexPath:indexPath];
	
	cell.mediaPlayerController = mediaPlayerController;
	
	[cell setControlsOverlayHidden:self.statusBarHidden];
	
	return cell;
}



#pragma mark - UICollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	RTSMediaPlayerController *mediaPlayerController = [self.multiPlayerController thumbnailMediaPlayerControllerAtIndex:indexPath.item];
	[self.multiPlayerController setMainIdentifier:mediaPlayerController.identifier];

	[UIView performWithoutAnimation:^{
		[collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
	}];
}



#pragma mark - Thumbnails size

- (CGSize) availableSizeForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	CGFloat screenWidth = MIN(CGRectGetMaxX(self.view.frame), CGRectGetMaxY(self.view.frame));
	CGFloat screenHeight = MAX(CGRectGetMaxX(self.view.frame), CGRectGetMaxY(self.view.frame));
	
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
	{
		screenWidth = MAX(CGRectGetMaxX(self.view.frame), CGRectGetMaxY(self.view.frame));
		screenHeight = MIN(CGRectGetMaxX(self.view.frame), CGRectGetMaxY(self.view.frame));
	}
	
	CGFloat viewHeight = (screenWidth * 9) / 16;
	return CGSizeMake(0, screenHeight - viewHeight);
}

- (CGSize) thumbnailSizeForAvailableSize:(CGSize)availableSize interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	CGFloat minHeightWidth = MIN(CGRectGetMaxX(self.view.bounds), CGRectGetMaxY(self.view.bounds));
	NSUInteger count = [self.multiPlayerController numberOfThumbnailMediaPlayerControllers];
		
	CGFloat itemWidth = minHeightWidth / (MAX(count, 2));
	CGFloat itemHeight = (itemWidth / 16)*9;
		
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
	{
		itemHeight = floor(availableSize.height) ?: floor(minHeightWidth/5);
		itemWidth = itemHeight * 16/9;
	}
	
	return CGSizeMake(itemWidth, itemHeight);
}

- (void) updateThumbnailsSizeForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	CGSize availableSize = [self availableSizeForInterfaceOrientation:interfaceOrientation];
	CGSize itemSize = [self thumbnailSizeForAvailableSize:availableSize interfaceOrientation:interfaceOrientation];
	
	UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.thumbnailsCollectionView.collectionViewLayout;
	flowLayout.itemSize = itemSize;
	[flowLayout invalidateLayout];
	
	self.thumbnailsViewHeightConstraint.constant = itemSize.height+1;
	self.thumbnailsViewWidthConstraints.constant = itemSize.width * [self.multiPlayerController numberOfThumbnailMediaPlayerControllers];
	
	self.thumbnailsViewBottomConstraint.constant = self.thumbnailsViewBottomConstraint.constant < 0 ? [self thumbnailsViewBottomConstant] : 0;
}

- (CGFloat) thumbnailsViewBottomConstant
{
	CGFloat thumbnailsOverlayViewHeight = self.thumbnailsOverlayView.isHidden ? self.thumbnailsOverlayViewHeightConstant.constant : 0;
	return -(self.thumbnailsViewHeightConstraint.constant + thumbnailsOverlayViewHeight);
}



#pragma mark - Thumbnails visibility

- (void) setThumbnailsHidden:(BOOL) hidden
{
	if (!self.navigationController.navigationBarHidden)
		[self.thumbnailsOverlayView setHidden:hidden];
	
	[self.thumbnailsCollectionView setHidden:hidden];
	
	if (hidden)
		[self closeThumbnailsView];
	else
		[self openThumbnailsView];
}

- (void) openThumbnailsView
{
	if (self.thumbnailsViewBottomConstraint.constant == 0)
		return;
	
	[self.multiPlayerController playThumbnails];
	
	self.thumbnailsViewBottomConstraint.constant = 0;
	[UIView animateWithDuration:0.3f animations:^{
		[self.view layoutIfNeeded];
		self.thumbnailsCollectionView.alpha = 1.0f;
	} completion:NULL];
	
	if ([self.multiPlayerViewDelegate respondsToSelector:@selector(multiPlayerViewControllerThumbnailsViewWillOpen:)])
		[self.multiPlayerViewDelegate multiPlayerViewControllerThumbnailsViewWillOpen:self];
}

- (void) closeThumbnailsView
{
	if (self.thumbnailsViewBottomConstraint.constant < 0)
		return;
	
	self.thumbnailsViewBottomConstraint.constant = [self thumbnailsViewBottomConstant];
	
	[UIView animateWithDuration:0.3f animations:^{
		[self.view layoutIfNeeded];
		self.thumbnailsCollectionView.alpha = 0.0f;
	} completion:^(BOOL finished) {
		[self.multiPlayerController resetThumbnails];
	}];
	
	if ([self.multiPlayerViewDelegate respondsToSelector:@selector(multiPlayerViewControllerThumbnailsViewWillClose:)])
		[self.multiPlayerViewDelegate multiPlayerViewControllerThumbnailsViewWillClose:self];
}



#pragma mark - RTSMultiPlayerViewDataSource

- (NSString *) multiPlayerViewControllerTitleForThumbnailsViewHeader:(RTSMultiPlayerViewController *)multiPlayerViewController
{
	return @"En direct";
}

#pragma mark - RTSMultiPlayerViewDelegate

- (void)multiPlayerViewControllerThumbnailsViewWillClose:(RTSMultiPlayerViewController *)multiPlayerViewController
{
	[self.thumbnailsViewToggleButton setTitle:@"Afficher" forState:UIControlStateNormal];
}

- (void)multiPlayerViewControllerThumbnailsViewWillOpen:(RTSMultiPlayerViewController *)multiPlayerViewController
{
	[self.thumbnailsViewToggleButton setTitle:@"Masquer" forState:UIControlStateNormal];
}



#pragma mark - Remote Control Events

- (void) remoteControlReceivedWithEvent:(UIEvent *)event
{
	switch (event.subtype)
	{
		case UIEventSubtypeRemoteControlTogglePlayPause:
			
			if (self.multiPlayerController.mainMediaPlayerController.playbackState == RTSMediaPlaybackStatePaused) {
				[self.multiPlayerController.mainMediaPlayerController play];
			}else{
				[self.multiPlayerController.mainMediaPlayerController pause];
			}
			
			break;
		case UIEventSubtypeRemoteControlPlay:
			[self.multiPlayerController.mainMediaPlayerController play];
			break;
		case UIEventSubtypeRemoteControlPause:
			[self.multiPlayerController.mainMediaPlayerController pause];
			break;
		case UIEventSubtypeRemoteControlNextTrack:
			[self.multiPlayerController setNextMainIdentifier];
			break;
		case UIEventSubtypeRemoteControlPreviousTrack :
			[self.multiPlayerController setPreviousMainIdentifier];
			break;
		default:
			break;
	}
}

@end
