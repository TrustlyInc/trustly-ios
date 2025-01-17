#
# Be sure to run `pod lib lint TrustlySDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TrustlySDK-Test'

  s.version          = '3.3.0'

  s.summary          = 'This SDK help the merchants to integrate their solutions with Trustly Widget and LightBox.'
  s.swift_version    = '5.0'

  s.description      = 'This cocoapods provides the ability to integrate your application with Trustly Widget and LightBox.'

  s.homepage         = 'https://github.com/TrustlyInc/trustly-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Trustly' => 'amer.developer.experience@trustly.com' }
  s.source           = { :git => 'https://github.com/TrustlyInc/trustly-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.source_files = 'Sources/TrustlySDK/**/*.swift'

end
