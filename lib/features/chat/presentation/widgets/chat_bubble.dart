import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.isSender,
    required this.bubbleColor,
    required this.messageChild,
    this.showTail = false,
  });

  final bool isSender;
  final Color bubbleColor;
  final Widget messageChild;
  final bool showTail;

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.72;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              child: CustomPaint(
                painter: _ChatBubblePainter(
                  color: bubbleColor,
                  isSender: isSender,
                  tail: showTail,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: messageChild,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubblePainter extends CustomPainter {
  _ChatBubblePainter({
    required this.color,
    required this.isSender,
    required this.tail,
  });

  final Color color;
  final bool isSender;
  final bool tail;

  static const double _radius = 15.0;
  static const double _tailHeight = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final h = size.height;
    final w = size.width;
    final bubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(_radius),
    );

    canvas.drawRRect(bubble, paint);
    if (!tail) return;

    final path = Path();
    if (isSender) {
      path
        ..moveTo(w - _radius - 1, 0)
        ..quadraticBezierTo(w - 4, 1, w, _tailHeight)
        ..lineTo(w, 0)
        ..close();
    } else {
      path
        ..moveTo(_radius + 1, 0)
        ..quadraticBezierTo(4, 1, 0, _tailHeight)
        ..lineTo(0, 0)
        ..close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChatBubblePainter old) =>
      old.color != color || old.isSender != isSender || old.tail != tail;
}
