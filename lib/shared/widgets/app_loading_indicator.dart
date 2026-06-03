import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rumour_app/core/extensions/context_extensions.dart';

/// A centred, animated three-dot loading indicator.
///
/// Each dot fades and scales in a staggered wave using the app's
/// [AppPalette.accentPrimary] colour. Drop it anywhere a loading
/// state needs a polished visual:
///
/// ```dart
/// const Center(child: AppLoadingIndicator())
/// ```
class AppLoadingIndicator extends StatefulWidget {
  const AppLoadingIndicator({super.key, this.dotSize = 10.0});

  /// Diameter of each dot.
  final double dotSize;

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const int _dotCount = 3;
  static const Duration _period = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.palette.accentPrimary;
    final size = widget.dotSize;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_dotCount, (i) {
        // Each dot is offset by 1/3 of the total period.
        final delay = i / _dotCount;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: size * 0.35),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              // Sine-wave mapped to [0..1], shifted per dot.
              final phase = ((_controller.value - delay) % 1.0);
              final sine = math.sin(phase * 2 * math.pi);
              final t = (sine + 1) / 2; // [0..1]

              return Opacity(
                opacity: 0.35 + 0.65 * t,
                child: Transform.scale(
                  scale: 0.65 + 0.35 * t,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
