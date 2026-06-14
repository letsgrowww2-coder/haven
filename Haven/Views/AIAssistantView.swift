import SwiftUI

struct AIAssistantView: View {
    @StateObject private var viewModel = AIAssistantViewModel()
    @State private var showCaseSummary = false
    @State private var showTranslate = false
    @State private var showSafeProfile = false

    private let quickPrompts = [
        "What documents do I need for housing?",
        "How do I apply for Section 8?",
        "Find food near me"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                languageBar
                Divider()

                ScrollViewReader { proxy in
                    ScrollView {
                        if viewModel.messages.isEmpty {
                            quickPromptsView
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.messages) { msg in
                                    ChatBubble(message: msg).id(msg.id)
                                }
                                if viewModel.isLoading {
                                    TypingIndicator()
                                        .id("typing")
                                }
                            }
                            .padding()
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: viewModel.messages.count) { _, _ in
                        withAnimation {
                            if let last = viewModel.messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                    .onChange(of: viewModel.isLoading) { _, loading in
                        if loading { withAnimation { proxy.scrollTo("typing", anchor: .bottom) } }
                    }
                }

                Divider()
                inputBar
            }
            .navigationTitle(L10n.t(.navAIAssistant))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !viewModel.messages.isEmpty {
                        Button("Clear") { viewModel.clearHistory() }
                    }
                }
            }
            .havenSOS()
            .sheet(isPresented: $showCaseSummary) {
                CaseSummaryView()
            }
            .sheet(isPresented: $showTranslate) {
                TranslationView()
            }
            .sheet(isPresented: $showSafeProfile) {
                SafeProfileView()
            }
        }
    }

    // MARK: - Language bar

    private var languageBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HavenUser.Language.allCases) { lang in
                    Button(lang.displayName) {
                        viewModel.selectedLanguage = lang
                    }
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.selectedLanguage == lang ? Color.blue : Color(.systemGray5))
                    .foregroundColor(viewModel.selectedLanguage == lang ? .white : .primary)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Quick prompts + Tools

    private var quickPromptsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 24)

                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)

                Text(L10n.t(.howCanIHelp))
                    .font(.title2.bold())

                Text(L10n.t(.askAboutHousing))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Chat quick-start prompts
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.t(.askAQuestion))
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    ForEach(quickPrompts, id: \.self) { prompt in
                        Button {
                            viewModel.inputText = prompt
                            Task { await viewModel.send() }
                        } label: {
                            HStack {
                                Image(systemName: "bubble.left.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                Text(prompt)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(14)
                            .havenCard()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)

                // Tools section
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.t(.tools))
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    HStack(spacing: 12) {
                        ToolCard(
                            icon: "globe",
                            title: L10n.t(.translateDoc),
                            subtitle: "Document or notice",
                            color: .blue
                        ) { showTranslate = true }

                        ToolCard(
                            icon: "lock.shield.fill",
                            title: L10n.t(.safeProfile),
                            subtitle: "Share with a shelter",
                            color: .green
                        ) { showSafeProfile = true }

                        ToolCard(
                            icon: "doc.badge.plus",
                            title: L10n.t(.caseSummary),
                            subtitle: "For agencies",
                            color: .purple
                        ) { showCaseSummary = true }
                    }
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 16)
            }
        }
    }

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField(L10n.t(.askAnything), text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .onSubmit { Task { await viewModel.send() } }

            Button {
                Task { await viewModel.send() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading ? .gray : .blue)
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

// MARK: - Chat Bubble

struct ChatBubble: View {
    let message: AIAssistantViewModel.ChatMessage

    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !isUser {
                aiAvatar
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.subheadline)
                    .padding(12)
                    .background(isUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isUser ? .white : .primary)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )

                Text(message.timestamp.timeAgoDisplay())
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isUser ? .trailing : .leading)

            if isUser {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }

    private var aiAvatar: some View {
        Image(systemName: "sparkles")
            .font(.caption)
            .foregroundColor(.blue)
            .frame(width: 30, height: 30)
            .background(Color.blue.opacity(0.1))
            .clipShape(Circle())
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var phase = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 7, height: 7)
                        .offset(y: phase ? -4 : 0)
                        .animation(
                            .easeInOut(duration: 0.45).repeatForever().delay(Double(i) * 0.15),
                            value: phase
                        )
                }
            }
            .padding(12)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { phase = true }
    }
}

// MARK: - Tool Card

struct ToolCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 110)
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
