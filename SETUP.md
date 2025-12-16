# AppAgents Monorepo Setup

## Quick Start

```bash
# Clone the repository
git clone git@github.com:brunovlucena/AppAgents.git
cd AppAgents

# Initial setup
make setup

# Run tests
make test

# Build all apps
make build
```

## Repository Structure

```
AppAgents/
├── apps/
│   ├── AppRestaurant/      # Restaurant agent app
│   └── AppMedical/         # Medical agent app
├── shared/                  # Shared code (future)
│   ├── Services/
│   └── Models/
├── .github/
│   └── workflows/          # CI/CD pipelines
├── fastlane/               # Fastlane configs
├── scripts/                # Build scripts
├── Makefile                # Monorepo commands
└── README.md
```

## Available Commands

### All Apps
- `make setup` - Initial setup
- `make test` - Test all apps
- `make build` - Build all apps
- `make lint` - Lint all apps
- `make clean` - Clean all builds

### Specific App
- `make test-AppRestaurant` - Test AppRestaurant
- `make build-AppMedical` - Build AppMedical
- `make lint-AppRestaurant` - Lint AppRestaurant

## CI/CD

GitHub Actions automatically:
- Runs tests on every PR
- Lints code
- Builds apps
- Deploys to TestFlight on main branch

## Adding a New App

1. Create app directory: `apps/YourApp/`
2. Add to `APPS` in Makefile
3. Add to matrix in `.github/workflows/ci.yml`
4. Run `make setup`
