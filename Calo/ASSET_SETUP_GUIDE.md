# Asset Setup Guide - Splash Screen

## Step 1: Add Assets Folder Structure in Xcode

1. **Open Xcode** and navigate to your project
2. **Right-click** on the `Calo` folder in the Project Navigator (left sidebar)
3. Select **"New Group"**
4. Name it `Assets`
5. **Right-click** on the newly created `Assets` folder
6. Select **"New Group"** again
7. Name it `Images`

You should now have: `Calo/Assets/Images/`

## Step 2: Add splash-icons.svg File

### Option A: If you have the SVG file locally

1. **Right-click** on the `Assets/Images` folder in Xcode
2. Select **"Add Files to Calo..."**
3. Navigate to your `splash-icons.svg` file
4. **Important Settings:**
   - ✅ Check **"Copy items if needed"**
   - ✅ Select **"Add to targets: Calo"**
   - ⚠️ Make sure **"Create groups"** is selected (not "Create folder references")
5. Click **"Add"**

### Option B: If the SVG is in the project root

1. In Finder, locate `splash-icons.svg` at the project root
2. Drag it into Xcode's `Assets/Images` folder
3. When prompted:
   - ✅ Check **"Copy items if needed"**
   - ✅ Select **"Add to targets: Calo"**
   - Select **"Create groups"**
4. Click **"Finish"**

## Step 3: Verify in Build Phases

1. Select your project in the Project Navigator
2. Select the **"Calo"** target
3. Go to **"Build Phases"** tab
4. Expand **"Copy Bundle Resources"**
5. Verify that `splash-icons.svg` is listed there
6. If it's not there, click the **"+"** button and add it

## Step 4: Verify File Location

The file should be located at:
```
Calo/
└── Assets/
    └── Images/
        └── splash-icons.svg
```

## Troubleshooting

- **If the SVG doesn't show**: Make sure it's added to the target in Build Phases
- **If you get build errors**: Clean the build folder (Product → Clean Build Folder)
- **If the file isn't found**: Check that the file name is exactly `splash-icons.svg` (case-sensitive)

## Current Implementation

The code will automatically:
1. First try to load as an image asset (if added to Assets.xcassets)
2. Then try to load as a bundle file (if added as a file reference)
3. Show a placeholder if neither is found

The splash screen will display for 2.5 seconds, then automatically transition to the HomeView.

