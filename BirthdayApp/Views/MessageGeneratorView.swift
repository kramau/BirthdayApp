import SwiftUI

struct MessageGeneratorView: View {
    @ObservedObject var birthday: Birthday
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var generatedMessage = ""
    @State private var customPrompt = ""
    @State private var isGenerating = false
    @State private var showingShareSheet = false
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Custom Instructions (Optional)")
                        .font(.headline)
                    
                    TextEditor(text: $customPrompt)
                        .frame(minHeight: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Button(action: generateMessage) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isGenerating ? "Generating..." : "Generate Birthday Message")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGenerating)
                
                if !generatedMessage.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Generated Message")
                            .font(.headline)
                        
                        ScrollView {
                            Text(generatedMessage)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .textSelection(.enabled)
                        }
                        .frame(maxHeight: 200)
                        
                        HStack(spacing: 12) {
                            Button("Save Message") {
                                saveMessage()
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Generate New") {
                                generateMessage()
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
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func generateMessage() {
        isGenerating = true
        generatedMessage = ""
        
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
                    errorMessage = error.localizedDescription
                    showingError = true
                    isGenerating = false
                }
            }
        }
    }
    
    private func saveMessage() {
        withAnimation {
            let message = BirthdayMessage(context: viewContext)
            message.id = UUID()
            message.content = generatedMessage
            message.createdAt = Date()
            message.usedPrompt = customPrompt.isEmpty ? nil : customPrompt
            message.birthday = birthday
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                errorMessage = "Failed to save message: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
}

struct MessageGeneratorView_Previews: PreviewProvider {
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
        
        return MessageGeneratorView(birthday: sampleBirthday)
            .environment(\.managedObjectContext, context)
    }
}