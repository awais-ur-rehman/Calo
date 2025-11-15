# Calo - Phase 1 Implementation Setup Guide

## Overview
Phase 1 implementation is complete with MVVM architecture. This guide will help you complete the Xcode project setup.

## Files Created

### Models/Entities
- `FoodItem.swift` - Main food item model
- `FoodPrediction.swift` - ML prediction results
- `NutritionInfo.swift` - Nutrition data structure

### Services
**Data Services:**
- `JSONLoader.swift` - Loads JSON files from bundle
- `FoodDataService.swift` - Manages food data and nutrition info

**ML Services:**
- `FoodClassifierService.swift` - CoreML model integration
- `ImagePreprocessor.swift` - Image preprocessing for ML model

**Camera Services:**
- `CameraService.swift` - Camera capture functionality
- `PermissionManager.swift` - Camera permission handling

### ViewModels
- `HomeViewModel.swift` - Home screen logic
- `CameraViewModel.swift` - Camera and prediction logic
- `FoodDetailViewModel.swift` - Food detail screen logic

### Views
**Screens:**
- `HomeView.swift` - Main screen with food list
- `CameraView.swift` - Camera interface
- `FoodDetailView.swift` - Food details and nutrition

**Components:**
- `FoodCardView.swift` - Food item card
- `CameraOverlayView.swift` - Camera capture overlay
- `PredictionResultView.swift` - Prediction results display

### Utilities
- `Errors.swift` - Custom error types
- `Constants.swift` - App constants
- `Extensions.swift` - Helper extensions

## Xcode Setup Steps

### 1. Add JSON Files to Project Bundle
The JSON files are already in the correct location: `Calo/Models/Data/`
1. In Xcode, right-click on the `Calo/Models/Data` folder
2. Select "Add Files to Calo..."
3. Navigate to `Calo/Models/Data/` and select:
   - `class_names.json`
   - `calorie_database.json`
4. **Important:** Check "Copy items if needed" and ensure "Add to targets: Calo" is selected

### 2. Add CoreML Model to Project
The CoreML model is already in the correct location: `Calo/Models/CoreML/`
1. In Xcode, right-click on the `Calo/Models/CoreML` folder
2. Select "Add Files to Calo..."
3. Navigate to `Calo/Models/CoreML/` and select:
   - `mobilenetv2_food101-v1.2.mlpackage`
4. **Important:** Check "Copy items if needed" and ensure "Add to targets: Calo" is selected
5. Verify the model appears in the project navigator

### 3. Verify Info.plist
The `Info.plist` file has been created with camera permissions. If Xcode doesn't recognize it:
1. Select the project in the navigator
2. Select the "Calo" target
3. Go to "Info" tab
4. Add key: `NSCameraUsageDescription`
5. Set value: `We need camera access to scan and identify food items for calorie tracking.`

### 4. Build Settings Check
Ensure minimum iOS version is set to 15.0:
1. Select project → Target "Calo"
2. Go to "General" tab
3. Set "iOS Deployment Target" to 15.0

## Project Structure

```
Calo/
├── Models/
│   ├── CoreML/
│   │   └── mobilenetv2_food101-v1.2.mlpackage/
│   ├── Data/
│   │   ├── class_names.json
│   │   └── calorie_database.json
│   └── Entities/
│       ├── FoodItem.swift
│       ├── FoodPrediction.swift
│       └── NutritionInfo.swift
├── Services/
│   ├── Data/
│   │   ├── JSONLoader.swift
│   │   └── FoodDataService.swift
│   ├── ML/
│   │   ├── FoodClassifierService.swift
│   │   └── ImagePreprocessor.swift
│   └── Camera/
│       ├── CameraService.swift
│       └── PermissionManager.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── CameraViewModel.swift
│   └── FoodDetailViewModel.swift
├── Views/
│   ├── Screens/
│   │   ├── HomeView.swift
│   │   ├── CameraView.swift
│   │   └── FoodDetailView.swift
│   └── Components/
│       ├── FoodCardView.swift
│       ├── CameraOverlayView.swift
│       └── PredictionResultView.swift
├── Utilities/
│   ├── Errors.swift
│   ├── Constants.swift
│   └── Extensions.swift
├── CaloApp.swift
└── Info.plist
```

## Features Implemented

✅ Camera integration with permission handling
✅ CoreML model loading and prediction
✅ JSON data loading (class names and calorie database)
✅ Home screen with food list
✅ Camera view with live preview
✅ Food prediction with top 5 results
✅ Food detail view with adjustable serving size
✅ MVVM architecture throughout
✅ Error handling
✅ Loading states

## Testing Checklist

- [ ] App launches without errors
- [ ] Camera permission is requested on first launch
- [ ] Camera preview displays correctly
- [ ] Photo capture works
- [ ] ML prediction runs successfully
- [ ] Predictions display correctly
- [ ] Food items can be added to home screen
- [ ] Food detail view shows correct nutrition info
- [ ] Serving size adjustment works
- [ ] JSON files load correctly
- [ ] CoreML model loads successfully

## Notes

- The app initializes data services and ML model on launch
- Mock data is used initially for home screen
- All services use singleton pattern for shared state
- Camera session management is handled automatically
- Error states are displayed to users with helpful messages

## Next Steps (Phase 2)

- Authentication flow
- Backend integration
- User data persistence
- Food history sync

