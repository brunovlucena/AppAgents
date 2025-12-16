//
//  ContentView.swift
//  AppRestaurant
//
//  WhatsApp-style chat interface for restaurant agents
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        NavigationStack {
        VStack(spacing: 0) {
                // WhatsApp-style header
                ChatHeader(
                    agent: viewModel.currentAgent,
                    connectionStatus: viewModel.connectionStatus,
                    isConnected: viewModel.isConnected,
                    onAgentChange: { role in
                        viewModel.switchAgent(role)
                    }
                )
            
                // Chat messages area
            ScrollViewReader { proxy in
                ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                        }
                    }
                        .padding(.vertical, 8)
                    }
                    .background(
                        // WhatsApp-like background pattern
                        ZStack {
                            Color(red: 0.92, green: 0.96, blue: 0.92) // Light green tint
                            Image(systemName: "ellipsis")
                                .font(.system(size: 200))
                                .foregroundColor(.white.opacity(0.03))
                                .offset(x: 50, y: 50)
                }
                    )
                .onChange(of: viewModel.messages.count) {
                    if let last = viewModel.messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
                // WhatsApp-style input field
            ChatInput(
                onSend: { text in
                    Task {
                        await viewModel.sendMessage(text)
                    }
                },
                    isSending: viewModel.isSending,
                    isConnected: viewModel.isConnected
            )
        }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EmptyView()
                }
            }
        }
        .onDisappear {
            viewModel.disconnect()
        }
    }
}

struct ChatHeader: View {
    let agent: AgentRole
    let connectionStatus: String
    let isConnected: Bool
    let onAgentChange: (AgentRole) -> Void
    
    @State private var showAgentPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main header bar
            HStack(spacing: 12) {
                // Agent avatar/emoji
                Button(action: {
                    showAgentPicker.toggle()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.18, green: 0.8, blue: 0.44)) // WhatsApp green
                            .frame(width: 44, height: 44)
                        
                        Text(agent.emoji)
                            .font(.title2)
                    }
                }
                
                // Agent info
                VStack(alignment: .leading, spacing: 2) {
                    Text(agent.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(isConnected ? Color.green : Color.gray)
                            .frame(width: 6, height: 6)
                        Text(isConnected ? "online" : connectionStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Menu button
                Button(action: {
                    showAgentPicker.toggle()
                }) {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            // Agent picker (when expanded)
            if showAgentPicker {
                AgentPicker(currentAgent: agent, onSelect: { role in
                    onAgentChange(role)
                    showAgentPicker = false
                })
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(Color(.systemBackground))
    }
}

struct AgentPicker: View {
    let currentAgent: AgentRole
    let onSelect: (AgentRole) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                ForEach(AgentRole.allCases, id: \.self) { role in
                        Button(action: {
                            onSelect(role)
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(currentAgent == role ? Color(red: 0.18, green: 0.8, blue: 0.44) : Color.gray.opacity(0.2))
                                        .frame(width: 56, height: 56)
                                    
                            Text(role.emoji)
                                        .font(.title)
                                }
                                
                            Text(role.name)
                                .font(.caption)
                                    .foregroundColor(currentAgent == role ? .primary : .secondary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(Color(.systemBackground))
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var isUser: Bool { message.role == .user }
    
    var statusIcon: String {
        switch message.status {
        case .sending:
            return "clock"
        case .sent:
            return "checkmark"
        case .delivered:
            return "checkmark.circle"
        case .read:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.triangle"
        }
    }
    
    var statusColor: Color {
        switch message.status {
        case .sending, .sent:
            return .white.opacity(0.7)
        case .delivered, .read:
            return .white
        case .error:
            return .red
        }
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            if !isUser { Spacer(minLength: 50) }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 2) {
                // Agent name (only for agent messages)
                if !isUser, let agentRole = message.agentRole {
                    Text("\(agentRole.emoji) \(agentRole.name)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, isUser ? 0 : 12)
                        .padding(.bottom, 2)
                }
                
                // Message bubble
                HStack(alignment: .bottom, spacing: 6) {
                Text(message.content)
                        .font(.body)
                    .foregroundColor(isUser ? .white : .primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 3) {
                        Text(timeString)
                            .font(.caption2)
                            .foregroundColor(isUser ? .white.opacity(0.8) : .secondary)
                        
                        if isUser {
                            Image(systemName: statusIcon)
                                .font(.system(size: 10))
                                .foregroundColor(statusColor)
            }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isUser
                        ? Color(red: 0.18, green: 0.8, blue: 0.44) // WhatsApp green
                        : Color(.systemBackground)
                )
                .cornerRadius(8)
                // WhatsApp-style rounded corners (no tail for simplicity, but still looks great)
            }
            
            if isUser { Spacer(minLength: 50) }
        }
    }
}

struct ChatInput: View {
    let onSend: (String) -> Void
    let isSending: Bool
    let isConnected: Bool
    
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 8) {
                // Attachment button (placeholder)
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .disabled(!isConnected)
                
                // Text input
                HStack {
                    TextField("Message", text: $text, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .lineLimit(1...5)
                        .focused($isFocused)
                        .disabled(isSending || !isConnected)
                }
                
                // Send button
            Button(action: {
                guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                onSend(text)
                text = ""
                isFocused = false
            }) {
                    ZStack {
                        Circle()
                            .fill(text.isEmpty || isSending || !isConnected
                                  ? Color.gray.opacity(0.3)
                                  : Color(red: 0.18, green: 0.8, blue: 0.44))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: text.isEmpty ? "mic.fill" : "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(text.isEmpty || isSending || !isConnected ? .gray : .white)
                    }
            }
                .disabled(text.isEmpty || isSending || !isConnected)
        }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        .background(Color(.systemBackground))
        }
    }
}

#Preview {
        ContentView()
}
