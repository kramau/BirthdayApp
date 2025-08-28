import Foundation
import CoreData
import UniformTypeIdentifiers

struct ImportedBirthday {
    let name: String
    let birthDate: Date
    let relationship: String?
    let interests: String?
    let personalityTraits: String?
    let notes: String?
}

class CSVImportService {
    static func importBirthdays(from url: URL, context: NSManagedObjectContext) async throws -> [ImportedBirthday] {
        let content = try String(contentsOf: url, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)
        
        guard lines.count > 1 else {
            throw ImportError.invalidFormat
        }
        
        let headers = lines[0].components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        var importedBirthdays: [ImportedBirthday] = []
        
        let nameIndex = headers.firstIndex(of: "name") ?? 0
        let dateIndex = headers.firstIndex(of: "birthday") ?? headers.firstIndex(of: "birthdate") ?? headers.firstIndex(of: "date") ?? 1
        let relationshipIndex = headers.firstIndex(of: "relationship")
        let interestsIndex = headers.firstIndex(of: "interests")
        let personalityIndex = headers.firstIndex(of: "personality") ?? headers.firstIndex(of: "traits")
        let notesIndex = headers.firstIndex(of: "notes")
        
        for i in 1..<lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty { continue }
            
            let values = parseCSVLine(line)
            guard values.count > max(nameIndex, dateIndex) else { continue }
            
            let name = values[nameIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { continue }
            
            let dateString = values[dateIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            guard let birthDate = parseDate(from: dateString) else {
                throw ImportError.invalidDate(line: i + 1, value: dateString)
            }
            
            let relationship = relationshipIndex.map { values.count > $0 ? values[$0].trimmingCharacters(in: .whitespacesAndNewlines) : nil }?.flatMap { $0.isEmpty ? nil : $0 }
            let interests = interestsIndex.map { values.count > $0 ? values[$0].trimmingCharacters(in: .whitespacesAndNewlines) : nil }?.flatMap { $0.isEmpty ? nil : $0 }
            let personalityTraits = personalityIndex.map { values.count > $0 ? values[$0].trimmingCharacters(in: .whitespacesAndNewlines) : nil }?.flatMap { $0.isEmpty ? nil : $0 }
            let notes = notesIndex.map { values.count > $0 ? values[$0].trimmingCharacters(in: .whitespacesAndNewlines) : nil }?.flatMap { $0.isEmpty ? nil : $0 }
            
            let importedBirthday = ImportedBirthday(
                name: name,
                birthDate: birthDate,
                relationship: relationship,
                interests: interests,
                personalityTraits: personalityTraits,
                notes: notes
            )
            
            importedBirthdays.append(importedBirthday)
        }
        
        return importedBirthdays
    }
    
    static func saveBirthdays(_ importedBirthdays: [ImportedBirthday], to context: NSManagedObjectContext) throws {
        for importedBirthday in importedBirthdays {
            let birthday = Birthday(context: context)
            birthday.id = UUID()
            birthday.name = importedBirthday.name
            birthday.birthDate = importedBirthday.birthDate
            birthday.relationship = importedBirthday.relationship
            birthday.interests = importedBirthday.interests
            birthday.personalityTraits = importedBirthday.personalityTraits
            birthday.notes = importedBirthday.notes
            birthday.createdAt = Date()
            birthday.updatedAt = Date()
        }
        
        try context.save()
    }
    
    private static func parseCSVLine(_ line: String) -> [String] {
        var values: [String] = []
        var currentValue = ""
        var insideQuotes = false
        var i = line.startIndex
        
        while i < line.endIndex {
            let char = line[i]
            
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                values.append(currentValue)
                currentValue = ""
            } else {
                currentValue.append(char)
            }
            
            i = line.index(after: i)
        }
        
        values.append(currentValue)
        
        return values.map { $0.replacingOccurrences(of: "\"", with: "") }
    }
    
    private static func parseDate(from string: String) -> Date? {
        let formatter = DateFormatter()
        
        let formats = [
            "MM/dd/yyyy",
            "dd/MM/yyyy", 
            "yyyy-MM-dd",
            "MM-dd-yyyy",
            "dd-MM-yyyy",
            "M/d/yyyy",
            "d/M/yyyy",
            "yyyy/MM/dd",
            "MM/dd/yy",
            "dd/MM/yy"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return date
            }
        }
        
        return nil
    }
}

enum ImportError: Error, LocalizedError {
    case invalidFormat
    case invalidDate(line: Int, value: String)
    case encodingError
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Invalid CSV format. File must have at least a header row and one data row."
        case .invalidDate(let line, let value):
            return "Invalid date format on line \(line): '\(value)'. Expected formats: MM/dd/yyyy, dd/MM/yyyy, yyyy-MM-dd, etc."
        case .encodingError:
            return "Unable to read file. Please ensure it's a valid CSV file with UTF-8 encoding."
        case .fileNotFound:
            return "File not found or cannot be accessed."
        }
    }
}