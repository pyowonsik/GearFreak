# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Gear Freak** is a Flutter e-commerce application for fitness equipment trading, built with Serverpod backend. The project follows Clean Architecture principles with feature-based modularization.

## Tech Stack

- **Frontend**: Flutter 3.24+, Dart 3.5+
- **Backend**: Serverpod 2.9.2
- **State Management**: Riverpod 2.6.1
- **Navigation**: GoRouter 15.1.2
- **Authentication**: Firebase Auth (Kakao, Naver, Google, Apple)
- **Messaging**: Firebase Cloud Messaging
- **Client**: `gear_freak_client` (Serverpod generated client)

## Common Commands

### Development
```bash
# Run the app (ensure Serverpod server is running first)
flutter run

# Run on specific device
flutter run -d <device-id>

# Hot reload: r
# Hot restart: R
```

### Code Quality
```bash
# Run linter (very_good_analysis)
flutter analyze

# Fix auto-fixable issues
dart fix --apply

# Format code
dart format .
```

### Build
```bash
# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios

# Generate launcher icons
flutter pub run flutter_launcher_icons
```

### Dependencies
```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Clean build cache
flutter clean && flutter pub get
```

## Architecture

### Directory Structure

```
lib/
├── main.dart              # App entry point
├── core/                  # Global configuration
│   ├── route/            # GoRouter configuration
│   ├── util/             # Global utilities
│   ├── di/               # Dependency injection
│   ├── constants/        # App-wide constants
│   └── theme/            # Theme configuration
├── shared/               # Shared modules
│   ├── widget/          # Reusable widgets (Gb* prefix)
│   ├── service/         # Common services (FCM, DeepLink, Pod)
│   ├── domain/          # Shared domain models
│   └── feature/         # Shared features (e.g., S3)
└── feature/             # Feature modules
    ├── auth/            # Authentication
    ├── product/         # Product management
    ├── chat/            # Real-time chat
    ├── notification/    # Push notifications
    ├── review/          # Review system
    ├── search/          # Product search
    └── profile/         # User profile
```

### Clean Architecture Layers

**Every feature follows this strict layer structure:**

```
feature/
├── data/
│   ├── datasource/      # API calls (Serverpod client)
│   └── repository/      # Repository implementation
├── domain/
│   ├── repository/      # Repository interface
│   └── usecase/         # Business logic
├── presentation/
│   ├── page/            # Routable pages
│   ├── view/            # State-specific UI (Loading, Error, Data)
│   ├── widget/          # Reusable widgets
│   ├── provider/        # Riverpod Notifiers/Providers
│   └── presentation.dart # Barrel file
└── di/                  # Dependency injection providers
```

**Layer Dependencies (must follow):**
- Presentation → Domain (UseCase only)
- Data → Domain (implements Repository interface)
- Domain → No external dependencies
- **Never skip layers** (e.g., Presentation → Repository directly)

### Barrel File Pattern

**All presentation folders must use barrel files:**

```dart
// presentation/page/pages.dart
export 'product_detail_page.dart';
export 'product_list_page.dart';

// presentation/view/view.dart
export 'product_detail_loaded_view.dart';
export 'product_list_loaded_view.dart';

// presentation/widget/widget.dart
export 'product_card_widget.dart';

// presentation/provider/provider.dart
export 'product_notifier.dart';
export 'product_state.dart';

// presentation/presentation.dart (top-level barrel)
export 'page/pages.dart';
export 'view/view.dart';
export 'widget/widget.dart';
export 'provider/provider.dart';
```

**Import rule:**
- ✅ `import 'package:gear_freak_flutter/feature/product/presentation/presentation.dart';`
- ❌ Direct file imports (except within same feature)

## Key Patterns

### Shared Widgets (Gb* Prefix)

All common UI components use `Gb` prefix and are located in `lib/shared/widget/`:

- `GbDialog.show()` - Always use instead of `AlertDialog`
- `GbSnackBar.showSuccess/Error/Warning/Info()` - Always use instead of `ScaffoldMessenger`
- `GbTextFormField` - Always use instead of `TextFormField`
- `GbErrorView` - Error state display
- `GbLoadingView` - Loading state display
- `GbEmptyView` - Empty state display

