platform :ios, '14.0'

inhibit_all_warnings!

target 'vexl' do

    use_frameworks!

    # Cleevio Framework // This is not a vendor lock. If you need access to this framework, contact Cleevio and you will get accesss to this repo
    # Uncoment following lines when we opensource Cleevio Framework
#    if File.exist?("../CleevioFramework-ios")
        pod 'Cleevio', :path => "./CleevioFramework-ios"
#    else
#        pod 'Cleevio', :git => 'git@gitlab.cleevio.cz:cleevio-dev-ios/CleevioFramework-ios.git'
#    end

    pod 'ACKLocalization'

    # Strong typing
    pod 'R.swift', '~> 6.1.0'

    # Swift syntax control
    pod 'SwiftLint'

    # Dependency Injection
    pod 'Swinject'

    # Keychain
    pod 'KeychainAccess'

    # Networking
    pod 'Alamofire'
    pod 'AlamofireNetworkActivityIndicator'
    pod 'AlamofireNetworkActivityLogger', configuration: ['Debug', 'Devel']
    pod 'Kingfisher'

 
    # Firebase
    pod 'Firebase/Core'
    pod 'Firebase/Crashlytics'
    pod 'Firebase/DynamicLinks'
    pod 'FirebaseRemoteConfig'

    # Logging
    pod 'SwiftyBeaver'

    # UI
    pod 'SnapKit'
    pod 'PhoneNumberKit', '~> 3.3'

    # Facebook
#    pod 'FBSDKCoreKit', '~> 13.1'
#    pod 'FBSDKLoginKit', '~> 13.1'

    # Charts
    pod 'SwiftUICharts', :git => 'https://github.com/willdale/SwiftUICharts.git', :tag => '2.9.9'

    pod 'Firebase/Messaging'

    pod 'lottie-ios'

    target 'vexlTests' do
    end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'RxSwift'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
                end
            end
        end

        target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 13.0
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end

    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
