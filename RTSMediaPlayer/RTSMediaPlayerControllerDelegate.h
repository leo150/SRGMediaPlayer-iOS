//
//  RTSMediaPlayerControllerDelegate.h
//  SRGMediaPlayer
//
//  Created by Лев Соколов on 26/10/16.
//  Copyright © 2016 SRG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RTSMediaPlayerController;

@protocol RTSMediaPlayerControllerDelegate <NSObject>

@optional
- (void)playerDidHandleSingleTap:(id)playerController;

- (void)playerDidHandleDoubleTap:(id)playerController;

- (void)playerController:(id)playerController
   didSetOverlaysVisible:(BOOL)visible;

@end
