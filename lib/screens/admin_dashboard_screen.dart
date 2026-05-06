import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../utils/constants.dart';
import '../widgets/appointment_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Mock data — will be replaced by provider in Phase 3
  final List<Appointment> _todayQueue = [];
  final Map<String, int> _stats = {
    'Scheduled': 0,
    'In Progress': 0,
    'Completed': 0,
    'Cancelled': 0,
  };

  @override
  Widget build(BuildContext context) {
    final total = _stats.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Total card
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
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                  // Status grid
                  Row(
                    children: [
                      Expanded(child: _statCard('Scheduled', _stats['Scheduled'] ?? 0, AppColors.scheduled, Icons.schedule_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: _statCard('In Progress', _stats['In Progress'] ?? 0, AppColors.inProgress, Icons.play_circle_rounded)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _statCard('Completed', _stats['Completed'] ?? 0, AppColors.completed, Icons.check_circle_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: _statCard('Cancelled', _stats['Cancelled'] ?? 0, AppColors.cancelled, Icons.cancel_rounded)),
                    ],
                  ),
                ],
              ),
            ),

            // Today's Queue header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text("Today's Queue", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${_todayQueue.length} appointments', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Queue list or empty
            if (_todayQueue.isEmpty)
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
                      Text('No appointments today', style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(
                _todayQueue.length,
                (i) => AppointmentCard(
                  appointment: _todayQueue[i],
                  showActions: true,
                  onComplete: () {},
                  onCancel: () {},
                ),
              ),
          ],
        ),
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
