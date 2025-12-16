# Makefile for AppAgents Monorepo
# Usage: make <target>

.PHONY: help install test build lint clean validate release setup

APPS = AppRestaurant AppMedical

# Default target
help:
	@echo "AppAgents Monorepo - iOS Development Automation"
	@echo ""
	@echo "Available targets:"
	@echo "  setup      - Initial setup (install dependencies)"
	@echo "  install    - Install dependencies for all apps"
	@echo "  test       - Run tests for all apps"
	@echo "  test-<app> - Run tests for specific app (e.g., test-AppRestaurant)"
	@echo "  build      - Build all apps"
	@echo "  build-<app>- Build specific app"
	@echo "  lint       - Run SwiftLint for all apps"
	@echo "  lint-<app> - Run SwiftLint for specific app"
	@echo "  validate   - Run all validations"
	@echo "  clean      - Clean all build artifacts"
	@echo "  release    - Release all apps to TestFlight"

# Initial setup
setup:
	@echo "Setting up AppAgents monorepo..."
	bundle install
	@for app in $(APPS); do \
		echo "Setting up $$app..."; \
		cd apps/$$app && \
		if [ -f Podfile ]; then pod install; fi && \
		cd ../..; \
	done
	@echo "Setup complete!"

# Install dependencies
install:
	@echo "Installing dependencies..."
	bundle install
	@for app in $(APPS); do \
		if [ -f apps/$$app/Podfile ]; then \
			echo "Installing pods for $$app..."; \
			cd apps/$$app && pod install && cd ../..; \
		fi; \
	done

# Run tests for all apps
test:
	@echo "Running tests for all apps..."
	@for app in $(APPS); do \
		echo "Testing $$app..."; \
		cd apps/$$app && \
		if [ -f scripts/build.sh ]; then \
			./scripts/build.sh test || exit 1; \
		else \
			xcodebuild test -project $$app.xcodeproj -scheme $$app -destination 'platform=iOS Simulator,name=iPhone 15' || exit 1; \
		fi && \
		cd ../..; \
	done
	@echo "All tests passed!"

# Run tests for specific app
test-%:
	@app=$(subst test-,,$@); \
	echo "Testing $$app..."; \
	cd apps/$$app && \
	if [ -f scripts/build.sh ]; then \
		./scripts/build.sh test; \
	else \
		xcodebuild test -project $$app.xcodeproj -scheme $$app -destination 'platform=iOS Simulator,name=iPhone 15'; \
	fi

# Build all apps
build:
	@echo "Building all apps..."
	@for app in $(APPS); do \
		echo "Building $$app..."; \
		cd apps/$$app && \
		if [ -f scripts/build.sh ]; then \
			./scripts/build.sh build || exit 1; \
		else \
			xcodebuild build -project $$app.xcodeproj -scheme $$app -destination 'platform=iOS Simulator,name=iPhone 15' || exit 1; \
		fi && \
		cd ../..; \
	done
	@echo "All builds succeeded!"

# Build specific app
build-%:
	@app=$(subst build-,,$@); \
	echo "Building $$app..."; \
	cd apps/$$app && \
	if [ -f scripts/build.sh ]; then \
		./scripts/build.sh build; \
	else \
		xcodebuild build -project $$app.xcodeproj -scheme $$app -destination 'platform=iOS Simulator,name=iPhone 15'; \
	fi

# Run SwiftLint for all apps
lint:
	@echo "Running SwiftLint for all apps..."
	@for app in $(APPS); do \
		echo "Linting $$app..."; \
		cd apps/$$app && \
		if [ -f .swiftlint.yml ]; then \
			swiftlint lint --strict || exit 1; \
		fi && \
		cd ../..; \
	done
	@echo "All linting passed!"

# Run SwiftLint for specific app
lint-%:
	@app=$(subst lint-,,$@); \
	echo "Linting $$app..."; \
	cd apps/$$app && \
	if [ -f .swiftlint.yml ]; then \
		swiftlint lint --strict; \
	fi

# Validate all apps
validate:
	@echo "Validating all apps..."
	@for app in $(APPS); do \
		echo "Validating $$app..."; \
		cd apps/$$app && \
		if [ -f scripts/validate.sh ]; then \
			./scripts/validate.sh || exit 1; \
		fi && \
		cd ../..; \
	done
	@echo "All validations passed!"

# Clean all build artifacts
clean:
	@echo "Cleaning all build artifacts..."
	@for app in $(APPS); do \
		echo "Cleaning $$app..."; \
		cd apps/$$app && \
		rm -rf build/ DerivedData/ && \
		if [ -f scripts/build.sh ]; then \
			./scripts/build.sh clean; \
		fi && \
		cd ../..; \
	done
	@echo "Clean complete!"

# Release all apps to TestFlight
release:
	@echo "Releasing all apps to TestFlight..."
	@for app in $(APPS); do \
		echo "Releasing $$app..."; \
		cd apps/$$app && \
		fastlane beta && \
		cd ../..; \
	done

# CI target
ci: lint test build
