Pod::Spec.new do |s|
  s.name             = "Once"
  s.version          = "1.0.0"
  s.summary          = "A short description of Once."
  s.homepage         = "https://github.com/dernster/Once"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { "Xmartlabs SRL" => "dernst@xmartlabs.com" }
  s.source           = { git: "https://github.com/dernster/Once.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/dernster'
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.ios.source_files = 'Sources/**/*'
  # s.ios.frameworks = 'UIKit', 'Foundation'
  # s.dependency 'Eureka', '~> 1.0'
end
