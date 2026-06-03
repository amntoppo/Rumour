import 'package:flutter/material.dart';
import 'package:rumour_app/core/extensions/context_extensions.dart';
import 'package:rumour_app/core/extensions/date_extensions.dart';
import 'package:rumour_app/features/chat/domain/entities/message_entity.dart';
import 'package:rumour_app/features/chat/presentation/widgets/chat_bubble.dart';

class MessageRow extends StatelessWidget {
  const MessageRow({
    super.key,
    required this.message,
    required this.isMine,
    required this.showSenderLabel,
    required this.startsGroup,
  });

  final MessageEntity message;
  final bool isMine;
  final bool showSenderLabel;
  final bool startsGroup;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bubbleColor = isMine
        ? palette.accentPrimary
        : palette.surfaceElevated;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, startsGroup ? 10 : 2, 16, 2),
      child: Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (showSenderLabel && !isMine) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                message.senderName,
                style: context.typography.username.copyWith(
                  color: palette.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            mainAxisAlignment: isMine
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMine) ...[
                if (startsGroup)
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: palette.divider,
                    backgroundImage: message.avatarUrl != null
                        ? NetworkImage(message.avatarUrl!)
                        : null,
                    child: message.avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: 14,
                            color: palette.textSecondary,
                          )
                        : null,
                  )
                else
                  const SizedBox(width: 28),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: ChatMessageBubble(
                  isSender: isMine,
                  bubbleColor: bubbleColor,
                  showTail: startsGroup,
                  messageChild: _BubbleContent(
                    text: message.text,
                    createdAt: message.createdAt,
                    isMine: isMine,
                    isPending: message.isPending,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  const _BubbleContent({
    required this.text,
    required this.createdAt,
    required this.isMine,
    required this.isPending,
  });

  final String text;
  final DateTime? createdAt;
  final bool isMine;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;
    final textColor = isMine ? palette.onAccent : palette.textPrimary;
    final metaColor = isMine
        ? palette.onAccent.withValues(alpha: 0.6)
        : palette.textSecondary;
    final timeText = (createdAt ?? DateTime.now()).hhmm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(text, style: typography.message.copyWith(color: textColor)),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeText,
              style: typography.messageMeta.copyWith(color: metaColor),
            ),
            if (isMine) ...[
              const SizedBox(width: 4),
              Icon(
                isPending ? Icons.access_time : Icons.done,
                size: 11,
                color: metaColor,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
