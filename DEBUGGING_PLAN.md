# Flutter Explore Feature Debugging Plan

## Overview
This debugging plan will help you trace the exact point of failure in the Explore feature's search functionality. The codebase has been instrumented with detailed logging to capture every step of the data flow from BLoC events to network calls.

## Prerequisites

### 1. Network Configuration
The Dio client baseUrl has been updated for Android emulator compatibility:

**Current Configuration:**
- **Android Emulator:** `http://10.0.2.2:1444/api` (automatically configured)
- **iOS Simulator/Physical Device:** Change to `http://192.168.1.14:1444/api` if needed

**To change the baseUrl (if needed):**
1. Open `lib/core/constants/api_constants.dart`
2. Modify the `baseUrl` constant:
   ```dart
   // For Android Emulator
   static const String baseUrl = 'http://10.0.2.2:1444/api';
   
   // For iOS Simulator or Physical Device
   static const String baseUrl = 'http://192.168.1.14:1444/api';
   ```

### 2. Backend Server
Ensure your backend server is running on port 1444:
```bash
cd /Users/nha/Project4/BE/Management_Field
# Start your backend server
```

## Debugging Steps

### Step 1: Run the Application with Debug Logging

1. **Start the Flutter app in debug mode:**
   ```bash
   cd /Users/nha/Project4/flutter
   flutter run
   ```

2. **Open the Debug Console** in your IDE (VS Code, Android Studio, etc.) to monitor logs

### Step 2: Trigger the Error

1. **Navigate to the Explore screen** in the app
2. **Trigger the search functionality** by:
   - Allowing location permission when prompted
   - Tapping the "Search nearby fields" button
   - Or any action that triggers `SearchNearbyFields` event

### Step 3: Analyze the Debug Logs

The logs will follow this sequence pattern:

#### 3.1 BLoC Event Logs
Look for these log patterns:
```
[BLOC] Event received: SearchNearbyFields
[BLOC] Current state: ExploreLoaded
[BLOC] Emitting ExploreLoading state
[BLOC] Starting SearchNearbyFields execution...
[BLOC] Current user location: Position(...)
[BLOC] Search radius: 5.0km
[BLOC] Search coordinates: lat=10.8231, lng=106.6297
[BLOC] Calling searchLocationsUseCase...
```

#### 3.2 Data Source Network Logs
Look for these critical logs:
```
[DataSource] Making GET request to: http://10.0.2.2:1444/api/locations/map-search
[DataSource] Query parameters: {latitude: 10.8231, longitude: 106.6297, radius: 5.0}
[DataSource] Response received - Status Code: 200
[DataSource] Response Data: [...]
```

#### 3.3 Error Logs (Most Important)
If there's a network error, look for:
```
[DataSource] DIO ERROR Status Code: 404/500/etc
[DataSource] DIO ERROR Response Data: {"error": "...", "message": "..."}
[DataSource] DIO ERROR Message: Connection refused/Timeout/etc
[DataSource] DIO ERROR Type: DioExceptionType.connectionTimeout
```

### Step 4: Common Error Patterns & Solutions

#### 4.1 Connection Refused
```
[DataSource] DIO ERROR Message: Connection refused
[DataSource] DIO ERROR Type: DioExceptionType.connectionError
```
**Solution:** Backend server is not running or wrong baseUrl

#### 4.2 404 Not Found
```
[DataSource] DIO ERROR Status Code: 404
[DataSource] DIO ERROR Response Data: {"error": "Not Found"}
```
**Solution:** API endpoint doesn't exist or wrong URL path

#### 4.3 500 Internal Server Error
```
[DataSource] DIO ERROR Status Code: 500
[DataSource] DIO ERROR Response Data: {"error": "Internal Server Error", "message": "..."}
```
**Solution:** Backend server error - check backend logs

#### 4.4 Timeout
```
[DataSource] DIO ERROR Type: DioExceptionType.connectionTimeout
```
**Solution:** Network is slow or server is unresponsive

