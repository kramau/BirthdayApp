import SwiftUI

struct SettingsView: View {
    @AppStorage("openai_api_key") private var openAIKey = ""
    @State private var showingKeyAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("AI Configuration") {
                    HStack {
                        Text("OpenAI API Key")
                        Spacer()
                        Button(openAIKey.isEmpty ? "Set Key" : "Update") {
                            showingKeyAlert = true
                        }
                        .foregroundColor(.blue)
                    }
                    
                    if !openAIKey.isEmpty {
                        HStack {
                            Text("Status")
                            Spacer()
                            Text("Configured")
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Section("Data Management") {
                    NavigationLink("Import from CSV") {
                        CSVImportView()
                    }
                    
                    Button("Export All Data") {
                        // TODO: Implement export functionality
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .alert("OpenAI API Key", isPresented: $showingKeyAlert) {
            TextField("API Key", text: $openAIKey)
            Button("Save") { }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your OpenAI API key to enable AI-powered message generation.")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}