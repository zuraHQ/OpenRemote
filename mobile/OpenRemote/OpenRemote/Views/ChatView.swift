import SwiftUI

struct ChatView: View {
    @EnvironmentObject var connection: ConnectionManager
    @State private var inputText = ""
    @FocusState private var inputFocused: Bool
    @State private var showDisconnectAlert = false
    @State private var currentModel: ClaudeModel = ClaudeModel.load()
    @State private var toastMessage: String?
    @State private var showPortPicker = false
    @State private var previewPort = "3000"
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                if connection.messages.isEmpty && !connection.showTrustPrompt {
                                    WelcomeView(onPromptTap: { prompt in
                                        inputText = prompt
                                        inputFocused = true
                                    })
                                    .padding(.top, 40)
                                }
                                
                                ForEach(connection.messages) { message in
                                    MessageRow(
                                        message: message,
                                        liveActivity: message.isStreaming ? connection.currentActivity : nil
                                    )
                                    .id(message.id)
                                }
                                
                                if connection.showTrustPrompt {
                                    TrustPromptBubble(
                                        onAccept: { connection.acceptTrust() },
                                        onDecline: { connection.disconnect() }
                                    )
                                    .id("trust-prompt")
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .onTapGesture {
                            inputFocused = false
                        }
                        .onChange(of: connection.messages.count) {
                            if let last = connection.messages.last {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: connection.showTrustPrompt) {
                            if connection.showTrustPrompt {
                                withAnimation {
                                    proxy.scrollTo("trust-prompt", anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: inputFocused) {
                            if inputFocused, let last = connection.messages.last {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation {
                                        proxy.scrollTo(last.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    HStack(spacing: 10) {
                        TextField("Ask Claude...", text: $inputText, axis: .vertical)
                            .lineLimit(1...6)
                            .textFieldStyle(.plain)
                            .font(.system(size: 15))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .focused($inputFocused)
                            .submitLabel(.send)
                            .onSubmit { sendMessage() }
                        
                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(.tertiaryLabel) : .orange)
                                .frame(width: 36, height: 36)
                                .background(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.clear : Color.orange.opacity(0.15))
                                .clipShape(Circle())
                        }
                        .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                }
                
            }
            .background(Color(.systemBackground))
            .overlay(alignment: .bottom) {
                if toastMessage != nil {
                    Text(toastMessage!)
                        .font(.footnote.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.85))
                        .clipShape(Capsule())
                        .padding(.bottom, 70)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: toastMessage)
            .navigationTitle("OpenRemote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(connection.state == .connected ? .green : .orange)
                            .frame(width: 8, height: 8)
                        if connection.isClaudeThinking {
                            Text(connection.currentActivity.isEmpty ? "working..." : connection.currentActivity)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPortPicker = true
                    } label: {
                        if connection.isPreviewLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "play.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    .disabled(connection.isPreviewLoading)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Menu {
                            ForEach(ClaudeModel.allCases, id: \.self) { model in
                                Button {
                                    switchModel(to: model)
                                } label: {
                                    Label(model.displayName, systemImage: currentModel == model ? "checkmark" : "")
                                }
                            }
                        } label: {
                            Label("Model: \(currentModel.displayName)", systemImage: "cpu")
                        }
                        
                        Divider()
                        
                        Button {
                            connection.clearMessages()
                            showToast("New session started")
                        } label: {
                            Label("New Session", systemImage: "plus.circle")
                        }
                        
                        Button(role: .destructive) {
                            showDisconnectAlert = true
                        } label: {
                            Label("Disconnect", systemImage: "xmark.circle")
                        }
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .alert("Disconnect?", isPresented: $showDisconnectAlert) {
                Button("Disconnect", role: .destructive) { connection.disconnect() }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Preview localhost", isPresented: $showPortPicker) {
                TextField("Port", text: $previewPort)
                    .keyboardType(.numberPad)
                Button("Preview") {
                    if let port = Int(previewPort) {
                        connection.startPreview(port: port)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter the port your dev server is running on")
            }
            .onChange(of: connection.previewUrl) {
                if let urlString = connection.previewUrl,
                   let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                    connection.stopPreview()
                }
            }
        }
    }
    
    private func showToast(_ message: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            toastMessage = message
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                toastMessage = nil
            }
        }
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputFocused = false
        connection.sendChatMessage(text)
        inputText = ""
    }
    
    private func switchModel(to model: ClaudeModel) {
        guard model != currentModel else { return }
        model.save()
        currentModel = model
        connection.clearMessages()
        showToast("Switched to \(model.displayName)")
    }
}

struct PreviewURL: Identifiable {
    let url: String
    var id: String { url }
}

struct TrustPromptBubble: View {
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.shield")
                    .foregroundStyle(.orange)
                Text("Permission Required")
                    .font(.subheadline.bold())
            }
            
            Text("Claude needs access to the workspace folder to read, edit, and execute files.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 10) {
                Button {
                    onAccept()
                } label: {
                    Text("Allow")
                        .font(.footnote.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Button {
                    onDecline()
                } label: {
                    Text("Deny")
                        .font(.footnote.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemFill))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct MessageRow: View {
    let message: ChatMessage
    var liveActivity: String? = nil

    private var displayActivity: String? {
        if let tool = message.toolActivity, !tool.isEmpty { return tool }
        if let live = liveActivity, !live.isEmpty { return live }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: message.role == .user ? "person.fill" : "cpu")
                    .font(.caption)
                    .foregroundStyle(message.role == .user ? .orange : .purple)
                Text(message.role == .user ? "You" : "Claude")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
            }

            if message.isStreaming {
                if let activity = displayActivity {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text(activity)
                            .font(.footnote.bold())
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color.orange.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if message.content.isEmpty {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Connecting...")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                if !message.content.isEmpty {
                    FormattedMessageView(content: message.content)
                }
            } else if !message.content.isEmpty {
                FormattedMessageView(content: message.content)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(message.role == .user ? Color(.tertiarySystemFill) : Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct FormattedMessageView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(parseContent().enumerated()), id: \.offset) { _, segment in
                switch segment {
                case .text(let text):
                    Text(formatInlineCode(text))
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                case .codeBlock(let code, let language):
                    CodeBlockView(code: code, language: language)
                }
            }
        }
    }
    
    enum ContentSegment {
        case text(String)
        case codeBlock(String, String?)
    }
    
    private func parseContent() -> [ContentSegment] {
        var segments: [ContentSegment] = []
        let pattern = "```(\\w*)\\n([\\s\\S]*?)```"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return [.text(content)]
        }
        
        var lastEnd = content.startIndex
        let nsContent = content as NSString
        
        regex.enumerateMatches(in: content, range: NSRange(location: 0, length: nsContent.length)) { match, _, _ in
            guard let match = match else { return }
            
            let matchStart = content.index(content.startIndex, offsetBy: match.range.location)
            
            if lastEnd < matchStart {
                let text = String(content[lastEnd..<matchStart]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty {
                    segments.append(.text(text))
                }
            }
            
            let langRange = Range(match.range(at: 1), in: content)
            let codeRange = Range(match.range(at: 2), in: content)
            
            let language = langRange.map { String(content[$0]) }
            let code = codeRange.map { String(content[$0]).trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""
            
            segments.append(.codeBlock(code, language?.isEmpty == true ? nil : language))
            
            lastEnd = content.index(content.startIndex, offsetBy: match.range.location + match.range.length)
        }
        
        if lastEnd < content.endIndex {
            let text = String(content[lastEnd...]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                segments.append(.text(text))
            }
        }
        
        return segments.isEmpty ? [.text(content)] : segments
    }
    
    private func formatInlineCode(_ text: String) -> AttributedString {
        var result = AttributedString(text)
        let pattern = "`([^`]+)`"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return result
        }
        
        let nsText = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
        
        for match in matches.reversed() {
            guard let range = Range(match.range, in: text),
                  let attrRange = Range(range, in: result) else { continue }
            
            let codeRange = Range(match.range(at: 1), in: text)!
            let codeText = String(text[codeRange])
            
            var codeAttr = AttributedString(codeText)
            codeAttr.font = .system(size: 14, weight: .medium, design: .monospaced)
            codeAttr.backgroundColor = Color(.systemGray5)
            
            result.replaceSubrange(attrRange, with: codeAttr)
        }
        
        return result
    }
}

struct CodeBlockView: View {
    let code: String
    let language: String?
    @State private var copied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(language ?? "code")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    UIPasteboard.general.string = code
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        copied = false
                    }
                } label: {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                        .foregroundStyle(copied ? .green : .secondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(red: 0.15, green: 0.15, blue: 0.19))
            
            ScrollView(.horizontal, showsIndicators: false) {
                Text(highlightSyntax(code, language: language))
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(10)
            }
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.15))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func highlightSyntax(_ code: String, language: String?) -> AttributedString {
        var result = AttributedString(code)
        result.foregroundColor = Color(red: 0.85, green: 0.85, blue: 0.85)
        
        let keywords = [
            "func", "var", "let", "const", "class", "struct", "enum", "if", "else", 
            "for", "while", "return", "import", "from", "def", "async", "await",
            "try", "catch", "throw", "new", "this", "self", "true", "false", "nil",
            "null", "undefined", "private", "public", "static", "final", "override",
            "switch", "case", "break", "continue", "default", "do", "in", "guard",
            "where", "extension", "protocol", "interface", "type", "export", "function"
        ]
        
        let typeKeywords = [
            "String", "Int", "Bool", "Double", "Float", "Array", "Dictionary",
            "View", "State", "Binding", "Optional", "Result", "Error", "Any",
            "void", "number", "string", "boolean", "object", "Promise"
        ]
        
        for keyword in keywords {
            highlightPattern("\\b\(keyword)\\b", in: &result, color: Color(red: 0.8, green: 0.4, blue: 0.8))
        }
        
        for type in typeKeywords {
            highlightPattern("\\b\(type)\\b", in: &result, color: Color(red: 0.4, green: 0.8, blue: 0.8))
        }
        
        highlightPattern("\"[^\"]*\"", in: &result, color: Color(red: 0.8, green: 0.6, blue: 0.4))
        highlightPattern("'[^']*'", in: &result, color: Color(red: 0.8, green: 0.6, blue: 0.4))
        
        highlightPattern("\\b\\d+\\.?\\d*\\b", in: &result, color: Color(red: 0.7, green: 0.8, blue: 0.5))
        
        highlightPattern("//.*$", in: &result, color: Color(red: 0.5, green: 0.5, blue: 0.5), options: .anchorsMatchLines)
        highlightPattern("#.*$", in: &result, color: Color(red: 0.5, green: 0.5, blue: 0.5), options: .anchorsMatchLines)
        
        highlightPattern("@\\w+", in: &result, color: Color(red: 0.6, green: 0.7, blue: 0.9))
        
        highlightPattern("\\b[A-Z][a-zA-Z0-9]*(?=\\()", in: &result, color: Color(red: 0.4, green: 0.75, blue: 0.9))
        highlightPattern("(?<=\\.)\\w+(?=\\()", in: &result, color: Color(red: 0.9, green: 0.8, blue: 0.5))
        
        return result
    }
    
    private func highlightPattern(_ pattern: String, in attributedString: inout AttributedString, color: Color, options: NSRegularExpression.Options = []) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return }
        
        let string = String(attributedString.characters)
        let range = NSRange(location: 0, length: string.utf16.count)
        
        for match in regex.matches(in: string, range: range) {
            guard let swiftRange = Range(match.range, in: string),
                  let attrRange = Range(swiftRange, in: attributedString) else { continue }
            attributedString[attrRange].foregroundColor = color
        }
    }
}

struct WelcomeView: View {
    let onPromptTap: (String) -> Void
    
    private let examplePrompts = [
        ("Search my desktop", "magnifyingglass"),
        ("What files are here?", "folder.fill"),
        ("Summarize this folder", "doc.text.fill"),
        ("Open my notes", "note.text"),
        ("Run a command", "terminal.fill"),
        ("Help me with a task", "sparkles")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image("Vector")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                
                Text("OpenRemote")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                
                Text("Control Claude from your iPhone")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Try asking:")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(examplePrompts, id: \.0) { prompt, icon in
                        Button {
                            onPromptTap(prompt)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: icon)
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                Text(prompt)
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 20)
    }
}
