//
//  Created by Frédéric Humbert-Droz on 08/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import "RTSMultiPlayerController.h"
#import <RTSMediaplayer/RTSMediaPlayerController.h>

NSString * const RTSMultiPlayerMainMediaWillChangeNotification = @"RTSMultiPlayerMainMediaWillChange";
NSString * const RTSMultiPlayerMainMediaDidChangeNotification = @"RTSMultiPlayerMainMediaDidChange";

NSString * const RTSMultiPlayerNumberOfMediaDidChangeNotification = @"RTSMultiPlayerNumberOfMediaDidChange";

NSString * const RTSMultiPlayerWillReloadDataNotification = @"RTSMultiPlayerWillReloadData";
NSString * const RTSMultiPlayerDidReloadDataNotification = @"RTSMultiPlayerDidReloadData";

NSString * const RTSMultiPlayerPlaybackStateDidChangeNotification = @"RTSMultiPlayerPlaybackStateDidChange";

NSString * const RTSMultiPlayerWillShowControlOverlaysNotification = @"RTSMultiPlayerWillShowControlOverlays";
NSString * const RTSMultiPlayerDidShowControlOverlaysNotification = @"RTSMultiPlayerDidShowControlOverlays";
NSString * const RTSMultiPlayerWillHideControlOverlaysNotification = @"RTSMultiPlayerWillHideControlOverlays";
NSString * const RTSMultiPlayerDidHideControlOverlaysNotification = @"RTSMultiPlayerDidHideControlOverlays";

@interface RTSMultiPlayerController ()

@property (nonatomic, strong) NSMutableOrderedSet *mediaPlayerControllers;

@end

@implementation RTSMultiPlayerController

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self.mediaPlayerControllers enumerateObjectsUsingBlock:^(RTSMediaPlayerController *mediaPlayerController, NSUInteger idx, BOOL *stop) {
		[mediaPlayerController reset];
	}];
	
	self.mediaPlayerControllers = nil;
}

- (instancetype) initWithMainPlayerView:(UIView *)mainPlayerView
{
	if (!(self = [super init]))
		return nil;
	
	_mainPlayerView = mainPlayerView;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerWillShowControlOverlays:) name:RTSMediaPlayerWillShowControlOverlaysNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerDidShowControlOverlays:) name:RTSMediaPlayerDidShowControlOverlaysNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerWillHideControlOverlays:) name:RTSMediaPlayerWillHideControlOverlaysNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerDidHideControlOverlays:) name:RTSMediaPlayerDidHideControlOverlaysNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerPlaybackStateDidChangeNotification:) name:RTSMediaPlayerPlaybackStateDidChangeNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	
	return self;
}



#pragma mark - Data

- (void) setDataSource:(id<RTSMultiPlayerControllerDataSource>)dataSource
{
	if ([dataSource isEqual:_dataSource])
		return;
	
	_dataSource = dataSource;
	
	[self reloadData];
}

- (void) reloadData
{
	if (!self.mediaPlayerControllers)
		self.mediaPlayerControllers = [NSMutableOrderedSet new];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RTSMultiPlayerWillReloadDataNotification object:self];
	
	[self.dataSource multiPlayerController:self fetchMediaIdentifiersWithCompletionHandler:^(NSArray *identifiers) {
		[identifiers enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger idx, BOOL *stop) {
			[self insertIdentifier:identifier atIndex:idx];
		}];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:RTSMultiPlayerDidReloadDataNotification object:self];
	}];
}

- (void) insertIdentifier:(NSString *)identifier atIndex:(NSUInteger)index
{
	RTSMediaPlayerController *mediaPlayerController = [self mediaPlayerControllerWithIdentifier:identifier];
	if (mediaPlayerController)
		return;
	
	mediaPlayerController = [[RTSMediaPlayerController alloc] initWithContentIdentifier:identifier dataSource:self.dataSource];
	[self.mediaPlayerControllers insertObject:mediaPlayerController atIndex:index];
	
	if (index == 0) {
		[self setupMainMediaPlayerController];
	}else{
		[self setupThumbnailMediaPlayerControllerAtIndex:index];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RTSMultiPlayerNumberOfMediaDidChangeNotification object:self];
}

