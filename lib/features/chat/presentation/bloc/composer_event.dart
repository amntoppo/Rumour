import 'package:equatable/equatable.dart';

sealed class ComposerEvent extends Equatable {
  const ComposerEvent();

  @override
  List<Object?> get props => [];
}

class ComposerTextChanged extends ComposerEvent {
  const ComposerTextChanged(this.text);
  final String text;

  @override
  List<Object?> get props => [text];
}

class ComposerReset extends ComposerEvent {
  const ComposerReset();
}
