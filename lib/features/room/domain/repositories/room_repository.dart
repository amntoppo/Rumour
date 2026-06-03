import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/features/room/domain/entities/room_entity.dart';

abstract interface class RoomRepository {
  Future<DataState<RoomEntity>> joinRoom(String code);
}

