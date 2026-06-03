import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/usecase/use_case.dart';
import 'package:rumour_app/features/room/domain/entities/room_entity.dart';
import 'package:rumour_app/features/room/domain/repositories/room_repository.dart';

class JoinRoomUseCase extends UseCase<DataState<RoomEntity>, String> {
  JoinRoomUseCase(this._repository);

  final RoomRepository _repository;

  @override
  Future<DataState<RoomEntity>> call(String params) => _repository.joinRoom(params);
}

