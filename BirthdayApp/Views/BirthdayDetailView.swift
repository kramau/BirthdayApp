import SwiftUI

struct BirthdayDetailView: View {
    @ObservedObject var birthday: Birthday
    @State private var showingMessageGenerator = false
    @State private var showingMessageHistory = false
    @State private var showingEditView = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                BirthdayInfoSection(birthday: birthday)
                
                HStack(spacing: 15) {
                    Button("Generate Message") {
                        showingMessageGenerator = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!hasOpenAIKey)
                    
                    Button("Message History") {
                        showingMessageHistory = true
                    }
                    .buttonStyle(.bordered)
                }
                
                RecentMessagesPreview(birthday: birthday)
            }
            .padding()
        }
        .navigationTitle(birthday.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditView = true
                }
            }
        }
        .sheet(isPresented: $showingMessageGenerator) {
            MessageGeneratorView(birthday: birthday)
        }
        .sheet(isPresented: $showingMessageHistory) {
            MessageHistoryView(birthday: birthday)
        }
        .sheet(isPresented: $showingEditView) {
            EditBirthdayView(birthday: birthday)
        }
    }
    
    private var hasOpenAIKey: Bool {
        !UserDefaults.standard.string(forKey: "openai_api_key")?.isEmpty ?? true
    }
}

struct BirthdayInfoSection: View {
    let birthday: Birthday
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Birthday")
                        .font(.headline)
                    Text(formattedBirthDate)
                        .font(.title2)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Age")
                        .font(.headline)
                    Text("\(birthday.age)")
                        .font(.title2)
                        .fontWeight(.medium)
                }
            }
            
            if birthday.daysUntilBirthday >= 0 {
                HStack {
                    Text("Next Birthday")
                        .font(.headline)
                    Spacer()
                    Text(daysUntilText)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(birthday.daysUntilBirthday <= 7 ? .red : .blue)
                }
            }
            
            if let relationship = birthday.relationship {
                DetailRow(title: "Relationship", content: relationship)
            }
            
            if let interests = birthday.interests {
                DetailRow(title: "Interests", content: interests)
            }
            
            if let traits = birthday.personalityTraits {
                DetailRow(title: "Personality", content: traits)
            }
            
            if let notes = birthday.notes {
                DetailRow(title: "Notes", content: notes)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: birthday.birthDate)
    }
    
    private var daysUntilText: String {
        let days = birthday.daysUntilBirthday
        if days == 0 {
            return "Today! 🎉"
        } else if days == 1 {
            return "Tomorrow 🎂"
        } else {
            return "in \(days) days"
        }
    }
}

struct DetailRow: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct RecentMessagesPreview: View {
    let birthday: Birthday
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Messages")
                .font(.headline)
            
            if let messages = birthday.messages?.allObjects as? [BirthdayMessage],
               !messages.isEmpty {
                let sortedMessages = messages.sorted { $0.createdAt > $1.createdAt }
                
                ForEach(sortedMessages.prefix(3), id: \.id) { message in
                    MessagePreviewCard(message: message)
                }
            } else {
                Text("No messages yet")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
}

struct MessagePreviewCard: View {
    let message: BirthdayMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(message.content)
                .font(.body)
                .lineLimit(3)
            
            Text(RelativeDateTimeFormatter().localizedString(for: message.createdAt, relativeTo: Date()))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

struct BirthdayDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleBirthday = Birthday(context: context)
        sampleBirthday.id = UUID()
        sampleBirthday.name = "John Doe"
        sampleBirthday.birthDate = Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
        sampleBirthday.relationship = "Friend"
        sampleBirthday.interests = "Photography, Hiking"
        sampleBirthday.personalityTraits = "Creative, Adventurous"
        sampleBirthday.notes = "Loves outdoor activities"
        sampleBirthday.createdAt = Date()
        sampleBirthday.updatedAt = Date()
        
        return NavigationView {
            BirthdayDetailView(birthday: sampleBirthday)
        }
    }
}