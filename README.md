# TravnexSDK

TravnexSDK enables seamless integration of voice chat and tour guide features into your iOS applications. This guide will help you set up and integrate the SDK into your project.

## Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5.0+

## Installation

### Swift Package Manager

Add TravnexSDK to your project through Xcode:
1. File → Add Package Dependencies
2. Enter the package URL: `https://github.com/trav-nex/TravnexSDK_Preview.git`
3. Select "Up to Next Major Version" with "4.4.0"

### CocoaPods

Add this to your Podfile:

```ruby
target 'YourApp' do
  use_frameworks!
  
  use_frameworks! :linkage => :static
  
  pod 'TravnexSDK'
end
```

## Required Permissions and Privacy

### Info.plist Keys

Add the following keys to your app's Info.plist:

```xml
<!-- Microphone -->
<key>NSMicrophoneUsageDescription</key>
<string>TravnexSDK needs access to your microphone for voice chat functionality.</string>

<!-- Location Services -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>TravnexSDK needs access to your location to provide tour guide features.</string>
```

### Privacy Manifest File

The SDK requires a privacy manifest file to declare API usage. Follow these steps:

1. Create a privacy manifest in your app project:
   - File → New File
   - Select "Resource" section
   - Choose "App Privacy File" type
   - Name it `PrivacyInfo.xcprivacy`
   - Select your target
   - Click Create

2. Add the following content to your `PrivacyInfo.xcprivacy`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>NSPrivacyTracking</key>
        <false/>
        <key>NSPrivacyCollectedDataTypes</key>
        <array/>
        <key>NSPrivacyAccessedAPITypes</key>
        <array>
            <dict>
                <key>NSPrivacyAccessedAPIType</key>
                <string>NSPrivacyAccessedAPICategorySystemBootTime</string>
                <key>NSPrivacyAccessedAPITypeReasons</key>
                <array>
                    <string>35F9.1</string>
                </array>
            </dict>
            <dict>
                <key>NSPrivacyAccessedAPIType</key>
                <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
                <key>NSPrivacyAccessedAPITypeReasons</key>
                <array>
                    <string>DDA9.1</string>
                </array>
            </dict>
            <dict>
                <key>NSPrivacyAccessedAPIType</key>
                <string>NSPrivacyAccessedAPICategoryDiskSpace</string>
                <key>NSPrivacyAccessedAPITypeReasons</key>
                <array>
                    <string>E174.1</string>
                </array>
            </dict>
        </array>
    </dict>
</plist>
```

This privacy manifest file declares the following API usage:
- System Boot Time Access
- File Timestamp Access
- Disk Space Access

These permissions are required for proper SDK functionality and voice chat features.

## Required Capabilities

Add the following capabilities to your Xcode project:
1. Background Modes:
   - Audio, AirPlay, and Picture in Picture
   - Background fetch
   - Background processing
   - Voice over IP

To enable these capabilities:
1. Select your target in Xcode
2. Go to "Signing & Capabilities"
3. Click "+" and add "Background Modes"
4. Enable the required background modes

## Integration

### Basic Setup

```swift
import UIKit
import TravnexSDK

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure SDK
        let config = Travnex.Configuration(
            apiKey: "YOUR_API_KEY",  // Obtain from Travnex
            serviceUrl: "YOUR_SERVICE_URL"  // Obtain from Travnex
        )
        
        // Initialize SDK
        Travnex.shared.initialize(with: config)
        
        // Add Travnex button to your view
        Travnex.shared.addTravnexButton(
            to: view,
            userId: "USER_ID",
            tourId: TOUR_ID
        )
    }
}
```

### Configuration Parameters

- `apiKey`: Your unique API key (obtain from Travnex)
- `serviceUrl`: Your service URL (obtain from Travnex)
- `userId`: Unique identifier for the current user
- `tourId`: Identifier for the specific tour

## Background Modes Configuration

### Audio Session

The SDK automatically configures the audio session for optimal voice chat performance. No additional configuration is required.

### Background Processing

The SDK handles background processing for continuous operation. Ensure you've enabled the required background modes in your app's capabilities.

## Troubleshooting

Common issues and solutions:

1. **Microphone Access Denied**
   - Ensure microphone permission is properly configured in Info.plist
   - Guide users to enable microphone access in device Settings

2. **Location Services Unavailable**
   - Verify location permission is configured in Info.plist
   - Check if location services are enabled on the device

3. **Background Processing Issues**
   - Confirm all required background modes are enabled
   - Verify app is properly signed with required capabilities

## Best Practices

1. **Initialization**
   - Initialize the SDK as early as possible in your app lifecycle
   - Preferably in `application(_:didFinishLaunchingWithOptions:)`

2. **Resource Management**
   - The SDK automatically manages system resources
   - No manual cleanup is required

3. **Error Handling**
   - Implement proper error handling for SDK operations
   - Monitor SDK status through provided delegates

## Example Implementation

```swift
import UIKit
import TravnexSDK

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure SDK early in app lifecycle
        let config = Travnex.Configuration(
            apiKey: "YOUR_API_KEY",
            serviceUrl: "YOUR_SERVICE_URL"
        )
        Travnex.shared.initialize(with: config)
        return true
    }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Travnex button when view loads
        Travnex.shared.addTravnexButton(
            to: view,
            userId: "USER_ID",
            tourId: TOUR_ID
        )
    }
}
```

## Support

For support, please contact:
- Email: support@travnex.com
- Website: https://travnex.com/support
- Documentation: https://docs.travnex.com

## License

TravnexSDK is available under a commercial license. Contact Travnex for licensing information.

---

© 2024 Travnex. All rights reserved.
