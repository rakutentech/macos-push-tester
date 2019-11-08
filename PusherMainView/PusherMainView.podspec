Pod::Spec.new do |spec|
  spec.name         = 'PusherMainView'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'MIT', :file => '../LICENSE' }
  spec.authors      = 'Rakuten Ecosystem Mobile'
  spec.summary      = 'PusherMainView Framework for macOS'
  spec.source_files = 'PusherMainView/*.swift'
  spec.framework    = 'Cocoa'
  spec.dependency 'APNS'
  spec.homepage     = 'https://github.com/rakutentech/macos-push-tester'
  spec.source       = { :git => 'https://github.com/rakutentech/macos-push-tester.git' }
  spec.osx.deployment_target  = '10.14'
  spec.resources = ["PusherMainView/Base.lproj/Pusher.storyboard","PusherMainView/MainPlayground.playground"]
end