**Never use Flutter's default widgets directly when Gb* variant exists.**

### State Pattern Matching

Use pattern matching with `||` for same View:

```dart
// ✅ Correct
switch (state) {
  ProductLoaded(:final products) ||
  ProductLoadingMore(:final products) =>
    ProductListView(
      products: products,
      isLoadingMore: state is ProductLoadingMore,
    ),
}

// ❌ Wrong - duplicate branches
switch (state) {
  ProductLoaded(:final products) => ProductListView(...),
  ProductLoadingMore(:final products) => ProductListView(...),
}
```

### Build Helper Methods

**Never use `_build*` helper methods. Always use Widget classes directly:**

```dart
// ✅ Correct - Widget class with const
@override
Widget build(BuildContext context) {
  return switch (state) {
    Loading() => const GbLoadingView(),
    Loaded(:final data) => DataView(data: data),  // StatelessWidget
  };
}

// ❌ Wrong - _build helper
Widget _buildDataView(Data data) {  // Prevents const, breaks optimization
  return DataView(data: data);
}
```

**Reason**: Widget classes enable `const` constructors and Flutter's Element reuse optimization.

### BuildContext Safety

When using `BuildContext` across async gaps in functions:

```dart
// ✅ Correct - check context.mounted
Future<void> _handleTap(BuildContext context) async {
  await someAsyncOperation();

  if (!context.mounted) return;  // Check context, not State.mounted

  await context.push('/next');
}

// ❌ Wrong - using State.mounted with function parameter context
Future<void> _handleTap(BuildContext context) async {
  await someAsyncOperation();

  if (!mounted) return;  // Wrong: checks State, not the context parameter

  await context.push('/next');
}
```

## Environment Setup

### Required Files

Create `.env` file in project root:

```env
BASE_URL=your_serverpod_url
KAKAO_NATIVE_APP_KEY=your_kakao_key
```

### Firebase Configuration

Ensure Firebase configuration files are present:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

## Core Services

### PodService (Serverpod Client)

Singleton service managing Serverpod client connection:

- **Access**: `PodService.instance.client`
- **Location**: `lib/shared/service/pod_service.dart`
- **Initialization**: `main.dart` with BASE_URL from `.env`
- **Features**:
  - Connection timeout: 15 minutes
  - Streaming timeout: 20 minutes
  - Automatic connectivity monitoring
  - Built-in authentication key management
  - SessionManager for auth state

```dart
// Usage in DataSource
pod.Client get _client => PodService.instance.client;

final products = await _client.product.getPaginatedProducts(...);
```

### FCMService (Push Notifications)

Singleton service managing Firebase Cloud Messaging:

- **Access**: `FcmService.instance`
- **Location**: `lib/shared/service/fcm_service.dart`
- **Initialization**: Call after login with optional GoRouter for deep linking
- **Features**:
  - FCM token registration with auto-retry (3 attempts)
  - Token refresh handling
  - Foreground/background message listeners
  - Deep link navigation on notification tap
  - Callbacks for chat and notification updates

```dart
// Initialize after login
await FcmService.instance.initialize(router: router);

// Set callbacks
FcmService.instance.onMessageReceived = (chatRoomId) {
  // Refresh chat data
};
FcmService.instance.onNotificationReceived = () {
  // Refresh notification badge
};
```

**Important**:
- Background handler must be top-level function (cannot access Riverpod)
- Notification taps handled via `handleNotificationTap()` with deep linking
- Token synced to server automatically

### DeepLinkService

Singleton service managing app_links for deep linking:

- **Access**: `DeepLinkService.instance`
- **Location**: `lib/shared/service/deep_link_service.dart`
- **Initialization**: `main.dart` with GoRouter instance
- **Features**:
  - Initial link handling (app opened via deep link)
  - Real-time link stream listening
  - Automatic navigation via GoRouter

```dart
// Initialize in main.dart
await DeepLinkService.instance.initialize(router);
```

