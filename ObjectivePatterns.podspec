#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "ObjectivePatterns"
  s.version          = "0.1.0"
  s.summary          = "Useful design patterns implemented in Objective-C."
  s.homepage         = "http://github.com/ObjectivePatterns"
  s.license          = 'MIT'
  s.author           = { "David Hart" => "david@hart-dev.com" }
  s.source           = { :git => "http://github.com/ObjectivePatterns.git", :tag => s.version.to_s }

  s.requires_arc = true

  s.source_files = 'Classes'

  s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation'
end
