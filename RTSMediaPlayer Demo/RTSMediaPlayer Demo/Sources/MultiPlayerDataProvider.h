//
//  Created by Frédéric Humbert-Droz on 08/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RTSMediaPlayer/RTSMultiPlayerControllerDataSource.h>

@interface MultiPlayerDataProvider : NSObject <RTSMultiPlayerControllerDataSource>

- (instancetype) initMultiPlayerDataProviderWithItemInfo:(NSDictionary *)itemInfo;

- (id) objectForItemWithIdentifier:(NSString *)identifier;

@end