- (void) swapMediaPlayerControllerActionHandler:(NSUInteger (^)(void))actionHandler;
{
	if (self.mediaPlayerControllers.count <= 1)
		return;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RTSMultiPlayerMainMediaWillChangeNotification object:self];
	
	BOOL isExternalPlaybackActive = self.mainMediaPlayerController.player.isExternalPlaybackActive;
	
	NSUInteger indexOfNewMainPlayer = actionHandler();
	
	if (isExternalPlaybackActive) {
		RTSMediaPlayerController *mediaPlayerController = self.mediaPlayerControllers[indexOfNewMainPlayer];
		[mediaPlayerController reset];
	}
	
	[self.mediaPlayerControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (idx > 0) {
			[self setupThumbnailMediaPlayerControllerAtIndex:idx];
		}
	}];
	[self setupMainMediaPlayerController];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:RTSMultiPlayerMainMediaDidChangeNotification object:self];
}

- (void) setMainIdentifier:(NSString *)identifier
{
	RTSMediaPlayerController *mediaPlayerController = [self mediaPlayerControllerWithIdentifier:identifier];
	if (!mediaPlayerController)
		return;
	
	NSUInteger indexOfNewMainPlayer = [self.mediaPlayerControllers indexOfObject:mediaPlayerController];
	
	[self swapMediaPlayerControllerActionHandler:^NSUInteger{
		[self.mediaPlayerControllers exchangeObjectAtIndex:indexOfNewMainPlayer withObjectAtIndex:0];
		return indexOfNewMainPlayer;
	}];
}

- (void) setNextMainIdentifier
{
	[self swapMediaPlayerControllerActionHandler:^NSUInteger{

		RTSMediaPlayerController *mediaPlayerController = self.mediaPlayerControllers[0];
		[self.mediaPlayerControllers removeObjectAtIndex:0];
		[self.mediaPlayerControllers addObject:mediaPlayerController];

		return self.mediaPlayerControllers.count - 1;
	}];
}

- (void) setPreviousMainIdentifier
{
	[self swapMediaPlayerControllerActionHandler:^NSUInteger{
		
		RTSMediaPlayerController *mediaPlayerController = self.mediaPlayerControllers[self.mediaPlayerControllers.count - 1];
		[self.mediaPlayerControllers removeObjectAtIndex:self.mediaPlayerControllers.count - 1];
		[self.mediaPlayerControllers insertObject:mediaPlayerController atIndex:0];
		
		return self.mediaPlayerControllers.count - 1;
	}];
}



#pragma mark - Media Play Controllers

- (void) setupMainMediaPlayerController
{
	if (self.mediaPlayerControllers.count == 0)
		return;
	
	RTSMediaPlayerController *mediaPlayerController = self.mediaPlayerControllers[0];
	mediaPlayerController.activityView = self.mainPlayerView.superview ?: self.mainPlayerView;
	mediaPlayerController.player.allowsExternalPlayback = YES;
	mediaPlayerController.player.muted = NO;
	
	[mediaPlayerController.view.gestureRecognizers enumerateObjectsUsingBlock:^(UIGestureRecognizer *gestureRecognizer, NSUInteger idx, BOOL *stop) {
		gestureRecognizer.enabled = [gestureRecognizer isKindOfClass:UITapGestureRecognizer.class];
	}];
	
	[mediaPlayerController attachPlayerToView:self.mainPlayerView];
	[mediaPlayerController play];
}

- (void) setupThumbnailMediaPlayerControllerAtIndex:(NSUInteger)index
{
	if (self.mediaPlayerControllers.count <= 1 && index >= self.mediaPlayerControllers.count)
		return;
	
	RTSMediaPlayerController *mediaPlayerController = self.mediaPlayerControllers[index];
	mediaPlayerController.activityView = self.mainPlayerView.superview ?: self.mainPlayerView;
	mediaPlayerController.player.allowsExternalPlayback = NO;
	mediaPlayerController.player.muted = YES;
	
	[mediaPlayerController.view.gestureRecognizers enumerateObjectsUsingBlock:^(UIGestureRecognizer *gestureRecognizer, NSUInteger idx, BOOL *stop) {
		gestureRecognizer.enabled = NO;
	}];
}

- (NSUInteger) numberOfThumbnailMediaPlayerControllers
{
	return self.mediaPlayerControllers.count > 0 ? self.mediaPlayerControllers.count - 1 : 0;
}

- (RTSMediaPlayerController *) mediaPlayerControllerWithIdentifier:(NSString *)identifier
{
	__block RTSMediaPlayerController *mediaPlayerController = nil;
	
	[self.mediaPlayerControllers enumerateObjectsUsingBlock:^(RTSMediaPlayerController *controller, NSUInteger idx, BOOL *stop) {
		if ([controller.identifier isEqualToString:identifier]) {
			mediaPlayerController = controller;
			*stop = YES;
		}
	}];
	
	return mediaPlayerController;
}

