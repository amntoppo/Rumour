import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour_app/core/extensions/context_extensions.dart';
import 'package:rumour_app/core/extensions/date_extensions.dart';
import 'package:rumour_app/features/chat/domain/entities/message_entity.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:rumour_app/features/chat/presentation/widgets/chat_empty_state.dart';
import 'package:rumour_app/features/chat/presentation/widgets/date_separator.dart';
import 'package:rumour_app/features/chat/presentation/widgets/message_row.dart';
import 'package:rumour_app/shared/widgets/app_loading_indicator.dart';

class ChatMessagesList extends StatelessWidget {
  const ChatMessagesList({super.key, required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatInitial ||
            (state is ChatLoading && state.messages.isEmpty)) {
          return const Center(
            child: AppLoadingIndicator(),
          );
        }

        final messages = state.messages;
        if (messages.isEmpty) {
          return const ChatEmptyState();
        }

        final showPaginationFooter = state.hasMore && state is! ChatFailure;
        final itemCount = messages.length + (showPaginationFooter ? 1 : 0);

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index < messages.length) {
              final message = messages[index];
              final older = (index + 1 < messages.length)
                  ? messages[index + 1]
                  : null;
              final chatBloc = context.read<ChatBloc>();
              final isMine = chatBloc.isMyMessage(message);
              final separator = _shouldShowDateSeparator(
                current: message,
                older: older,
              );
              final startsGroup =
                  separator ||
                  !_continuesSenderRun(current: message, older: older);

              final row = MessageRow(
                message: message,
                isMine: isMine,
                showSenderLabel: startsGroup,
                startsGroup: startsGroup,
              );

              if (!separator) return row;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DateSeparator(date: message.createdAt ?? DateTime.now()),
                  row,
                ],
              );
            }

            // Pagination footer reached
            if (state is! ChatLoading) {
              Future.microtask(() {
                if (context.mounted) {
                  context.read<ChatBloc>().add(ChatLoadMoreRequested(roomCode));
                }
              });
            }

            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: AppLoadingIndicator(dotSize: 7),
              ),
            );
          },
        );
      },
    );
  }

  bool _shouldShowDateSeparator({
    required MessageEntity current,
    required MessageEntity? older,
  }) {
    if (older == null) return true;
    final currentDate = current.createdAt;
    if (currentDate == null) return false;
    final olderDate = older.createdAt;
    if (olderDate == null) return true;
    return !currentDate.isSameDayAs(olderDate);
  }

  bool _continuesSenderRun({
    required MessageEntity current,
    required MessageEntity? older,
  }) {
    if (older == null) return false;
    if (current.senderId != older.senderId) return false;

    final currentDate = current.createdAt;
    final olderDate = older.createdAt;
    if (currentDate == null || olderDate == null) return true;
    return currentDate.isSameDayAs(olderDate);
  }
}