**Supported deep links**:
- Product detail: `/product/:id`
- Chat room: `/chat/:id?sellerId=X&chatRoomId=Y`
- Review write: `/product/:id/review/write?revieweeId=X&chatRoomId=Y`

## Dependency Injection Pattern

All features use Riverpod Providers in `di/` folder following this structure:

```dart
// 1. DataSource Provider
final featureRemoteDataSourceProvider = Provider<FeatureRemoteDataSource>((ref) {
  return const FeatureRemoteDataSource();
});

// 2. Repository Provider
final featureRepositoryProvider = Provider<FeatureRepository>((ref) {
  final remoteDataSource = ref.watch(featureRemoteDataSourceProvider);
  return FeatureRepositoryImpl(remoteDataSource);
});

// 3. UseCase Providers
final getFeatureUseCaseProvider = Provider<GetFeatureUseCase>((ref) {
  final repository = ref.watch(featureRepositoryProvider);
  return GetFeatureUseCase(repository);
});

// 4. Notifier Provider
final featureNotifierProvider = StateNotifierProvider<FeatureNotifier, FeatureState>((ref) {
  final getFeatureUseCase = ref.watch(getFeatureUseCaseProvider);
  return FeatureNotifier(getFeatureUseCase);
});
```

**Pattern**: DataSource → Repository → UseCase → Notifier
- Each layer only depends on the layer directly below
- All dependencies injected via Riverpod `ref.watch()`

## Pagination Pattern

Use `PaginationScrollMixin` for infinite scroll pagination:

```dart
class _MyPageState extends ConsumerState<MyPage> with PaginationScrollMixin {
  @override
  void initState() {
    super.initState();

    // Initialize pagination (after first frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPaginationScroll(
        onLoadMore: () {
          ref.read(myNotifierProvider.notifier).loadMoreItems();
        },
        getPagination: () {
          final state = ref.read(myNotifierProvider);
          if (state is MyLoaded) return state.pagination;
          if (state is MyLoadingMore) return state.pagination;
          return null;
        },
        isLoading: () {
          return ref.read(myNotifierProvider) is MyLoadingMore;
        },
        screenName: 'MyPage',
        reverse: false,  // true for chat (load on top scroll)
      );
    });
  }

  @override
  void dispose() {
    disposePaginationScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,  // From mixin
      itemBuilder: ...,
    );
  }
}
```

**Features**:
- Automatic scroll detection (top or bottom)
- Debouncing to prevent duplicate loads
- Loading state management
- Configurable threshold (default: 200px from edge)

## Feature Modules (Detailed)

### auth (Authentication)

**Purpose**: Multi-provider OAuth authentication with Firebase

**Key Features**:
- Email/password authentication
- Social login: Kakao, Naver, Google, Apple
- Session management via Serverpod SessionManager
- Auto-login on app start

**Main UseCases**:
- `LoginUseCase` - Email/password login
- `LoginWithKakaoUseCase` - Kakao OAuth
- `LoginWithNaverUseCase` - Naver OAuth
- `LoginWithGoogleUseCase` - Google OAuth
- `LoginWithAppleUseCase` - Apple Sign In
- `SignupUseCase` - New user registration
- `GetMeUseCase` - Fetch current user profile

**State Flow**:
```
AuthInitial → AuthLoading → AuthAuthenticated / AuthUnauthenticated
```

### product (Product Management)

**Purpose**: Product CRUD, search, filtering, and favorites

**Key Features**:
- Product creation with image uploads (S3)
- Product editing and deletion
- Pagination with sorting (latest, price, popularity)
- Category filtering
- Favorite/like system
- Product status management (selling, reserved, sold)

**Main UseCases**:
- `GetPaginatedProductsUseCase` - List with pagination
- `GetProductDetailUseCase` - Single product
- `CreateProductUseCase` - New product
- `UpdateProductUseCase` - Edit product
- `DeleteProductUseCase` - Remove product
- `ToggleFavoriteUseCase` - Like/unlike
- `UpdateProductStatusUseCase` - Change selling status

**Image Upload**:
- Uses S3 presigned URLs
- Multiple images per product
- Thumbnail generation on backend

