import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/network/pagination.dart';
import 'package:rumour_app/core/usecase/use_case.dart';
import 'package:rumour_app/features/chat/domain/entities/message_entity.dart';
import 'package:rumour_app/features/chat/domain/repositories/chat_repository.dart';

class LoadMessagesParams {
  const LoadMessagesParams({
    required this.roomCode,
    required this.pageSize,
    this.after,
  });

  final String roomCode;
  final int pageSize;
  final QueryCursor? after;
}

class LoadMessagesUseCase
    implements UseCase<DataState<PagedData<MessageEntity>>, LoadMessagesParams> {
  LoadMessagesUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<DataState<PagedData<MessageEntity>>> call(
    LoadMessagesParams params,
  ) {
    return _repository.loadMessages(
      roomCode: params.roomCode,
      pageSize: params.pageSize,
      after: params.after,
    );
  }
}
