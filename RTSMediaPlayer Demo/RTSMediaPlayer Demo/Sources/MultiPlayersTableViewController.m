//
//  Created by Frédéric Humbert-Droz on 22/04/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import "MultiPlayersTableViewController.h"
#import "ChannelVideo.h"
#import "MultiPlayerDataProvider.h"

#import "CustomRTSMultiPlayerViewController.h"

#import <RTSMultiChannelPlayer/RTSMultiPlayer.h>

@interface MultiPlayersTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UISegmentedControl *playerSegmentedControl;
@property (nonatomic, strong) MultiPlayerDataProvider *multiPlayerDataProvider;
@property (nonatomic, strong) NSArray *streams;

@end

@implementation MultiPlayersTableViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
	self.streams = [NSArray arrayWithContentsOfFile:[[NSBundle bundleForClass:self.class] pathForResource:@"MediaURLs" ofType:@"plist"]];
	
	self.clearsSelectionOnViewWillAppear = YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	UINavigationController *navigationController = segue.destinationViewController;
	
	if ([segue.identifier isEqualToString:@"ShowRTSMultiPlayer"])
	{
		NSIndexPath *indexPath = (NSIndexPath *)sender;
		NSDictionary *itemInfo = [self itemInfoAtIndexPath:indexPath];
		
		CustomRTSMultiPlayerViewController *controller = navigationController.viewControllers[0];
		controller.itemInfo = itemInfo;
	}
}



#pragma mark - Data

- (NSDictionary *) itemInfoAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *sectionInfo = self.streams[indexPath.section];
	NSArray *items = sectionInfo[@"items"];
	return items[indexPath.row];
}



#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.streams.count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSDictionary *sectionInfo = self.streams[section];
	return sectionInfo[@"name"];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSDictionary *sectionInfo = self.streams[section];
    return [(NSArray *)sectionInfo[@"items"] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveStreamCell" forIndexPath:indexPath];
	
	NSDictionary *itemInfo = [self itemInfoAtIndexPath:indexPath];
	cell.textLabel.text = itemInfo[@"name"];
    
    return cell;
}



#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *itemInfo = [self itemInfoAtIndexPath:indexPath];

	switch (self.playerSegmentedControl.selectedSegmentIndex) {
		case 0:
		{
			self.multiPlayerDataProvider = [[MultiPlayerDataProvider alloc] initMultiPlayerDataProviderWithItemInfo:itemInfo];
			[self presentMultiPlayerViewControllerAnimated:YES dataSource:self.multiPlayerDataProvider completion:NULL];
			break;
		}
		case 1:
		{
			[self performSegueWithIdentifier:@"ShowRTSMultiPlayer" sender:indexPath];
			break;
		}
	}
}



#pragma mark - RTSAnalyticsMediaPlayerDataSource

- (NSDictionary *) streamSenseLabelsMetadataForIdentifier:(NSString *)identifier
{
	return nil;
}

- (NSDictionary *) streamSensePlaylistMetadataForIdentifier:(NSString *)identifier
{
	return nil;
}

- (NSDictionary *) streamSenseClipMetadataForIdentifier:(NSString *)identifier
{
	return nil;
}

@end
