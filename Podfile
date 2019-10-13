# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'AvH Plan' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AvH Plan
	pod 'SwiftSoup'
  pod 'SQLite.swift'
  pod 'MagazineLayout'
  pod 'Firebase/Messaging'
  pod 'Firebase/Analytics'
  pod 'Fabric', '~> 1.10.2'
  pod 'Crashlytics', '~> 3.13.4'
  pod 'Toast-Swift', '~> 5.0.0'

  target 'AvH PlanTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'AvH PlanUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  # temporary fix for Xcode 11 not playing well with SwiftSoup
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      next unless target.name == 'SwiftSoup'
      target.build_configurations.each do |config|
        next unless config.name.start_with?('Release')
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
      end
    end
  end

end
