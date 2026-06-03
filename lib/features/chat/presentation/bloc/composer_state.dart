import 'package:equatable/equatable.dart';

class ComposerState extends Equatable {
  const ComposerState({
    required this.text,
    required this.canSend,
  });

  const ComposerState.initial()
      : text = '',
        canSend = false;

  final String text;
  final bool canSend;

  @override
  List<Object?> get props => [text, canSend];
}
