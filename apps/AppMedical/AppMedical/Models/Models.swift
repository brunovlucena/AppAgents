//
//  Models.swift
//  AppMedical
//
//  Models for medical agent chat using agents-whatsapp-rust protocol
//

import Foundation

// Medical agent is a single agent (not multiple roles like restaurant)
enum MedicalAgent {
    static let agentId = "agent-medical"
    static let name = "Medical Assistant"
    static let emoji = "🏥"
    static let description = "HIPAA-compliant medical records assistant"
}

struct ChatMessage: Identifiable {
    let id: String // message_id from server or client_message_id
    let role: MessageRole
    let content: String
    let timestamp: Date
    let sequenceNumber: Int?
    let conversationId: String?
    let status: MessageStatus
    
    init(
        id: String = UUID().uuidString,
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        sequenceNumber: Int? = nil,
        conversationId: String? = nil,
        status: MessageStatus = .sending
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
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

