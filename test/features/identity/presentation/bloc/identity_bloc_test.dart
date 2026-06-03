import 'package:flutter_test/flutter_test.dart';
import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/exceptions/app_exception.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';
import 'package:rumour_app/features/identity/domain/usecases/get_identity_usecase.dart';
import 'package:rumour_app/features/identity/presentation/bloc/identity_bloc.dart';
import 'package:rumour_app/features/identity/presentation/bloc/identity_event.dart';
import 'package:rumour_app/features/identity/presentation/bloc/identity_state.dart';
import 'package:rumour_app/features/room/domain/entities/room_entity.dart';
import 'package:rumour_app/features/room/domain/usercases/join_room_usecase.dart';

// ── Minimal AppException concrete class for testing ──────────────────────────

class _FakeAppException extends AppException {
  const _FakeAppException(super.message);
}

// ── Fake GetIdentityUseCase ──────────────────────────────────────────────────

class _FakeGetIdentityUseCase implements GetIdentityUseCase {
  final DataState<IdentityEntity> result;
  IdentityEntity? cachedResult;

  _FakeGetIdentityUseCase(this.result, {this.cachedResult});

  @override
  Future<DataState<IdentityEntity>> call(String roomCode) async => result;

  @override
  Future<IdentityEntity?> getCached(String roomId) async => cachedResult;
}

// ── Fake JoinRoomUseCase ─────────────────────────────────────────────────────

class _FakeJoinRoomUseCase implements JoinRoomUseCase {
  final DataState<RoomEntity> result;

  _FakeJoinRoomUseCase(this.result);

  @override
  Future<DataState<RoomEntity>> call(String code) async => result;
}

// ── Helpers ──────────────────────────────────────────────────────────────────

const _identity = IdentityEntity(
  id: 'id-1',
  displayName: 'Test User',
  username: 'testuser',
  roomId: 'room-1',
);

const _room = RoomEntity(
  id: 'room-1',
  code: 'room-1',
);

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('IdentityBloc', () {
    late IdentityBloc bloc;

    tearDown(() => bloc.close());

    test('initial state is IdentityInitial', () {
      bloc = IdentityBloc(
        _FakeGetIdentityUseCase(const DataSuccess(_identity)),
        _FakeJoinRoomUseCase(DataSuccess(_room)),
      );
      expect(bloc.state, isA<IdentityInitial>());
    });

    test('LoadIdentity cache hit emits IdentitySuccess immediately (no loading)', () async {
      final getIdentity = _FakeGetIdentityUseCase(
        const DataSuccess(_identity),
        cachedResult: _identity,
      );
      final joinRoom = _FakeJoinRoomUseCase(DataSuccess(_room));

      bloc = IdentityBloc(getIdentity, joinRoom);

      final states = <IdentityState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadIdentity('room-1'));
      await Future.delayed(Duration.zero);

      expect(states, hasLength(1));
      expect(states[0], isA<IdentitySuccess>());

      final success = states[0] as IdentitySuccess;
      expect(success.identity, _identity);
      expect(success.isFresh, isFalse);
    });

    test('LoadIdentity cache miss success emits IdentityLoading then IdentitySuccess (isFresh: true)', () async {
      final getIdentity = _FakeGetIdentityUseCase(
        const DataSuccess(_identity),
        cachedResult: null, // Cache miss initially
      );
      final joinRoom = _FakeJoinRoomUseCase(DataSuccess(_room));

      bloc = IdentityBloc(getIdentity, joinRoom);

      final states = <IdentityState>[];
      bloc.stream.listen(states.add);

      // Simulate caching the identity after joinRoom succeeds
      bloc.add(const LoadIdentity('room-1'));
      getIdentity.cachedResult = _identity;
      await Future.delayed(Duration.zero);

      expect(states[0], isA<IdentityLoading>());
      expect(states[1], isA<IdentitySuccess>());

      final success = states[1] as IdentitySuccess;
      expect(success.identity, _identity);
      expect(success.isFresh, isTrue);
    });

    test('LoadIdentity cache miss failure emits IdentityLoading then IdentityFailure', () async {
      final getIdentity = _FakeGetIdentityUseCase(
        const DataSuccess(_identity),
        cachedResult: null,
      );
      final joinRoom = _FakeJoinRoomUseCase(
        const DataFailure(_FakeAppException('Join room failed')),
      );

      bloc = IdentityBloc(getIdentity, joinRoom);

      final states = <IdentityState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadIdentity('room-1'));
      await Future.delayed(Duration.zero);

      expect(states[0], isA<IdentityLoading>());
      expect(states[1], isA<IdentityFailure>());

      final failure = states[1] as IdentityFailure;
      expect(failure.message, 'Join room failed');
    });

    test('AcknowledgeReveal sets isFresh to false', () async {
      final getIdentity = _FakeGetIdentityUseCase(
        const DataSuccess(_identity),
        cachedResult: null,
      );
      final joinRoom = _FakeJoinRoomUseCase(DataSuccess(_room));

      bloc = IdentityBloc(getIdentity, joinRoom);

      bloc.add(const LoadIdentity('room-1'));
      getIdentity.cachedResult = _identity;
      await Future.delayed(Duration.zero);

      final states = <IdentityState>[];
      bloc.stream.listen(states.add);

      bloc.add(const AcknowledgeReveal());
      await Future.delayed(Duration.zero);

      expect(states, isNotEmpty);
      final acknowledged = states.last as IdentitySuccess;
      expect(acknowledged.isFresh, isFalse);
      expect(acknowledged.identity, _identity);
    });

    test('AcknowledgeReveal on non-success state does nothing', () async {
      bloc = IdentityBloc(
        _FakeGetIdentityUseCase(const DataSuccess(_identity)),
        _FakeJoinRoomUseCase(DataSuccess(_room)),
      );

      // Still in IdentityInitial — acknowledge should be a no-op
      final states = <IdentityState>[];
      bloc.stream.listen(states.add);

      bloc.add(const AcknowledgeReveal());
      await Future.delayed(Duration.zero);

      expect(states, isEmpty);
    });
  });
}
