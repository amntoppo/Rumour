import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rumour_app/core/constants/app_assets.dart';
import 'package:rumour_app/core/di/injection_controller.dart';
import 'package:rumour_app/core/extensions/context_extensions.dart';
import 'package:rumour_app/core/routes/route_name.dart';
import 'package:rumour_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:rumour_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:rumour_app/features/chat/presentation/bloc/composer_bloc.dart';
import 'package:rumour_app/features/chat/presentation/widgets/chat_composer.dart';
import 'package:rumour_app/features/chat/presentation/widgets/chat_messages_list.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';
import 'package:rumour_app/features/identity/presentation/bloc/identity_bloc.dart';
import 'package:rumour_app/features/identity/presentation/bloc/identity_event.dart';
import 'package:rumour_app/features/identity/presentation/bloc/identity_state.dart';
import 'package:rumour_app/features/identity/presentation/widgets/identity_error_view.dart';
import 'package:rumour_app/features/identity/presentation/widgets/identity_reveal_overlay.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<IdentityBloc>(
          create: (_) => sl<IdentityBloc>()..add(LoadIdentity(roomCode)),
        ),
        BlocProvider<ComposerBloc>(
          create: (_) => ComposerBloc(),
        ),
      ],
      child: _ChatScaffold(roomCode: roomCode),
    );
  }
}

class _ChatScaffold extends StatelessWidget {
  const _ChatScaffold({required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<IdentityBloc, IdentityState>(
      builder: (context, state) {
        return switch (state) {
          IdentityInitial() || IdentityLoading() => Scaffold(
              backgroundColor: palette.bgBase,
              appBar: _ChatAppBar(roomCode: roomCode),
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(palette.accentPrimary),
                ),
              ),
            ),
          IdentityFailure(:final message) => Scaffold(
              backgroundColor: palette.bgBase,
              appBar: _ChatAppBar(roomCode: roomCode),
              body: IdentityErrorView(
                message: message,
                onRetry: () => context.read<IdentityBloc>().add(LoadIdentity(roomCode)),
              ),
            ),
          IdentitySuccess(:final identity, :final isFresh) => _LoadedScaffold(
              roomCode: roomCode,
              identity: identity,
              isFresh: isFresh,
            ),
        };
      },
    );
  }
}

class _LoadedScaffold extends StatelessWidget {
  const _LoadedScaffold({
    required this.roomCode,
    required this.identity,
    required this.isFresh,
  });

  final String roomCode;
  final IdentityEntity identity;
  final bool isFresh;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocProvider<ChatBloc>(
      create: (_) => ChatBloc(
        repository: sl(),
        loadMessagesUseCase: sl(),
        sendMessageUseCase: sl(),
        identity: identity,
      )..add(ChatSubscribed(roomCode)),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: palette.bgBase,
            appBar: _ChatAppBar(
              roomCode: roomCode,
              showMemberCount: true,
            ),
            body: ColoredBox(
              color: palette.bgBase,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: ChatMessagesList(roomCode: roomCode),
                      ),
                      const ChatComposer(),
                    ],
                  ),
                  if (isFresh)
                    Positioned.fill(
                      child: IdentityRevealOverlay(
                        identity: identity,
                        onAcknowledge: () {
                          context.read<IdentityBloc>().add(const AcknowledgeReveal());
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.roomCode, this.showMemberCount = false});

  final String roomCode;
  final bool showMemberCount;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;
    return AppBar(
      backgroundColor: palette.bgBase,
      elevation: 0,
      centerTitle: true,
      leading: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: palette.surfaceElevated.withValues(alpha: 0.5),
            border: Border.all(
              color: palette.divider,
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed(RouteName.roomScreen);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  AppAssets.backIcon,
                  colorFilter: ColorFilter.mode(
                    palette.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Room #$roomCode',
            style: typography.appBarTitle,
          ),
          const SizedBox(height: 2),
          if (showMemberCount)
            StreamBuilder<int>(
              stream: sl<ChatRepository>().watchRoomMemberCount(roomCode),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Text(
                  count == 1 ? '1 member' : '$count members',
                  style: typography.appBarSubtitle,
                );
              },
            )
          else
            Text(
              'Connecting...',
              style: typography.appBarSubtitle,
            ),
        ],
      ),
    );
  }
}
