//
//  Created by Frédéric Humbert-Droz on 08/05/15.
//  Copyright (c) 2015 RTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTSMultiPlayerControllerDataSource.h"

/**
 *  <#Description#>
 */
@interface UIViewController (RTSMultiPlayer)

/**
 *  <#Description#>
 *
 *  @param dataSource <#dataSource description#>
 *
 *  @return <#return value description#>
 */
- (UINavigationController *) multiPlayerViewControllerWithDataSource:(id<RTSMultiPlayerControllerDataSource>)dataSource;

/**
 *  <#Description#>
 *
 *  @param flag       <#flag description#>
 *  @param dataSource <#dataSource description#>
 *  @param completion <#completion description#>
 */
- (void) presentMultiPlayerViewControllerAnimated:(BOOL)flag dataSource:(id<RTSMultiPlayerControllerDataSource>)dataSource completion:(void (^)(void))completion;

@end
