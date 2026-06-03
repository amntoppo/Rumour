import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_bloc.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_event.dart';
import 'package:rumour_app/features/room/presentation/bloc/room_code_form_state.dart';

void main() {
  group('RoomCodeFormBloc', () {
    late RoomCodeFormBloc bloc;

    setUp(() => bloc = RoomCodeFormBloc());
    tearDown(() => bloc.close());

    test('initial state has empty digits and isComplete = false', () {
      expect(bloc.state.digits, isEmpty);
      expect(bloc.state.code, '');
      expect(bloc.state.isComplete, isFalse);
    });

    test('RoomCodeDigitAdded appends a digit', () async {
      bloc.add(const RoomCodeDigitAdded('3'));
      await Future.delayed(Duration.zero);

      expect(bloc.state.digits, ['3']);
      expect(bloc.state.code, '3');
    });

    test('RoomCodeDigitAdded sets isComplete after 6 digits', () async {
      for (final d in ['1', '2', '3', '4', '5', '6']) {
        bloc.add(RoomCodeDigitAdded(d));
      }
      await Future.delayed(Duration.zero);

      expect(bloc.state.isComplete, isTrue);
      expect(bloc.state.code, '123456');
    });

    test('RoomCodeDigitAdded does nothing when code is already complete', () async {
      for (final d in ['1', '2', '3', '4', '5', '6']) {
        bloc.add(RoomCodeDigitAdded(d));
      }
      await Future.delayed(Duration.zero);

      bloc.add(const RoomCodeDigitAdded('7')); // should be ignored
      await Future.delayed(Duration.zero);

      expect(bloc.state.digits.length, 6);
      expect(bloc.state.code, '123456');
    });

    test('RoomCodeBackspaced removes the last digit', () async {
      bloc.add(const RoomCodeDigitAdded('5'));
      bloc.add(const RoomCodeDigitAdded('9'));
      bloc.add(const RoomCodeBackspaced());
      await Future.delayed(Duration.zero);

      expect(bloc.state.digits, ['5']);
    });

    test('RoomCodeBackspaced on empty state does nothing', () async {
      final states = <RoomCodeFormState>[];
      bloc.stream.listen(states.add);

      bloc.add(const RoomCodeBackspaced());
      await Future.delayed(Duration.zero);

      expect(states, isEmpty); // no state emitted
    });

    test('RoomCodeFormCleared resets to empty state', () async {
      for (final d in ['A', 'B', 'C']) {
        bloc.add(RoomCodeDigitAdded(d));
      }
      bloc.add(const RoomCodeFormCleared());
      await Future.delayed(Duration.zero);

      expect(bloc.state.digits, isEmpty);
      expect(bloc.state.isComplete, isFalse);
    });
  });
}
