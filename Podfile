# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "13.0"
    end
  end
end

target 'WDLive' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WDLive
  
  pod 'SnapKit'
  pod 'Alamofire'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'SwiftLint', '= 0.46.3'
  pod 'HaishinKit', '~> 1.9'

end
