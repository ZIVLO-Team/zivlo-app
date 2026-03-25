# Contributing to Zivlo

First off, thank you for considering contributing to Zivlo! It's people like you that make Zivlo such a great tool for small businesses across Latin America.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to **conduct@mowgliph.dev**.

## I Don't Want to Read This Whole Thing, I Just Have a Question

> **Please don't open an issue for questions.**

Instead, check if there's already a discussion in the [Discussions](https://github.com/mowgliph/zivlo/discussions) tab. If not, start a new discussion there.

## What Should I Know Before I Get Started?

### Architecture

Zivlo uses **Clean/Hexagonal Architecture**. This is not optional — it's core to the project's maintainability and testability.

Before contributing, please read:
- [`docs/Context.md`](docs/Context.md) — Architecture overview
- [`docs/Stack.md`](docs/Stack.md) — Technology stack
- [`.qwen/AGENTS.md`](.qwen/AGENTS.md) — Development guidelines

**Key principles:**
1. **Domain is pure Dart** — No Flutter imports in `domain/`
2. **Use cases return `Either<Failure, T>`** — No exceptions in the domain
3. **Widgets have no business logic** — All logic in BLoCs
4. **One feature, one directory** — All code for a feature lives in `features/feature-name/`

### Development Model

**Important**: This project follows a **local-code-only** development model.

- ❌ **DO NOT** compile or run Flutter locally
- ❌ **DO NOT** run `flutter build`, `flutter run`, `flutter pub get`
- ✅ **DO** write pure code locally
- ✅ **DO** commit your changes
- ✅ **DO** let GitHub Actions handle compilation and validation

GitHub Actions automatically:
- Runs `flutter analyze`
- Executes all tests with `flutter test`
- Builds the APK with `flutter build apk --release`
- Creates releases when tags are pushed

### Project Structure

```
lib/
├── core/                    # Shared utilities, theme, error handling
├── features/                # Feature modules
│   ├── catalog/            # Product catalog management
│   ├── cart/               # Shopping cart
│   ├── scanner/            # Barcode scanning
│   ├── checkout/           # Payment processing
│   ├── printer/            # Bluetooth printer
│   ├── sales_history/      # Sales history
│   └── settings/           # Business configuration
└── injection_container.dart # Dependency injection setup
```

Each feature follows the same structure:
```
features/catalog/
├── domain/
│   ├── entities/           # Business objects (Product, etc.)
│   ├── repositories/       # Interface definitions
│   └── value_objects/      # Value objects (Barcode, Money, etc.)
├── application/
│   ├── usecases/           # Business logic orchestration
│   └── dtos/               # Data transfer objects
├── infrastructure/
│   ├── repositories/       # Concrete implementations (Hive)
│   └── models/             # Data models (Hive models, etc.)
└── presentation/
    ├── bloc/               # BLoCs, events, states
    └── pages/              # Flutter widgets
```

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report for Zivlo. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

