import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/features/identity/domain/usecases/get_identity_usecase.dart';
import 'package:rumour_app/features/identity/presentation/bloc/identity_event.dart';
import 'package:rumour_app/features/identity/presentation/bloc/identity_state.dart';

class IdentityBloc extends Bloc<IdentityEvent, IdentityState> {
  IdentityBloc(this._getIdentityUseCase) : super(IdentityInitial()) {
    on<LoadIdentity>(_onLoadIdentity);
    on<AcknowledgeReveal>(_onAcknowledgeReveal);
  }

  final GetIdentityUseCase _getIdentityUseCase;

  Future<void> _onLoadIdentity(
    LoadIdentity event,
    Emitter<IdentityState> emit,
  ) async {
    emit(IdentityLoading());
    final result = await _getIdentityUseCase(event.roomCode);
    switch (result) {
      case DataSuccess(:final data):
        emit(IdentitySuccess(data, isFresh: true));
      case DataFailure(:final error):
        emit(IdentityFailure(error.message));
      case DataLoading():
        break;
    }
  }

  void _onAcknowledgeReveal(
    AcknowledgeReveal event,
    Emitter<IdentityState> emit,
  ) {
    final current = state;
    if (current is IdentitySuccess) {
      emit(IdentitySuccess(current.identity, isFresh: false));
    }
  }
}
