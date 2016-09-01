//
//  Copyright (c) SRG. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>

#import "SRGMediaPlayerConstants.h"
#import "SRGMediaPlayerView.h"
#import "SRGSegment.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  `SRGMediaPlayerController` is inspired by the `MPMoviePlayerController` class. It manages the playback of a media 
 *  from a file or a network stream, but provides only core player functionality. As such, it is intended for custom
 *  media player implementation. If you need a player with limited customization abilities but which you can readily 
 *  use, you should have a look at `SRGMediaPlayerViewController` instead.
 *
 *  ## Functionalities
 *
 * `SRGMediaPlayerController` provides standard player features:
 *    - Audio and video playback for all kinds of streams (on-demand, live, DVR)
 *    - Playback status information (mostly through notifications or KVO)
 *    - Media information extraction
 *
 *  In addition, `SRGMediaPlayerController` optionally supports segments. A segment is part of a media, defined by a
 *  start time and a duration. Segments make it possible to add a logical structure on top of a media, e.g. topics
 *  in a news show, chapters in a movie, and so on. If segments are associated with the media being played, 
 *  `SRGMediaPlayerController` will:
 *    - Report transitions between segments when they occur (through notifications)
 *    - Skip segments which must must not be played (blocked segments)
 *
 *  ## Basic usage
 *
 *  `SRGMediaPlayerController` is a raw media player and is usually not used as is (though it could, for example
 *  when you only need to play audio files).
 *
 *  To implement your own custom media player, you need create your own player class (most probably a view controller),
 *  and to delegate playback to an `SRGMediaPlayerController` instance:
 *    - Instantiate `SRGMediaPlayerController` in your player implementation file. If you are using a storyboard or 
 *      a xib to define your player layout, you can also drop a plain object with Interface Builder and assign it the
 *      `SRGMediaPlayerController` class. Be sure to connect an outlet to it if you need to later refer to it from
 *      witin your code
 *    - When creating a video player, you must add the `view` property somewhere within your view hierarchy so that
 *      the content can be properly displayed:
 *        - If you are instantiating the controller in a storyboard or a nib, this is easily achieved by adding a view 
 *          with the `SRGMediaPlayerView` to your layout, and binding it to the `view` property right from Interface 
 *          Builder.
 *        - If you have instantiated `SRGMediaPlayerController` in code, then you must add the `view` property manually
 *          to your view hierarchy by calling `-[UIView addSubview:]` or one of the similar `UIView` methods. Be sure 
 *          to set constraints or autoresizing masks properly so that the view behaves as expected.
 *      If you only need to implement an audio player, you can skip this step.
 *    - Call one of the play methods to start playing your media
 *
 *  You should now have a working implementation able to play audios or videos. There is no way to pause playback or to 
 *  seek within the media, though. The `SRGMediaPlayer` library provides a few standard controls and overlays with which 
 *  you can easily add such functionalities to your custom player.
 *
 *  ## Controls and overlays
 *
 *  The `SRGMediaPlayer` library provides the following set of controls which can be easily connected to a media player
 *  controller instance to report its status or manage playback.
 *
 *  - Buttons:
 *    - `SRGPlaybackButton`: A button to pause or resume playback
 *    - `SRGPictureInPictureButton`: A button to enter or leave picture in picture playback
 *  - Sliders:
 *    - `SRGTimeSlider`: A slide to see the current playback progress, seek, and display the elapsed and remaining times
 *    - `SRGTimelineSlider`: Similar to the time slider, but with the ability to display specific points of interests
 *                           along its track
 *    - `SRGVolumeView`: A slider to adjust the volume
 *  - Miscellaneous:
 *    - `SRGPlaybackActivityIndicatorView`: An activity indicator displayed when the playing is buffering or seeking
 *    - `SRGAirplayView`: An overlay which is visible when external Airplay playback is active, and which displays the
 *                        current route
 *    - `SRGTimelineView`: A linear collection to display the segments associated with a media
 *
 *  Customizing your player layout using these overlays is straightforward:
 *    - Drop instances of the views onto your player layout you need (or instantiate them in code) and tweak their
 *      appearance
 *    - Set their `mediaPlayerController` property to point at the underlying controller. If your controller was
 *      instantiated in a storyboard or a xib file, this can be entirely done in Interface Builder via ctrl-dragging
 *
 *  Usually, you want to hide overlays after some user inactivity delay. While showing or hiding overlays is something
 *  your implementation is responsible of, the `SRGMediaPlayer` library provides the `SRGActivityGestureRecognizer`
 *  class to easily detect any kind of user activity. Just add this gesture recognizer on the view where you want
 *  to track its activity, and associate a corresponding action to show or hide the interface, as you need.
 *
 *  ## Player lifecycle
 *
 *  `SRGMediaPlayerController` is based around `AVPlayer`, which is publicly exposed as a `player` property. You should
 *  avoid controlling playback by acting on this `AVPlayer` instance directly, but you can still use it for any other
 *  purpose:
 *    - Information extraction (e.g. current `AVPlayerItem`, subtitle and audio channels)
 *    - Key-value observation of some other changes you might be interested in (e.g. IceCast / SHOUTcast information)
 *    - Airplay setup
 *    - Muting the player
 *    - etc.
 *
 *  Since the lifecycle of the `AVPlayer` instance is managed by `SRGMediaPlayerController`, specific customization
 *  points have been exposed. Those take the form of optional blocks to which the player is provided as parameter:
 *    - `playerCreationBlock`: This block is called right after player creation
 *    - `playerDestructionBlock`: This block is called right before player destruction
 *    - `playerConfigurationBlock`: This block is called right after player creation, and each time you call the
 *                                  `-reloadPlayerConfiguration` method
 *
 *  ## Player events
 *
 *  The player emits notifications when important changes are detected:
 *    - Playback state changes and errors. Errors are defined in the `SRGMediaPlayerError.h` header file
 *    - Segment changes and blocked segment skipping
 *  For more information about the available notifications, have a look at the `SRGMediaPlayerConstants.h` header file.
 *
 *  Some controller properties (e.g. the `playbackState` property) are key-value observable. If not stated explicitly,
 *  KVO might be possible but is not guaranteed.
 *
 *  ## Segments
 *
 *  When playing a media, an optional `segments` parameter can be provided. This parameter must be an array of objects
 *  conforming to the `SRGSegment` protocol. When segments have been supplied to the player, corresponding notifications
 *  will be emitted when segment transitions occur (see above). If you want to display segments, you can use the supplied
 *  `SRGTimelineView` or create your own view, as required by your application.
 *
 *  ## Boundary time and periodic time observers
 *
 *  Three kinds of observers can be set on a player to observe its playback:
 *    - Usual boundary time and periodic time observers, which you define on the `AVPlayer` instance directly by accessing
 *      the `player` property directly. You should use the player creation and destruction blocks to install and remove
 *      them reliably.
 *    - `AVPlayer` periodic time observers only trigger when the player actually plays. In some cases, you still want to
 *      perform periodic updates even when playback is paused (e.g. updating the user interface while a DVR stream is paused).
 *      For such use cases, `SRGMediaPlayerController` provides the `-addPeriodicTimeObserverForInterval:queue:usingBlock:`
 *      method, with which such observers can be defined. Since such observers are bound to the controller, you can set
 *      them up right after controller creation, if you like
 *  For more information about `AVPlayer` observers, please refer to the official Apple documentation.
 */
