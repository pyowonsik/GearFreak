# Flutter iOS/Android CI/CD Deployment Research

**Date**: 2026-01-12
**Project**: Gear Freak Flutter App
**Author**: Claude Code Research

---

## Table of Contents

1. [Project Analysis](#1-project-analysis)
2. [GitHub Actions for Flutter](#2-github-actions-for-flutter)
3. [Fastlane Integration](#3-fastlane-integration)
4. [Complete Workflow Examples](#4-complete-workflow-examples)
5. [Required Secrets](#5-required-secrets)
6. [Firebase App Distribution (Alternative)](#6-firebase-app-distribution-alternative)
7. [Implementation Checklist](#7-implementation-checklist)

---

## 1. Project Analysis

### Current Project Structure

```
gear_freak_flutter/
├── pubspec.yaml              # Flutter 3.24+, Dart 3.5+
├── ios/
│   ├── Runner/
│   │   ├── Info.plist        # Bundle ID, URL schemes
│   │   ├── Runner.entitlements # Push notifications, Apple Sign-In, Associated Domains
│   │   └── GoogleService-Info.plist
│   ├── Podfile               # iOS 13.0+ minimum
│   └── Podfile.lock
├── android/
│   ├── app/
│   │   ├── build.gradle      # compileSdk 36, targetSdk 35, minSdk 21
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── google-services.json
│   └── build.gradle
└── .env                       # Environment variables (BASE_URL, API keys)
```

### Key Dependencies

| Category | Dependencies |
|----------|-------------|
| Firebase | firebase_core, firebase_auth, firebase_messaging |
| Auth | kakao_flutter_sdk, flutter_naver_login, google_sign_in, sign_in_with_apple |
| State | flutter_riverpod 2.6.1 |
| Navigation | go_router 15.1.2 |
| Serverpod | serverpod_flutter 2.9.2, serverpod_auth_client 2.9.2 |

### iOS Capabilities (from Runner.entitlements)

- Push Notifications (aps-environment: development)
- Sign in with Apple
- Associated Domains (applinks:gear-freaks.com)

### Android Configuration

- Application ID: `com.pyowonsik.gearFreakFlutter`
- Deep Links: `gearfreak://`, `https://gear-freaks.com`
- Social Login: Kakao, Naver
- FCM Channel: `chat_channel`

### Existing CI/CD

The project has existing AWS deployment workflows for the Serverpod server (`deployment-aws.yml`), but **no Flutter mobile CI/CD** is configured yet.

---

## 2. GitHub Actions for Flutter

### 2.1 Best Practices

#### Workflow Triggers

```yaml
on:
  push:
    branches: [main, develop]
    paths:
      - 'gear_freak_flutter/**'
      - 'gear_freak_client/**'
  pull_request:
    branches: [main, develop]
    paths:
      - 'gear_freak_flutter/**'
      - 'gear_freak_client/**'
  workflow_dispatch:
    inputs:
      platform:
        description: 'Build platform'
        required: true
        type: choice
        options: [ios, android, both]
```

#### Recommended Runner Selection

| Platform | Runner | Notes |
|----------|--------|-------|
| iOS | `macos-14` or `macos-latest` | Required for Xcode |
| Android | `ubuntu-latest` | Faster and cheaper |
| Both | Separate jobs | Parallel execution |

#### Flutter Action Setup

```yaml
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.0'
    channel: 'stable'
    cache: true
    cache-key: flutter-:os:-:channel:-:version:-:arch:-:hash:
    pub-cache-key: flutter-pub-:os:-:channel:-:version:-:arch:-:hash:
```

### 2.2 Caching Strategies

#### Comprehensive Caching Configuration

```yaml
# 1. Flutter SDK and pub cache (built into flutter-action)
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.0'
    channel: 'stable'
    cache: true

# 2. Gradle cache for Android
- uses: actions/cache@v4
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
    restore-keys: |
      ${{ runner.os }}-gradle-

# 3. CocoaPods cache for iOS
- uses: actions/cache@v4
  with:
    path: gear_freak_flutter/ios/Pods
    key: ${{ runner.os }}-pods-${{ hashFiles('**/Podfile.lock') }}
    restore-keys: |
      ${{ runner.os }}-pods-

# 4. Java setup with Gradle cache
- uses: actions/setup-java@v4
  with:
    distribution: 'zulu'
    java-version: '17'
    cache: 'gradle'
```

#### Cache Size Considerations

- Individual cache files: max 400 MB
- Total repository caches: max 10 GB
- Use `pubspec.lock` hash as cache key for dependencies

### 2.3 Environment Secrets Management

#### Secret Types

| Type | GitHub Secrets | Use Case |
|------|----------------|----------|
| Env Vars | `ENV_FILE` | Base64 encoded .env file |
| iOS Signing | `MATCH_PASSWORD`, `MATCH_GIT_BASIC_AUTH` | Code signing |
| Android Signing | `KEYSTORE_BASE64`, `KEY_PASSWORD` | APK/AAB signing |
| API Keys | `APP_STORE_CONNECT_KEY` | Deployment |

#### Decoding Secrets in Workflow

```yaml
# Decode .env file
- name: Create .env file
  run: echo "${{ secrets.ENV_FILE }}" | base64 --decode > gear_freak_flutter/.env

# Decode Android keystore
- name: Decode keystore
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks
```

---

## 3. Fastlane Integration

### 3.1 Directory Structure

```
gear_freak_flutter/
├── ios/
│   └── fastlane/
│       ├── Appfile
│       ├── Fastfile
│       └── Matchfile
├── android/
│   └── fastlane/
│       ├── Appfile
│       └── Fastfile
└── Gemfile
```

### 3.2 iOS Configuration

#### Appfile (ios/fastlane/Appfile)

```ruby
app_identifier("com.pyowonsik.gearFreakFlutter")
apple_id("your-apple-id@email.com")
itc_team_id("YOUR_ITC_TEAM_ID")  # App Store Connect Team ID
team_id("YOUR_DEV_TEAM_ID")      # Developer Portal Team ID
```

#### Matchfile (ios/fastlane/Matchfile)

```ruby
git_url("https://github.com/your-org/certificates.git")
storage_mode("git")
type("appstore")  # development, adhoc, appstore, enterprise
app_identifier(["com.pyowonsik.gearFreakFlutter"])
username("your-apple-id@email.com")

# For CI/CD - API Key authentication (recommended)
# api_key_path("fastlane/AuthKey.json")
```

#### Fastfile (ios/fastlane/Fastfile)

```ruby
default_platform(:ios)

platform :ios do
  desc "Push a new beta build to TestFlight"
  lane :beta do
    # CI environment setup
    setup_ci if ENV['CI']

    # Sync code signing
    match(
      type: "appstore",
      readonly: is_ci,
      app_identifier: "com.pyowonsik.gearFreakFlutter"
    )

    # Get latest TestFlight build number and increment
    latest_build_number = latest_testflight_build_number(
      app_identifier: "com.pyowonsik.gearFreakFlutter"
    )
    increment_build_number(
      build_number: latest_build_number + 1,
      xcodeproj: "Runner.xcodeproj"
    )

    # Build Flutter app first (run from project root)
    # flutter build ios --release --no-codesign

    # Build and sign with Xcode
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store",
      export_options: {
        provisioningProfiles: {
          "com.pyowonsik.gearFreakFlutter" => "match AppStore com.pyowonsik.gearFreakFlutter"
        }
      }
    )

    # Upload to TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true,
      apple_id: "YOUR_APP_APPLE_ID"
    )
  end

  desc "Push a new release build to App Store"
  lane :release do
    setup_ci if ENV['CI']

    match(type: "appstore", readonly: is_ci)

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )

    upload_to_app_store(
      skip_metadata: true,
      skip_screenshots: true,
      precheck_include_in_app_purchases: false
    )
  end

  desc "Sync certificates and profiles"
  lane :certificates do
    match(type: "development")
    match(type: "appstore")
  end
end
```

### 3.3 Android Configuration

#### Appfile (android/fastlane/Appfile)

```ruby
json_key_file("fastlane/play-store-key.json")
package_name("com.pyowonsik.gearFreakFlutter")
```

#### Fastfile (android/fastlane/Fastfile)

```ruby
default_platform(:android)

platform :android do
  desc "Deploy to Play Store Internal Track"
  lane :internal do
    # Build Flutter AAB first (run from project root)
    # flutter build appbundle --release

    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      release_status: "completed"
    )
  end

  desc "Deploy to Play Store Beta Track"
  lane :beta do
    upload_to_play_store(
      track: "beta",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end

  desc "Promote Internal to Beta"
  lane :promote_to_beta do
    upload_to_play_store(
      track: "internal",
      track_promote_to: "beta",
      skip_upload_apk: true,
      skip_upload_aab: true
    )
  end

  desc "Deploy to Production"
  lane :production do
    upload_to_play_store(
      track: "production",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      rollout: "0.1"  # Start with 10% rollout
    )
  end
end
```

### 3.4 Android Signing Configuration

#### Create key.properties (android/key.properties)

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=../keystore.jks
```

#### Update build.gradle (android/app/build.gradle)

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3.5 Gemfile Setup

```ruby
# gear_freak_flutter/Gemfile
source "https://rubygems.org"

gem "fastlane", "~> 2.220"
gem "cocoapods", "~> 1.15"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
```

---

## 4. Complete Workflow Examples

### 4.1 PR Checks Workflow

```yaml
# .github/workflows/flutter-pr-checks.yml
name: Flutter PR Checks

on:
  pull_request:
    branches: [main, develop]
    paths:
      - 'gear_freak_flutter/**'
      - 'gear_freak_client/**'

env:
  FLUTTER_VERSION: '3.24.0'

jobs:
  analyze-and-test:
    name: Analyze & Test
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: gear_freak_flutter

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Get gear_freak_client dependencies
        run: flutter pub get
        working-directory: gear_freak_client

      - name: Get dependencies
        run: flutter pub get

      - name: Create dummy .env file
        run: |
          cat > .env << EOF
          BASE_URL=https://dummy.example.com
          KAKAO_NATIVE_APP_KEY=dummy_key
          EOF

      - name: Run analyzer
        run: flutter analyze --no-fatal-infos

      - name: Check formatting
        run: dart format --output=none --set-exit-if-changed .

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          files: coverage/lcov.info
          flags: flutter
          name: gear_freak_flutter

  build-android:
    name: Build Android (Debug)
    runs-on: ubuntu-latest
    needs: analyze-and-test
    defaults:
      run:
        working-directory: gear_freak_flutter

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
          cache: 'gradle'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
          restore-keys: ${{ runner.os }}-gradle-

      - name: Get gear_freak_client dependencies
        run: flutter pub get
        working-directory: gear_freak_client

      - name: Get dependencies
        run: flutter pub get

      - name: Create .env file
        run: echo "${{ secrets.ENV_FILE }}" | base64 --decode > .env

      - name: Build APK (Debug)
        run: flutter build apk --debug

      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: android-debug-apk
          path: gear_freak_flutter/build/app/outputs/flutter-apk/app-debug.apk
          retention-days: 7

  build-ios:
    name: Build iOS (Debug)
    runs-on: macos-14
    needs: analyze-and-test
    defaults:
      run:
        working-directory: gear_freak_flutter

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Cache CocoaPods
        uses: actions/cache@v4
        with:
          path: gear_freak_flutter/ios/Pods
          key: ${{ runner.os }}-pods-${{ hashFiles('**/Podfile.lock') }}
          restore-keys: ${{ runner.os }}-pods-

      - name: Get gear_freak_client dependencies
        run: flutter pub get
        working-directory: gear_freak_client

      - name: Get dependencies
        run: flutter pub get

      - name: Create .env file
        run: echo "${{ secrets.ENV_FILE }}" | base64 --decode > .env

      - name: Install CocoaPods
        run: cd ios && pod install --repo-update

      - name: Build iOS (no codesign)
        run: flutter build ios --debug --no-codesign
```

### 4.2 Deploy to TestFlight Workflow

```yaml
# .github/workflows/deploy-ios-testflight.yml
name: Deploy iOS to TestFlight

on:
  push:
    branches: [main]
    paths:
      - 'gear_freak_flutter/**'
      - 'gear_freak_client/**'
  workflow_dispatch:

env:
  FLUTTER_VERSION: '3.24.0'

jobs:
  deploy-testflight:
    name: Deploy to TestFlight
    runs-on: macos-14
    defaults:
      run:
        working-directory: gear_freak_flutter

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Cache CocoaPods
        uses: actions/cache@v4
        with:
          path: gear_freak_flutter/ios/Pods
          key: ${{ runner.os }}-pods-${{ hashFiles('**/Podfile.lock') }}
          restore-keys: ${{ runner.os }}-pods-

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: gear_freak_flutter

      - name: Get gear_freak_client dependencies
        run: flutter pub get
        working-directory: gear_freak_client

      - name: Get dependencies
        run: flutter pub get

      - name: Create .env file
        run: echo "${{ secrets.ENV_FILE }}" | base64 --decode > .env

      - name: Install CocoaPods
        run: cd ios && pod install --repo-update

      - name: Build Flutter iOS
        run: flutter build ios --release --no-codesign

      - name: Create App Store Connect API Key
        run: |
          mkdir -p ios/fastlane
          cat > ios/fastlane/AuthKey.json << EOF
          {
            "key_id": "${{ secrets.APP_STORE_CONNECT_KEY_ID }}",
            "issuer_id": "${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}",
            "key": "${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY }}"
          }
          EOF

      - name: Deploy to TestFlight
        run: cd ios && bundle exec fastlane beta
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_BASIC_AUTHORIZATION: ${{ secrets.MATCH_GIT_BASIC_AUTH }}
          APP_STORE_CONNECT_API_KEY_KEY_ID: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          APP_STORE_CONNECT_API_KEY_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_KEY: ${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY }}
```

### 4.3 Deploy to Play Store Workflow

```yaml
# .github/workflows/deploy-android-playstore.yml
name: Deploy Android to Play Store

on:
  push:
    branches: [main]
    paths:
      - 'gear_freak_flutter/**'
      - 'gear_freak_client/**'
  workflow_dispatch:
    inputs:
      track:
        description: 'Play Store track'
        required: true
        type: choice
        options:
          - internal
          - alpha
          - beta
          - production

env:
  FLUTTER_VERSION: '3.24.0'

jobs:
  deploy-playstore:
    name: Deploy to Play Store
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: gear_freak_flutter

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
          cache: 'gradle'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
          restore-keys: ${{ runner.os }}-gradle-

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: gear_freak_flutter

      - name: Get gear_freak_client dependencies
        run: flutter pub get
        working-directory: gear_freak_client

      - name: Get dependencies
        run: flutter pub get

      - name: Create .env file
        run: echo "${{ secrets.ENV_FILE }}" | base64 --decode > .env

      - name: Decode keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/keystore.jks
          cat > android/key.properties << EOF
          storePassword=${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}
          keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}
          storeFile=keystore.jks
          EOF

      - name: Build App Bundle
        run: flutter build appbundle --release

      - name: Create Play Store Service Account
        run: |
          mkdir -p android/fastlane
          echo '${{ secrets.PLAY_STORE_SERVICE_ACCOUNT_JSON }}' > android/fastlane/play-store-key.json

      - name: Deploy to Play Store
        run: cd android && bundle exec fastlane ${{ github.event.inputs.track || 'internal' }}
```

---

## 5. Required Secrets

### 5.1 Complete Secrets List

#### Common Secrets

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `ENV_FILE` | Base64 encoded .env file | `base64 -i .env` |

#### iOS Secrets (TestFlight/App Store)

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `MATCH_PASSWORD` | Password for Match encryption | Create strong password |
| `MATCH_GIT_BASIC_AUTH` | Base64 encoded `username:PAT` | Create GitHub PAT with repo access |
| `APP_STORE_CONNECT_KEY_ID` | App Store Connect API Key ID | App Store Connect > Users > Keys |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect Issuer ID | App Store Connect > Users > Keys |
| `APP_STORE_CONNECT_PRIVATE_KEY` | API Key .p8 file content | Download from App Store Connect |

#### Android Secrets (Play Store)

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `ANDROID_KEYSTORE_BASE64` | Base64 encoded keystore | `base64 -i keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password | Set when creating keystore |
| `ANDROID_KEY_PASSWORD` | Key password | Set when creating keystore |
| `ANDROID_KEY_ALIAS` | Key alias | Set when creating keystore |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Service account JSON content | Google Cloud Console |

### 5.2 Setup Instructions

#### iOS: Create App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to Users and Access > Keys
3. Click "+" to create new key
4. Select "App Manager" or "Admin" role
5. Download the .p8 file (only downloadable once!)
6. Note the Key ID and Issuer ID
7. Add to GitHub Secrets:
   - `APP_STORE_CONNECT_KEY_ID`: The Key ID
   - `APP_STORE_CONNECT_ISSUER_ID`: The Issuer ID
   - `APP_STORE_CONNECT_PRIVATE_KEY`: Content of .p8 file

#### iOS: Setup Match Certificates Repository

1. Create private GitHub repository (e.g., `your-org/certificates`)
2. Create a Personal Access Token (PAT) with `repo` scope
3. Generate MATCH_GIT_BASIC_AUTH:
   ```bash
   echo -n "github-username:ghp_your_token" | base64
   ```
4. Initialize Match locally:
   ```bash
   cd ios
   fastlane match init
   # Select 'git' storage
   # Enter repository URL

   fastlane match development
   fastlane match appstore
   ```
5. Set `MATCH_PASSWORD` in GitHub Secrets

#### Android: Create Keystore

```bash
# Create release keystore
keytool -genkey -v -keystore keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias gear_freak_release

# Encode for GitHub Secrets
base64 -i keystore.jks | pbcopy
# Paste into ANDROID_KEYSTORE_BASE64
```

#### Android: Create Play Store Service Account

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create new project or select existing
3. Enable Google Play Android Developer API
4. Create Service Account:
   - IAM & Admin > Service Accounts > Create
   - Name: "play-store-deploy"
   - Role: No role needed (will be granted in Play Console)
5. Create JSON key for service account
6. Go to [Play Console](https://play.google.com/console)
7. Setup > API Access > Link to Google Cloud project
8. Grant access to service account:
   - Select your service account
   - Grant "Release manager" or "Admin" permissions
9. Copy JSON content to `PLAY_STORE_SERVICE_ACCOUNT_JSON`

---

## 6. Firebase App Distribution (Alternative)

### 6.1 When to Use

- **Beta testing** before TestFlight/Play Store Internal
- **Faster distribution** (no store review)
- **Ad-hoc distribution** for specific testers
- **Emergency hotfixes** to test group

### 6.2 Setup

#### Android Workflow Addition

```yaml
- name: Upload to Firebase App Distribution
  uses: wzieba/Firebase-Distribution-Github-Action@v1
  with:
    appId: ${{ secrets.FIREBASE_ANDROID_APP_ID }}
    serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT_JSON }}
    groups: testers
    file: build/app/outputs/flutter-apk/app-release.apk
    releaseNotes: |
      Build: ${{ github.run_number }}
      Commit: ${{ github.sha }}
```

#### iOS Workflow Addition

For iOS, the Firebase action only runs on Linux, so you need to upload the IPA as an artifact first, then distribute in a separate Linux job:

```yaml
# Job 1: Build on macOS
build-ios:
  runs-on: macos-14
  steps:
    # ... build steps ...
    - name: Upload IPA artifact
      uses: actions/upload-artifact@v4
      with:
        name: ios-ipa
        path: ios/build/Runner.ipa

# Job 2: Distribute on Linux
distribute-ios:
  runs-on: ubuntu-latest
  needs: build-ios
  steps:
    - name: Download IPA
      uses: actions/download-artifact@v4
      with:
        name: ios-ipa

    - name: Upload to Firebase
      uses: wzieba/Firebase-Distribution-Github-Action@v1
      with:
        appId: ${{ secrets.FIREBASE_IOS_APP_ID }}
        serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT_JSON }}
        groups: testers
        file: Runner.ipa
```

#### Required Firebase Secrets

| Secret | Description |
|--------|-------------|
| `FIREBASE_ANDROID_APP_ID` | Found in Firebase Console > Project Settings |
| `FIREBASE_IOS_APP_ID` | Found in Firebase Console > Project Settings |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Firebase service account JSON for API access |

---

## 7. Implementation Checklist

### Phase 1: Prerequisites

- [ ] Create Android release keystore
- [ ] Create GitHub repository for Match certificates
- [ ] Create App Store Connect API Key
- [ ] Create Google Play Service Account
- [ ] Add all secrets to GitHub repository
- [ ] Create Gemfile in gear_freak_flutter/

### Phase 2: Fastlane Setup

- [ ] Initialize Fastlane for iOS (`fastlane init` in ios/)
- [ ] Initialize Fastlane for Android (`fastlane init` in android/)
- [ ] Setup Match (`fastlane match init`)
- [ ] Generate development certificates (`fastlane match development`)
- [ ] Generate App Store certificates (`fastlane match appstore`)
- [ ] Configure Fastfiles for both platforms
- [ ] Test lanes locally

### Phase 3: GitHub Actions

- [ ] Create PR checks workflow
- [ ] Create TestFlight deployment workflow
- [ ] Create Play Store deployment workflow
- [ ] Test workflows on a feature branch
- [ ] Enable branch protection rules

### Phase 4: Verification

- [ ] Verify PR checks run on pull requests
- [ ] Verify TestFlight deployment works
- [ ] Verify Play Store Internal deployment works
- [ ] Document deployment process for team

---

## References

### Official Documentation
- [Flutter CI/CD Documentation](https://docs.flutter.dev/deployment/cd)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

### Tutorials and Guides
- [Automate Flutter CI/CD with GitHub Actions](https://medium.com/@sharmapraveen91/automate-flutter-ci-cd-with-github-actions-android-ios-testflight-deployment-89a1c903721a)
- [Flutter CI/CD with Fastlane - NTT DATA](https://nttdata-dach.github.io/posts/dd-fluttercicd-01-basics/)
- [iOS TestFlight with GitHub Actions and Fastlane Match](https://brightinventions.pl/blog/ios-testflight-github-actions-fastlane-match/)
- [CI/CD for Flutter Android Apps](https://www.aubergine.co/insights/setting-up-ci-cd-for-flutter-android-apps)
- [CI/CD for Flutter iOS Apps](https://www.aubergine.co/insights/setting-up-ci-cd-for-flutter-ios-apps)
- [Building and deploying Flutter apps with Fastlane - CircleCI](https://circleci.com/blog/deploy-flutter-android/)

### GitHub Actions and Tools
- [subosito/flutter-action](https://github.com/marketplace/actions/flutter-action)
- [actions/cache](https://github.com/actions/cache)
- [Firebase App Distribution Action](https://github.com/marketplace/actions/firebase-app-distribution)
