workspace "pusher.xcworkspace"
project "pusher/pusher"
use_frameworks!
platform :macos, "10.13"

target 'pusher' do
    pod 'APNS', :path => 'APNS/', :testspecs => ['APNSTests']
    pod 'FCM', :path => 'FCM/'
    pod 'PusherMainView', :path => 'PusherMainView/', :testspecs => ['PusherMainViewTests']
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['MACOSX_DEPLOYMENT_TARGET'].to_f < 10.11
        config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.11'
      end
    end
  end
end
