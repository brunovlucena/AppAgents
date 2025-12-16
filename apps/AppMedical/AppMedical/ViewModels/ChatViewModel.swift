//
//  ChatViewModel.swift
//  AppMedical
//
//  View model for medical agent chat using WebSocket (agents-whatsapp-rust protocol)
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isSending = false
    @Published var connectionStatus: String = "Disconnected"
    @Published var isConnected = false
    
    private let wsService = WebSocketService.shared
    private let persistenceService = MessagePersistenceService.shared
    private var cancellables = Set<AnyCancellable>()
    private var conversationId: String
    
    var baseURL: String {
        // For kind cluster on Docker Desktop:
        // Option 1: Port-forward (recommended for simulator):
        //   kubectl port-forward -n homelab-services svc/messaging-service 8080:80
        //   Then use: http://localhost:8080
        //
        // Option 2: Change service to NodePort and use node IP + NodePort
        // Option 3: Use Docker Desktop host IP (for physical device)
        if let configured = UserDefaults.standard.string(forKey: "messaging_api_base_url"), !configured.isEmpty {
            return configured
        }
        // Default: localhost with port-forward
        return "http://localhost:8080"
    }
    
    init() {
        // Generate a conversation ID for this session
        conversationId = UUID().uuidString
        
        // Load persisted messages for this conversation
        loadPersistedMessages()
        
        // Subscribe to WebSocket service updates
        wsService.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateConnectionStatus(state)
            }
            .store(in: &cancellables)
        
        wsService.$receivedMessages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] receivedMessages in
                self?.handleReceivedMessages(receivedMessages)
            }
            .store(in: &cancellables)
        
        // Connect on init
        Task {
            await connect()
        }
    }
    
    private func loadPersistedMessages() {
        let persistedMessages = persistenceService.loadMessages(for: conversationId)
        messages = persistedMessages
    }
    
    private func updateConnectionStatus(_ state: WebSocketConnectionState) {
        switch state {
        case .disconnected:
            connectionStatus = "Disconnected"
            isConnected = false
        case .connecting:
            connectionStatus = "Connecting..."
            isConnected = false
        case .connected:
            connectionStatus = "Connected"
            isConnected = false
        case .authenticated:
            connectionStatus = "Connected"
            isConnected = true
        case .error(let message):
            connectionStatus = "Error: \(message)"
            isConnected = false
        }
    }
    
    private func handleReceivedMessages(_ receivedMessages: [ReceivedMessage]) {
        // Convert received messages to ChatMessage format
        for receivedMsg in receivedMessages {
            // Check if we already have this message
            if messages.contains(where: { $0.id == receivedMsg.messageId }) {
                continue
            }
            
            let chatMessage = ChatMessage(
                id: receivedMsg.messageId,
                role: .agent,
                content: receivedMsg.content,
                timestamp: receivedMsg.timestamp,
                sequenceNumber: receivedMsg.sequenceNumber,
                conversationId: receivedMsg.conversationId,
                status: .delivered
            )
            
            messages.append(chatMessage)
            // Persist the message
            if let conversationId = receivedMsg.conversationId {
                persistenceService.saveMessage(chatMessage, conversationId: conversationId)
            }
        }
    }
    
    func connect() async {
        // Generate a user ID (in production, this would come from authentication)
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? UUID().uuidString
        UserDefaults.standard.set(userId, forKey: "user_id")
        
        await wsService.connect(baseURL: baseURL, userId: userId, authToken: nil)
    }
    
    func disconnect() {
        wsService.disconnect()
    }
    
    func sendMessage(_ text: String) async {
        guard isConnected else {
            let errorMessage = ChatMessage(
                role: .agent,
                content: "Not connected. Please wait for connection.",
                status: .error("Not connected")
            )
            messages.append(errorMessage)
            return
        }
        
        let userMessage = ChatMessage(
            role: .user,
            content: text,
            timestamp: Date(),
            conversationId: conversationId,
            status: .sending
        )
        messages.append(userMessage)
        // Persist immediately
        persistenceService.saveMessage(userMessage, conversationId: conversationId)
        isSending = true
        
        // Send via WebSocket to medical agent
        let clientMessageId = await wsService.sendTextMessage(
            content: text,
            conversationId: conversationId,
            receiverId: MedicalAgent.agentId
        )
        
        // Update message status to sent (optimistically)
        if let index = messages.firstIndex(where: { $0.id == userMessage.id }) {
            let updatedMessage = ChatMessage(
                id: clientMessageId ?? userMessage.id,
                role: userMessage.role,
                content: userMessage.content,
                timestamp: userMessage.timestamp,
                sequenceNumber: userMessage.sequenceNumber,
                conversationId: userMessage.conversationId,
                status: .sent
            )
            messages[index] = updatedMessage
            // Update persisted message
            persistenceService.updateMessageStatus(messageId: updatedMessage.id, status: .sent)
        }
        
        // Note: Actual message ACK will update status to delivered when received
        
        isSending = false
    }
}

