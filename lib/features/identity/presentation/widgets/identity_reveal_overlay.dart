import 'package:flutter/material.dart';

import 'package:rumour_app/core/extensions/context_extensions.dart';
import 'package:rumour_app/core/theme/app_gradients.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';

/// Full-screen sheet shown on a fresh identity. Tap CTA to dismiss.
class IdentityRevealOverlay extends StatelessWidget {
  const IdentityRevealOverlay({
    super.key,
    required this.identity,
    required this.onAcknowledge,
  });

  final IdentityEntity identity;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;

    return ColoredBox(
      color: palette.bgBase,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // push the card + CTA to the bottom as a pair
              const Spacer(),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                decoration: BoxDecoration(
                  color: palette.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'For this room, you are',
                      textAlign: TextAlign.center,
                      style: typography.identityCaption,
                    ),
                    const SizedBox(height: 12),
                    _GradientName(name: identity.displayName),
                    const SizedBox(height: 12),
                    Text(
                      'This is your anonymous identifier, visible only to others in this room.',
                      textAlign: TextAlign.center,
                      style: typography.identityHelper,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: onAcknowledge,
                child: const Text('Acknowledge and continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientName extends StatelessWidget {
  const _GradientName({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = context.typography.identityName;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) =>
          AppGradients.identityName(palette).createShader(rect),
      child: Text(name, textAlign: TextAlign.center, style: style),
    );
  }
}
