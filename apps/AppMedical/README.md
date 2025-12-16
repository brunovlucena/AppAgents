# 🏥 AppMedical - iOS App for Medical Agent

**WhatsApp-style iOS app for communicating with the medical agent via agent-whatsapp-rust messaging service**

A native SwiftUI app that connects to the medical agent running in your homelab using the WebSocket-based messaging protocol from `agents-whatsapp-rust`.

## 🎯 Features

- **🔌 WebSocket Communication**: Real-time messaging via `agents-whatsapp-rust` messaging-service
- **🏥 Medical Agent**: HIPAA-compliant medical records assistant
- **💬 WhatsApp-style UI**: Beautiful, native iOS chat interface
- **🔄 Real-time Updates**: Live message delivery and status updates
- **📱 iOS Native**: Built with SwiftUI for iPhone

## 📋 Requirements

- iOS 17.0+
- iPhone (device or simulator)
- VPN connection to homelab cluster (or port-forward)
- Xcode 15.0+ (for development)

## 🚀 Quick Start

### 1. Port-forward Messaging Service

```bash
# Port-forward the messaging-service to localhost
kubectl port-forward -n homelab-services svc/messaging-service 8080:80
```

### 2. Open in Xcode

```bash
cd AppMedical
open AppMedical.xcodeproj
```

### 3. Build & Run

1. Open `AppMedical.xcodeproj` in Xcode
2. Select your iPhone (device or simulator)
3. Press `Cmd + R` to build and run

### 4. Configure Connection (Optional)

The app defaults to `http://localhost:8080` for the messaging service. You can configure a custom URL in the app settings or by setting `messaging_api_base_url` in UserDefaults.

## 🏗️ Architecture

```
AppMedical/
├── Models/
│   └── Models.swift          # Chat message models, MedicalAgent enum
├── Services/
│   └── WebSocketService.swift # WebSocket client (agents-whatsapp-rust protocol)
├── ViewModels/
│   └── ChatViewModel.swift   # Chat logic & state management
├── Views/
│   └── ContentView.swift     # Main chat interface
└── AppMedicalApp.swift       # App entry point
```

## 🔌 Communication Flow

1. **Connection**: App connects to `messaging-service` via WebSocket (`ws://localhost:8080/ws`)
2. **Authentication**: Sends auth message with user ID and device info
3. **Messaging**: Sends messages to `agent-medical` via `receiver_id` field
4. **Responses**: Receives agent responses through WebSocket messages
5. **Status Updates**: Message delivery and read receipts

## 📝 Message Format

Messages are sent using the `agents-whatsapp-rust` protocol:

```json
{
  "type": "message",
  "client_message_id": "uuid",
  "idempotency_key": "uuid",
  "payload": {
    "conversation_id": "uuid",
    "receiver_id": "agent-medical",
    "content": "User message text",
    "type": "text",
    "timestamp": 1234567890
  }
}
```

## 🎨 UI Theme

- **Primary Color**: Medical red (`#D93333`)
- **Background**: Light blue tint for medical theme
- **Agent Emoji**: 🏥
- **Agent Name**: "Medical Assistant"

## 🔧 Configuration

### Custom Messaging Service URL

Set `messaging_api_base_url` in UserDefaults or configure in app settings.

### Agent ID

The medical agent ID is hardcoded as `agent-medical` in `Models.swift`.

## 📚 Related Projects

- **agent-medical**: The medical agent backend (knative-lambda-operator)
- **agents-whatsapp-rust**: WebSocket messaging service
- **AppRestaurant**: Similar app for restaurant agents (reference implementation)

## 🐛 Troubleshooting

### Connection Issues

1. **Cannot connect**: Ensure port-forward is running
   ```bash
   kubectl port-forward -n homelab-services svc/messaging-service 8080:80
   ```

2. **WebSocket handshake failed**: Check if messaging-service is running
   ```bash
   kubectl get svc -n homelab-services messaging-service
   ```

3. **Messages not received**: Verify agent-medical is deployed and connected to messaging-service

### Development

- Use Xcode's debugger to inspect WebSocket messages
- Check console logs for connection status
- Verify UserDefaults for stored user ID and configuration

## 📄 License

See parent repository for license information.

