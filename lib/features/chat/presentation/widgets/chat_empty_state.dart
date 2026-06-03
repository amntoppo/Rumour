import 'package:flutter/material.dart';
import 'package:rumour_app/core/extensions/context_extensions.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.surfaceElevated.withValues(alpha: 0.5),
              ),
              child: Icon(
                Icons.forum_outlined,
                color: palette.accentPrimary,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No messages yet',
              textAlign: TextAlign.center,
              style: typography.bodyLg.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first one to say something anonymous!',
              textAlign: TextAlign.center,
              style: typography.body.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
