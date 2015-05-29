//
//  Created by Frédéric Humbert-Droz on 08/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import "MultiPlayerDataProvider.h"

#import <RTSMediaPlayer/RTSMediaPlayer.h>
#import <RTSMultiChannelPlayer/RTSMultiPlayer.h>

@interface MultiPlayerDataProvider ()

@property (nonatomic, strong) NSDictionary *itemInfo;

@end

@implementation MultiPlayerDataProvider

- (instancetype) initMultiPlayerDataProviderWithItemInfo:(NSDictionary *)itemInfo
{
	if (!(self = [super init]))
		return nil;
	
	_itemInfo = itemInfo;
	
	return self;
}

- (NSArray *) identifiers
{
	NSArray *items = self.itemInfo[@"urls"];
	return [items valueForKey:@"url"];
}

- (id) objectForItemWithIdentifier:(NSString *)identifier
{
	NSArray *items = self.itemInfo[@"urls"];
	return [[items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
		return [evaluatedObject[@"url"] isEqualToString:identifier];
	}]] firstObject];
}

#pragma mark - RTSMultiPlayerControllerDataSource

- (void) multiPlayerController:(RTSMultiPlayerController *)multiPlayerController fetchMediaIdentifiersWithCompletionHandler:(void (^)(NSArray* identifiers))completionHandler
{
	completionHandler(self.identifiers);
}

#pragma mark - RTSMediaPlayerControllerDataSource

- (void) mediaPlayerController:(RTSMediaPlayerController *)mediaPlayerController contentURLForIdentifier:(NSString *)identifier completionHandler:(void (^)(NSURL *contentURL, NSError *error))completionHandler
{
	completionHandler([NSURL URLWithString:identifier], nil);
}



@end
