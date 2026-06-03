import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/features/chat/presentation/bloc/composer_bloc.dart';
import 'package:rumour_app/features/chat/presentation/bloc/composer_event.dart';
import 'package:rumour_app/features/chat/presentation/bloc/composer_state.dart';

void main() {
  group('ComposerBloc Tests', () {
    late ComposerBloc bloc;

    setUp(() {
      bloc = ComposerBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has empty text and cannot send', () {
      expect(bloc.state, const ComposerState(text: '', canSend: false));
    });

    test('ComposerTextChanged updates state and validates canSend', () async {
      bloc.add(const ComposerTextChanged('hello'));
      await expectLater(
        bloc.stream,
        emits(const ComposerState(text: 'hello', canSend: true)),
      );
    });

    test('ComposerReset clears text and disables canSend', () async {
      bloc.add(const ComposerTextChanged('hello'));
      bloc.add(const ComposerReset());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          const ComposerState(text: 'hello', canSend: true),
          const ComposerState(text: '', canSend: false),
        ]),
      );
    });
  });
}
