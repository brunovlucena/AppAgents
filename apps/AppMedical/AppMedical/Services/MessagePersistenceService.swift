//
//  MessagePersistenceService.swift
//  AppMedical
//
//  Persistence service for chat messages using UserDefaults/Codable
//

import Foundation
import SwiftUI

struct StoredMessage: Codable {
    let messageId: String
    let content: String
    let timestamp: Date
    let role: String // "user" or "agent"
    let conversationId: String
    let sequenceNumber: Int?
    let status: String
    let createdAt: Date
}

@MainActor
class MessagePersistenceService: ObservableObject {
    static let shared = MessagePersistenceService()
    
    private let userDefaultsKey = "persisted_messages"
    private var messagesCache: [String: [StoredMessage]] = [:]
    
    private init() {
        loadAllMessages()
    }
    
    // MARK: - Message Operations
    
    func saveMessage(_ message: ChatMessage, conversationId: String) {
        let storedMessage = StoredMessage(
            messageId: message.id,
            content: message.content,
            timestamp: message.timestamp,
            role: message.role == .user ? "user" : "agent",
            conversationId: conversationId,
            sequenceNumber: message.sequenceNumber,
            status: messageStatusToString(message.status),
            createdAt: Date()
        )
        
        if messagesCache[conversationId] == nil {
            messagesCache[conversationId] = []
        }
        
        // Remove existing message with same ID if present
        messagesCache[conversationId]?.removeAll { $0.messageId == message.id }
        messagesCache[conversationId]?.append(storedMessage)
        
        saveAllMessages()
    }
    
    func loadMessages(for conversationId: String) -> [ChatMessage] {
        guard let storedMessages = messagesCache[conversationId] else {
            return []
        }
        
        return storedMessages.sorted { $0.timestamp < $1.timestamp }.compactMap { stored -> ChatMessage? in
            let role: MessageRole = stored.role == "user" ? .user : .agent
            let status = stringToMessageStatus(stored.status)
            
            return ChatMessage(
                id: stored.messageId,
                role: role,
                content: stored.content,
                timestamp: stored.timestamp,
                sequenceNumber: stored.sequenceNumber,
                conversationId: stored.conversationId,
                status: status
            )
        }
    }
    
    func deleteMessages(for conversationId: String) {
        messagesCache.removeValue(forKey: conversationId)
        saveAllMessages()
    }
    
    func updateMessageStatus(messageId: String, status: MessageStatus) {
        for (conversationId, messages) in messagesCache {
            if let index = messages.firstIndex(where: { $0.messageId == messageId }) {
                var updatedMessages = messages
                let oldMessage = updatedMessages[index]
                let updatedMessage = StoredMessage(
                    messageId: oldMessage.messageId,
                    content: oldMessage.content,
                    timestamp: oldMessage.timestamp,
                    role: oldMessage.role,
                    conversationId: oldMessage.conversationId,
                    sequenceNumber: oldMessage.sequenceNumber,
                    status: messageStatusToString(status),
                    createdAt: oldMessage.createdAt
                )
                updatedMessages[index] = updatedMessage
                messagesCache[conversationId] = updatedMessages
                saveAllMessages()
                break
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveAllMessages() {
        if let encoded = try? JSONEncoder().encode(messagesCache) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadAllMessages() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([String: [StoredMessage]].self, from: data) {
            messagesCache = decoded
        }
    }
    
    // MARK: - Helper Methods
    
    private func messageStatusToString(_ status: MessageStatus) -> String {
        switch status {
        case .sending: return "sending"
        case .sent: return "sent"
        case .delivered: return "delivered"
        case .read: return "read"
        case .error(let message): return "error:\(message)"
        }
    }
    
    private func stringToMessageStatus(_ string: String) -> MessageStatus {
        if string.hasPrefix("error:") {
            let errorMessage = String(string.dropFirst(6))
            return .error(errorMessage)
        }
        switch string {
        case "sending": return .sending
        case "sent": return .sent
        case "delivered": return .delivered
        case "read": return .read
        default: return .sent
        }
    }
}
