Pod::Spec.new do |spec|
  spec.name         = 'APNS'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.authors      = 'Rakuten Ecosystem Mobile'
  spec.summary      = 'APNS Framework for macOS'
  spec.source_files = 'APNS/*.swift'
  spec.framework    = 'Cocoa'
  spec.dependency 'CupertinoJWT'
  spec.homepage     = 'https://github.com/rakutentech/macos-push-tester'
  spec.source       = { :git => 'https://github.com/rakutentech/macos-push-tester.git' }
  spec.osx.deployment_target  = '10.14'
  spec.test_spec 'APNSTests' do |test_spec|
    test_spec.source_files = 'APNSTests/*.swift'
  end
end
