import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/appointment.dart';
import '../utils/constants.dart';

class AppointmentProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all appointments from SQLite
  Future<void> loadAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _appointments = await _dbHelper.getAllAppointments();
    } catch (e) {
      _error = 'Failed to load appointments: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Book a new appointment with conflict detection
  Future<Map<String, dynamic>> bookAppointment({
    required String name,
    required String serviceType,
    required String date,
    required String timeSlot,
  }) async {
    try {
      // 1. Check if slot is available
      final isAvailable = await _dbHelper.isSlotAvailable(date, timeSlot);
      if (!isAvailable) {
        return {'success': false, 'message': 'This time slot is fully booked. Please choose another.'};
      }

      // 2. Get next queue position for the date
      final queuePos = await _dbHelper.getNextQueuePosition(date);

      // 3. Create appointment
      final appointment = Appointment(
        name: name,
        serviceType: serviceType,
        date: date,
        timeSlot: timeSlot,
        status: AppointmentStatus.scheduled,
        queuePosition: queuePos,
        isSynced: false,
      );

      // 4. Save to database
      await _dbHelper.insertAppointment(appointment);

      // 5. Refresh list
      await loadAppointments();

      return {'success': true, 'message': 'Booking confirmed!', 'appointment': appointment};
    } catch (e) {
      return {'success': false, 'message': 'Booking failed: $e'};
    }
  }

  /// Get unavailable slots for a given date
  Future<Set<String>> getUnavailableSlots(String date) async {
    final unavailable = <String>{};
    for (final slot in TimeSlots.all) {
      final available = await _dbHelper.isSlotAvailable(date, slot);
      if (!available) unavailable.add(slot);
    }
    return unavailable;
  }

  /// Update appointment status
  Future<bool> updateStatus(String id, String status) async {
    try {
      await _dbHelper.updateStatus(id, status);
      await loadAppointments();
      return true;
    } catch (e) {
      _error = 'Failed to update: $e';
      notifyListeners();
      return false;
    }
  }

  /// Cancel an appointment
  Future<bool> cancelAppointment(String id) async {
    return updateStatus(id, AppointmentStatus.cancelled);
  }

  /// Reschedule an appointment
  Future<Map<String, dynamic>> rescheduleAppointment(String id, String newDate, String newTimeSlot) async {
    try {
      final isAvailable = await _dbHelper.isSlotAvailable(newDate, newTimeSlot);
      if (!isAvailable) {
        return {'success': false, 'message': 'New time slot is fully booked.'};
      }

      final existing = await _dbHelper.getAppointmentById(id);
      if (existing == null) {
        return {'success': false, 'message': 'Appointment not found.'};
      }

      final queuePos = await _dbHelper.getNextQueuePosition(newDate);
      final updated = existing.copyWith(
        date: newDate,
        timeSlot: newTimeSlot,
        queuePosition: queuePos,
        status: AppointmentStatus.scheduled,
        isSynced: false,
      );
      await _dbHelper.updateAppointment(updated);
      await loadAppointments();
      return {'success': true, 'message': 'Rescheduled successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Reschedule failed: $e'};
    }
  }

  /// Search and filter
  Future<List<Appointment>> searchAndFilter({
    String? query,
    String? date,
    String? status,
    String? serviceType,
  }) async {
    try {
      return await _dbHelper.getFilteredAppointments(
        searchQuery: query,
        date: date,
        status: status,
        serviceType: serviceType,
      );
    } catch (e) {
      return [];
    }
  }

  /// Get status counts for dashboard
  Future<Map<String, int>> getStatusCounts() async {
    try {
      return await _dbHelper.getStatusCounts();
    } catch (e) {
      return {};
    }
  }
}
