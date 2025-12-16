# AppRestaurant

Restaurant agent chat application.

## Status

⚠️ **Source files need to be added**

The Xcode project is set up, but the Swift source files need to be added to the `AppRestaurant/` directory.

## Expected Structure

```
AppRestaurant/
├── AppRestaurant/
│   ├── AppRestaurantApp.swift
│   ├── ContentView.swift
│   ├── Models/
│   │   └── Models.swift
│   ├── Services/
│   │   ├── WebSocketService.swift
│   │   ├── MessagePersistenceService.swift
│   │   └── RetryQueue.swift
│   └── ViewModels/
│       └── ChatViewModel.swift
├── AppRestaurant.xcodeproj
└── AppRestaurantTests/
```

## Adding Source Files

Once source files are added, the CI/CD pipeline will automatically:
- Run SwiftLint
- Run tests
- Build the app
- Deploy to TestFlight (on main branch)
