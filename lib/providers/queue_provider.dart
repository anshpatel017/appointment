import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/appointment.dart';
import '../utils/constants.dart';

class QueueProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Appointment> _todayQueue = [];
  int _currentServing = 0;

  List<Appointment> get todayQueue => _todayQueue;
  int get currentServing => _currentServing;

  /// Load today's queue
  Future<void> loadTodayQueue() async {
    try {
      _todayQueue = await _dbHelper.getTodayQueue();
      _calculateCurrentServing();
      notifyListeners();
    } catch (e) {
      debugPrint('QueueProvider error: $e');
    }
  }

  /// Figure out which queue position is currently being served
  void _calculateCurrentServing() {
    // Find the first "In Progress" appointment
    final inProgress = _todayQueue.where(
      (a) => a.status == AppointmentStatus.inProgress,
    );
    if (inProgress.isNotEmpty) {
      _currentServing = inProgress.first.queuePosition;
      return;
    }
    // Otherwise, find the last completed + 1
    final completed = _todayQueue.where(
      (a) => a.status == AppointmentStatus.completed,
    );
    if (completed.isNotEmpty) {
      _currentServing = completed.last.queuePosition + 1;
    } else if (_todayQueue.isNotEmpty) {
      _currentServing = _todayQueue.first.queuePosition;
    } else {
      _currentServing = 0;
    }
  }

  /// Get estimated wait time for a given position (in minutes)
  int getEstimatedWait(int userPosition) {
    if (_currentServing <= 0 || userPosition <= _currentServing) return 0;
    final ahead = userPosition - _currentServing;
    return ahead * TimeSlots.avgServiceDurationMinutes;
  }

  /// Get user's position in queue by appointment ID
  int getUserPosition(String appointmentId) {
    final match = _todayQueue.where((a) => a.id == appointmentId);
    if (match.isEmpty) return 0;
    return match.first.queuePosition;
  }

  /// Move queue forward: mark current as completed, next as in progress
  Future<void> moveQueueForward() async {
    try {
      // Complete the current one
      final current = _todayQueue.where(
        (a) => a.status == AppointmentStatus.inProgress,
      );
      if (current.isNotEmpty) {
        await _dbHelper.updateStatus(current.first.id, AppointmentStatus.completed);
      }

      // Reload and find next scheduled
      _todayQueue = await _dbHelper.getTodayQueue();
      final nextScheduled = _todayQueue.where(
        (a) => a.status == AppointmentStatus.scheduled,
      );
      if (nextScheduled.isNotEmpty) {
        await _dbHelper.updateStatus(nextScheduled.first.id, AppointmentStatus.inProgress);
      }

      await loadTodayQueue();
    } catch (e) {
      debugPrint('Move queue error: $e');
    }
  }

  /// Start serving the first in queue
  Future<void> startServing() async {
    final scheduled = _todayQueue.where(
      (a) => a.status == AppointmentStatus.scheduled,
    );
    if (scheduled.isNotEmpty) {
      await _dbHelper.updateStatus(scheduled.first.id, AppointmentStatus.inProgress);
      await loadTodayQueue();
    }
  }
}
