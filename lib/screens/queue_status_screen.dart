import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/queue_position_card.dart';

class QueueStatusScreen extends StatefulWidget {
  const QueueStatusScreen({super.key});

  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  // Mock data — will be replaced by provider in Phase 3
  final int _currentServing = 3;
  final List<Map<String, dynamic>> _queue = [
    {'position': 1, 'name': 'No appointments yet', 'status': 'Completed'},
    {'position': 2, 'name': 'Book your first', 'status': 'Completed'},
    {'position': 3, 'name': 'appointment to see', 'status': 'In Progress'},
    {'position': 4, 'name': 'your queue status', 'status': 'Scheduled'},
    {'position': 5, 'name': 'here', 'status': 'Scheduled'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Status', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.completed.withAlpha((30 + 20 * _pulseController.value).toInt()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: AppColors.completed, size: 8),
                    SizedBox(width: 4),
                    Text('LIVE', style: TextStyle(color: AppColors.completed, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Queue position card
            const QueuePositionCard(
              currentServing: 3,
              userPosition: 4,
              estimatedWaitMinutes: 20,
            ),
            const SizedBox(height: 24),

            // Queue progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('Today\'s Queue', style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${_queue.length} appointments', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Queue list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _queue.length,
              itemBuilder: (context, index) {
                final item = _queue[index];
                final isServing = item['position'] == _currentServing;
                final isCompleted = item['status'] == 'Completed';

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isServing ? AppColors.inProgress.withAlpha(15) : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isServing ? AppColors.inProgress.withAlpha(80) : AppColors.divider,
                      width: isServing ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Position circle
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.completed.withAlpha(30)
                              : isServing
                                  ? AppColors.inProgress.withAlpha(30)
                                  : AppColors.surfaceBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.completed
                                : isServing
                                    ? AppColors.inProgress
                                    : AppColors.divider,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, color: AppColors.completed, size: 18)
                              : Text(
                                  '${item['position']}',
                                  style: TextStyle(
                                    color: isServing ? AppColors.inProgress : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name
                      Expanded(
                        child: Text(
                          item['name'],
                          style: TextStyle(
                            color: isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: isServing ? FontWeight.w600 : FontWeight.w400,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      // Status
                      if (isServing)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.inProgress.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NOW',
                            style: TextStyle(color: AppColors.inProgress, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
