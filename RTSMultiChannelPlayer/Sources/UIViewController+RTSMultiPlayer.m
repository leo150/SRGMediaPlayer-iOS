//
//  Created by Frédéric Humbert-Droz on 08/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import "UIViewController+RTSMultiPlayer.h"
#import "NSBundle+RTSMultiPlayer.h"
#import "RTSMultiPlayerViewController.h"

@implementation UIViewController (RTSMultiPlayer)

- (UINavigationController *) multiPlayerViewControllerWithDataSource:(id<RTSMultiPlayerControllerDataSource>)dataSource
{
	UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"RTSMultiPlayer" bundle:[NSBundle RTSMultiPlayerBundle]];
	
	UINavigationController *navigationController = [storyBoard instantiateInitialViewController];
	
	RTSMultiPlayerViewController *multiPlayerViewController = navigationController.viewControllers[0];
	multiPlayerViewController.multiPlayerControllerDataSource = dataSource;
	return navigationController;
}

- (void) presentMultiPlayerViewControllerAnimated:(BOOL)flag dataSource:(id<RTSMultiPlayerControllerDataSource>)dataSource completion:(void (^)(void))completion
{
	UINavigationController *navigationController = [self multiPlayerViewControllerWithDataSource:dataSource];
	[self presentViewController:navigationController animated:flag completion:completion];
}

@end
