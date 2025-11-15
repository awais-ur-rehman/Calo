# Font Setup Guide - Space Grotesk

## Step 1: Add Font Files to Xcode

1. **Open Xcode** and navigate to your project
2. **Right-click** on the `Assets` folder in the Project Navigator (left sidebar)
3. Select **"New Group"**
4. Name it `Fonts`
5. **Right-click** on the newly created `Fonts` folder
6. Select **"Add Files to Calo..."**
7. Navigate to `/Users/zain/Downloads/space-grotesk/`
8. Select **ALL 5 font files**:
   - `SpaceGrotesk-Bold.otf`
   - `SpaceGrotesk-Light.otf`
   - `SpaceGrotesk-Medium.otf`
   - `SpaceGrotesk-Regular.otf`
   - `SpaceGrotesk-SemiBold.otf`
9. **Important Settings:**
   - ✅ Check **"Copy items if needed"**
   - ✅ Select **"Add to targets: Calo"**
   - ⚠️ Make sure **"Create groups"** is selected (not "Create folder references")
10. Click **"Add"**

## Step 2: Register Fonts in Info.plist

1. In Xcode, select your project in the Project Navigator
2. Select the **"Calo"** target
3. Go to the **"Info"** tab
4. Expand **"Custom iOS Target Properties"**
5. Click the **"+"** button to add a new key
6. Type: `Fonts provided by application` (or search for it)
7. It should appear as a key with type "Array"
8. Expand the array and add **5 items** (one for each font):
   - Item 0: `SpaceGrotesk-Bold.otf`
   - Item 1: `SpaceGrotesk-Light.otf`
   - Item 2: `SpaceGrotesk-Medium.otf`
   - Item 3: `SpaceGrotesk-Regular.otf`
   - Item 4: `SpaceGrotesk-SemiBold.otf`

**Alternative Method (if Info tab doesn't show the key):**
1. Right-click on `Info.plist` in Project Navigator
2. Select **"Open As"** → **"Source Code"**
3. Add this before the closing `</dict>` tag:
```xml
<key>UIAppFonts</key>
<array>
    <string>SpaceGrotesk-Bold.otf</string>
    <string>SpaceGrotesk-Light.otf</string>
    <string>SpaceGrotesk-Medium.otf</string>
    <string>SpaceGrotesk-Regular.otf</string>
    <string>SpaceGrotesk-SemiBold.otf</string>
</array>
```

## Step 3: Verify in Build Phases

1. Select your project in the Project Navigator
2. Select the **"Calo"** target
3. Go to **"Build Phases"** tab
4. Expand **"Copy Bundle Resources"**
5. Verify that all 5 font files are listed there
6. If any are missing, click the **"+"** button and add them

## Step 4: Verify Font Names

The actual font names in code might be slightly different. To check:
1. Run the app
2. Check the console for any font loading errors
3. The font extension I created will handle the mapping automatically

## Font Mapping

- **Regular** → `SpaceGrotesk-Regular`
- **Light** → `SpaceGrotesk-Light`
- **Medium** → `SpaceGrotesk-Medium`
- **SemiBold** → `SpaceGrotesk-SemiBold`
- **Bold** → `SpaceGrotesk-Bold`

## Usage in Code

After setup, you can use the custom font throughout your app:

```swift
Text("Hello")
    .font(.custom("SpaceGrotesk-Regular", size: 16))

// Or use the extension:
Text("Hello")
    .font(.spaceGrotesk(size: 16, weight: .regular))
```

## Troubleshooting

- **Fonts not loading?** Make sure they're added to the target in Build Phases
- **Font names not found?** Check the actual font names using Font Book app on Mac
- **Build errors?** Clean build folder (Product → Clean Build Folder) and rebuild

