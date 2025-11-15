# Camera Flow Documentation

## Current Flow (Issues)
1. Home → Camera (Sheet overlay)
2. Take photo → ProcessingView (Sheet overlay on top)
3. Results show in overlay
4. Cancel/Add → Dismiss sheets

**Problems:**
- Overlay-based navigation is confusing
- Image capture onChange not triggering properly
- State management issues with sheets

## Desired Flow

### Screen 1: Home Screen
- Shows list of scanned food items (or empty state)
- Camera button at bottom
- **Action:** Tap camera button → Navigate to Camera Preview (push navigation)

### Screen 2: Camera Preview Screen
- Full screen camera preview
- Shutter button at bottom
- Back button at top (navigates back to Home)
- **Action:** Tap shutter → Capture photo → Navigate to Processing Result Screen (push navigation)

### Screen 3: Processing Result Screen
- **Top Section:**
  - Back button (navigates to Home, skipping Camera)
  - Captured image displayed
  
- **Middle Section:**
  - Skeleton loading animation while processing
  - Once results arrive: Show predictions with nutrition info
  
- **Bottom Section:**
  - "Retake" button (always visible after results)
  - **Action:** Tap Retake → Navigate back to Camera Preview Screen
  - **Action:** Tap Back → Navigate to Home Screen

### Navigation Flow Diagram
```
Home Screen
    ↓ (tap camera)
Camera Preview Screen
    ↓ (tap shutter)
Processing Result Screen
    ↓ (tap retake)        ↓ (tap back)
Camera Preview Screen    Home Screen
    ↓ (tap shutter)
Processing Result Screen
    (cycle continues...)
```

## Implementation Plan

### Phase 1: Update Navigation Structure
1. Change HomeView to use NavigationLink instead of sheet for Camera
2. Remove NavigationView from CameraView (will be pushed, not presented)
3. Create new ProcessingResultView as full screen (not sheet)

### Phase 2: Fix Image Capture Flow
1. Update CameraViewModel to properly handle image capture
2. Use NavigationLink with state binding for navigation
3. Pass captured image via navigation

### Phase 3: Create ProcessingResultView
1. New full-screen view with:
   - Image display at top
   - Skeleton loading component
   - Results display
   - Retake button
   - Back button
2. Handle processing state properly
3. Clean state management

### Phase 4: Update CameraView
1. Remove sheet logic
2. Use NavigationLink to ProcessingResultView
3. Pass captured image
4. Handle retake flow

### Phase 5: Clean Up
1. Remove old ProcessingView (or repurpose)
2. Remove sheet-related code
3. Clean up state management
4. Test navigation flow

