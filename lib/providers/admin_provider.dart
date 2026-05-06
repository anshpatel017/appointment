import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/appointment.dart';
import '../utils/constants.dart';

class AdminProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Appointment> _allAppointments = [];
  List<Appointment> _todayQueue = [];
  Map<String, int> _statusCounts = {};
  bool _isLoading = false;

  List<Appointment> get allAppointments => _allAppointments;
  List<Appointment> get todayQueue => _todayQueue;
  Map<String, int> get statusCounts => _statusCounts;
  bool get isLoading => _isLoading;
  int get totalCount => _statusCounts.values.fold(0, (a, b) => a + b);

  /// Load all admin data
  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allAppointments = await _dbHelper.getAllAppointments();
      _todayQueue = await _dbHelper.getTodayQueue();
      _statusCounts = await _dbHelper.getStatusCounts();
    } catch (e) {
      debugPrint('AdminProvider error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Mark appointment as completed
  Future<bool> markCompleted(String id) async {
    try {
      await _dbHelper.updateStatus(id, AppointmentStatus.completed);
      await loadDashboard();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mark appointment as in progress
  Future<bool> markInProgress(String id) async {
    try {
      await _dbHelper.updateStatus(id, AppointmentStatus.inProgress);
      await loadDashboard();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cancel appointment
  Future<bool> cancelAppointment(String id) async {
    try {
      await _dbHelper.updateStatus(id, AppointmentStatus.cancelled);
      await loadDashboard();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Move queue forward
  Future<void> moveQueueForward() async {
    try {
      // Complete current in-progress
      final current = _todayQueue.where((a) => a.status == AppointmentStatus.inProgress);
      if (current.isNotEmpty) {
        await _dbHelper.updateStatus(current.first.id, AppointmentStatus.completed);
      }
      // Start next scheduled
      final refreshed = await _dbHelper.getTodayQueue();
      final next = refreshed.where((a) => a.status == AppointmentStatus.scheduled);
      if (next.isNotEmpty) {
        await _dbHelper.updateStatus(next.first.id, AppointmentStatus.inProgress);
      }
      await loadDashboard();
    } catch (e) {
      debugPrint('Move queue error: $e');
    }
  }
}
