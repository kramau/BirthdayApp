import SwiftUI
import CoreData

struct BirthdayTimelineView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Birthday.birthDate, ascending: true)],
        animation: .default)
    private var birthdays: FetchedResults<Birthday>
    
    var body: some View {
        NavigationView {
            List {
                Section("Recent & Upcoming") {
                    ForEach(filteredBirthdays, id: \.id) { birthday in
                        NavigationLink(destination: BirthdayDetailView(birthday: birthday)) {
                            BirthdayRowView(birthday: birthday)
                        }
                    }
                }
            }
            .navigationTitle("Birthday Timeline")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddBirthdayView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    private var filteredBirthdays: [Birthday] {
        let calendar = Calendar.current
        let today = Date()
        
        let sortedBirthdays = birthdays.sorted { birthday1, birthday2 in
            let days1 = calendar.dateComponents([.day], from: today, to: birthday1.nextBirthday).day ?? Int.max
            let days2 = calendar.dateComponents([.day], from: today, to: birthday2.nextBirthday).day ?? Int.max
            
            if days1 < 0 && days2 >= 0 { return false }
            if days1 >= 0 && days2 < 0 { return true }
            if days1 < 0 && days2 < 0 { return days1 > days2 }
            
            return days1 < days2
        }
        
        let recentBirthdays = sortedBirthdays.filter { birthday in
            let days = calendar.dateComponents([.day], from: today, to: birthday.nextBirthday).day ?? 0
            return days < 0 && days >= -14
        }.suffix(2)
        
        let upcomingBirthdays = sortedBirthdays.filter { birthday in
            let days = calendar.dateComponents([.day], from: today, to: birthday.nextBirthday).day ?? 0
            return days >= 0
        }.prefix(10)
        
        return Array(recentBirthdays) + Array(upcomingBirthdays)
    }
}

struct BirthdayTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        BirthdayTimelineView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}