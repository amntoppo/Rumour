import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rumour_app/core/constants/app_assets.dart';
import 'package:rumour_app/core/extensions/context_extensions.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:rumour_app/features/chat/presentation/bloc/composer_bloc.dart';
import 'package:rumour_app/features/chat/presentation/bloc/composer_event.dart';
import 'package:rumour_app/features/chat/presentation/bloc/composer_state.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({super.key});

  void _onSendTap(BuildContext context) {
    final composer = context.read<ComposerBloc>();
    final chat = context.read<ChatBloc>();
    if (!composer.state.canSend) return;

    final text = composer.state.text;
    composer.add(const ComposerReset());

    chat.add(ChatMessageSent(text));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(child: _InputField()),
            const SizedBox(width: 12),
            _SendButton(onTap: () => _onSendTap(context)),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField();

  @override
  Widget build(BuildContext context) {
    final composer = context.read<ComposerBloc>();
    final palette = context.palette;
    final typography = context.typography;
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: palette.inputBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: composer.textController,
        focusNode: composer.focusNode,
        maxLines: 5,
        minLines: 1,
        textInputAction: TextInputAction.newline,
        style: typography.inputText,
        cursorColor: palette.accentPrimary,
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintText: 'Type a message anonymously...',
          hintStyle: typography.inputHint,
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<ComposerBloc, ComposerState>(
      builder: (context, state) {
        final enabled = state.canSend;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: enabled ? 1.0 : 0.5,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.accentPrimary,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  AppAssets.sendIcon,
                  colorFilter: ColorFilter.mode(
                    palette.onAccent,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
