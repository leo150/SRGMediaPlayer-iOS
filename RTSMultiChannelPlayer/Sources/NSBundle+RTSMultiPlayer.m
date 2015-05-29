//
//  Created by Frédéric Humbert-Droz on 08/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import "NSBundle+RTSMultiPlayer.h"

@implementation NSBundle (RTSMultiPlayer)

+ (instancetype) RTSMultiPlayerBundle
{
	static NSBundle *multiPlayerBundle;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		NSURL *multiPlayerBundleURL = [[NSBundle mainBundle] URLForResource:@"RTSMultiPlayer" withExtension:@"bundle"];
		NSAssert(multiPlayerBundleURL != nil, @"RTSMultiPlayer.bundle not found in the main bundle's resources");
		multiPlayerBundle = [NSBundle bundleWithURL:multiPlayerBundleURL];
	});
	return multiPlayerBundle;
}

@end
