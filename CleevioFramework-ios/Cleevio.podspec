#
# Be sure to run `pod lib lint Cleevio.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Cleevio'
  s.version          = '1.3.4'
  s.summary          = 'Cleevio\'s framework'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://gitlab.cleevio.cz/cleevio-dev-ios/cleevioui-ios-specs'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Cleevio team' => 'hello@cleevio.com' }
  s.source           = { :git => 'https://gitlab.cleevio.cz/cleevio-dev-ios/CleevioFramework-ios.git', :tag => s.version.to_s }

  s.swift_version    = '5.0' 
  s.ios.deployment_target = '14.0'
  s.framework  = "SwiftUI", "Combine"
  s.requires_arc = true
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
  'echo "5.0" > .swift-version'
  
  s.default_subspec = "Full"

  s.subspec "Full" do |full|
    full.source_files = "Cleevio/Classes/**/*.{h,m,swift}"
  end

  s.subspec "Core" do |core|
    core.source_files = "Cleevio/Classes/Core/**/*.{h,m,swift}"
  end

  s.subspec "Routers" do |router|
    router.source_files = "Cleevio/Classes/Routers/**/*.{h,m,swift}"
    router.dependency 'Cleevio/Core'
  end

  s.subspec "UI" do |core|
    core.source_files = "Cleevio/Classes/UI/**/*.{h,m,swift}"
  end
end
