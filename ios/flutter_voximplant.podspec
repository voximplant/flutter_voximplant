#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_voximplant'
  s.version          = '2.1.2'
  s.summary          = 'Voximplant Flutter SDK'
  s.description      = <<-DESC
Voximplant plugin for embedding voice and video communication into Flutter applications.
                       DESC
  s.homepage         = 'https://voximplant.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Zingaya Inc.' => 'mobiledev@zingaya.com'}
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'VoxImplantSDK', '2.30.0'

  s.ios.deployment_target = '9.0'
end
