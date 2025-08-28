import SwiftUI
import CoreData

struct BirthdayListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Birthday.name, ascending: true)],
        animation: .default)
    private var birthdays: FetchedResults<Birthday>
    
    @State private var searchText = ""
    @State private var showingImportSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredBirthdays, id: \.id) { birthday in
                    NavigationLink(destination: BirthdayDetailView(birthday: birthday)) {
                        BirthdayRowView(birthday: birthday)
                    }
                }
                .onDelete(perform: deleteBirthdays)
            }
            .searchable(text: $searchText)
            .navigationTitle("All Birthdays")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Import") {
                        showingImportSheet = true
                    }
                    
                    NavigationLink(destination: AddBirthdayView()) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingImportSheet) {
                CSVImportView()
            }
        }
    }
    
    private var filteredBirthdays: [Birthday] {
        if searchText.isEmpty {
            return Array(birthdays)
        } else {
            return birthdays.filter { birthday in
                birthday.name.localizedCaseInsensitiveContains(searchText) ||
                birthday.relationship?.localizedCaseInsensitiveContains(searchText) == true ||
                birthday.interests?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    private func deleteBirthdays(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredBirthdays[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct BirthdayListView_Previews: PreviewProvider {
    static var previews: some View {
        BirthdayListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}