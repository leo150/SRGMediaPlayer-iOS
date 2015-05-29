//
//  Created by Frédéric Humbert-Droz on 08/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RTSMediaPlayer/RTSMediaPlayerControllerDataSource.h>

@class RTSMultiPlayerController;

/**
 *  <#Description#>
 */
@protocol RTSMultiPlayerControllerDataSource <RTSMediaPlayerControllerDataSource>

@required

/**
 *  <#Description#>
 *
 *  @param multiPlayerController <#multiPlayerController description#>
 *  @param completionHandler     <#completionHandler description#>
 */
- (void) multiPlayerController:(RTSMultiPlayerController *)multiPlayerController fetchMediaIdentifiersWithCompletionHandler:(void (^)(NSArray* identifiers))completionHandler;

@end
