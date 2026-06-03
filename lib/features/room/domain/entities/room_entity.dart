import 'package:equatable/equatable.dart';

class RoomEntity extends Equatable {
  const RoomEntity({required this.code, required this.id});

  final String code;
  final String id;

  @override
  List<Object?> get props => [code, id];
}
