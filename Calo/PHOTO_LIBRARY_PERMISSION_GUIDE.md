# Photo Library Permission Setup Guide

## Step 1: Add Permission to Info.plist

1. **Open Xcode** and select your project in the Project Navigator
2. Select the **"Calo"** target
3. Go to the **"Info"** tab
4. Expand **"Custom iOS Target Properties"**
5. Click the **"+"** button to add a new key
6. Type: `Privacy - Photo Library Usage Description` (or search for it)
7. Set the value to: `"We need access to your photo library to select food images for analysis."`

**Alternative Method (if Info tab doesn't show the key):**
1. Right-click on `Info.plist` in Project Navigator (if visible)
2. Select **"Open As"** → **"Source Code"**
3. Add this before the closing `</dict>` tag:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select food images for analysis.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save food images to your photo library.</string>
```

## Step 2: Verify

The photo library picker will:
- Request permission automatically when the user taps "Gallery"
- Show the native iOS photo picker
- Allow users to select images from their library
- Process selected images the same way as camera captures

## Note

The app uses `PHPickerViewController` which doesn't require explicit permission for iOS 14+, but we've added permission handling for better compatibility and to support saving images if needed in the future.

