import SwiftUI

struct AddBirthdayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var relationship = ""
    @State private var interests = ""
    @State private var personalityTraits = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Name", text: $name)
                    DatePicker("Birthday", selection: $birthDate, displayedComponents: .date)
                    TextField("Relationship (optional)", text: $relationship)
                }
                
                Section("Personal Details") {
                    TextField("Interests", text: $interests, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("Personality Traits", text: $personalityTraits, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Birthday")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBirthday()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveBirthday() {
        withAnimation {
            let newBirthday = Birthday(context: viewContext)
            newBirthday.id = UUID()
            newBirthday.name = name
            newBirthday.birthDate = birthDate
            newBirthday.relationship = relationship.isEmpty ? nil : relationship
            newBirthday.interests = interests.isEmpty ? nil : interests
            newBirthday.personalityTraits = personalityTraits.isEmpty ? nil : personalityTraits
            newBirthday.notes = notes.isEmpty ? nil : notes
            newBirthday.createdAt = Date()
            newBirthday.updatedAt = Date()
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct AddBirthdayView_Previews: PreviewProvider {
    static var previews: some View {
        AddBirthdayView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}