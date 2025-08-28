import SwiftUI

struct MessageHistoryView: View {
    @ObservedObject var birthday: Birthday
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var messageToShare = ""
    
    var messages: [BirthdayMessage] {
        (birthday.messages?.allObjects as? [BirthdayMessage])?.sorted { $0.createdAt > $1.createdAt } ?? []
    }
    
    var body: some View {
        NavigationView {
            if messages.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "message.badge")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No Messages Yet")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Generate your first birthday message for \(birthday.name)")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                List {
                    ForEach(messages, id: \.id) { message in
                        MessageHistoryCard(
                            message: message,
                            onShare: { content in
                                messageToShare = content
                                showingShareSheet = true
                            }
                        )
                    }
                }
            }
        }
        .navigationTitle("Message History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [messageToShare])
        }
    }
}

struct MessageHistoryCard: View {
    let message: BirthdayMessage
    let onShare: (String) -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(RelativeDateTimeFormatter().localizedString(for: message.createdAt, relativeTo: Date()))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: { onShare(message.content) }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption)
                }
            }
            
            Text(message.content)
                .font(.body)
                .lineLimit(isExpanded ? nil : 3)
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            
            if let prompt = message.usedPrompt, !prompt.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Custom Prompt:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(prompt)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

struct MessageHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleBirthday = Birthday(context: context)
        sampleBirthday.id = UUID()
        sampleBirthday.name = "John Doe"
        sampleBirthday.createdAt = Date()
        sampleBirthday.updatedAt = Date()
        
        let message = BirthdayMessage(context: context)
        message.id = UUID()
        message.content = "Happy birthday, John! Wishing you an amazing year ahead filled with adventures and joy!"
        message.createdAt = Date()
        message.birthday = sampleBirthday
        
        return MessageHistoryView(birthday: sampleBirthday)
    }
}