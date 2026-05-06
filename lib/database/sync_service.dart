import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'database_helper.dart';

/// Monitors connectivity and simulates syncing unsynced appointments
class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;
  int _pendingCount = 0;

  bool get isOnline => _isOnline;
  int get pendingCount => _pendingCount;

  /// Initialize the sync service and start monitoring connectivity
  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = !results.contains(ConnectivityResult.none);
    _pendingCount = await _dbHelper.getUnsyncedCount();

    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final wasOffline = !_isOnline;
      _isOnline = !results.contains(ConnectivityResult.none);

      if (_isOnline && wasOffline) {
        await syncPendingAppointments();
      }
    });
  }

  /// Simulate syncing pending appointments
  Future<int> syncPendingAppointments() async {
    if (!_isOnline) return 0;

    try {
      final unsynced = await _dbHelper.getUnsyncedAppointments();
      if (unsynced.isEmpty) return 0;

      // Simulate network delay for sync
      await Future.delayed(const Duration(milliseconds: 500));

      // Mark all as synced (simulated backend sync)
      await _dbHelper.markAllAsSynced();
      _pendingCount = 0;

      debugPrint('SyncService: Synced ${unsynced.length} appointments');
      return unsynced.length;
    } catch (e) {
      debugPrint('SyncService: Sync failed - $e');
      return 0;
    }
  }

  /// Refresh pending count
  Future<void> refreshPendingCount() async {
    _pendingCount = await _dbHelper.getUnsyncedCount();
  }

  /// Dispose the subscription
  void dispose() {
    _subscription?.cancel();
  }
}
