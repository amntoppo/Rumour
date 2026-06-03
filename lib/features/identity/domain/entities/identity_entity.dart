import 'package:equatable/equatable.dart';

/// Per-room anonymous identity from randomuser.me.
class IdentityEntity extends Equatable {
  const IdentityEntity({
    required this.id,
    required this.displayName,
    required this.username,
    required this.roomId,
    this.avatarUrl,
  });

  /// randomuser.me `login.uuid`
  final String id;

  final String displayName;
  final String username;
  final String roomId;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, displayName, username, roomId, avatarUrl];
}
