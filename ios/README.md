# Quietly - iOS Reading Tracker

A native iOS app for tracking your reading journey. Built with SwiftUI and Supabase.

## Features

- **Book Management**: Search books via OpenLibrary API, add by ISBN, or enter manually
- **Reading Sessions**: Timer-based reading with pause/resume support
- **Notes & Quotes**: Capture thoughts and quotes with OCR text scanning
- **Reading Goals**: Daily, weekly, monthly, or yearly reading targets
- **Statistics**: Track reading streaks, total time, and progress
- **Notifications**: Daily reading reminders and achievement alerts

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/wolfgangpeters02/quietly.git
cd quietly/Quietly
```

### 2. Open in Xcode

Open `Quietly.xcodeproj` in Xcode.

### 3. Install Dependencies

The project uses Swift Package Manager. Xcode will automatically fetch dependencies:

- [supabase-swift](https://github.com/supabase/supabase-swift) - Supabase SDK for Swift

### 4. Configure Supabase

The app is pre-configured with Supabase credentials in `Core/Constants/AppConstants.swift`.
For your own backend, update the `Supabase` enum with your project URL and anon key.

### 5. Build and Run

Select your target device/simulator and run the project (Cmd + R).

## Project Structure

```
Quietly/
├── App/                    # App entry point
├── Core/
│   ├── Constants/          # Colors, configuration
│   ├── Extensions/         # Swift extensions
│   └── Utilities/          # Helper functions
├── Services/
│   ├── Supabase/           # Database services
│   ├── OpenLibraryService  # Book search API
│   ├── NotificationService # Push notifications
│   └── OCRService          # Text recognition
├── Models/                 # Data models
├── ViewModels/             # MVVM view models
├── Views/
│   ├── Screens/            # Main app screens
│   └── Components/         # Reusable UI components
└── Navigation/             # App navigation
```

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern:

- **Models**: Swift structs with Codable conformance
- **Views**: SwiftUI views with declarative UI
- **ViewModels**: ObservableObject classes with @Published properties
- **Services**: Business logic and API communication

## Backend

The app uses an existing Supabase backend with:

- PostgreSQL database
- Row-Level Security (RLS)
- Email/password authentication
- OpenLibrary API integration for book data

## Design System

The app uses a warm, literary color palette:

- **Primary**: Warm brown (#514335)
- **Background**: Cream (#F5F1EB)
- **Accent**: Sage green (#69A279)

## License

This project is for personal use.
