import SwiftUI
import UniformTypeIdentifiers

struct CSVImportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingDocumentPicker = false
    @State private var importedBirthdays: [ImportedBirthday] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var importStep: ImportStep = .selectFile
    
    enum ImportStep {
        case selectFile
        case preview
        case importing
        case completed
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                switch importStep {
                case .selectFile:
                    selectFileView
                case .preview:
                    previewView
                case .importing:
                    importingView
                case .completed:
                    completedView
                }
            }
            .padding()
            .navigationTitle("Import CSV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker { url in
                importCSV(from: url)
            }
        }
        .alert("Import Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var selectFileView: some View {
        VStack(spacing: 24) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 12) {
                Text("Import Birthdays from CSV")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Select a CSV file containing birthday information. The file should have columns for Name, Birthday, and optionally Relationship, Interests, Personality, and Notes.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                Text("Expected CSV Format:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name,Birthday,Relationship,Interests")
                        .font(.system(.caption, design: .monospaced))
                    Text("John Doe,12/15/1990,Friend,Photography")
                        .font(.system(.caption, design: .monospaced))
                    Text("Jane Smith,03/22/1985,Colleague,Hiking")
                        .font(.system(.caption, design: .monospaced))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            Button("Select CSV File") {
                showingDocumentPicker = true
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
        }
    }
    
    private var previewView: some View {
        VStack(spacing: 16) {
            Text("Preview Import")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("\(importedBirthdays.count) birthdays found")
                .foregroundColor(.secondary)
            
            List(importedBirthdays.indices, id: \.self) { index in
                let birthday = importedBirthdays[index]
                VStack(alignment: .leading, spacing: 4) {
                    Text(birthday.name)
                        .font(.headline)
                    Text(DateFormatter.mediumDate.string(from: birthday.birthDate))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if let relationship = birthday.relationship {
                        Text("Relationship: \(relationship)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 2)
            }
            .frame(maxHeight: 300)
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    importStep = .selectFile
                    importedBirthdays = []
                }
                .buttonStyle(.bordered)
                
                Button("Import All") {
                    performImport()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private var importingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Importing birthdays...")
                .font(.headline)
            
            Text("Please wait while we import your birthday data.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var completedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Import Completed!")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Successfully imported \(importedBirthdays.count) birthdays.")
                .foregroundColor(.secondary)
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func importCSV(from url: URL) {
        isLoading = true
        
        Task {
            do {
                let birthdays = try await CSVImportService.importBirthdays(from: url, context: viewContext)
                
                await MainActor.run {
                    importedBirthdays = birthdays
                    importStep = .preview
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isLoading = false
                }
            }
        }
    }
    
    private func performImport() {
        importStep = .importing
        
        Task {
            do {
                try CSVImportService.saveBirthdays(importedBirthdays, to: viewContext)
                
                await MainActor.run {
                    importStep = .completed
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save imported birthdays: \(error.localizedDescription)"
                    showingError = true
                    importStep = .preview
                }
            }
        }
    }
}

extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

struct CSVImportView_Previews: PreviewProvider {
    static var previews: some View {
        CSVImportView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}