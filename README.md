# Smart Appointment - Queue Management App

A Flutter-based Smart Appointment Scheduling & Queue Management App that enables users to book time slots, manage appointments, and allows administrators to monitor and control real-time queues with offline-first functionality.

## Features

- 📅 **Appointment Booking** — Book with name, service type, date & time slot
- 🔢 **Queue Management** — Real-time queue position & estimated wait time
- 👨‍💼 **Admin Dashboard** — View all appointments, manage queue, cancel/reschedule
- 🔍 **Search & Filter** — Search by name/ID, filter by date/status/service
- 📴 **Offline Support** — Book without internet, auto-sync when online
- ⚠️ **Conflict Detection** — Prevents double-booking and overbooking

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| State Management | Provider |
| Local Storage | SQLite (sqflite) |
| Architecture | Modular (Booking, Queue, Admin) |

## Getting Started

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── models/          # Data models
├── database/        # SQLite helper & sync service
├── providers/       # State management
├── screens/         # App screens
├── widgets/         # Reusable widgets
└── utils/           # Constants, theme, validators
```
