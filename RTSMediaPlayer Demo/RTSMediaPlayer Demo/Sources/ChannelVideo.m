//
//  Created by Frédéric Humbert-Droz on 22/04/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import "ChannelVideo.h"

@implementation ChannelVideo

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
	if (!(self = [super init]))
		return nil;
	
	self.identifier = dictionary[@"url"];
	self.multiChannelTitle = dictionary[@"name"];
	
	return self;
}

@end
