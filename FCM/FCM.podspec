Pod::Spec.new do |spec|
  spec.name         = 'FCM'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'MIT', :file => '../LICENSE' }
  spec.authors      = 'Rakuten Ecosystem Mobile'
  spec.summary      = 'FCM Framework for macOS'
  spec.source_files = 'FCM/*.swift'
  spec.framework    = 'Cocoa'
  spec.homepage     = 'https://github.com/rakutentech/macos-push-tester'
  spec.source       = { :git => 'https://github.com/rakutentech/macos-push-tester.git' }
  spec.osx.deployment_target  = '10.13'
end