### chat (Real-time Messaging)

**Purpose**: One-on-one chat between buyer and seller

**Key Features**:
- Real-time messaging via Serverpod streams
- Message history with pagination
- Unread message counter
- Image sharing in chat
- Chat room creation per product-buyer pair

**Main UseCases**:
- `GetChatRoomsUseCase` - List all chat rooms
- `GetChatMessagesUseCase` - Message history
- `SendChatMessageUseCase` - Send message
- `MarkMessagesAsReadUseCase` - Update read status
- `GetUnreadChatCountUseCase` - Badge count

**Stream Management**:
```dart
// Listen to real-time messages
final stream = await client.chat.streamChatMessages(chatRoomId);
await for (final message in stream) {
  // Update UI
}

// Reconnection on failure
if (stream closed unexpectedly) {
  // Auto-reconnect logic in notifier
}
```

**Important**:
- Stream must be cancelled in dispose()
- Reconnection handled automatically
- Pagination uses `reverse: true` (load older on top scroll)

### notification (Push Notifications)

**Purpose**: FCM-based notification system

**Key Features**:
- List all notifications with pagination
- Mark as read/unread
- Delete notifications
- Unread count badge
- Deep linking to relevant screens
- Notification types: review_received, chat_message, etc.

**Main UseCases**:
- `GetNotificationsUseCase` - Paginated list
- `MarkAsReadUseCase` - Update read status
- `DeleteNotificationUseCase` - Remove notification
- `GetUnreadCountUseCase` - Badge count

**Deep Link Handling**:
- Review notifications → Review write page or review list
- Chat notifications → Chat room
- Uses notification data payload for navigation

### review (Review System)

**Purpose**: Buyer/seller mutual review system

**Key Features**:
- Two-way reviews (buyer ↔ seller)
- Review creation after transaction
- Review list by type (received/given)
- Review prevention: one per transaction per user type
- Template-based review tags

**Main UseCases**:
- `CreateReviewUseCase` - Write new review
- `GetReviewsUseCase` - Paginated list
- `CheckReviewExistsUseCase` - Prevent duplicates

**Review Types**:
- `buyer_to_seller`: Buyer reviews seller (on product status change)
- `seller_to_buyer`: Seller reviews buyer (via notification)

**Important**:
- Buyer reviews created when product status changes to sold
- Seller reviews created via notification tap only
- Each user can only write one review per role per transaction

### search (Product Search)

**Purpose**: Product search with history

**Key Features**:
- Full-text search on product name and description
- Recent search history (local storage)
- Search result pagination
- Sort options (same as product list)

**Main UseCases**:
- `SearchProductsUseCase` - Search with pagination
- Recent search service (not UseCase, uses SharedPreferences)

**Local Services**:
- `RecentSearchService` - Stores last 10 searches

### profile (User Profile)

**Purpose**: User profile and account management

**Key Features**:
- Profile editing (name, image, address)
- My products list (selling/sold)
- Favorite products list
- Review statistics
- Logout

**Main UseCases**:
- `GetMyProfileUseCase` - Fetch profile
- `UpdateProfileUseCase` - Edit profile
- `UploadProfileImageUseCase` - S3 image upload
- `GetMyProductsUseCase` - My listings
- `GetMyFavoritesUseCase` - Liked products

## Routing Structure

Uses GoRouter with `StatefulShellRoute` for bottom navigation:

### Main Shell Routes (Bottom Tabs)

```dart
StatefulShellRoute(
  branches: [
    StatefulShellBranch(routes: [
      GoRoute(path: '/', builder: HomePage),           // Home (tab 0)
    ]),
    StatefulShellBranch(routes: [
      GoRoute(path: '/chat-list', builder: ChatListPage),  // Chat (tab 1)
    ]),
    StatefulShellBranch(routes: [
      GoRoute(path: '/add-product', builder: AddProductPage), // Add (tab 2)
    ]),
    StatefulShellBranch(routes: [
      GoRoute(path: '/notifications', builder: NotificationListPage), // Notifications (tab 3)
    ]),
    StatefulShellBranch(routes: [
      GoRoute(path: '/profile', builder: ProfilePage),  // Profile (tab 4)
    ]),
  ],
)
```

