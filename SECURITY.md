# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of Zivlo seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### How to Report

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to **security@mowgliph.dev** with the following information:

1. Description of the vulnerability
2. Steps to reproduce the issue
3. Potential impact
4. Suggested fix (if any)

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

### Security Considerations

Zivlo is designed with security in mind:

- **No telemetry** — The app does not send any data to external servers
- **Local storage only** — All data is stored locally using Hive encryption
- **Minimal permissions** — Only requests `CAMERA` and `BLUETOOTH` permissions
- **Offline-first** — No internet connection required, reducing attack surface
- **No third-party analytics** — No Firebase, Sentry, or similar services

### Known Security Features

1. **Data Protection**
   - All sales data is stored locally in the app sandbox
   - No cloud synchronization in MVP (reduces attack surface)
   - Hive boxes can be encrypted with `hive_cipher` (future enhancement)

2. **Permission Model**
   - Camera permission only for barcode scanning
   - Bluetooth permission only for thermal printer connection
   - No internet permission requested

3. **Payment Security**
   - No payment card data is stored or processed by the app
   - Card payments are handled externally by POS terminals
   - The app only records the payment method type (cash/card/mixed)

### Security Best Practices for Contributors

When contributing to Zivlo, please follow these security best practices:

1. **Never add telemetry or analytics** without explicit discussion and approval
2. **Never store sensitive data** in plain text (use Hive encryption for financial data)
3. **Minimize permissions** — only request what's absolutely necessary
4. **Validate all input** — use fpdart's `Either` for explicit error handling
5. **Follow secure coding practices** — no hardcoded secrets, use environment variables for CI/CD

### Security Updates

Security updates will be released as patch versions (e.g., `1.0.1` → `1.0.2`). Critical security fixes may result in an immediate release outside the normal release cycle.

All security updates will be documented in the [CHANGELOG](CHANGELOG.md) with appropriate detail (without exposing vulnerabilities).

---

Thank you for helping keep Zivlo and our users safe!
