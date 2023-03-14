# The macOS Push Tester app Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

## [1.5.0] - 2023-03-14

### Features
- Add Live Activity support (SDKCF-6014)
- Automatically update the timestamp for live activity (SDKCF-6078)
- Add device token type in the devices browser (SDKCF-6079)

## [1.4.0] - 2022-11-02
- Add support for Android devices (FCM)

## [1.3.0] - 2022-08-04
- Add SwiftLint
- PusherMainView Localization
- Convert PusherStoreTests to BDD
- Handle ⌘S shortcut and the Save Menu Item in the File Menu
- Convert APNSTests to BDD
- Replace print by RLogger.debug in the AppDelegate
- Allow Undo and Redo in NSTextView with ⌘Z
- Handle ⇧⌘S shortcut and the Save as... Menu Item in the File Menu
- Replace pusher by PushTester in Application.xib
- Show an error alert when the user tries to send an invalid JSON file
- Handle ⌘O shortcut and the Open File Menu Item

## [1.2.1] - 2022-02-01
- Fix TooManyProviderTokenUpdates send to device APNS error

## [1.2.0] - 2021-11-16
- Add "Send push to simulator" implementation (SDKCF-4031)
- Add UI for selecting push destination - device or simulator (SDKCF-4030)
- GitHub Actions release on tag
- Use ephemeral URL session configuration and reorder data task error messages

## [1.1.2] - 2021-07-21
- improve: use the StackView in the main screen (SDKCF-3988) => Fix the json text view when there are more than 10 lines
- setup Bitrise CI

## [1.1.1] - 2021-07-07
- Build with Fastlane fix
- Bugfix when deviceTokenTextField.string changes, the state must be updated
- Rename the app

## [1.1.0] - 2021-06-22
- Load a JSON File
- Update README with mention of UDP service
- Update README for iOS 14 info.plist Requirements
- Remove code sign identity so it can be built and run on any mac
- Fastlane must run even if Xcode version is not 10.3
- Pusher Reducer

## [1.0.1] - 2019-12-03
- Introduce newState function
- Memory Leaks fixes + subcribe/unsubscribe functions in PushInteractor class
- Global use of dispatch function from Push Interactor
- Bugfix when the user open the Authorization Token UI
- APNSSecIdentity refactoring and simplication

## [1.0.0] - 2019-11-27
- Project init
