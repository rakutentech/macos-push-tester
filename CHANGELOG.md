# The macOS Push Tester app Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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
