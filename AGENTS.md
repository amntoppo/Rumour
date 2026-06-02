## Summary
- This is an Anonymous Room-Code Chat App. User can join room by code, users can chat in the room.

## Folder Structure
- lib
    - config/
        - routes/
        - theme/
    - core/
        - di/
        - usercase/
        - network/
        - data_state/
    - features/
        - chat_room/
            - domain/
                - entities/
                - repositories/
                - usercases/
            - data/
                - models/
                - repositories/
                - data_sources/
            - presentation/
                - pages/
                - widgets/
                - bloc/
        
    - shared/
        - widgets/


## Rules
- **State Management**: Mandatory use of **Bloc**. See [.agent/rules/state_management.md](file:///Users/aman/Documents/flutter/news_app/.agent/rules/state_management.md) for details.

## Tech Stack
- Flutter
- Dart
- Bloc
