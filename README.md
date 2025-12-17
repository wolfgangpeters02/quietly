# Quietly

A reading tracker app to help you build consistent reading habits.

## Apps

| Platform | Location | Stack |
|----------|----------|-------|
| **Web** | [`/web`](./web) | React + TypeScript + Vite + Tailwind |
| **iOS** | [`/ios`](./ios) | SwiftUI + Swift |

## Features

- **Book Management** - Search via OpenLibrary, ISBN lookup, or manual entry
- **Reading Sessions** - Timer with pause/resume and page tracking
- **Notes & Quotes** - Capture thoughts with optional OCR scanning
- **Reading Goals** - Daily, weekly, monthly, or yearly targets
- **Statistics** - Track streaks, total time, and reading speed
- **Notifications** - Daily reminders and achievement alerts

## Backend

Both apps share a [Supabase](https://supabase.com) backend:
- PostgreSQL database
- Email/password authentication
- Row-Level Security (RLS)

## Getting Started

### Web App

```bash
cd web
npm install
npm run dev
```

### iOS App

1. Open `/ios` in Xcode
2. Add Swift Package: `https://github.com/supabase/supabase-swift`
3. Build and run

## License

Private project.
