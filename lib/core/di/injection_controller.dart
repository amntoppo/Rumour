import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:rumour_app/core/local/local_client.dart';
import 'package:rumour_app/core/local/hive_data_source.dart';
import 'package:rumour_app/core/network/remote_client.dart';
import 'package:rumour_app/core/network/dio_client.dart';
import 'package:rumour_app/core/network/firebase_firestore_client.dart';
import 'package:rumour_app/core/network/firestore_client.dart';
import 'package:rumour_app/features/room/data/data_sources/firestore_room_data_source.dart';
import 'package:rumour_app/features/room/data/data_sources/room_remote_data_source.dart';
import 'package:rumour_app/features/room/data/repositories/room_repository_impl.dart';
import 'package:rumour_app/features/room/domain/repositories/room_repository.dart';
import 'package:rumour_app/features/room/domain/usercases/join_room_usecase.dart';
import 'package:rumour_app/features/room/presentation/bloc/join_room_bloc.dart';

// Identity feature imports
import 'package:rumour_app/features/identity/domain/repositories/identity_repository.dart';
import 'package:rumour_app/features/identity/domain/usecases/get_identity_usecase.dart';
import 'package:rumour_app/features/identity/data/data_sources/identity_local_data_source.dart';
import 'package:rumour_app/features/identity/data/data_sources/hive_identity_local_data_source.dart';
import 'package:rumour_app/features/identity/data/data_sources/identity_remote_data_source.dart';
import 'package:rumour_app/features/identity/data/data_sources/http_identity_remote_data_source.dart';
import 'package:rumour_app/features/identity/data/repositories/identity_repository_impl.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Local Storage ──────────────────────────────────────────────────────────
  final localClient = HiveDataSource();
  sl.registerLazySingleton<LocalClient>(() => localClient);

  // Generate and cache unique user UUID on app startup
  await _ensureUserUuid(localClient);

  // ── Network ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<RemoteClient>(
    () => DioClient(baseUrl: 'https://randomuser.me/api/'),
  );
  sl.registerLazySingleton<FirestoreClient>(() => FirebaseFirestoreClient());

  // ── Room feature ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<RoomRemoteDataSource>(
    () => FirestoreRoomDataSource(sl(), sl()),
  );
  sl.registerLazySingleton<RoomRepository>(
    () => RoomRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => JoinRoomUseCase(sl()));
  sl.registerFactory(() => JoinRoomBloc(sl()));

  // ── Identity feature ───────────────────────────────────────────────────────
  sl.registerLazySingleton<IdentityLocalDataSource>(
    () => HiveIdentityLocalDataSource(sl()),
  );
  sl.registerLazySingleton<IdentityRemoteDataSource>(
    () => HttpIdentityRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<IdentityRepository>(
    () => IdentityRepositoryImpl(
      local: sl(),
      remote: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetIdentityUseCase(sl()));
}

Future<void> _ensureUserUuid(LocalClient localClient) async {
  final uuid = await localClient.fetchOne<String>(
    'user/uuid',
    (data) => data['uuid'] as String,
  );
  if (uuid == null) {
    final newUuid = const Uuid().v4();
    await localClient.save('user/uuid', newUuid, (id) => {'uuid': id});
  }
}

