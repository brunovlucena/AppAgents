//
//  WebSocketService.swift
//  AppRestaurant
//
//  WebSocket service implementing agents-whatsapp-rust protocol
//

import Foundation
import Combine
import UIKit

enum WebSocketMessageType: String, Codable {
    // Client → Server
    case auth
    case message
    case deliveryAck = "delivery_ack"
    case readReceipt = "read_receipt"
    case heartbeat
    case retransmit
    
    // Server → Client
    case authSuccess = "auth_success"
    case messageAck = "message_ack"
    case messages
    case heartbeatAck = "heartbeat_ack"
    case migration
}

struct WebSocketMessage: Codable {
    let type: WebSocketMessageType
    let clientMessageId: String?
    let idempotencyKey: String?
    let messageId: String?
    let payload: WebSocketPayload?
    let timestamp: Int64?
    
    enum CodingKeys: String, CodingKey {
        case type
        case clientMessageId = "client_message_id"
        case idempotencyKey = "idempotency_key"
        case messageId = "message_id"
        case payload
        case timestamp
    }
}

struct WebSocketPayload: Codable {
    // Auth
    let userId: String?
    let authToken: String?
    let deviceId: String?
    let platform: String?
    let appVersion: String?
    
    // Auth Success
    let sessionId: String?
    let serverTime: Int64?
    let unreadCount: Int?
    
    // Message
    let conversationId: String?
    let receiverId: String?
    let senderId: String?
    let content: String?
    let messageType: String?
    let mediaUrl: String?
    let replyToMessageId: String?
    let sequenceNumber: Int?
    let status: String?
    
    // Migration
    let newEndpoint: String?
    let sessionToken: String?
    
    // Messages (array)
    let messages: [MessagePayload]?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case authToken = "auth_token"
        case deviceId = "device_id"
        case platform
        case appVersion = "app_version"
        case sessionId = "session_id"
        case serverTime = "server_time"
        case unreadCount = "unread_count"
        case conversationId = "conversation_id"
        case receiverId = "receiver_id"
        case senderId = "sender_id"
        case content
        case messageType = "type"
        case mediaUrl = "media_url"
        case replyToMessageId = "reply_to_message_id"
        case sequenceNumber = "sequence_number"
        case status
        case newEndpoint = "new_endpoint"
        case sessionToken = "session_token"
        case messages
    }
}

struct MessagePayload: Codable {
    let messageId: String
    let sequenceNumber: Int
    let content: String
    let timestamp: Int64
    
    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case sequenceNumber = "sequence_number"
        case content
        case timestamp
    }
}

enum WebSocketConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case authenticated
    case error(String)
}

@MainActor
class WebSocketService: ObservableObject {
    static let shared = WebSocketService()
    
    @Published var connectionState: WebSocketConnectionState = .disconnected
    @Published var receivedMessages: [ReceivedMessage] = []
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var heartbeatTimer: Timer?
    private var reconnectTimer: Timer?
    private var urlSession: URLSession?
    
    private var userId: String?
    private var conversationId: String?
    private var lastSequenceNumber: [String: Int] = [:] // conversation_id -> sequence_number
    
    private let heartbeatInterval: TimeInterval = 5.0
    private let reconnectDelay: TimeInterval = 2.0
    
    private init() {}
    
    // MARK: - Connection Management
    
    func connect(baseURL: String, userId: String, authToken: String? = nil) async {
        guard connectionState != .connecting && connectionState != .connected && connectionState != .authenticated else {
            return
        }
        
        self.userId = userId
        self.storedBaseURL = baseURL
        
        // Convert http:// to ws:// and https:// to wss://
        // Remove trailing slash if present
        var cleanBaseURL = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        let wsURL: String
        if cleanBaseURL.hasPrefix("http://") {
            wsURL = cleanBaseURL.replacingOccurrences(of: "http://", with: "ws://") + "/ws"
        } else if cleanBaseURL.hasPrefix("https://") {
            wsURL = cleanBaseURL.replacingOccurrences(of: "https://", with: "wss://") + "/ws"
        } else if cleanBaseURL.hasPrefix("ws://") || cleanBaseURL.hasPrefix("wss://") {
            wsURL = cleanBaseURL + (cleanBaseURL.hasSuffix("/ws") ? "" : "/ws")
        } else {
            // Assume http if no protocol specified
            wsURL = "ws://" + cleanBaseURL + "/ws"
        }
        
        guard let url = URL(string: wsURL) else {
            connectionState = .error("Invalid WebSocket URL: \(wsURL)")
            return
        }
        
        connectionState = .connecting
        
        // Create URLSession with proper configuration for WebSocket
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        let session = URLSession(configuration: config)
        self.urlSession = session
        
        let task = session.webSocketTask(with: url)
        self.webSocketTask = task
        
        task.resume()
        
        // Update state to connected (authentication will happen next)
        connectionState = .connected
        
        // Start receiving messages immediately
        receiveMessages()
        
        // Send authentication
        await authenticate(userId: userId, authToken: authToken)
        
        // Start heartbeat
        startHeartbeat()
    }
    
