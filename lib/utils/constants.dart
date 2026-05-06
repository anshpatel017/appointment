import 'package:flutter/material.dart';

// ─── Service Types ───────────────────────────────────────────────────────────
class ServiceTypes {
  static const List<String> all = [
    'General Checkup',
    'Dental',
    'Eye Examination',
    'Haircut & Styling',
    'Consultation',
    'Document Verification',
    'Admission Inquiry',
    'Other',
  ];
}

// ─── Time Slots ──────────────────────────────────────────────────────────────
class TimeSlots {
  static const int maxAppointmentsPerSlot = 3;
  static const int avgServiceDurationMinutes = 20;

  static const List<String> all = [
    '09:00 AM - 09:30 AM',
    '09:30 AM - 10:00 AM',
    '10:00 AM - 10:30 AM',
    '10:30 AM - 11:00 AM',
    '11:00 AM - 11:30 AM',
    '11:30 AM - 12:00 PM',
    '12:00 PM - 12:30 PM',
    '02:00 PM - 02:30 PM',
    '02:30 PM - 03:00 PM',
    '03:00 PM - 03:30 PM',
    '03:30 PM - 04:00 PM',
    '04:00 PM - 04:30 PM',
    '04:30 PM - 05:00 PM',
  ];
}

// ─── Appointment Status ──────────────────────────────────────────────────────
class AppointmentStatus {
  static const String scheduled = 'Scheduled';
  static const String inProgress = 'In Progress';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';

  static const List<String> all = [
    scheduled,
    inProgress,
    completed,
    cancelled,
  ];
}

// ─── App Colors ──────────────────────────────────────────────────────────────
class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42DB);

  // Accent
  static const Color accent = Color(0xFF00D9A6);
  static const Color accentLight = Color(0xFF5EFFD4);

  // Background
  static const Color scaffoldBg = Color(0xFF0F0E17);
  static const Color cardBg = Color(0xFF1A1932);
  static const Color surfaceBg = Color(0xFF232147);

  // Status colors
  static const Color scheduled = Color(0xFF5B8DEF);
  static const Color inProgress = Color(0xFFFFB84D);
  static const Color completed = Color(0xFF4ADE80);
  static const Color cancelled = Color(0xFFFF6B6B);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0AECF);
  static const Color textMuted = Color(0xFF6B6893);

  // Misc
  static const Color divider = Color(0xFF2E2B54);
  static const Color shimmer = Color(0xFF3D3A6E);

  static Color statusColor(String status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return scheduled;
      case AppointmentStatus.inProgress:
        return inProgress;
      case AppointmentStatus.completed:
        return completed;
      case AppointmentStatus.cancelled:
        return cancelled;
      default:
        return textSecondary;
    }
  }
}
