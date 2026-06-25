Google Maps setup for KormoBD

1) Get API keys
- Go to Google Cloud Console > APIs & Services > Credentials.
- Create an API key for Android and one for iOS (or use same with restrictions).
- Enable the following APIs: Maps SDK for Android, Maps SDK for iOS, Geocoding API (optional).

2) Android
- Open `android/app/src/main/AndroidManifest.xml` and set your Android API key in the application meta-data:

  <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_ANDROID_API_KEY"/>

- Ensure permissions are present:

  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

- If you restrict the API key, set Android app restrictions (package name + SHA-1).

3) iOS
- Open `ios/Runner/Info.plist` and set `GMSApiKey` key or provide the key in `AppDelegate`.

  <key>GMSApiKey</key>
  <string>YOUR_IOS_API_KEY</string>

- Add location permission description:

  <key>NSLocationWhenInUseUsageDescription</key>
  <string>App needs your location to pick worker location.</string>

- If you prefer code-based setup (AppDelegate.swift):

  import GoogleMaps
  ...
  GMSServices.provideAPIKey("YOUR_IOS_API_KEY")

4) Testing
- Run the app on a real device or emulator with Google Play services.
- On first use, grant location permission when prompted.
- Open `Edit Profile` -> `Pick location`, tap the map and `Confirm location`.
- Verify `latitude`/`longitude` fields are saved in Firestore for the profile document.

5) Security
- Restrict API keys in Google Cloud to your app bundle IDs / package name + SHA-1.

If you want, I can automatically insert your real API keys (you must supply them), or add iOS AppDelegate code instead of the `GMSApiKey` plist entry.