import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour_app/features/chat/presentation/bloc/composer_event.dart';
import 'package:rumour_app/features/chat/presentation/bloc/composer_state.dart';

class ComposerBloc extends Bloc<ComposerEvent, ComposerState> {
  ComposerBloc() : super(const ComposerState.initial()) {
    on<ComposerTextChanged>(_onTextChanged);
    on<ComposerReset>(_onReset);

    // Sync input controller value with text state
    textController.addListener(_onControllerChanged);
  }

  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  void _onControllerChanged() {
    add(ComposerTextChanged(textController.text));
  }

  void _onTextChanged(
    ComposerTextChanged event,
    Emitter<ComposerState> emit,
  ) {
    emit(ComposerState(
      text: event.text,
      canSend: event.text.trim().isNotEmpty,
    ));
  }

  void _onReset(
    ComposerReset event,
    Emitter<ComposerState> emit,
  ) {
    textController.removeListener(_onControllerChanged);
    textController.clear();
    emit(const ComposerState.initial());
    textController.addListener(_onControllerChanged);
  }

  @override
  Future<void> close() {
    textController.removeListener(_onControllerChanged);
    textController.dispose();
    focusNode.dispose();
    return super.close();
  }
}