@interface SRGMediaPlayerController : NSObject

/**
 *  @name Settings
 */

/**
 *  The minimum window length which must be available for a stream to be considered to be a DVR stream, in seconds. The
 *  default value is 0. This setting can be used so that streams detected as DVR ones because their window is small can
 *  properly behave as live streams. This is useful to avoid usual related seeking issues, or slider hiccups during 
 *  playback, most notably
 */
@property (nonatomic) NSTimeInterval minimumDVRWindowLength;

/**
 *  Return the tolerance (in seconds) for a DVR stream to be considered being played in live conditions. If the stream
 *  playhead is located within the last `liveTolerance` seconds of the stream, it is considered to be live. The default 
 *  value is 30 seconds and matches the standard iOS player controller behavior
 */
@property (nonatomic) NSTimeInterval liveTolerance;

/**
 *  @name Player
 */

/**
 *  The instance of the player. You should not control playback directly on this instance, otherwise the behavior is undefined.
 *  You can still use if for any other purposes, e.g. getting information about the player, setting observers, etc. If you need
 *  to alter properties of the player, you should use the lifecycle blocks hooks instead (see below)
 */
@property (nonatomic, readonly, nullable) AVPlayer *player;

/**
 *  The layer used by the player. Use it if you need to change the content gravity or to detect when the player is ready
 *  for display
 */
