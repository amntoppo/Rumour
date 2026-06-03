import 'package:flutter/material.dart';
import 'package:rumour_app/core/routes/route_name.dart';
import 'package:rumour_app/splash_screen.dart';
import 'package:rumour_app/features/chat/presentation/pages/chat_screen.dart';
import 'package:rumour_app/features/room/presentation/pages/room_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteName.roomScreen:
        return MaterialPageRoute(builder: (_) => RoomScreen());
      case RouteName.chatScreen:
        final roomCode = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ChatScreen(roomCode: roomCode));

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
