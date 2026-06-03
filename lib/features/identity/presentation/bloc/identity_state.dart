import 'package:equatable/equatable.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';

sealed class IdentityState extends Equatable {
  const IdentityState();

  @override
  List<Object?> get props => [];
}

class IdentityInitial extends IdentityState {}

class IdentityLoading extends IdentityState {}

class IdentitySuccess extends IdentityState {
  const IdentitySuccess(this.identity, {required this.isFresh});
  final IdentityEntity identity;
  final bool isFresh;

  @override
  List<Object?> get props => [identity, isFresh];
}

class IdentityFailure extends IdentityState {
  const IdentityFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