**Before creating bug reports**, please check the [existing issues](https://github.com/mowgliph/zivlo/issues) as you might find out that you don't need to create one.

When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed and what behavior you expected**
- **Include screenshots if possible**
- **Include device information** (Android version, device model)

**Template:**
```markdown
### Description
[Clear description of the issue]

### Steps to Reproduce
1. [First step]
2. [Second step]
3. [and so on...]

### Expected Behavior
[What you expected to happen]

### Actual Behavior
[What actually happened]

### Environment
- Device: [e.g., Samsung Galaxy A10]
- Android Version: [e.g., 9.0]
- Zivlo Version: [e.g., 1.0.0]

### Screenshots
[If applicable, add screenshots to help explain your problem]
```

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for Zivlo, including completely new features and minor improvements to existing functionality.

**Before creating enhancement suggestions**, please check the [existing issues](https://github.com/mowgliph/zivlo/issues) and [discussions](https://github.com/mowgliph/zivlo/discussions).

When you are creating an enhancement suggestion, please include as many details as possible:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior and explain which behavior you expected to see instead**
- **Explain why this enhancement would be useful**

### Pull Requests

The process described here has several goals:

- Maintain Zivlo's quality
- Fix problems that are important to users
- Engage the community in working toward the best possible Zivlo
- Enable a sustainable system for Zivlo's maintainers to review contributions

Please follow these steps to have your contribution considered by the maintainers:

1. **Fork the repository** and create your branch from `main`
2. **Follow the development model** — write code locally, let GitHub Actions compile
3. **Write tests** for your code (TDD is preferred)
4. **Ensure your code follows the style guidelines** (see below)
5. **Verify that GitHub Actions passes** on your pull request
6. **Update documentation** if necessary

**Before submitting your PR:**
- [ ] Does your code follow the architecture (domain/application/infrastructure/presentation)?
- [ ] Are there tests for your changes?
- [ ] Does your code pass `flutter analyze` (will run in GitHub Actions)?
- [ ] Is your code properly documented?
- [ ] Did you update the CHANGELOG if this is a user-facing change?

### Development Workflow

1. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Write your code** following the architecture and conventions

3. **Commit your changes** with clear, descriptive messages:
   ```bash
   git commit -m "feat: add discount by percentage to cart"
   ```

4. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Open a Pull Request** on GitHub

6. **Wait for GitHub Actions** to complete all checks

7. **Address any review feedback** if requested

### Style Guidelines

#### Naming Conventions

```dart
// ✅ DO
class Product {}                    // Entities: PascalCase
class Barcode {}                    // Value Objects: PascalCase
abstract class IProductRepository {} // Interfaces: PascalCase with 'I' prefix
class GetProductByBarcode {}        // Use Cases: PascalCase (verb + noun)
class CatalogBloc {}                // BLoCs: PascalCase with 'Bloc' suffix
class ProductCard {}                // Widgets: PascalCase with type suffix

// ❌ DON'T
class product {}                    // No camelCase for classes
class ProductRepository { }         // No missing 'I' prefix for interfaces
```

#### Error Handling

```dart
// ✅ DO: Use Either from fpdart
Future<Either<Failure, Product>> execute(String barcode) async {
  final product = await repository.getByBarcode(barcode);
  if (product == null) {
    return Left(ProductNotFound(barcode));
  }
  return Right(product);
}

// ❌ DON'T: Throw exceptions in domain
throw ProductNotFoundException();  // Never do this in domain layer
```

#### BLoC Pattern

```dart
// ✅ DO: Immutable states with Equatable
abstract class CatalogState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CatalogLoaded extends CatalogState {
  final List<Product> products;
  
  CatalogLoaded(this.products);
  
  @override
  List<Object?> get props => [products];
}

// ❌ DON'T: Mutable states
class CatalogLoaded extends CatalogState {
  List<Product> products;  // Never mutable
  CatalogLoaded(this.products);
}
```

#### Design System

Always use the colors and typography from [`docs/Styles.md`](docs/Styles.md):

```dart
// ✅ DO
static const colorAccent = Color(0xFFE94560);
TextStyle(
  fontFamily: 'Space Mono',
  fontWeight: FontWeight.bold,
)

// ❌ DON'T
static const myColor = Color(0xFFFF0000);  // Use design system colors
TextStyle(fontFamily: 'Arial')  // Use Space Mono or DM Sans
```

### Testing

Write tests for all new features and bug fixes. The project uses:

- **Unit tests** for domain entities and use cases
- **BLoC tests** using `bloc_test` package
- **Widget tests** for critical UI components (optional in MVP)

**Example test:**
```dart
test('debe retornar producto cuando el barcode existe', () async {
  // Arrange
  when(() => mockRepository.getByBarcode('123'))
    .thenAnswer((_) async => Right(product));
  
  // Act
  final result = await usecase.execute('123');
  
  // Assert
  expect(result, Right(product));
});
```

Run tests locally (optional, GitHub Actions will verify):
```bash
flutter test
```

### Documentation

When adding new features, update the relevant documentation:

- **User-facing features** → Update [`README.md`](README.md)
- **API changes** → Update inline code documentation
- **Architecture changes** → Update [`docs/Context.md`](docs/Context.md)
- **Design changes** → Update [`docs/Styles.md`](docs/Styles.md) or [`docs/Design.md`](docs/Design.md)

## Release Process

Releases are created automatically when a tag is pushed:

```bash
# Tag a release
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will:
1. Build the APK
2. Create a GitHub Release
3. Upload the APK as a release asset

## Questions?

Feel free to ask questions in the [Discussions](https://github.com/mowgliph/zivlo/discussions) tab or reach out to the maintainers.

---

Thank you for contributing to Zivlo! 🎉
