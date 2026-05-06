import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

/// Monitors connectivity and syncs unsynced appointments
class SyncService extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;
  int _pendingCount = 0;
  bool _isSyncing = false;
  
  // Stream to notify UI of sync results
  final _syncResultController = StreamController<String>.broadcast();
  Stream<String> get syncResultStream => _syncResultController.stream;

  bool get isOnline => _isOnline;
  int get pendingCount => _pendingCount;
  bool get isSyncing => _isSyncing;

  /// Initialize the sync service and start monitoring connectivity
  Future<void> initialize() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = !results.contains(ConnectivityResult.none);
    } catch (e) {
      _isOnline = true; // Assume online if check fails
    }

    await refreshPendingCount();

    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final wasOffline = !_isOnline;
      _isOnline = !results.contains(ConnectivityResult.none);
      notifyListeners();

      if (_isOnline && wasOffline) {
        await syncPendingAppointments();
      }
    });
  }

  /// Simulate syncing pending appointments
  Future<int> syncPendingAppointments() async {
    if (!_isOnline || _isSyncing) return 0;

    try {
      _isSyncing = true;
      notifyListeners();

      final unsynced = await _dbHelper.getUnsyncedAppointments();
      if (unsynced.isEmpty) {
        _isSyncing = false;
        notifyListeners();
        return 0;
      }

      // Simulate network delay for sync
      await Future.delayed(const Duration(milliseconds: 800));

      // Mark all as synced (simulated backend sync)
      await _dbHelper.markAllAsSynced();
      int syncedCount = unsynced.length;
      _pendingCount = 0;
      _isSyncing = false;
      notifyListeners();

      _syncResultController.add('Successfully synced $syncedCount appointments');
      debugPrint('SyncService: Synced $syncedCount appointments');
      return syncedCount;
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      _syncResultController.add('Sync failed: Please check your connection');
      debugPrint('SyncService: Sync failed - $e');
      return 0;
    }
  }

  /// Refresh pending count
  Future<void> refreshPendingCount() async {
    _pendingCount = await _dbHelper.getUnsyncedCount();
    notifyListeners();
  }

  /// Dispose the subscription
  @override
  void dispose() {
    _subscription?.cancel();
    _syncResultController.close();
    super.dispose();
  }
}