@property (nonatomic, readonly) AVPlayerLayer *playerLayer;

/**
 *  The view where the player displays its content. Either install in your own view hierarchy, or bind a corresponding view
 *  with the `SRGMediaPlayerView` class in Interface Builder
 */
@property (nonatomic, readonly, nullable) IBOutlet SRGMediaPlayerView *view;

/**
 *  @name Player lifecycle
 */

/**
 *  Optional block which gets called right after player creation
 */
@property (nonatomic, copy, nullable) void (^playerCreationBlock)(AVPlayer *player);

/**
 *  Optional block which gets called right after player creation and when the configuration is reloaded by calling
 *  `-reloadPlayerConfiguration`
 */
@property (nonatomic, copy, nullable) void (^playerConfigurationBlock)(AVPlayer *player);

/**
 *  Optional block which gets called right before player destruction
 */
@property (nonatomic, copy, nullable) void (^playerDestructionBlock)(AVPlayer *player);

/**
 *  Ask the player to reload its configuration
 */
- (void)reloadPlayerConfiguration;

/**
 *  @name Playback
 */

/**
 *  Prepare to play the media, starting from the specified time, but with the player paused. If you want playback to start
 *  when it is ready, call `-play` from the completion handler. Segments can be optionally provided
 *
 *  @param URL               The URL to play
 *  @param startTime         The time to start at. Use kCMTimeZero to start at the default location:
 *                             - For on-demand streams: At the beginning
 *                             - For live and DVR streams: In live conditions, i.e. at the end of the stream
 *                           If the time is invalid it will be set to kCMTimeZero. Setting a start time outside the
 *                           actual media time range will seek to the nearest location (either zero or the end time)
 *  @param segments          A segment list
 *  @param completionHandler The completion block to be called after the player has finished preparing the media. This
 *                           block will only be called if the media could be loaded. If finished is set to YES, the media
 *                           could seek to its start location (@see `startTime` discussion above)
 */
- (void)prepareToPlayURL:(NSURL *)URL atTime:(CMTime)startTime withSegments:(nullable NSArray<id<SRGSegment>> *)segments completionHandler:(nullable void (^)(BOOL finished))completionHandler;

/**
 *  Attempt to make the player play
 *
 *  @discussion Calling this method does not guarantee that the player will be playing right afterwards. If the media
 *              is ready, it should, but otherwise nothing will happen. Always rely on real `playbackState` changes
 *              to adjust your interface appropriately
 */
- (void)play;

/**
 *  Attempt to pause the player. The media should be playing first, otherwise nothing will happen
 *
 *  @discussion See `-play`
 */
- (void)pause;

/**
 * Attempt to toggle the state of the player
 *
 *  @discussion See `-play`
 */
- (void)togglePlayPause;

/**
 *  Prepare to play the media, starting from the specified time, but with the player paused. If you want playback to start
 *  when it is ready, call `-play` from the completion handler.
 *  
 *  For a discussion of the available parameters, @see `-prepareToPlayURL:atTime:withSegments:completionHandler:`
 */
- (void)prepareToPlayURL:(NSURL *)URL atTime:(CMTime)startTime withCompletionHandler:(nullable void (^)(BOOL finished))completionHandler;

/**
 *  Play a media, starting from the specified time. Segments can be optionally provided
 *
 *  For a discussion of the available parameters, @see `-prepareToPlayURL:atTime:withSegments:completionHandler:`
 */
- (void)playURL:(NSURL *)URL atTime:(CMTime)time withSegments:(nullable NSArray<id<SRGSegment>> *)segments;

/**
 *  Play a media, starting from the specified time
 *
 *  For a discussion of the available parameters, @see `-prepareToPlayURL:atTime:withSegments:completionHandler:`
 */
