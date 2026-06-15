#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_voximplant'
  s.version          = '3.17.0'
  s.summary          = 'Voximplant Flutter SDK'
  s.description      = <<-DESC
Voximplant plugin for embedding voice and video communication into Flutter applications.
                       DESC
  s.homepage         = 'https://voximplant.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Zingaya Inc.' => 'mobiledev@zingaya.com'}
  s.source           = { :http => 'https://github.com/voximplant/flutter_voximplant/' }
  s.source_files = 'flutter_voximplant/Sources/flutter_voximplant/**/*.{h,m}'
  s.public_header_files = 'flutter_voximplant/Sources/flutter_voximplant/include/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'VoxImplantSDK', '2.58.0'
  s.ios.deployment_target = '12.0'
end
