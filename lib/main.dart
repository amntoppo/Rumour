import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rumour_app/core/di/injection_controller.dart';
import 'package:rumour_app/core/exceptions/firebase_exceptions.dart';
import 'package:rumour_app/core/routes/route_name.dart';
import 'package:rumour_app/core/routes/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await _initFirebase();   // Firebase must be ready before Firestore client registers
  await initDependencies();
  runApp(const MyApp());
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
  } on FirebaseException catch (e) {
    // duplicate-app happens on hot restart — safe to ignore.
    if (e.code != 'duplicate-app') {
      throw FirebaseInitException(e.message ?? 'Firebase failed to initialise.');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: RouteName.splashScreen,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
