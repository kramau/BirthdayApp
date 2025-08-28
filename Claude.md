# Birthday Reminder iOS App

## Project Overview
Create a native iOS app in Swift that helps users manage birthdays, generate personalized messages with AI assistance, and share them through iOS sharing capabilities.

## Core Features
- Birthday list management with CRUD operations
- CSV mass import functionality
- Smart timeline showing last 2 and next 10 birthdays
- AI-powered birthday message generation using ChatGPT API
- Message history with timestamps
- iOS native sharing integration
- Configurable message templates

## Technical Stack
- **Language**: Swift
- **Framework**: SwiftUI
- **Data Persistence**: Core Data
- **AI Integration**: OpenAI API
- **File Import**: UniformTypeIdentifiers for CSV
- **Sharing**: UIActivityViewController

## App Structure

### 1. Core Data Models

#### Birthday Entity
```swift
// Birthday.swift
@objc(Birthday)
class Birthday: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var birthDate: Date
    @NSManaged var notes: String?
    @NSManaged var personalityTraits: String?
    @NSManaged var interests: String?
    @NSManaged var relationship: String?
    @NSManaged var createdAt: Date
    @NSManaged var updatedAt: Date
    @NSManaged var messages: NSSet?
}
```

#### BirthdayMessage Entity
```swift
// BirthdayMessage.swift
@objc(BirthdayMessage)
class BirthdayMessage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var content: String
    @NSManaged var createdAt: Date
    @NSManaged var usedPrompt: String?
    @NSManaged var birthday: Birthday
}
```

### 2. Main Views

#### ContentView (Tab Container)
```swift
// ContentView.swift
struct ContentView: View {
    var body: some View {
        TabView {
            BirthdayTimelineView()
                .tabItem {
                    Image(systemName: "calendar.badge.clock")
                    Text("Timeline")
                }
            
            BirthdayListView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("All Birthdays")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}
```

#### BirthdayTimelineView
```swift
// BirthdayTimelineView.swift
struct BirthdayTimelineView: View {
    @FetchRequest var birthdays: FetchedResults<Birthday>
    
    init() {
        // Configure fetch request for last 2 and next 10 birthdays
        let calendar = Calendar.current
        let today = Date()
        
        _birthdays = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Birthday.birthDate, ascending: true)],
            predicate: NSPredicate(format: "birthDate >= %@ OR birthDate <= %@", 
                                 calendar.date(byAdding: .day, value: -730, to: today)!,
                                 calendar.date(byAdding: .day, value: 365, to: today)!)
        )
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Recent & Upcoming") {
                    ForEach(filteredBirthdays, id: \.id) { birthday in
                        BirthdayRowView(birthday: birthday)
                            .onTapGesture {
                                // Navigate to birthday detail
                            }
                    }
                }
            }
            .navigationTitle("Birthday Timeline")
        }
    }
    
    private var filteredBirthdays: [Birthday] {
        let calendar = Calendar.current
        let today = Date()
        
        // Logic to get last 2 and next 10 birthdays
        // Implementation needed for birthday sorting logic
    }
}
```

#### BirthdayDetailView
```swift
// BirthdayDetailView.swift
struct BirthdayDetailView: View {
    @ObservedObject var birthday: Birthday
    @State private var showingMessageGenerator = false
    @State private var showingMessageHistory = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Birthday info section
                BirthdayInfoSection(birthday: birthday)
                
                // Quick actions
                HStack(spacing: 15) {
                    Button("Generate Message") {
                        showingMessageGenerator = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Message History") {
                        showingMessageHistory = true
                    }
                    .buttonStyle(.bordered)
                }
                
                // Recent messages preview
                RecentMessagesPreview(birthday: birthday)
            }
            .padding()
        }
        .navigationTitle(birthday.name)
        .sheet(isPresented: $showingMessageGenerator) {
            MessageGeneratorView(birthday: birthday)
        }
        .sheet(isPresented: $showingMessageHistory) {
            MessageHistoryView(birthday: birthday)
        }
    }
}
```

#### MessageGeneratorView
```swift
// MessageGeneratorView.swift
struct MessageGeneratorView: View {
    @ObservedObject var birthday: Birthday
    @State private var generatedMessage = ""
    @State private var customPrompt = ""
    @State private var isGenerating = false
    @State private var showingShareSheet = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Input section
                VStack(alignment: .leading) {
                    Text("Custom Instructions (Optional)")
                        .font(.headline)
                    
                    TextEditor(text: $customPrompt)
                        .frame(minHeight: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                }
                
                // Generate button
                Button(action: generateMessage) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isGenerating ? "Generating..." : "Generate Birthday Message")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGenerating)
                
                // Generated message display
                if !generatedMessage.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Generated Message")
                            .font(.headline)
                        
                        Text(generatedMessage)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        HStack {
                            Button("Save Message") {
                                saveMessage()
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Button("Share") {
                                showingShareSheet = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Generate Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [generatedMessage])
        }
    }
    
    private func generateMessage() {
        // OpenAI API integration
        isGenerating = true
        
        Task {
            do {
                let message = try await OpenAIService.shared.generateBirthdayMessage(
                    for: birthday,
                    customPrompt: customPrompt
                )
                
                await MainActor.run {
                    generatedMessage = message
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    // Handle error
                    isGenerating = false
                }
            }
        }
    }
    
    private func saveMessage() {
        // Save to Core Data
        let context = PersistenceController.shared.container.viewContext
        let message = BirthdayMessage(context: context)
        message.id = UUID()
        message.content = generatedMessage
        message.createdAt = Date()
        message.usedPrompt = customPrompt
        message.birthday = birthday
        
        try? context.save()
        dismiss()
    }
}
```

