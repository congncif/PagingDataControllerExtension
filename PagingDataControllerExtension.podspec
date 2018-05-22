#
# Be sure to run `pod lib lint PagingDataControllerExtension.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PagingDataControllerExtension'
  s.version          = '1.1.0'
  s.summary          = 'This is Extensions help you to implement PagingDataController'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Install PagingDataControllerExtension and setupScrollViewForPaging -> All done.
                       DESC

  s.homepage         = 'https://github.com/congncif/PagingDataControllerExtension'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NGUYEN CHI CONG' => 'congnc.if@gmail.com' }
  s.source           = { :git => 'https://github.com/congncif/PagingDataControllerExtension.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/congncif'

  s.ios.deployment_target = '8.0'

  s.source_files = 'PagingDataControllerExtension/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PagingDataControllerExtension' => ['PagingDataControllerExtension/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

s.dependency 'PagingDataController'
s.dependency 'SiFUtilities'
s.dependency 'SVPullToRefresh'

end
