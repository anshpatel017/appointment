import 'package:flutter/material.dart';

// ─── Service Types ───────────────────────────────────────────────────────────
class ServiceTypes {
  static const List<String> all = [
    'Regular Checkup',
    'Headache',
    'Fever & Cold',
    'Body Pain',
    'Stomach Issue',
    'Skin Consultation',
    'Emergency',
    'Other',
  ];
}

// ─── Time Slots ──────────────────────────────────────────────────────────────
class TimeSlots {
  static const int maxAppointmentsPerSlot = 1;
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
  // Primary palette (Teal Medical Theme)
  static const Color primary = Color(0xFF26A69A); // Vibrant Teal
  static const Color primaryLight = Color(0xFFB2DFDB);
  static const Color primaryDark = Color(0xFF00796B);

  // Accent
  static const Color accent = Color(0xFF4DB6AC);
  static const Color accentLight = Color(0xFFE0F2F1);

  // Background
  static const Color scaffoldBg = Color(0xFFF5F7F8); // Very light grey
  static const Color cardBg = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceBg = Color(0xFFF0F4F4); // Light teal tint grey

  // Status colors
  static const Color scheduled = Color(0xFF3B82F6); // Brighter blue
  static const Color inProgress = Color(0xFFF59E0B); // Amber/orange
  static const Color completed = Color(0xFF10B981); // Green
  static const Color cancelled = Color(0xFFEF4444); // Red

  // Text
  static const Color textPrimary = Color(0xFF1E293B); // Dark slate
  static const Color textSecondary = Color(0xFF475569); // Slate gray
  static const Color textMuted = Color(0xFF94A3B8); // Light gray

  // Misc
  static const Color divider = Color(0xFFE2E8F0); // Light border color
  static const Color shimmer = Color(0xFFE2E8F0);

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
