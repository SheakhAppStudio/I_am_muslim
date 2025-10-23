# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'I am Muslim' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for I am Muslim
  pod 'Google-Mobile-Ads-SDK', '~> 11.0'

  target 'I am MuslimTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'I am MuslimUITests' do
    # Pods for testing
  end
end

target 'PrayerTimesWidgetExtension' do
  use_frameworks!
  # Pods for PrayerTimesWidgetExtension
end

target 'I am Muslim Watch App Watch App' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for I am Muslim Watch App Watch App
end

target 'I am Muslim Watch App Watch AppTests' do
  # Pods for testing
end

target 'I am Muslim Watch App Watch AppUITests' do
  # Pods for testing
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
