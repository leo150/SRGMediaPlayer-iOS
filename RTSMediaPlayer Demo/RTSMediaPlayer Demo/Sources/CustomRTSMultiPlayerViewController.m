//
//  Created by Frédéric Humbert-Droz on 12/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import "CustomRTSMultiPlayerViewController.h"
#import "MultiPlayerDataProvider.h"
#import "RTSMediaFailureOverlayView.h"

#import <RTSMediaPlayer/RTSMediaPlayerController.h>
#import <RTSMediaPlayer/RTSMediaFailureOverlayView.h>

@interface CustomRTSMultiPlayerViewController ()
@property (nonatomic, strong) MultiPlayerDataProvider *dataProvider;
@property (nonatomic, weak) IBOutlet RTSMediaFailureOverlayView *mainMediaFailureOverlayView;
@end

@implementation CustomRTSMultiPlayerViewController

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	_itemInfo = nil;
	_dataProvider = nil;
}

- (void) viewDidLoad
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customMultiPlayerMainMediaWillChange:) name:RTSMultiPlayerMainMediaWillChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customMultiPlayerMainMediaDidChange:) name:RTSMultiPlayerMainMediaDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customMultiPlayerDidReloadData:) name:RTSMultiPlayerDidReloadDataNotification object:nil];

	[super viewDidLoad];
	
}

- (void) setItemInfo:(NSDictionary *)itemInfo
{
	_itemInfo = itemInfo;
	self.dataProvider = [[MultiPlayerDataProvider alloc] initMultiPlayerDataProviderWithItemInfo:itemInfo];
}

- (void) setDataProvider:(MultiPlayerDataProvider *)dataProvider
{
	_dataProvider = dataProvider;
	self.multiPlayerControllerDataSource = dataProvider;
}



#pragma mark - Notifications

- (void) customMultiPlayerMainMediaWillChange:(NSNotification *)notification
{
	NSLog(@"multiPlayerMainMediaWillChange : %@", self.multiPlayerController.mainMediaPlayerController.identifier);
}

- (void) customMultiPlayerMainMediaDidChange:(NSNotification *)notification
{
	NSLog(@"multiPlayerMainMediaDidChange : %@", self.multiPlayerController.mainMediaPlayerController.identifier);
	[self.mainMediaFailureOverlayView setMediaPlayerController:self.multiPlayerController.mainMediaPlayerController];
}

- (void) customMultiPlayerDidReloadData:(NSNotification *)notification
{
	NSLog(@"customMultiPlayerDidReloadData : %@", self.multiPlayerController.mainMediaPlayerController.identifier);
	[self.mainMediaFailureOverlayView setMediaPlayerController:self.multiPlayerController.mainMediaPlayerController];
}



#pragma mark - Actions

- (IBAction) retry:(id)sender
{
	[self.multiPlayerController.mainMediaPlayerController play];
}



#pragma mark - RTSMultiPlayerViewDataSource

- (NSString *) multiPlayerViewController:(RTSMultiPlayerViewController *)multiPlayerViewController titleForMainMediaWithIdentifier:(NSString *)identifier
{
	id object = [self.dataProvider objectForItemWithIdentifier:identifier];
	return object[@"name"];
}

- (NSString *) multiPlayerViewController:(RTSMultiPlayerViewController *)multiPlayerViewController subTitleForMainMediaWithIdentifier:(NSString *)identifier;
{
	id object = [self.dataProvider objectForItemWithIdentifier:identifier];
	
	NSString *subtitle = [NSString stringWithFormat:@"En direct"];
	if (subtitle.length > 0)
		subtitle = [NSString stringWithFormat:@"%@ - En direct", object[@"subtitle"]];
	
	return subtitle;
}

- (void) multiPlayerViewController:(RTSMultiPlayerViewController *)multiPlayerViewController configureThumbnailCell:(RTSMultiPlayerThumbnailCell *)cell mediaPlayerController:(RTSMediaPlayerController *)mediaPlayerController atIndexPath:(NSIndexPath *)indexPath
{
	id object = [self.dataProvider objectForItemWithIdentifier:mediaPlayerController.identifier];
	cell.mediaPlayerTitleLabel.text = object[@"name"];
}

- (NSString *) multiPlayerViewControllerTitleForThumbnailsViewHeader:(RTSMultiPlayerViewController *)multiPlayerViewController
{
	return @"Retrouvez nos émissions en direct";
}

@end
