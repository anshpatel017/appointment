import 'package:flutter/material.dart';
import '../database/sync_service.dart';
import '../utils/constants.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // This will be used with a Consumer in the parent
    return const SizedBox.shrink();
  }

  /// Build the actual banner content based on sync state
  static Widget buildBanner({
    required bool isOnline,
    required int pendingCount,
    required bool isSyncing,
    VoidCallback? onSyncTap,
  }) {
    if (isOnline && pendingCount == 0) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isOnline
            ? isSyncing
                ? AppColors.inProgress.withAlpha(25)
                : AppColors.accent.withAlpha(25)
            : AppColors.cancelled.withAlpha(25),
        border: Border(
          bottom: BorderSide(
            color: isOnline
                ? isSyncing
                    ? AppColors.inProgress.withAlpha(60)
                    : AppColors.accent.withAlpha(60)
                : AppColors.cancelled.withAlpha(60),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOnline
                ? isSyncing
                    ? Icons.sync_rounded
                    : Icons.cloud_done_rounded
                : Icons.cloud_off_rounded,
            color: isOnline
                ? isSyncing
                    ? AppColors.inProgress
                    : AppColors.accent
                : AppColors.cancelled,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOnline
                  ? isSyncing
                      ? 'Syncing $pendingCount appointment${pendingCount != 1 ? 's' : ''}...'
                      : '$pendingCount pending sync'
                  : 'You are offline • Bookings saved locally',
              style: TextStyle(
                color: isOnline
                    ? isSyncing
                        ? AppColors.inProgress
                        : AppColors.accent
                    : AppColors.cancelled,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isOnline && pendingCount > 0 && !isSyncing)
            GestureDetector(
              onTap: onSyncTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withAlpha(60)),
                ),
                child: const Text(
                  'Sync Now',
                  style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small sync status icon for AppBar
class SyncStatusIcon extends StatelessWidget {
  final SyncService syncService;

  const SyncStatusIcon({super.key, required this.syncService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: syncService,
      builder: (context, _) {
        if (syncService.isOnline && syncService.pendingCount == 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(
            children: [
              Icon(
                syncService.isOnline ? Icons.cloud_queue_rounded : Icons.cloud_off_rounded,
                color: syncService.isOnline ? AppColors.inProgress : AppColors.cancelled,
                size: 22,
              ),
              if (syncService.pendingCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.cancelled,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${syncService.pendingCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
