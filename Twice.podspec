Pod::Spec.new do |s|
  s.name             = "Twice"
  s.version          = "1.0.0"
  s.summary          = "Task manager"
  s.homepage         = "https://github.com/xmartlabs/Twice"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { "Diego Ernst" => "dernst@xmartlabs.com" }
  s.source           = { git: "https://github.com/xmartlabs/Twice.git", tag: s.version.to_s }
  s.social_media_url = 'http://twitter.com/xmartlabs'
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.ios.source_files = 'Sources/**/*'
end