#### 4.5 Data Parsing Error
```
[BLOC] CRITICAL ERROR - Location parsing error: FormatException
[DataSource] ERROR: Unexpected response format: String
```
**Solution:** Backend response format doesn't match expected JSON structure

## Step 5: Copy and Analyze Complete Log Output

1. **Copy the entire debug console output** from when you triggered the search
2. **Look for the sequence:**
   - `[BLOC] Event received: SearchNearbyFields`
   - `[DataSource] Making GET request to: ...`
   - `[DataSource] DIO ERROR ...` (if error occurs)
   - `[BLOC] CRITICAL ERROR ...` (if error propagates)

3. **The most critical log is:**
   ```
   [DataSource] DIO ERROR Response Data: {...}
   ```
   This will reveal the exact error message from the backend.

## Step 6: Report Findings

When reporting the issue, include:
1. **Complete log sequence** from `[BLOC] Event received` to the final error
2. **The specific DIO ERROR Response Data** content
3. **Your development environment** (Android Emulator, iOS Simulator, Physical Device)
4. **Backend server status** (running/not running)

## Additional Debugging Commands

### Check Network Connectivity
```bash
# Test if the backend is reachable
curl http://10.0.2.2:1444/api/locations/map-search?latitude=10.8231&longitude=106.6297&radius=5.0

# Or for physical device/iOS
curl http://192.168.1.14:1444/api/locations/map-search?latitude=10.8231&longitude=106.6297&radius=5.0
```

### Flutter Clean (if needed)
```bash
cd /Users/nha/Project4/flutter
flutter clean
flutter pub get
flutter run
```

## Expected Success Log Pattern

When everything works correctly, you should see:
```
[BLOC] Event received: SearchNearbyFields
[BLOC] Calling searchLocationsUseCase...
[DataSource] Making GET request to: http://10.0.2.2:1444/api/locations/map-search
[DataSource] Response received - Status Code: 200
[DataSource] Response is a List with X items
[DataSource] Successfully converted to X LocationMapModel objects
[BLOC] Search successful! Received X locations
[BLOC] Valid locations after filtering: X
[BLOC] Data processed successfully. Emitting ExploreLoaded with X sorted locations
[BLOC] ExploreLoaded state emitted successfully
```

The absence of any of these logs will pinpoint exactly where the failure occurs.

## ENHANCED REQUEST LOGGING (CRITICAL UPDATE)

### Issue Analysis:
The Flutter app receives empty data `[]` while curl with the same parameters returns full data. This indicates a **request parameter mismatch**.

### New Debugging Steps:

#### Step 1: Enable Enhanced Request Logging
A new Dio logging interceptor has been added to capture the exact request parameters being sent.

#### Step 2: Run Application and Trigger Search
1. Run the Flutter application
2. Navigate to the Explore screen
3. Trigger the search feature (tap search button or enable location)
4. Monitor the debug console

#### Step 3: Analyze Request Logs
Look for the log block that starts with:
```
--- DIO REQUEST ---
--> GET http://10.0.2.2:1444/api/locations/map-search
Headers: {...}
Query Parameters: {latitude: X, longitude: Y, radius: Z}
--> END GET
```

#### Step 4: Compare Parameters
Compare the Query Parameters from the Flutter app with your successful curl command:
- **Curl command**: `latitude=10.8231, longitude=106.6297, radius=5`
- **Flutter app**: Check the actual values in the log

#### Step 5: Identify the Mismatch
Common issues to look for:
- `latitude: null` or `longitude: null`
- `latitude: 0.0` or `longitude: 0.0`
- Missing `radius` parameter
- Incorrectly formatted coordinates
- Additional unexpected parameters

#### Expected Resolution:
The `--- DIO REQUEST ---` log will immediately reveal why the Flutter app receives empty data while curl returns full results. This will pinpoint the exact parameter issue causing the search failure.