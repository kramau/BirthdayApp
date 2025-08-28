import SwiftUI

struct EditBirthdayView: View {
    @ObservedObject var birthday: Birthday
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var birthDate: Date
    @State private var relationship: String
    @State private var interests: String
    @State private var personalityTraits: String
    @State private var notes: String
    
    init(birthday: Birthday) {
        self.birthday = birthday
        _name = State(initialValue: birthday.name)
        _birthDate = State(initialValue: birthday.birthDate)
        _relationship = State(initialValue: birthday.relationship ?? "")
        _interests = State(initialValue: birthday.interests ?? "")
        _personalityTraits = State(initialValue: birthday.personalityTraits ?? "")
        _notes = State(initialValue: birthday.notes ?? "")
    }
    
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
            .navigationTitle("Edit Birthday")
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
            birthday.name = name
            birthday.birthDate = birthDate
            birthday.relationship = relationship.isEmpty ? nil : relationship
            birthday.interests = interests.isEmpty ? nil : interests
            birthday.personalityTraits = personalityTraits.isEmpty ? nil : personalityTraits
            birthday.notes = notes.isEmpty ? nil : notes
            birthday.updatedAt = Date()
            
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

struct EditBirthdayView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleBirthday = Birthday(context: context)
        sampleBirthday.id = UUID()
        sampleBirthday.name = "John Doe"
        sampleBirthday.birthDate = Date()
        sampleBirthday.relationship = "Friend"
        sampleBirthday.interests = "Photography, Hiking"
        sampleBirthday.personalityTraits = "Creative, Adventurous"
        sampleBirthday.notes = "Loves outdoor activities"
        sampleBirthday.createdAt = Date()
        sampleBirthday.updatedAt = Date()
        
        return EditBirthdayView(birthday: sampleBirthday)
            .environment(\.managedObjectContext, context)
    }
}