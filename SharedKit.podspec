Pod::Spec.new do |s|
 s.name = 'SharedKit'
 s.version = '0.7.1'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'AarKay is a language independent code generation framework.'
 s.homepage = 'https://aarkay.xyz'
 s.social_media_url = 'https://twitter.com/rahulkatariya91'
 s.authors = { "Rahul Katariya" => "rahulkatariya@me.com" }
 s.source = { :git => "https://github.com/RahulKatariya/AarKay.git", :tag => "v"+s.version.to_s }
 s.platforms = { :osx => "10.14" }
 s.requires_arc = true
 s.swift_version = '4.2'
 s.cocoapods_version = '>= 1.4.0'
 s.default_subspec = "Core"

 s.subspec "Core" do |ss|
    ss.source_files = "Sources/SharedKit/**/*.swift"
 end

end