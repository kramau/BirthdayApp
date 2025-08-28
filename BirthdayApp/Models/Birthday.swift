import Foundation
import CoreData

@objc(Birthday)
public class Birthday: NSManagedObject {
    
}

extension Birthday {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Birthday> {
        return NSFetchRequest<Birthday>(entityName: "Birthday")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var birthDate: Date
    @NSManaged public var notes: String?
    @NSManaged public var personalityTraits: String?
    @NSManaged public var interests: String?
    @NSManaged public var relationship: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var messages: NSSet?
}

extension Birthday {
    
    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: BirthdayMessage)
    
    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: BirthdayMessage)
    
    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)
    
    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)
}

extension Birthday : Identifiable {
    
}

extension Birthday {
    var nextBirthday: Date {
        let calendar = Calendar.current
        let today = Date()
        let currentYear = calendar.component(.year, from: today)
        
        var components = calendar.dateComponents([.month, .day], from: birthDate)
        components.year = currentYear
        
        guard let thisYearBirthday = calendar.date(from: components) else {
            return birthDate
        }
        
        if thisYearBirthday < today {
            components.year = currentYear + 1
            return calendar.date(from: components) ?? birthDate
        }
        
        return thisYearBirthday
    }
    
    var daysUntilBirthday: Int {
        let calendar = Calendar.current
        let today = Date()
        let nextBirthday = self.nextBirthday
        
        return calendar.dateComponents([.day], from: today, to: nextBirthday).day ?? 0
    }
    
    var age: Int {
        let calendar = Calendar.current
        let today = Date()
        return calendar.dateComponents([.year], from: birthDate, to: today).year ?? 0
    }
}