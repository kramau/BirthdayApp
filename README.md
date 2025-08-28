# Birthday Reminder iOS App

A native iOS app built with SwiftUI that helps users manage birthdays, generate personalized AI-powered messages, and share them through iOS sharing capabilities.

## Features

### ✅ Completed
- **Birthday Management**: Add, edit, delete, and view birthday entries
- **Smart Timeline**: Shows last 2 and next 10 birthdays in chronological order
- **Birthday List**: Complete list of all birthdays with search functionality
- **CSV Import**: Mass import birthdays from CSV files with flexible format support
- **AI Message Generation**: Uses OpenAI GPT API to generate personalized birthday messages
- **Message History**: Save and view previously generated messages
- **iOS Sharing**: Native sharing integration for messages
- **Core Data**: Persistent storage for birthdays and messages

### 🏗️ Architecture
- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Local data persistence
- **MVVM Pattern**: Clean separation of concerns
- **Async/Await**: Modern concurrency for API calls

### 📁 Project Structure
```
BirthdayApp/
├── Models/
│   ├── Birthday.swift              # Core Data birthday entity
│   ├── BirthdayMessage.swift       # Core Data message entity
│   └── PersistenceController.swift # Core Data stack management
├── Views/
│   ├── ContentView.swift           # Main tab container
│   ├── BirthdayTimelineView.swift  # Timeline showing recent/upcoming birthdays
│   ├── BirthdayListView.swift      # Complete birthday list with search
│   ├── BirthdayDetailView.swift    # Detailed birthday information
│   ├── AddBirthdayView.swift       # Add new birthday form
│   ├── EditBirthdayView.swift      # Edit existing birthday
│   ├── MessageGeneratorView.swift  # AI message generation interface
│   ├── MessageHistoryView.swift    # View saved messages
│   ├── CSVImportView.swift         # CSV import workflow
│   └── SettingsView.swift          # App settings and configuration
├── Components/
│   ├── BirthdayRowView.swift       # Reusable birthday list item
│   ├── ShareSheet.swift            # iOS sharing integration
│   └── DocumentPicker.swift        # File picker for CSV import
├── Services/
│   ├── OpenAIService.swift         # OpenAI API integration
│   └── CSVImportService.swift      # CSV parsing and import logic
├── Resources/
│   └── BirthdayApp.xcdatamodeld/   # Core Data model
└── BirthdayApp.swift               # App entry point
```

## Getting Started

### Prerequisites
- Xcode 14.0 or later
- iOS 15.0 or later
- OpenAI API key (for message generation)

### Installation
1. Open the project in Xcode
2. Build and run on device or simulator
3. Configure OpenAI API key in Settings tab for AI message generation

### CSV Import Format
The app supports flexible CSV import with the following columns (case-insensitive):
- **Name** (required)
- **Birthday/BirthDate/Date** (required) - Formats: MM/dd/yyyy, dd/MM/yyyy, yyyy-MM-dd, etc.
- **Relationship** (optional)
- **Interests** (optional)
- **Personality/Traits** (optional)
- **Notes** (optional)

Example CSV:
```csv
Name,Birthday,Relationship,Interests
John Doe,12/15/1990,Friend,Photography
Jane Smith,03/22/1985,Colleague,Hiking
```

## Technical Details

### Core Data Model
- **Birthday Entity**: Stores personal information and birthday dates
- **BirthdayMessage Entity**: Stores generated messages with timestamps and prompts
- Automatic relationship management between birthdays and messages

### OpenAI Integration
- Secure API key storage using UserDefaults
- Contextual message generation using person details
- Error handling for API failures
- Customizable prompts for personalized messages

### Date Calculations
- Smart next birthday calculation considering year transitions
- Days until birthday with negative values for recent birthdays
- Age calculation from birth date

## Privacy & Security
- OpenAI API keys stored locally on device
- No personal data transmitted except to OpenAI for message generation
- All birthday data stored locally using Core Data
- Optional relationship and personal details for enhanced AI context

## Future Enhancements
- Push notifications for birthday reminders
- iOS Contacts integration
- Widget support for upcoming birthdays
- Photo integration for birthday contacts
- Multiple message templates
- Dark mode optimization
- Localization support