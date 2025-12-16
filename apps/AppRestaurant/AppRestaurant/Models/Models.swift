//
//  Models.swift
//  AppRestaurant
//
//  Models for restaurant agent chat using agents-whatsapp-rust protocol
//

import Foundation

enum AgentRole: String, CaseIterable {
    case host = "host"
    case waiter = "waiter"
    case sommelier = "sommelier"
    case chef = "chef"
    
    var name: String {
        switch self {
        case .host: return "Host"
        case .waiter: return "Waiter"
        case .sommelier: return "Sommelier"
        case .chef: return "Chef"
        }
    }
    
    var emoji: String {
        switch self {
        case .host: return "🎩"
        case .waiter: return "👔"
        case .sommelier: return "🍷"
        case .chef: return "👨‍🍳"
        }
    }
    
    var agentId: String {
        return "agent-restaurant-\(rawValue)"
    }
}

struct ChatMessage: Identifiable {
    let id: String // message_id from server or client_message_id
    let role: MessageRole
    let content: String
    let timestamp: Date
    let agentRole: AgentRole?
    let sequenceNumber: Int?
    let conversationId: String?
    let status: MessageStatus
    
    init(
        id: String = UUID().uuidString,
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        agentRole: AgentRole? = nil,
        sequenceNumber: Int? = nil,
        conversationId: String? = nil,
        status: MessageStatus = .sending
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.agentRole = agentRole
        self.sequenceNumber = sequenceNumber
        self.conversationId = conversationId
        self.status = status
    }
}

enum MessageRole {
    case user
    case agent
}

enum MessageStatus {
    case sending
    case sent
    case delivered
    case read
    case error(String)
}
