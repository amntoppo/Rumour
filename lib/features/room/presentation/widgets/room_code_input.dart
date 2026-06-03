import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_bloc.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_event.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_state.dart';

/// 6-cell OTP-style room code input backed by [RoomCodeFormBloc].
class RoomCodeInput extends StatefulWidget {
  const RoomCodeInput({super.key, this.enabled = true});

  final bool enabled;

  @override
  State<RoomCodeInput> createState() => _RoomCodeInputState();
}

class _RoomCodeInputState extends State<RoomCodeInput> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;

  /// Tracks the controller's length so we can compare it synchronously
  /// without reading from the bloc (which is async and not yet updated).
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
      // A digit was appended — FilteringTextInputFormatter guarantees it's a digit
      final newChar = value[value.length - 1];
      bloc.add(RoomCodeDigitAdded(newChar));
    } else if (value.length < _prevLength) {
      // Backspace was pressed
      bloc.add(const RoomCodeBackspaced());
    }

    // Always stay in sync with what the controller actually holds now.
    // We do NOT set _controller.text here — that would cause onChanged to fire
    // again and create a feedback loop.
    _prevLength = value.length;
  }

  /// Called by [BlocListener] when the bloc is cleared externally
  /// (e.g. after a successful join or failure).
  void _resetController() {
    _controller.clear();
    _prevLength = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: BlocListener<RoomCodeFormBloc, RoomCodeFormState>(
        // Reset the hidden controller when the bloc is cleared externally
        listenWhen: (prev, curr) =>
            prev.digits.isNotEmpty && curr.digits.isEmpty,
        listener: (_, _) => _resetController(),
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
                // Visible digit cells
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_cellCount, (i) {
                    final hasDigit = i < state.digits.length;
                    final isCurrent =
                        widget.enabled && i == state.digits.length;
                    return _DigitCell(
                      digit: hasDigit ? state.digits[i] : null,
                      isActive: isCurrent,
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DigitCell extends StatelessWidget {
  const _DigitCell({this.digit, this.isActive = false});

  final String? digit;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = const Color(0xFFA3E635);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 46,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? accentColor
              : digit != null
                  ? accentColor.withValues(alpha: 0.5)
                  : const Color(0xFF334155),
          width: isActive ? 2 : 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: digit != null
          ? Text(
              digit!,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            )
          : isActive
              ? _Cursor(color: accentColor)
              : null,
    );
  }
}

class _Cursor extends StatefulWidget {
  const _Cursor({required this.color});
  final Color color;

  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 2,
        height: 24,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
