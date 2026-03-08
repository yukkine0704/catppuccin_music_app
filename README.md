# The Vinyl Sanctuary

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11%2B-blue?style=flat-square" alt="Flutter Version">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-purple?style=flat-square" alt="Architecture">
</p>

A professional **offline-first music player** built with Flutter, featuring a **minimalist retro-pastel aesthetic** powered by [Catppuccin](https://github.com/catppuccin/catppuccin) colors and [Material Design 3 Expressive (M3E)](https://m3.material.io) components.

---

## ✨ Features

### Core Features
- **Offline Music Playback** — Play local audio files directly from your device
- **Background Audio** — Continue playing music when app is in background with lock screen controls
- **Queue Management** — View and manage your playback queue
- **Shuffle & Repeat** — Shuffle playback and repeat modes (off/all/one)

### UI/UX Features
- **Catppuccin Themes** — 4 flavor options: Mocha, Latte, Frappé, Macchiato
- **Vinyl Animation** — Animated vinyl record visualization during playback
- **Mini Player** — Compact player bar with quick controls
- **Now Playing Sheet** — Expandable full-screen player with gestures

### Architecture
- **Clean Architecture** — Feature-first structure with proper separation of concerns
- **Riverpod** — Reactive state management
- **GetIt** — Dependency injection
- **dartz** — Functional programming with `Either<Failure, Success>` pattern

---

## 📱 Screenshots

| Home | Albums | Library | Now Playing |
|------|--------|---------|-------------|
| ![Home](https://via.placeholder.com/300x600/1e1e2e/cdd6f4?text=Home) | ![Albums](https://via.placeholder.com/300x600/1e1e2e/cdd6f4?text=Albums) | ![Library](https://via.placeholder.com/300x600/1e1e2e/cdd6f4?text=Library) | ![Now Playing](https://via.placeholder.com/300x600/1e1e2e/cdd6f4?text=Now+Playing) |

---

## 🏗️ Project Structure

```
lib/
├── core/                          # Shared core utilities
│   ├── di/                        # Dependency injection
│   │   └── injection_container.dart
│   └── theme/                     # Theme configuration
│       └── catppuccin_theme.dart
├── features/                      # Feature modules (Clean Architecture)
│   ├── audio_player/              # Audio playback feature
│   │   ├── data/
│   │   │   └── datasources/      # AudioPlayerService
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/        # Riverpod providers
│   │       ├── screens/         # NowPlayingScreen
│   │       └── widgets/         # MiniPlayer, QueueSheet, AnimatedPlayerSheet
│   ├── home/                     # Home & Albums feature
│   │   ├── domain/
│   │   │   └── entities/        # Album entity
│   │   └── presentation/
│   │       ├── providers/        # AlbumsProvider
│   │       ├── screens/         # HomeScreen, AlbumsScreen
│   │       └── widgets/         # AlbumCard, AlbumFilterSheet
│   ├── library/                  # Local music library
│   │   ├── data/
│   │   │   └── datasources/     # LocalMusicDatasource
│   │   ├── domain/
│   │   │   └── entities/        # Track entity
│   │   └── presentation/
│   │       ├── providers/        # LibraryProvider
│   │       └── screens/         # LibraryScreen
│   ├── metadata_fetcher/         # Metadata fetching
│   └── settings/                 # App settings
│       └── presentation/
│           ├── providers/        # FlavorProvider
│           └── screens/         # SettingsScreen
└── main.dart                     # App entry point
```

### Architecture Principles

| Layer | Purpose |
|-------|---------|
| **data/** | DTOs, DataSources, Repository implementations |
| **domain/** | Pure entities, Value Objects, Repository interfaces |
| **presentation/** | UI (Widgets/Screens) and Riverpod providers (Notifiers) |

---

## 🎨 Design System

### Catppuccin Colors

The app uses **Catppuccin** as its primary color system with 4 available flavors:

| Flavor | Description | Use Case |
|--------|-------------|----------|
| **Mocha** | Rich dark theme (default) | Primary dark experience |
| **Latte** | Light cream theme | Light mode option |
| **Frappé** | Muted pastel dark | Alternative dark |
| **Macchiato** | Bold dark with contrast | High contrast dark |

### Material Design 3 Expressive (M3E)

UI components follow M3E guidelines with:
- **Expressive animations** with spring physics
- **Dynamic color** roles (Primary, Secondary, Tertiary)
- **Surface containers** for hierarchy
- **Emphasized typography** for key moments

### Typography

- **Font Family**: [Lexend](https://fonts.google.com/specimen/Lexend) (via Google Fonts)
- **Design Tokens**: Using `md.sys.*` naming convention for semantic tokens

---

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State & DI
  provider: ^6.1.1
  get_it: ^8.0.3
  riverpod: ^2.6.1
  flutter_riverpod: ^2.6.1
  dartz: ^0.10.1

  # Audio
  just_audio: ^0.10.5
  audio_service: ^0.18.12

  # UI & Design
  catppuccin_flutter: ^1.0.0
  m3e_collection: ^0.3.7
  m3e_design: ^0.2.1
  google_fonts: ^8.0.2

  # Storage & Utils
  path_provider: ^2.1.2
  shared_preferences: ^2.2.2
  permission_handler: ^12.0.1
  dio: ^5.4.0
```

### M3E Components Used
- `app_bar_m3e` — Custom AppBar
- `button_m3e` — Expressive buttons
- `button_group_m3e` — Button groups
- `icon_button_m3e` — Icon buttons
- `navigation_bar_m3e` — Bottom navigation
- `slider_m3e` — Progress slider
- `fab_m3e` — Floating action button
- `loading_indicator_m3e` — Loading states
- `progress_indicator_m3e` — Progress indicators

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.11.0+
- Dart SDK 3.11.0+
- Android SDK for Android builds
- Xcode for iOS builds (macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/catppuccin_music_app.git
   cd catppuccin_music_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building

**Android APK:**
```bash
flutter build apk --debug
# or for release
flutter build apk --release
```

**iOS:**
```bash
flutter build ios
```

---

## 📋 Key Files

| File | Description |
|------|-------------|
| [`lib/main.dart`](lib/main.dart) | App entry point with DI and audio service initialization |
| [`lib/core/theme/catppuccin_theme.dart`](lib/core/theme/catppuccin_theme.dart) | Theme configuration with Catppuccin flavors |
| [`lib/core/di/injection_container.dart`](lib/core/di/injection_container.dart) | Dependency injection setup |
| [`lib/features/audio_player/data/datasources/audio_player_service.dart`](lib/features/audio_player/data/datasources/audio_player_service.dart) | Audio playback service |
| [`lib/features/settings/presentation/providers/flavor_provider.dart`](lib/features/settings/presentation/providers/flavor_provider.dart) | Theme flavor state management |

---

## 🛠️ Development

### Code Conventions

Following the project's coding standards:

- **Naming**:
  - Booleans: `isLoading`, `hasError`, `isAuth`
  - Functions: `fetchData`, `saveUser`
  - Classes: `PascalCase`
  - Files: `snake_case`

- **Quality**:
  - Max 20 instructions per function
  - Strict typing (no `dynamic` or `var` for public APIs)
  - Trailing commas for all constructors
  - Early returns with guard clauses

### Running Tests

```bash
flutter test
```

### Analysis

```bash
flutter analyze
```

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Catppuccin](https://github.com/catppuccin/catppuccin) — Beautiful pastel color scheme
- [Material Design 3 Expressive](https://m3.material.io) — Expressive UI components
- [just_audio](https://github.com/ryanheise/just_audio) — Powerful audio playback
- [Flutter](https://flutter.dev) — Cross-platform UI toolkit

---

<p align="center">
  Made with ❤️ using Flutter & Catppuccin
</p>
