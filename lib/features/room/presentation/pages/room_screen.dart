import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rumour_app/core/constants/app_assets.dart';
import 'package:rumour_app/core/di/injection_controller.dart';
import 'package:rumour_app/core/routes/route_name.dart';
import 'package:rumour_app/features/room/presentation/bloc/join_room_bloc.dart';
import 'package:rumour_app/features/room/presentation/bloc/join_room_event.dart';
import 'package:rumour_app/features/room/presentation/bloc/join_room_state.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_bloc.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_event.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_state.dart';
import 'package:rumour_app/features/room/presentation/widgets/room_code_input.dart';

// ─── Root screen – injects Blocs ──────────────────────────────────────────────

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<JoinRoomBloc>(create: (_) => sl<JoinRoomBloc>()),
        BlocProvider<RoomCodeFormBloc>(create: (_) => RoomCodeFormBloc()),
      ],
      child: const _JoinRoomView(),
    );
  }
}

// ─── Inner view – reads Blocs from context ────────────────────────────────────

class _JoinRoomView extends StatelessWidget {
  const _JoinRoomView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF020617)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: MultiBlocListener(
            listeners: [
              // When form is complete → trigger join
              BlocListener<RoomCodeFormBloc, RoomCodeFormState>(
                listenWhen: (prev, curr) =>
                    !prev.isComplete && curr.isComplete,
                listener: (context, state) {
                  context
                      .read<JoinRoomBloc>()
                      .add(JoinRoomSubmitted(state.code));
                },
              ),
              // When join result arrives → navigate or show error
              BlocListener<JoinRoomBloc, JoinRoomState>(
                listenWhen: (_, curr) =>
                    curr is JoinRoomSuccess || curr is JoinRoomFailure,
                listener: (context, state) {
                  if (state is JoinRoomSuccess) {
                    Navigator.of(context).pushReplacementNamed(
                      RouteName.chatScreen,
                      arguments: state.room.code,
                    );
                  } else if (state is JoinRoomFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  // Reset both blocs after handling
                  context
                      .read<RoomCodeFormBloc>()
                      .add(const RoomCodeFormCleared());
                  context.read<JoinRoomBloc>().add(const JoinRoomReset());
                },
              ),
            ],
            child: BlocBuilder<JoinRoomBloc, JoinRoomState>(
              builder: (context, state) {
                final isChecking = state is JoinRoomChecking;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),
                      // Key icon
                      Center(
                        child: _GlowContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: SvgPicture.asset(
                              AppAssets.keyIcon,
                              width: 56,
                              height: 28,
                              fit: BoxFit.contain,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFFA3E635),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                      // Title
                      const Text(
                        'Join a Room',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Enter the 6-digit room code\nshared with you',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                            letterSpacing: 0.5,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 6-digit code input
                      RoomCodeInput(enabled: !isChecking),
                      const SizedBox(height: 20),
                      // Loading indicator (animates in/out)
                      _CheckingSpinner(visible: isChecking),
                      const Spacer(flex: 5),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Glowing icon container ───────────────────────────────────────────────────

class _GlowContainer extends StatelessWidget {
  const _GlowContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        border: Border.all(
          color: const Color(0xFFA3E635).withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA3E635).withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Animated checking spinner ────────────────────────────────────────────────

class _CheckingSpinner extends StatelessWidget {
  const _CheckingSpinner({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 180),
      child: const SizedBox(
        height: 24,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Color(0xFFA3E635)),
            ),
          ),
        ),
      ),
    );
  }
}
