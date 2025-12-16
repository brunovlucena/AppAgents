# AppAgents

Monorepo for iOS agent applications built with SwiftUI and the agents-whatsapp-rust protocol.

## Apps

- **AppRestaurant** - Restaurant agent chat app (Host, Waiter, Sommelier, Chef)
- **AppMedical** - Medical agent chat app (HIPAA-compliant)

## Architecture

All apps share:
- WebSocket service for real-time messaging
- Message persistence layer
- Retry queue with exponential backoff
- Automatic reconnection logic

## Getting Started

### Prerequisites

- Xcode 15.4+
- Swift 6.0+
- CocoaPods (if using pods)
- Fastlane (for CI/CD)

### Setup

```bash
# Install dependencies
bundle install

# Setup each app
cd apps/AppRestaurant
pod install  # if using CocoaPods
```

### Development

```bash
# Run tests for all apps
make test-all

# Build all apps
make build-all

# Run linting
make lint-all
```

## CI/CD

GitHub Actions workflows are configured for:
- Automated testing
- Code quality checks
- TestFlight deployment
- App Store submission

See `.github/workflows/` for details.

## Project Structure

```
AppAgents/
├── apps/
│   ├── AppRestaurant/
│   └── AppMedical/
├── shared/
│   ├── Services/        # Shared services
│   └── Models/         # Shared models
├── .github/
│   └── workflows/      # CI/CD pipelines
├── fastlane/           # Fastlane configuration
└── scripts/            # Build and utility scripts
```

## License

[Your License Here]
