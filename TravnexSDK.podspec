Pod::Spec.new do |spec|
  spec.name         = "TravnexSDK"
  spec.version      = "1.0.0"
  spec.summary      = "TravnexSDK for connecting with Travnex powered service"

  spec.description  = <<-DESC
    TravnexSDK provides a comprehensive solution for integrating with Travnex services.
    
    Key Features:
    * Real-time audio/video communication powered by Agora
    * Location-based services integration
    * Custom UI components and resources
    * iOS 14+ support with modern Swift implementation
    
    For detailed implementation guidelines and examples, visit the documentation
    at https://github.com/trav-nex/TravnexSDK_Preview
  DESC

  spec.homepage     = "https://github.com/trav-nex/TravnexSDK_Preview"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Dominic Thompson" => "onlythompson@gmail.com" }

  # Platform & Version Configuration
  spec.platform              = :ios
  spec.ios.deployment_target = "14.0"
  spec.swift_version        = "5.0"

  # Source Configuration
  spec.source               = {
    :git => "https://github.com/trav-nex/TravnexSDK_Preview.git",
    :tag => "#{spec.version}"
  }
  
  # Framework & Source Files
  spec.vendored_frameworks    = "TravnexSDK.xcframework"
  spec.source_files          = "TravnexSDK/**/*.{h,m,swift}"
  spec.public_header_files   = "TravnexSDK/Public/*.h"
  
  # Resources
  spec.resources = "TravnexSDK/**/*.{png,xib,storyboard,xcassets,strings}"

  # Required Frameworks
  spec.frameworks = ["UIKit", "CoreLocation"]
  
  # Build Configuration
  spec.pod_target_xcconfig = {
    'ENABLE_BITCODE' => 'NO',
    'OTHER_LDFLAGS' => '-ObjC',
    'SWIFT_VERSION' => '5.0'
  }
  
  # Dependencies
  spec.dependency "AgoraRtcEngine_iOS", "~> 4.4.0"  # Explicitly specify minor version
  
  # Additional Configuration
  spec.requires_arc     = true
  spec.static_framework = true
end
