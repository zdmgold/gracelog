import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/utils/constants.dart';

/// Toggle switch with moon icon for bedtime reflection mode.
///
/// When enabled, triggers OLED-black theme (pure #000000 background),
/// reduces brightness hint, and simplifies UI to 1-item entry.
/// Haptic feedback on toggle.
class BedtimeModeToggle extends StatelessWidget {
  const BedtimeModeToggle({
    super.key,
    required this.isEnabled,
    required this.onToggle,
  });

  final bool isEnabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Bedtime reflection mode',
      hint: isEnabled
          ? 'Double tap to disable bedtime mode'
          : 'Double tap to enable bedtime mode',
      toggled: isEnabled,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onToggle();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.accentPrimary.withOpacity(0.1)
                : AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled
                  ? AppColors.accentPrimary
                  : AppColors.borderSubtle,
              width: isEnabled ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? AppColors.accentPrimary.withOpacity(0.15)
                      : AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isEnabled ? Icons.nights_stay : Icons.nightlight_outlined,
                  color: isEnabled
                      ? AppColors.accentPrimary
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bedtime Reflection',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEnabled
                          ? 'OLED black mode active. Dimmed for rest.'
                          : 'Enable a simplified, dimmed entry before sleep.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (_) {
                  HapticFeedback.mediumImpact();
                  onToggle();
                },
                activeColor: AppColors.accentPrimary,
                activeTrackColor: AppColors.accentPrimary.withOpacity(0.3),
                inactiveThumbColor: AppColors.bgTertiary,
                inactiveTrackColor: AppColors.borderSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
