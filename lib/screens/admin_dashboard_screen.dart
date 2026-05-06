import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/queue_provider.dart';
import '../providers/auth_provider.dart';
import '../database/sync_service.dart';
import '../widgets/connectivity_banner.dart';
import '../utils/constants.dart';
import '../widgets/appointment_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          SyncStatusIcon(syncService: context.read<SyncService>()),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<AdminProvider>().loadDashboard();
              context.read<QueueProvider>().loadTodayQueue();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.cancelled),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, _) {
          if (admin.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final stats = admin.statusCounts;
          final total = admin.totalCount;
          // Filter to show pending/in-progress appointments first, from all dates
          final pendingQueue = admin.allAppointments.where((a) => 
            a.status == AppointmentStatus.scheduled || a.status == AppointmentStatus.inProgress
          ).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Total
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary.withAlpha(50), AppColors.primaryDark.withAlpha(30)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withAlpha(40)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.primary.withAlpha(40), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.dashboard_rounded, color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Appointments', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text('$total', style: const TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _statCard('Scheduled', stats[AppointmentStatus.scheduled] ?? 0, AppColors.scheduled, Icons.schedule_rounded)),
                          const SizedBox(width: 10),
                          Expanded(child: _statCard('In Progress', stats[AppointmentStatus.inProgress] ?? 0, AppColors.inProgress, Icons.play_circle_rounded)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _statCard('Completed', stats[AppointmentStatus.completed] ?? 0, AppColors.completed, Icons.check_circle_rounded)),
                          const SizedBox(width: 10),
                          Expanded(child: _statCard('Cancelled', stats[AppointmentStatus.cancelled] ?? 0, AppColors.cancelled, Icons.cancel_rounded)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Move queue button
                if (pendingQueue.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await admin.moveQueueForward();
                          if (context.mounted) {
                            context.read<QueueProvider>().loadTodayQueue();
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Queue moved forward'),
                                backgroundColor: AppColors.surfaceBg,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.skip_next_rounded),
                        label: const Text('Move Queue Forward'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Pending queue
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text("Pending Appointments", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text('${pendingQueue.length} appointments', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                if (pendingQueue.isEmpty)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox_rounded, color: AppColors.textMuted, size: 40),
                          SizedBox(height: 12),
                          Text('No pending appointments', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                        ],
                      ),
                    ),
                  )
                else
                  ...List.generate(
                    pendingQueue.length,
                    (i) => AppointmentCard(
                      appointment: pendingQueue[i],
                      showActions: true,
                      onComplete: () => _confirmAction(
                        pendingQueue[i].status == AppointmentStatus.scheduled 
                            ? 'Accept this appointment?' 
                            : 'Complete this appointment?',
                        () async {
                          if (pendingQueue[i].status == AppointmentStatus.scheduled) {
                            await admin.markInProgress(pendingQueue[i].id);
                          } else {
                            await admin.markCompleted(pendingQueue[i].id);
                          }
                          if (context.mounted) {
                            context.read<QueueProvider>().loadTodayQueue();
                            context.read<SyncService>().refreshPendingCount();
                          }
                        },
                      ),
                      onCancel: () => _confirmAction(
                        pendingQueue[i].status == AppointmentStatus.scheduled 
                            ? 'Reject this appointment?' 
                            : 'Cancel this appointment?',
                        () async {
                          await admin.cancelAppointment(pendingQueue[i].id);
                          if (context.mounted) {
                            context.read<QueueProvider>().loadTodayQueue();
                            context.read<SyncService>().refreshPendingCount();
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmAction(String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(message, style: const TextStyle(color: AppColors.textPrimary, fontSize: 17)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              Text('$count', style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
