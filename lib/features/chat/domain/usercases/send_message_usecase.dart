import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/usecase/use_case.dart';
import 'package:rumour_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';

class SendMessageParams {
  const SendMessageParams({
    required this.roomCode,
    required this.text,
    required this.sender,
  });

  final String roomCode;
  final String text;
  final IdentityEntity sender;
}

class SendMessageUseCase
    implements UseCase<DataState<void>, SendMessageParams> {
  SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<DataState<void>> call(SendMessageParams params) {
    return _repository.sendMessage(
      roomCode: params.roomCode,
      text: params.text,
      sender: params.sender,
    );
  }
}
