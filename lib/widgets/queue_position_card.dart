import 'package:flutter/material.dart';
import '../utils/constants.dart';

class QueuePositionCard extends StatelessWidget {
  final int currentServing;
  final int userPosition;
  final int estimatedWaitMinutes;

  const QueuePositionCard({
    super.key,
    required this.currentServing,
    required this.userPosition,
    required this.estimatedWaitMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final isBeingServed = userPosition == currentServing;
    final positionsAhead = userPosition - currentServing;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBeingServed
              ? [AppColors.completed.withAlpha(40), AppColors.accent.withAlpha(20)]
              : [AppColors.primary.withAlpha(40), AppColors.primaryDark.withAlpha(20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBeingServed ? AppColors.completed.withAlpha(80) : AppColors.primary.withAlpha(60),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Your Position
          Text(
            isBeingServed ? '🎉 It\'s Your Turn!' : 'Your Queue Position',
            style: TextStyle(
              color: isBeingServed ? AppColors.completed : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '#$userPosition',
            style: TextStyle(
              color: isBeingServed ? AppColors.completed : AppColors.primary,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem(
                icon: Icons.play_circle_rounded,
                label: 'Now Serving',
                value: '#$currentServing',
                color: AppColors.inProgress,
              ),
              Container(width: 1, height: 40, color: AppColors.divider),
              _statItem(
                icon: Icons.people_rounded,
                label: 'Ahead of You',
                value: positionsAhead > 0 ? '$positionsAhead' : '0',
                color: AppColors.scheduled,
              ),
              Container(width: 1, height: 40, color: AppColors.divider),
              _statItem(
                icon: Icons.timer_rounded,
                label: 'Est. Wait',
                value: '${estimatedWaitMinutes}m',
                color: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}
