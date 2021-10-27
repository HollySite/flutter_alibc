#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_alibc.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_alibc'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'

  s.dependency 'Flutter'
  #基础电商SDK依赖
  s.dependency 'mtopSDK', '3.0.0.5'
  s.dependency 'securityGuard', '5.4.191'
  s.dependency 'BCUserTrack', '7.2.0.6-BC'
  s.dependency 'AliAuthSDK', '1.1.0.39-bc'
  s.dependency 'AliLinkPartnerSDK', '4.0.0.24-wk'
  s.dependency 'MunionBcAdSDK', '1.0.5'
  #电商套件依赖
  s.dependency 'WindVane', '8.5.0.46-bc11'
  s.dependency 'WindMix', '1.0.0.5'
  s.dependency 'Ariver', '1.0.11.2-BC1'
  s.dependency 'Triver', '1.0.11.5-BC4'
  s.dependency 'Windmill', '1.3.7.3-BC1'
  s.dependency 'AlibcTradeUltimateSDK', '4.9.2.6'
  s.dependency 'TBMediaPlayer', '2.0.7.37'
  s.dependency 'miniAppMediaSDK', '0.0.1.45-BC'
  
  s.dependency 'FMDB', '~> 2.7.5'
  s.dependency 'Reachability'
  s.dependency 'SocketRocket'
  s.dependency 'SSZipArchive'
  s.dependency 'SDWebImage'
  s.platform = :ios, '10.0'

  s.frameworks = "CoreTelephony","CoreMotion","UIKit","Foundation"
  s.libraries = "z","c++","sqlite3.0"
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
