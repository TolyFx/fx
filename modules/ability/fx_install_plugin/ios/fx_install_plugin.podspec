#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'fx_install_plugin'
  s.version          = '2.1.1'
  s.summary          = 'Install APK files on Android and open App Store URLs on iOS.'
  s.description      = <<-DESC
Install APK files on Android and open App Store URLs on iOS.
                       DESC
  s.homepage         = 'https://github.com/hui-z/flutter_install_plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Install Plugin' => '1981462002@qq.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'
end
