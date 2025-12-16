//
//  ContentView.swift
//  AppMedical
//
//  WhatsApp-style chat interface for medical agent
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Medical-themed header
                ChatHeader(
                    connectionStatus: viewModel.connectionStatus,
                    isConnected: viewModel.isConnected
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
                        // Medical-themed background
                        ZStack {
                            Color(red: 0.95, green: 0.97, blue: 0.99) // Light blue tint
                            Image(systemName: "cross.case.fill")
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
            
                // Medical-themed input field
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
    let connectionStatus: String
    let isConnected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Main header bar
            HStack(spacing: 12) {
                // Medical agent avatar
                ZStack {
                    Circle()
                        .fill(Color(red: 0.85, green: 0.2, blue: 0.2)) // Medical red
                        .frame(width: 44, height: 44)
                    
                    Text(MedicalAgent.emoji)
                        .font(.title2)
                }
                
                // Agent info
                VStack(alignment: .leading, spacing: 2) {
                    Text(MedicalAgent.name)
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
                
                // Settings button (placeholder)
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
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
                if !isUser {
                    HStack(spacing: 4) {
                        Text(MedicalAgent.emoji)
                            .font(.caption2)
                        Text(MedicalAgent.name)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 12)
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
                        ? Color(red: 0.85, green: 0.2, blue: 0.2) // Medical red
                        : Color(.systemBackground)
                )
                .cornerRadius(8)
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
                                  : Color(red: 0.85, green: 0.2, blue: 0.2))
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

