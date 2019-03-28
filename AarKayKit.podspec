Pod::Spec.new do |s|
 s.name = 'AarKayKit'
 s.version = '0.8.2'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'AarKay is a language independent code generation framework.'
 s.homepage = 'https://aarkay.xyz'
 s.social_media_url = 'https://twitter.com/rahulkatariya91'
 s.authors = { "Rahul Katariya" => "rahulkatariya@me.com" }
 s.source = { :git => "https://github.com/RahulKatariya/AarKay.git", :tag => "v"+s.version.to_s }
 s.platforms = { :osx => "10.12" }
 s.requires_arc = true
 s.swift_version = '5.0'
 s.cocoapods_version = '>= 1.4.0'
 s.default_subspec = "Core"

 s.subspec "Core" do |ss|
    ss.source_files = "Sources/AarKayKit/**/*.swift"
    ss.dependency "SharedKit", "~> 0.8.2"
    ss.dependency "StencilSwiftKit", "~> 2.5"
    ss.dependency "Result", "~> 4.0"
    ss.dependency "Yams", "~> 1.0"
 end

end