### Full-Screen Routes (Outside Tabs)

- `/splash` - Initial splash screen
- `/login` - Login page
- `/signup` - Sign up page
- `/product/:id` - Product detail
- `/product/edit/:id` - Edit product
- `/chat/:id` - Chat room
- `/profile/edit` - Edit profile
- `/profile/reviews` - Review list
- `/product/:id/review/write` - Write review

**Route Guards**:
- Unauthenticated users redirected to `/login`
- Handled in `app_route_guard.dart`

## Important Notes

### Serverpod Client

- Access via: `PodService.instance.client`
- Located: `lib/shared/service/pod_service.dart`
- Initialized in `main.dart` with BASE_URL from `.env`

### Naming Conventions

- **Directories**: Singular form (`route/`, `util/`, `widget/`)
- **Exception**: `constants/` (plural)
- **Files**: Snake_case (`product_detail_page.dart`)
- **Classes**: PascalCase (`ProductDetailPage`)
- **Private**: Underscore prefix (`_handleTap`)

### Code Organization

**Service class methods (Backend):**
1. Public methods (called by endpoints)
2. Private helper methods (`_buildResponse`, `_filterData`)

**Notifier class methods (Frontend):**
1. Public methods - UseCase calls
2. Public methods - Service calls
3. Private helper methods

Use section comments:
```dart
// ==================== Public Methods (UseCase) ====================

// ==================== Private Helper Methods ====================
```

## Documentation

- **Troubleshooting**: `gear_freak_flutter/docs/TROUBLESHOOTING_AND_IMPROVEMENTS.md`
- **Cursor Rules**: `.cursorrules` (comprehensive architecture guide)
- **Work Logs**: `thoughts/personal/implement/` (daily implementation logs)

## Testing

Currently using manual testing. Unit/widget tests should follow feature structure when added.

## Build Configuration

- **Min SDK**: Android 21 (Android 5.0+)
- **Target SDK**: Latest
- **iOS Deployment**: 12.0+
- **App Icon**: `assets/app_icon.png` (configured with flutter_launcher_icons)

## Common Issues & Best Practices

1. **Lint warnings**: Run `flutter analyze` and fix issues before committing
   - Project uses `very_good_analysis` for strict linting
   - Fix `use_build_context_synchronously` with `context.mounted` checks

2. **Import order**: Follow barrel file pattern
   - Always import from `presentation/presentation.dart`
   - Never import individual files from other features

3. **BuildContext async safety**:
   - Always use `context.mounted` for function parameter contexts
   - Use `mounted` (State property) only for State's own context
   - Check before any navigation after `await`

4. **Clean Architecture violations**:
   - Never call Repository from Notifier (use UseCase)
   - Never call DataSource from UseCase (use Repository)
   - Never skip layers

5. **Widget reuse**:
   - Check `lib/shared/widget/` before creating common widgets
   - Use Gb* widgets (GbDialog, GbSnackBar, etc.) instead of Flutter defaults
   - Create StatelessWidget instead of `_build*` helper methods

6. **Pagination issues**:
   - Always initialize in `addPostFrameCallback`, not directly in `initState`
   - Always call `disposePaginationScroll()` in `dispose()`
   - Use `reverse: true` for chat-style pagination (load on top scroll)

7. **Stream management** (Chat):
   - Always cancel stream subscriptions in `dispose()`
   - Handle reconnection on stream errors
   - Don't forget to update UI when stream emits

8. **FCM & Deep Links**:
   - Initialize FCMService AFTER login (needs auth token)
   - DeepLinkService initialized in main with router
   - Background FCM handler must be top-level function

9. **State management**:
   - Use pattern matching `||` for states sharing same View
   - Match parent state class to include all subclasses
   - Don't create duplicate switch branches

10. **Image uploads**:
    - Use S3 presigned URLs (handled by backend)
    - Multiple images: iterate and upload sequentially
    - Show upload progress to user
