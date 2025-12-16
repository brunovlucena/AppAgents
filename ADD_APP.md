# Adding an iOS App to AppAgents Monorepo

## Steps to Add a New App

1. **Create app directory structure:**
   ```bash
   mkdir -p apps/YourAppName
   ```

2. **Copy your Xcode project:**
   ```bash
   cp -r /path/to/YourApp.xcodeproj apps/YourAppName/
   cp -r /path/to/YourApp/ apps/YourAppName/YourAppName/
   ```

3. **Update Makefile:**
   Add your app to the `APPS` variable:
   ```makefile
   APPS = AppRestaurant AppMedical YourAppName
   ```

4. **Update CI/CD:**
   Add your app to `.github/workflows/ci.yml` matrix:
   ```yaml
   strategy:
     matrix:
       app: [AppRestaurant, AppMedical, YourAppName]
   ```

5. **Add app-specific files (if needed):**
   - `.swiftlint.yml` in `apps/YourAppName/`
   - `fastlane/Fastfile` in `apps/YourAppName/`
   - `scripts/` in `apps/YourAppName/`

6. **Test:**
   ```bash
   make test-YourAppName
   make build-YourAppName
   ```

## Current Apps

- **AppRestaurant** - Restaurant agent chat
- **AppMedical** - Medical agent chat

## Shared Code

Future shared code will go in:
- `shared/Services/` - Shared services (WebSocket, Persistence, etc.)
- `shared/Models/` - Shared data models
