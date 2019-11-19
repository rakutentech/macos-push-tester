![Platform](https://img.shields.io/badge/Platform-macOS-black) 
![Compatibility](https://img.shields.io/badge/Compatibility-macOS%20%3E%3D%2010.13-orange) 
![Compatibility](https://img.shields.io/badge/Swift-5.0-orange.svg) 
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg) 

# The macOS Pusher App

The macOS Pusher App allows you to send push notifications through APNS (Apple Push Notification Service) and receive them on a device.

It can also get device tokens from any iPhone on the same wifi network.

**Notice**: This app was created to be used by the SSED SDK team internally. Anyone is free to use it but please be aware that it is unsupported.

## How to build/run from source

- 1) Run `pod install` from root folder
- 2) Open pusher.xcworkspace*
- 3) Build and run

## How to build with Fastlane

### Install fastlane
- 1) Using RubyGems `sudo gem install fastlane -NV`

- 2) Alternatively using Homebrew `brew cask install fastlane`

### Run fastlane
Run `fastlane macos ci`

## UI Preview

![The macOS Pusher App](preview.png)
