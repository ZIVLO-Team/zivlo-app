# Changelog

All notable changes to Zivlo will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure with Clean/Hexagonal Architecture
- Core layer: error handling, theme, constants
- Catalog feature: domain entities, value objects, use cases
- BLoC pattern implementation for state management
- GitHub Actions workflows for CI/CD
- Design system with colors, typography, and spacing
- Documentation: PRD, Stack, Design, Styles, Brand, Context, AppFlow

### Changed
- Nothing yet

### Deprecated
- Nothing yet

### Removed
- Nothing yet

### Fixed
- Nothing yet

### Security
- Nothing yet

---

## [1.0.0] - 2024-01-XX

### Added
- Initial release
- Offline-first POS system for Android
- Barcode scanning with mobile_scanner
- Shopping cart with discount support
- Multiple payment methods (cash, card, mixed)
- Bluetooth thermal printer support
- Sales history with daily summary
- Product catalog management
- Business configuration
- Dark mode UI optimized for retail environments
- Space Mono font for numbers and prices
- DM Sans font for UI text
- fpdart for functional error handling
- Hive for local database storage
- GoRouter for navigation
- GetIt for dependency injection

### Technical
- Clean/Hexagonal Architecture
- BLoC pattern for state management
- TDD-ready structure
- GitHub Actions for automated builds
- Automated release process
- Comprehensive documentation

---

## Version Naming

Zivlo uses semantic versioning:
- **MAJOR** version for incompatible changes
- **MINOR** version for backwards-compatible features
- **PATCH** version for backwards-compatible bug fixes

**Format**: `MAJOR.MINOR.PATCH` (e.g., `1.0.0`)

---

## Release Checklist

Before each release, ensure:
- [ ] All tests pass
- [ ] Code is properly documented
- [ ] CHANGELOG is updated
- [ ] Version number is updated in pubspec.yaml
- [ ] Git tag is created (vX.X.X)
- [ ] GitHub Release is published with APK
- [ ] Documentation is up to date

---

## Contact

For questions or feedback about releases, please open an issue on GitHub.
