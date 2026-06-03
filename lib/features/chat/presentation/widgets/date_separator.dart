import 'package:flutter/material.dart';
import 'package:rumour_app/core/extensions/context_extensions.dart';
import 'package:rumour_app/core/extensions/date_extensions.dart';

class DateSeparator extends StatelessWidget {
  const DateSeparator({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: palette.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            date.dateSeparatorLabel(),
            style: typography.dateSeparator,
          ),
        ),
      ),
    );
  }
}
