# GutCheck 🥗

A local-first, cross-platform digestive health tracker built with Flutter. Track meals, wellness scores, and discover how different foods impact your digestive health.

## Features

- 📱 **Cross-Platform**: iOS, Android, Web (PWA), Linux, and macOS
- 🔒 **Local-First**: All data stored locally on your device—no cloud sync required
- 📊 **Analytics**: Visual charts and trends for meals and wellness scores
-  **Data Export**: Export meals and wellness data as JSON
- 🌍 **Progressive Web App**: Install as a PWA on any device with a web browser
- 🎯 **Ingredient Tracking**: Extensive ingredient database for quick meal logging
- 🌙 **Offline First**: Full functionality without internet connectivity

## Architecture

- **Framework**: Flutter 3.11+
- **Database**: Isar (native/mobile) + LocalStorage/Hive (web)
- **State Management**: Riverpod 2.5+
- **Navigation**: GoRouter 14+
- **Charts**: FL Chart 0.68+
- **Localization**: intl + Flutter i18n

## Getting Started

### Prerequisites

- Flutter SDK 3.11.0 or later: [Install Flutter](https://flutter.dev/docs/get-started/install)
- For iOS: Xcode 14+ with CocoaPods
- For Android: Android SDK, build tools 34+
- For Web: Modern browser with PWA support

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/FreaxMATE/GutCheck.git
   cd GutCheck
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (Isar, localization, etc.)**
   ```bash
   flutter pub run build_runner build
   ```

### Running the App

**Development (with hot reload)**
```bash
flutter run
```

**Specific platform**
```bash
flutter run -d ios      # iOS simulator/device
flutter run -d android  # Android emulator/device
flutter run -d chrome   # Web (Chrome)
flutter run -d linux    # Linux desktop
```

### Building for Production

**Android (APK)**
```bash
flutter build apk --release
```

**Android (App Bundle for Play Store)**
```bash
flutter build appbundle --release
```

**iOS**
```bash
flutter build ios --release
```

**Web (PWA)**
```bash
flutter build web --release
```

**Linux**
```bash
flutter build linux --release
```

## Project Structure

```
lib/
  ├── core/              # Core utilities, constants, themes
  ├── features/          # Feature modules (meals, wellness, etc.)
  └── main.dart          # App entry point

android/               # Android platform code
ios/                   # iOS platform code
web/                   # Web platform code & PWA assets
linux/                 # Linux platform code

test/                  # Unit and widget tests
```

## Configuration

### App Icons
Replace `gutcheck.png` in the root directory with your icon (minimum 1024×1024px), then regenerate:
```bash
flutter pub run flutter_launcher_icons
```

### Localization
Add new translations in `lib/l10n/` YAML files and rebuild to generate localized strings.

### Database
Isar models are in `lib/core/models/`. After modifying, regenerate:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes and test**
   ```bash
   flutter analyze
   flutter test
   ```

3. **Format code**
   ```bash
   dart format lib/ test/
   ```

4. **Commit and push**
   ```bash
   git add .
   git commit -m "feat: description of changes"
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request**

## Known Issues & Limitations

- **Web Build**: Isar has limitations on web due to JavaScript integer constraints. The current implementation uses Hive for web data persistence.
- **iOS PWA Icons**: Requires explicit cache clearing in Safari settings for icon updates to appear on home screen.

See [WEB_BUILD_NOTES.md](WEB_BUILD_NOTES.md) for web-specific considerations.

## Testing

Run all tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please ensure code is well-tested and follows Dart/Flutter best practices.

## License

This project is licensed under the GNU Affero General Public License v3 (AGPLv3)—see the [LICENSE](LICENSE) file for details.

## Website

A modern Astro landing page is available in the `astro-site` folder:
- `astro-site/src/pages/index.astro`
- `astro-site/package.json`
- `astro-site/astro.config.mjs`

Run locally:
```bash
cd astro-site
npm install
npm run dev
```

GitHub Pages deployment:
1. Ensure branch names are `main` or `develop`.
2. Push to repo; workflow `astro-gh-pages` deploys to `gh-pages` branch.
3. In GitHub repo settings > Pages, set source to `gh-pages` branch / `/`.

After deploy, site will be available at `https://<owner>.github.io/<repo>`.

## Support

For questions or issues:
- Open an [issue](https://github.com/FreaxMATE/GutCheck/issues) on GitHub
- Check existing [discussions](https://github.com/FreaxMATE/GutCheck/discussions)

## Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Database powered by [Isar](https://isar.dev) and [Hive](https://hivedb.dev)
