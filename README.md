# Rumour — Anonymous Room Chat

A Flutter app that lets users join a room by code and chat anonymously. Every session generates a random identity (name + avatar) via [randomuser.me](https://randomuser.me), so no sign-up or personal data is required.

## Demo & Downloads

- **Video Demonstration**: [Watch Video on Google Drive](https://drive.google.com/file/d/19rOhNIQYIKezc0abtok_65ATSv4sGerF/view?usp=drive_link)
- **APK Download**: [Download Android APK from Google Drive](https://drive.google.com/file/d/1DNXL77Brr1-_Wg_HygEIkUQ38CqDt_ac/view?usp=sharing)

---

## Features

| Feature | Description |
|---|---|
| **Anonymous identity** | A random display name, username, and avatar are fetched from randomuser.me on every new room join |
| **Room join by code** | Enter a 6-digit room code to create or join a room instantly |
| **Real-time chat** | Messages stream live via Firestore's `snapshots()` listener |
| **Cursor-based pagination** | Older messages are fetched in pages of 30 on scroll-to-top |
| **Offline persistence** | Last known messages and identity are cached in Hive — visible even without connectivity |
| **Theming** | Full light/dark theme support via `AppPalette` and `AppTypography` ThemeExtensions |
| **Optimistic send** | Sent messages appear immediately with a pending clock icon until Firestore confirms |

---

## Tech Stack

- **Flutter** + **Dart**
- **State management**: `flutter_bloc` (BLoC pattern)
- **Remote DB**: Cloud Firestore (`cloud_firestore`)
- **Local cache**: Hive (`hive_flutter`)
- **HTTP**: Dio (`dio`) — used for the randomuser.me identity API
- **DI**: GetIt (`get_it`)
- **Anonymous identity API**: [randomuser.me](https://randomuser.me/api/)

---

## Codebase Structure

```
lib/
├── config/
│   └── routes/            # Named route definitions and generation
│
├── core/
│   ├── constants/         # AppAssets (SVG/icon paths)
│   ├── data_state/        # DataState sealed class (DataSuccess / DataFailure / DataLoading)
│   ├── di/
│   │   └── injection_controller.dart   # GetIt wiring for all features
│   ├── exceptions/        # Typed exceptions (NetworkException, FirestorePermissionException, …)
│   ├── extensions/        # BuildContext extensions (context.palette, context.typography)
│   ├── local/
│   │   ├── local_client.dart       # Abstract local storage interface (get/put/post/patch/delete)
│   │   └── hive_data_source.dart   # Hive implementation of LocalClient
│   ├── network/
│   │   ├── remote_client.dart           # Abstract HTTP interface (get/post/put/patch/delete)
│   │   ├── dio_client.dart              # Dio implementation of RemoteClient
│   │   ├── firestore_client.dart        # Extends RemoteClient with streams, pagination & merge
│   │   ├── firebase_firestore_client.dart  # Firestore implementation of FirestoreClient
│   │   └── pagination.dart              # PagedData<T>, QueryCursor types
│   ├── theme/
│   │   ├── app_palette.dart     # Semantic colour tokens (dark + light)
│   │   ├── app_typography.dart  # Named TextStyle set (dark + light)
│   │   ├── app_theme.dart       # ThemeData builder for light/dark
│   │   └── app_gradients.dart   # Shared gradient helpers
│   └── usecase/
│       └── use_case.dart        # Base UseCase<Output, Input> abstract class
│
├── features/
│   │
│   ├── identity/          # Random identity generation & caching
│   │   ├── domain/
│   │   │   ├── entities/identity_entity.dart
│   │   │   ├── repositories/identity_repository.dart
│   │   │   └── usecases/get_identity_usecase.dart
│   │   ├── data/
│   │   │   ├── models/identity_model.dart           # fromRandomUser / fromCache / toCacheJson
│   │   │   ├── data_sources/
│   │   │   │   ├── identity_remote_data_source.dart
│   │   │   │   ├── http_identity_remote_data_source.dart  # Dio → randomuser.me
│   │   │   │   ├── identity_local_data_source.dart
│   │   │   │   └── hive_identity_local_data_source.dart   # Hive cache
│   │   │   └── repositories/identity_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/      # IdentityBloc / IdentityEvent / IdentityState
│   │       └── widgets/   # IdentityRevealOverlay, IdentityErrorView
│   │
│   ├── room/              # Room creation & joining
│   │   ├── domain/
│   │   │   ├── entities/room_entity.dart
│   │   │   ├── repositories/room_repository.dart
│   │   │   └── usecases/join_room_usecase.dart
│   │   ├── data/
│   │   │   ├── models/room_dto.dart
│   │   │   ├── data_sources/
│   │   │   │   ├── room_remote_data_source.dart
│   │   │   │   └── firestore_room_data_source.dart
│   │   │   └── repositories/room_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/      # JoinRoomBloc, RoomCodeFormBloc
│   │       ├── pages/     # RoomScreen
│   │       └── widgets/   # RoomCodeInput
│   │
│   └── chat/              # Real-time messaging
│       ├── domain/
│       │   ├── entities/message_entity.dart
│       │   ├── repositories/chat_repository.dart
│       │   └── usecases/  # LoadMessagesUseCase, SendMessageUseCase
│       ├── data/
│       │   ├── models/message_model.dart
│       │   ├── data_sources/
│       │   │   ├── chat_remote_data_source.dart
│       │   │   ├── firestore_chat_remote_data_source.dart
│       │   │   ├── chat_local_data_source.dart
│       │   │   └── hive_chat_local_data_source.dart
│       │   └── repositories/chat_repository_impl.dart
│       └── presentation/
│           ├── bloc/      # ChatBloc / ChatEvent / ChatState / ComposerBloc
│           ├── pages/     # ChatScreen
│           └── widgets/   # ChatMessagesList, MessageRow, ChatBubble, ChatComposer, …
│
└── shared/
    └── widgets/
        └── app_loading_indicator.dart   # Three-dot animated loading indicator
```

---

## Firebase Cloud Firestore Data Structure

```
rooms/
└── {roomCode}/                          # Document — roomCode is the document ID
    ├── roomCode:    string
    ├── createdAt:   timestamp           # server timestamp
    ├── createdBy:   string              # user UUID
    └── memberCount: number

    identities/
    └── {userUuid}/                      # Document — one per member
        ├── id:          string
        ├── displayName: string
        ├── username:    string
        ├── roomId:      string
        └── avatarUrl?:  string

    messages/
    └── {messageId}/                     # Auto-ID document
        ├── text:       string
        ├── senderId:   string
        ├── senderName: string
        ├── avatarUrl?: string
        ├── type:       string           # "text" (extensible)
        └── createdAt:  timestamp        # server timestamp
```

### Security notes
- `memberCount` is incremented inside a Firestore **transaction** (see `incrementAndSave`) so concurrent joins are safe
- The `createdAt` field on messages and rooms is always written with `FieldValue.serverTimestamp()` — the client never trusts its own clock for ordering

---

## Pagination Logic

The chat screen uses **cursor-based pagination** backed by Firestore document snapshots.

### Page size
`ChatBloc._pageSize = 30` messages per fetch.

### Startup sequence (inside `ChatBloc._onSubscribed`)

```
1. Emit ChatLoading
2. Load Hive cache → emit ChatLoaded (instant display)
3. Subscribe to Firestore stream (latest 30 messages, real-time)
4. Fetch first remote page (sets the initial QueryCursor)
5. Merge remote page with any cached/pending messages → emit ChatLoaded
6. Cache the merged list back to Hive
```

### Load-more sequence (inside `ChatBloc._onLoadMoreRequested`)

```
1. Guard: skip if already loading, hasMore == false, or cursor == null
2. Emit ChatLoading (preserves existing messages)
3. Call LoadMessagesUseCase with current cursor
4. Append new page to state.messages (de-duped by message ID)
5. Update cursor to nextCursor returned by Firestore
6. Set hasMore = false when the page returns fewer items than pageSize
7. Cache the extended list to Hive
```

### UI trigger

`ChatMessagesList` uses a `ListView.builder` reversed list. When the pagination footer item is rendered (the last index), a `Future.microtask` fires `ChatLoadMoreRequested`. During loading, the footer shows a small `AppLoadingIndicator`.

### Cursor implementation

`FirebaseFirestoreClient.fetchPage` wraps the last `DocumentSnapshot` in `_DocumentCursor extends QueryCursor` and passes it to `.startAfterDocument()` on the next query. This is internal to the network layer — the rest of the app only sees the opaque `QueryCursor` type.

---

## Offline Persistence

Two layers work together:

### Firestore disk cache
Firestore's `persistenceEnabled: true` is set in `FirebaseFirestoreClient.configure()` with `cacheSizeBytes: CACHE_SIZE_UNLIMITED`. This means Firestore automatically serves reads from disk when offline and syncs writes when reconnected.

### Hive application cache
A separate Hive-based cache in `HiveDataSource` stores:

| Box | Key | Content |
|---|---|---|
| `messages` | `{roomCode}` | Serialised `List<MessageModel>` (latest merged page) |
| `identities` | `{roomId}` | Serialised `IdentityModel` for the current session |
| `user` | `uuid` | Stable device UUID generated on first launch |

**Write strategy**: after every successful remote fetch or live update, `ChatRepository.cacheMessages` writes the latest merged list to Hive. On the next app launch, the BLoC reads Hive first (step 2 of the startup sequence above) and renders messages immediately — before any network response arrives.

**Identity caching**: `IdentityRepositoryImpl` checks Hive first. If an identity is found for the room it is returned immediately without hitting randomuser.me, ensuring the user always has the same anonymous persona for a given room across sessions.