    func disconnect() {
        stopHeartbeat()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        urlSession = nil
        connectionState = .disconnected
    }
    
    // MARK: - Authentication
    
    private func authenticate(userId: String, authToken: String?) async {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let platform = "ios"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        let authPayload = WebSocketPayload(
            userId: userId,
            authToken: authToken,
            deviceId: deviceId,
            platform: platform,
            appVersion: appVersion,
            sessionId: nil,
            serverTime: nil,
            unreadCount: nil,
            conversationId: nil,
            receiverId: nil,
            senderId: nil,
            content: nil,
            messageType: nil,
            mediaUrl: nil,
            replyToMessageId: nil,
            sequenceNumber: nil,
            status: nil,
            newEndpoint: nil,
            sessionToken: nil,
            messages: nil
        )
        
        let authMessage = WebSocketMessage(
            type: .auth,
            clientMessageId: nil,
            idempotencyKey: nil,
            messageId: nil,
            payload: authPayload,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
        
        await sendMessage(authMessage)
    }
    
    // MARK: - Message Sending
    
    func sendTextMessage(
        content: String,
        conversationId: String,
        receiverId: String,
        agentRole: AgentRole
    ) async -> String? {
        guard connectionState == .authenticated else {
            return nil
        }
        
        let clientMessageId = UUID().uuidString
        let idempotencyKey = UUID().uuidString
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        
        // For restaurant agents, receiver_id is the agent ID
        let agentId = "agent-restaurant-\(agentRole.rawValue)"
        
        let messagePayload = WebSocketPayload(
            userId: nil,
            authToken: nil,
            deviceId: nil,
            platform: nil,
            appVersion: nil,
            sessionId: nil,
            serverTime: nil,
            unreadCount: nil,
            conversationId: conversationId,
            receiverId: agentId,
            senderId: nil,
            content: content,
            messageType: "text",
            mediaUrl: nil,
            replyToMessageId: nil,
            sequenceNumber: nil,
            status: nil,
            newEndpoint: nil,
            sessionToken: nil,
            messages: nil
        )
        
        let message = WebSocketMessage(
            type: .message,
            clientMessageId: clientMessageId,
            idempotencyKey: idempotencyKey,
            messageId: nil,
            payload: messagePayload,
            timestamp: timestamp
        )
        
        await sendMessage(message)
        return clientMessageId
    }
    
    private func sendMessage(_ message: WebSocketMessage) async {
        guard let task = webSocketTask else {
            print("WebSocket: Cannot send message - no active connection")
            // Add to retry queue if it's a user message
            if message.type == .message, let payload = message.payload {
                await addToRetryQueue(message: message, payload: payload)
            }
            return
        }
        
        do {
            // Manual encoding to match the exact schema
            var json: [String: Any] = ["type": message.type.rawValue]
            
            if let clientMessageId = message.clientMessageId {
                json["client_message_id"] = clientMessageId
            }
            if let idempotencyKey = message.idempotencyKey {
                json["idempotency_key"] = idempotencyKey
            }
            if let messageId = message.messageId {
                json["message_id"] = messageId
            }
            if let timestamp = message.timestamp {
                json["timestamp"] = timestamp
            }
            if let payload = message.payload {
                let payloadDict: [String: Any] = {
                    var dict: [String: Any] = [:]
                    
                    if let userId = payload.userId { dict["user_id"] = userId }
                    if let authToken = payload.authToken { dict["auth_token"] = authToken }
                    if let deviceId = payload.deviceId { dict["device_id"] = deviceId }
                    if let platform = payload.platform { dict["platform"] = platform }
                    if let appVersion = payload.appVersion { dict["app_version"] = appVersion }
                    if let sessionId = payload.sessionId { dict["session_id"] = sessionId }
                    if let serverTime = payload.serverTime { dict["server_time"] = serverTime }
                    if let unreadCount = payload.unreadCount { dict["unread_count"] = unreadCount }
                    if let conversationId = payload.conversationId { dict["conversation_id"] = conversationId }
                    if let receiverId = payload.receiverId { dict["receiver_id"] = receiverId }
                    if let senderId = payload.senderId { dict["sender_id"] = senderId }
                    if let content = payload.content { dict["content"] = content }
                    if let messageType = payload.messageType { dict["type"] = messageType }
                    if let mediaUrl = payload.mediaUrl { dict["media_url"] = mediaUrl }
                    if let replyToMessageId = payload.replyToMessageId { dict["reply_to_message_id"] = replyToMessageId }
                    if let sequenceNumber = payload.sequenceNumber { dict["sequence_number"] = sequenceNumber }
                    if let status = payload.status { dict["status"] = status }
                    if let newEndpoint = payload.newEndpoint { dict["new_endpoint"] = newEndpoint }
                    if let sessionToken = payload.sessionToken { dict["session_token"] = sessionToken }
                    if let messages = payload.messages {
                        dict["messages"] = messages.map { msg in
                            [
                                "message_id": msg.messageId,
                                "sequence_number": msg.sequenceNumber,
                                "content": msg.content,
                                "timestamp": msg.timestamp
                            ]
                        }
                    }
                    return dict
                }()
                
                if !payloadDict.isEmpty {
                    json["payload"] = payloadDict
                }
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: json)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("WebSocket: Failed to encode message to JSON string")
                return
            }
            
            let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
            try await task.send(wsMessage)
        } catch {
            print("Error sending WebSocket message: \(error)")
            connectionState = .error("Failed to send message: \(error.localizedDescription)")
            // Add to retry queue if it's a user message
            if message.type == .message, let payload = message.payload {
                await addToRetryQueue(message: message, payload: payload)
            }
        }
    }
    
