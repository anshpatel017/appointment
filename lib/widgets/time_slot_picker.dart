import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TimeSlotPicker extends StatelessWidget {
  final String? selectedSlot;
  final Set<String> unavailableSlots;
  final ValueChanged<String> onSlotSelected;

  const TimeSlotPicker({
    super.key,
    required this.selectedSlot,
    required this.unavailableSlots,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Select Time Slot',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TimeSlots.all.map((slot) {
            final isSelected = slot == selectedSlot;
            final isUnavailable = unavailableSlots.contains(slot);
            return GestureDetector(
              onTap: isUnavailable ? null : () => onSlotSelected(slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isUnavailable
                      ? AppColors.surfaceBg.withAlpha(100)
                      : isSelected
                          ? AppColors.primary
                          : AppColors.surfaceBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isUnavailable
                        ? AppColors.divider.withAlpha(50)
                        : isSelected
                            ? AppColors.primaryLight
                            : AppColors.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    color: isUnavailable
                        ? AppColors.textMuted.withAlpha(100)
                        : isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    decoration: isUnavailable ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (unavailableSlots.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(
                  color: AppColors.surfaceBg.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                )),
                const SizedBox(width: 6),
                const Text('Fully booked', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
      ],
    );
  }
}
