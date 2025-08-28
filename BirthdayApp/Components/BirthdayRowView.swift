import SwiftUI

struct BirthdayRowView: View {
    let birthday: Birthday
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(birthday.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(formattedBirthDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let relationship = birthday.relationship {
                        Text("• \(relationship)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if birthday.daysUntilBirthday >= 0 {
                    Text(daysUntilText)
                        .font(.caption)
                        .foregroundColor(birthday.daysUntilBirthday <= 7 ? .red : .blue)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Age \(birthday.age)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if birthday.daysUntilBirthday == 0 {
                    Text("🎉 TODAY!")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                } else if birthday.daysUntilBirthday == 1 {
                    Text("🎂 Tomorrow")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    private var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: birthday.birthDate)
    }
    
    private var daysUntilText: String {
        let days = birthday.daysUntilBirthday
        if days == 0 {
            return "Today!"
        } else if days == 1 {
            return "Tomorrow"
        } else if days < 0 {
            return "\(abs(days)) days ago"
        } else {
            return "in \(days) days"
        }
    }
}

struct BirthdayRowView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleBirthday = Birthday(context: context)
        sampleBirthday.id = UUID()
        sampleBirthday.name = "John Doe"
        sampleBirthday.birthDate = Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
        sampleBirthday.relationship = "Friend"
        sampleBirthday.createdAt = Date()
        sampleBirthday.updatedAt = Date()
        
        return BirthdayRowView(birthday: sampleBirthday)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}