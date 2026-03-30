# EcoTrade Rwanda — Mobile App

Full-featured Flutter application for the EcoTrade Rwanda circular-economy waste marketplace. Supports Android, Windows desktop, and web (Chrome) from a single codebase. Provides dedicated experiences for HORECA businesses, recyclers, and drivers — with real OpenStreetMap maps, QR code scanning, offline-first Hive caching, PDF report export, and CAT (Central African Time) display throughout.

**Backend API:** https://api.ecotrade-rwanda.com/api
**GitHub Repository:** https://github.com/Daniel-IRYIVUZE/EcoTrade_Rwanda.git
**Project Report:** https://docs.google.com/document/d/1Kouxf8p8D40-Nn8H4EkhoHpnLBhfcDyF/edit?usp=sharing&ouid=108652004118988396657&rtpof=true&sd=true
**Slides Deck:** https://docs.google.com/presentation/d/1-Jo_mrii-yioCeo_iM7OJzIDn9y2JrbF/edit?usp=sharing&ouid=108652004118988396657&rtpof=true&sd=true

---

## Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the App](#running-the-app)
- [Supported Platforms](#supported-platforms)
- [Project Structure](#project-structure)
- [Features by Role](#features-by-role)
- [Key Technical Features](#key-technical-features)
- [GreenScore System](#greenscore-system)
- [Environment / Configuration](#environment--configuration)
- [Building for Release](#building-for-release)
- [Permissions](#permissions)
- [Technology Stack](#technology-stack)
- [Demo Credentials](#demo-credentials)
- [License](#license)

---

## Quick Start

```bash
cd mobile
flutter pub get
flutter run -d chrome       # Web (fastest to start)
flutter run -d android      # Android emulator or device
flutter run -d windows      # Windows desktop
```

---

## Prerequisites

- Flutter SDK **3.2** or higher
- Dart SDK **3.2** or higher (bundled with Flutter)
- Android Studio (for Android builds) or Visual Studio 2022 (for Windows builds)
- A connected device, emulator, or the Chrome browser

Verify your setup:

```bash
flutter doctor
flutter --version     # must be 3.2+
```

---

## Installation

```bash
# Clone the repository
git clone https://github.com/Daniel-IRYIVUZE/EcoTrade_Rwanda.git
cd EcoTrade_Rwanda/mobile

# Install Flutter dependencies
flutter pub get
```

---

## Running the App

```bash
# List available devices
flutter devices

# Run on a specific target
flutter run -d chrome           # Web browser (fastest)
flutter run -d android          # Android emulator or physical device
flutter run -d windows          # Windows desktop
flutter run -d <device-id>      # Any device from flutter devices list
```

Hot reload is available on all targets — press `r` in the terminal to reload, `R` for full restart.

---

## Supported Platforms

| Platform | Status | Notes |
|---|---|---|
| **Android** | Supported | Minimum SDK 21 (Android 5.0) |
| **Windows** | Supported | Windows 10 / 11 |
| **Web (Chrome)** | Supported | Full feature parity with mobile |
| iOS | Code-compatible | Requires macOS + Xcode to build |
| macOS | Code-compatible | Requires macOS + Xcode to build |
| Linux | Code-compatible | Requires Linux build tools |

---

## Project Structure

```
mobile/
├── lib/
│   ├── main.dart                       # Entry point — Hive init, providers, orientation
│   └── core/
│       ├── models/
│       │   └── models.dart             # All Dart data classes (User, Listing, Bid, etc.)
│       ├── providers/
│       │   └── app_providers.dart      # All Riverpod providers (auth, listings, bids, etc.)
│       ├── services/
│       │   ├── api_service.dart        # Full API client (40+ methods, JWT, refresh)
│       │   ├── offline_sync_service.dart  # Mutation queue + auto replay on reconnect
│       │   ├── notification_service.dart  # Local push notifications
│       │   └── local_storage_service.dart # Shared preferences wrapper
│       ├── router/
│       │   └── app_router.dart         # GoRouter — all routes + auth redirect logic
│       ├── theme/
│       │   └── app_theme.dart          # Light + dark Material Design 3 themes
│       └── utils/
│           ├── cat_date_utils.dart     # CAT (UTC+2) date/time formatting
│           ├── image_url.dart          # Absolute URL resolver for API images
│           └── pdf_report_service.dart # PDF export (driver history + earnings)
└── features/
    ├── splash/                         # Animated splash screen
    ├── onboarding/                     # First-launch onboarding flow
    ├── auth/                           # Login, OTP verification, forgot password
    ├── hotel/                          # HORECA business screens
    │   ├── hotel_main_screen.dart      # Home, My Listings, Bids, Pickups, Profile tabs
    │   ├── list_waste_screen.dart      # Create / edit waste listing with map pin + photo upload
    │   ├── bids_screen.dart            # Incoming bids — accept / reject
    │   ├── collections_screen.dart     # Scheduled and history tabs; call driver
    │   └── hotel_profile_screen.dart   # Hotel details + GreenScore card
    ├── recycler/                       # Recycler company screens
    │   ├── recycler_main_screen.dart   # Home, Marketplace, Bids, Fleet, Collections tabs
    │   ├── marketplace_screen.dart     # Browse open listings with flutter_map
    │   ├── my_bids_screen.dart         # Submitted bids — withdraw / increase
    │   ├── fleet_screen.dart           # Driver and vehicle management
    │   └── recycler_collections_screen.dart
    ├── driver/                         # Driver screens
    │   ├── driver_main_screen.dart     # Home with next stop card and daily stats
    │   ├── collection_screen.dart      # Active collection — QR scanner, multi-stop queue
    │   ├── navigation_screen.dart      # OpenStreetMap route map
    │   ├── earnings_screen.dart        # Earnings with period filter + PDF export
    │   ├── driver_history_screen.dart  # Past collections + PDF export
    │   └── driver_profile_screen.dart  # Profile, vehicle, GreenScore
    └── shared/                         # Shared across all roles
        ├── live_tracking_screen.dart   # Real-time driver GPS map (hotel view)
        ├── terms_privacy_screen.dart
        ├── notifications_screen.dart
        └── support_screen.dart
├── assets/
│   ├── images/                        # App logo, EcoTrade.png (used in PDF header)
│   ├── icons/                         # Icon set
│   └── animations/                    # Lottie animation files
└── pubspec.yaml
```

---

## Features by Role

### HORECA Business (Hotel)
- **Home tab** — eco greeting (CAT-based), stats row (listings, collections, CO₂), recent bids feed, active listings horizontal scroll
- **My Listings tab** — list mode with 84px left image, status pill, waste type, volume, quality, pickup date chips, bids count
  - Eye icon → full detail bottom sheet (photo strip, all fields, bid list)
  - Edit button — only for Open / Draft listings
  - Delete button — only for Open, Draft, and Expired listings (Assigned, Collected, Completed are protected)
- **List Waste** — create / edit listing with photo upload (up to 5), waste type picker, map pin for location, auction settings, QR code generation
- **Bids** — accept or reject incoming recycler bids; bid details with recycler info
- **Pickups tab** — Scheduled and History sub-tabs; "En Route" live banner; tap Map to see live GPS; tap Call to phone driver
- **Profile** — hotel details, green score card with tier

### Recycler
- **Home tab** — company stats, recent bids, nearby listings preview map
- **Marketplace** — browse all open listings; filter by waste type; listing detail with full specs
- **My Bids** — submitted bids; withdraw or increase bid amount
- **Fleet** — manage vehicles and assigned drivers
- **Collections** — pickups assigned to this recycler; status timeline

### Driver
- **Home tab** — CAT greeting, today's progress (stops done / total), next stop card (business name, waste type, map button, call button), upcoming stops queue
- **Collection** — active pickup: QR scanner, verify pickup with scan, mark collected; multi-stop queue shows all active collections
- **Navigation** — OpenStreetMap route map with stop markers and zoom controls
- **Earnings** — period filter; total breakdown; transaction list with date (CAT); PDF export
- **Collection History** — completed collections with search, filter, period selector; PDF export
- **Profile** — vehicle info, rating, GreenScore card, availability toggle

---

## Key Technical Features

### Offline-First Architecture
- **Hive** local cache with 24-hour TTL for all API responses
- Mutation queue stores POST / PATCH / DELETE operations when offline
- `OfflineSyncService` replays the queue automatically on reconnect
- Empty-state UI shown (never fake data) when cache is cold

### Central African Time (CAT = UTC+2)
All dates and times displayed throughout the app use `CatDateUtils`:

| Method | Example Output |
|---|---|
| `formatDate(dt)` | `31/3/2026` |
| `formatDateTime(dt)` | `31/3/2026  09:00 CAT` |
| `formatTime(dt)` | `09:00 CAT` |
| `timeAgo(dt)` | `5m ago`, `3h ago`, `2d ago` |
| `greeting()` | `Good morning` / `Good afternoon` / `Good evening` |

All backend timestamps are stored as UTC; the utility adds the 2-hour CAT offset for display.

### QR Code System
- Each waste listing gets a unique `qr_token` from the backend
- Hotel's listing card shows a compact QR preview; tap to enlarge to full-screen dialog
- Driver taps "Scan QR" on the collection screen; `mobile_scanner` reads the token
- Backend verifies the token and advances collection status to `collected`
- Multi-stop queue: after scanning one listing the next one in the queue is automatically promoted

### PDF Reports
Using the `pdf` + `printing` packages with EcoTrade logo:
- **Driver Collection History** — table of all collections for selected period
- **Driver Earnings** — transaction table with period totals and all-time total
- Both include EcoTrade Rwanda logo header, blue summary stats row, blue-header table, and branded footer
- Shared via native OS share sheet on all platforms

### State Management (Riverpod)
All data flows through typed Riverpod providers:
- `authProvider` — authentication state
- `businessListingsProvider` — hotel's own listings with bids
- `businessCollectionsProvider` — hotel's collections
- `driverRouteProvider` — driver's daily route (synthesised from collections)
- `transactionsProvider` — earnings / transaction history
- `openListingsProvider` — marketplace listings
- `notificationsProvider` — in-app notification feed
- And more in `core/providers/app_providers.dart`

### Real OpenStreetMap Maps (`flutter_map`)
- **Marketplace** — all open listings plotted at real hotel GPS coordinates
- **List Waste** — tap-to-move pin for selecting pickup location
- **Navigation** — driver route map with stop markers
- **Live Tracking** — hotel sees driver's real-time GPS + ETA (30 km/h city estimate)

---

## GreenScore System

GreenScore is calculated on the backend when a collection is marked **Completed** and reflected immediately in the user's profile.

**Formula:**
```
score = min(100, total_kg_or_litres / 100)
```
Every 100 kg / L of waste collected = 1 point, capped at 100.

**Tiers (consistent across mobile and web):**

| Tier | Score |
|---|---|
| Eco Beginner | 0 – 39 |
| Eco Starter | 40 – 59 |
| Eco Champion | 60 – 79 |
| Eco Master | 80 – 100 |

Displayed via the `GreenScoreCard` shared widget (circular progress indicator + tier label).

---

## Environment / Configuration

The API base URL is set in `lib/core/services/api_service.dart`:

```dart
static const String _baseUrl = 'https://api.ecotrade-rwanda.com/api';
```

To use a local backend during development, change this to `http://10.0.2.2:8000/api` (Android emulator) or `http://localhost:8000/api` (Chrome / Windows).

---

## Building for Release

### Android APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Windows Executable

```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

### Web (deploy to any static host)

```bash
flutter build web --release
# Output: build/web/
```

---

## Permissions

| Permission | Used For | Platform |
|---|---|---|
| Internet | All API calls | Android, Windows, Web |
| Camera | QR code scanning | Android, iOS |
| Location | GPS for pickup coordinates and driver tracking | Android, iOS |
| Storage / Photos | Photo upload for waste listings | Android, iOS |
| Notifications | Local push notifications | Android, iOS |

Android permissions are declared in `android/app/src/main/AndroidManifest.xml`.

---

## Technology Stack

| Category | Package | Version |
|---|---|---|
| State management | flutter_riverpod | 2.5.1 |
| Navigation | go_router | 13.2.0 |
| HTTP client | http | 1.2.0 |
| Maps | flutter_map | 6.1.0 |
| Map tiles | OpenStreetMap (via flutter_map) | — |
| Offline cache | hive_flutter | 1.1.0 |
| QR scanner | mobile_scanner | 5.2.0 |
| QR generator | qr_flutter | 4.1.0 |
| PDF generation | pdf | 3.10.8 |
| PDF sharing | printing | 5.13.1 |
| Animations | flutter_animate | 4.5.0 |
| Fonts | google_fonts | 6.2.1 |
| Image picker | image_picker | 1.0.7 |
| Network images | cached_network_image | 3.3.1 |
| Connectivity | connectivity_plus | 5.0.2 |
| Geolocation | geolocator | 11.0.0 |
| Notifications | flutter_local_notifications | 17.2.1 |
| Charts | fl_chart | 0.67.0 |
| Progress indicators | percent_indicator | 4.2.3 |
| Local storage | shared_preferences | 2.2.3 |
| Loading effects | shimmer | 3.0.0 |
| Timeline UI | timeline_tile | 2.0.0 |
| Rating UI | flutter_rating_bar | 4.0.1 |
| SVG | flutter_svg | 2.0.10 |
| Lottie animations | lottie | 3.1.0 |
| OTP input | pinput | 5.0.0 |
| URL launcher | url_launcher | 6.2.6 |
| File picker | file_picker | 8.0.3 |

---

## Demo Credentials

After running `python seed_comprehensive.py` in the backend (password for all: **Password123!**):

| Role | Email |
|---|---|
| Business / Hotel | hotel@kigali.rw |
| Recycler | recycler@greencycle.rw |
| Driver | driver@greencycle.rw |

---

## License

MIT License — see [LICENSE](../LICENSE) in the repository root for details.
