import Foundation
import CoreData

@objc(BirthdayMessage)
public class BirthdayMessage: NSManagedObject {
    
}

extension BirthdayMessage {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BirthdayMessage> {
        return NSFetchRequest<BirthdayMessage>(entityName: "BirthdayMessage")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var content: String
    @NSManaged public var createdAt: Date
    @NSManaged public var usedPrompt: String?
    @NSManaged public var birthday: Birthday
}

extension BirthdayMessage : Identifiable {
    
}