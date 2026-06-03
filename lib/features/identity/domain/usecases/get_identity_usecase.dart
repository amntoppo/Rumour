import 'package:rumour_app/core/data_state/data_state.dart';
import 'package:rumour_app/core/usecase/use_case.dart';
import 'package:rumour_app/features/identity/domain/entities/identity_entity.dart';
import 'package:rumour_app/features/identity/domain/repositories/identity_repository.dart';

class GetIdentityUseCase extends UseCase<DataState<IdentityEntity>, String> {
  GetIdentityUseCase(this._repository);

  final IdentityRepository _repository;

  @override
  Future<DataState<IdentityEntity>> call(String params) {
    return _repository.getOrFetchIdentity(params);
  }
}