    private func addToRetryQueue(message: WebSocketMessage, payload: WebSocketPayload) async {
        guard let content = payload.content,
              let conversationId = payload.conversationId,
              let receiverId = payload.receiverId else {
            return
        }
        
        // Extract agent role from receiver_id if it's a restaurant agent
        let agentRole: String? = {
            if receiverId.contains("agent-restaurant-") {
                let roleString = receiverId.replacingOccurrences(of: "agent-restaurant-", with: "")
                return roleString
            }
            return nil
        }()
        
        let pendingMessage = PendingMessage(
            id: message.clientMessageId ?? UUID().uuidString,
            content: content,
            conversationId: conversationId,
            receiverId: receiverId,
            agentRole: agentRole
        )
        
        await RetryQueue.shared.enqueue(pendingMessage)
    }
    
    // MARK: - Message Receiving
    
    private func receiveMessages() {
        guard let task = webSocketTask else { return }
        
        task.receive { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                switch result {
                case .success(let message):
                    switch message {
                    case .string(let text):
                        await self.handleMessage(text)
                    case .data(let data):
                        if let text = String(data: data, encoding: .utf8) {
                            await self.handleMessage(text)
                        }
                    @unknown default:
                        break
                    }
                    
                    // Continue receiving only if still connected
                    if case .disconnected = self.connectionState {
                        return
                    }
                    self.receiveMessages()
                    
                case .failure(let error):
                    print("WebSocket receive error: \(error)")
                    let errorDescription = error.localizedDescription
                    
                    // Check for specific error types
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet:
                            self.connectionState = .error("No internet connection")
                        case .timedOut:
                            self.connectionState = .error("Connection timed out")
                        case .cannotFindHost:
                            self.connectionState = .error("Cannot find server. Check if messaging service is running.")
                        case .cannotConnectToHost:
                            self.connectionState = .error("Cannot connect to server. Check port-forward or service URL.")
                        case .networkConnectionLost:
                            self.connectionState = .error("Network connection lost")
                        default:
                            self.connectionState = .error("Connection error: \(errorDescription)")
                        }
                    } else {
                        // Handle WebSocket-specific errors
                        if errorDescription.contains("bad response") || errorDescription.contains("handshake") {
                            self.connectionState = .error("WebSocket handshake failed. Check if server supports WebSocket at \(self.getBaseURL())")
                        } else {
                            self.connectionState = .error("Connection error: \(errorDescription)")
                        }
                    }
                    self.scheduleReconnect()
                }
            }
        }
    }
    
    private var storedBaseURL: String?
    
    private func getBaseURL() -> String {
        return storedBaseURL ?? UserDefaults.standard.string(forKey: "messaging_api_base_url") ?? "http://localhost:8080"
    }
    
    private func parseWebSocketMessage(json: [String: Any], type: WebSocketMessageType) -> WebSocketMessage? {
        let clientMessageId = json["client_message_id"] as? String
        let idempotencyKey = json["idempotency_key"] as? String
        let messageId = json["message_id"] as? String
        let timestamp = json["timestamp"] as? Int64
        
        var payload: WebSocketPayload? = nil
        if let payloadDict = json["payload"] as? [String: Any] {
            let messages = (payloadDict["messages"] as? [[String: Any]])?.compactMap { msgDict -> MessagePayload? in
                guard let msgId = msgDict["message_id"] as? String,
                      let seq = msgDict["sequence_number"] as? Int,
                      let content = msgDict["content"] as? String,
                      let ts = msgDict["timestamp"] as? Int64 else {
                    return nil
                }
                return MessagePayload(messageId: msgId, sequenceNumber: seq, content: content, timestamp: ts)
            }
            
            payload = WebSocketPayload(
                userId: payloadDict["user_id"] as? String,
                authToken: payloadDict["auth_token"] as? String,
                deviceId: payloadDict["device_id"] as? String,
                platform: payloadDict["platform"] as? String,
                appVersion: payloadDict["app_version"] as? String,
                sessionId: payloadDict["session_id"] as? String,
                serverTime: payloadDict["server_time"] as? Int64,
                unreadCount: payloadDict["unread_count"] as? Int,
                conversationId: payloadDict["conversation_id"] as? String,
                receiverId: payloadDict["receiver_id"] as? String,
                senderId: payloadDict["sender_id"] as? String,
                content: payloadDict["content"] as? String,
                messageType: payloadDict["type"] as? String,
                mediaUrl: payloadDict["media_url"] as? String,
                replyToMessageId: payloadDict["reply_to_message_id"] as? String,
                sequenceNumber: payloadDict["sequence_number"] as? Int,
                status: payloadDict["status"] as? String,
                newEndpoint: payloadDict["new_endpoint"] as? String,
                sessionToken: payloadDict["session_token"] as? String,
                messages: messages
            )
        }
        
        return WebSocketMessage(
            type: type,
            clientMessageId: clientMessageId,
            idempotencyKey: idempotencyKey,
            messageId: messageId,
            payload: payload,
            timestamp: timestamp
        )
    }
    
    private func handleMessage(_ text: String) async {
        guard let data = text.data(using: .utf8) else { return }
        
        do {
            // Parse JSON manually to handle snake_case
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            
            guard let typeString = json["type"] as? String,
                  let type = WebSocketMessageType(rawValue: typeString) else {
                return
            }
            
            guard let message = parseWebSocketMessage(json: json, type: type) else {
                return
            }
            
            switch message.type {
            case .authSuccess:
                connectionState = .authenticated
                resetReconnectAttempts() // Reset on successful connection
                // Process any pending retry queue messages
                Task {
                    await RetryQueue.shared.processRetries()
                }
                if let payload = message.payload, let unreadCount = payload.unreadCount, unreadCount > 0 {
                    // Could trigger a sync of unread messages here
                }
                
            case .messageAck:
                // Message was acknowledged by server
                if let clientMessageId = message.clientMessageId,
                   let payload = message.payload,
                   let sequenceNumber = payload.sequenceNumber {
                    // Update sequence number tracking
                    if let conversationId = payload.conversationId {
                        lastSequenceNumber[conversationId] = sequenceNumber
                    }
                }
                
            case .message:
                // Received a message from server (agent response)
                if let payload = message.payload,
                   let messageId = message.messageId,
                   let content = payload.content,
                   let senderId = payload.senderId,
                   let sequenceNumber = payload.sequenceNumber {
                    
                    // Check for sequence gaps
                    if let conversationId = payload.conversationId {
                        let lastSeq = lastSequenceNumber[conversationId] ?? 0
                        if sequenceNumber > lastSeq + 1 {
                            // Request retransmission
                            await requestRetransmission(
                                conversationId: conversationId,
                                fromSequence: lastSeq + 1,
                                toSequence: sequenceNumber - 1
                            )
                        }
                        lastSequenceNumber[conversationId] = sequenceNumber
                    }
                    
                    // Extract agent role from sender_id (e.g., "agent-restaurant-waiter")
                    let agentRole: AgentRole? = {
                        if senderId.contains("host") { return .host }
                        if senderId.contains("waiter") { return .waiter }
                        if senderId.contains("sommelier") { return .sommelier }
                        if senderId.contains("chef") { return .chef }
                        return nil
                    }()
                    
                    let receivedMessage = ReceivedMessage(
                        messageId: messageId,
                        content: content,
                        senderId: senderId,
                        conversationId: payload.conversationId,
                        sequenceNumber: sequenceNumber,
                        timestamp: Date(timeIntervalSince1970: TimeInterval((payload.serverTime ?? Int64(Date().timeIntervalSince1970 * 1000)) / 1000)),
                        agentRole: agentRole
                    )
                    
                    receivedMessages.append(receivedMessage)
                    
                    // Send delivery ACK
                    await sendDeliveryAck(messageId: messageId)
                }
                
            case .messages:
                // Received multiple messages (retransmission)
                if let payload = message.payload,
                   let messages = payload.messages {
                    for msg in messages {
                        let agentRole: AgentRole? = {
                            if msg.content.contains("host") || msg.content.contains("Host") { return .host }
                            if msg.content.contains("waiter") || msg.content.contains("Waiter") { return .waiter }
                            if msg.content.contains("sommelier") || msg.content.contains("Sommelier") { return .sommelier }
                            if msg.content.contains("chef") || msg.content.contains("Chef") { return .chef }
                            return nil
                        }()
                        
                        let receivedMessage = ReceivedMessage(
                            messageId: msg.messageId,
                            content: msg.content,
                            senderId: nil,
                            conversationId: payload.conversationId,
                            sequenceNumber: msg.sequenceNumber,
                            timestamp: Date(timeIntervalSince1970: TimeInterval(msg.timestamp / 1000)),
                            agentRole: agentRole
                        )
                        
                        receivedMessages.append(receivedMessage)
                    }
                }
                
            case .heartbeatAck:
                // Heartbeat acknowledged
                break
                
            case .migration:
                // Server requested migration
                if let payload = message.payload,
                   let newEndpoint = payload.newEndpoint {
                    disconnect()
                    // In a real app, you'd reconnect to newEndpoint
                    print("Migration requested to: \(newEndpoint)")
                }
                
            default:
                break
            }
        } catch {
            print("Error decoding WebSocket message: \(error)")
            print("Message text: \(text)")
        }
    }
    
    // MARK: - Heartbeat
    
    private func startHeartbeat() {
        stopHeartbeat()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: heartbeatInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.sendHeartbeat()
            }
        }
    }
    
    private func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }
    
    private func sendHeartbeat() async {
        let message = WebSocketMessage(
            type: .heartbeat,
            clientMessageId: nil,
            idempotencyKey: nil,
            messageId: nil,
            payload: nil,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
        await sendMessage(message)
    }
    
    // MARK: - Delivery ACK
    
    private func sendDeliveryAck(messageId: String) async {
        let message = WebSocketMessage(
            type: .deliveryAck,
            clientMessageId: nil,
            idempotencyKey: nil,
            messageId: messageId,
            payload: nil,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
        await sendMessage(message)
    }
    
    // MARK: - Retransmission
    
    private func requestRetransmission(conversationId: String, fromSequence: Int, toSequence: Int) async {
        var json: [String: Any] = [
            "type": "retransmit",
            "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
        ]
        
        var payloadDict: [String: Any] = [
            "conversation_id": conversationId,
            "from_sequence": fromSequence,
            "to_sequence": toSequence
        ]
        
        json["payload"] = payloadDict
        
        guard let task = webSocketTask else { return }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
            try await task.send(wsMessage)
        } catch {
            print("Error sending retransmission request: \(error)")
        }
    }
    
    // MARK: - Reconnection
    
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 10
    
    private func scheduleReconnect() {
        reconnectTimer?.invalidate()
        
        // Exponential backoff: 2s, 4s, 8s, 16s, 32s, max 60s
        let delay = min(reconnectDelay * pow(2.0, Double(reconnectAttempts)), 60.0)
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                // Don't reconnect if already connected or connecting
                if case .connected = self.connectionState { return }
                if case .authenticated = self.connectionState { return }
                if case .connecting = self.connectionState { return }
                
                guard let baseURL = self.storedBaseURL,
                      let userId = self.userId else {
                    self.connectionState = .error("Cannot reconnect: missing base URL or user ID")
                    return
                }
                
                if self.reconnectAttempts >= self.maxReconnectAttempts {
                    self.connectionState = .error("Max reconnection attempts reached")
                    return
                }
                
                self.reconnectAttempts += 1
                print("WebSocket: Attempting reconnection \(self.reconnectAttempts)/\(self.maxReconnectAttempts)")
                
                // Attempt reconnection
                await self.connect(baseURL: baseURL, userId: userId, authToken: nil)
            }
        }
    }
    
    private func resetReconnectAttempts() {
        reconnectAttempts = 0
    }
}

struct ReceivedMessage {
    let messageId: String
    let content: String
    let senderId: String?
    let conversationId: String?
    let sequenceNumber: Int
    let timestamp: Date
    let agentRole: AgentRole?
}
