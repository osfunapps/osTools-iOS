#
# Be sure to run `pod lib lint OsTools.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OsTools'
  s.version          = '1.7.0'
  s.summary          = 'a bunch of tools for iOS/OSX development'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
"this module contains fundamental tools and extensions to implement in an iOS/OSX project."
                       DESC
  s.swift_versions = "5.0"
  s.homepage         = 'https://github.com/osfunapps/osTools-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'osfunapps' => 'osfunapps@gmail.com' }
  s.source           = { :git => 'https://github.com/osfunapps/osTools-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

#  s.source_files  = 'Classes/*.{h,m,swift}'
    s.source_files = 'Classes/**/*'
    
  # s.resource_bundles = {
  #   'OsTools' => ['OsTools/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