- (RTSMediaPlayerController *) mainMediaPlayerController
{
	return (self.mediaPlayerControllers.count > 0) ? [self.mediaPlayerControllers objectAtIndex:0] : nil;
}

- (RTSMediaPlayerController *) thumbnailMediaPlayerControllerAtIndex:(NSUInteger)index
{
	NSUInteger thumbnailIndex = index + 1;
	return thumbnailIndex < self.mediaPlayerControllers.count ? [self.mediaPlayerControllers objectAtIndex:thumbnailIndex] : nil;
}

- (BOOL) isMainMediaPlayerController:(RTSMediaPlayerController *) mediaPlayerController
{
	return mediaPlayerController ? [self.mediaPlayerControllers indexOfObject:mediaPlayerController] == 0 : NO;
}



#pragma mark - Media player actions

- (void) playThumbnails
{
	[self.mediaPlayerControllers enumerateObjectsUsingBlock:^(RTSMediaPlayerController *mediaPlayerController, NSUInteger idx, BOOL *stop) {
		if (idx > 0) {
			[mediaPlayerController play];
		}
	}];
}

- (void) resetThumbnails
{
	[self.mediaPlayerControllers enumerateObjectsUsingBlock:^(RTSMediaPlayerController *mediaPlayerController, NSUInteger idx, BOOL *stop) {
		if (idx > 0) {
			[mediaPlayerController reset];
		}
	}];
}



#pragma mark - Notifications

- (void) applicationWillEnterForeground:(NSNotification *)notification
{
	if(self.mainMediaPlayerController.player.isExternalPlaybackActive)
	{
		[self playThumbnails];
	}
}

- (void) applicationDidEnterBackground:(NSNotification *)notification
{
	if(self.mainMediaPlayerController.player.isExternalPlaybackActive)
	{
		[self resetThumbnails];
	}
}

- (void) mediaPlayerPlaybackStateDidChangeNotification:(NSNotification *)notification
{
	RTSMediaPlayerController *controller = notification.object;
	
	BOOL isMainMediaPlayerController = [self isMainMediaPlayerController:controller];
	
	switch (controller.playbackState)
	{
		case RTSMediaPlaybackStateReady:
		{
			if (isMainMediaPlayerController) {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
					[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
					[[AVAudioSession sharedInstance] setActive:YES error: nil];
				});
			}
			
			controller.player.allowsExternalPlayback = isMainMediaPlayerController;
			controller.player.muted = !isMainMediaPlayerController;
			
			[self performSelector:@selector(unmuteMainMediaPlayerControllerWorkarround) withObject:nil afterDelay:0.5f];
			
			break;
		}
		case RTSMediaPlaybackStateIdle:
		{
			if (isMainMediaPlayerController) {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
					[[AVAudioSession sharedInstance] setActive:NO error: nil];
				});
			}
			break;
		}
		default:
			break;
	}

	[self forwardMainMediaPlayerControllerNotification:notification notificationName:RTSMultiPlayerPlaybackStateDidChangeNotification];
}

- (void) unmuteMainMediaPlayerControllerWorkarround
{
	dispatch_async(dispatch_get_main_queue(), ^{
		self.mainMediaPlayerController.player.muted = YES;
		self.mainMediaPlayerController.player.muted = NO;
	});
}

- (void) mediaPlayerWillShowControlOverlays:(NSNotification *)notification
{
	[self forwardMainMediaPlayerControllerNotification:notification notificationName:RTSMultiPlayerWillShowControlOverlaysNotification];
}

- (void) mediaPlayerDidShowControlOverlays:(NSNotification *)notification
{
	[self forwardMainMediaPlayerControllerNotification:notification notificationName:RTSMultiPlayerDidShowControlOverlaysNotification];
}

- (void) mediaPlayerWillHideControlOverlays:(NSNotification *)notification
{
	[self forwardMainMediaPlayerControllerNotification:notification notificationName:RTSMultiPlayerWillHideControlOverlaysNotification];
}

- (void) mediaPlayerDidHideControlOverlays:(NSNotification *)notification
{
	[self forwardMainMediaPlayerControllerNotification:notification notificationName:RTSMultiPlayerDidHideControlOverlaysNotification];
}

- (void) forwardMainMediaPlayerControllerNotification:(NSNotification *)notification notificationName:(NSString *)notificationName
{
	if (![self isMainMediaPlayerController:notification.object])
		return;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
}

@end
