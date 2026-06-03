import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rumour_app/core/constants/app_assets.dart';
import 'package:rumour_app/core/extensions/context_extensions.dart';
import 'package:rumour_app/core/routes/route_name.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_bloc.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_event.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_state.dart';
import 'package:rumour_app/features/room/presentation/widgets/room_code_input.dart';

// ─── Root screen – injects Blocs ──────────────────────────────────────────────

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RoomCodeFormBloc>(
      create: (_) => RoomCodeFormBloc(),
      child: const _JoinRoomView(),
    );
  }
}

// ─── Inner view – reads Blocs from context ────────────────────────────────────

class _JoinRoomView extends StatelessWidget {
  const _JoinRoomView();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;
    return Scaffold(
      backgroundColor: palette.bgBase,
      body: ColoredBox(
        color: palette.bgBase,
        child: SafeArea(
          child: BlocListener<RoomCodeFormBloc, RoomCodeFormState>(
            listenWhen: (prev, curr) => !prev.isComplete && curr.isComplete,
            listener: (context, state) {
              Navigator.of(context).pushReplacementNamed(
                RouteName.chatScreen,
                arguments: state.code,
              );
              context.read<RoomCodeFormBloc>().add(
                const RoomCodeFormCleared(),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  // Key icon container (flat circle with keyIconBg color, no border, no glow)
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.keyIconBg,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: SvgPicture.asset(
                          AppAssets.keyIcon,
                          width: 46,
                          height: 20,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            palette.accentPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Title
                  Text(
                    'Join A Room',
                    textAlign: TextAlign.center,
                    style: typography.screenTitle,
                  ),
                  const SizedBox(height: 16),
                  // Subtitle
                  Text(
                    'Enter the code to join the anon chat\nroom',
                    textAlign: TextAlign.center,
                    style: typography.screenSubtitle,
                  ),
                  const SizedBox(height: 48),
                  // 6-digit code input
                  const RoomCodeInput(enabled: true),
                  const Spacer(flex: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
