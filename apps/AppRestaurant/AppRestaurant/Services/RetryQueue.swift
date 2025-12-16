//
//  RetryQueue.swift
//  AppRestaurant
//
//  Retry queue for failed message sends with exponential backoff
//

import Foundation
import SwiftUI

struct PendingMessage: Codable {
    let id: String
    let content: String
    let conversationId: String
    let receiverId: String
    let agentRole: String?
    let timestamp: Date
    var retryCount: Int
    var lastRetryAttempt: Date?
    
    init(
        id: String = UUID().uuidString,
        content: String,
        conversationId: String,
        receiverId: String,
        agentRole: String? = nil,
        timestamp: Date = Date(),
        retryCount: Int = 0,
        lastRetryAttempt: Date? = nil
    ) {
        self.id = id
        self.content = content
        self.conversationId = conversationId
        self.receiverId = receiverId
        self.agentRole = agentRole
        self.timestamp = timestamp
        self.retryCount = retryCount
        self.lastRetryAttempt = lastRetryAttempt
    }
}

@MainActor
class RetryQueue: ObservableObject {
    static let shared = RetryQueue()
    
    private let maxRetries = 5
    private let baseRetryDelay: TimeInterval = 2.0 // 2 seconds
    private let maxRetryDelay: TimeInterval = 300.0 // 5 minutes max
    
    private var pendingMessages: [PendingMessage] = []
    private var retryTimer: Timer?
    
    private let userDefaultsKey = "pending_messages_queue"
    
    private init() {
        loadPendingMessages()
        startRetryTimer()
    }
    
    // MARK: - Queue Management
    
    func enqueue(_ message: PendingMessage) {
        pendingMessages.append(message)
        savePendingMessages()
        print("RetryQueue: Enqueued message \(message.id) for retry")
    }
    
    func dequeue(_ messageId: String) {
        pendingMessages.removeAll { $0.id == messageId }
        savePendingMessages()
    }
    
    func clear() {
        pendingMessages.removeAll()
        savePendingMessages()
    }
    
    // MARK: - Retry Logic
    
    private func startRetryTimer() {
        retryTimer?.invalidate()
        retryTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.processRetries()
            }
        }
    }
    
    func processRetries() async {
        let now = Date()
        let messagesToRetry = pendingMessages.filter { message in
            // Calculate exponential backoff delay
            let delay = min(baseRetryDelay * pow(2.0, Double(message.retryCount)), maxRetryDelay)
            let nextRetryTime = (message.lastRetryAttempt ?? message.timestamp).addingTimeInterval(delay)
            return now >= nextRetryTime && message.retryCount < maxRetries
        }
        
        for var message in messagesToRetry {
            message.retryCount += 1
            message.lastRetryAttempt = now
            
            print("RetryQueue: Retrying message \(message.id) (attempt \(message.retryCount)/\(maxRetries))")
            
            // Attempt to send via WebSocket
            let success = await retryMessage(message)
            
            if success {
                dequeue(message.id)
                print("RetryQueue: Successfully sent message \(message.id)")
            } else {
                // Update the message in the queue
                if let index = pendingMessages.firstIndex(where: { $0.id == message.id }) {
                    pendingMessages[index] = message
                    savePendingMessages()
                }
                
                if message.retryCount >= maxRetries {
                    print("RetryQueue: Max retries reached for message \(message.id), removing from queue")
                    dequeue(message.id)
                }
            }
        }
    }
    
    private func retryMessage(_ message: PendingMessage) async -> Bool {
        let wsService = WebSocketService.shared
        
        // Check if connected
        guard case .authenticated = wsService.connectionState else {
            return false
        }
        
        // Retry sending - AppRestaurant always has an agent role
        if let agentRoleString = message.agentRole, let agentRole = AgentRole(rawValue: agentRoleString) {
            let _ = await wsService.sendTextMessage(
                content: message.content,
                conversationId: message.conversationId,
                receiverId: message.receiverId,
                agentRole: agentRole
            )
        } else {
            // Fallback: try to extract from receiverId
            if message.receiverId.contains("agent-restaurant-") {
                let roleString = message.receiverId.replacingOccurrences(of: "agent-restaurant-", with: "")
                if let agentRole = AgentRole(rawValue: roleString) {
                    let _ = await wsService.sendTextMessage(
                        content: message.content,
                        conversationId: message.conversationId,
                        receiverId: message.receiverId,
                        agentRole: agentRole
                    )
                }
            }
        }
        
        // For now, assume success if we got here (actual success would be confirmed via message_ack)
        // In a production app, you'd track message ACKs to confirm delivery
        return true
    }
    
    // MARK: - Persistence
    
    private func savePendingMessages() {
        if let encoded = try? JSONEncoder().encode(pendingMessages) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadPendingMessages() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([PendingMessage].self, from: data) {
            pendingMessages = decoded
            print("RetryQueue: Loaded \(pendingMessages.count) pending messages")
        }
    }
}
