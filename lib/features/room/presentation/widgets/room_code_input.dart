import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour_app/core/extensions/context_extensions.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_bloc.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_event.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_state.dart';

/// 6-cell room code input backed by [RoomCodeFormBloc].
class RoomCodeInput extends StatefulWidget {
  const RoomCodeInput({super.key, this.enabled = true});

  final bool enabled;

  @override
  State<RoomCodeInput> createState() => _RoomCodeInputState();
}

class _RoomCodeInputState extends State<RoomCodeInput> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  int _prevLength = 0;

  static const _cellCount = RoomCodeFormState.codeLength;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value, BuildContext ctx) {
    final bloc = ctx.read<RoomCodeFormBloc>();

    if (value.length > _prevLength) {
      final newChar = value[value.length - 1];
      bloc.add(RoomCodeDigitAdded(newChar));
    } else if (value.length < _prevLength) {
      bloc.add(const RoomCodeBackspaced());
    }

    _prevLength = value.length;
  }

  void _resetController() {
    _controller.clear();
    _prevLength = 0;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: () {
        if (widget.enabled) {
          _focusNode.requestFocus();
        }
      },
      child: BlocListener<RoomCodeFormBloc, RoomCodeFormState>(
        listenWhen: (prev, curr) =>
            prev.digits.isNotEmpty && curr.digits.isEmpty,
        listener: (_, __) => _resetController(),
        child: BlocBuilder<RoomCodeFormBloc, RoomCodeFormState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Hidden text field that receives actual keyboard input
                Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    keyboardType: TextInputType.number,
                    maxLength: _cellCount,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) => _onChanged(v, context),
                    decoration: const InputDecoration(counterText: ''),
                  ),
                ),
                // Visible design matching the screenshot
                Container(
                  width: double.infinity,
                  height: 80,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: palette.inputBg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_cellCount, (i) {
                      final hasDigit = i < state.digits.length;
                      return Container(
                        width: 20,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: hasDigit
                            ? Text(
                                state.digits[i],
                                style: context.typography.inputText.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: palette.textPrimary,
                                ),
                              )
                            : Container(
                                width: 20,
                                height: 3.5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF71717A), // zinc-400
                                  borderRadius: BorderRadius.circular(1.75),
                                ),
                              ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
