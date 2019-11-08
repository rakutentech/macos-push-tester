# Master Cocoapods repository
source "https://github.com/CocoaPods/Specs.git"

workspace "pusher.xcworkspace"
project "pusher/pusher"
use_frameworks!

target 'pusher' do
    pod 'APNS', :path => 'APNS/', :testspecs => ['APNSTests']
    pod 'PusherMainView', :path => 'PusherMainView/', :testspecs => ['PusherMainViewTests']
end
