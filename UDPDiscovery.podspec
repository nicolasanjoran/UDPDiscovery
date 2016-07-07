Pod::Spec.new do |spec|
  spec.name = "UDPDiscovery"
  spec.version = "1.0.0"
  spec.summary = "An Network Discovery Library based on UDP."
  spec.homepage = "https://github.com/nicolasanjoran/UDPDiscovery"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Nicolas Anjoran" => 'contact@nicolasanjoran.com' }
  spec.social_media_url = "http://twitter.com/radiohacktive"

  spec.platform = :ios, "9.1"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/nicolasanjoran/UDPDiscovery.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "UDPDiscovery/**/*.{h,swift}"

end
