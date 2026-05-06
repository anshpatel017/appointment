import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../utils/constants.dart';
import 'status_badge.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final bool showActions;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.showActions = false,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appointment.status == AppointmentStatus.inProgress
                ? AppColors.inProgress.withAlpha(100)
                : AppColors.divider,
            width: appointment.status == AppointmentStatus.inProgress ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${appointment.shortId}',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    if (!appointment.isSynced) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.cloud_off_rounded, color: AppColors.inProgress, size: 14),
                    ],
                  ],
                ),
                StatusBadge(status: appointment.status),
              ],
            ),
            const SizedBox(height: 12),
            // Name
            Text(
              appointment.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // Service + Queue
            Row(
              children: [
                _infoChip(Icons.medical_services_rounded, appointment.serviceType),
                const SizedBox(width: 12),
                _infoChip(Icons.tag_rounded, 'Queue #${appointment.queuePosition}'),
              ],
            ),
            const SizedBox(height: 8),
            // Date + Time
            Row(
              children: [
                _infoChip(Icons.calendar_today_rounded, appointment.date),
                const SizedBox(width: 12),
                Expanded(child: _infoChip(Icons.access_time_rounded, appointment.timeSlot)),
              ],
            ),
            // Action buttons for admin
            if (showActions && appointment.status != AppointmentStatus.completed && appointment.status != AppointmentStatus.cancelled) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (appointment.status == AppointmentStatus.scheduled || appointment.status == AppointmentStatus.inProgress)
                    Expanded(
                      child: _actionButton(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Complete',
                        color: AppColors.completed,
                        onTap: onComplete,
                      ),
                    ),
                  if (appointment.status == AppointmentStatus.scheduled || appointment.status == AppointmentStatus.inProgress) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionButton(
                        icon: Icons.cancel_outlined,
                        label: 'Cancel',
                        color: AppColors.cancelled,
                        onTap: onCancel,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textMuted, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
