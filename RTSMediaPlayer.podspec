Pod::Spec.new do |s|
  s.name                  = "RTSMediaPlayer"
  s.version               = "0.0.3"
  s.summary               = "Shared media player for RTS mobile apps."
  s.homepage              = "ssh://git@bitbucket.org/rtsmb/rtsmediaplayer-ios.git"
  s.authors               = { "Frédéric Humbert-Droz" => "fred.hd@me.com", "Cédric Luthi" => "cedric.luthi@rts.ch" }

  s.source                = { :git => "ssh://git@bitbucket.org/rtsmb/rtsmediaplayer-ios.git", :branch => "master", :tag => "#{s.version}" }

  s.ios.deployment_target = "7.0"
  s.requires_arc          = true

  s.source_files          = "RTSMediaPlayer"
  s.public_header_files   = "RTSMediaPlayer/*.h"

  s.default_subspec = 'Core'

  ### Subspecs

  s.subspec 'Core' do |co|
	co.source_files         = "RTSMediaPlayer"
	co.public_header_files  = "RTSMediaPlayer/*.h"
	co.frameworks           = "Foundation", "UIKit"
	co.dependency             "CocoaLumberjack",  "~> 2.0.0"
	co.dependency             "TransitionKit", "~> 2.2.0"
	co.dependency             "libextobjc/EXTScope", "0.4.1"
	co.resource_bundle      = { "RTSMediaPlayer" => [ "RTSMediaPlayer/Info.plist", "RTSMediaPlayer/*.xib" ] }
  end

  s.subspec 'MultiPlayers' do |mp|
	mp.source_files         = "RTSMultiChannelPlayer/RTSMultiPlayer.h", "RTSMultiChannelPlayer/Sources/*.{h,m}"
	mp.private_header_files = "SRGIntegrationLayerDataProvider/**/*+Private.h"
	mp.frameworks           = "Foundation", "UIKit"
	mp.dependency             "RTSMediaPlayer/Core"
	mp.dependency             "RTSAnalytics"
	s.resource_bundle       = { "RTSMultiPlayer" => [ "RTSMultiChannelPlayer/**/*.xib", "RTSMultiChannelPlayer/Storyboard/*.storyboard", "RTSMultiChannelPlayer/**/*.png", "RTSMultiChannelPlayer/Resources/*.xcassets", "RTSMultiChannelPlayer/Resources/Info.plist" ] }
  end

end
