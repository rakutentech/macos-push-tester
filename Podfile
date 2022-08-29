workspace "pusher.xcworkspace"
project "pusher/pusher"
use_frameworks!
platform :macos, "10.13"

target 'pusher' do
    pod 'APNS', :path => 'APNS/', :testspecs => ['APNSTests']
    pod 'FCM', :path => 'FCM/'
    pod 'PusherMainView', :path => 'PusherMainView/', :testspecs => ['PusherMainViewTests']
end