- (void)playURL:(NSURL *)URL atTime:(CMTime)time;

/**
 *  Play a media. Segments can be optionally provided
 *
 *  For a discussion of the available parameters, @see `-prepareToPlayURL:atTime:withSegments:completionHandler:`
 */
- (void)playURL:(NSURL *)URL withSegments:(nullable NSArray<id<SRGSegment>> *)segments;

/**
 *  Play a media
 */
- (void)playURL:(NSURL *)URL;

// TODO: Describe behavior when paused / playing, and write associated tests
- (void)seekToTime:(CMTime)time withCompletionHandler:(nullable void (^)(BOOL finished))completionHandler;
- (void)seekToSegment:(id<SRGSegment>)segment withCompletionHandler:(nullable void (^)(BOOL finished))completionHandler;;

- (void)reset;

/**
 *  @name Playback information
 */

// KVO observable
@property (nonatomic, readonly) SRGPlaybackState playbackState;

@property (nonatomic, readonly, nullable) NSURL *contentURL;
@property (nonatomic, readonly) NSArray<id<SRGSegment>> *segments;

/**
 *  The current media time range (might be empty or indefinite). Use `CMTimeRange` macros for checking time ranges
 */
@property (nonatomic, readonly) CMTimeRange timeRange;

/**
 *  The media type (audio / video). See `SRGMediaType` for possible values
 *
 *  Warning: Is currently unreliable when Airplay playback has been started before the media is played
 *           Related to https://openradar.appspot.com/27079167
 */
@property (nonatomic, readonly) SRGMediaType mediaType;

/**
 *  The stream type (live / DVR / VOD). See `SRGMediaStreamType` for possible values
 *
 *  Warning: Is currently unreliable when Airplay playback has been started before the media is played
 *           Related to https://openradar.appspot.com/27079167
 */
@property (nonatomic, readonly) SRGMediaStreamType streamType;

/**
 *  Return YES iff the stream is currently played in live conditions
 */
@property (nonatomic, readonly, getter=isLive) BOOL live;

/**
 *  Return the segment currently being played, nil if none
 */
@property (nonatomic, readonly, nullable) id<SRGSegment> currentSegment;

/**
 *  --------------------
 *  @name Time observers
 *  --------------------
 */

/**
 *  Register a block for periodical execution. Unlike usual `AVPlayer` time observers, such observers not only run during playback, but
 *  also when paused. This makes such observers very helpful when UI must be updated continously, even when playback is paused, e.g.
 *  in the case of DVR streams
 *
 *  @param interval Time interval between block executions
 *  @param queue    The serial queue onto which block should be enqueued (main queue if NULL)
 *  @param block	The block to be periodically executed
 *
 *  @discussion There is no need to KVO-observe the presence or not of the `AVPlayer` instance before registration. You can register
 *              time observers earlier if needed
 *
 *  @return The time observer. The observer is retained by the media player controller, you can store a weak reference
 *          to it and remove it at a later time if needed
 */
- (id)addPeriodicTimeObserverForInterval:(CMTime)interval queue:(nullable dispatch_queue_t)queue usingBlock:(void (^)(CMTime time))block;

/**
 *  Remove a time observer (does nothing if the observer is not registered)
 *
 *  @param observer The time observer to remove
 */
- (void)removePeriodicTimeObserver:(id)observer;

@end

/**
 *  Picture in picture functionality (not available on all devices)
 *
 *  Remark: When the application is sent to the background, the behavior is the same as the vanilla picture in picture
 *          controller: If the managed player layer is the one of a view controller's root view ('full screen'), picture
 *          in picture is automatically enabled when switching to the background (provided the corresponding flag has been
 *          enabled in the system settings). This is the only case where switching to picture in picture can be made
 *          automatically. Picture in picture must otherwise always be user-triggered, otherwise you application might
 *          get rejected by Apple (see `AVPictureInPictureController` documentation)
 */
@interface SRGMediaPlayerController (PictureInPicture)

/**
 *  Return the picture in picture controller if available, nil otherwise
 */
@property (nonatomic, readonly, nullable) AVPictureInPictureController *pictureInPictureController;

@end

NS_ASSUME_NONNULL_END