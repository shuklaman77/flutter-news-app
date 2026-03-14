import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.15),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.warningColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 14,
            color: AppTheme.warningColor,
          ),
          const SizedBox(width: 6),
          Text(
            'Offline mode — showing cached news',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.warningColor,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.5, end: 0, duration: 300.ms);
  }
}
