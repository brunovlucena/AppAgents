//
//  AppRestaurantTests.swift
//  AppRestaurantTests
//
//  Unit tests for AppRestaurant
//

import XCTest
@testable import AppRestaurant

final class AppRestaurantTests: XCTestCase {
    
    var viewModel: ChatViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ChatViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - WebSocket Service Tests
    
    func testWebSocketServiceSingleton() {
        let service1 = WebSocketService.shared
        let service2 = WebSocketService.shared
        XCTAssertTrue(service1 === service2, "WebSocketService should be a singleton")
    }
    
    func testWebSocketConnectionState() {
        let service = WebSocketService.shared
        XCTAssertEqual(service.connectionState, .disconnected, "Initial state should be disconnected")
    }
    
    // MARK: - Message Persistence Tests
    
    func testMessagePersistenceSaveAndLoad() {
        let persistence = MessagePersistenceService.shared
        let conversationId = UUID().uuidString
        
        let message = ChatMessage(
            role: .user,
            content: "Test message",
            timestamp: Date(),
            conversationId: conversationId,
            status: .sent
        )
        
        persistence.saveMessage(message, conversationId: conversationId)
        
        let loadedMessages = persistence.loadMessages(for: conversationId)
        XCTAssertEqual(loadedMessages.count, 1, "Should load one message")
        XCTAssertEqual(loadedMessages.first?.content, "Test message", "Message content should match")
    }
    
    // MARK: - Chat ViewModel Tests
    
    func testChatViewModelInitialization() {
        XCTAssertNotNil(viewModel, "ViewModel should initialize")
        XCTAssertEqual(viewModel.messages.count, 0, "Initial messages should be empty")
        XCTAssertFalse(viewModel.isConnected, "Should start disconnected")
    }
    
    // MARK: - Model Tests
    
    func testAgentRole() {
        XCTAssertEqual(AgentRole.host.rawValue, "host")
        XCTAssertEqual(AgentRole.waiter.rawValue, "waiter")
        XCTAssertEqual(AgentRole.host.agentId, "agent-restaurant-host")
    }
    
    func testChatMessageCreation() {
        let message = ChatMessage(
            role: .user,
            content: "Hello",
            timestamp: Date(),
            status: .sent
        )
        
        XCTAssertEqual(message.role, .user)
        XCTAssertEqual(message.content, "Hello")
        XCTAssertNotNil(message.id)
    }
}
