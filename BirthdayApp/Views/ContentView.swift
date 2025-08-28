import SwiftUI

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}