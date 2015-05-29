//
//  Created by Frédéric Humbert-Droz on 22/04/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChannelVideo : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *multiChannelTitle;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end
