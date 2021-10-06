## Preparation

Create and merge a release PR with following changes:

1. Update `MARKETING_VERSION` in `pusher/pusher.xcodeproj/project.pbxproj`
1. Add a new version entry in `CHANGELOG.md`

## Deploy

### Using CI

Git tag the release commit with the format `[0-9].[0-9]+.[0-9]+` (i.e. the same `MARKETING_VERSION` value in your release PR) to kickoff a Github Actions workflow to create a release page with a build and release notes (taken from `CHANGELOG.md`).

* [GitHub Actions](https://github.com/rakutentech/macos-push-tester/actions) which will create a 
* [Latest release page](https://github.com/rakutentech/macos-push-tester/releases/latest)
* [Latest direct download link](https://github.com/rakutentech/macos-push-tester/releases/latest/download/PushTester.zip)