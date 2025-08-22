# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'File Locker' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for File Locker
  pod "Bugly"
  pod "SVProgressHUD"
  
  pod "ZipArchive(= '2.4.3')"
  pod "UnrarKit"
  pod 'SSZipArchive'
  pod 'LzmaSDK-ObjC', :inhibit_warnings => true
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        config.build_settings['ENABLE_BITCODE'] = 'NO'
        config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
        config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
        config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
        if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
          xcconfig_path = config.base_configuration_reference.real_path
          IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
        end
      end
    end
  end
end
