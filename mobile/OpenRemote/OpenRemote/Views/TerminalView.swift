import SwiftUI

struct TerminalView: View {
    @EnvironmentObject var connection: ConnectionManager
    @State private var inputText = ""
    @FocusState private var inputFocused: Bool
    @State private var showQuickCommands = false
    @State private var showDisconnectAlert = false

    private let quickCommands = [
        ("ls", "ls -la"),
        ("git status", "git status"),
        ("clear", "clear"),
        ("Ctrl+C", "\u{03}"),
    ]
    
    private let arrowUp = "\u{1b}[A"
    private let arrowDown = "\u{1b}[B"
    private let arrowRight = "\u{1b}[C"
    private let arrowLeft = "\u{1b}[D"
    private let enterKey = "\r"
    private let escKey = "\u{1b}"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        Text(connection.terminalOutput)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .id("output")
                    }
                    .background(.black)
                    .onChange(of: connection.terminalOutput) {
                        withAnimation {
                            proxy.scrollTo("output", anchor: .bottom)
                        }
                    }
                }

                Divider()

                if showQuickCommands {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(quickCommands, id: \.0) { label, command in
                                Button(label) {
                                    if command == "\u{03}" {
                                        connection.sendInput(command)
                                    } else {
                                        connection.sendCommand(command)
                                    }
                                }
                                .font(.system(size: 13, design: .monospaced))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray5))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemGray6))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                HStack(spacing: 12) {
                    Button { connection.sendInput(escKey) } label: {
                        Text("ESC")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.orange)
                    }
                    
                    Spacer()
                    
                    Button { connection.sendInput(arrowUp) } label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.green)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button { connection.sendInput(arrowLeft) } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.green)
                        }
                        
                        Button { connection.sendInput(arrowDown) } label: {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.green)
                        }
                        
                        Button { connection.sendInput(arrowRight) } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Spacer()
                    
                    Button { connection.sendInput(enterKey) } label: {
                        Text("RET")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.green)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(.systemGray5))

                HStack(spacing: 8) {
                    Button {
                        withAnimation { showQuickCommands.toggle() }
                    } label: {
                        Image(systemName: showQuickCommands ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.green)
                    }

                    TextField("Command...", text: $inputText)
                        .font(.system(size: 15, design: .monospaced))
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($inputFocused)
                        .submitLabel(.send)
                        .onSubmit { submitCommand() }

                    Button {
                        submitCommand()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(inputText.isEmpty ? .gray : .green)
                    }
                    .disabled(inputText.isEmpty)

                    Button {
                        connection.sendInput("\t")
                    } label: {
                        Text("⇥")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.green)
                    }
                    
                    Button {
                        connection.sendInput("\u{03}")
                    } label: {
                        Text("^C")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
            }
            .navigationTitle(connection.sessionId.map { "Session \($0)" } ?? "Terminal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            showDisconnectAlert = true
                        } label: {
                            Label("Disconnect", systemImage: "xmark.circle")
                        }

                        if connection.sessionId != nil {
                            Button {
                                connection.killSession()
                                connection.createSession()
                            } label: {
                                Label("New Session", systemImage: "plus.rectangle")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Disconnect?", isPresented: $showDisconnectAlert) {
                Button("Disconnect", role: .destructive) { connection.disconnect() }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear { inputFocused = true }
        }
    }

    private func submitCommand() {
        guard !inputText.isEmpty else { return }
        connection.sendCommand(inputText)
        inputText = ""
    }
}
