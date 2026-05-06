
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/queue_provider.dart';
import '../utils/constants.dart';
import '../widgets/queue_position_card.dart';

class QueueStatusScreen extends StatefulWidget {
  const QueueStatusScreen({super.key});

  @override
  State<QueueStatusScreen> createState() => _QueueStatusScreenState();
}

class _QueueStatusScreenState extends State<QueueStatusScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

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
      body: Consumer<QueueProvider>(
        builder: (context, queueProvider, _) {
          final queue = queueProvider.todayQueue;
          final currentServing = queueProvider.currentServing;

          if (queue.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.queue_rounded, color: AppColors.primary, size: 56),
                  ),
                  const SizedBox(height: 20),
                  const Text('No Queue Today', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Book an appointment to\njoin the queue', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                ],
              ),
            );
          }

          // Use last appointment's position as user position (simplified)
          final userPos = queue.isNotEmpty ? queue.last.queuePosition : 1;
          final waitTime = queueProvider.getEstimatedWait(userPos);

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.cardBg,
            onRefresh: () => queueProvider.loadTodayQueue(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  QueuePositionCard(
                    currentServing: currentServing,
                    userPosition: userPos,
                    estimatedWaitMinutes: waitTime,
                  ),
                  const SizedBox(height: 24),

                  // Queue header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text("Today's Queue", style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text('${queue.length} appointments', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Queue list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final item = queue[index];
                      final isServing = item.status == AppointmentStatus.inProgress;
                      final isCompleted = item.status == AppointmentStatus.completed;

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
                                  color: isCompleted ? AppColors.completed : isServing ? AppColors.inProgress : AppColors.divider,
                                ),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(Icons.check, color: AppColors.completed, size: 18)
                                    : Text(
                                        '${item.queuePosition}',
                                        style: TextStyle(
                                          color: isServing ? AppColors.inProgress : AppColors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      color: isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: isServing ? FontWeight.w600 : FontWeight.w400,
                                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  Text(item.serviceType, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                ],
                              ),
                            ),
                            if (isServing)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.inProgress.withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('NOW', style: TextStyle(color: AppColors.inProgress, fontSize: 11, fontWeight: FontWeight.w700)),
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
        },
      ),
    );
  }
}
