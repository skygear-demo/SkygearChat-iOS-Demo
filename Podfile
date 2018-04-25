# Uncomment the next line to define a global platform for your project

target 'Swift Chat Demo 2' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Swift Chat Demo 2
  pod 'SVProgressHUD', '~> 2.1.0'

  pod 'SKYKit', '~> 1.1'
  pod 'SKYKitChat/UI', '~> 1.2.0-alpha.7'

  pod 'AFDateHelper', '~> 4.2.7'
  pod 'DZNEmptyDataSet'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
    end
  end
end
