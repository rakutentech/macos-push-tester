Pod::Spec.new do |spec|
  spec.name         = 'PusherMainView'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'MIT', :file => '../LICENSE' }
  spec.authors      = 'Rakuten Ecosystem Mobile'
  spec.summary      = 'PusherMainView Framework for macOS'
  spec.source_files = 'PusherMainView/*.swift'
  spec.resource_bundles = { 'PusherMainViewResources' => ['PusherMainView/*.strings'] }
  spec.framework    = 'Cocoa'
  spec.dependency 'APNS'
  spec.dependency 'FCM'
  spec.vendored_framework = 'Highlight.framework'
  spec.homepage     = 'https://github.com/rakutentech/macos-push-tester'
  spec.source       = { :git => 'https://github.com/rakutentech/macos-push-tester.git' }
  spec.osx.deployment_target  = '10.13'
  spec.resources = ["PusherMainView/Base.lproj/Pusher.storyboard","PusherMainView/MainPlayground.playground","PusherMainView/pushtypes.plist"]
  spec.test_spec 'PusherMainViewTests' do |test_spec|
    test_spec.source_files = 'PusherMainViewTests/*.swift'
    test_spec.dependency 'Quick'
    test_spec.dependency 'Nimble'
  end
end
