import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/exceptions/app_exception.dart';
import 'package:rumour_app/features/room/domain/entities/room_entity.dart';
import 'package:rumour_app/features/room/domain/usercases/join_room_usecase.dart';
import 'package:rumour_app/features/room/presentation/bloc/join_room_bloc.dart';
import 'package:rumour_app/features/room/presentation/bloc/join_room_event.dart';
import 'package:rumour_app/features/room/presentation/bloc/join_room_state.dart';

// ── Fake use case ─────────────────────────────────────────────────────────────

class _FakeJoinRoomUseCase implements JoinRoomUseCase {
  DataState<RoomEntity> result;

  _FakeJoinRoomUseCase(this.result);

  @override
  Future<DataState<RoomEntity>> call(String code) async => result;
}

class _FakeAppException extends AppException {
  const _FakeAppException(super.message);
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('JoinRoomBloc', () {
    late JoinRoomBloc bloc;

    tearDown(() => bloc.close());

    test('initial state is JoinRoomInitial', () {
      bloc = JoinRoomBloc(_FakeJoinRoomUseCase(
        const DataSuccess(RoomEntity(id: 'r', code: 'ABC123')),
      ));
      expect(bloc.state, isA<JoinRoomInitial>());
    });

    test('JoinRoomSubmitted success emits JoinRoomChecking then JoinRoomSuccess', () async {
      const room = RoomEntity(id: 'room_id', code: 'XYZ789');
      bloc = JoinRoomBloc(_FakeJoinRoomUseCase(const DataSuccess(room)));

      final states = <JoinRoomState>[];
      bloc.stream.listen(states.add);

      bloc.add(const JoinRoomSubmitted('XYZ789'));
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<JoinRoomChecking>());
      expect(states[1], isA<JoinRoomSuccess>());

      final success = states[1] as JoinRoomSuccess;
      expect(success.room.code, 'XYZ789');
    });

    test('JoinRoomSubmitted failure emits JoinRoomChecking then JoinRoomFailure', () async {
      bloc = JoinRoomBloc(_FakeJoinRoomUseCase(
        const DataFailure(_FakeAppException('Room not found')),
      ));

      final states = <JoinRoomState>[];
      bloc.stream.listen(states.add);

      bloc.add(const JoinRoomSubmitted('BADCODE'));
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<JoinRoomChecking>());
      expect(states[1], isA<JoinRoomFailure>());

      final failure = states[1] as JoinRoomFailure;
      expect(failure.message, 'Room not found');
    });

    test('JoinRoomReset returns to JoinRoomInitial from any state', () async {
      const room = RoomEntity(id: 'r', code: 'CODE');
      bloc = JoinRoomBloc(_FakeJoinRoomUseCase(const DataSuccess(room)));

      bloc.add(const JoinRoomSubmitted('CODE'));
      await Future.delayed(Duration.zero);

      final states = <JoinRoomState>[];
      bloc.stream.listen(states.add);

      bloc.add(const JoinRoomReset());
      await Future.delayed(Duration.zero);

      expect(states.last, isA<JoinRoomInitial>());
    });
  });
}