### 3. Services

#### OpenAI Service
```swift
// OpenAIService.swift
import Foundation

class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    private let apiKey = "YOUR_OPENAI_API_KEY" // Store securely
    
    func generateBirthdayMessage(for birthday: Birthday, customPrompt: String = "") async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        var prompt = """
        Generate a personalized birthday message for \(birthday.name).
        
        Person details:
        - Relationship: \(birthday.relationship ?? "friend")
        - Interests: \(birthday.interests ?? "various")
        - Personality: \(birthday.personalityTraits ?? "wonderful")
        - Notes: \(birthday.notes ?? "")
        """
        
        if !customPrompt.isEmpty {
            prompt += "\n\nAdditional instructions: \(customPrompt)"
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant that creates warm, personal birthday messages."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 200,
            "temperature": 0.7
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        return response.choices.first?.message.content ?? "Happy Birthday!"
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}
```

#### CSV Import Service
```swift
// CSVImportService.swift
import Foundation
import UniformTypeIdentifiers

class CSVImportService {
    static func importBirthdays(from url: URL) async throws -> [Birthday] {
        let content = try String(contentsOf: url)
        let lines = content.components(separatedBy: .newlines)
        
        guard lines.count > 1 else {
            throw ImportError.invalidFormat
        }
        
        let headers = lines[0].components(separatedBy: ",")
        var birthdays: [Birthday] = []
        
        for i in 1..<lines.count {
            let values = lines[i].components(separatedBy: ",")
            guard values.count >= 2 else { continue }
            
            let context = PersistenceController.shared.container.viewContext
            let birthday = Birthday(context: context)
            birthday.id = UUID()
            birthday.name = values[0].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Parse date - expect MM/DD/YYYY or DD/MM/YYYY format
            let dateString = values[1].trimmingCharacters(in: .whitespacesAndNewlines)
            if let date = parseDate(from: dateString) {
                birthday.birthDate = date
            }
            
            // Additional fields if present
            if values.count > 2 {
                birthday.relationship = values[2].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if values.count > 3 {
                birthday.interests = values[3].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if values.count > 4 {
                birthday.notes = values[4].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            birthday.createdAt = Date()
            birthday.updatedAt = Date()
            
            birthdays.append(birthday)
        }
        
        return birthdays
    }
    
    private static func parseDate(from string: String) -> Date? {
        let formatter = DateFormatter()
        
        // Try different date formats
        let formats = ["MM/dd/yyyy", "dd/MM/yyyy", "yyyy-MM-dd", "MM-dd-yyyy"]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return date
            }
        }
        
        return nil
    }
}

enum ImportError: Error {
    case invalidFormat
    case invalidDate
}
```

### 4. Supporting Views and Components

#### ShareSheet
```swift
// ShareSheet.swift
import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
```

#### DocumentPicker
```swift
// DocumentPicker.swift
import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.commaSeparatedText])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentPicked: onDocumentPicked)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onDocumentPicked: (URL) -> Void
        
        init(onDocumentPicked: @escaping (URL) -> Void) {
            self.onDocumentPicked = onDocumentPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onDocumentPicked(url)
        }
    }
}
```

## Implementation Steps

### Phase 1: Core Setup
1. Create new iOS project with SwiftUI
2. Set up Core Data stack with Birthday and BirthdayMessage entities
3. Implement basic CRUD operations for birthdays
4. Create main navigation structure with TabView

### Phase 2: Birthday Management
1. Implement BirthdayListView with add/edit/delete functionality
2. Create BirthdayDetailView with comprehensive birthday information
3. Add form validation and error handling
4. Implement search and filtering capabilities

### Phase 3: Timeline Feature
1. Create birthday timeline logic (last 2, next 10)
2. Implement date calculations and sorting
3. Add visual indicators for upcoming birthdays
4. Create notification scheduling for birthday reminders

### Phase 4: CSV Import
1. Implement DocumentPicker for CSV file selection
2. Create CSV parsing service with error handling
3. Add import preview and confirmation flow
4. Handle duplicate detection and merging options

### Phase 5: AI Integration
1. Set up OpenAI API service with secure key storage
2. Implement MessageGeneratorView with custom prompts
3. Add message history and management
4. Create message templates and customization options

### Phase 6: Sharing & Polish
1. Implement iOS sharing integration
2. Add app settings and configuration options
3. Implement data backup and restore features
4. Add comprehensive error handling and user feedback
5. Perform testing and optimization

## Security Considerations
- Store OpenAI API key securely using Keychain Services
- Validate all CSV input data
- Implement proper error handling for network requests
- Add user permissions for file access and notifications

## Testing Strategy
- Unit tests for Core Data operations
- Unit tests for CSV import functionality
- Integration tests for OpenAI API
- UI tests for main user flows
- Test with various CSV formats and edge cases

## Future Enhancements
- Push notifications for birthday reminders
- Widget support for upcoming birthdays
- Multiple message templates
- Photo integration for contacts
- Sync with iOS Contacts app
- Dark mode optimization
- Localization support
